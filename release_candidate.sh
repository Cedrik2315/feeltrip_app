#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Uso: ./release_candidate.sh <version_name> <build_number>"
  echo "Ejemplo: ./release_candidate.sh 1.0.1 2"
  exit 1
fi

VERSION_NAME="$1"
BUILD_NUMBER="$2"

if [[ ! "$VERSION_NAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VersionName invalido. Usa formato semver: X.Y.Z"
  exit 1
fi
if [[ ! "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || [[ "$BUILD_NUMBER" -lt 1 ]]; then
  echo "BuildNumber invalido. Debe ser >= 1."
  exit 1
fi

cd "$(dirname "$0")"

if [[ ! -f android/key.properties ]]; then
  echo "Falta android/key.properties. Copia android/key.properties.example y completa tus valores."
  exit 1
fi

STORE_FILE="$(grep -E '^storeFile=' android/key.properties | head -n1 | cut -d'=' -f2-)"
if [[ -z "$STORE_FILE" ]]; then
  echo "android/key.properties no define storeFile."
  exit 1
fi
if [[ ! -f "$STORE_FILE" ]]; then
  echo "No existe keystore en storeFile: $STORE_FILE"
  exit 1
fi

NEW_VERSION="${VERSION_NAME}+${BUILD_NUMBER}"
sed -i.bak -E "s/^version:.*/version: ${NEW_VERSION}/" pubspec.yaml
rm -f pubspec.yaml.bak

echo "Version seteada: ${NEW_VERSION}"

./preflight_release.sh
flutter build appbundle --release --dart-define=APP_ENV=prod --dart-define=APP_VERSION="${NEW_VERSION}"

echo "Release candidate generado:"
echo "  version: ${NEW_VERSION}"
echo "  artifact: build/app/outputs/bundle/release/app-release.aab"
