# TODO.md - Code 10/10 Quality

**Information Gathered:** Layers good, legacy folder, fpdart not full, no pagination, sync writes single.

**Plan:**
1. Legacy refactor: Move services to features/*/data/datasources
2. fpdart Either<Failure, Result> in repos/usecases (auth/premium/search/diario)
3. Pagination lists (search_notifier startAfter, diario too)
4. Batch writes sync_service
5. Cloud Functions doc FIREBASE_ARCHITECTURE.md for heavy sync
6. Deploy indexes.json

**File level:**
- lib/core/di/providers.dart : fix RouterRef (final Provider)
- lib/legacy/services/* -> lib/features/*/data/datasources/*
- lib/features/*/domain/repositories/* : Either
- lib/features/*/domain/usecases/* : Either
- lib/features/search/presentation/providers/* : pagination
- lib/core/network/sync_service.dart : batch
- FIREBASE_ARCHITECTURE.md : CF examples

**Dependent:**
providers.dart, legacy/services, features/auth/premium/search/diario repos/usecases, sync_service, search_notifier

**Followup:**
flutter pub run build_runner build
flutter test
firebase deploy firestore:indexes

**Next:** Step 1 - Fix providers.dart + move legacy revenuecat.
