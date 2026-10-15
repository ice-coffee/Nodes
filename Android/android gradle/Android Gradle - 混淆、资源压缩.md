https://juejin.cn/post/6844903639698374669

[Android 混淆从入门到精通](http://mp.weixin.qq.com/s?__biz=MzA4NDM2MjAwNw==&mid=2650576349&idx=1&sn=c0a7f535d352f7f6ba2367225f0a134a&chksm=87e063a5b097eab3c88b74e8b17f396064d74c634a5d76d4b014aaec34b07e6881bc28f9f0f2&mpshare=1&scene=23&srcid=1216CPMuwCK55jklsXmquT45#rd)

[Android Proguard(混淆)](http://www.jianshu.com/p/60e82aafcfd0)

[ProGuard 最全混淆规则说明](https://www.jianshu.com/p/b471db6a01af)

[Android反编译工具总结](http://sunzq1993.com/2017/03/19/Android%E5%8F%8D%E7%BC%96%E8%AF%91%E5%B7%A5%E5%85%B7%E6%80%BB%E7%BB%93/)

[使用gradle减少apk大小](https://www.jianshu.com/p/f8f6ba13f4f8)

[TOC]

### 简介
作为Android开发者，如果你不想开源你的应用，那么在应用发布前，就需要对代码进行混淆处理，从而让我们代码即使被反编译，也难以阅读。混淆概念虽然容易，但很多初学者也只是网上搜一些成型的混淆规则粘贴进自己项目，并没有对混淆有个深入的理解。本篇文章的目的就是让一个初学者在看完后，能在不进行任何帮助的情况下，独立写出适合自己代码的混淆规则。

#### 说在前面

这里我们直接用Android Studio来说明如何进行混淆，Android Studio自身集成Java语言的ProGuard作为压缩，优化和混淆工具，配合Gradle构建工具使用很简单，只需要在工程应用目录的gradle文件中设置minifyEnabled为true即可。然后我们就可以到proguard-rules.pro文件中加入我们的混淆规则了。

```
android {
    ...
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

以上示例代码表示对release版本就行混淆处理。下面我们先来简介下ProGuard的三大作用，并简要说明下它们常用的命令。

#### ProGuard作用

压缩（Shrinking）：默认开启，用以减小应用体积，移除未被使用的类和成员，并且会在优化动作执行之后再次执行（因为优化后可能会再次暴露一些未被使用的类和成员）。

`-dontshrink` 关闭压缩

优化（Optimization）：默认开启，在字节码级别执行优化，让应用运行的更快。

`-dontoptimize`  关闭优化
- optimizationpasses n 表示proguard对代码进行迭代优化的次数，Android一般为5
混淆（Obfuscation）：默认开启，增大反编译难度，类和类成员会被随机命名，除非用keep保护。

`-dontobfuscate` 关闭混淆

混淆后默认会在工程目录app/build/outputs/mapping/release下生成一个mapping.txt文件，这就是混淆规则，我们可以根据这个文件把混淆后的代码反推回源本的代码，所以这个文件很重要，注意保护好。原则上，代码混淆后越乱越无规律越好，但有些地方我们是要避免混淆的，否则程序运行就会出错，所以就有了下面我们要教大家的，如何让自己的部分代码避免混淆从而防止出错。

### 基本语法

先看如下两个比较常用的命令，很多童鞋可能会比较迷惑以下两者的区别。

```
-keep class cn.hadcn.test.**
-keep class cn.hadcn.test.*
```

一颗星表示只是保持该包下的类名，而子包下的类名还是会被混淆；两颗星表示把本包和所含子包下的类名都保持；用以上方法保持类后，你会发现类名虽然未混淆，但里面的具体方法和变量命名还是变了，这时如果既想保持类名，又想保持里面的内容不被混淆，我们就需要以下方法了

```
-keep class cn.hadcn.test.* {*;}
```

在此基础上，我们也可以使用Java的基本规则来保护特定类不被混淆，比如我们可以用extend，implement等这些Java规则。如下例子就避免所有继承Activity的类被混淆

```
-keep public class * extends android.app.Activity
```

如果我们要保留一个类中的内部类不被混淆则需要用$符号，如下例子表示保持ScriptFragment内部类JavaScriptInterface中的所有public内容不被混淆。

```
-keepclassmembers class cc.ninty.chat.ui.fragment.ScriptFragment$JavaScriptInterface {
   public *;
}
```

再者，如果一个类中你不希望保持全部内容不被混淆，而只是希望保护类下的特定内容，就可以使用

```
<init>;     //匹配所有构造器
<fields>;   //匹配所有域
<methods>;  //匹配所有方法方法
```

你还可以在`<fields>`或`<methods>`前面加上private 、public、native等来进一步指定不被混淆的内容，如

```
-keep class cn.hadcn.test.One {
    public <methods>;
}
```

表示One类下的所有public方法都不会被混淆，当然你还可以加入参数，比如以下表示用JSONObject作为入参的构造函数不会被混淆

```
-keep class cn.hadcn.test.One {
   public <init>(org.json.JSONObject);
}
```

有时候你是不是还想着，我不需要保持类名，我只需要把该类下的特定方法保持不被混淆就好，那你就不能用keep方法了，keep方法会保持类名，而需要用keepclassmembers ，如此类名就不会被保持，为了便于对这些规则进行理解，官网给出了以下表格

| 保留      |     防止被移除或者被重命名 |  防止被重命名  |
| :-------- | :--------:| :------: |
|  类和类成员   |  	-keep  |  	-keepnames  |
|  仅类成员   |  -keepclassmembers  |  	-keepclassmembernames  |
|  如果拥有某成员，保留类和类成员   |  -keepclasseswithmembers  |  -keepclasseswithmembernames  |

### 常见混淆设置

* **`-ignorewarnings`**：
忽略所有警告。

* **`-dontwarn`**：
告诉 `ProGuard` 不要对指定的类或包发出『找不到引用』或『未使用的代码』等警告。

示例：

```
# 忽略所有以 `android` 开头的包或者类所产生的警告
-dontwarn android**
```

* **`-dontoptimize`**：
这个参数告诉 `ProGuard` 不要对代码进行优化。优化可能包括移除未使用的代码、内联短方法、简化条件语句等。在某些情况下，开发者可能不希望进行这些优化，可能是因为优化可能会改变代码的行为（尽管这种情况很少见），或者是因为优化过程本身可能消耗大量时间。

* **`-dontpreverify`**：
ProGuard默认会对处理后的类文件进行预校验，以确保它们符合Java字节码规范。使用-dontpreverify参数可以跳过这一步。在Android开发中，由于Dalvik虚拟机（Android 2.x及更早版本使用）和ART运行时（Android 5.0及更高版本使用）在加载类时会进行自己的验证，因此通常不需要ProGuard进行预校验。

> 设置之后有可能导致混淆后的包在运行时字节码校验失败，如下：

```
Exception in thread "main" java.lang.VerifyError: Expecting a stackmap frame at branch target 15
Exception Details:
  Location:
    android/os/Handler.dispatchMessage(Landroid/os/Message;)V @4: ifnull
  Reason:
    Expected stackmap frame at this location.
  Bytecode:
    0000000: 2bb4 0012 c600 0b2a 2bb7 0019 a700 1d2a
    0000010: b400 0ec6 0011 2ab4 000e 2bb9 0031 0200
    0000020: 9900 04b1 2a2b b600 1ab1     
```

* **`-dontusemixedcaseclassnames`**：
这个参数指示 `ProGuard` 在混淆类名时，不要使用大小写混合的命名方式。这主要是为了兼容性考虑，因为某些文件系统或运行环境可能对大小写敏感。

* **`-dontskipnonpubliclibraryclasses`**：
默认情况下，`ProGuard` 可能会跳过非公共库类的处理（例如，第三方库中的类）。使用此参数可以确保所有库类，无论其访问级别如何，都会被 `ProGuard` 处理。这有助于确保即使是非公共的库类也能被混淆、优化等。

* **`-dontskipnonpubliclibraryclassmembers`**：
此参数可以确保所有库类的成员（如方法和字段）也会被 `ProGuard` 处理。

* **`-verbose`**：
启用详细输出模式。在处理过程中，`ProGuard` 会打印出更多的信息，帮助开发者了解哪些类被保留、哪些被移除、哪些被混淆等。这对于调试 `ProGuard` 配置文件非常有用。

* **`-dontshrink`**：
这个参数告诉 `ProGuard` 不要移除任何代码或资源。通常，`ProGuard` 会分析代码，移除未使用的类或方法，以减少应用的大小。使用它可以禁用这一行为，保留所有代码和资源。

### 常见混淆规则
#### 1、属性混淆
以 `keepattrbutes` 开头，不混淆的各种属性如下：

**`异常和内部类：`**
```
-keepattributes Exceptions
```

**`内部类：`**
```
-keepattributes InnerClasses
```

**`泛型：`**
```
-keepattributes Signature
```

**`注解：`**
```
-keepattributes *Annotation*
```

**`抛出异常时保留代码行号：`**
```
-keepattributes SourceFile,LineNumberTable
```

**`JS：`**
```
-keepattributes *JavascriptInterface*
```

#### 2、单个内部类不混淆规则
使用内部类写法$，例如：
```
-keep interface some.demo$inner{*;}
```

> 注意：使用此功能需要先设置 `-keepattributes InnerClasses`。

#### 3、常见继承不混淆
```
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service 
-keep public class * extends android.content.BroadcastReceiver 
-keep public class * extends android.content.ContentProvider 
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class com.android.vending.licensing.ILicensingService
-keep public class * extends android.widget.BaseAdapter {*;}
```

#### 4、保持native方法不被混淆
```
-keepclasseswithmembernames class * { 
    native <methods>;
}
```

#### 5、保留枚举enum类不被混淆
```
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
```

#### 6、序列化不混淆
```
-keep class * implements android.os.Parcelable{
    public static final android.os.Parcelable$Creator *;
}
```
```
-keepclassmembers class * implements java.io.Serializable {
   static final long serialVersionUID;
   private static final java.io.ObjectStreamField[] serialPersistentFields;
   !static !transient <fields>;
   private void writeObject(java.io.ObjectOutputStream);
   private void readObject(java.io.ObjectInputStream);
   java.lang.Object writeReplace();
   java.lang.Object readResolve();
}
```
#### 7、不混淆资源、support中的v4和v7
```
-keepclassmembers class **.R$* { *; }
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
}
# support-v4
-dontwarn android.support.v4.**
-keep class android.support.v4.** { *; }
-keep interface android.support.v4.** { *; }
-keep public class * extends android.support.v4.**
# support-v7
-dontwarn android.support.v7.**                                             #去掉警告
-keep class android.support.v7.** { *; }                                    #过滤android.support.v7
-keep interface android.support.v7.app.** { *; }
-keep public class * extends android.support.v7.**
```

#### 8、自定义view
```
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(***);
    *** get* ();
}
```

#### 9、回调函数
```
-keepclassmembers class * {
    void *(**On*Listener);
}
```

#### 10、第三方引用
```
# 不混淆第三方引用的库
-dontskipnonpubliclibraryclasses
```

#### 11、JSON 相关实体类
与服务端交互时，使用 `GSON`、`fastjson` 等框架解析服务端数据时，所写的 `JSON` 对象类不可混淆，否则无法将 `JSON` 解析成对应的对象；

#### 12、Android 四大组件和自定义 View 默认不混淆
`AndroidMainfest` 中的类不会被混淆，所以四大组件和 `Application` 的子类和 `Framework` 层下所有的类默认不会进行混淆。`自定义View` 默认也不会被混淆；所以像网上贴的很多排除 `自定义View`，或四大组件被混淆的规则在 `AS` 中是无需加入的；


### 使用命令行执行混淆
`ProGuard` 可以用于对 `Java` 项目和 `Android` 项目的混淆，但是对于 `Android` 项目来说 `ProGuard` 是默认集成在 `Andoid SDK` 中的，只需要添加混淆规则即可。

对于纯 `Java` 项目来说，如果要使用 `ProGuard` 对代码进行混淆，那么可以使用命令行调用的方式。

下载 `ProGuard`：
[ProGuard GitHub](https://github.com/Guardsquare/proguard?tab=readme-ov-file)

目录说明：
```
|--bin：     存放调起混淆、反混淆、ProGuard视图的脚本
|--docs：    说明文档
|--example： 各种项目的使用示例
|--lib：     提供实际功能的库
```

使用 `progurad` 脚本混淆代码示例：

> bin/proguard.sh `-injars` in.jar `-outjars` out.jar `-libraryjars` ${JAVA_HOME}/jmods/java.base.jmod `-printmapping` mapping.txt `-include` proguard-rules.pro

说明：

* `-injars`：要混淆的 `jar` 包；
* `-outjars`：混淆后的 `jar` 包；
* `-libraryjars`：
* `-printmapping`：生成映射文件；
* `-include`：指定混淆配置文件；

### 写在最后

发布一款应用除了设`minifyEnabled`为ture，你也应该设置`zipAlignEnabled`为true，像Google Play强制要求开发者上传的应用必须是经过zipAlign的，zipAlign可以让安装包中的资源按4字节对齐，这样可以减少应用在运行时的内存消耗。所以通常是这样写法.
```
android {
    ...
    buildTypes {
        release {
            minifyEnabled true
            zipAlignEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```
