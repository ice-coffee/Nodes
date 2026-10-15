## Android Studio导入第三方项目库
1. 复制到导入的第三方项目库到根目录
2. 在根目录中的setting.gradle文件中添加代码

```
include ':app',':[目录名]'
```

3. 在app目录下的build.gradle文件中添加

```
dependencies {
    compile project(':library')
}
```
4. 在导入的第三方项目库中添加build.gradle文件，添加代码

```
apply plugin: 'com.android.library'

android {
    compileSdkVersion 21
    buildToolsVersion "21.1.2"

    defaultConfig {
        minSdkVersion 9
        targetSdkVersion 21
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
}
```
