#!/bin/bash

# This script provides a controlled way to capture adb logcat output for debugging.

# Step 1: Clear existing logs to ensure a clean capture.
echo "Clearing adb logcat buffer..."
adb logcat -c
echo "Buffer cleared."
echo ""

# Step 2: Wait for the user to be ready to start.
read -n 1 -s -p "Press any key to start capturing logcat..."
echo "" # Add a newline after the key press

# Step 3: Start the logcat capture in a background process.
# The output is redirected to a file, and we save the Process ID (PID).
echo "Starting logcat capture..."
# Start adb logcat in the background and get its PID
adb logcat > logcat_capture.txt &
LOGCAT_PID=$!

# Step 4: Wait for the user to signal when to stop.
# The main script execution pauses here while the background process continues.
echo ""
echo "Capturing logs to logcat_capture.txt... Press any key to stop."
read -n 1 -s
echo "" # Add a newline after the key press

# Step 5: Stop the background logcat process gracefully.
echo "Stopping logcat capture..."
kill $LOGCAT_PID
# Wait a moment to ensure the process is terminated and the file is fully written.
sleep 1

# Step 6: Confirm completion.
echo "Log capture complete: logcat_capture.txt"
echo ""

# Step 7: Ensure the log file is ignored by Git.
GITIGNORE_FILE=".gitignore"
IGNORE_ENTRY="logcat_capture.txt"

# Check if .gitignore exists, create it if it doesn't.
if [ ! -f "$GITIGNORE_FILE" ]; then
    touch "$GITIGNORE_FILE"
    echo "Created .gitignore file."
fi

# Check if the entry already exists in .gitignore to avoid duplicates.
if grep -qxF "$IGNORE_ENTRY" "$GITIGNORE_FILE"; then
    echo "'$IGNORE_ENTRY' already exists in .gitignore."
else
    # Append the entry to .gitignore on a new line.
    echo "" >> "$GITIGNORE_FILE"
    echo "# Log files" >> "$GITIGNORE_FILE"
    echo "$IGNORE_ENTRY" >> "$GITIGNORE_FILE"
    echo "Added '$IGNORE_ENTRY' to .gitignore."
fi
