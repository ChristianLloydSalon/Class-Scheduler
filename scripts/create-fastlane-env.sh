#!/bin/bash

# Create fastlane directory if it doesn't exist
mkdir -p android/fastlane

# Create or overwrite .env file
echo "
    FIREBASE_APP_ID=${FIREBASE_APP_ID}
    FIREBASE_TOKEN=${FIREBASE_TOKEN}
    TESTERS_GROUP=${TESTERS_GROUP}
" > android/fastlane/.env
