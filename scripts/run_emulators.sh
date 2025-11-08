#!/bin/bash
echo "Starting Firebase Emulators..."
firebase emulators:start --import=./firebase-emulator-data --export-on-exit
