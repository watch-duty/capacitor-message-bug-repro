#!/bin/bash

# set -e

. ./constants.sh

TARGET=$1
OUTPUT_DIR=${2:-/tmp}
ITERATION=${3:-1}

PNG_PATH=$OUTPUT_DIR/$ITERATION.png
TXT_PATH=$OUTPUT_DIR/$ITERATION.txt

rm -f $PNG_PATH $TXT_PATH

set -e

if [ -z "$SKIP_BUILD" ]; then
  sh ./clean_and_run.sh $TARGET
else
  # terminate and re-install the app from the local build
  xcrun simctl uninstall $TARGET org.watchduty.capmessagebugrepro
  sleep ${SIMULATED_BUILD_SLEEP_SECONDS:-0}
  xcrun simctl install $TARGET ios/DerivedData/$TARGET/Build/Products/Debug-iphonesimulator/App.app
  xcrun simctl launch $TARGET org.watchduty.capmessagebugrepro
fi
sleep 5

if ! sh ./try_repro.sh $TARGET; then
  exit $EXIT_TEST_INTERNAL_ERROR
fi
sleep 2

# take a screenshot
xcrun simctl io $TARGET screenshot $PNG_PATH

# run ocr on it
shortcuts run "Grab Text from Image" --input-path $PNG_PATH --output-path $TXT_PATH

set +e

if grep "Did it work?" $TXT_PATH; then
  if grep -q "YES IT WORKED" $TXT_PATH; then
    exit $EXIT_TEST_SUCCESS
  else
    exit $EXIT_TEST_FAILED
  fi
else
  # some issue with the test, since OCR didn't return expected text
  exit $EXIT_TEST_INTERNAL_ERROR
fi

