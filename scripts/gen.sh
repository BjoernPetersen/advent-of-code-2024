#!/usr/bin/env bash

set -eu

N=$(printf '%02d' "$1")
mkdir "examples/$N"
touch "examples/$N/instructions-1.txt"
mkdir -p "inputs"
touch "inputs/$N.txt"

for FILE in $(find lib test -type f -name "*.template")
do
  TARGET_FILE="${FILE%template}.dart"
  TARGET_FILE="${TARGET_FILE/N/$N}"
  sed "s/%N/2/g" "$FILE" > "$TARGET_FILE"
done
