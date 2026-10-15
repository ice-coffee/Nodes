### 关联地址

[配置构建](https://developer.android.com/studio/build/index.html?hl=zh-cn#sourcesets)

[如何选择 compileSdkVersion, minSdkVersion 和 targetSdkVersion](http://chinagdg.org/2016/01/picking-your-compilesdkversion-minsdkversion-targetsdkversion/)

[批量修改apk文件名](http://www.flysnow.org/2015/03/30/manage-your-android-project-with-gradle.html)

[Gradle Plugin User Guide](https://github.com/rujews/android-tech-docs/blob/master/new-build-system/user-guide/README.md)

[Gradle学习系列之十——自定义Plugin（本系列完）](http://www.cnblogs.com/davenkin/p/gradle-learning-10.html)

[TOC]

### 是什么
gradle是一种`依赖管理/自动化构建工具`类似ant/maven。但是跟ant/maven不一样，它并没有使用xml语言，而是采用了`Groovy语言`，这使得它更加简洁、灵活，更加强大的是，gradle完全兼容maven和ivy。更多详细介绍可以看它的官网：http://www.gradle.org/

### 为什么
- 更容易重用资源和代码;
- 可以更容易创建不同的版本的程序，多个类型的apk包；
- 更容易配置，扩展;
- 更好的IDE集成;

### 怎么用

#### 1. 基本配置

Android Studio中的android项目通常至少包含两个build.gradle文件，一个是project范围的，另一个是module范围的，由于一个project可以有多个module，所以每个module下都会对应一个build.gradle。

![enter image description here](http://img.blog.csdn.net/20150410093201149?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvY2hkamo=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

project下的build.gradle是基于整个project的配置，而module下的build.gradle是每个模块自己的配置。下面看下这两个build.gradle里面的内容：

project#build.gradle

```
buildscript {
    //构建过程依赖的仓库
    repositories {
	    jcenter()
	}
	//构建过程需要依赖的库
	dependencies {
	     //下面声明的是gradle插件的版本
	     classpath 'com.android.tools.build:gradle:1.1.0'
	     // 不要把项目依赖放到这里
	}
}
//这里面配置整个项目依赖的仓库,这样每个module就不用配置仓库了
allprojects {
     repositories {
          jcenter()
     }
}
```

注：大家可能很奇怪，为什么仓库repositories需要声明两次，这其实是由于它们作用不同，buildscript中的仓库是gradle脚本自身需要的资源，而allprojects下的仓库是项目所有模块需要的资源。所以大家千万不要配错了。

module#build.gradle

```
//声明插件，这是一个android程序，如果是android库，应该是com.android.library
apply plugin: 'com.android.application'

android {
     //安卓构建过程需要配置的参数
     compileSdkVersion 21//编译版本
     buildToolsVersion "21.1.2"//buildtool版本
     
     //默认配置，会同时应用到debug和release版本上
     defaultConfig {
	     applicationId "com.taobao.startupanim"//包名
	     minSdkVersion 15
	     targetSdkVersion 21
	     versionCode 1
	     versionName "1.0"
	 }
	 buildTypes {
	     //这里面可以配置debug和release版本的一些参数，比如混淆、签名配置等
	     release {
	         //release版本
	         minifyEnabled false//是否开启混淆
	         proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'//混淆文件位置
	     }
	}

	productFlavors {
        shoujizhushou {}
        yingyongbao {}
        xiaomi {}
        wandoujia {}

        productFlavors.all { flavor ->
            flavor.manifestPlaceholders = [UMENG_CHANNEL_VALUE: name]
        }
    }
}
dependencies {
     //模块依赖
     compile fileTree(dir: 'libs', include: ['*.jar'])//依赖libs目录下所有jar包
     compile 'com.android.support:appcompat-v7:21.0.3'//依赖appcompat库
}
```

#### 2. gradle相关文件说明
1. gradle.properties：
从名字上就知道它是一个配置文件，没错，这里面可以定义一些常量供build.gradle使用，比如可以配置签名相关信息如keystore位置，密码，keyalias等。
2. settings.gradle：
这个文件是用来配置多模块的，比如你的项目有两个模块module-a,module-b,那么你就需要在这个文件中进行配置，格式如下：

```
include ':module-a',':module-b'
```

3. gradle文件夹：
这里面有两个文件，`gradle-wrapper.jar`和`gradle-wrapper.properties`,它们就是gradle wrapper。gradle项目都会有，你可以通过命令gradle init来创建它们（前提是本地安装了gradle并且配置到了环境变量中）。
4. gradlew和gradlew.bat:
这分别是linux下的shell脚本和windows下的批处理文件，它们的作用是根据gradle-wrapper.properties文件中的distributionUrl下载对应的gradle版本。这样就可以保证在不同的环境下构建时都是使用的统一版本的gradle，即使该环境没有安装gradle也可以，因为gradle wrapper会自动下载对应的gradle版本。
gradlew的用法跟gradle一模一样，比如执行构建gradle build命令，你可以用gradlew build。gradlew即gradle wrapper的缩写。

#### 3. gradle任务

#### 4. 配置 buildTypes
在每个模块的 build.gradle 中AS会自动创建调试和发布两个构建类型. 尽管调试构建类型不会出现在构建配置中, 但是AS会默认为其配置 `debuggable true`, 保证可以在安全的Android设备上调试应用, 并使用通用调试秘钥库配置APK签署.

创建一个构建类型"jnidebug", 使用调试构建类型中的设置进行初始化.
```
android {
    ...
    defaultConfig {...}
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }

        debug {
            applicationIdSuffix ".debug"
        }

        /**
         * "initwith"属性允许你从其他构建类型中配置信息.所以你可以不必重新开始配置.然后你只需要
         * 配置你想要更改的设置.下方代码使用调试版本类型初始化“jnidebug”，并仅更改
         * applicationIdSuffix和versionNameSuffix设置。
         */

        jnidebug {

            // 这将复制可调试属性和调试签名配置。
            initWith debug

            applicationIdSuffix ".jnidebug"
            jniDebuggable true
        }
    }
}
```
如需详细了解对于构建类型可以配置的所有属性，请阅读[构建类型 DSL 参考](http://google.github.io/android-gradle-dsl/current/com.android.build.gradle.internal.dsl.BuildType.html)。

#### 5. 配置 productFlavors
创建 productFlavor 和 buildType 类似, 只需要把他们添加到 `productFlavors{}`代码块并配置你想要的设置即可. productFlavor 支持与 `defaultConfig`相同的属性, 这是因为 defaultConfig 实际上属于[ProductFlavor](http://google.github.io/android-gradle-dsl/current/com.android.build.gradle.internal.dsl.ProductFlavor.html)类. 这意味着, 您可以在 defaultConfig {} 代码块中提供所有flavor的基本配置, 每种flavor均可替换任何默认值, 例如 applicationId.

如下代码创建了两个productFlavor并 赋予其自己的 `applicationId` 和 `versionName`

```
android {
    ...
    defaultConfig {...}
    buildTypes {...}
    productFlavors {
        demo {
            applicationId "com.example.myapp.demo"
            versionName "1.0-demo"
        }
        full {
            applicationId "com.example.myapp.full"
            versionName "1.0-full"
        }
    }
}
```
在创建和配置您的productFlavor之后, Gradle 会根据您的buildType和productFlavor自动创建build variant，并按照 `<product-flavor><Build-Type>` 的格式命名这些变体。例如，如果您创建了"demo"和"full"这两种productFlavor并保留默认的"debug"和"release" buildType，Gradle 将创建以下构build variant：
- demoDebug
- demoRelease
- fullDebug
- fullRelease

您可以将build variant更改为您要构建并运行的任何变体，只需转到 Build > Select Build Variant，然后从下拉菜单中选择一个变体

#### 6. 创建用于 Build Variant 的源集()
默认情况下，Android Studio 会创建 main/ 源集和目录，用于存储您要在所有 buildType 之间共享的一切资源。然而，您可以创建新的源集来确切控制 Gradle 要为特定的buildType、productFlavor和buld variant来编译和打包哪些文件。例如，您可以在 main/ 源集中定义基本的功能，使用productFlavor源集针对不同的客户更改应用的品牌，或者仅针对使用debug buildType的build variant包含特殊的权限和日志记录功能。

Android Plugin for Gradle 提供了一项有用的 Gradle 任务，可向您展示如何针对每种buildType、productFlavor和Build Variant组织您的文件. 操作如下:
- 点击 IDE 窗口右侧的 Gradle 。
- 导航至 MyApplication > Tasks > android 并双击 sourceSets。
- 要查看报告，请单击 IDE 窗口底部的 Gradle Console 。

```
------------------------------------------------------------
Project :app
------------------------------------------------------------
...
debug
----
Compile configuration: compile
build.gradle name: android.sourceSets.debug
Java sources: [app/src/debug/java]
Manifest file: app/src/debug/AndroidManifest.xml
Android resources: [app/src/debug/res]
Assets: [app/src/debug/assets]
AIDL sources: [app/src/debug/aidl]
RenderScript sources: [app/src/debug/rs]
JNI sources: [app/src/debug/jni]
JNI libraries: [app/src/debug/jniLibs]
Java-style resources: [app/src/debug/resources]
```
当您创建新的build variant时，Android Studio 不会为您创建源集目录，但会为您提供几个选项，帮助您创建源集。例如，要为"debug" buildType创建 java/ 目录：

- 1. 打开 Project 窗格并从窗格顶端的下拉菜单中选择 Project 视图。
- 2. 导航至 MyProject/app/src/。
- 3. 右键点击 src 目录并选择 New > Folder > Java Folder。
- 4. 从 Target Source Set 旁边的下拉菜单中，选择合适的项。
- 5. 点击 Finish。

#### 7. 使用源集(Source Set)构建
您可以使用源集目录包含您希望仅针对特定配置打包的代码和资源。例如，如果您要构建"demoDebug" 的build variant，Gradle 会查看这些目录并赋予以下优先级顺序：

- src/demoDebug/ （build variant source set）
- src/debug/ （buildType SS）
- src/demo/ （productFlavor SS）
- src/main/ （main SS）

上面列出的顺序决定了在 Gradle 合并代码和资源时哪个源集具有较高的优先级。由于 demoDebug/ 源集目录很可能包含特定于该build variant的文件，如果 demoDebug/ 包含在 debug/ 中也有定义的文件，Gradle 将使用 demoDebug/ 源集中的文件。类似地，Gradle 为buildType和productFlavor源集中的文件赋予比 main/ 中相同文件更高的优先级。Gradle 在应用以下构建规则时会考虑此优先级顺序：

- 集中编译 java/ 目录中的所有源代码以生成单一的输出。
> 注：对于给定的build variant，如果找到两个或两个以上定义同一 Java 类的源集目录，Gradle 就会引发一个build error。例如，在构建调试 APK 时，您不能同时定义 src/debug/Utility.java and src/main/Utility.java。这是因为 Gradle 会在构建过程中检查这两个目录并引发“duplicate class”错误。如果您需要针对不同的 buildType 构建不同版本的 Utility.java，您可以让每个buildType定义自己的文件版本，而不将其包含在 main/ 源集中。

- 所有清单合并为单个清单文件。将按照上述列表中的相同顺序指定优先级。也就是说，某个buildType的清单设置会替换某个productFlavor的清单设置，依此类推。如需了解更多信息，请阅读[合并清单](https://developer.android.com/studio/build/manifest-merge.html?hl=zh-cn)。
- 类似地，values/ 目录中的文件也会合并在一起。如果两个文件同名，例如存在两个 strings.xml 文件，将按照上述列表中的相同顺序指定优先级。也就是说，在buildType源集中的文件中定义的值将会替换productFlavor中同一文件中定义的值，依此类推。
- res/ 和 asset/ 目录中的资源均打包在一起。如果两个或两个以上的源集中定义有同名资源，将按照上述列表中的相同顺序指定优先级。
- 最后，在构建 APK 时，Gradle 会为随库模块依赖项包含的资源和清单分配最低的优先级。声明依赖项

#### 8. 签署您的应用
[签署您的应用](https://developer.android.com/studio/publish/app-signing.html?hl=zh-cn#signing-manually)
> 打开连接, 里面是详细的apk打包流程, 和注意事项! 关键是中文哟

#### 9. SDK Build Tools 版本，Gradle 版本，Gradle Plugin 版本的对应关系

[Android Studio中gradle版本对应关系](http://yuanfentiank789.github.io/2017/04/17/gradle_version/)
[Android developer 地址](https://developer.android.com/studio/releases/gradle-plugin.html#revisions)
[下载地址](https://services.gradle.org/distributions/)

#### 10. Android Studio 加入aar 资源包 报Failed to resolve:

在Android Studio中创建一个module或者导入一个module的时候，如果这个module中依赖了aar库，当build工程的时候，会出现failed to resolve这个错误，如下图：
![Alt text](./20161214110404140.png)

这时候，只要在你的app build.gradle（不是project的build.gradle）中加入下面代码就可以完美解决了：

```
repositories {  
    flatDir {  
        dirs project(':taesdk').file('libs')  
    }  
```

上面代码中的“taesdk“替换成你的module的名字，libs是module依赖的aar库所在的目录

#### 11. 修改打包apk名
gradle 3.0 以下

```
applicationVariants.all { variant ->
        variant.outputs.each { output ->
            def timeNow = getDate()
            def oldFile = output.outputFile
            def newName = "zanzan" + "-" + buildType.name + "-" +  variant.productFlavors.name + "-v" + defaultConfig.versionName + '.apk'
            output.outputFile = new File(oldFile.parent, newName)
        }
    }
```
gradle 3.0 以上

```
applicationVariants.all { variant ->
        variant.outputs.all {
            // 输出apk名称为great_v1.0_wandoujia.apk
            outputFileName = "zanzan_${buildType.name}_${variant.productFlavors[0].name}_v${defaultConfig.versionName}.apk"

        }
    }
```

#### 12. compileSdkVersion, minSdkVersion 和 targetSdkVersion

[如何选择 compileSdkVersion, minSdkVersion 和 targetSdkVersion](https://chinagdg.org/2016/01/picking-your-compilesdkversion-minsdkversion-targetsdkversion/)

区别
- compileSdkVersion: SDK编译版本, 指定在代码编写过程中, 可以使用那些api, 修改它会导致新的编译警告和错误, 它纯粹只是在编译的时候使用. 

- minSdkVersion: 设备可运行应用的最低版本要求

- targetSdkVersion: 它是Android向前兼容的主要依据，应用运行时使用的sdk版本( 这个参数很重要! ) 
该参数指定的android sdk的功能特性，将在运行时生效。比如，targetSdkVersion<23时：该应用安装在android6.0以上版本的手机上后，不会执行android6.0系统以上特有的动态权限检查逻辑，而是仍继续执行以前的权限检查逻辑。

选择
- minSdkVersion <= targetSdkVersion == compileSdkVersion
