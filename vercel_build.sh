#!/bin/bash
set -e

echo "🚀 Setting up Flutter for Vercel..."

# Download and extract Flutter SDK
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz | tar -xJf -

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor

# Get dependencies
flutter pub get

# Build the Flutter web release
flutter build web --release

echo "✅ Flutter Web build complete!"
