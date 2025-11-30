plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePath: String? = project.findProperty("MYAPP_KEYSTORE_PATH") as String?
            val keystorePassword: String? = project.findProperty("MYAPP_KEYSTORE_PASSWORD") as String?
            val keyAlias: String? = project.findProperty("MYAPP_KEY_ALIAS") as String?
            val keyPassword: String? = project.findProperty("MYAPP_KEY_PASSWORD") as String?

            if (keystorePath != null &&
                keystorePassword != null &&
                keyAlias != null &&
                keyPassword != null
            ) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            } else {
                // Fallback para debug se as propriedades não estiverem definidas
                signingConfigs.getByName("debug")
            }
        }
    }

    buildTypes {
        release {
            // Compatível com shrinkResources exigido pela toolchain atual.
            // Se shrinkResources estiver ativo (configuração padrão do Flutter),
            // o minify (R8) também precisa estar ativado.
            isMinifyEnabled = true
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
