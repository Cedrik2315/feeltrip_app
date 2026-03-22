# TODO - Trips/Bookings Optimization

**Information Gathered:** Partial flow (models/services partial, screens loose in cwd). MercadoPago ready, affiliate/destination/weather/currency services open. No full sync.

**Plan:**
1. Models: lib/models/booking_model.dart (freezed, Isar), cart_item_model.dart, trip_model.dart
2. Services: lib/services/booking_service.dart (full flow: cart->checkout->success->sync Firestore users/{userId}/bookings)
3. Integrate: affiliate commission (10%), weather good = discount, currency convert, destination details.
4. Screens: Move loose checkout_screen.dart etc to lib/screens/, connect flow.
5. Sync: Extend sync_service.dart for pending bookings Isar->Firestore batch.
6. Tests: Add repo tests, widget cart/checkout.

**Dependent Files:**
- lib/models/* (create/optimize)
- lib/services/cart_service.dart, booking_service.dart (open/create)
- lib/screens/cart_screen.dart, bookings_screen.dart, checkout_screen.dart, booking_success_screen.dart (move/connect)
- sync_service.dart
- lib/app_router.dart (routes)

**Followup:** flutter pub run build_runner build, flutter test

<ask_followup_question>
<question>Confirm?</question>
</ask_followup_question>
