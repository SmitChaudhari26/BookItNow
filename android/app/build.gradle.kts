plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ✅ use full name, not kotlin-android
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.bookitnow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ Match Firebase plugins requirement

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.bookitnow"
        minSdk = 23 // ✅ required by Firebase Firestore
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

    // Firebase Analytics (example)
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase SDKs you need
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}
