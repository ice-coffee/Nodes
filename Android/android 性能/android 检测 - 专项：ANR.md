[toc]

## 获取 ANR 信息
### 命令行获取

**`获取`**：

文件目录为 `data/`，但是未 `root` 设备无法访问该文件夹。可以通过 `adb` 命令获取 `crash` 以及 `ANR` 文件：
生成
```c++
adb bugreport
```
拉去到本地：
```
adb pull <生成文件目录> <存放目录>
```

**`示例`**：
```c++
ice-coffeedeMBP:~ ice-coffee$ adb bugreport
/data/user_de/0/com.android.shell/files/bugreports/bugreport-AGS3-W00D-HUAWEIAGS3-W00D-2022-10-15-16-14-34.zip: 1 file pulled. 36.2 MB/s (5088886 bytes in 0.134s)
ice-coffeedeMBP:~ ice-coffee$ adb pull /data/user_de/0/com.android.shell/files/bugreports/bugreport-AGS3-W00D-HUAWEIAGS3-W00D-2022-10-15-16-14-34.zip
```

**`文件目录`**：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/adb_bugreport.jpg)

### ANR 文件分析

在 `/data/anr/` 文件中可能会看到如下多个文件：
```
anr_2026-01-06-03-38-21-933
temp_anr_301996988825851051.txt
trace_00
...
trace_63
```
其中分析主要依靠 `anr_*` 文件，其它文件可以看成是在 `ANR` 过程中生成的中间文件。

在 `anr_*` 文件中，内容主要分为如下几个部分：

* **ANR 事件概要信息**
* **Java 线程快照（ART）**
* **Native 线程快照（debuggerd）**
* **Kernel 状态快照（/proc）**

#### ANR 事件概要信息
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/performance/cpu/anr_part_1.png)

**ANR 事件概要信息：**
* `Subject`：说明 `ANR` 类型，此处表明为 `输入事件分发超时` 触发
* `Process`：发生 `ANR` 的 应用进程名
* `PID`：发生 `ANR` 时的进程 `ID`
* `UID`：用户 `ID`
* `Frozen`：
* `Foreground`：应用是否处于前台
* `Process uptime`：进程已运行时长
* `Activity`：当前获得输入焦点的 Activity
* `Build`：设备信息
* `OnlyDumpSelf`：是否仅 `dump` 当前进程

常见 `ANR` 类型：
| Reason | 含义 |
| --- | --- |
| Input dispatching timed out | 输入 ANR（5s） |
| Broadcast of Intent | 广播 ANR（10s） |
| Executing service | Service ANR（20s） |

> 注：`ANR` 并不代表造成的原因，只是外在表现。

**系统内存快照：**
* `RssHwmKb`：历史上占用过的最大物理内存峰值
* `RssKb`：当前时刻进程实际占用的物理内存
* `RssAnonKb`：匿名页占用的物理内存
* `RssShmemKb`：共享内存占用的 RSS
* `VmSwapKb`：该进程被 swap 到磁盘的内存大小

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/performance/cpu/cpu_part_2.png)

> `PSI`：内核级系统压力快照

这里分别表示系统内存、CPU、IO在过去 `10/60/300` 秒内阻塞时间的占比。

* `some`：至少有一个任务被阻塞
* `full`：所有可运行任务都被阻塞

#### 线程信息

在 `anr_***` 文件可能会看到如下两种格式的线程信息：

##### Native 格式

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/performance/cpu/cpu_part_3.png)

> 注：线程状态列表在 `anr_*` 文件中可能包含多条，它们分别是不同时间的线程状态，可以通过对比分析 `ANR` 原因。

这里 `timeout reached` 表示 `tombstoned` 响应超时，可能是因为：

* **CPU 繁忙**：	tombstoned 抢不到 CPU
* **binder 线程池耗尽**：请求排队
* **进程被 swap**：dump 本身很慢
* **内核压力大**：调度延迟

接下来是 **20285** 进程中所包含的所有线程状态，由左至右分别为：

* **线程ID**
* **线程状态**
* **wchan**
* **线程名**

**Linux内核的线程状态：**
| state | 名称 | 含义 |
| --- | --- | --- |
| R | Running / Runnable | 正在运行或可运行 |
| S | Sleeping | 阻塞等待（可中断） |
| D | Uninterruptible sleep | 不可中断等待（通常 IO） |
| T | Stopped | 被暂停 |
| Z | Zombie | 僵尸 |
| W | Waking | 线程正在从睡眠状态转换到可运行状态 |
| I | Idle | 空闲内核线程 |

**wchan**：
在 `Linux` 中当线程处于不可运行状态时（`Sleeping`）时，内核会记录它现在卡在内核的哪一行代码上，这个名字就是 `wchan（wait channel）`。体现在 `anr_*` 文件上的是 `wchan` 的符号化结果。

常见 `wchan`：
| wchan | 内核在干什么 | 常见来源 | 实战解读 |
| --- | --- | --- | --- | --- |
| **futex_wait_queue** | 等用户态锁 | `synchronized`、`ReentrantLock`、`Condition.await` | **主线程出现 = 高危**，优先找谁持锁 |
| **binder_thread_read** | 等 Binder 事务 | IPC、AIDL、系统服务 | 主线程 Binder 调用被阻塞 |
| **binder_wait_for_work** | Binder 线程空闲 | Binder 线程池 | 正常（除非 system_server 异常） |
| **do_epoll_wait** / **__epoll_pwait** | 等 fd 事件 | Looper / MessageQueue | 主线程长期出现 → 可能消息未投递 |
| **pipe_read** | 读管道阻塞 | profiler / trace / hprof| 通常是工具线程 |

`Native` 相关堆栈：
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/performance/cpu/cpu_part_4.png)

##### Dalvik/ART格式

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/performance/cpu/cpu_part_5.png)

```
"main" prio=5 tid=1 Native
  | group="main" sCount=1 ucsCount=0 flags=1 obj=0x73374588 self=0xb4000075a4442c00
  | sysTid=7188 nice=0 cgrp=foreground sched=0/0 handle=0x765b0fc500
  | state=S schedstat=( 93201182 324828240 420 ) utm=5 stm=3 core=6 HZ=100
  | stack=0x7ff91c3000-0x7ff91c5000 stackSize=8188KB
  | held mutexes=
```

**线程状态对比：**
| Java Thread 状态 | Linux Thread 状态 | 说明 |
|---|---|---|
| TERMINATED | ZOMBIE | 线程死亡，终止运行 |
| RUNNABLE | RUNNING/RUNNABLE | 线程可运行或正在运行 |
| TIMED_WAITING | TIMED_WAIT | 执行了带有超时参数的wait、sleep或join函数 |
| BLOCKED | MONITOR | 线程阻塞，等待获取对象锁 |
| WAITING | WAIT | 执行了无超时参数的wait函数 |
| NEW | INITIALIZING | 新建，正在初始化，为其分配资源 |
| NEW | STARTING | 新建，正在启动 |
| RUNNABLE | NATIVE | 正在执行JNI本地函数 |
| WAITING | VMWAIT | 正在等待VM资源 |
| RUNNABLE | SUSPENDED | 线程暂停，通常是由于GC或debug被暂停 |

## ANR 实例
### 等待GC
