# Firebase Analytics Integration - FeelTrip App

Current progress: Starting implementation...

## Steps:

### 1. Create Analytics Service [IN PROGRESS]
- Create `lib/services/analytics_service.dart` with provided Firebase Analytics wrapper.

### 2. Update main.dart
- Add import for AnalyticsService
- Add AnalyticsService.observer to navigatorObservers

### 3. Integrate login events
- `lib/screens/login_screen.dart`: logLogin('email') or 'google' on _authController.login/loginWithGoogle success (in _runSignIn try block before Get.offAll)

### 4. Integrate register events
- `lib/screens/register_screen.dart`: logSignUp('email') on _authController.register success (in _submit try block after await)

### 5. Integrate trip detail events
- `lib/screens/trip_detail_screen.dart`: logViewTrip(trip.id, trip.title) in _tripFuture.then after if(trip != null)
- logAddToCart(trip.id, trip.price) in bottomNavigationBar onPressed before _cartController.addToCart

### 6. Integrate quiz events
- `lib/screens/emotional_preferences_quiz_screen.dart`: logQuizCompleted(_archetype!) in _showResults after computing primary

### 7. Integrate premium events
- `lib/screens/premium_subscription_screen.dart`: logPremiumViewed() in initState
- logPremiumAttempt(pkg.storeProduct.title) before controller.purchase(pkg)

### 8. Integrate affiliate events
- `lib/widgets/affiliate_widget.dart`: logAffiliateClick(option.name, option.url) before AffiliateService.openAffiliateLink

### 9. Final steps
- Run `flutter pub get`
- Run `flutter analyze`
- Update TODO with ✓ for completed steps
- Use attempt_completion when all done

**Next step: Create analytics_service.dart**

