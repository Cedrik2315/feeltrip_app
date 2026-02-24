# Ignorar las clases de Push Provisioning que faltan
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }

# Reglas generales para Stripe
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Reglas para RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Mantener clases de soporte y multidex
-keep class androidx.multidex.** { *; }