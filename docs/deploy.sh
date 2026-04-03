#!/usr/bin/env bash
set -e

echo "Building Flutter web..."
flutter build web --release

echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "Deploy concluído."
