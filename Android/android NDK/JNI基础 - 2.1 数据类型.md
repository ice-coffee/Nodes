[toc]

## 数据类型
### 基本数据类型

| Java | JNI | C++ |  |
| --- | --- | --- | --- |
| boolean | jboolean | bool | unsigned 8 bits |
| byte | jbyte | signed char | signed 8 bits |
| char | jchar | char | signed 8 bits |
| short | jshort | short int | signed 16 bits |
| int | jint | int | signed 32 bits |
| long | jlong | long int | signed 64 bits |
| float | jfloat | float | 32 bits |
| double | jdouble | double | 64 bits |

`JNI` 的基本数据类型其实是 `C++` 数据类型的别名，所以可以使用直接赋值转换。如下：

```c++
typedef uint8_t  jboolean; /* unsigned 8 bits */
typedef int8_t   jbyte;    /* signed 8 bits */
typedef uint16_t jchar;    /* unsigned 16 bits */
typedef int16_t  jshort;   /* signed 16 bits */
typedef int32_t  jint;     /* signed 32 bits */
typedef int64_t  jlong;    /* signed 64 bits */
typedef float    jfloat;   /* 32-bit IEEE 754 */
typedef double   jdouble;  /* 64-bit IEEE 754 */
```

示例：
```c++
#include <jni.h>

extern "C" JNIEXPORT jint JNICALL
Java_com_baidu_demo_MainActivity_addFromJNI(JNIEnv* env, jobject, jint value) {
    int jni_value = value;
    jni_value += 1;
    return jni_value;
}
```

### 扩展数据类型
| Native | C++ |  |
| --- | --- | --- |
| jsize | int | signed 32 bits |

### 引用类型

**`引用数据类型表：`**
![](https://doc.yonyoucloud.com/doc/wiki/project/jni-ndk-developer-guide/images/recommend.png)

#### 概念
**`局部引用表`**
[JNI内存管理之Local Reference 和 Global Reference知识点](https://blog.csdn.net/qq_29426201/article/details/106593840)
![局部引用表](https://mzp-blog.oss-cn-beijing.aliyuncs.com/cpp_img/local_reference.png)

每当线程从 `Java` 环境进入到 `Native` 环境后，`JVM` 就会创建该线程 `Native` 环境的局部引用表，用来保存本次 `Native` 环境所创建的所有局部引用，每当 `Native` 中引用或者新创建一个 `Java` 对象，`JVM` 就会局部引用表创建一个局部引用，局部引用表是有大小限制的，最大是 `512`，如果超过限制会报 `OOM` 内存泄漏。（最大数量并不固定，JVM可根据需要动态调整大小。调整方式未知）。

#### 局部引用
引用数据类型表中的引用对象在函数内部创建就是局部引用，也可以通过 `NewLocalRef` 函数创建。局部引用不可以跨方法、跨线程使用。函数返回后局部引用所引用的对象会被 `JVM` 自动释放，或调用 `DeleteLocalRef` 释放。

**`示例：`**
```c++
// 创建局部引用
jclass cls_string = env->FindClass("java/lang/String");
// ......
// 释放局部引用
env->DeleteLocalRef(cls_string);
```

##### 管理局部引用
`JNI` 提供了一系列函数来管理局部引用的生命周期。这些函数包括：
* `NewLocalRef`：创建局部引用
* `DeleteLocalRef`：释放局部引用
* `EnsureLocalCapacity`
* `PushLocalFrame`
* `PopLocalFrame`

**`EnsureLocalCapacity：`**
`JNI` 规范指出，任何实现 `JNI` 规范的 `JVM`，必须确保每个本地函数至少可以创建 `16` 个局部引用。如果需要创建更多的引用，可以通过调用 `EnsureLocalCapacity` 函数，确保在当前线程中创建指定数量的局部引用，如果创建成功则返回 0，否则创建失败，并抛出 `OutOfMemoryError` 异常。

```c++
/*处理函数逻辑时，确保函数能创建len个局部引用*/
if(env->EnsureLocalCapacity(len) != 0) {
    ... /*申请len个局部引用的内存空间失败 OutOfMemoryError*/
    return;
}
for(i=0; i < len; i++) {
    jstring jstr = env->GetObjectArrayElement(arr, i);
    // ... 使用jstr字符串
    /*这里没有删除在for中临时创建的局部引用*/
}
```

**`PushLocalFrame、PopLocalFrame：`**
`PushLocalFrame` 和 `PopLocalFrame` 可以创建、销毁引用栈。

```c++
#define N_REFS ... /*最大局部引用数量*/
for (i = 0; i < len; i++) {
    if (env->PushLocalFrame(N_REFS) != 0) {
        ... /*内存溢出*/
    }
    jstring jstr = env->GetObjectArrayElement(arr, i);
    ... /* 使用jstr */
    env->PopLocalFrame(NULL);
}
```

每遍历一次调用 `env->GetObjectArrayElement(arr, i);` 返回一个局部引用时，`JVM` 会自动将该引用压入当前局部引用栈中。
在调用 `PopLocalFrame` 销毁当前 `frame` 中的所有引用前，如果第二个参数 `result` 不为空，会由 `result` 生成一个新的局部引用，再把这个新生成的局部引用存储在上一个 `frame` 中。

```c++
// 函数原型
jobject (JNICALL *PopLocalFrame)(JNIEnv *env, jobject result);

jstring other_jstr;
for (i = 0; i < len; i++) {
    if (env->PushLocalFrame(N_REFS) != 0) {
        ... /*内存溢出*/
    }
    jstring jstr = env->GetObjectArrayElement(arr, i);
    ... /* 使用jstr */
    if (i == 2) {
       other_jstr = jstr;
    }
    other_jstr = env->PopLocalFrame(other_jstr);  // 销毁局部引用栈前返回指定的引用
}
```

#### 全局引用
调用 `NewGlobalRef` 基于局部引用创建。可以跨方法、跨线程使用。`JVM` 不会自动释放，必须调用 `DeleteGlobalRef` 手动释放。

**`示例：`**
```c++
// 创建局部变量
jclass cls_string = env->FindClass("java/lang/String");
// 创建全局变量
jobject obj_global = env->NewGlobalRef(cls_string);

// ******

// 释放全局变量
env->DeleteGlobalRef(obj_global);
// 释放局部变量
env->DeleteLocalRef(cls_string);
```

**`使用场景：`**


#### 弱全局引用
弱全局引用使用 `NewGlobalWeakRef` 创建，使用 `DeleteGlobalWeakRef` 释放。下面简称弱引用。与全局引用类似，弱引用可以跨方法、线程使用。但与全局引用很重要不同的一点是，弱引用不会阻止 `GC` 回收它引用的对象。

**`示例：`**
```c++
JNIEXPORT void JNICALL
Java_mypkg_MyCls_f(JNIEnv *env, jobject self)
{
    static jclass myCls2 = NULL;
    if (myCls2 == NULL)
    {
        jclass myCls2Local = env->FindClass("mypkg/MyCls2");
        if (myCls2Local == NULL)
        {
            return; /* 没有找到mypkg/MyCls2这个类 */
        }
        myCls2 = NewWeakGlobalRef(env, myCls2Local);
        if (myCls2 == NULL)
        {
            return; /* 内存溢出 */
        }
    }
    ... /* 使用myCls2的引用 */
}
```

**`使用场景：`**
待补充

#### 引用比较
使用函数 `IsSameObject` 可以判断两个引用是否指向相同的对象。有一个特殊的引用需要注意：`NULL`，`JNI` 中的 `NULL` 引用指向 `JVM` 中的 `null` 对象。如果 `obj` 是一个局部或全局引用，使用`(*env)->IsSameObject(env, obj, NULL)` 或者 `obj == NULL` 来判断 `obj` 是否指向一个 `null` 对象即可。但需要注意的是，`IsSameObject` 用于弱全局引用与 `NULL` 比较时，返回值的意义是不同于局部引用和全局引用的。

```c++
jobject local_obj_ref = env->NewObject(xxx_cls,xxx_mid);
jobject g_obj_ref = env->NewWeakGlobalRef(local_ref);
// ... 业务逻辑处理
jboolean isEqual = env->IsSameObject(g_obj_ref, NULL);
```

在上面的 `IsSameObject` 调用中，如果 `g_obj_ref` 指向的 **`Java 对象`** 已经被回收，会返回 `JNI_TRUE`，否则返回 `JNI_FALSE`。

## 字符串
### 访问字符串

在 `JNI` 中 `jstring` 类型无法直接访问字符串，需要通过 `GetStringUTFChars` 等方法进行访问。

**`示例`**：

```c++
JNIEXPORT jstring JNICALL Java_com_study_jnilearn_Sample_sayHello  
  (JNIEnv *env, jclass cls, jstring j_str)  
{  
    const char *c_str = NULL;  
    char buff[128] = {0};  
    jboolean isCopy;    // 返回JNI_TRUE表示原字符串的拷贝，返回JNI_FALSE表示返回原字符串的指针  
    c_str = env->GetStringUTFChars(j_str, &isCopy);  
    printf("isCopy:%d\n",isCopy);  
    if(c_str == NULL)  
    {  
        return NULL;  
    }  
    printf("C_str: %s \n", c_str);  
    sprintf(buff, "hello %s", c_str);  
    env->ReleaseStringUTFChars(j_str, c_str);  
    return env->NewStringUTF(buff);  
}  
```

#### GetStringUTFChars、ReleaseStringUTFChars

**`函数定义`**：
```
const char* GetStringUTFChars(jstring string, jboolean* isCopy);
```

- **`jstring`**：`jstring` 类型（`Java` 传递给本地代码的字符串指针）
- **`jboolean`**：调用 `GetStringUTFChars` 函数时，`JVM` 会根据平台有两种选择。第一种，将 `jstring` 所对应的原始 `jchar` 拷贝一份给你，这时候会将 `isCopy` 赋值为 `true`；第二种，将 `jstring` 所对应的原始 `jchar*` 直接返回给你，这时候会将 `isCopy` 赋值为 `false`，这意味着可以通过指针修改源字符串的内容，不推荐这么做，因为这样做就打破了 `Java` 字符串不能修改的规定。但我们在开发当中，并不关心这个值是多少，通常情况下这个参数填 `NULL/nullptr` 即可。

**`函数异常`**：

调用完 `GetStringUTFChars` 之后不要忘记安全检查，因为 `JVM` 需要为新诞生的字符串分配内存空间，当内存空间不够分配的时候，会导致调用失败，失败后 `GetStringUTFChars` 会返回 `NULL`，并抛出一个 `OutOfMemoryError` 异常。`JNI` 的异常和 `Java` 中的异常处理流程是不一样的，`Java` 遇到异常如果没有捕获，程序会立即停止运行。而 `JNI` 遇到未决的异常不会改变程序的运行流程，也就是程序会继续往下走，这样后面针对这个字符串的所有操作都是非常危险的，因此，我们需要用 `return` 语句跳过后面的代码，并立即结束当前方法。

**`*释放字符串`**：

在调用 `GetStringUTFChars` 函数从 `JVM` 内部获取一个字符串之后，`JVM` 内部会分配一块新的内存，用于存储源字符串的拷贝，以便本地代码访问和修改。即然有内存分配，用完之后马上释放是一个编程的好习惯。`ReleaseStringUTFChars` 方法可以通知 `JVM` 可以清除目标内存。

#### GetStringCritical、ReleaseStringCritical

- 提高 `JVM` 返回源字符串直接指针的可能性。
- `Get/ReleaseStringCritical` 可直接返回源字符串的指针。
- `GetStringCritical` 得到的是一个指向 `JVM` 内部字符串的直接指针，获取这个直接指针后会导致暂停 `GC` 线程，当 `GC` 被暂停后，如果其它线程触发 `GC` 继续运行的话，都会导致阻塞调用者。所以在 `Get/ReleaseStringCritical` 这对函数中间的任何本地代码都不可以执行导致阻塞的调用或为新对象在 `JVM` 中分配内存，否则  `JVM` 有可能死锁。
- `JVM` 在执行 `GetStringCritical` 这个函数时仍有发生数据复制的可能性，尤其当 `JVM` 内部存储的数组不连续时，为了返回一个指向连续内存空间的指针，`JVM` 必须复制所有数据。
- 因为可能发生内存复制，所以需要检查可能因为内存溢出而导致它的返回值为 `NULL、nullptr`。

正确使用示例：

```c++
JNIEXPORT jstring JNICALL Java_com_study_jnilearn_Sample_sayHello  
  (JNIEnv *env, jclass cls, jstring j_str)  
{  
    const jchar* c_str= NULL;  
    char buff[128] = "hello ";  
    char* pBuff = buff + 6;  
    /* 
     * 在GetStringCritical/RealeaseStringCritical之间是一个关键区。 
     * 在这关键区之中,绝对不能呼叫JNI的其他函数和会造成当前线程中断或是会让当前线程等待的任何本地代码， 
     * 否则将造成关键区代码执行区间垃圾回收器停止运作，任何触发垃圾回收器的线程也会暂停。 
     * 其他触发垃圾回收器的线程不能前进直到当前线程结束而激活垃圾回收器。 
     */  
    c_str = env->GetStringCritical(j_str, NULL);   // 返回源字符串指针的可能性  
    if (c_str == NULL)  // 验证是否因为字符串拷贝内存溢出而返回NULL  
    {  
        return NULL;  
    }  
    while(*c_str)   
    {  
        *pBuff++ = *c_str++;  
    }  
    env->ReleaseStringCritical(j_str, c_str);  
    return env->NewStringUTF(buff);  
}  
```

> 备注：`GetStringCritical`、`ReleaseStringCritical` 具体的使用场景并不明确，若只是单纯的打印日志那在 `Java` 层就可以打印，如果是因为不进行内存复制，但在上面的例子中自己申请了

#### GetStringRegion、GetStringUTFRegion

**`函数定义`**：
```c++
/**
 * JNIEnv*：JNI环境对象指针
 * jstring：拷贝数据源
 * jsize：开始拷贝位置
 * jsize：拷贝长度
 * jchar*：从指针指向的位置开始缓存数据，缓冲区必须足够大
 */
void (*GetStringRegion)(JNIEnv*, jstring, jsize, jsize, jchar*);
void (*GetStringUTFRegion)(JNIEnv*, jstring, jsize, jsize, char*);
```

分别表示获取 `Unicode` 和 `UTF-8` 编码字符串指定范围内的内容。这对函数会把源字符串复制到一个预先分配的缓冲区内。

示例代码：

```c++
JNIEXPORT jstring JNICALL Java_com_study_jnilearn_Sample_sayHello  
  (JNIEnv *env, jclass cls, jstring j_str)  
{  
    jsize len = env->GetStringLength(j_str);  // 获取unicode字符串的长度  
    printf("str_len:%d\n",len);  
    char buff[128] = "hello ";  
    char* pBuff = buff + 6;  
    // 将JVM中的字符串以utf-8编码拷入C缓冲区,该函数内部不会分配内存空间  
    env->GetStringUTFRegion(j_str, 0, len, pBuff);  
    return env->NewStringUTF(buff);  
}
```

`GetStringUTFRegion` 这个函数会做越界检查，如果检查发现越界了，会抛出 `StringIndexOutOfBoundsException` 异常，这个方法与 `GetStringUTFChars` 比较相似，不同的是，`GetStringUTFRegion` 内部不分配内存，不会抛出内存溢出异常。

> 注意：`GetStringUTFRegion` 和 `GetStringRegion` 这两个函数由于内部没有分配内存，所以 `JNI` 没有提供 `ReleaseStringUTFRegion` 和 `ReleaseStringRegion` 这样的函数。

### 创建字符串
通过调用 `NewStringUTF` 函数，会构建一个新的 `java.lang.String` 字符串对象。这个新创建的字符串会自动转换成 `Java` 支持的 `Unicode` 编码。如果 `JVM` 不能为构造 `java.lang.String` 分配足够的内存，`NewStringUTF` 会抛出一个 `OutOfMemoryError` 异常，并返回 `NULL`。在这个例子中我们不必检查它的返回值，如果 `NewStringUTF` 创建 `java.lang.String` 失败，`OutOfMemoryError` 这个异常会被在 `native` 方法被调用的地方抛出。如果 `NewStringUTF` 创建 `java.lang.String` 成功，则返回一个 `JNI` 引用，这个引用指向新创建的 `java.lang.String` 对象。

**`示例`**：
```c++
// 创建字符串：
jstring str_arg = env->NewStringUTF("我是静态方法");
// 删除引用：
env->DeleteLocalRef(str_arg); 
```

### 常见字符串方法

| 函数 | 返回值 | 说明 |
| --- | --- | --- |
| GetStringUTFChars | const char* | 用于获取以 `UTF-8` 格式编码的字符串 |
| ReleaseStringUTFChars | void | 释放 ~ |
| GetStringChars | const jchar* | 用于获取以 `Unicode` 格式编码的字符串 |
| ReleaseStringChars | void | 释放 ~ |
| GetStringCritical | const jchar* | 获取源字符串指针 |
| ReleaseStringCritical | void | 释放 ~ |
| GetStringRegion | void | 获取 `Unicode` 编码字符串指定范围内的内容，无内存分配不需要 release |
| GetStringUTFRegion | void | 获取 `UTF-8` 编码字符串指定范围内的内容，无内存分配不需要 release |
| NewStringUTF | jstring | 创建 `Unicode` 字符串 |
| GetStringLength | jsize | 获取一个 `Unicode` 编码的字符串长度 |
| GetStringUTFLength | jsize | 获取一个 `UTF-8` 编码字符串的长度，也可以通过标准 C 函数 `strlen` 获取。 |

> 注意：
> - 通过 `GetStringUTFChars`、`GetStringChars`、`GetStringCritical` 获取字符串，这些函数内部会分配内存，必须调用相对应的 `ReleaseXXXX` 函数释放内存。
> - 对于小字符串来说，`GetStringRegion` 和 `GetStringUTFRegion` 这两对函数是最佳选择，因为缓冲区可以被编译器提前分配，而且永远不会产生内存溢出的异常。当你需要处理一个字符串的一部分时，使用这对函数也是不错。因为它们提供了一个开始索引和子字符串的长度值。另外，复制少量字符串的消耗 也是非常小的。

## 数组

| 函数名 | 返回值 | 说明 |
| --- | --- | --- |
| getArrayLength | jsize | 返回数组长度 |

### 基本数据类型数组访问

`JNI` 提供了两种访问基本数据类型数组的访问方式：

* **`GetArrayRegion/SetArrayRegion`**

**优点**：可以避免直接操作 `Java` 数组，减少了因直接访问数组而导致的潜在错误。
不会影响原始数组，操作安全。
**缺点**：需要额外的内存空间来存储复制的数组片段，可能会增加内存开销。每次调用都需要进行数组的复制，可能会影响性能，尤其是当数组较大时。

* **`GetArrayElements/ReleaseArrayElements`**

**优点**：直接操作原始数组，无需额外的内存开销，效率较高。不会复制数组元素，节省了内存。
**缺点**：直接操作原始数组，容易引起内存访问错误，需要小心处理指针，避免造成内存泄漏或越界访问等问题。返回的指针在释放前一直有效，需要及时释放以避免内存泄漏，否则可能导致资源占用过多。

综上所述，选择使用哪个函数取决于具体情况。如果需要避免对原始数组的直接操作或者需要保证安全性，可以选择使用 `GetIntArrayRegion`；如果需要高效地直接访问原始数组，并且能够确保操作的安全性，可以选择使用 `GetIntArrayElements`。

#### GetArrayRegion/SetArrayRegion
以 `int` 数组举例：
| 函数 | 返回值 | 说明 |
| --- | --- | --- |
| GetIntArrayRegion | void | 将 `Java` 数组中的元素拷贝到 `JNI` 数组 |
| SetIntArrayRegion | void | 以 `JNI` 数组中的元素替换 `Java` 数组中的元素 |

**`GetIntArrayRegion`**：
```c++
/**
 *@param 第一个参数：JNIEnv 指针
 *@param 第二个参数：Java 数组
 *@param 第三个参数：拷贝数组起始索引
 *@param 第四个参数：拷贝数组长度
 *@param 第五个参数：JNI 数组指针
 */
void (*GetIntArrayRegion)(JNIEnv*, jintArray, jsize, jsize, jint*);
```

**`SetIntArrayRegion`**：
```c++
/**
 * 与 get 函数相同
 */
void (*SetIntArrayRegion)(JNIEnv*, jintArray, jsize, jsize, const jint*);
```

#### GetArrayElements/ReleaseArrayElements
以 `int` 数组举例：
| 函数 | 返回值 | 说明 |
| --- | --- | --- |
| GetIntArrayElements | jint* | 获取指向 `Java` 数组的 `JNI` 数组指针 |
| ReleaseIntArrayElements | void | 释放 `JNI` 数组指针 |

**`GetIntArrayElements`**：
```c++
/**
 *@param array：Java 数组
 *@param isCopy：非NULL指针，函数调用后根据返回数组指针是否指向原始数组为其赋值 
         isCopy == JNI_TRUE 表示返回的是临时缓冲区的数组指针
         isCopy == JNI_FALSE 表示返回的是原始数组指针
 */
jint* GetIntArrayElements(jintArray array, jboolean* isCopy)
```

**`ReleaseIntArrayElements`**：
```c++
/**
 *@param array：Java 数组
 *@param elems：Get 函数返回的数组指针
 *@param mode：释放模式
 */
void ReleaseIntArrayElements(jintArray array, jint* elems, jint mode)
```

释放模式用于控制修改数组元素的值后是否同步到 `Java` 数组，模式有如下三种：

* **`mode 0`**：刷新 `java` 数组，并释放 `C/C++` 数组；
* **`mode 1(JNI_COMMIT)`**：只刷新 `java` 数组；
* **`mode 2(JNI_ABORT)`**：只释放 `C/C++` 数组；

`mode 0、1` 表示如果修改了数组的值，那么最终 `Java` 层数组的值也会被修改。`mode 2` 则表示不会修改 `Java` 层数组的值。

> `Byte、Char、Short、Int、Long、Float、Double` 类型数组也有各自对应的函数。

### 对象数组访问

`JNI` 提供了两个函数来访问对象数组，`GetObjectArrayElement` 返回数组中指定位置的元素，`SetObjectArrayElement` 修改数组中指定位置的元素。与基本类型不同的是，我们不能一次得到数据中的所有对象元素或者一次复制多个对象元素到缓冲区。因为字符串和数组都是引用类型，只能通过 `Get/SetObjectArrayElement` 这样的 `JNI` 函数来访问字符串数组或者数组中的数组元素。

```c++
/**
 *@param array：Java 数组
 *@param index：目标元素所在数组位置下标
 */
jobject GetObjectArrayElement(jobjectArray array, jsize index)

/**
 *@param array：Java 数组
 *@param index：目标元素所在数组位置下标
 *@param value：新的 Java 对象元素
 */
void SetObjectArrayElement(jobjectArray array, jsize index, jobject value)
```
