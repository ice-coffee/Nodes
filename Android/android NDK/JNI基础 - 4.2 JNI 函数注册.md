[toc]

[ART虚拟机 | JNI静态注册和动态注册](https://juejin.cn/post/6955322183895908366)

注册的本质是建立(`Java` 层) `native` 方法和(`Native/C++`层) `JNI` 函数之间的一对一关系。静态注册指的是映射规则预先设定，一个 `native` 方法名可以转换成一个唯一的 `JNI` 函数名。动态注册的映射规则由程序员自己设定，通过结构体将 `native` 方法和 `JNI` 函数指针绑定起来。

## 静态注册

### JNI函数名规则

完整函数名模板如下：
```
JNIEXPORT 返回值类型 JNICALL Java_包名_类名_方法名__参数签名(JNIEnv *, jclass, ...)
```

> **`注意`**：
> - 如果没有函数重载，可以省略拼接 `__参数签名`。
> - 方法名和方法签名之间由两个下划线连接。

#### JNIEXPORT 和 JNICALL
[【Android NDK 开发】JNI 方法解析 \( JNIEXPORT 与 JNICALL 宏定义作用 \)](https://blog.csdn.net/shulianghan/article/details/104072587)

`JNIEXPORT` 和 `JNICALL` 宏定义与平台相关。

* `JNIEXPORT`：该声明的作用是保证在生成动态库时此方法能够在其他项目中被调用；
* `JNICALL`：在 `Linux` 平台为空定义，在 `Windows` 平台下表示函数的入栈规则。

#### 返回值类型
返回值类型为 `JNI` 数据类型，参照 [JNI基础 - 数据类型]。

#### 参数签名

参数签名是由 `Java` 函数中的参数类型拼接后，由字段描述符替代对应数据类型，并进行字符转换得到。

`Java` 数据类型与签名中数据类型字段描述符的映射关系如下：

| 字段描述符 | Java 类型 | 示例 |
| --- | --- | --- |
| Z | boolean | |
| B | byte | |
| C | char | |
| S | short | |
| I | int | |
| J | long | |
| F | float | |
| D | double | |
| V | void | |
| "L+全路径类名+;" | 引用类型 | String：Ljava/lang/String; |
| "[+字段描述符" | 数组 | String[]：[Ljava/lang/String; |

> **`注意`**：
> - 参数列表中，每个引用类型都是以 "`L`" 开头，后面紧跟类的全路径名（需将"`.`"全部替换成"`/`"），最后以"`;`"结尾。例如，`String` 表示为 `Ljava/lang/String;`。

如果一个函数中只有一个 `String` 字符串参数，那么：
`String`
替换描述符后：
`Ljava/lang/String;` 

#### 字符转换
`JNI` 在函数命名时采用名字扰乱方案，以保证所有的 `Unicode` 字符都能转换为有效的C函数名，所有的"`/`",无论是包名中的还是全限定类名中的，均使用"`_`"代替，用`_0,…,_9`来代替转义字符，如下：

| 转义字符序列 | 表示 |
| --- | --- |
| _0XXXX | Unicode字符XXXX |
| _1 | 字符“_” |
| _2 | 签名中的字符“;” |
| _3 | 签名中的字符“[” |

`Ljava/lang/String;` 
经过字符转换后得到：
`Ljava/lang/String_2`

举一个比较复杂的例子，

```java
void function(String[] strs, int[] values)
```

函数参数中包含字符串数组和整型数组：
`String[]int[]`
替换描述符后：
`[Ljava/lang/String;[I` 
经过字符转换后得到：
`_3Ljava_lang_String_2_3I`

#### 参数

| 参数 | 说明 |
| --- | --- |
| `JNIEnv *` | `JNIEnv *` 是任意 `native` 方法的第一个参数； |
| `jclass` | `jclass` 表示此 `native` 方法是静态方法，如果方法是实例方法，则是 `jobject`； |
| `...` | 为 `Java` 函数中的参数列表 |

#### 示例
Java 原生函数：
```java
package com.example;

public class MyClass {
    public static native String nativeMethod(String value);

    public static native int nativeMethod(int value);
}
```

JNI 函数：
```c++
#include <jni.h>

JNIEXPORT jstring JNICALL Java_com_example_MyClass_nativeMethod__Ljava_lang_String_2(JNIEnv *, jclass, jstring value);

JNIEXPORT jint JNICALL Java_com_example_MyClass_nativeMethod__I(JNIEnv *, jclass, jint value);
```

## 动态注册

加载 `so` 库时会调用 `JNI_Onload` 函数。在 `JNI_Onload` 函数中可以调用 `RegisterNatives` 动态注册本地函数。`RegisterNatives` 函数声明如下：

```c++
/**
 * @param clazz 函数所在类的类对象
 * @param methods JNINativeMethod 函数数组
 * @param nMethods 动态注册函数个数
 */
jint RegisterNatives(jclass clazz, const JNINativeMethod* methods, jint nMethods)
```

`clazz` 类对象可以通过 `FindClass` 函数获取。
结构体 `JNINativeMethod` 定义如下：

```c++
typedef struct {
    // 对应Java函数的函数名
    const char* name;
    // 对应Java函数的方法签名
    const char* signature;
    // 对应JNI函数的函数指针
    void*       fnPtr;
} JNINativeMethod;
```

定义一个 `JNINativeMethod` 数组：

```c++
static JNINativeMethod methods[] = {
    {"nativeMethod", "(Ljava/lang/String;)Ljava/lang/String;", (void *) Java_MyClass_nativeMethod__Ljava_lang_String_2},
    {"nativeMethod", "(I)I", (void *) Java_MyClass_nativeMethod__I},
};
```

函数个数可以通过 `sizeof` 计算：

```
sizeof(methods) / sizeof(methods[0])
```

### 方法签名

方法签名格式：`(参数类型描述符列表)返回值类型描述符`。描述符参照上表。

> 注意：`()`必须存在即使目标函数没有参数。

### 示例
JNI 代码如下：
```c++
#include <jni.h>

extern "C" JNIEXPORT jint JNICALL MyClass_nativeMethod(
        JNIEnv* env, jclass /* this */, jint value) {

    value += 1;

    return value;
}

static JNINativeMethod methods[] = {
        {"nativeMethod", "(I)I", (void *)MyClass_nativeMethod}
};

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    JNIEnv *env = nullptr;

    if (vm->GetEnv((void **)&env, JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    jclass findClass = env->FindClass("com/example/nativeMethod");
    if (findClass == nullptr) {
        return JNI_ERR;
    }

    if (env->RegisterNatives(findClass, methods, sizeof(methods) / sizeof(methods[0])) < 0) {
        return JNI_ERR;
    }

    return JNI_VERSION_1_6;
}
```
Java 代码如下：
```java
package com.example;

public class MyClass {
    static {
        System.loadLibrary("native-lib");
    }

    public native int nativeMethod(int value);
}
```
