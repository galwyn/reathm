#!/bin/bash

echo "Generating app icons for Flutter project..."

# Ensure Flutter is available
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Please ensure Flutter SDK is installed and in your PATH."
    exit 1
fi

# Ensure flutter_launcher_icons is installed as a dev dependency
# You might need to add it to your pubspec.yaml if not already present:
# dev_dependencies:
#   flutter_launcher_icons: "^0.13.1"
#
# Then run: flutter pub get

# Check if flutter_launcher_icons is available
if ! flutter pub run flutter_launcher_icons --help &> /dev/null
then
    echo "flutter_launcher_icons package not found or not configured."
    echo "Please add flutter_launcher_icons to your dev_dependencies in pubspec.yaml and run 'flutter pub get'."
    exit 1
fi

# Ensure the source icon exists
SOURCE_ICON="assets/icons/app_icon_512x512.png"
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Source icon not found at $SOURCE_ICON."
    echo "Please place your 512x512 app icon in this location before running this script."
    exit 1
fi

echo "Using source icon: $SOURCE_ICON"

# Run flutter_launcher_icons to generate icons
# This assumes you have a flutter_launcher_icons configuration in your pubspec.yaml
# Example configuration:
# flutter_launcher_icons:
#   android: "launcher_icon"
#   ios: true
#   image_path: "assets/icons/app_icon_512x512.png"
#   min_sdk_android: 21 # android min sdk min:16, default 21
#   remove_alpha_ios: true
#   web:
#     generate: true
#     image_path: "assets/icons/app_icon_512x512.png"
#     background_color: "#hexcode"
#     theme_color: "#hexcode"
#   windows:
#     generate: true
#     image_path: "assets/icons/app_icon_512x512.png"
#     icon_size: 48 # min:48, max:256, default: 48
#   macos:
#     generate: true
#     image_path: "assets/icons/app_icon_512x512.png"

flutter pub run flutter_launcher_icons

if [ $? -eq 0 ]; then
    echo "App icons generated successfully!"
    echo "Remember to rebuild your application for changes to take effect."
else
    echo "App icon generation failed."
    exit 1
fi
