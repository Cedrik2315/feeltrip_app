# IMPLEMENTACIÓN ESTRATEGIA CONVERSIÓN MES 3-4 + AdMob [BLACKBOXAI]
Estado: 🚀 EN PROGRESO

## ✅ PASOS COMPLETADOS
- [ ]

## 🔄 PASOS PENDIENTES (Orden de ejecución)
1. [ ] Crear lib/data/services/admob_service.dart (nuevo servicio)
2. [ ] Crear lib/presentation/providers/admob_provider.dart (StateNotifierProvider)
3. [ ] Editar lib/services/notification_service.dart (+3 métodos al final)
4. [ ] Editar lib/data/services/subscription_service.dart (insert en activateTrialIfEligible)
5. [ ] Editar lib/data/services/referral_service.dart (insert en _rewardReferrer)
6. [ ] Editar lib/main.dart (+initialize AdMob)
7. [ ] Editar lib/screens/home_screen.dart (Scaffold + persistentFooter banner)
8. [ ] Editar lib/services/route_provider.dart (intersticial en finishRoute)
9. [ ] Verificar flutter analyze (0 errors)
10.[ ] Test: run app → complete route → verificar logs/notifs/ads

## 📋 NOTAS
- No modificar lógica existente
- Solo usuarios Free (level == SubscriptionLevel.free)
- IDs AdMob de test (reemplazar prod)
- notifyBonusExpiringSoon del task NO usado aún → pendiente si needed

Última actualización: BLACKBOXAI
