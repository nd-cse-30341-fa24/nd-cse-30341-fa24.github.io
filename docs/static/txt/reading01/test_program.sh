#!/bin/bash

POINTS=2

compare() {
    python3 - "$@" <<EOF
import itertools, sys
print(sum(1 for a, b in itertools.zip_longest(sys.argv[1].split(), sys.argv[2].split()) if a != b))
EOF
}

output() {
    cat <<EOF | base64 -d
RmFsc2UKRmFsc2UKRmFsc2UKVHJ1ZQpGYWxzZQpUcnVlCkZhbHNlClRydWUKVHJ1ZQpGYWxzZQpUcnVlCkZhbHNlCg==
EOF
}

echo "Testing reading01 program ... "

DIFF=$(compare "$(./program)" "$(output)")
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
