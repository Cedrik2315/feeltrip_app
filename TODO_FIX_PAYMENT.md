# Payment Fixes Progress

- [x] FIX 1: payment_repository_impl.dart lines 69-75 - Change _metrics.logSubscriptionSuccess() to MetricsService.logSubscriptionSuccess() (static method) - COMPLETED

- [ ] FIX 2: Identify and fix the second error (likely provider duplication in core/di/providers.dart or another static method call). Run `dart
