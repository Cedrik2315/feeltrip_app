# TODO: Flutter Analyze Cleanup - 0 Errors, Clean All Warnings/Infos (754 total)

## Progress
- [ ] Phase 1: Remove unused imports (lib/main.dart: 22, app_router.dart, auth_gate.dart, profile_screen.dart, premium_subscription_screen.dart, etc.)
✅ Phase 2: emotional_preferences_quiz_screen.dart const constructors fixed (inference warning remains for MaterialPageRoute)
- [ ] Phase 3: Fix inference failures (showDialog<Widget>, MaterialPageRoute<Page>, Future.delayed<void>, List<String>)
- [ ] Phase 4: Fix deprecated (withOpacity → withValues(alpha:), logger levels v→trace/wtf→fatal)
- [ ] Phase 5: Formatting (trailing commas, EOL newlines, reflow >80 chars lines in mock_data.dart etc.)
- [ ] Phase 6: prefer_final_locals/omit_local_types (var→final)
- [ ] Phase 7: Remove unused elements (methods like _buildPackageCard, _buildFollowerStats)
- [ ] Phase 8: avoid_print → AppLogger
- [ ] Phase 9: Task-specific dead code/nulability in notifications_screen.dart:101 (simplify ternary/??)
- [ ] Phase 10: Run `dart format lib/ test/ --line-length=100`
- [ ] Phase 11: `flutter analyze` → verify 0 issues
- [ ] Phase 12: `flutter test`

✅ Phase 1: Remove unused imports  
✅ Phase 1: Remove unused imports  
✅ main.dart cleaned (22 unused imports removed)  
✅ Phase 1: Remove unused imports (main.dart cleaned)
✅ Phase 2 Started: Fixing emotional_preferences_quiz_screen.dart const constructors (30+)
**Current: Phase 2**
