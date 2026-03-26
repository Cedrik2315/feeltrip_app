# MLKit - Evita que borre los reconocedores de texto y modelos
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.common.sdkinternal.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Stripe - Evita que borre clases de aprovisionamiento y pagos
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Mantener clases genéricas que suelen dar problemas con R8
-keepattributes Signature,Annotation
-dontwarn com.google.mlkit.**
-dontwarn com.stripe.android.**