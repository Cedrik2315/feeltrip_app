#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "[1/5] flutter pub get"
flutter pub get

echo "[2/5] flutter analyze"
flutter analyze

echo "[3/5] flutter test (release suite, staging env)"
flutter test \
  test/services \
  test/unit/admob_service_test.dart \
  test/unit/auth_controller_test.dart \
  test/unit/auth_service_test.dart \
  test/unit/database_service_test.dart \
  test/unit/diary_controller_test.dart \
  test/unit/experience_controller_test.dart \
  test/widget_test.dart \
  --dart-define=APP_ENV=staging

echo "[4/5] build staging debug apk"
flutter build apk --debug --dart-define=APP_ENV=staging

echo "[5/5] build prod debug apk"
flutter build apk --debug --dart-define=APP_ENV=prod

echo "Preflight release OK"
