[toc]

## 创建Java虚拟机

### 创建Java虚拟机
```c++
/**
 * 创建Java虚拟机
 * @param JavaVM**: JavaVM指针的地址
 * @param JNIEnv**: JNIEnv指针的地址
 * @param void*: Java虚拟机参数指针
 * @return JNI_OK:成功，JNI_ERR:失败
 */
jint JNI_CreateJavaVM(JavaVM**, JNIEnv**, void*);
```

* `JavaVM**`：JavaVM指针的地址
* `JNIEnv**`：JNIEnv指针的地址
* `void*`：Java虚拟机参数指针
* 返回值 `JNI_OK` 表示成功，其它表示失败。

```c++
/**
 * 销毁Java虚拟机
 */
jint DestroyJavaVM()
```

```c++
/**
 * 获取默认Java虚拟机参数指针
 */
jint JNI_GetDefaultJavaVMInitArgs(void*);
```

* `void*`：Java虚拟机参数指针。
* 返回值 `JNI_OK` 表示成功，其它表示失败。

虚拟机参数结构体：

```c++
typedef struct JavaVMOption {
    const char* optionString;
    void*       extraInfo;
} JavaVMOption;

typedef struct JavaVMInitArgs {
    jint        version;    /* use JNI_VERSION_1_2 or later */

    jint        nOptions;
    JavaVMOption* options;
    jboolean    ignoreUnrecognized;
} JavaVMInitArgs;
```

示例：

```c++
#include <jni.h>
#include <stdio.h>

int main() {
    JavaVM *jvm;
    JNIEnv *env;
    JavaVMInitArgs vm_args;
    jint res;
    int nOptions = 1;
    JavaVMOption options[1];

    // 获取默认的 Java 虚拟机初始化参数
    res = JNI_GetDefaultJavaVMInitArgs(&vm_args);
    if (res != JNI_OK) {
        printf("Error: Failed to get default JVM init args\n");
        return 1;
    }

    // 修改 Java 类路径，添加当前目录
    options[0].optionString = "-Djava.class.path=.";
    vm_args.options = options;
    vm_args.nOptions = nOptions;

    // 创建 Java 虚拟机实例
    res = JNI_CreateJavaVM(&jvm, (void **)&env, &vm_args);
    if (res != JNI_OK) {
        printf("Error: Failed to create JVM instance\n");
        return 1;
    }

    // 调用 Java 方法
    jclass cls = env->FindClass("HelloWorld");
    jmethodID mid = env->GetStaticMethodID(cls, "main", "([Ljava/lang/String;)V");
    env->CallStaticVoidMethod(cls, mid, nullptr);

    // 销毁 Java 虚拟机实例
    jvm->DestroyJavaVM();

    return 0;
}
```

### 获取虚拟机列表

```c++
/**
 * 获取当前已创建虚拟机列表 
 */
jint JNI_GetCreatedJavaVMs(JavaVM**, jsize, jsize*);
```

* `JavaVM**`：指向 JavaVM* 数组的指针，该数组用于存储 Java 虚拟机实例的列表。函数会将 JavaVM* 指针存储到该数组中，并返回实际存储的 Java 虚拟机实例数量。
* `jsize`：表示 vmBuf 数组的长度。
* `jsize*`：指向 jint 类型变量的指针，用于存储已创建 Java 虚拟机实例的数量。
* 返回值 `JNI_OK` 表示成功，其它表示失败。

示例：

```c++
#include <jni.h>

int main(int argc, char **argv) {
    JavaVM *jvms[1];
    jint num_vms;

    // 获取已创建的 Java 虚拟机列表
    jint rc = JNI_GetCreatedJavaVMs(jvms, 1, &num_vms);
    if (rc != JNI_OK) {
        // 获取 Java 虚拟机列表失败，处理错误
    }

    // 处理已创建的 Java 虚拟机列表
    for (int i = 0; i < num_vms; i++) {
        JavaVM *jvm = jvms[i];

        // 使用 jvm 进行操作，例如获取 JNIEnv 等
    }

    return 0;
}
```

## 操作Java虚拟机

### 本地线程访问Java
[JNI为什么要调用AttachCurrentThread？](https://keeplooking.top/2020/05/19/Android/AttachCurrentThread/)
在 `Java` 中通过 `Thread` 创建的线程时实际 `JVM` 会调用本地方法在本地创建线程，并和 `Java Thread` 关联。

但是在本地创建的线程因为没有和 `Java Thread` 创建联系所以不可以访问 `Java`。

通过 `AttachCurrentThread`、`AttachCurrentThreadAsDaemon` 方法可以将本地线程关联到 `JVM`，之后就可以正常访问 `Java` 方法或对象了，访问结束后需调用 `DetachCurrentThread` 方法解除关联。

方法声明如下：
```c++
/**
 * 将当前原生线程附加到 JVM 中，使该线程能够与 JVM 交互
 */
jint AttachCurrentThread(JNIEnv** p_env, void* thr_args)
/**
 * 将当前原生线程附加到 JVM 中，作为守护线程存在
 */
jint AttachCurrentThreadAsDaemon(JNIEnv** p_env, void* thr_args)
/**
 * 解除当前原生线程和 JVM 的关系
 */
jint DetachCurrentThread()
```

* `p_env`：二级指针，用于返回指向 `JNIEnv` 的指针，可以用其来访问 `Java`。
* `thr_args`：指向任意类型的指针，通常传 `nullptr`, 也可以传递一些参数给新建的线程。
* 返回值 `JNI_OK` 表示成功，其它表示失败。

线程参数定义如下：
```c++
struct JavaVMAttachArgs {
    jint        version;    /* must be >= JNI_VERSION_1_2 */
    const char* name;       /* NULL or name of thread as modified UTF-8 str */
    jobject     group;      /* global ref of a ThreadGroup object, or NULL */
};
typedef struct JavaVMAttachArgs JavaVMAttachArgs;
```

如果使用 `JavaVMAttachArgs` 结构体时，可以指定如线程名等属性，有助于管理线程，而使用 `nullpter` 时会为该线程分配一个默认名称。

示例：
```java
void doSomthingOnJavaThread(JNIEnv* env, JavaVM* jvm) {
    JavaVMAttachArgs args;
    args.version = JNI_VERSION_1_6;
    args.name = "test_1";
    args.group = nullptr;

    // 附加当前线程到Java虚拟机
    jint res = jvm->AttachCurrentThreadAsDaemon((JNIEnv **)&env, &args);
    if (res != JNI_OK) {
        return;
    }

    // 在守护线程中执行Java代码
    jclass myClass = env->FindClass("com/example/MyClass");
    jmethodID myMethod = env->GetStaticMethodID(myClass, "myMethod", "()V");
    env->CallStaticVoidMethod(myClass, myMethod);

    // 分离当前线程
    jvm->DetachCurrentThread();
}
```
