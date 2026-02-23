#!/usr/bin/env bash
# AUTOMATED TESTING FLOW - Run this to test everything
# Platforms: macOS, Linux, WSL

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════╗"
echo "║     FEELTRIP - AUTOMATED FEATURE TESTING FLOW          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Clean and prepare
echo "Step 1️⃣  Preparing project..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$(dirname "$0")"
flutter clean
flutter pub get
echo "✅ Project prepared"
echo ""

# Step 2: Build
echo "Step 2️⃣  Building APK..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter build apk --debug
echo "✅ APK built successfully"
echo ""

# Step 3: Run
echo "Step 3️⃣  Running app on emulator..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "App launching in 3 seconds..."
echo "Press 'h' for help, 'q' to quit"
sleep 3
flutter run
echo ""

# Step 4: Summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║              TESTING COMPLETE!                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "1. Test in-app features manually"
echo "2. Check Firebase Console for data"
echo "3. Review MANUAL_TESTING.md for detailed steps"
echo ""
