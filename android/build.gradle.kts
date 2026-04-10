import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
    kotlin("android") apply false 
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")

    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { androidExtension ->
            val getNamespace = androidExtension.javaClass.methods.find { it.name == "getNamespace" }
            val currentNamespace = getNamespace?.invoke(androidExtension) as String?
            if (currentNamespace.isNullOrBlank()) {
                val setNamespace = androidExtension.javaClass.methods.find {
                    it.name == "setNamespace" && it.parameterTypes.contentEquals(arrayOf(String::class.java))
                }
                if (setNamespace != null) {
                    val fallbackNamespace = when (project.name) {
                        "isar_flutter_libs" -> "dev.isar.flutter.libs"
                        else -> "feeltrip.generated.${project.name.replace('-', '_')}"
                    }
                    setNamespace.invoke(androidExtension, fallbackNamespace)
                }
            }
        }
    }

    // 1. Forzamos Java 17 de forma directa
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }

    // 2. Forzamos Kotlin a JVM 17 y lenguaje moderno (2.0)
    tasks.withType<KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
            // Usamos KOTLIN_2_0 para que Sentry y MLKit dejen de quejarse
            languageVersion.set(KotlinVersion.KOTLIN_2_0)
            apiVersion.set(KotlinVersion.KOTLIN_2_0)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
