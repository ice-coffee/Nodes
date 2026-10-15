[toc]

### 概述
`Android NDK` 是在 `SDK` 前面又加上了**原生**二字，即`Native Development Kit`，因此又被称为 `NDK`。

众所周知，`Android` 程序运行在虚拟机中，`NDK` 允许用户使用类似 `C/C++` 之类的原生代码语言执行部分程序。字节码需要由虚拟机解释，而本地代码可以由设备处理器直接执行，没有任何中间步骤，执行速度更快，有时快很多。

#### 为何要用到NDK?
概括来说主要分为以下几种情况：
1. 代码的保护，由于 `apk` 的 `java` 层代码很容易被反编译，而 `C/C++` 库反汇难度较大。
2. 在 `NDK` 中调用第三方 `C/C++` 库，因为大部分的开源库都是用 `C/C++` 代码编写的。
3. 便于移植，用 `C/C++` 写的库可以方便在其他的嵌入式平台上再次使用。

####  NDK下载
[下载链接](http://d.android.com/sdk/ndk)

- 目录结构

NDK包含多个平台以及不同版本的预编译库。NDKr7支持以下三个应用程序的二进制接口(ABI):
- armeabi
- armeabi-v7a
- x86
> 注意：NDK不支持ARMv6的ABI

### 原生应用
[构建您的项目](https://developer.android.com/ndk/guides/build?hl=zh-cn)

[Android developer - 添加C/C++代码](https://developer.android.com/studio/projects/add-native-code?hl=zh-cn)

在 `Android` 项目中使用 `NDK` 编译原生代码主要有三种方式：

* `cmake`：一个跨平台的开源构建系统，广泛用于各类项目，包括但不限于 `Android` 项目。`CMake` 使用 `CMakeLists.txt` 文件来定义构建配置和规则，并能够生成适合多种构建系统的项目文件，例如 `Makefile`、`Ninja`、`Visual Studio` 项目等。
* `ndk-build`：基于 `Make` 是 `Android NDK` 中自带的构建系统，使用 `Android.mk` 和 `Application.mk` 文件来定义构建规则和配置选项。
* `独立工具链`：用于与其他构建系统集成。

#### CMake

`CMake` 相关语法可以参照如下：

* [C++ - CMake](https://app.yinxiang.com/shard/s58/nl/10744683/56af1549-da55-4725-b458-f32687dd6cfd/)

在 `Android` 项目中编译原生代码需要在 `module` 级的 `build.gradle` 文件配置 `CMake` 脚本文件的链接：

```groovy
android {
  ...
  defaultConfig {...}
  buildTypes {...}

  externalNativeBuild {
    cmake {
      // 配置 CMakeLists.txt 文件相对 build.gradle 文件的地址
      path "CMakeLists.txt"
    }
  }
}
```

##### 指定可选配置

[CmakeFlags](https://developer.android.com/reference/tools/gradle-api/8.0/com/android/build/api/dsl/CmakeFlags?_gl=1*1uh7t3x*_up*MQ..*_ga*MTA3MjQyMTcwMC4xNzIyNjcwMTI2*_ga_6HH9YJMN9M*MTcyMjY3MDEyNi4xLjAuMTcyMjY3MDY0My4wLjAuMA..)

在 `defaultConfig` 代码块中可以使用 `externalNativeBuild` 代码块为 `CMake` 指定编译属性。

和其它存在于 `defaultConfig` 中的属性一样，可以在每个 `productFlavors` 中复写 `CMake` 的编译属性：

```groovy
android {
  ...
  defaultConfig {
    ...
    // defaultConfig 内的 externalNativeBuild 配置和外部作用不同
    externalNativeBuild {
      cmake {
        arguments "-DANDROID_ARM_NEON=TRUE", "-DANDROID_TOOLCHAIN=clang"
        cFlags "-D__STDC_FORMAT_MACROS"
        cppFlags "-fexceptions", "-frtti"
      }
    }
  }

  productFlavors {
    ...
    demo {
      ...
      externalNativeBuild {
        cmake {
          targets "native-lib-demo",
                  "my-executible-demo"
        }
      }
    }

    paid {
      ...
      externalNativeBuild {
        cmake {
          ...
          targets "native-lib-paid",
                  "my-executible-paid"
        }
      }
    }
  }

  // 配置 CMake 脚本链接
  externalNativeBuild {
    cmake {
    	path "src/main/cpp/CMakeLists.txt"
    }
  }
}
```

* `arguments`：指定 `CMake` 参数。
* `cppFlags`：指定 `c++` 编译器标识，包括定义宏、启用或禁用特性等。
* `cFlags`：同上。
* `targets`：指定Gradle应该从CMake项目中构建的库和可执行目标。例如，如果你的CMake项目定义了多个库和可执行文件，你可以告诉Gradle只构建这些输出的一个子集。
