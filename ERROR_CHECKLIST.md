# P0/P1 Error Checklist for FeelTrip

## P0 - Crashes (App closes)
- [ ] App crash on startup (Firebase/Sentry init fail)
- [ ] Crash on login (auth providers)
- [ ] Crash on purchase (RevenueCat null key)
- [ ] Crash on camera open (permission)
- [ ] Crash on sync (Isar/Firestore conflict)
- [ ] Crash on notifications (FCM payload null)

## P1 - Functional breaks (core flow blocked)
- [ ] Login fails, no error message
- [ ] Premium offerings not loading
- [ ] Purchase fails silently
- [ ] Restore purchases not working
- [ ] Sync stuck in error status
- [ ] Booking not saving local/cloud
- [ ] MercadoPago preference fail (no beta warning)

## Monitoring
- Sentry events: crashes, performance
- Crashlytics: unhandled exceptions
- AppLogger: auth/payment/search/camera/sync

**Zero tolerance for P0 in production.**

