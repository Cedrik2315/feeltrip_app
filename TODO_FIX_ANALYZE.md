# TODO: Fix Flutter Analyze - 0 Errors Goal

## Phase 1: Critical Errors (Missing Methods & Providers)
- [x] Step 1.1: Read lib/services/isar_service.dart full content again if needed
- [x] Step 1.2: Add missing sync methods to IsarService:
  * enqueueMomentoSync(MomentoModel item)
  * getPendingMomentos(String userId)
  * pushMomentoToCloud(MomentoModel momento) → placeholder
  * markMomentoAsSynced(String key, String remoteId)
  * markMomentoSyncError(String id, String error)
  * Similar for proposals/itineraries: getPendingProposals(String userId), pushProposalToCloud, markProposalAsSynced(String id), markProposalSyncError(String id, String error)
  * getPendingItineraries(String userId), pushItineraryToCloud, markItineraryAsSynced(String id), markItinerarySyncError(String id, String error)
- [x] Step 1.3: Add booking methods:
  * Future<List<BookingModel>> getBookingsForUser(String userId)
  * Future<void> saveBooking(BookingModel booking)
- [x] Step 1.4: Fix syncServiceProvider ambiguities:
  * Remove duplicate in lib/services/sync_service.dart
  * Ensure consistent import 'package:feeltrip_app/core/di/providers.dart' in main.dart, momento_provider.dart, travel_suggestions_screen.dart, my_itineraries_screen.dart
  * Fix main.dart import conflict
- [ ] Step 1.5: Fix dynamic calls (main.dart:173 ref.read(dynamic), travel_suggestions_screen.dart:83)

## Phase 2: Warnings & Deprecations
- [ ] Step 2.1: Replace all withOpacity → copyWith(opacity: ) in screens (agency_profile, auth_gate, creator_stats, etc.)
- [ ] Step 2.2: Remove unused imports (flutter_riverpod in profile_repository.dart, dart:convert in reels_screen.dart, etc.)
- [ ] Step 2.3: Fix unused element parameters 'key' in various builders
- [ ] Step 2.4: Remove unused fields/variables (agedGold, slateGrey, deepCarbon, isFollowing)
- [ ] Step 2.5: Fix other deprecations (activeColor → activeThumbColor/trackColor, setMapStyle → GoogleMap.style)
- [ ] Step 2.6: Fix strict_raw_type, unnecessary casts, null-aware operators
- [ ] Step 2.7: Run `flutter analyze` and fix remaining

## Follow-up
- [ ] Test app compilation: `flutter pub get && flutter analyze`
- [ ] Manual test key flows (add momento, sync, bookings)
- [ ] Update TODO with completed steps
- [ ] attempt_completion

**Current Progress: Phase 1 Step 1.4 - Fixing syncServiceProvider**
