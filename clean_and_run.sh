#!/bin/bash

# set -x

TARGET=$1

# clean
rm -rf node_modules
rm -rf dist
rm -rf ios/App/Pods
rm -rf ios/App/Podfile.lock
rm -rf ios/App/App/public
rm -rf ios/DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/App-giomahdtuiozbnflyvhwbnqioylw
rm -rf ios/capacitor-cordova-ios-plugins

# uninstall app on target
xcrun simctl uninstall $TARGET org.watchduty.capmessagebugrepro

# build
yarn
yarn build

# run
npx cap run ios --target $TARGET