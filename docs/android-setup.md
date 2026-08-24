# Android Setup

The demo is configured for Flutter 3.44+, Gradle 8.14, Android Gradle Plugin 8.13.2, Kotlin 2.2.20, Java 17, and minSdk 24 (Android 7.0).

In `android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-bin.zip
```

In `android/settings.gradle`, use Flutter's plugin loader and declare the Android/Kotlin plugin versions:

```groovy
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.13.2" apply false
    id "org.jetbrains.kotlin.android" version "2.2.20" apply false
}

include ":app"
```

At project level, keep the Sency artifact repository available in `android/build.gradle`:

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://artifacts.sency.ai/artifactory/release"
        }
    }
}
```

In `android/app/build.gradle`, use the Flutter Gradle plugin and built-in Kotlin support:

```groovy
plugins {
    id "com.android.application"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    compileSdk 36

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    packagingOptions {
        pickFirst "**/*.so"
    }

    defaultConfig {
        minSdkVersion 24
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
```
