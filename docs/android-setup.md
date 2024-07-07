# Android Setup

In order to be compatible with SMKitUI, the Android project should make some changes.

At `gradle-wrapper.properties` please change gradle version to be 8^.

```groovy
  distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
```

Under `gradle.properties` on project level add the following: 

```groovy
  SMKitUI_Version = 0.1.3
  artifactory_contentUrl = https://artifacts.sency.ai/artifactory/release
```

Remove all the content in `settings.gradle` and insert the follow: 
```groovy
  include ":app" // YOUR Module Name
  def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
  def properties = new Properties()

  assert localPropertiesFile.exists()
  localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

  def flutterSdkPath = properties.getProperty("flutter.sdk")
  assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
  apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
```  

At `build.gradle` on project level insert buildscript block like the following:
And please make sure your kotlin_version is at least 1.9
```groovy
buildscript {
  ext.kotlin_version = '1.9.24'
  repositories {
      google()
      mavenCentral()
  }

  dependencies {
      classpath 'com.android.tools.build:gradle:8.0.2'
      classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
      classpath 'com.google.gms:google-services:4.3.8'
  }
}
```

Also please specify under allprojects.repositories our repo url
```groovy
allprojects {
  repositories {
      google()
      mavenCentral()
      maven {
          url "${artifactory_contentUrl}"
      }
  }
}
```

At `build.gradle` on module level please remove upper Plugin{} auto-generate block
And Insert the following:
```groovy
def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
android{
  ...
}
```
> :warning: **Please make sure**: To declare def flutterRoot before applying plugins !

At `build.gradle` on module level please add packagingOptions and change `minSdkVersion` to 26
```groovy
android{
  ...
  packagingOptions {
      pickFirst '**/*.so'
  }
  defaultConfig {
    minSdkVersion 26
  }
}
```
