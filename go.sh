#!/bin/bash

# set -e

TARGET=$1
OUTPUT_DIR=${2:-/tmp}
ITERATION=${3:-1}

PNG_PATH=$OUTPUT_DIR/$ITERATION.png
TXT_PATH=$OUTPUT_DIR/$ITERATION.txt

rm -f $PNG_PATH $TXT_PATH

if [ -z "$SKIP_BUILD" ]; then
  sh ./clean_and_run.sh $TARGET
  sleep 5
else
  # terminate and re-install the app from the local build
  xcrun simctl uninstall $TARGET org.watchduty.capmessagebugrepro
  xcrun simctl install $TARGET ios/DerivedData/$TARGET/Build/Products/Debug-iphonesimulator/App.app
  xcrun simctl launch $TARGET org.watchduty.capmessagebugrepro
  sleep 5
fi

sh ./try_repro.sh $TARGET
sleep 2

# take a screenshot
xcrun simctl io $TARGET screenshot $PNG_PATH

# run ocr on it
set -e
shortcuts run "Grab Text from Image" --input-path $PNG_PATH --output-path $TXT_PATH
set +e

if grep "Did it work?" $TXT_PATH; then
  if grep -q "YES IT WORKED" $TXT_PATH; then
    exit 0
  else
    exit 1
  fi
else
  # some issue with the test, since OCR didn't return expected text
  exit 2
fi

