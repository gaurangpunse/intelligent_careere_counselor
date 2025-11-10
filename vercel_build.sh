#!/bin/bash
set -e

echo "🚀 Setting up Flutter 3.35.7 for Vercel..."

# Download and extract Flutter SDK (version 3.35.7)
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.7-stable.tar.xz | tar -xJf -

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Build Flutter web
flutter build web --release

echo "✅ Flutter Web build complete!"
