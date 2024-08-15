#!/bin/bash

POINTS=2

output() {
    cat <<EOF | base64 -d
RmFsc2UKRmFsc2UKRmFsc2UKVHJ1ZQpGYWxzZQpUcnVlCkZhbHNlClRydWUKVHJ1ZQpGYWxzZQpUcnVlCkZhbHNlCg==
EOF
}

echo "Testing reading01 program ... "

DIFF=$(diff <(./program 2> /dev/null) <(output) | grep -E "^[><]" | wc -l)
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
