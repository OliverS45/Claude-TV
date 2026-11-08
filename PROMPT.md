# Claude TV: assistant-guided setup

**Your TV. Your Rules. No Clutter.**

Use this optional prompt in a coding assistant with shell access, opened in your existing Claude TV folder. It is a workflow for a TV you authorize the assistant to access, not an automatically executed script. The software does not require an Anthropic account or any particular assistant.

Claude TV is an independent derivative of [Gathin's tv-vibehack](https://github.com/Gathin23/tv-vibehack), not affiliated with Anthropic. This adapts the original project's setup prompt to reuse the included software.

Read the [requirements](README.md#requirements) and [platform limitations](README.md#supported-devices). Android TV / Google TV API 26 or newer is required; ADB and HOME replacement depend on firmware. LG webOS, Samsung Tizen and Amazon Fire TV are outside this project's supported scope.

Enable developer options and USB/Network debugging as available. Have the TV's IP address ready. The client expects authenticated ADB over TCP, normally port 5555; it does not implement pairing-code Wireless debugging.

Copy the prompt below and fill in your details.

---

I want to set up **Claude TV** on my Android TV / Google TV.

My TV model: `<MODEL>`
My TV IP address: `<IP ADDRESS>`

Work directly in this existing project. Do not clone or download another copy, move the project, or build a replacement application. Read README.md, the scripts, launcher configuration and relevant example notes first.

### Scope and preferences

- Preserve the existing launcher interface, dependencies, SDK versions, `com.gathin.tvhome` package ID, component names and script paths.
- Ask which apps I use, their dock order, and whether I want casting, voice, accessibility services, manufacturer apps and firmware updates retained.
- Configure `launcher/app/src/main/res/values/config.xml`. Do not promise an on-TV dock editor, wallpaper picker or ad blocking inside streaming apps.
- Explain device changes before applying them. Do not commit or push automatically.

### Connect and inspect

- Use my supplied address or ask if missing. Set `TV_HOST`; use `TV_PORT` only for a different compatible endpoint.
- Reuse or prepare `tools/venv` with `tools/requirements.txt`. Run `tools/tv.py --probe` and tell me when to accept debugging authorization.
- Identify the exact stock launcher package and full HOME component, Live TV package and essential input services. Do not assume defaults match my model.
- If stock adb fails, use the included Python client. Use `tools/b64push.py` for large uploads and require a matching checksum.

### Record before changing

- Create a fresh directory under `backup/` with full and disabled-package lists, getprop, system/secure/global settings and the current HOME component.
- Record screensaver settings and any settings you plan to change. Keep dumps and ADB keys private.
- Save an exact reviewed list of newly disabled packages, excluding packages already disabled. The restore scripts re-enable all listed packages, not their previous states.

### Install the existing launcher

- Configure dock priorities, hidden tiles, columns and `live_tv_package`. Build with JDK 17 and SDK platform 34/build-tools 34.0.0, without changing project versions.
- Upload the APK, check installation Success, and select `com.gathin.tvhome/.MainActivity` as HOME. Grant the existing location permission for Wi-Fi SSID display where supported.
- Have me verify Home before disabling stock HOME. Prefer the README's explicit installation sequence: the convenience installers check install and HOME results but not every remote response before disabling stock HOME.
- Verify app launching, D-pad navigation, return focus, Settings and inputs. With my device authorization, use remote key injection and screenshots where useful. Report anything you cannot verify.

### Debloat after verification

- Treat examples as firmware-specific references. Inspect unfamiliar packages with `dumpsys package` and ask if purpose or preference is unclear.
- Preserve HDMI/tuner services, input menus, remote/Bluetooth services, keyboard, Play Store and Play Services. Retain accessibility services and apps I use.
- Use `pm disable-user --user 0`, never uninstall system packages. Run package-manager commands one per shell call; batch mode does this but does not detect every remote command failure.
- Apply only my reviewed list, inspect responses and record results. Do not claim this removes every ad or telemetry source.

### Verify and hand over

- Confirm Home, streaming apps, inputs and retained features work. Do not redesign the launcher for unrelated preferences.
- Give exact restore commands for my reviewed list and stock launcher. Explain that restore resets animation scales to 1.0 and leaves Claude TV installed.
- Provide the saved full HOME component as a fallback if the restore scripts cannot resolve it. Document separate reversal for settings and screensaver changes.
- Explain editing config.xml and rebuilding, re-enabling one package and switching debugging off after maintenance.
- Report changed files, device changes, completed checks and limitations. Preserve original licenses and attribution.

---

See [README.md](README.md) for manual setup and recovery, and [CONTRIBUTING.md](CONTRIBUTING.md) for sharing redacted device notes.
