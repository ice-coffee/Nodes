`<unistd.h>` 是 POSIX 系统（如 Linux、macOS、Android 等）中最核心的头文件之一，提供了大量底层系统调用的函数声明，覆盖了 **文件IO、进程管理、内存、用户权限、环境变量等基础功能**。

它本质上是 C 程序与操作系统内核通信的桥梁，下面是 `<unistd.h>` 提供的主要功能模块和代表性函数。

## 文件操作（底层 IO）

```c
/**
 * 从 fd 的当前文件偏移量处读取最多 count 字节到 buf，
 * 并把偏移量前移实际读取的字节数
 *
 * @param fd    已打开的文件描述符
 * @param buf   接收数据的缓冲区，至少要有 count 字节可写空间
 * @param count 本次期望读取的最大字节数
 * @return 实际读取的字节数；0 表示已到文件末尾（EOF）；-1 出错并设置 errno
 */
ssize_t read(int fd, void *buf, size_t count);
```

返回值小于 `count` 是**正常现象**（读到文件尾、管道数据不足、被信号打断），不是错误。

```c
/**
 * 从 offset 指定的绝对位置读取，等价于「lseek + read」但保证原子性，
 * 且不改变当前文件偏移量
 *
 * @param fd     已打开的文件描述符
 * @param buf    接收数据的缓冲区，至少要有 count 字节可写空间
 * @param count  本次期望读取的最大字节数
 * @param offset 从文件起始处算起的字节偏移，与当前偏移量无关
 * @return 含义同 read
 */
ssize_t pread(int fd, void *buf, size_t count, off_t offset);
```

因为不依赖也不修改共享的文件偏移量，多线程共用同一个 `fd` 并发读时应当用 `pread`。对管道、socket 等不可 seek 的 `fd` 调用会失败，`errno` 为 `ESPIPE`。

```c
/**
 * 把 buf 中的 count 字节写到 fd 的当前文件偏移量处，
 * 并把偏移量前移实际写入的字节数
 *
 * @param fd    已打开的文件描述符
 * @param buf   待写出数据的起始地址，const 表示函数不会修改它
 * @param count 期望写入的字节数
 * @return 实际写入的字节数；-1 出错并设置 errno
 */
ssize_t write(int fd, const void *buf, size_t count);
```

同样存在**短写**：返回值可能小于 `count`（磁盘满、管道缓冲区满、被信号打断）。

```c
/**
 * 写到 offset 指定的绝对位置，不改变当前文件偏移量
 *
 * @param fd     已打开的文件描述符
 * @param buf    待写出数据的起始地址
 * @param count  期望写入的字节数
 * @param offset 从文件起始处算起的字节偏移，与当前偏移量无关
 * @return 含义同 write
 */
ssize_t pwrite(int fd, const void *buf, size_t count, off_t offset);
```

需要注意 Linux 的一个已知偏差：文件以 `O_APPEND` 打开时，POSIX 规定 `pwrite` 应忽略该标志按 `offset` 写入，但 Linux 实际会无视 `offset` 直接追加到文件末尾。

```c
/**
 * 重新定位 fd 的当前文件偏移量，只改偏移量、不产生任何 IO
 *
 * @param fd     已打开的文件描述符
 * @param offset 位移量，可以为负（配合 SEEK_CUR / SEEK_END 往前退）
 * @param whence 位移的基准位置
 *               SEEK_SET  文件起始处，最终偏移 = offset
 *               SEEK_CUR  当前偏移处，最终偏移 = 当前值 + offset
 *               SEEK_END  文件末尾，  最终偏移 = 文件大小 + offset
 * @return 定位后的新偏移量（相对文件头）；-1 出错并设置 errno
 */
off_t lseek(int fd, off_t offset, int whence);
```

`lseek(fd, 0, SEEK_CUR)` 是获取当前偏移量的惯用写法；`lseek(fd, 0, SEEK_END)` 可用来取文件大小。允许把偏移量定位到文件末尾之后，此时写入会在中间形成**空洞**（读出为 `\0`，且不占实际磁盘块）。

```c
/**
 * 把 fd 对应文件的数据和元数据从内核页缓存刷到存储设备
 *
 * @param fd 已打开的文件描述符
 * @return 0 成功；-1 出错并设置 errno
 */
int fsync(int fd);
```

`write` 返回成功只表示数据进了内核页缓存，此时掉电或内核崩溃仍会丢数据。要确认落盘必须显式调用 `fsync` 并检查它的返回值，不能指望 `close` 帮忙报错。

```c
/**
 * 关闭 fd，释放它占用的描述符表项
 *
 * @param fd 待关闭的文件描述符
 * @return 0 成功；-1 出错并设置 errno
 */
int close(int fd);
```

文件描述符就是描述符表的下标，一个小的非负整数。`close` 释放表项后它回到可分配状态，而 `open` / `socket` / `dup` 按 POSIX 规定总是返回**当前最小的可用整数**，所以极可能立刻被复用：

```c
int fd = open("a.txt", O_RDONLY);   // 假设 fd == 3
close(fd);
int fd2 = open("b.txt", O_RDONLY);  // fd2 很可能也是 3
write(fd, buf, n);                  // 危险：实际写到了 b.txt
```

问题不在数字失效，而在**数字仍有效却指向了别的文件**，不报错却静默写坏数据。所以 `close` 后应把变量置 `-1`。

`close` 失败**不要重试**（Linux 上描述符已释放，重试会误关别的文件），但返回值仍要检查——写入的延迟错误可能到这里才暴露。

**示例：文件复制**

```c++
#include <unistd.h>
#include <fcntl.h>      // open
#include <errno.h>
#include <stdio.h>      // perror

int main() {
    int ret = 1;        // 默认失败，只有走完成功路径才置 0
    int src_fd = -1;
    int dst_fd = -1;
    char buf[4096];

    src_fd = open("src.txt", O_RDONLY);
    if (src_fd < 0) {
        perror("open src.txt");
        goto cleanup;
    }
    dst_fd = open("dst.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (dst_fd < 0) {
        perror("open dst.txt");
        goto cleanup;
    }

    for (;;) {
        ssize_t bytes_read = read(src_fd, buf, sizeof(buf));
        if (bytes_read == 0) {          // 0 表示读到文件末尾，正常结束
            break;
        }
        if (bytes_read < 0) {
            if (errno == EINTR) {       // 被信号打断，重试而不是当成失败
                continue;
            }
            perror("read");
            goto cleanup;
        }
        // 短写：一次 write 可能只写入一部分，必须循环写完
        ssize_t total_written = 0;
        while (total_written < bytes_read) {
            ssize_t written = write(dst_fd, buf + total_written,
                                    bytes_read - total_written);
            if (written < 0) {
                if (errno == EINTR) {
                    continue;
                }
                perror("write");
                goto cleanup;
            }
            total_written += written;
        }
    }

    if (fsync(dst_fd) < 0) {            // 确认数据真正落盘
        perror("fsync");
        goto cleanup;
    }
    ret = 0;

cleanup:
    if (src_fd >= 0) {
        close(src_fd);
    }
    // 目标文件的 close 失败可能是延迟暴露的写错误，要计入返回值
    if (dst_fd >= 0 && close(dst_fd) < 0) {
        perror("close dst.txt");
        ret = 1;
    }
    return ret;
}
```

### 错误处理与 errno

上面这些系统调用统一约定「返回 `-1` 表示失败」，失败的具体原因放在 `errno` 中（声明于 `<errno.h>`，POSIX 要求它是线程局部的，多线程下各自独立）。

```c
#include <errno.h>
#include <stdio.h>
#include <string.h>

if (close(fd) < 0) {
    // 方式一：perror，自动拼接 ": 错误描述\n" 输出到 stderr
    perror("close");                                  // close: Bad file descriptor

    // 方式二：strerror，拿到字符串自己排版
    fprintf(stderr, "close failed: %s\n", strerror(errno));

    // 方式三：按 errno 值分支处理
    if (errno == EINTR) {
        // 被信号打断
    }
}
fd = -1;
```

几个容易踩的点：

* **`errno` 只在调用失败后才有意义**。成功时它不会被清零，读到的是之前某次失败的残留值。必须先判返回值 `< 0`，再读 `errno`。
* **`errno` 会被后续调用覆盖**。如果失败后要先做清理（比如再 `close` 另一个 fd）才打印日志，得先把 `errno` 存到局部变量。
* **`strerror` 不是线程安全的**，多线程里改用 `strerror_r`。

`close` 常见的 `errno`：

* `EBADF`：fd 不是有效的描述符（重复 close 或用了野值）
* `EINTR`：被信号打断
* `EIO` / `ENOSPC` / `EDQUOT`：底层写回失败，通常是网络文件系统（NFS）上延迟暴露的写错误

最后这类才是「`close` 也要检查返回值」的真正理由：数据在 `write` 返回时只进了内核页缓存，真正的落盘错误可能到 `close` 才浮现。但如果在意数据完整性，正确做法是显式调用 `fsync(fd)` 并检查它的返回值，再 `close`，而不是指望 `close` 帮忙报错。

### 缓冲机制

* **`unistd.h`**

  * 无用户态缓冲，调用 `read` / `write` 就会触发系统调用。
  * 每次调用可能导致内核态与用户态切换，性能较低但更可控。

* **`stdio.h`**

  * 内置用户态缓冲机制：

    * **全缓冲**（文件，直到缓冲区满再写出）。
    * **行缓冲**（终端，遇到换行符才写出）。
    * **无缓冲**（`stderr` 默认）。
  * 提高了性能，但可能数据还没真正写入磁盘，需要 `fflush()` 或 `fclose()` 才能保证落盘。

## 进程管理

### fork

```c
/**
 * 创建子进程，复制当前进程的地址空间、文件描述符表和信号设置
 *
 * @return 在父进程中返回子进程的 pid；在子进程中返回 0；失败返回 -1 并设置 errno
 */
pid_t fork(void);
```

一次调用、**两次返回**是它最反直觉的地方:调用后有两个进程都从 `fork` 的返回处继续执行,靠返回值区分身份。

* 父子进程的执行顺序**不确定**,由调度器决定,不能假设谁先跑。
* 子进程**继承打开的文件描述符**,且与父进程共享同一个文件偏移量。两者同时写同一个 fd 会交错。
* 子进程会继承父进程 `stdio` 的**用户态缓冲区内容**。`fork` 前若有未刷新的 `printf`,父子各自 `fflush` 一次,同一段输出会打印两遍。规避办法是 `fork` 前先 `fflush(NULL)`。
* 父进程必须用 `wait` / `waitpid`(在 `<sys/wait.h>`)回收子进程,否则子进程退出后变成**僵尸进程**,占据进程表项。

### exec 系列

```c
/**
 * 用新程序替换当前进程映像，成功后不再返回
 *
 * @param file 可执行文件名；不含 '/' 时按 PATH 环境变量搜索
 * @param argv 参数数组，argv[0] 惯例为程序名，**必须以 NULL 结尾**
 * @return 成功不返回；失败返回 -1 并设置 errno
 */
int execvp(const char *file, char *const argv[]);
```

「成功则不返回」是 `exec` 系列的共同特征:进程的代码段、数据段、堆栈全部被新程序替换,原来 `exec` 之后的代码不会执行到。所以调用后紧跟的一定是错误处理:

```c
execvp("ls", argv);
perror("execvp");   // 执行到这里说明 exec 失败了
_exit(1);
```

`argv` 数组末尾漏掉 `NULL` 是常见 bug,会导致越界读取。

**pid 不变、fd 保持打开**是 `exec` 的重要性质:新程序继承原有的文件描述符(除非设置了 `FD_CLOEXEC`),shell 的重定向就是靠「`fork` → 子进程里 `dup2` 改 fd → `exec`」实现的。

`exec` 家族有六个变体,命名规则是:`l` 表示参数逐个列出(list),`v` 表示参数用数组传(vector),`p` 表示按 `PATH` 搜索,`e` 表示显式传环境变量。`execvp` 就是「数组 + 搜 PATH」。

### 进程信息与休眠

```c
/**
 * 获取当前进程的进程 ID
 *
 * @return 当前进程 pid，恒定成功，无错误返回值
 */
pid_t getpid(void);

/**
 * 获取父进程的进程 ID
 *
 * @return 父进程 pid，恒定成功，无错误返回值
 */
pid_t getppid(void);
```

两者都不会失败,所以无需检查返回值。常见用途是拼日志前缀、生成进程私有的临时文件名。

需要注意 `getppid` 的返回值**可能已经过期**:父进程若先退出,子进程会被 init(pid 1)或用户态的 subreaper 收养,此时 `getppid` 返回的是新父进程。用它判断「父进程还活着吗」并不可靠。

```c
/**
 * 挂起当前进程，直到指定秒数耗尽或收到未被忽略的信号
 *
 * @param seconds 期望睡眠的秒数
 * @return 正常睡满返回 0；被信号提前唤醒时返回**剩余未睡的秒数**
 */
unsigned int sleep(unsigned int seconds);
```

返回值的语义容易忽略:它不是错误码,而是**剩余秒数**。信号可以提前打断 `sleep`,想睡满就得循环:

```c
unsigned int left = 5;
while ((left = sleep(left)) > 0) {
    // 被信号打断，继续睡剩下的
}
```

秒级精度往往不够,更细的粒度用 `usleep`(微秒,同在 `<unistd.h>`,但已被 POSIX 标记为废弃)或 `nanosleep`(纳秒,在 `<time.h>`,推荐)。`nanosleep` 还能通过第二个参数直接拿到剩余时间,比 `sleep` 更好写。

**示例：创建子进程**

```c++
#include <unistd.h>

int main() {
    pid_t pid = fork();
    
    if (pid == -1) {
        std::cout << "fork sub process failed" << std::endl;
        return 0;
    }
    
    if (pid == 0) {
        std::cout << "enter sub process" << std::endl;
        //...
    } else {
        std::cout << "enter main process" << std::endl;
        //...
    }
    return 0;
}
```

## 用户信息

| 函数名                     | 功能           |
| ----------------------- | ------------ |
| `uid_t getuid()`        | 获取用户 ID      |
| `gid_t getgid()`        | 获取组 ID       |
| `int setuid(uid_t uid)` | 设置用户 ID（需权限） |

## 系统环境信息

### 工作目录

```c
/**
 * 获取当前工作目录的绝对路径
 *
 * @param buf  接收路径的缓冲区；传 NULL 时部分实现会 malloc（GNU 扩展，需自行 free）
 * @param size buf 的大小，含结尾的 '\0'
 * @return 成功返回 buf；缓冲区不足时返回 NULL 并置 errno 为 ERANGE
 */
char *getcwd(char *buf, size_t size);
```

缓冲区大小要按 `PATH_MAX`（在 `<limits.h>`，通常 1024 或 4096）准备。写死一个小数组是常见 bug——路径可以很长，`ERANGE` 就是在告诉你缓冲区不够。

```c
/**
 * 切换当前进程的工作目录
 *
 * @param path 目标目录路径
 * @return 0 成功；-1 失败并设置 errno
 */
int chdir(const char *path);

/**
 * 按已打开的目录文件描述符切换当前进程的工作目录
 *
 * @param fd 已打开目录的文件描述符（如 open(".", O_RDONLY) 得到）
 * @return 0 成功；-1 失败并设置 errno
 */
int fchdir(int fd);
```

**注意：**

* 它改的是**当前进程**的属性,不影响父进程。所以在程序里 `chdir` 之后回到 shell,shell 的目录没变。
* 工作目录是所有相对路径的解析基准,也是**多线程下的隐患**：它是进程级共享状态,一个线程 `chdir` 会影响所有线程正在进行的相对路径操作。
* `chdir` 靠路径字符串,每次调用要重新解析;`fchdir` 靠已打开的目录 fd,直接定位 inode,更快也更可靠——路径字符串可能因目录被 rename 而失效,fd 认的是目录实体本身。

**示例：用 fchdir 临时切换目录后再切回**

```c++
#include <unistd.h>
#include <fcntl.h>

int main() {
    int saved_fd = open(".", O_RDONLY);
    if (saved_fd == -1) {
        std::cout << "open current dir failed" << std::endl;
        return 0;
    }

    chdir("/tmp");
    // ... 在 /tmp 下做一些操作 ...

    fchdir(saved_fd); // 切回原来的目录，即使 "." 当时的路径已被改名也不受影响
    close(saved_fd);
    return 0;
}
```

### 文件访问权限

```c
/**
 * 按调用进程的**真实** uid/gid 检查对文件的访问权限
 *
 * @param path 待检查的文件路径
 * @param mode F_OK 是否存在 / R_OK 可读 / W_OK 可写 / X_OK 可执行，可按位或组合
 * @return 全部权限都满足返回 0；否则返回 -1 并设置 errno
 */
int access(const char *path, int mode);
```

**`注意：`** `access` 存在经典的 TOCTOU（检查与使用之间的时间差）竞态,不要用它做安全判断:

```c
if (access(path, W_OK) == 0) {   // 检查通过
    // ← 攻击者在这个窗口把 path 换成指向 /etc/passwd 的符号链接
    fd = open(path, O_WRONLY);   // 实际写到了别的文件
}
```

正确做法是**直接尝试操作,让内核在一次原子调用里完成权限检查**,失败后看 `errno`:

```c
int fd = open(path, O_WRONLY);
if (fd < 0) {
    if (errno == EACCES) { /* 没权限 */ }
    return -1;
}
```

另一个坑是它用**真实 uid** 而非有效 uid 判断。setuid 程序里两者不同,`access` 返回可访问不代表当前实际有权限。想按有效 uid 检查要用 `faccessat` 配合 `AT_EACCESS` 标志。

`access` 仅在「探测文件是否存在且不涉及安全决策」时还算合适,比如查找配置文件在哪个候选路径下。

### 系统配置

```c
/**
 * 查询系统配置值与资源限制
 *
 * @param name 配置项名称，如 _SC_OPEN_MAX、_SC_PAGESIZE、_SC_NPROCESSORS_ONLN
 * @return 配置值；无限制或不支持时返回 -1（需先把 errno 清零来区分这两种情况）
 */
long sysconf(int name);
```

返回 `-1` 有两种含义:该项无限制,或该项不被支持。要区分就得在调用前 `errno = 0`,调用后若 `errno` 仍为 0 说明是「无限制」。

常用配置项:

* `_SC_PAGESIZE`：内存页大小,做内存对齐时用
* `_SC_OPEN_MAX`：单进程最大打开文件数
* `_SC_NPROCESSORS_ONLN`：在线 CPU 核数,常用来定线程池大小
* `_SC_CLK_TCK`：时钟节拍数,解析 `times()` 返回值时需要

## 管道与通信

管道（`pipe`）是 `UNIX/Linux` 系统中实现 **进程间通信（IPC）** 的一种经典方式，它通过内核缓冲区让一个进程的输出成为另一个进程的输入。下面我将从原理、行为、限制、使用场景等方面全面讲解管道的特性。

```c
/**
 * 创建管道
 *
 * @param fd 输出参数，fd[0] 为读端，fd[1] 为写端
 * @return 0 成功；-1 失败并设置 errno
 */
int pipe(int fd[2]);

/**
 * 复制文件描述符，返回当前最小可用的空闲 fd
 *
 * @param oldfd 待复制的文件描述符
 * @return 成功返回新的文件描述符；-1 失败并设置 errno
 */
int dup(int oldfd);

/**
 * 复制文件描述符到指定编号，若 newfd 已打开会先被关闭
 *
 * @param oldfd 待复制的文件描述符
 * @param newfd 目标文件描述符编号（如 STDOUT_FILENO）
 * @return 成功返回 newfd；-1 失败并设置 errno
 */
int dup2(int oldfd, int newfd);
```

#### 管道的基本原理

管道是一个**单向**的数据通道，由内核维护一个**缓冲区**。

* 使用 `pipe(int fd[2])` 创建，返回两个文件描述符：

  * `fd[0]`: 读取端（read end）
  * `fd[1]`: 写入端（write end）
* 数据写入 `fd[1]`，从 `fd[0]` 读取。

```cpp
int pipefd[2];
pipe(pipefd);
// pipefd[0]：read，pipefd[1]：write
```

#### 关键特性

1. **单向性**

* 管道只能单向传输数据（写入 -> 读取），若需要双向通信，要使用两个管道。

2. **半双工通信**

* 通常在 **父子进程** 间使用；
* 通信方向由 `dup2` 重定向后决定，实际读写端通常只有一个有效。

3. **通过内核缓冲区传递数据**

* 缓冲区大小：通常是 4KB（可使用 `ulimit -a` 查看）；
* 写入进程写入管道的数据暂存在内核缓冲区中。

4. **阻塞行为**

* 写阻塞：若缓冲区满（没人读取，或读取太慢），`write()` 阻塞；除非以非阻塞模式打开。
* 读阻塞：如果缓冲区为空，`read()` 阻塞；如果所有写端都关闭，返回 0（表示 EOF）。
* 读到 EOF：管道的所有写端都关闭后，`read()` 返回 0。
* 写端写失败：管道读端已全部关闭时，`write()` 会收到 `SIGPIPE` 信号，并出错返回 `EPIPE`。

5. **共享文件描述符但不共享缓冲区**

* `fork()` 后，子进程继承父进程的文件描述符，但内核缓冲区是系统资源，不拷贝。

**`示例：`**

```cpp
int pipefd[2];
pipe(pipefd);

if (fork() == 0) {
    // 子进程 - 读取
    close(pipefd[1]); // 不写
    char buf[100];
    read(pipefd[0], buf, sizeof(buf)); // 如果没有数据，就阻塞
    close(pipefd[0]);
} else {
    // 父进程 - 写入
    close(pipefd[0]); // 不读
    write(pipefd[1], "hello", 5);
    close(pipefd[1]); // 写完必须关闭写端，子进程 read 才能收到 EOF
}
```

#### 示例 1

```cpp
#include <unistd.h>
#include <sys/select.h>
#include <vector>
#include <string>
#include <atomic>
#include <iostream>

std::atomic_bool _keep_running;
std::atomic_bool _is_ready;
pid_t pid;
int parent_to_child[2];
int child_to_parent[2];
    
bool start() {

    if (pipe(parent_to_child) == -1 || pipe(child_to_parent) == -1) {
        std::cout << "create pipe failed" << std::endl;
        return false;
    }

    pid = fork(); //fork sub process
    if (pid == -1) {
        std::cout << "fork sub process failed" << std::endl;
        return false;
    }

    if (pid == 0) {  // 子进程（服务器）
        std::cout << "enter sub process" << std::endl;
        close(parent_to_child[1]);
        close(child_to_parent[0]);

        std::cout << "start load library" << std::endl;

        // 发送就绪信号
        const char* ready_signal = "READY";
        write(child_to_parent[1], ready_signal, strlen(ready_signal));
        
        _keep_running.store(true);
        while (_keep_running) {
            // 处理客户端请求
            sleep(1);
        }
        
        std::cout << "close sub process" << std::endl;
        close(parent_to_child[0]);
        close(child_to_parent[1]);

        exit(0); //sub process exit
    }
    else { // 父进程
        close(parent_to_child[0]);
        close(child_to_parent[1]);

        std::cout << "enter main process" << std::endl;

        // 设置超时时间
        timeval tv{};
        tv.tv_sec = 10;
        tv.tv_usec = 0;

        fd_set readfds;
        FD_ZERO(&readfds);
        FD_SET(child_to_parent[0], &readfds);

        // 等待子进程就绪
        int ready = select(child_to_parent[0] + 1, &readfds, nullptr, nullptr, &tv);

        if (ready <= 0) {
            std::cout << (ready == 0 ? "wait sub process timeout" : "wait sub process error") << std::endl;
            close(parent_to_child[1]);
            close(child_to_parent[0]);
            return false;
        }

        // 读取就绪信号
        char ready_buf[5] = {0};
        ssize_t n = read(child_to_parent[0], ready_buf, sizeof(ready_buf));
        if (n <= 0 || strcmp(ready_buf, "READY") != 0) {
            close(parent_to_child[1]);
            close(child_to_parent[0]);
            return false;
        }

        // 检测到子进程就绪
        _is_ready = true;
    }

    return true;
}

void close() {
    close(parent_to_child[1]);
    close(child_to_parent[0]);
}
```

#### 示例2
先读请求头再读请求尾：

```c++
bool read_request_info(int fd)
{
    // 接收数据长度
    uint64_t len;
    ssize_t bytes_read = read(fd, &len, sizeof(len));
    if (bytes_read <= 0) {
        std::cout << "read empty pipe header" << std::endl;
        return false;
    }

    // 接收数据
    std::string buffer(len, '\0');
    bytes_read = read(fd, &buffer[0], len);
    if (bytes_read <= 0) {
        std::cout << "read empty pipe body" << std::endl;
        return false;
    }

    return true;
}
```