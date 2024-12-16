#!/bin/bash

# set -e

. ./constants.sh

caffeinate -s -i -d -w $$ &

TARGET=$1
COUNT=$2

RESULTS_ARRAY=()

OUTPUT_DIR="$(pwd)/output/$(date -Iminutes)"
echo "Output dir: $OUTPUT_DIR"
echo

mkdir -p $OUTPUT_DIR
cp package.json capacitor.config.ts $OUTPUT_DIR

for i in $(seq 1 $COUNT); do
  echo "Iteration $i"
  if sh ./go.sh $TARGET $OUTPUT_DIR $i; then
    RESULTS_ARRAY+=(".")
  else
    if [ $? -eq $EXIT_TEST_FAILED ]; then
      RESULTS_ARRAY+=("F")
    else
      RESULTS_ARRAY+=('!')
    fi
  fi
  
  echo
done

echo "${RESULTS_ARRAY[@]}" | sed 's/ //g' > $OUTPUT_DIR/summary.txt
cat $OUTPUT_DIR/summary.txt