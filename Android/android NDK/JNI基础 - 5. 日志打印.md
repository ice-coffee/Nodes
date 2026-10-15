[toc]
### 使用介绍
**`log.h 文件地址`**：
> `../Library/Android/Sdk/ndk/22.1.7171670/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/android/log.h`

**`引入头文件：`**

```c++
#include <android/log.h>
```

**`常用接口：`**

```c++
/*
 * 发送一条消息到日志
 * @param prio 日志优先级
 * @param tag 
 * @param text 消息内容 
 */
int __android_log_write(int prio, const char *tag, const char *text);

/*
 * 发送一条模板消息
 * @param prio 日志优先级
 * @param tag 
 * @param fmt 消息模板
 * @param ... 模板填充值
 */
int __android_log_print(int prio, const char *tag,  const char *fmt, ...)
```

**`日志优先级：`**
```c++
typedef enum android_LogPriority {
    ANDROID_LOG_UNKNOWN = 0,
    ANDROID_LOG_DEFAULT,    /* only for SetMinPriority() */
    ANDROID_LOG_VERBOSE,
    ANDROID_LOG_DEBUG,
    ANDROID_LOG_INFO,
    ANDROID_LOG_WARN,
    ANDROID_LOG_ERROR,
    ANDROID_LOG_FATAL,
    ANDROID_LOG_SILENT,     /* only for SetMinPriority(); must be last */
} android_LogPriority;
```

### 示例
```c++
// 引入头文件
#include <android/log.h>

// 定义 TAG
#define TAG "jni_text"
// 定义宏
#define  LOGA_V(...)  __android_log_print(ANDROID_LOG_VERBOSE, TAG, __VA_ARGS__);
#define  LOGA_I(...)  __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__);
#define  LOGA_W(...)  __android_log_print(ANDROID_LOG_WARN, TAG, __VA_ARGS__);
#define  LOGA_D(...)  __android_log_print(ANDROID_LOG_DEBUG, TAG, __VA_ARGS__);
#define  LOGA_E(...)  __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__);

// 使用
LOGA_D("今天是周六");
LOGA_D("今天是%s", "周六");
```
