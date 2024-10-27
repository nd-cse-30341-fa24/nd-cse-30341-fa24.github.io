#!/bin/bash

WORKSPACE=/tmp/reading12.$(id -u)
FAILURES=0
POINTS=2

error() {
    echo "$@"
    [ -r $WORKSPACE/test ] && (echo; cat $WORKSPACE/test; echo)
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE

    if [ "$STATUS" -eq 0 ]; then
        echo "  Status Success"
    else
        echo "  Status Failure"
    fi

    echo
    exit $STATUS
}

disk1() {
    printf '12345670'
}

disk2() {
    printf '1234567012345670'
}

disk3() {
    printf '1234567089ABCDE@'
}

disk4() {
    printf 'abcdefg`hijklmnoopqrstunvwxyz12y345678920      0'
}

# Main execution

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing reading12 program..."

# disk2

printf " %-60s ... " "disk1"
disk1 | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk1 (inconsistent byte)"
disk1 | sed 's/1/0/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 1 ]; then
    error "Failure (Status $STATUS != 1)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk1 (inconsistent parity)"
disk1 | sed 's/0/1/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 1 ]; then
    error "Failure (Status $STATUS != 1)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk1 (swapped bytes)"
disk1 | sed 's/12/21/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

# disk2

printf " %-60s ... " "disk2"
disk2 | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk2 (inconsistent byte)"
disk2 | sed 's/1/0/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 2 ]; then
    error "Failure (Status $STATUS != 2)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk2 (inconsistent parity)"
disk2 | sed 's/0/1/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 2 ]; then
    error "Failure (Status $STATUS != 2)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk2 (swapped bytes)"
disk2 | sed 's/12/21/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

# disk3

printf " %-60s ... " "disk3"
disk3 | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk3 (inconsistent byte)"
disk3 | sed 's/A/B/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 1 ]; then
    error "Failure (Status $STATUS != 1)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk3 (inconsistent parity)"
disk3 | sed 's/@/#/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 1 ]; then
    error "Failure (Status $STATUS != 1)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk3 (swapped bytes)"
disk3 | sed 's/AB/BA/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

# disk4

printf " %-60s ... " "disk4"
disk4 | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk4 (inconsistent byte)"
disk4 | sed 's/2/0/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 2 ]; then
    error "Failure (Status $STATUS != 2)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk4 (inconsistent parity)"
disk4 | sed 's/`/!/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 1 ]; then
    error "Failure (Status $STATUS != 1)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

printf " %-60s ... " "disk4 (swapped bytes)"
disk4 | sed 's/pq/qp/g' | valgrind --leak-check=full ./program &> $WORKSPACE/test
STATUS=$?
if [ $STATUS -ne 0 ]; then
    error "Failure (Status $STATUS != 0)"
elif [ $(awk '/ERROR SUMMARY:/ {print $4}' $WORKSPACE/test) -ne 0 ]; then
    error "Failure (Valgrind)"
else
    echo "Success"
fi

TESTS=$(($(grep -c Success $0) - 1))
SCORE=$(python3 <<EOF
print("{:0.2f} / $POINTS.00".format(($TESTS - $FAILURES) * $POINTS.0 / $TESTS))
EOF
)
echo "   Score $SCORE"
