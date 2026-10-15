[toc]

导致 `Crash` 的原因大致如下：

* `Java` 崩溃
* `Native` 崩溃
* `ANR` 
* 内存

处理 `crash` 最重要的手段就是：`捕获异常，收集异常信息`。

### 工具

* `bugly`
* `Android Studio Profiler`
* `LeakCanary`

### Java 崩溃
`Java` 崩溃就是在 `Java` 代码中出现了 `未捕获` 的异常，导致程序异常退出。

#### 捕获
全局捕获异常：[Thread.UncaughtExceptionHandler](https://www.jianshu.com/p/c13eb158d39e)

通过它获取 `Exception` 对象，获取异常信息。

### Native 崩溃
`Native` 崩溃一般是因为在 `Native` 代码中访问非法地址，也可能地址对齐出现问题，或程序主动 `abort`，这些都会产生相应的 `signal` 信号导致程序退出。

#### 捕获

### ANR 异常退出

### 获取异常信息

#### 线程名、进程名

#### Logcat
> `Logcat` 中包括应用、系统的运行日志。由于系统权限问题，获取到的 `Logcat` 可能只包含与当前 `App` 相关的。其中系统的 `event logcat` 会记录 `App` 运行的一些基本情况，记录在文件 `/system/etc/event-log-tags` 中。

如何获取 `Logcat`

#### 内存信息

* 系统剩余内存
* 应用使用内存
* 虚拟内存
