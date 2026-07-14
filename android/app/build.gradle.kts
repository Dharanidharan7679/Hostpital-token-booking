plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.token_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
    applicationId = "com.example.token_app"
    minSdk = 23              // ✅ Correct Kotlin DSL syntax
    targetSdk = 33           // or whatever your compile SDK is
    versionCode = 1
    versionName = "1.0"
}


    buildTypes {
        release {
            // You should replace this with your release signing config when ready
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // Firebase Analytics (you can add more Firebase products as needed)
    implementation("com.google.firebase:firebase-analytics")

    // Example: Add Firebase Auth if needed
    // implementation("com.google.firebase:firebase-auth")

    // Example: Add Cloud Firestore if needed
    // implementation("com.google.firebase:firebase-firestore")
}
