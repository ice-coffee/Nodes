[toc]

## CPU
[Android 高版本采集系统CPU使用率的方式](https://blog.csdn.net/bugyinyin/article/details/127129270)



### top
`top` 命令可以用来查看 Linux 系统进程状态。

#### 命令说明
查看命令帮助信息：

```bash
adb shell top --help
```

输出如下：

```
usage: top [-Hbq] [-k FIELD,] [-o FIELD,] [-s SORT] [-n NUMBER] [-m LINES] [-d SECONDS] [-p PID,] [-u USER,]：top 命令语法说明
```

* `-H`：显示线程信息；
* `-k`：指定按照哪个字段排序，值为字段名；
* `-o`：指定要显示的字段，用逗号分隔；
* `-O`：替换显示的默认字段；
* `-s`：指定按照哪个字段排序，值为字段编号，字段编号从1到X，X是显示的字段数目，默认是第9个字段；
* `-b`：批处理模式，不使用终端交互界面；
* `-d`：每次刷新之间的延迟时间，单位是秒，默认是3秒；
* `-m`：最大显示的任务数；
* `-n`：执行多少次后自动退出；
* `-p`：只显示指定进程ID（PID）的信息；
* `-u`：只显示指定用户的信息；
* `-q`：静默模式，没有标题行。

#### 输出解析
执行 `top` 命令，输出如下：

```
Tasks: 857 total,   2 running, 855 sleeping,   0 stopped,   0 zombie
  Mem:  5746772K total,  5606544K used,   140228K free,     2396K buffers
 Swap:  4194300K total,  1556724K used,  2637576K free,  1470412K cached
800%cpu  33%user   0%nice  29%sys 728%idle   0%iow   7%irq   1%sirq   0%host
  PID USER         PR  NI VIRT  RES  SHR S[%CPU] %MEM     TIME+ ARGS            
22298 u0_a830      10 -10  27G 156M 156M S 21.6   2.7 220:35.18 com.baidu.mapau+
 1878 system       18  -2  12G 332M 332M S  7.0   5.9 2927:53.0 system_server
10760 shell        20   0 2.1G  10M 3.5M S  6.0   0.1   0:16.20 top -H
 1154 system       -2 -10 2.8G  32M  32M S  5.3   0.5 1530:02.6 surfaceflinger
10805 shell        20   0 2.1G 5.3M 3.4M R  2.0   0.0   0:03.32 top
 9104 root         20   0    0    0    0 R  2.0   0.0   0:21.10 [kworker/u16:7++
```

**`第1行`**：进程（或线程）状态

* `total`：当前系统中进程总数
* `running`：正在运行的进程数
* `sleeping`：休眠的进程数
* `stopped`：暂定的进程数
* `zombie`：僵尸进程数

**`第2行`**：内存状态

**`第3行`**：交换分区状态

**`第4行`**：`CPU` 状态

* `cpu`：CPU使用率为800%。这可能是因为有8个CPU内核，每个内核的使用率都是100%；
* `user`：用户空间CPU使用率；偏高说明应用代码本身在跑逻辑（渲染、计算、业务逻辑），是性能优化时最常见的排查对象；
* `nice`：改变过优先级的进程CPU使用率；日常场景很少见，一般不用特别关注；
* `sys`：系统空间CPU使用率；偏高说明内核在为进程做事（内存分配、系统调用、驱动处理），可能意味着频繁 I/O、频繁创建线程/锁竞争、频繁 GC 触发的内核态操作，值得进一步排查是哪类调用导致的；
* `idle`：空闲CPU使用率；高说明系统整体负载不重，性能问题可能不在 CPU 层面（比如卡顿是主线程被阻塞而非 CPU 跑满）；低（尤其接近0）说明 CPU 接近满载，是性能瓶颈的直接信号；
* `iow`：I/O等待CPU使用率；偏高说明存在 I/O 瓶颈（频繁读写文件、数据库操作、网络请求阻塞），优化方向是异步化或减少 I/O 次数，而不是优化计算逻辑；
* `irq`：硬中断CPU使用率；正常应该很低，异常偏高可能是硬件驱动问题或异常的中断风暴；
* `sirq`：软中断CPU使用率；偏高常见于网络流量突增或网络子系统异常；
* `host`：Hypervisor或者Host CPU使用率；非虚拟化环境通常为0，纯 Android 手机上一般不需要关注。

实际分析时的经验法则：

* 看应用卡顿/发热问题，重点看 `user` + `sys` 之和：这部分高说明 CPU 确实在忙于计算或系统调用，是"真忙"；
* 如果 `idle` 很高但应用依然卡顿，说明瓶颈不在 CPU，要去查锁等待、主线程阻塞、GC 停顿等；
* 如果 `iow` 明显偏高，要去查是否有同步 I/O 操作放在了关键路径上；
* `sys` 偏高但 `user` 不高，往往提示锁竞争、频繁系统调用（如频繁 mmap/binder 调用）或者内存抖动触发的内核态开销，Android 上常见于 Binder IPC 频繁或者内存分配密集的场景。

**`第5行`**：标题行

* `PID`：进程ID；
* `TID`：线程ID；
* `USER`：[进程/线程]所属用户；
* `PR`：[进程/线程]的优先级；
* `NI`：[进程/线程]的nice值；
* `VIRT`：[进程/线程]使用的虚拟内存大小；
* `RES`：[进程/线程]使用的物理内存大小；
* `SHR`：[进程/线程]使用的共享内存大小；
* `S`：[进程/线程]状态：
* `[%CPU]`：[进程/线程]的CPU使用率；
* `%MEM`：[进程/线程]的内存使用率；
* `TIME+`：[进程/线程]已经运行的时间，单位 **`1/100`** 秒；
* `THREAD`：线程名；
* `ARGS`：进程的命令行参数。

**`[%CPU]补充说明：`**

表示 "这个进程/线程相对于一个 CPU 核心的满载能力，实际占用了多少"，而不是"占系统总算力的百分之几"。
* 如果要换算成占系统总算力的比例，需要用 %CPU ÷ 核心数（比如 8 核设备上某进程显示 400%，实际占系统总算力的 50%）。

**`第6~行`**：每一条代表一条进程。

进程状态：

* `R`（Running）： 进程正在运行，或者在运行队列中等待执行。
* `S`（Sleeping）： 进程处于休眠状态，即进程暂时不活跃，正在等待某个事件的发生（例如输入）。
* `D`（Uninterruptible Sleep）： 进程不可中断的休眠状态，通常在等待硬件设备的输入或输出操作完成时发生。
* `Z`（Zombie）： 僵尸进程，即已经终止但其父进程还未对其进行善后处理的进程。
* `T`（Stopped）： 进程被停止，通常是因为收到了停止信号（如CTRL+Z）。
* `I`（Idle）： 进程处于空闲状态，即没有活动的进程。


线程状态：

* 运行（Running）： 线程正在运行。
* 就绪（Ready）： 线程已经准备好运行，但尚未被调度执行。
* 阻塞（Blocked）： 线程因为某种原因被阻塞，例如等待I/O操作完成。
* 休眠（Sleeping）： 线程暂时不活跃，正在等待某个事件的发生，可以被唤醒。
* 终止（Terminated）： 线程执行完成并已被销毁。

#### CPU 使用率计算
`CPU` 使用率：指单位时间内CPU非空闲态时间占比。

虽然 `Top` 命令可以直接返回当前时段[进程/线程]的 `CPU`，但是实际使用下来看某次返回数据中可能有异常数据返回；例如某线程 `CPU` 使用率高达 `1000%`（原因不明）。这种情况下可以通过 `TIME+` 字段计算 `CPU` 使用率。

`TIME+` 字段格式：
> **`分:秒.百分秒`**

计算方式：
```java
private static DecimalFormat cpuUsageFormat = new DecimalFormat("0.0");

/**
 * 计算上次采样时各个线程cpu使用率
 * @param lastCpuTime 上一次采样cpu时间
 * @param currentCpuTime 当前采样cpu时间
 * @param cpuTimeInterval 采样间隔
 * @return 返回上次采样时各个线程cpu使用率，时间片没变化返回0，如果计算失败则返回-1
 */
private static float calculateLastCpuUsage(String lastCpuTime, String currentCpuTime, int cpuTimeInterval) {
    int lastCpuTimeValue = parseCpuTime(lastCpuTime);
    int currentCpuTimeValue = parseCpuTime(currentCpuTime);
    if (lastCpuTimeValue == currentCpuTimeValue) {
        return 0f;
    }
    float lastCpuUsage = (float) (currentCpuTimeValue - lastCpuTimeValue) / cpuTimeInterval;

    if (lastCpuUsage < 0 || lastCpuUsage >= 100) {
        return -1;
    }

    if (lastCpuUsage * 10 != (int) (lastCpuUsage * 10)) {
        lastCpuUsage = Float.parseFloat(cpuUsageFormat.format(lastCpuUsage));
    }
    return lastCpuUsage;
}

/**
 * 解析cpu时间
 * @param cpuTime cpu时间字符串 格式：01:23.45
 * @return 返回cpu时间，单位：百分秒
 */
private static int parseCpuTime(String cpuTime) {
    Pattern p = Pattern.compile("^[0-9]+:[0-9]+.[0-9][0-9]$");
    Matcher m = p.matcher(cpuTime);
    if (m.matches()) {
        // 分
        int minutes = Integer.parseInt(cpuTime.substring(0, cpuTime.indexOf(":")));
        // 秒
        int seconds = Integer.parseInt(cpuTime.substring(cpuTime.indexOf(":") + 1, cpuTime.lastIndexOf(".")));
        // 百分秒
        int hundseconds = Integer.parseInt(cpuTime.substring(cpuTime.lastIndexOf(".") + 1));

        return minutes * 60 * 100 + seconds * 100 + hundseconds;
    }

    return -1;
}
```
