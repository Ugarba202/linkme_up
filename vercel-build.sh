#!/bin/bash

# Vercel Build Script for Flutter Web
# This script installs Flutter on the fly and builds the project.

FLUTTER_VERSION="3.24.5"
FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "🚀 Starting Vercel Build Process..."

# 1. Download and Install Flutter
echo "📥 Downloading Flutter SDK (version ${FLUTTER_VERSION})..."
curl -C - -O $FLUTTER_SDK_URL
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# 2. Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Verify Flutter Installation
echo "🤖 Checking Flutter version..."
flutter --version

# 4. Enable Web support (just in case)
echo "🌐 Enabling Flutter Web support..."
flutter config --enable-web

# 5. Get Dependencies
echo "📦 Getting pub dependencies..."
flutter pub get

# 6. Build Web for Release
echo "🏗️ Building Flutter Web in release mode..."
flutter build web --release

echo "✅ Build Complete! Serving from build/web"
