# Android APK Export Guide

This guide provides instructions for exporting "Pakistan Truck Driver Tycoon" as an Android APK using Godot 4.2+.

## Prerequisites
1. **Android SDK**: Install the Android SDK and ensure the `adb` command is available.
2. **OpenJDK**: Install OpenJDK 11 or 17.
3. **Debug Keystore**: Generate a debug keystore if you haven't already.
   - Command: `keytool -keyalg RSA -genkey -alias androiddebugkey -keystore debug.keystore -storepass android -keypass android -validity 36500 -dname "CN=Android Debug,O=Android,C=US"`
4. **Godot Android Export Templates**: Download and install export templates via Godot (Project > Install Android Build Template).

## Export Steps

1. **Open Godot Editor**: Launch the project in Godot 4.2.
2. **Configure SDK Paths**:
   - Go to `Editor > Editor Settings`.
   - Navigate to `Export > Android`.
   - Set the paths for `Android Sdk Path`, `Debug Keystore`, and `Keytool`.
3. **Install Android Build Template** (Optional but recommended):
   - Go to `Project > Install Android Build Template...`.
4. **Open Export Menu**:
   - Go to `Project > Export...`.
5. **Select Android Preset**:
   - You should see the "Android" preset already configured.
6. **Verify Settings**:
   - Ensure "Runnable" is checked.
   - Package Name: `com.pakistantruck.driver.tycoon`
   - Architectures: `armeabi-v7a` and `arm64-v8a` should be checked.
7. **Export APK**:
   - Click **Export Project...**.
   - Choose a destination (default is `../build/android/pakistan_truck_tycoon.apk`).
   - Ensure "Export With Debug" is unchecked for a release-like build (unless debugging).

## Troubleshooting
- **Missing Resource Errors**: If the export fails due to missing resources, ensure all paths in `export_presets.cfg` are correct and all files exist.
- **Permission Errors**: If the app fails to install, ensure "Unknown Sources" is enabled on the target Android device.
- **Rendering Issues**: The project uses the `mobile` renderer. Ensure your device supports Vulkan or OpenGL ES 3.0.
