[ndk preview官网](http://tools.android.com/tech-docs/android-ndk-preview)

[NDK-JNI实战教程（一） 在Android Studio运行第一个NDK程序](http://yanbober.github.io/2015/02/14/android_studio_jni_1/)

> ABI : 应用程序二进制接口

#### 开发准备工作
在集成NDK时会报这样的错误:

```
Error: NDK integration is deprecated in the current plugin.
```

需要在`gradle.properties`中添加以下代码

```
android.useDeprecatedNdk=true
```

在`local.properties`中添加NDK路径(路径以自己本地NDK路径为准)

```
ndk.dir=D\:\\android_data\\android_NDK\\android-ndk-r12b-windows-x86_64\\android-ndk-r12b
```

#### 声明本地方法
在java代码中声明本地方法和声明普通java方法并无太大区别, 只是使用了`native`关键字, 并没有方法实现

```
public static native long localNative(int n);
```

#### 实现JNI粘合层
通过在cmd页面输入以下命令生成头文件
```
javah -jni -classpath ./bin -d ./jni com.example.android.Fibonacci
```
参数说明
- classpath：类搜索路径，表示某个目录下查找(命令中使用`./bin`代指)
- d：将生成的头文件放到当前的 jni 目录下(命令中使用`./jni`代指)
- o：指定生成的头文件名称，默认以类全路径名生成（包名+类名.h） 
> 注意: 
> - -d 和 -o不可混用
> - 使用-o生成的头文件在当前命令行目录下
> - 由于生成 .h 头文件需要使用 .class 文件, 使用Android Studio开发可以在 /app/build/intermediates目录下寻找

#### 创建Makefile

Android.mk

> 只需要关心LOCAL_MODULE和LOCAL_SRC_FILES的定义, 其他照抄即可

```
//指向本地Android.mk路径
LOCAL_PATH := $(call my-dir)

//清除LOCAL_PATH之外的所有LOCAL_XXX变量, 这个必须加, 不然变量可能被错误定义
include $(CLEAR_VARS)

//定义模块名称也就是生成库的名称
LOCAL_MODULE    := hello-jni

//编译到库中的文件
LOCAL_SRC_FILES := hello-jni.c

//构建库规则
include $(BUILD_SHARED_LIBRARY)
```
> 注意: 如果有多个需要编译到库中的文件那么记得在 LOCAL_SRC_FILES 队列里添加, 以空格隔开即可

#### 实现本地函数

#### 编译本地库
首先修改PATH变量, 把NDK目录加进去. 然后就可以在CMD页面使用`ndk-build`命令了
![Alt text](./ndk-build.png)

#### 加载本地库
在静态初始化块内调用`System.loadLibrary`加载本地库, 是加载库的最简单方法. 
> 注意: 加载本地库时要注意, 如果你的本地库文件为`libXYZ.so`, 那么加载时要这样写>`System.loadLibrary("XYZ")`, 由于生成的 .so 库文件默认会在文件名前加 `lib` .


#### 坑人集锦

##### 1. java.lang.UnsatisfiedLinkError: Couldn't load XXX indLibrary returned null
解决方案:
- 首先把生成的 .so 库文件连带文件夹添加到 `libs`文件夹里
- 在`build.gradle`文件里添加语句

```
android {
    sourceSets {
        main {
            jniLibs.srcDirs = ['libs']
        }
}
```
