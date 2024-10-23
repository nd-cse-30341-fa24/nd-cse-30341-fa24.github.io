#!/bin/bash

POINTS=2

compare() {
    python3 - "$@" <<EOF
import itertools, sys
print(sum(1 for a, b in itertools.zip_longest(sys.argv[1].split(), sys.argv[2].split()) if a != b))
EOF
}

input() {
    python3 <<EOF
import os
import sys
VIRTUAL_ADDRESSES = [
    '0010 0100',
    '1000 0001',
    '0000 0101',
    '1100 1111',
    '0011 1100',
    '0001 1001',
]

with os.fdopen(sys.stdout.fileno(), 'wb') as fs:
    for virtual_address in VIRTUAL_ADDRESSES:
        virtual_address = virtual_address.replace(' ', '')
        virtual_address = int(virtual_address, 2)

        fs.write(virtual_address.to_bytes(1, byteorder='little'))
EOF
}

output() {
    cat <<EOF | base64 -d
VkFbMjRdIC0+IFBBWzU0XQpWQVs4MV0gLT4gUEFbMDFdIFNlZ21lbnRhdGlvbiBGYXVsdApWQVsw
NV0gLT4gUEFbMzVdClZBW2NmXSAtPiBQQVswZl0gU2VnbWVudGF0aW9uIEZhdWx0ClZBWzNjXSAt
PiBQQVsyY10gUHJvdGVjdGlvbiBGYXVsdApWQVsxOV0gLT4gUEFbNzldCg==
EOF
}

echo "Testing reading09 program ... "

DIFF=$(compare "$(input | ./program 2> /dev/null)" "$(output)")
COUNT=$(output | wc -l)
SCORE=$(python3 <<EOF
print("{:0.2f} / $POINTS.00".format(($COUNT - $DIFF) * $POINTS.0 / $COUNT.0))
EOF
)
echo "   Score $SCORE"

if [ "$DIFF" -eq 0 ]; then
    echo "  Status Success"
else
    echo "  Status Failure"
fi

echo
exit $DIFF
