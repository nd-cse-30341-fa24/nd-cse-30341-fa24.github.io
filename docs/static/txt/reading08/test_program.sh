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
    '1000 0100 0000 1010',
    '1000 1111 1111 1111',
    '0100 0000 0010 0010',
    '0100 1010 1010 1010',
    '0000 0011 0110 0110',
    '0000 1100 0011 0011',
    '1100 0001 1001 1011',
    '1100 1011 1101 1110',
]

with os.fdopen(sys.stdout.fileno(), 'wb') as fs:
    for virtual_address in VIRTUAL_ADDRESSES:
        virtual_address = virtual_address.replace(' ', '')
        virtual_address = int(virtual_address, 2)

        fs.write(virtual_address.to_bytes(2, byteorder='little'))
EOF
}

output() {
    cat <<EOF | base64 -d
VkFbODQwYV0gLT4gUEFbOTQwYV0KVkFbOGZmZl0gLT4gUEFbOWZmZl0gU2VnbWVudGF0aW9uIEZh
dWx0ClZBWzQwMjJdIC0+IFBBWzg4MjJdClZBWzRhYWFdIC0+IFBBWzkyYWFdIFNlZ21lbnRhdGlv
biBGYXVsdApWQVswMzY2XSAtPiBQQVs4MzY2XQpWQVswYzMzXSAtPiBQQVs4YzMzXSBTZWdtZW50
YXRpb24gRmF1bHQKVkFbYzE5Yl0gLT4gUEFbNzE5Yl0KVkFbY2JkZV0gLT4gUEFbN2JkZV0gU2Vn
bWVudGF0aW9uIEZhdWx0Cg==
EOF
}

echo "Testing reading08 program ... "

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
