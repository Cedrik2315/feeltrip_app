# Flutter Analyze Fix Plan - Target: 0 Errors

## Current Status: 222 → 0 Errors

### ✅ Block 1-3 Completed (Files/Providers created, login fixed)

### ✅ Step 1: Mass withOpacity → withValues (High Impact ~64 fixes)
- [x ] reels_screen.dart 5 instances fixed
- [ ] Remaining ~59

### 🔄 Step 2: Icons/Curves/Haptics Fixes
- [ ] lib/screens/onboarding_screen.dart: Icons.Architecture_outlined → Icons.architecture
- [ ] lib/screens/travel_suggestions_screen.dart: Icons.Map_outlined → Icons.map_outlined; HapticFeedback.successOverridable → mediumImpact
- [ ] lib/screens/splash_screen.dart: Curves.outBack → Curves.easeOutBack
- [ ] lib/widgets/ai_proposal_card.dart: Curves.extrapolateMaxFinished → Curves.easeOut
- [ ] lib/screens/travel_diary_screen.dart: HapticFeedback.successOverridable → mediumImpact

### 🔄 Step 3: Type/Syntax Errors
- [ ] lib/screens/emotional_preferences_quiz_screen.dart: Line 56 dynamic cast fix
- [ ] lib/screens/ocr_screen.dart: Line 252 remove const
- [ ] lib/screens/diary_screen.dart: Line 348 ] syntax
- [ ] lib/features/profile/data/profile_repository.dart: Line 91 Iterable cast if needed

### 🔄 Step 4: Isar/Hive Boxes
- [ ] lib/core/local_storage/isar_service.dart: Add chroniclesBox/metaBox getters

### 🔄 Step 5: Unused Imports/Fields/Deprecated
- [ ] user_preferences.dart:170 Switch activeColor → activeThumbColor
- [ ] Specific unused: profile_repository.dart riverpod import, etc.
- [ ] destination_map_widget.dart:88 setMapStyle deprecated

### 🔄 Step 6: Validate & Mass Cleanup
- [ ] execute `flutter analyze > analyze_after_step6.txt`
- [ ] If errors: search_files on output, repeat

### 🔄 Step 7: Final Validation
```
flutter analyze
```
**Goal: 0 errors (warnings/info optional)**

**Progress: 0/7 → Update on complete.**

