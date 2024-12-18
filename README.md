# Capacitor message-passing bug

See: _link to issue when available_

A minimal reproduction app to show a possible bug in the interaction between iOS and Capacitor that seems to result in some messages from Capacitor Natve -> JS being dropped. In the production app where we first noticed the issue, this manfested as either:

_(A)_

- A push notification would come in
- The user would tap it
- The app would come into the foreground (_not_ launch fresh)
- The app would not navigate to the page indicated in the notification payload

_(B)_

- User clicks on a deeplink
- The app would come into the foreground
- The app would not navigate to the page indicated by the deeplink

It appears that if a capacitor app is backgrounded for a long time, iOS can kill its `WKWebView`'s `WebContent` process but not terminate the native app. As soon as Capacitor receives the [signal that its `WebContent` process](<https://developer.apple.com/documentation/webkit/wknavigationdelegate/webviewwebcontentprocessdidterminate(_:)>) was terminated, it reloads the `WKWebView`. It also appears that this signal is sometimes delayed until the app is foregrounded.

This reproduction app and associated scripts simulate iOS killing the `WebContent` process by terminating it explicitly after backgrounding the app.

The test steps performed by the scripts are:

1. Launch the test app in the Simulator
2. Background the test app by opening the "Files" app
3. Explicitly kill the `WebContent` process
4. Issue an `openurl` instruction that will result in the `@capacitor/app` plugin attempting to send a message with the URL to the JS side of the app
5. Observe if the URL was delivered by OCR'ing the Simulator's screen

## Instructions

First, start an iOS simulator and get its device ID. You can get its device ID by running:

```sh
xcrun simctl list devices booted
```

Then, install the included MacOS Shortcut in the file `Grab Text from Image.shortcut` by double-clicking on it. The shortcut is used by the `go.sh` script below.

The first run-through of the reproduction will require accepting some permissions in iOS. It is recommended to invoke `go.sh` (see below) one time to get through these dialogs before running a full automated test.

### One-off test

```sh
sh go.sh $DEVICE_ID
```

The build environment is cleaned, forcing a full rebuild of the app, on each invocation.

Once the script terminates, the iOS program will either show "YES IT WORKED" on-screen if the `openurl` test message was delivered, or it will show "NOPE".

### N iterations test

This script will run N iterations and print a summary of results. Since the bug is due to a race condition, it can be useful to run many iterations. Each iteration takes ~1 min.

```sh
sh go_loop.sh $DEVICE_ID <count>
```

The OCR shortcut will only run if the machine is unlocked, so `go_loop.sh` also runs `caffeinate` to keep the display on and machine awake.

The summary results are printed as a series of `.` and `F` characters:

- `.`: the test message was delivered, and the bug did not trigger
- `F`: the test message was not delivered, showing the effects of the bug
- `!`: expected text was not present in the Simulator screenshot, indicating some other test run failure

Results are also output to a dated directory within `output/`, and will contain the following:

- `package.json`, `capacitor.config.ts` - copies from the repo root
- `summary.txt` - a summary of results such as `FFF!F!!F...`
- `<n>.png`, `<n>.txt` - the screenshot and the OCR'd text from each iteration
- `env.txt` - output of the `env` command

### Notes

To simulate the bug's production conditions, there are a number of explicit sleeps between steps. For example, the app is backgrounded, 5 seconds elapse, then the `WebContent` process is killed, 5 more seconds elapse, and then the test `openurl` command is issued. It is unknown how important these sleeps are for reproducing the bug with the same conditions as we see in production.

However, and for reasons I do not yet understand, iOS is less likely to immediately issue the "WebContent process terminated" signal to Capacitor (and thus have Capacitor immediately reload the `WKWebView`) if the app is removed from the Simulator, entirely rebuilt, and re-installed.

For example:

```sh
sh ./go_loop.sh <target> 20
```

will fail (`F`) 75-100% of the time for me on my MacBook Pro M1 running on an iPhone 16 Plus simulator running iOS 18.1, with the other iterations encountering a restarted `WebContent` process before the app is foregrounded (`!`). While:

```sh
SKIP_BUILD=1 sh ./go_loop.sh <target> 10
```

will encounter a restarted `WebContent` process 100% of the time. To reduce the likelihood of encountering a restarted `WebContent` process, you can reduce the interval between the `kill` command and the `openurl` command:

```sh
WEBCONTENT_KILL_TO_MESSAGE_INTERVAL_SECONDS=0.1 SKIP_BUILD=1 sh ./go_loop.sh DAAAF488-ED44-4874-BDE0-8808EF277ADB 10
```

will fail (`F`) 75-100% of the time again.
