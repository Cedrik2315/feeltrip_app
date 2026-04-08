# TODO: chronicle_schema.dart creation and integration - Progress Tracker

## Approved Plan Steps:
- [x] 1. Create this TODO.md (done)
- [x] 2. Update lib/core/local_storage/chronicle_schema.dart with complete @collection ChronicleModel matching Hive model fields (id String @id, indexes, Embedded ExpeditionDataSchema, etc.)
- [x] 3. Handle ExpeditionData schema (Embedded if needed; read lib/models/expedition_data.dart)
- [x] 4. Delete/replace lib/core/local_storage/_chronicles_box.dart stub
- [ ] 5. Run `flutter pub run build_runner build --delete-conflicting-outputs` for .g.dart
- [ ] 6. `flutter analyze lib/core/local_storage/` - confirm 0 errors
- [ ] 7. Update TODO_ISAR_FIX.md with progress
- [x] 8. Test IsarService.init() compatibility (no changes needed for Hive)
- [ ] 9. attempt_completion

**Status:** Schema ready for future Isar migration while keeping Hive current.

**Next:** Complete schema matching ChronicleModel exactly.

