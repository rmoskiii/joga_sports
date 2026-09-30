#!/usr/bin/env bash
# One-time setup: generates the iOS, Android and web platform folders
# (not stored in the repo yet), fetches packages and runs the checks.
set -euo pipefail

flutter create . \
  --project-name joga_sports \
  --org com.jogasports \
  --platforms=ios,android,web

flutter pub get
dart format lib test
flutter analyze
flutter test

echo ""
echo "Ready. Run the demo with: flutter run -d chrome"
