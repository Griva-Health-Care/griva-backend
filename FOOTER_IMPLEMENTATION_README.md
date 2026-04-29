# Centralized Footer Implementation

This document explains how to implement the centralized footer across all screens in the Griva Pi application.

## Overview

The centralized footer is a reusable widget that displays the copyright notice "© 2025 Griva. All rights reserved." across all screens, ensuring consistency and maintainability.

## Files

### 1. Centralized Footer Widget
- **Location**: `lib/widgets/centralized_footer.dart`
- **Purpose**: Reusable footer component with consistent styling

### 2. Updated Screens
- **Image Comparison Screen**: `lib/screens/image_comparison_screen.dart` ✅
- **Home Page**: `lib/home_page.dart` ✅
- **Custom Drawer**: `lib/custom_drawer.dart` ✅
- **Login Page**: `lib/login_page.dart` ✅

## How to Add Footer to New Screens

### Step 1: Import the Footer
```dart
import '../widgets/centralized_footer.dart';
```

### Step 2: Add Footer to Screen Layout
Place the footer at the bottom of your screen's main Column or ListView:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Your Screen')),
    body: Column(
      children: [
        // Your main content here
        Expanded(
          child: YourMainContent(),
        ),
        
        // Add the centralized footer
        const CentralizedFooter(),
      ],
    ),
  );
}
```

### Step 3: Alternative Layout (if using ListView)
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Your Screen')),
    body: ListView(
      children: [
        // Your main content here
        YourMainContent(),
        
        // Add the centralized footer
        const CentralizedFooter(),
      ],
    ),
  );
}
```

## Footer Features

- **Consistent Styling**: Same appearance across all screens
- **Responsive Design**: Adapts to different screen sizes
- **Professional Look**: Clean, subtle design with border
- **Easy Maintenance**: Single source of truth for footer content
- **Shorebird Compatible**: Version updates via OTA patches

## Styling Details

The footer includes:
- White background
- Subtle top border
- Centered copyright text
- Consistent padding and typography
- Professional grey color scheme

## Benefits

1. **Consistency**: All screens have identical footer appearance
2. **Maintainability**: Update footer content in one place
3. **Professional**: Consistent branding across the application
4. **Code Reusability**: No need to duplicate footer code
5. **Easy Updates**: Change copyright year or text in one location

## Example Implementation

Here's a complete example of a screen with the footer:

```dart
import 'package:flutter/material.dart';
import '../widgets/centralized_footer.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Screen'),
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Center(
              child: Text('Your content goes here'),
            ),
          ),
          
          // Centralized footer
          const CentralizedFooter(),
        ],
      ),
    );
  }
}
```

## Notes

- The footer should always be placed at the bottom of the screen
- Use `Expanded` widget to push content to the top and footer to the bottom
- The footer automatically handles responsive behavior
- No additional styling is needed - the widget is self-contained

## Shorebird Version Management

Since this app uses Shorebird for OTA updates, the footer version is managed through a centralized configuration file:

- **Version Config**: `lib/config/app_version.dart`
- **Update Process**: Change version in config file before pushing Shorebird patches
- **No Rebuild Required**: Version updates are included in OTA patches

For detailed Shorebird version management, see `SHOREBIRD_VERSION_MANAGEMENT.md`.
