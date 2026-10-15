[toc]

`Java Native Interface (JNI)` 是 `Java` 平台的一部分，它提供了 `Java` 代码与其他编程语言（如 `C` 和 `C++`）交互的能力。`JNIEnv` 和 `JavaVM` 都是 `JNI` 中的重要组件。

`JNIEnv` 和 `JavaVM` 是定义在 `jni.h` 文件中的两个结构体。

* `JNIEnv` 包含了一组函数，可以让本地代码访问 `Java` 对象、调用 `Java` 方法、处理 `Java` 异常等。在 `JNI` 中，`JNIEnv` 是线程局部的，这意味着每个线程都需要自己的 `JNIEnv` 实例。
* `JavaVM` 包含了一组用于操作 `Java` 虚拟机的函数。`JavaVM` 是进程全局的，这意味着在一个进程中只有一个 `JavaVM` 实例。

## JNIEnv

### 获取 JavaVM 指针

```c++
/**
 * 获取 JavaVM 指针
 */
jint GetJavaVM(JavaVM** vm)
```

* `JavaVM** vm`：指向 `JavaVM` 的二级指针，用于返回 `JavaVM` 的指针。
* 返回值 `JNI_OK` 表示成功，其它表示失败。


在使用 `GetJavaVM` 函数时，需要注意以下几点：

1. `GetJavaVM` 函数只能在已经附加到 `Java` 虚拟机上的线程中使用，否则会返回 `JNI_EDETACHED` 错误。
2. 在使用 `GetJavaVM` 函数获取 `Java` 虚拟机实例后，需要将其存储在全局变量中，以便在需要时使用。
3. 在多线程环境中，应该使用线程本地存储（TLS）来存储 `Java` 虚拟机实例，以避免不同线程之间的竞争条件。
4. 在使用 `Java` 虚拟机实例时，需要使用 `AttachCurrentThread` 函数附加当前线程到 `Java` 虚拟机上，并在使用完成后使用 `DetachCurrentThread` 函数将当前线程分离出 `Java` 虚拟机。

## JavaVM
Java 虚拟机相关函数声明
Java 虚拟机相关数据类型声明

### 获取当前线程的 JNIEnv 指针

```c++
/**
 * 获取当前线程的 JNIEnv 指针
 */
jint GetEnv(void** env, jint version)
```

* `void** env`：指向 `JNIEnv` 的二级指针，用于返回 `JNIEnv` 的指针。
* `jint`：`JNIEnv` 的版本号，一般情况下应该使用 `JNI_VERSION_1_6` 或更高版本。
* 返回值 `JNI_OK` 表示成功，其它表示失败。

> **`注意`**：如果当前线程是本地线程且未和虚拟机线程关联那么可以通过 `AttachCurrentThread` 方法获取当前线程的 `JNIEnv` 指针。

示例：
```c++
#include <jni.h>

jint JavaObjectBase::GetThreadEnv(JavaVM* vm, JNIEnv ** env)
{
    if ( vm != V_NULL )
    {
        int ret = vm->GetEnv((void **)env, JNI_VERSION_1_6);
        if ( ret == JNI_OK )
        {
            return JNI_TRUE;
        }
        else if ( ret == JNI_EDETACHED )
        {
            int attach_ret = vm->AttachCurrentThread(env, 0);
            if (attach_ret == JNI_OK) {
                if ((*env) != V_NULL)
                {
                    return JNI_FALSE;
                } else {
                    return JNI_TRUE;
                }
            } else {
                (*env) = V_NULL;
                return JNI_TRUE;
            }
        } 
        else 
        {
            (*env) = V_NULL;
            return JNI_FALSE;
        }
    } 
    else 
    {
        return JNI_TRUE;
    }
}
```

## 常量
`JNI_TRUE` 和 `JNI_FALSE`：表示JNI函数执行成功或失败，用于表示函数返回值的布尔类型。

`JNI_OK`：表示JNI函数执行成功，没有发生异常。
`JNI_ERR`：表示JNI函数执行失败，通常是因为参数不正确或发生了其他错误。
`JNI_EDETACHED`：表示当前线程没有附加到Java虚拟机上，不能调用JNI函数。
`JNI_EVERSION`：JNI 版本错误。
`JNI_ENOMEM`：内存溢出。
`JNI_EEXIST`：Java虚拟机对象已存在。
`JNI_EINVAL`：无效参数。

`JNI_VERSION_1_1`、`JNI_VERSION_1_2`、`JNI_VERSION_1_4`、`JNI_VERSION_1_6`、`JNI_VERSION_1_8`：表示JNI版本号。

`JNI_THROW`：表示在JNI函数中抛出Java异常。
`JNI_ABORT`：表示停止JNI函数的执行。
