# 🚀 TODO: Limpieza Warnings Deprecados - BLACKBOXAI
Status: [IN PROGRESS] ✅ Plan Aprobado

## 📋 PASOS DEL PLAN (Fase por Fase)

### ✅ FASE 1: Deprecations Críticos (Completado cuando ✅)
- [✅] sharing_service.dart: Migrar 4x Share.share → SharePlus
- [✅] agency_profile_screen.dart: 6x canLaunch/launch → canLaunchUrl/launchUrl + remove Get
- [ ] 8 screens withOpacity → withValues(alpha:) (15+ cambios)

### 📂 FASE 2: Unused Imports
- [ ] user_model.dart: remove intl
- [ ] agency_profile_screen.dart: remove Get  
- [ ] comments_screen.dart: remove Get
- [ ] reels_screen.dart: remove Get
- [ ] travel_diary_screen.dart: remove image_picker
- [ ] creator_stats_screen.dart: remove unused
- [ ] profile_screen.dart: remove unused
- [ ] stories_screen.dart: remove unused
- [ ] trip_detail_screen.dart: remove unused

### 🧹 FASE 3: Remove Prints/Debug
- [ ] agency_service.dart: Eliminar todos print/debugPrint
- [ ] diary_service.dart: Eliminar todos print/debugPrint
- [ ] story_service.dart: Eliminar todos print/debugPrint
- [ ] user_service.dart: Eliminar todos print/debugPrint
- [ ] feed_screen.dart: Eliminar todos print/debugPrint

### 💰 FASE 4: RevenueCat Update
- [ ] revenuecat_service.dart: purchasePackage → purchase(PurchaseParams)

### 🔍 FASE 5: Verificación Final
- [ ] flutter pub get
- [ ] flutter analyze (0 warnings)
- [ ] flutter test (pass)
- [ ] Manual: Test sharing, URLs, UI, purchases, no console spam

### 🎉 COMPLETADO
- [ ] Marcar TODO.md ✅ 
- [ ] attempt_completion

**Próximo paso:** Fase 1 ediciones → marcar ✅ → Fase 2...

