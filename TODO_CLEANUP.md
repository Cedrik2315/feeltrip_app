# Post-Modularization Cleanup TODO

## Status: In Progress

### Step 1: [DONE] Fix unsafe cast in lib/services/osint_ai_service.dart
- Replaced `dest['name'] as String` with safe `(dest['name'] as String?) ?? 'Unknown'`
- Additional type fixes applied (risk_score cast, async removal)

### Step 2: [DONE] Fix TravelAgency constructors in lib/widgets/demo_agencies_screen.dart
- Added all required params including 'address' to both demo instances

### Step 3: [PENDING] Run flutter analyze
- Execute `flutter analyze`
- Verify 'No issues found!' or fix remaining

### Step 4: [PENDING] Test demo screen
- Run app and navigate to demo agencies if possible

### Step 5: [PENDING] Complete task
- Update status to DONE
- Run final analyze

Updated after each step.
