# Isar Schema Sync with MomentoModel & ItineraryModel - Progress Tracker

## Plan Steps (from approved plan):
- [x] 1. Update `lib/core/local_storage/chronicle_schema.dart` with @collection MomentoCollection & ItineraryCollection matching exact model fields.
- [x] 2. Add comment in `lib/services/isar_service.dart` init() for Isar migration path.

- [ ] 2. Add comment in `lib/services/isar_service.dart` init() for Isar migration path.
- [ ] 3. Run `flutter packages pub run build_runner build --delete-conflicting-outputs` (skip, no isar dep)

- [ ] 4. Run `flutter analyze lib/core/local_storage/` - confirm 0 errors
- [ ] 5. Update `TODO_chronicle_schema.md` status to completed.
- [ ] 6. Update `TODO_ISAR_FIX.md` if relevant.
- [ ] 7. Test storage init.
- [ ] 8. attempt_completion

**Status:** Starting implementation.
</xai:function_call >

Now implementing step 1: Update chronicle_schema.dart with matching Isar schemas (using Isar 3.x syntax: @collection, @id, @Index). Id.String @id.0, indexes on userId, syncStatusName, createdAt for queries. List/DateTime types supported.

<xai:function_call name="create_file">
<parameter name="absolute_path">lib/core/local_storage/chronicle_schema.dart
