import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. Cargamos las propiedades sin mencionar "java.util"
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { stream ->
        localProperties.load(stream)
    }
}

// 2. Extraemos las versiones con valores por defecto seguros
val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"

android {
    namespace = "com.feeltrip.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        @Suppress("DEPRECATION")
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.feeltrip.app"
        // CORREGIDO: Usamos 21 directamente para evitar errores de referencia
        minSdk = flutter.minSdkVersion 
        targetSdk = 34
        versionCode = flutterVersionCode.toInt()
        // CORREGIDO: Usamos la variable que leÃƒÂ­mos arriba
        versionName = flutterVersionName 
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "231504"
            storeFile = file("C:/Users/monch/upload-keystore.jks")
            storePassword = "231504"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Nota: Si el build falla por "ProGuard", cambia estos dos a false temporalmente
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}


dependencies {
    dependencies {
    // 1. Desugaring para soporte de APIs de Java moderno en Android viejo
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // 2. FIREBASE BOM: Esto soluciona el crash de MissingDependencyException
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    
    // 3. Agregamos las librerías base (sin versión, el BOM la pone por ti)
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
}
}

flutter {
    source = "../.."
}
