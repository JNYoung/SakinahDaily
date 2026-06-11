import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningProperties = Properties().apply {
    val signingFile = rootProject.file("key.properties")
    if (signingFile.exists()) {
        signingFile.inputStream().use(::load)
    }
}

fun releaseSigningValue(propertyName: String, environmentName: String): String? =
    providers.environmentVariable(environmentName).orNull
        ?: releaseSigningProperties.getProperty(propertyName)

val releaseStoreFile = releaseSigningValue("storeFile", "SAKINAH_UPLOAD_STORE_FILE")
val releaseStorePassword = releaseSigningValue(
    "storePassword",
    "SAKINAH_UPLOAD_STORE_PASSWORD",
)
val releaseKeyAlias = releaseSigningValue("keyAlias", "SAKINAH_UPLOAD_KEY_ALIAS")
val releaseKeyPassword = releaseSigningValue(
    "keyPassword",
    "SAKINAH_UPLOAD_KEY_PASSWORD",
)
val hasReleaseSigning = listOf(
    releaseStoreFile,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }
val requireReleaseSigning =
    providers.environmentVariable("SAKINAH_REQUIRE_RELEASE_SIGNING").orNull == "true"

if (requireReleaseSigning && !hasReleaseSigning) {
    throw org.gradle.api.GradleException(
        "Release signing is required. Provide android/key.properties or " +
            "SAKINAH_UPLOAD_* environment variables.",
    )
}

android {
    namespace = "com.sakinahdaily.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.sakinahdaily.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Local release builds keep debug signing unless
                // SAKINAH_REQUIRE_RELEASE_SIGNING=true is set.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
