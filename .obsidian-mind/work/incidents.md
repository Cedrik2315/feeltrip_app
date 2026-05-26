# 🐛 Incidents & Gotchas

## Android / Gradle Issues

### [RESOLVED] GoogleSignIn Duplicate API Error
**Date:** 2026-05-25 | **Severity:** 🔴 Critical

**Root Cause:** Multiple GoogleSignIn instances causing conflicts

**Solution Applied:** ✅
- Removed custom `_googleSignIn` field
- Use `GoogleSignIn.instance` singleton pattern
- Updated `signInWithGoogle()` and `signOut()`

**Files Changed:**
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/config/providers/providers.dart`

---

### [PENDING] Lint Warnings Explosion (120+)
**Date:** 2026-05-26 | **Severity:** 🟡 Medium

**Categories:**
- Missing `@override`: 30+
- Unused imports: 25+
- Type safety: 20+
- Widget size: 15+
- Missing docs: 30+

---

## Firebase Issues

### [PENDING] Isar Schema Migration for Existing Users
**Date:** 2026-05-26 | **Severity:** 🟡 Medium

**Problem:** No migration path if schemas change

**Solution:** Implement backward-compatible schema versioning

---

### [RESOLVED] Firebase Crashlytics Not Sending on Debug
**Date:** 2026-05-24 | **Severity:** 🔴 Critical

**Solution:** ✅ Enable `setCrashlyticsCollectionEnabled(true)` in main()

---

## Performance Issues

### [PENDING] Agent Loop Token Cost Not Optimized
**Date:** 2026-05-26 | **Severity:** 🟡 Medium

**Observed:** ~450 tokens per turn (target: <300)

**In Progress:**
- [ ] Implement response cache in Hive (24h TTL)
- [ ] Summarize diary context with embeddings
- [ ] Compress tool descriptions

---

## Flutter / UI Issues

### [PENDING] Memory Leak in Video Player (Chewie)
**Date:** 2026-05-25 | **Severity:** 🟠 Medium

**Symptom:** +15-20MB memory after video playback not released

**Suspected Fix:** Ensure proper disposal in lifecycle

---

### [KNOWN] Animation Frame Drops on Moto G35
**Date:** 2026-05-24 | **Severity:** 🟡 Medium

**Workaround:**
- Reduce animation duration (300ms → 150ms)
- Use `SingleTickerProvider` instead of multi-ticker

---

## 🛠️ Pre-Commit Checklist

```
☐ flutter analyze (no new warnings)
☐ flutter test (all tests pass)
☐ Check Sentry baseline crashes
☐ Test on emulator + physical device
☐ Update .obsidian-mind/ if architectural change
```

---

**Última Actualización:** 2026-05-26