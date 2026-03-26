plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.feeltrip_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.feeltrip_app"
        minSdk = 21 // Recomendado para Stripe y MLKit
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Usamos la firma de debug por ahora para que puedas probarlo en tu Moto g35
            signingConfig = signingConfigs.getByName("debug")
            
            // ACTIVAMOS LA PROTECCIÓN CONTRA EL ERROR DE R8
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Eliminamos la estrategia de resolución que excluía firebase-iid 
// porque MLKit la necesita para funcionar en modo Release.

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    
    // Aseguramos que las librerías de MLKit y Stripe tengan lo necesario
    implementation("com.google.firebase:firebase-iid") 
}