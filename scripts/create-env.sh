# creates .env file in root directory
echo "
    FIREBASE_API_KEY=$FIREBASE_API_KEY
    FIREBASE_APP_ID=$FIREBASE_APP_ID
    FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
    FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID
" >> .env
