#!/bin/bash

set -e

TARGET=$1

rm -f /tmp/capmessagebug.*

sh ./clean_and_run.sh $TARGET
sleep 5
sh ./try_repro.sh $TARGET
sleep 2

# take a screenshot
xcrun simctl io $TARGET screenshot /tmp/capmessagebug.png

# run ocr on it
shortcuts run "Grab Text from Clipboard Image" --input-path /tmp/capmessagebug.png --output-path /tmp/capmessagebug.txt

if grep "YES IT WORKED" /tmp/capmessagebug.txt; then
  echo "SUCCESS"
else
  echo "FAILURE"
fi