#!/bin/bash

# set -x

TARGET=$1

# put our app in the background by launching Files
xcrun simctl launch $TARGET com.apple.DocumentsApp
sleep 5

# kill the WebContent process on the simulator
kill $(pgrep -P $(pgrep launchd_sim) 'com.apple.WebKit.WebContent')
sleep 5

# open our app with a deeplink
xcrun simctl openurl $TARGET "capmessagebug://test"
sleep 1

# signal to the app that the test is complete
xcrun simctl openurl $TARGET "capmessagebug://complete"