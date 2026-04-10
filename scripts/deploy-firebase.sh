#!/bin/bash

# Firebase Build & Deploy Script for LinkMeUp
echo "🚀 Starting Bulletproof Deployment to Firebase..."

# 1. Build the app
echo "🏗️ Building Flutter Web..."
flutter build web --release

# 2. Deploy to Firebase
if command -v firebase &> /dev/null
then
    echo "📤 Deploying to Firebase Hosting..."
    firebase deploy --only hosting
else
    echo "⚠️ Firebase CLI not found. Please run 'build/web' manually or install firebase-tools."
    echo "You can host the contents of 'build/web' on any static provider (Netlify, GitHub Pages, etc.)"
fi

echo "✅ Done!"
