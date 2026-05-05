#!/bin/bash

echo "📦 Starting Trackify Release Process..."

# Prompt for the version tag
read -p "Enter version tag (e.g., v1.0.0-alpha): " version

# Prompt for a short release message
read -p "Enter release message: " message

echo "🛠️ Compiling Release Builds..."

# Build for Android
echo "Building Android APK..."
flutter build apk --release

# Build for Linux
echo "Building Linux Native App..."
flutter build linux --release

# 1. Stage and commit any lingering changes (including any updated build files if tracked)
git add .
git commit -m "chore: prepare for release $version and generate builds"

# 2. Create an annotated git tag
git tag -a "$version" -m "$message"

# 3. Push commits and the new tag to your remote
echo "🚀 Pushing branch and tags to North-Abyss/Trackify-Flutter..."
git push origin main
git push origin "$version"

echo "✅ Release $version pushed successfully!"
echo "💡 Tip: Your compiled binaries are located at:"
echo "   - Android: build/app/outputs/flutter-apk/app-release.apk"
echo "   - Linux: build/linux/x64/release/bundle/"