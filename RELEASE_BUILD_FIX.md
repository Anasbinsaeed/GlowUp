# 🔧 Release Build Fix - APK Issues

## Problem
When building APK with `flutter build apk --split-per-abi`, some features don't work:
- UI updates not happening
- Notifications not firing
- Background services not working

## Root Cause
Release builds use code obfuscation/minification which can break:
- Notification receivers
- Background services
- Provider state management
- Database operations

## ✅ What I Fixed

### 1. Disabled Code Obfuscation
Updated `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        minifyEnabled = false      // Disabled code shrinking
        shrinkResources = false    // Disabled resource shrinking
        ...
    }
}
```

### 2. Created ProGuard Rules
Created `android/app/proguard-rules.pro` with rules to keep:
- Flutter classes
- Notification receivers and services
- Database classes (SQLite)
- SharedPreferences
- Provider/ViewModel classes
- Timezone data
- AlarmManager classes
- All native methods
- Enums and Parcelables

### 3. Added ProGuard Configuration
Added ProGuard file reference (for future use if you enable minification):
```kotlin
proguardFiles(
    getDefaultProguardFile("proguard-android-optimize.txt"),
    "proguard-rules.pro"
)
```

## 🚀 How to Build APK Now

### Clean Build
```bash
flutter clean
flutter pub get
```

### Build APK
```bash
flutter build apk --split-per-abi
```

Or for a single APK (larger file):
```bash
flutter build apk
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle
```

## 📱 Testing Release Build

### Install on Device
```bash
flutter install
```

Or manually:
```bash
adb install build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### Test These Features
1. ✅ Add a reminder - notification should fire
2. ✅ Add a flight - countdown should appear
3. ✅ Toggle habit - UI should update
4. ✅ Close app completely - notifications should still fire
5. ✅ Reboot device - notifications should reschedule
6. ✅ Change theme - should persist and apply

## 🔍 If Issues Persist

### Check Logs
```bash
adb logcat | grep -i flutter
```

### Check for Crashes
```bash
adb logcat | grep -i crash
```

### Verify Permissions
- Settings > Apps > Glowup! > Permissions
- Ensure all permissions are granted
- Disable battery optimization

### Common Issues

**Issue: Notifications still don't work**
- Solution: Check battery optimization is disabled
- Solution: Grant exact alarm permission
- Solution: Check notification channel settings

**Issue: UI doesn't update**
- Solution: This should be fixed with minifyEnabled = false
- Solution: Check if Provider is properly set up in main.dart

**Issue: Database errors**
- Solution: ProGuard rules now keep SQLite classes
- Solution: Clear app data and reinstall

## 📊 APK Size Comparison

With `minifyEnabled = false`:
- APK will be slightly larger (~2-5 MB more)
- But all features will work correctly
- This is the recommended approach for this app

If you need smaller APK in future:
- Enable `minifyEnabled = true`
- The ProGuard rules are already in place
- Test thoroughly after enabling

## ⚠️ Important Notes

1. **Always test release builds** before distributing
2. **Battery optimization must be disabled** for notifications to work
3. **Exact alarm permission** is required for scheduled notifications
4. **The ProGuard rules file** is already configured for future use
5. **Split APKs** create smaller files but you need to install the right architecture

## 🎯 Architecture-Specific APKs

After building with `--split-per-abi`, you'll get:
- `app-armeabi-v7a-release.apk` - 32-bit ARM (older devices)
- `app-arm64-v8a-release.apk` - 64-bit ARM (most modern devices)
- `app-x86_64-release.apk` - 64-bit x86 (emulators, some tablets)

**Install the right one for your device:**
- Most modern phones: `app-arm64-v8a-release.apk`
- Older phones: `app-armeabi-v7a-release.apk`
- Emulator: `app-x86_64-release.apk`

## ✅ Verification Checklist

After installing release APK:
- [ ] Notifications fire at scheduled time
- [ ] Flight countdown appears and updates
- [ ] UI updates when toggling items
- [ ] Theme changes persist
- [ ] Data persists after app restart
- [ ] Notifications work when app is closed
- [ ] Notifications work after device reboot
- [ ] All screens load correctly
- [ ] No crashes or freezes

## 🔄 If You Need to Enable Minification Later

1. Change `minifyEnabled = true` in build.gradle.kts
2. The ProGuard rules are already in place
3. Build and test thoroughly
4. Check logs for any "ClassNotFoundException" errors
5. Add additional ProGuard rules if needed

The current setup prioritizes **functionality over APK size**, which is the right approach for this app.
