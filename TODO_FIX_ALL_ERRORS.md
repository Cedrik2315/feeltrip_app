# Flutter Errors Fix Plan - Attempt #7

Current status: flutter analyze shows multiple errors matching BLOCK 1-4.

## Block 1: Simple Casts (Approved, In Progress)
- [ ] Fix lib/services/optimized_home_content.dart (dynamic -> (as String?) on item['title'], ['destination'])
  - Edit Text(item['title'] ?? ...) -> Text((item['title'] as String?) ?? ...)
- [ ] Run `flutter analyze --no-fatal-infos 2>&1 | findstr \"error -\"`
- [ ] Fix lib/services/gemini_service.dart line 73: return response.text ?? fallback
- [ ] Analyze
- [ ] Fix lib/services/isar_service.dart line 150: cast itemDyn to Map<String, dynamic>['status']
- [ ] Analyze - Block 1 clean?

## Block 2: Broken by Previous AI
- [ ] notifications_screen.dart lines 41,49: Fix Badge ternary syntax, !isRead
- [ ] chronicle_service.dart lines 73 dynamic, 112 .['key'] -> ['key']
- [ ] smart_camera_screen.dart line 120: CameraController(cameras[0]...)
  - Read VisionState fields from lib/models/vision_models.dart
- [ ] translator_screen.dart line 66: cast response to Map
- [ ] payment_repository_impl.dart lines 65-69,87: bookingsBox -> isar.getBookings or correct API, define localBooking
- Analyze after each

## Block 3: Delete & Rewrite Tests
- [ ] Read production: booking_service.dart, Booking model, SyncService etc (grep done)
- [ ] Delete test/services/booking_service_test.dart content, rewrite with mocktail (pubspec has it), actual constructors
- [ ] Same for sync_service_test.dart, search_notifier_test.dart

## Block 4
- [ ] my_itineraries_screen.dart line 260: syncUserEntries -> correct SyncService method

## Final
- [ ] flutter analyze --no-fatal-infos 2>&1 | findstr \"error -\" == empty

Updated on completion.
