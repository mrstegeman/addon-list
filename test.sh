#!/bin/bash

set -e -x

COMMIT_RANGE=$(python -c \
    "import json, os; \
    data = json.loads(open(os.environ['GITHUB_EVENT_PATH']).read()); \
    print('{}..{}'.format(data['before'], data['after']))")

echo "$COMMIT_RANGE"
CHANGED_FILES=($(git diff --name-only $COMMIT_RANGE))
ADDONS_CHANGED=
SCHEMA_CHANGED=0
CHECKER_CHANGED=0

echo "Changed:" "${CHANGED_FILES[@]}"
echo

for file in ${CHANGED_FILES[@]}; do
    if [[ "$file" =~ ^addons/([^/]+).json ]]; then
        ADDONS_CHANGED="$ADDONS_CHANGED ${BASH_REMATCH[1]}"
    elif [ "$file" = "schema.json" ]; then
        SCHEMA_CHANGED=1
    elif [ "$file" = "tools/check-list.py" ]; then
        CHECKER_CHANGED=1
    fi
done

if [[ $SCHEMA_CHANGED == 1 || $CHECKER_CHANGED == 1 ]]; then
    ./tools/check-list.py
elif [ -n "$ADDONS_CHANGED" ]; then
    ./tools/check-list.py $ADDONS_CHANGED
fi
