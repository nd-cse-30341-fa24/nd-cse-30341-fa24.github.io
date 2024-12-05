#!/bin/bash

WORKSPACE=/tmp/exam03.$(id -u)
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

output_0() {
    # 14 64 4
    cat <<EOF
VA Bytes: 16.00 KB
VA Pages: 256 bytes
VPN Bits: 8
Offset Bits: 6
Page Table Entries: 256 bytes
Page Table Size: 1.00 KB
Page Table Pages: 16
Page Directory Entries: 16
PDI Bits: 4
PTI Bits: 4
Page Directory Size: 64 bytes
Page Directory Pages: 1
EOF
}

output_1() {
    # 30 4096 4
    cat <<EOF
VA Bytes: 1.00 GB
VA Pages: 256.00 KB
VPN Bits: 18
Offset Bits: 12
Page Table Entries: 256.00 KB
Page Table Size: 1.00 MB
Page Table Pages: 256
Page Directory Entries: 256
PDI Bits: 8
PTI Bits: 10
Page Directory Size: 1.00 KB
Page Directory Pages: 1
EOF
}

output_2() {
    # 28 2048 4
    cat <<EOF
VA Bytes: 256.00 MB
VA Pages: 128.00 KB
VPN Bits: 17
Offset Bits: 11
Page Table Entries: 128.00 KB
Page Table Size: 512.00 KB
Page Table Pages: 256
Page Directory Entries: 256
PDI Bits: 8
PTI Bits: 9
Page Directory Size: 1.00 KB
Page Directory Pages: 1
EOF
}

mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing exam03 vms..."

ARGS="14 64 4"
printf " %-60s ... " "vms $ARGS"
diff -y <(./vms.py $ARGS) <(output_0) > $WORKSPACE/test 2>/dev/null
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    echo "Success"
fi

ARGS="30 4096 4"
printf " %-60s ... " "vms $ARGS"
diff -y <(./vms.py $ARGS) <(output_1) > $WORKSPACE/test 2>/dev/null
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    echo "Success"
fi

ARGS="28 2048 4"
printf " %-60s ... " "vms $ARGS"
diff -y <(./vms.py $ARGS) <(output_2) > $WORKSPACE/test 2>/dev/null
if [ $? -ne 0 ]; then
    error "Failure (Output)"
else
    echo "Success"
fi

TESTS=$(($(grep -c Success $0) - 2))
SCORE=$(python3 <<EOF
print("{:0.2f} / $POINTS.00".format(($TESTS - $FAILURES) * $POINTS.00 / $TESTS))
EOF
)
echo "   Score $SCORE"
