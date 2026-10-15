### 文档
[POSIX 官方接口文档](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/contents.html)

### POSIX 是什么

**POSIX 是一个标准**，定义了操作系统应提供的一组编程接口（API）、命令行工具和行为规范。它是一组为 `Unix-like` 系统定义的 `API` 标准，例如 `Linux` 和 `macOS`。它规定了：

* 函数应该叫什么（如 `open()`、`fork()`）
* 应该提供什么参数
* 应该返回什么结果
* 出错时的行为
* 对应的结构体定义等

但是，它**不规定这些函数具体怎么实现**。实现由操作系统来完成。

### POSIX 头文件：

操作系统为了让程序员能使用这些接口，通常会通过一系列 **头文件（`.h` 文件）** 来声明这些接口。这些头文件构成了 POSIX 的“入口”。

例如：

| 头文件             | 提供的 POSIX 功能                               |
| --------------- | ------------------------------------------ |
| `<unistd.h>`    | 文件/进程/用户接口（如 `fork()`、`read()`、`getpid()`） |
| `<fcntl.h>`     | 文件控制接口（如 `open()`、`fcntl()`）               |
| `<dirent.h>`    | 目录读取接口（如 `opendir()`、`readdir()`）          |
| `<pthread.h>`   | 线程编程（POSIX Threads）                        |
| `<signal.h>`    | 信号处理接口（如 `signal()`、`sigaction()`）         |
| `<sys/stat.h>`  | 获取文件状态（如 `stat()`、`chmod()`）               |
| `<sys/types.h>` | 基本类型声明（如 `pid_t`, `off_t`）                 |
| `<time.h>`      | 时间与时钟接口（如 `clock_gettime()`）               |

这些文件通常位于系统的 `/usr/include` 目录下，包含在编译器默认的头文件搜索路径中。

### POSIX 动态库

在 `Linux` 系统中 `POSIX` 实现由 `libc.so` 提供；`libc.so` 还提供了 `C` 标准库能力。

`libc.so` 是 `libstdc++.so` 的依赖库；`libstdc++.so` 提供了 `C++` 标准库能力。
