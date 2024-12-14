#!/bin/bash

set -x

TARGET=$1

# clean
rm -rf node_modules
rm -rf dist
rm -rf ios/App/Pods
rm -rf ios/DerivedData
rf -rf ios/capacitor-cordova-ios-plugins

# uninstall app on target
xcrun simctl uninstall $TARGET org.watchduty.capmessagebugrepro

# build
yarn
yarn build
npx cap copy ios
npx cap sync ios

# run
npx cap run ios --target $TARGET