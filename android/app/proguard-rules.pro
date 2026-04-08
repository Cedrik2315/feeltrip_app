# === GLOBAL ===
-ignorewarnings
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature

# === FLUTTER ===
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# === FIREBASE ===
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.iid.FirebaseInstanceId

# === MLKIT - solo latin, ignorar idiomas opcionales ===
-keep class com.google.mlkit.vision.text.latin.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-dontwarn com.google.mlkit.**

# === STRIPE - pushProvisioning es opcional ===
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**