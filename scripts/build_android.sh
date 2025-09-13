#!/bin/bash

# Default build type
BUILD_TYPE="appbundle"

# Check for argument to override build type
if [ "$1" == "apk" ]; then
    BUILD_TYPE="apk"
fi

echo "Building Android $BUILD_TYPE for release..."

# Ensure Flutter is available
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Please ensure Flutter SDK is installed and in your PATH."
    exit 1
fi

# Increment the build number
echo "Incrementing build number..."
dart tool/increment_build_number.dart

# Clean previous builds
flutter clean

# Get Flutter dependencies
flutter pub get

# Build the app bundle or apk
if [ "$BUILD_TYPE" == "appbundle" ]; then
    flutter build appbundle --release
else
    flutter build apk --release
fi

if [ $? -eq 0 ]; then
    echo "Android $BUILD_TYPE built successfully!"
    if [ "$BUILD_TYPE" == "appbundle" ]; then
        echo "You can find the AAB file in: build/app/outputs/bundle/release/"
    else
        echo "You can find the APK file in: build/app/outputs/flutter-apk/"
    fi
else
    echo "Android $BUILD_TPE build failed."
    exit 1
fi
