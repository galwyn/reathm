#!/bin/bash

echo "Deploying web application to Firebase Hosting..."

# Ensure Flutter is available
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Please ensure Flutter SDK is installed and in your PATH."
    exit 1
fi

# Ensure Firebase CLI is available
if ! command -v firebase &> /dev/null
then
    echo "Firebase CLI not found. Please install it (npm install -g firebase-tools) and ensure it's in your PATH."
    exit 1
fi

# Increment the build number
echo "Incrementing build number..."
dart run tool/increment_build_number.dart

# Clean previous builds
flutter clean

# Get Flutter dependencies
flutter pub get

# Build the web application
flutter build web --release

if [ $? -eq 0 ]; then
    echo "Flutter web build successful. Deploying to Firebase Hosting..."
    # Deploy to Firebase Hosting
    # Assumes you are already logged in to Firebase CLI and have selected the correct project
    firebase deploy --only hosting

    if [ $? -eq 0 ]; then
        echo "Web application deployed successfully!"
    else
        echo "Firebase deployment failed."
        exit 1
    fi
else
    echo "Flutter web build failed."
    exit 1
fi
