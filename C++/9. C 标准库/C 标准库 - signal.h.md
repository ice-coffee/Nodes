## 简介

`signal.h` 是 **C/C++ 标准库**提供的用于 **信号处理（signal handling）** 的头文件。信号是操作系统用来通知进程某些事件发生的一种机制，例如：

* 用户按下 `Ctrl+C`（产生 `SIGINT`）
* 进程执行非法操作（产生 `SIGFPE`）
* 子进程退出（产生 `SIGCHLD`）
* 系统定时器触发（产生 `SIGALRM`）

`signal.h` 提供函数和宏来 **捕获、忽略或处理这些信号**。

## 主要宏

常用信号宏：

| 宏         | 说明              |
| --------- | --------------- |
| `SIGINT`  | Ctrl+C 中断信号     |
| `SIGKILL` | 强制终止进程（不可捕获/忽略） |
| `SIGTERM` | 请求终止进程（可捕获）     |
| `SIGSEGV` | 段错误（非法访问内存）     |
| `SIGABRT` | 调用 `abort()` 产生 |
| `SIGFPE`  | 浮点异常，如除以 0      |
| `SIGALRM` | 定时器信号           |
| `SIGCHLD` | 子进程退出信号         |

> 注意：不同系统可能支持的信号略有差异，POSIX 系统信号比较齐全。

## 主要函数

### 1. `signal`

```c
#include <signal.h>

void (*signal(int sig, void (*handler)(int)))(int);
```

* **作用**：设置对某个信号的处理函数
* **参数**：

  * `sig`：信号类型（如 `SIGINT`）
  * `handler`：处理函数指针，可以是：

    * `SIG_IGN`：忽略信号
    * `SIG_DFL`：默认处理
    * 自定义函数：如 `void handler(int signo)`
* **返回值**：上一次对该信号的处理函数指针

**示例**：

```c
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void sigint_handler(int sig) {
    printf("Caught SIGINT: %d\n", sig);
}

int main() {
    signal(SIGINT, sigint_handler);  // 捕获 Ctrl+C
    while(1) {
        printf("Running...\n");
        sleep(1);
    }
    return 0;
}
```

运行后，按 `Ctrl+C` 会触发 `sigint_handler`，而不是直接终止程序。

### 2. `raise`

```c
#include <signal.h>
int raise(int sig);
```

* **作用**：向当前进程发送信号
* **返回值**：0 表示成功，非 0 表示失败

**示例**：

```c
raise(SIGINT);  // 向自己发送 SIGINT 信号
```

---

### 3. `kill`（POSIX）

```c
#include <signal.h>
#include <unistd.h>
int kill(pid_t pid, int sig);
```

* **作用**：向指定进程发送信号
* `pid` = 0：发送给当前进程组
* `pid` > 0：发送给指定 pid
* `pid` < -1：发送给指定进程组

## 使用场景

1. **捕获用户中断**：防止程序被 Ctrl+C 直接终止
2. **处理异常信号**：如除 0、段错误，用来做日志或清理资源
3. **进程间通信**：父子进程通过 `SIGCHLD` 通知子进程退出
4. **定时任务**：通过 `SIGALRM` 实现定时器功能

## 注意事项

* 信号处理函数应 **尽量简单**，不要在处理函数里调用可能阻塞的函数（如 `malloc`、`printf` 等，虽然 `printf` 在大部分系统可用，但严格 POSIX 不保证安全）
* `SIGKILL`、`SIGSTOP` **无法捕获或忽略**
* 信号处理存在 **竞争问题**，多线程环境下需谨慎
