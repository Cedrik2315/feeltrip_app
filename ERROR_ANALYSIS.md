# Error Analysis and Fix Plan

## CRITICAL ERRORS FOUND

### 1. diario_screen.dart - Missing Controller Reference (RUNTIME ERROR)
**Problem:** Screen uses `_controller.isLoading` and `_controller.diaryEntries` but `_controller` is NEVER defined
```dart
// CURRENT (BROKEN):
if (_controller.isLoading) {  // _controller is undefined!
  return const Center(child: CircularProgressIndicator());
}
```
**Fix:** Add controller initialization using GetX

---

### 2. Dual Data Sources - Inconsistent Architecture
**Problem:** 
- `diario_screen.dart` uses `DatabaseService` → queries `entries` collection directly
- `ExperienceController` uses `DiaryService` → queries `users/{uid}/diaryEntries` subcollection

**Fix:** Consolidate to use single source (ExperienceController via GetX)

---

### 3. DiaryEntry Model Field Mismatches

#### 3a. `emotion` (String) vs `emotions` (List)
**Model:** `String emotion`
**Used as:** `entry.emotions` (List) in experience_controller.dart
```dart
// In experience_controller.dart - BROKEN:
emotions.addAll(entry.emotions);  // entry.emotions doesn't exist!

// In diary_service.dart - BROKEN:  
'emotions': entry.emotions,  // Trying to access non-existent field
```
**Fix:** Change model to use List<String> emotions

#### 3b. Missing `reflectionDepth` Field
**Model:** No `reflectionDepth` field
**Used as:** `entry.reflectionDepth` in multiple places
```dart
// In experience_controller.dart:
diaryEntries.map((e) => e.reflectionDepth).reduce((a, b) => a + b);

// In diary_service.dart:
'reflectionDepth': entry.reflectionDepth,
```
**Fix:** Add `reflectionDepth` field to DiaryEntry model

---

### 4. Field Name Inconsistency: date vs fecha
**Problem:** 
- `DatabaseService` queries: `.orderBy('fecha', descending: true)`
- `DiaryEntry` model: uses `date` field
- `DiaryEntry.fromFirestore`: maps from `date`

**Fix:** Standardize to use `createdAt` consistently

---

### 5. preview_entry_screen.dart - TODO: Dynamic User Profile
**Problem:** Hardcoded user profile
```dart
const userProfile = "Explorador";  // Should be dynamic
```
**Fix:** Fetch from user preferences or auth data

---

## FILES TO MODIFY

1. `lib/models/experience_model.dart` - Fix DiaryEntry model
2. `lib/screens/diario_screen.dart` - Fix controller reference
3. `lib/services/database_service.dart` - Fix field names
4. `lib/controllers/experience_controller.dart` - Fix field usage
5. `lib/screens/preview_entry_screen.dart` - Make userProfile dynamic

---

## IMPLEMENTATION PRIORITY
1. HIGH: Fix diario_screen.dart controller (crashes app)
2. HIGH: Fix DiaryEntry model fields
3. MEDIUM: Consolidate data sources
4. LOW: Make userProfile dynamic

