* FrameMetrics
* StrictMode
* Macrobenchmark 和 Microbenchmark：[对您的应用进行基准测试](https://developer.android.com/topic/performance/benchmarking/benchmarking-overview?hl=zh-cn)
* Debug.startMethodTracing

[TOC]

### StrictMode
`StrictMode` 是 **Android 提供的一套开发期问题检测工具**，主要用于**发现并暴露可能导致卡顿（ANR）、性能下降或不规范行为的代码**。它不会直接修复问题，而是**尽早让问题“显形”**。

[StrictMode](https://developer.android.com/reference/android/os/StrictMode)

#### 能解决什么问题？

StrictMode 主要关注 **两大类违规行为**：

##### 线程策略（ThreadPolicy）

> **防止在主线程做“慢操作”**

典型问题：

* 主线程进行磁盘 I/O（读 / 写文件）
* 主线程进行网络请求
* 主线程进行不合理的阻塞操作
* 主线程调用某些反射、Binder 慢调用（高版本）

这些行为很容易导致：

* 掉帧
* 卡顿
* ANR

##### 虚拟机策略（VmPolicy）

> **发现容易引发内存泄漏或资源滥用的问题**

典型问题：

* Activity / Context 泄漏
* SQLite Cursor / Closeable 对象未关闭
* 文件描述符泄漏
* 明显的内存泄漏路径
* 注册但未反注册的对象（部分版本）

#### 基本使用方式

StrictMode **只建议在 Debug / 内测环境启用**。

**启用 `ThreadPolicy`**

```java
StrictMode.setThreadPolicy(
        new StrictMode.ThreadPolicy.Builder()
                .detectDiskReads()
                .detectDiskWrites()
                .detectNetwork()
                .penaltyLog()
                .build()
);
```

| 方法               | 含义       |
| ---------------- | -------- |
| detectDiskReads  | 主线程读磁盘   |
| detectDiskWrites | 主线程写磁盘   |
| detectNetwork    | 主线程网络访问  |
| detectAll        | 开启所有可检测项 |

---

**启用 `VmPolicy`**

```java
StrictMode.setVmPolicy(
        new StrictMode.VmPolicy.Builder()
                .detectLeakedSqlLiteObjects()
                .detectLeakedClosableObjects()
                .detectActivityLeaks()
                .penaltyLog()
                .build()
);
```

| 方法 | 含义 |
| --- | --- |
| detectLeakedClosableObjects | Closeable 未关闭 |
| detectLeakedSqlLiteObjects | Cursor / SQLite 泄漏 |
| detectActivityLeaks | Activity 泄漏 |
| detectFileUriExposure | file:// Uri 暴露（7.0+） |
| detectAll | 所有检测 |

#### 常见 penalty（违规后的处理方式）

| penalty               | 作用                |
| --------------------- | ----------------- |
| penaltyLog            | Logcat 输出违规信息     |
| penaltyDialog         | 弹窗（仅调试用）          |
| penaltyDropBox        | 写入 DropBox        |
| penaltyDeath          | **直接 Crash（强约束）** |
| penaltyDeathOnNetwork | 主线程网络直接 Crash     |

⚠️ **建议策略**

* 开发期：`penaltyLog + penaltyDialog`
* 内测：`penaltyLog`
* 正式版：通常关闭或只保留极少项

#### 示例

通常放在 `Application#onCreate()` 中：

```java
if (BuildConfig.DEBUG) {
    StrictMode.setThreadPolicy(
            new StrictMode.ThreadPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .build()
    );

    StrictMode.setVmPolicy(
            new StrictMode.VmPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .build()
    );
}
```
输出示例：
```text
StrictMode: DiskReadViolation
    android.os.StrictMode$StrictModeDiskReadViolation
    at android.os.StrictMode.onReadFromDisk(StrictMode.java:...)
    at java.io.FileInputStream.read(FileInputStream.java:...)
    at ...
```

#### 进阶技巧：临时放行（白名单）

```java
StrictMode.ThreadPolicy old = StrictMode.allowThreadDiskReads();
try {
    // 临时允许
} finally {
    StrictMode.setThreadPolicy(old);
}
```

#### 总结

**StrictMode 是 Android 提供的“开发期性能与规范探照灯”，用来提前发现本该异步、却跑在主线程上的问题，以及常见资源泄漏风险。**
