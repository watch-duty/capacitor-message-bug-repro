#!/bin/bash

# set -x
set -e

TARGET=$1

# put our app in the background by launching Files
xcrun simctl launch $TARGET com.apple.DocumentsApp
sleep 5

# kill the WebContent process on the simulator
kill $(pgrep -P $(pgrep launchd_sim) 'com.apple.WebKit.WebContent')
if pgrep -P $(pgrep launchd_sim) 'com.apple.WebKit.WebContent'; then
  echo "ERROR: Failed to kill WebContent process, or more than one running"
  exit 1
fi
sleep 5

if pgrep -P $(pgrep launchd_sim) 'com.apple.WebKit.WebContent'; then
  echo "ERROR: WebContent process restarted before expected"
  exit 1
fi

# open our app with a deeplink
xcrun simctl openurl $TARGET "capmessagebug://test"
sleep 1

# signal to the app that the test is complete
xcrun simctl openurl $TARGET "capmessagebug://complete"

set +e