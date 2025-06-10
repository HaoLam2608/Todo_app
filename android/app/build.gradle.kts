plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.todo_list"
    compileSdk = 35 // Cập nhật lên Android 15 (API 35) để tương thích với các plugin
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // Bật desugaring cho Java 8+ API
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.todo_list"
        minSdk = 23 // Android 5.0, phù hợp với Flutter
        targetSdk = 35 // Đồng bộ với compileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // Bật MultiDex để hỗ trợ ứng dụng lớn
    }

    buildTypes {
        release {
            // Sử dụng debug signing tạm thời, thay bằng signingConfig chính thức cho production
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // Desugaring cho Java 8+
}

flutter {
    source = "../.."
}