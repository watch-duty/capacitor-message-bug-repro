# Capacitor message-passing bug

See: _link to issue when available_

This is a minimal reproduction app to show a possible bug in the interaction between iOS and Capacitor that seems to result in some messages from Capacitor Natve -> JS being dropped.

The specific conditions that result in this bug in the field are when the app has been backgrounded long enough for iOS to kill its `WKWebView`'s `WebContent` process, but not so long as to terminate the native app itself.

As soon as Capacitor receives the [signal that its `WebContent` process](<https://developer.apple.com/documentation/webkit/wknavigationdelegate/webviewwebcontentprocessdidterminate(_:)>) was terminated, it reloads the `WKWebView`. It appears that this signal is received when the app is again foregrounded, and it would also appear that sometimes messages that sent to the JS app from the Native side can get lost.

This app and associated scripts simulate iOS killing the `WebContent` process by terminating it explicitly after backgrounding the app.

The test steps are:

1. Launch the test app in the Simulator
2. Background the test app by opening the "Files" app
3. Explicitly kill the `WebContent` process
4. Issue an `openurl` instruction that will result in the `@capacitor/app` plugin attempting to send a message with the URL to the JS side of the app
5. Observe if the URL was delivered by OCR'ing the Simulator's screen

## Instructions

First, start an iOS simulator, and get its device ID. You can get its device ID by running:

```sh
xcrun simctl list devices booted
```

Then, install the included MacOS Shortcut in the file "Grab Text from Image.shortcut" by double-clicking on it. The shortcut is used by the `go.sh` script below.

### One-off test

```sh
sh go.sh $DEVICE_ID
```

Once the script terminates, the iOS program will either show "YES IT WORKED" on-screen, if the `openurl` message was delivered, or it will show "NOPE".

### N iterations test

Since the bug appears to be racy, this script will run N iterations and print a summary of results:

```sh
sh go_loop.sh $DEVICE_ID <count>
```

Because the image OCR shortcut will only run if the machine is unlocked, the script runs `caffeinate` to keep the display on and machine awake.

The summary results are printed as a series of `.` and `F` characters:

- `.` means the test message was delivered, and the bug did not trigger
- `F` means the test message was not delivered, showing the effects of the bug
- `!`: expected text was not present in the Simulator screenshot, indicating some other test run failure

Results are also output to a dated directory within `output/`, and will contain the following:

- `package.json`, `capacitor.config.ts` - copies of the files from the repo root
- `summary.txt` - a summary file of results
- `<n>.png`, `<n>.txt` - the screenshot and the OCR'd text from each iteration
