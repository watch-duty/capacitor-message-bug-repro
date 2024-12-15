#!/bin/bash

# set -e

caffeinate -s -w $$ &

TARGET=$1
COUNT=$2

RESULTS_ARRAY=()

for i in $(seq 1 $COUNT); do
  echo "Iteration $i"
  if sh ./go.sh $TARGET; then
    RESULTS_ARRAY+=(".")
  else
    RESULTS_ARRAY+=("F")
  fi
done

echo
echo -n "Results: "
echo "${RESULTS_ARRAY[@]}" | sed 's/ //g'