---
id: 20261018-004
tags: [C++, C, POSIX, 标准库]
aliases: [C++ 标准库与 C 标准库和 POSIX 对比, 标准库与 POSIX 能力对比]
created: 2026-10-18
updated: 2026-10-18
source: ""
status: draft
---
# C++、C 标准库与 POSIX 能力对比

## 概述

C++ 标准库、C 标准库和 POSIX 都通过头文件向程序声明接口，但三者分别面向 `C++ 通用编程`、`C 通用编程` 和 `Unix-like 系统编程`，能力范围与可移植边界不同。

### 定位对比

| 对比项 | C++ 标准库 | C 标准库 | POSIX |
| --- | --- | --- | --- |
| 标准制定者 | ISO C++ | ISO C | IEEE / The Open Group |
| 主要目标 | 提供 C++ 通用编程设施 | 提供 C 通用基础设施 | 统一 Unix-like 操作系统接口 |
| 主要使用语言 | C++ | C，也可被 C++ 调用 | 主要提供 C API，也可被 C++ 调用 |
| 接口入口 | `<vector>`、`<string>`、`<thread>` 等 | `<stdio.h>`、`<stdlib.h>`、`<string.h>` 等 | `<unistd.h>`、`<fcntl.h>`、`<pthread.h>` 等 |
| 名称组织 | 多数位于 `std` 命名空间 | 全局名称、宏和类型 | 全局名称、宏和类型 |
| 常见实现 | `libstdc++`、`libc++`、MSVC STL | glibc、musl、UCRT、newlib | glibc、musl、macOS 系统库等 |
| 可移植范围 | 支持相应 C++ 标准的实现 | 支持相应 C 标准的实现 | 支持相应 POSIX 版本的系统 |
| Windows 原生保证 | 是，由 C++ 实现提供 | 是，由 C 实现提供 | 否，需要兼容层或替代 API |

### 能力对比

表格填写各规范提供对应能力时使用的主要头文件；`—` 表示该规范没有提供对应的标准头文件接口。同名头文件可能同时包含 ISO C 与 POSIX 接口，具体归属仍需判断其中的函数或类型。

| 能力 | C++ 标准库头文件 | C 标准库头文件 | POSIX 头文件 |
| --- | --- | --- | --- |
| 字符串 | `<string>`、`<string_view>`、`<cstring>` | `<string.h>` | `<string.h>`、`<strings.h>` |
| 动态内存 | `<memory>`、`<new>`、`<cstdlib>` | `<stdlib.h>` | `<stdlib.h>`、`<sys/mman.h>` |
| 通用容器 | `<array>`、`<vector>`、`<list>`、`<map>`、`<unordered_map>` 等 | — | — |
| 通用算法 | `<algorithm>`、`<numeric>`、`<ranges>` | `<stdlib.h>` | `<stdlib.h>` |
| 格式化输入输出 | `<iostream>`、`<format>`、`<cstdio>` | `<stdio.h>` | `<stdio.h>` |
| 文件流 | `<fstream>` | `<stdio.h>` | `<stdio.h>` |
| 文件描述符 I/O | — | — | `<fcntl.h>`、`<unistd.h>` |
| 文件路径与目录 | `<filesystem>` | — | `<dirent.h>`、`<sys/stat.h>`、`<unistd.h>` |
| 文件权限与所有者 | `<filesystem>` | — | `<sys/stat.h>`、`<unistd.h>` |
| 时间与时钟 | `<chrono>`、`<ctime>` | `<time.h>` | `<time.h>`、`<sys/time.h>` |
| 线程 | `<thread>` | `<threads.h>` | `<pthread.h>` |
| 同步与原子操作 | `<mutex>`、`<shared_mutex>`、`<condition_variable>`、`<semaphore>`、`<atomic>` | `<threads.h>`、`<stdatomic.h>` | `<pthread.h>`、`<semaphore.h>`、`<stdatomic.h>` |
| 进程创建 | — | — | `<unistd.h>`、`<spawn.h>` |
| 程序执行与等待 | `<cstdlib>` | `<stdlib.h>` | `<unistd.h>`、`<sys/wait.h>` |
| 进程间通信 | — | — | `<unistd.h>`、`<sys/mman.h>`、`<sys/socket.h>`、`<mqueue.h>` |
| 信号处理 | `<csignal>` | `<signal.h>` | `<signal.h>` |
| 网络套接字 | — | — | `<sys/socket.h>`、`<netinet/in.h>`、`<arpa/inet.h>` |
| 动态库加载 | — | — | `<dlfcn.h>` |

同一行出现相同头文件不表示系统中存在多份不同版本。例如，C 标准库和 POSIX 栏中的 `<string.h>` 通常指同一个实际头文件：ISO C 规定 `strlen()`、`strcmp()` 等跨平台基础接口，POSIX 采用这些接口并可能追加 `strerror_r()` 等要求；系统实现将两套声明合并在一个头文件中，并可通过语言标准模式和功能测试宏控制扩展接口是否可见。因此，表格表达的是各规范对头文件及其接口的要求，不是磁盘上存在相互独立的“C 版”和“POSIX 版”头文件。

### 能力层次

```text
C++ 标准库
├── C++ 类型与泛型编程能力
├── 容器、算法、RAII、并发等高级抽象
└── 纳入并适配一部分 C 标准库设施

C 标准库
└── 跨平台的 C 基础能力

POSIX
├── 采用 ISO C 环境中的基础接口
└── 增加 Unix-like 文件、进程、线程、IPC 等系统能力
```

该图表示使用和能力层次，不表示三份标准存在简单的法律或规范包含关系。

## 我的理解

头文件像能力的“菜单”，标准规定菜单上应有什么以及如何使用，库和操作系统负责真正做菜；C++ 标准库偏向高级通用能力，C 标准库提供基础通用能力，POSIX 则补充 Unix-like 系统能力。
