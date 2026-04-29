# Shorebird Version Management

This document explains how to manage app versions when using Shorebird for pushing patches.

## Overview

Since you're using Shorebird for OTA (Over-The-Air) updates, the app version management works differently than traditional Flutter apps. The footer displays the current app version from a centralized configuration file.

## Files

### 1. Version Configuration
- **Location**: `lib/config/app_version.dart`
- **Purpose**: Centralized version management for Shorebird patches

### 2. Footer Widget
- **Location**: `lib/widgets/centralized_footer.dart`
- **Purpose**: Displays copyright and current app version

## How Shorebird Versioning Works

### Current Setup
- **App Version**: `1.0.0` (from pubspec.yaml)
- **Build Number**: `1` (from pubspec.yaml)
- **Footer Display**: `v1.0.0`

### When Pushing Shorebird Patches

1. **Update Version in Config File**:
   ```dart
   // lib/config/app_version.dart
   class AppVersion {
     static const String version = '1.0.1';  // Increment this
     static const String buildNumber = '1';   // Keep this the same
   }
   ```

2. **Push Shorebird Patch**:
   ```bash
   shorebird patch android
   shorebird patch ios
   ```

3. **Footer Automatically Updates**:
   - The footer will now show `v1.0.1`
   - No need to rebuild the entire app
   - Users get the new version number via OTA update

## Version Management Strategy

### For Minor Updates (Patches)
- Increment the patch version: `1.0.0` → `1.0.1`
- Keep major and minor versions the same
- Update `AppVersion.version` in the config file
- Push Shorebird patch

### For Major Updates (Full App Updates)
- Increment major or minor version: `1.0.0` → `1.1.0` or `2.0.0`
- Update both `pubspec.yaml` and `AppVersion.version`
- Build and release new app version
- Reset patch version to `0`

## Example Version Progression

```
Initial Release: v1.0.0+1
├── Shorebird Patch 1: v1.0.1 (footer shows v1.0.1)
├── Shorebird Patch 2: v1.0.2 (footer shows v1.0.2)
├── Shorebird Patch 3: v1.0.3 (footer shows v1.0.3)
└── Major Update: v1.1.0+2 (new app release)
    ├── Shorebird Patch 1: v1.1.1 (footer shows v1.1.1)
    └── Shorebird Patch 2: v1.1.2 (footer shows v1.1.2)
```

## Benefits of This Approach

1. **Easy Version Updates**: Change one file to update version across the app
2. **Shorebird Compatible**: Works seamlessly with OTA updates
3. **Consistent Display**: All screens show the same version number
4. **No Dependencies**: No external packages needed
5. **Quick Updates**: Version changes are included in patches

## Important Notes

- **Always update `AppVersion.version`** before pushing Shorebird patches
- **Don't change `pubspec.yaml` version** for patch updates (only for major releases)
- **Test version display** after pushing patches
- **Keep version numbers consistent** between config and what users see

## Troubleshooting

### Version Not Updating
- Check if the Shorebird patch was applied successfully
- Verify the `AppVersion.version` was updated
- Ensure the footer is using `AppVersion.shortVersion`

### Version Mismatch
- If footer shows different version than expected, check the config file
- Verify the import path in the footer widget
- Clear app cache and restart if needed
