#!/bin/bash

WORKSPACE=/tmp/exam02.$(id -u)
FAILURES=0
POINTS=3
DESTINATION="."
CONCURRENCY=2

case $(uname) in
Darwin)
    SHA1SUM=shasum
    ;;
*)
    SHA1SUM=sha1sum
    ;;
esac

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE
    rm -f homework*.html

    if [ "$STATUS" -eq 0 ]; then
        echo "  Status Success"
    else
        echo "  Status Failure"
    fi

    echo
    exit $STATUS
}

grep_all() {
    for pattern in $1; do
	if ! grep -q -E "$pattern" $2; then
	    echo "FAILURE: Missing '$pattern' in '$2'" > $WORKSPACE/test
	    return 1;
	fi
    done
    return 0;
}

grep_any() {
    for pattern in $1; do
	if grep -q -E "$pattern" $2; then
	    echo "FAILURE: Contains '$pattern' in '$2'" > $WORKSPACE/test
	    return 1;
	fi
    done
    return 0;
}

sha1sums() {
    cat <<EOF
66bb4c5c4e03d66a3761dda75c7449e23cacda0f  homework01.html
de3712003bda435b00c5525c9f2b234cc5ac74b0  homework02.html
c66b6eb9c9e44f749d5295a611b9ad58f4db5fa5  homework03.html
2bc6903aef2b39285b92f50ff34626ac15525d46  homework04.html
61b7dbf0bb3e4cf5bb8ad2c6df1acf326b1b2c6c  homework05.html
fd6515fb93175ff8a1c6f603662b81c6db96124e  homework06.html
3b958ac0d14a7bb27ea1fb69367ac82353ff781a  homework07.html
e6f121bd451ce8c399a908ff656e95266937170e  homework08.html
963894daadedb26e0cacc1e1b5644a9437062696  homework09.html
4521cbc2027fb10bb88421a3ea307485673869c0  homework10.html
EOF
}

check_sha1sums() {
    for url in $URLS; do
	name=$(basename $url)
	if [ "$name" = "homeworkXX.html" ]; then
	    continue
	fi

	if [ "$($SHA1SUM $DESTINATION/$name | awk '{print $1}')" != "$(sha1sums | grep $name | awk '{print $1}')" ]; then
	    return 1
	fi
    done
    return 0
}

check_concurrency() {
    python3 <<EOF
import sys
active=0
for line in open('$WORKSPACE/test'):
    if line.startswith('Start'):
        active += 1
    elif line.startswith('Finish'):
        active -= 1

    if active > $CONCURRENCY:
        sys.exit(1)

sys.exit(0)
EOF
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing exam02 program..."


printf " %-60s ... " "program"
valgrind --leak-check=full ./program &> $WORKSPACE/test
if [ $? -ne 1 ]; then
    error "Failure (Exit Code)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test | sort -rn | tail -n 1) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi


URLS="https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework06.html"
printf " %-60s ... " "program [$(echo $URLS | wc -w)]"
valgrind --leak-check=full ./program $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test | sort -rn | tail -n 1) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! check_sha1sums; then
    error "Failure (Contents)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

printf " %-60s ... " "program [$(echo $URLS | wc -w)] (strace)"
strace -e clone,clone3 ./program $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $(echo $URLS | wc -w) -a $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $CONCURRENCY ]; then
    error "Failure (Strace)"
else
    echo "Success"
fi

URLS="https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework06.html
https://fake.asdf/homeworkXX.html"
printf " %-60s ... " "program [$(echo $URLS | wc -w)]"
valgrind --leak-check=full ./program $URLS &> $WORKSPACE/test
if [ $? -eq 0 ]; then
    error "Failure (Exit Code)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test | sort -rn | tail -n 1) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! check_sha1sums; then
    error "Failure (Contents)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

printf " %-60s ... " "program [$(echo $URLS | wc -w)] (strace)"
strace -e clone,clone3 ./program $URLS &> $WORKSPACE/test
if [ $? -eq 0 ]; then
    error "Failure (Exit Code)"
elif [ $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $(echo $URLS | wc -w) -a $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $CONCURRENCY ]; then
    error "Failure (Strace)"
else
    echo "Success"
fi

URLS="https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework01.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework02.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework03.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework04.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework05.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework06.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework07.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework08.html"
printf " %-60s ... " "program [$(echo $URLS | wc -w)]"
valgrind --leak-check=full ./program $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test | sort -rn | tail -n 1) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! check_sha1sums; then
    error "Failure (Contents)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

printf " %-60s ... " "program [$(echo $URLS | wc -w)] (strace)"
strace -e clone,clone3 ./program $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $(echo $URLS | wc -w) -a $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $CONCURRENCY ]; then
    error "Failure (Strace)"
else
    echo "Success"
fi


URLS="https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework01.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework02.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework03.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework04.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework05.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework06.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework07.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework08.html"
DESTINATION=$WORKSPACE/html
printf " %-60s ... " "program -d $DESTINATION [$(echo $URLS | wc -w)]"
valgrind --leak-check=full ./program -d $DESTINATION $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test | sort -rn | tail -n 1) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! check_sha1sums; then
    error "Failure (Contents)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

printf " %-60s ... " "program -d $DESTINATION [$(echo $URLS | wc -w)] (strace)"
strace -e clone,clone3 ./program -d $DESTINATION $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $(echo $URLS | wc -w) -a $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $CONCURRENCY ]; then
    error "Failure (Strace)"
else
    echo "Success"
fi


URLS="https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework01.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework02.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework03.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework04.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework05.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework06.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework07.html
https://www3.nd.edu/~pbui/teaching/cse.20289.sp24/homework08.html"
DESTINATION=$WORKSPACE/html
CONCURRENCY=4
printf " %-60s ... " "program -d $DESTINATION -n $CONCURRENCY [$(echo $URLS | wc -w)]"
valgrind --leak-check=full ./program -d $DESTINATION -n $CONCURRENCY $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test | sort -rn | tail -n 1) -ne 0 ]; then
    error "Failure (Valgrind)"
elif ! check_sha1sums; then
    error "Failure (Contents)"
elif ! check_concurrency; then
    error "Failure (Concurrency)"
else
    echo "Success"
fi

printf " %-60s ... " "program -d $DESTINATION -n $CONCURRENCY [$(echo $URLS | wc -w)] (strace)"
strace -e clone,clone3 ./program -d $DESTINATION -n $CONCURRENCY $URLS &> $WORKSPACE/test
if [ $? -ne 0 ]; then
    error "Failure (Exit Code)"
elif [ $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $(echo $URLS | wc -w) -a $(grep -v ENOSYS $WORKSPACE/test | grep -c CLONE_THREAD) -ne $CONCURRENCY ]; then
    error "Failure (Strace)"
else
    echo "Success"
fi


TESTS=$(($(grep -c Success $0) - 1))
SCORE=$(python3 <<EOF
print("{:0.2f} / $POINTS.00".format(($TESTS - $FAILURES) * $POINTS.00 / $TESTS))
EOF
)
echo "   Score $SCORE"
