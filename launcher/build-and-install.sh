#!/usr/bin/env bash
# Build the launcher APK and install it on the TV as the default home screen.
set -euo pipefail
cd "$(dirname "$0")"
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.50 $0}"
STOCK_LAUNCHER="${STOCK_LAUNCHER:-com.google.android.tvlauncher}"
export JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 17 2>/dev/null || echo /opt/homebrew/opt/openjdk@17)}"
export ANDROID_HOME="${ANDROID_HOME:-$([ -d ~/Library/Android/sdk ] && echo ~/Library/Android/sdk || echo /opt/homebrew/share/android-commandlinetools)}"
export PATH="$JAVA_HOME/bin:$PATH"
[ -f local.properties ] || echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew assembleDebug -q --console=plain
PY=../tools/venv/bin/python
[ -x "$PY" ] || PY=../tools/venv/Scripts/python.exe
export MSYS_NO_PATHCONV=1
APK=app/build/outputs/apk/debug/app-debug.apk
"$PY" -I ../tools/b64push.py "$APK" /data/local/tmp/tvhome.apk
TV() { "$PY" -I ../tools/tv.py "$@"; }
# Check each step before touching the stock launcher, so a failed install never leaves the TV without a Home.
OUT=$(TV "pm install -r /data/local/tmp/tvhome.apk; rm -f /data/local/tmp/tvhome.apk")
echo "$OUT"
case "$OUT" in *Success*) ;; *) echo "pm install failed; the stock launcher was left untouched" >&2; exit 1;; esac
OUT=$(TV "cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity")
echo "$OUT"
case "$OUT" in *Error*) echo "could not set the new launcher as home; the stock launcher was left untouched" >&2; exit 1;; esac
TV "pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION && echo location-granted || echo location-not-granted"
TV "pm disable-user --user 0 $STOCK_LAUNCHER"
echo "Installed. Press Home on the remote to see it."
