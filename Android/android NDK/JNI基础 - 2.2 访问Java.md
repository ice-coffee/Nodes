[toc]

## 访问Java函数

### 创建类Class对象

#### FindClass
使用 `FindClass` 函数创建 `Class` 对象。

**`函数定义`**：
```c++
/**
 * name：类的全路径名
 * return：类class对象
 */
jclass FindClass(const char *name)
```

**`注意`**：
* 类全路径名要将 `[.]` 替换成下划线 `[\]`。例如：`java.lang.String` -> `java\lang\String`;

#### GetObjectClass 
使用 `GetObjectClass` 函数获取 `Class` 对象。

**`函数定义`**：
```c++
/**
 * obj：类实例对象
 */
jclass GetObjectClass(jobject obj)
```

### 获取函数ID

`JNI` 提供了 `GetMethodID、GetStaticMethodID` 函数用于获取获取成员函数ID和静态函数ID。

**`GetStaticMethodID 函数定义`**：
```c++
/**
 * clazz：类Class对象
 * name：函数名
 * sig：方法签名
 * return：函数ID
 */
jmethodID GetStaticMethodID(jclass clazz, const char *name, const char *sig)
```

**`GetMethodID 函数定义`**：
```c++
/**
 * clazz：类Class对象
 * name：函数名
 * sig：方法签名
 * return：函数ID
 */
jmethodID GetMethodID(jclass clazz, const char *name, const char *sig)
```

#### 方法签名
**`格式`**：
> (参数列表)返回值

**`示例`**：

* void doSomething();
* void doSomething(int value);
* String doSomething(int age, String name);

签名依次为：

* ()V
* (I)V
* (ILjava/lang/String;)Ljava/lang/String;

详细内容可以看 [JNI基础 - native 方法规则](https://app.yinxiang.com/shard/s58/nl/10744683/c5940d2b-2406-4770-bc2e-8453fd8a7ef0/)

### 创建类实例对象

以调用默认构造函数举例：

获取默认构造函数的函数ID：
```c++
jmethodID mid_construct = env->GetMethodID(clazz, "<init>","()V");
```

`<init>`：固定写法，代表类的构造方法名称；
`()V`：代表无参无返回值的构造方法（即默认构造方法）；

#### NewObject 
使用 `NewObject` 函数创建实例对象
```c++
/**
 * clazz：类Class对象
 * methodID：构造函数ID
 * ...：参数列表
 */
jobject NewObject(jclass clazz, jmethodID methodID, ...)

jobject NewObjectV(jclass clazz, jmethodID methodID, va_list args)

jobject NewObjectA(jclass clazz, jmethodID methodID, const jvalue *args)
```

示例：
```c++
jobject jobj = env->NewObject(clazz, mid_construct); 
```

#### AllocObject
使用 `AllocObject` 函数创建实例对象
```c++
jobject AllocObject(jclass clazz)
```

示例：
```c++
jobject jobj = env->AllocObject(clazz);
// 使用 AllocObject 函数创建对象需调用 CallNonvirtualVoidMethod 初始化
env->CallNonvirtualVoidMethod(jobj, clazz, methodID, args);
```

#### NewObject vs AllocObject

* **`NewObject`**：通过 `NewObject` 方法创建的对象会直接初始化；
* **`AllocObject`**：通过 `AllocObject` 方法创建对象，是未被初始化的，需调用 `CallNonvirtualVoidMethod` 初始化。在一定程度上，可以说 `AllocObject` 方法是延迟初始化的。

> 注意：使用 `NewObject`、`AllocObject` 创建的对象，要手动调用 `DeleteLocalRef` 删除本地引用，放置内存泄露。

### 调用函数
#### 调用静态函数

**`函数定义`**：
```C++
/**
 * clazz：类Class对象
 * methodID：函数ID
 * ...：参数列表
 */
void CallStaticVoidMethod(jclass clazz, jmethodID methodID, ...)

void CallStaticVoidMethodV(jclass clazz, jmethodID methodID, va_list args)

void CallStaticVoidMethodA(jclass clazz, jmethodID methodID, const jvalue *args)
```

`JNI` 提供了一系列不同返回值的函数，`jint CallStaticIntMethod`、`jboolean CallStaticBooleanMethod` 等，引用类型统一调用 `jobject CallStaticObjectMethod` 函数。此外，每种返回值类型的函数都提供了接收3种实参类型的实现。

#### 调用成员函数
`JNI` 提供调用 `Java` 成员函数的函数和静态函数相比仅函数名不同。

**`函数定义`**：
```C++
/**
 * clazz：类Class对象
 * methodID：函数ID
 * ...：参数列表
 */
void CallVoidMethod(jclass clazz, jmethodID methodID, ...)

void CallVoidMethodV(jclass clazz, jmethodID methodID, va_list args)

void CallVoidMethodA(jclass clazz, jmethodID methodID, const jvalue *args)
```

#### 调用父类函数

**`函数定义`**：
```C++
/**
 * obj：类实例对象
 * clazz：类class对象
 * methodID：调用的函数ID
 * ...：参数列表
 */
void CallNonvirtualVoidMethod(jobject obj, jclass clazz, jmethodID methodID, ...)

void CallNonvirtualVoidMethodV(jobject obj, jclass clazz, jmethodID methodID, va_list args)

void CallNonvirtualVoidMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args)
```

### 释放局部变量

虽然函数结束后，`JVM` 会自动释放所有局部引用变量所占的内存空间。但还是手动释放一下比较安全。

```c++
(*env)->DeleteLocalRef(env,clazz);  
```

### 示例

静态函数调用：
```c++
JNIEXPORT void JNICALL Java_com_study_jnilearn_AccessMethod_callJavaStaticMethod  
(JNIEnv *env, jclass cls)  
{  
    jclass clazz;
    jmethodID mid_static_method;
    // 1、从classpath路径下搜索ClassMethod这个类，并返回该类的Class对象
    clazz = env->FindClass("com/study/jnilearn/ClassMethod");
    if (clazz == nullptr) {
        return;
    }

    // 2、从clazz类中查找callStaticMethod方法
    mid_static_method = env->GetStaticMethodID(clazz,"callStaticMethod","(Ljava/lang/String;I)V");
    if (mid_static_method == nullptr) {
        printf("找不到callStaticMethod这个静态方法。");
        return;
    }

    // 3、调用clazz类的callStaticMethod静态方法
    jstring str_arg = env->NewStringUTF("我是静态方法");
    env->CallStaticVoidMethod(clazz,mid_static_method, str_arg, 100);

    // 删除局部引用
    env->DeleteLocalRef(clazz);
    env->DeleteLocalRef(str_arg);
}  
```

成员函数调用：
```c++
JNIEXPORT void JNICALL Java_com_study_jnilearn_AccessMethod_callJavaInstaceMethod  
(JNIEnv *env, jclass cls)  
{  
    jclass clazz;  
    jobject jobj;  
    jmethodID mid_construct;  
    jmethodID mid_instance;  
    // 1、从classpath路径下搜索ClassMethod这个类，并返回该类的Class对象  
    clazz = env->FindClass("com/study/jnilearn/ClassMethod");  
    if (clazz == nullptr) {  
        printf("找不到'com.study.jnilearn.ClassMethod'这个类");  
        return;  
    }  

    // 2、获取类的默认构造方法ID  
    mid_construct = env->GetMethodID(clazz, "<init>","()V");  
    if (mid_construct == nullptr) {  
        printf("找不到默认的构造方法");  
        return;  
    }  

    // 3、查找实例方法的ID  
    mid_instance = env->GetMethodID(clazz, "callInstanceMethod", "(Ljava/lang/String;I)V");  
    if (mid_instance == nullptr) {  

        return;  
    }  

    // 4、创建该类的实例  
    jobj = env->NewObject(clazz, mid_construct);  
    if (jobj == NULL) {  
        printf("在com.study.jnilearn.ClassMethod类中找不到callInstanceMethod方法");  
        return;  
    }  

    // 5、调用对象的实例方法  
    jstring str_arg = env->NewStringUTF("我是实例方法");  
    env->CallVoidMethod(jobj, mid_instance, str_arg, 200);  

    // 删除局部引用  
    env->DeleteLocalRef(clazz);  
    env->DeleteLocalRef(jobj);  
    env->DeleteLocalRef(str_arg);  
}  
```

## 访问Java变量

### 访问静态变量

1. 调用 `FindClass` 获取 `Class` 类对象；
2. 调用 `GetStaticFieldID` 获取静态变量ID；
3. 调用 `GetStaticXXXField` 函数获取静态变量的值；
4. 调用 `SetStaticXXXField` 函数设置静态变量的值；

**`GetStaticFieldID`**：
```c++
/**
 * clazz：类class对象
 * name：变量名
 * sig：变量类型签名
 * return：变量ID
 */
jfieldID GetStaticFieldID(jclass clazz, const char *name, const char *sig)
```

**`GetStaticIntField`**：
```c++
/**
 * clazz：类class对象
 * fieldID：变量ID
 * return：变量值
 */
jint GetStaticIntField(jclass clazz, jfieldID fieldID)
```

**`SetStaticIntField`**：
```c++
/**
 * clazz：类class对象
 * fieldID：变量ID
 * value：int变量新值
 */
void SetStaticIntField(jclass clazz, jfieldID fieldID, jint value)
```

**`示例`**：

```c++
//1.获取ClassField类的Class引用  
jclass clazz = env->FindClass("com/study/jnilearn/ClassField");  
if (clazz == nullptr) {    // 错误处理  
    return;  
}  

//2.获取ClassField类静态变量num的属性ID  
jfieldID fid = env->GetStaticFieldID(clazz, "num", "I");  
if (fid == nullptr) {  
    return;  
}  

// 3.获取静态变量num的值  
jint num = env->GetStaticIntField(clazz, fid);  
printf("In C--->ClassField.num = %d\n", num);  

// 4.修改静态变量num的值  
env->SetStaticIntField(clazz, fid, 80);  

// 删除属部引用  
env->DeleteLocalRef(clazz);  
```

### 访问成员变量

1. 调用 `FindClass` 获取 `Class` 类对象；
2. 调用 `GetFieldID` 获取成员变量ID；
3. 调用 `GetXXXField` 函数获取成员变量的值；
4. 调用 `SetXXXField` 函数设置成员变量的值；

**`GetFieldID`**：
```c++
/**
 * clazz：类class对象
 * name：变量名
 * sig：变量类型签名
 * return：变量ID
 */
jfieldID GetFieldID(jclass clazz, const char *name, const char *sig)
```

**`GetIntField`**：
```c++
/**
 * clazz：类class对象
 * fieldID：变量ID
 * return：变量值
 */
jint GetIntField(jclass clazz, jfieldID fieldID)
```

**`SetFieldID`**：
```c++
/**
 * clazz：类class对象
 * fieldID：变量ID
 * value：int变量新值
 */
void SetFieldID(jclass clazz, jfieldID fieldID, jint value)
```

**`示例`**：

```c++
// 1.获取AccessField类的Class引用  
jclass clazz = env->GetObjectClass(obj);  
if (clazz == nullptr) {  
    return;  
}  

// 2. 获取AccessField类实例变量str的属性ID  
jfieldID fid = env->GetFieldID(clazz, "str", "Ljava/lang/String;");  
if (clazz == nullptr) {  
    return;  
}  

// 3. 获取实例变量str的值  
jstring j_str = (jstring)env->GetObjectField(obj, fid);  

// 4. 将unicode编码的java字符串转换成C风格字符串  
const char *c_str = env->GetStringUTFChars(j_str, nullptr);  
if (c_str == nullptr) {  
    return;  
}  
printf("In C--->ClassField.str = %s\n", c_str);  
env->ReleaseStringUTFChars(j_str, c_str);  

// 5. 修改实例变量str的值  
jstring j_newStr = env->NewStringUTF("This is C String");  
if (j_newStr == nullptr) {  
    return;  
}  

env->SetObjectField(obj, fid, j_newStr);  

// 6.删除局部引用  
env->DeleteLocalRef(clazz);  
env->DeleteLocalRef(j_str);  
env->DeleteLocalRef(j_newStr);  
```
