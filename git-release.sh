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

# Build for Web (optional, uncomment if needed)
# echo "Building Web App..."
# flutter build web --release

# Build for Windows (optional, uncomment if needed)
# echo "Building Windows Native App..."
# flutter build windows --release

# Build for macOS (optional, uncomment if needed)
# echo "Building macOS Native App..."
# flutter build macos --release

# Build for iOS (optional, uncomment if needed)
# echo "Building iOS App..."
# flutter build ios --release

# add the build files and upload them in release section of github


# 1. Stage and commit any lingering changes (including any updated build files if tracked)
git add .
git commit -m "chore: prepare for release $version and generate builds"

# 2. Create an annotated git tag
git tag -a "$version" -m "$message"

# 3. Push commits and the new tag to your remote
echo "🚀 Pushing branch and tags to North-Abyss/Trackify-Flutter..."
git push origin main
git push origin "$version"


# 4. Create GitHub Release and upload build files
echo "📤 Creating GitHub release and uploading build files..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI (gh) is not installed. Please install it to upload release assets."
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# Create the release on GitHub with the tag
gh release create "$version" \
    --title "Trackify $version" \
    --notes "$message" \
    --repo North-Abyss/Trackify-Flutter

# Upload Android APK
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "Uploading Android APK..."
    gh release upload "$version" "build/app/outputs/flutter-apk/app-release.apk" \
        --repo North-Abyss/Trackify-Flutter --clobber
else
    echo "⚠️  Android APK not found at build/app/outputs/flutter-apk/app-release.apk"
fi

# Upload Linux binary
if [ -d "build/linux/x64/release/bundle/" ]; then
    echo "Uploading Linux binary..."
    cd "build/linux/x64/release/bundle/"
    tar -czf "trackify-linux-x64.tar.gz" .
    gh release upload "$version" "trackify-linux-x64.tar.gz" \
        --repo North-Abyss/Trackify-Flutter --clobber
    cd - > /dev/null
else
    echo "⚠️  Linux bundle not found"
fi

# Upload Web build (if it exists)
if [ -d "build/web" ]; then
    echo "Uploading Web build..."
    cd "build/web"
    tar -czf "trackify-web.tar.gz" .
    gh release upload "$version" "trackify-web.tar.gz" \
        --repo North-Abyss/Trackify-Flutter --clobber
    cd - > /dev/null
else
    echo "⚠️  Web build not found"
fi

echo "✅ Release $version created and uploaded successfully!"
echo "🔗 View release at: https://github.com/North-Abyss/Trackify-Flutter/releases/tag/$version"
echo "📋 Uploaded assets:"
echo "   - Android: app-release.apk"
echo "   - Linux: trackify-linux-x64.tar.gz (if built)"
echo "   - Web: trackify-web.tar.gz (if built)"
echo "   - Windows: trackify-windows-x64.zip (if built)"
echo "   - macOS: trackify-macos-x64.zip (if built)"
echo "   - iOS: trackify-ios.ipa (if built)"
