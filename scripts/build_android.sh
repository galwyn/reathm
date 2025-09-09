#!/bin/bash

BUILD_TYPE=${1:-"all"} # Default to "all" if no argument provided

echo "Starting Android build process..."

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

BUILD_SUCCESS=true

if [ "$BUILD_TYPE" = "all" ] || [ "$BUILD_TYPE" = "aab" ]; then
    echo "Building Android App Bundle (AAB) for release..."
    flutter build appbundle --release

    if [ $? -eq 0 ]; then
        echo "Android App Bundle built successfully!"
        echo "You can find the AAB file in: build/app/outputs/bundle/release/"
    else
        echo "Android App Bundle build failed."
        BUILD_SUCCESS=false
    fi
fi

if [ "$BUILD_TYPE" = "all" ] || [ "$BUILD_TYPE" = "apk" ]; then
    echo "Building Android APK for release..."
    flutter build apk --release

    if [ $? -eq 0 ]; then
        echo "Android APK built successfully!"
        echo "You can find the APK file in: build/app/outputs/flutter-apk/app-release.apk"
    else
        echo "Android APK build failed."
        BUILD_SUCCESS=false
    fi
fi

if [ "$BUILD_SUCCESS" = true ]; then
    echo "Android build process completed successfully."
else
    echo "Android build process completed with errors."
    exit 1
fi