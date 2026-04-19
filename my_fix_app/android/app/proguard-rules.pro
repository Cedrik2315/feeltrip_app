-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

-keep class com.google.mlkit.** { *; }
-keep class com.google_mlkit_** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.reactnativestripesdk.**
-keep class com.reactnativestripesdk.** { *; }

-keep class hive.** { *; }
-keep class io.sentry.** { *; }
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keep class com.algolia.** { *; }

-keep class androidx.** { *; }
-dontwarn androidx.**

# Atributos esenciales para Firebase y Sentry
-keepattributes SourceFile,LineNumberTable,Signature,*Annotation*

# Isar (Crítico para tu App de Viajes)
-keep class io.isar.** { *; }
-dontwarn io.isar.**

# Algolia (Para tu motor de búsqueda)
-keep class com.algolia.** { *; }
-dontwarn com.algolia.**

# Sentry (Para debuggear fallos en producción)
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# Flutter & Plugins (Base de la App)
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Wear OS Companion Rules (Fix for R8 Missing Classes)
-keep class com.mjohnsullivan.flutterwear.wear.** { *; }
-dontwarn com.google.android.wearable.compat.WearableActivityController$AmbientCallback
-dontwarn com.google.android.wearable.compat.WearableActivityController
-keep class com.google.android.wearable.** { *; }
