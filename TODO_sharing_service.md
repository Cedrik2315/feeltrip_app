# TODO: Implement SharingService

## Steps:
- [x] 1. Update lib/services/sharing_service.dart: Add imports for Story/TravelAgency models, implement shareStory(Story story) & shareAgency(TravelAgency agency) static methods with custom messages/emojis/links using Share.share, fix base URL to https://feeltrip.app, add logging.
- [x] 2. Update lib/screens/agency_profile_screen.dart: Fix import to use shared/models/agency_model.dart, update _shareAgency to call SharingService.shareAgency(agency).

Progress: Step 1 ✅ Step 2 ✅ Next: Step 3 (test).
- [ ] 2. Update lib/screens/agency_profile_screen.dart: Fix import to use shared/models/agency_model.dart, update _shareAgency to call SharingService.shareAgency(agency).
- [ ] 3. Test: flutter run, navigate to agency profile, tap share → verify share sheet with custom verified message + link.
- [ ] 4. (Optional) Add share buttons to story feed/screens using shareStory.
- [ ] 5. Mark complete.

Progress: Starting step 1.

