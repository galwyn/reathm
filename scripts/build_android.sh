#!/bin/bash

echo "Building Android App Bundle for release..."

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

# Build the app bundle
# This command automatically uses the signing configuration from android/key.properties
# and the keystore file specified within it (e.g., android/app/upload-keystore.jks).
# Ensure these files are present and correctly configured for a release build.
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "Android App Bundle built successfully!"
    echo "You can find the AAB file in: build/app/outputs/bundle/release/"
else
    echo "Android App Bundle build failed."
    exit 1
fi
