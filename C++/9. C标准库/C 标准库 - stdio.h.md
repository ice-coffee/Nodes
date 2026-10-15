`<stdio.h>` 是 ANSI/ISO C 标准库的一部分，提供 **高级 I/O**：它在系统调用之上封装了一层用户态缓冲，操作对象是 `FILE*` 文件流而不是文件描述符。

相比 `<unistd.h>` 的 `read` / `write`，它牺牲了一部分控制力，换来跨平台能力、格式化输入输出，以及更少的系统调用次数。

## FILE 流与三个标准流

`FILE` 是一个**不透明结构体**，内部维护着底层文件描述符、用户态缓冲区、当前读写位置、错误标志和 EOF 标志。各家实现的成员完全不同，不要直接访问，只能通过标准函数操作。

程序启动时自动打开三个流：

| 流        | 对应 fd | 默认缓冲方式                  |
| -------- | ----- | ----------------------- |
| `stdin`  | 0     | 行缓冲（终端）／全缓冲（重定向到文件时）    |
| `stdout` | 1     | 行缓冲（终端）／全缓冲（重定向到文件时）    |
| `stderr` | 2     | 无缓冲                     |

`stderr` 默认无缓冲，是为了让错误信息立刻可见——程序崩溃时缓冲区里的内容会丢失，而错误信息恰恰是崩溃时最需要看到的。这也解释了为什么 `printf` 和 `fprintf(stderr, ...)` 混用时输出顺序常常错乱：两者的缓冲策略不同。

## 打开与关闭

```c
/**
 * 打开文件并返回关联的流
 *
 * @param path 文件路径
 * @param mode 打开模式，见下表
 * @return 成功返回 FILE 指针；失败返回 NULL 并设置 errno
 */
FILE *fopen(const char *path, const char *mode);
```

`mode` 的取值：

| mode   | 文件不存在 | 文件已存在 | 初始位置 | 可读 | 可写 |
| ------ | ----- | ----- | ---- | -- | -- |
| `"r"`  | 失败    | 保留内容  | 开头   | ✅  | ❌  |
| `"w"`  | 创建    | **清空** | 开头   | ❌  | ✅  |
| `"a"`  | 创建    | 保留内容  | 末尾   | ❌  | ✅  |
| `"r+"` | 失败    | 保留内容  | 开头   | ✅  | ✅  |
| `"w+"` | 创建    | **清空** | 开头   | ✅  | ✅  |
| `"a+"` | 创建    | 保留内容  | 末尾   | ✅  | ✅  |

另外两个可叠加的字符：

* `"b"`：二进制模式，如 `"rb"`。POSIX 系统上是空操作，Windows 上决定是否做 `\n` ↔ `\r\n` 转换。为可移植性，处理非文本数据时应当加上。
* `"x"`：C11 引入，如 `"wx"`，文件已存在时直接失败，用于避免覆盖竞态。

`"a"` 模式的追加是**原子**的：每次写入前位置自动跳到当前末尾，多进程同时追加同一日志文件不会互相覆盖。这是它区别于「`fopen("r+")` 后 `fseek` 到末尾」的关键。

```c
/**
 * 刷新流的用户态缓冲并关闭它，释放 FILE 结构与底层 fd
 *
 * @param stream 待关闭的流
 * @return 0 成功；EOF 失败并设置 errno
 */
int fclose(FILE *stream);
```

`fclose` 会先隐式 `fflush`，所以缓冲区里的数据不会丢。但它的返回值**必须检查**：写入失败（磁盘满、网络文件系统出错）往往到这一步才暴露，忽略它等于忽略「数据没写成功」。关闭后 `FILE*` 立即失效，不能再使用，也不要重复 `fclose`。

```c
/**
 * 取出流底层的文件描述符（POSIX 扩展，不属于 ISO C）
 *
 * @param stream 已打开的流
 * @return 文件描述符；失败返回 -1
 */
int fileno(FILE *stream);
```

它是 `stdio.h` 与 `unistd.h` 之间的桥梁。典型用途是拿到 fd 后调用只有低级接口才有的能力，比如 `fsync`：

```c
fflush(fp);                 // 第一步：用户态缓冲 → 内核
if (fsync(fileno(fp)) < 0) { // 第二步：内核页缓存 → 磁盘
    perror("fsync");
}
```

两步都做才算真正落盘，只 `fflush` 是不够的。

## 缓冲机制

这是 `stdio.h` 与 `unistd.h` 最核心的差别。`read` / `write` 每次调用都会进内核，而 `stdio.h` 在用户态攒一批数据再统一写出，用一次系统调用替代多次。

### fflush
```c
/**
 * 把流的用户态缓冲区内容推给内核
 *
 * @param stream 目标流；传 NULL 表示刷新所有输出流
 * @return 0 成功；EOF 失败并设置 errno
 */
int fflush(FILE *stream);
```

要强调的是 `fflush` **只保证数据交给了内核，不保证落盘**。掉电或内核崩溃仍会丢数据，需要 `fsync(fileno(fp))` 才能确认写入存储设备。对输入流调用 `fflush` 的行为在 ISO C 里未定义，`fflush(stdin)` 这种写法不可移植。

### setvbuf

```c
/**
 * 设置流的缓冲模式与缓冲区
 *
 * @param stream 目标流
 * @param buf    自定义缓冲区；传 NULL 让库自行分配
 * @param mode   _IOFBF 全缓冲 / _IOLBF 行缓冲 / _IONBF 无缓冲
 * @param size   缓冲区大小，mode 为 _IONBF 时忽略
 * @return 0 成功；非 0 失败
 */
int setvbuf(FILE *stream, char *buf, int mode, size_t size);
```

三种缓冲模式：

* **全缓冲**（`_IOFBF`）：缓冲区满了才写出。普通文件默认此模式。
* **行缓冲**（`_IOLBF`）：遇到 `\n` 或缓冲区满才写出。终端默认此模式。
* **无缓冲**（`_IONBF`）：每次调用立即写出。`stderr` 默认此模式。

**必须在对该流做任何 I/O 之前调用**，否则行为未定义。`fopen` 之后、第一次读写之前是唯一的安全窗口。若自己提供 `buf`，要保证它的生命周期长于流本身——用局部数组然后离开作用域是常见的悬垂指针来源。

#### 使用场景

`setvbuf` 属于调优和排查手段，日常写代码基本不需要碰。四类真实场景：

**1. 输出被重定向后想保留实时性**（最常用）

`stdout` 连终端时是行缓冲，一旦重定向到文件或管道就变**全缓冲**。于是 `./app > log.txt` 后 `tail -f log.txt` 长时间没有输出——数据攒在用户态等缓冲区满。

```c
int main() {
    setvbuf(stdout, NULL, _IOLBF, 0);   // 强制行缓冲，必须在任何输出之前
    ...
}
```

**2. 崩溃前的输出会丢**

用 `printf` 调试时，程序段错误退出，缓冲区里的内容还没写出，看到的日志停在崩溃点很早之前。设为无缓冲可以避免：

```c
setvbuf(stdout, NULL, _IONBF, 0);
```

这也解释了 `printf` 与 `fprintf(stderr, ...)` 混用时输出顺序错乱的现象——`stderr` 无缓冲立即输出，`stdout` 还在攒。把 `stdout` 也设成无缓冲，顺序就一致了。

**3. 大文件顺序读写的吞吐调优**

默认缓冲区大小是 `BUFSIZ`（常见 1024 或 8192 字节）。处理 GB 级文件时调大能显著减少系统调用次数：

```c
static char big_buf[1 << 20];           // 1 MB，static 保证生命周期
setvbuf(fp, big_buf, _IOFBF, sizeof(big_buf));
```

这类场景通常直接用 `read` / `write` 或 `mmap` 更合适，`setvbuf` 只是在不改架构的前提下捞一点性能。

**4. 内存受限或流数量很多**

同时打开成百上千个流时，每个流默认都会 `malloc` 一块缓冲区。可以调小 `size`，或提供静态 `buf` 避免库内部分配——嵌入式环境里后者尤其有用。

**`不要用它做的两件事：`**

* **确保数据落盘**：设 `_IONBF` 只是让数据尽快进内核，与落盘无关。要落盘用 `fflush` + `fsync(fileno(fp))`。
* **偶尔需要立即输出**：直接在那几个点调 `fflush(stdout)` 即可。把整个流改成无缓冲会让每次 `printf` 都触发一个系统调用，吞吐可能差一个数量级。

## 读写

```c
/**
 * 按「元素」读取二进制数据
 *
 * @param ptr    接收数据的缓冲区，至少要有 size * nmemb 字节
 * @param size   单个元素的字节数
 * @param nmemb  期望读取的元素个数
 * @param stream 源流
 * @return 实际读取的**元素个数**（不是字节数）；小于 nmemb 表示遇到 EOF 或出错
 */
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);

/**
 * 按「元素」写出二进制数据
 *
 * @return 实际写出的元素个数；小于 nmemb 表示出错
 */
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
```

返回值是**元素个数**而非字节数，这是最容易出错的地方。习惯写法是把 `size` 设为 1、`nmemb` 设为字节数，这样返回值就直接是字节数，也能得知部分读写的确切长度。

返回值小于 `nmemb` 时无法区分是 EOF 还是出错，必须再用 `feof` / `ferror` 判断。

```c
/**
 * 读一行文本，遇到换行符、读满 size-1 字节或 EOF 就停止
 *
 * @param s      接收缓冲区
 * @param size   缓冲区大小，含结尾的 '\0'
 * @param stream 源流
 * @return 成功返回 s；到达 EOF 且未读到任何字符、或出错时返回 NULL
 */
char *fgets(char *s, int size, FILE *stream);
```

`fgets` **会把换行符一起存进缓冲区**，通常需要手动去掉。它总会补 `'\0'`，所以最多只读 `size - 1` 个字符。

已被移除的 `gets` 不要使用：它不接受长度参数，必然存在缓冲区溢出，C11 已将其从标准中删除。

```c
/**
 * 按格式写出文本
 *
 * @param stream 目标流
 * @param format 格式字符串
 * @return 实际写出的字符数（不含结尾 '\0'）；负值表示出错
 */
int fprintf(FILE *stream, const char *format, ...);
```

格式化输出是 `stdio.h` 相对低级 I/O 最直观的优势，`unistd.h` 没有对应能力。

**`注意：`** `format` 绝不能使用外部输入。`printf(user_input)` 属于格式化字符串漏洞，攻击者可用 `%n` 写内存、用 `%s` 读栈上数据。正确写法是 `printf("%s", user_input)`。

## 定位

```c
/**
 * 重新定位流的读写位置，并清除 EOF 标志
 *
 * @param stream 目标流
 * @param offset 位移量，可以为负
 * @param whence SEEK_SET 文件起始 / SEEK_CUR 当前位置 / SEEK_END 文件末尾
 * @return 0 成功；-1 失败并设置 errno
 */
int fseek(FILE *stream, long offset, int whence);

/**
 * 取当前读写位置
 *
 * @return 相对文件头的字节偏移；-1 失败并设置 errno
 */
long ftell(FILE *stream);
```

注意 `fseek` / `ftell` 用的是 `long`，在 32 位平台上无法处理 2 GB 以上的文件。大文件要用 POSIX 的 `fseeko` / `ftello`（配合 `off_t`），或 `fgetpos` / `fsetpos`。

以 `"r+"`、`"w+"`、`"a+"` 打开的流在**读写切换之间必须插入一次** `fflush` 或定位操作（`fseek` / `rewind`），否则行为未定义。这是双向流最常见的坑。

## 错误处理：区分 EOF 与出错

`stdio.h` 的函数大多用 `NULL` 或短返回值表示「读写没完成」，但这既可能是正常读到文件末尾，也可能是真的出错。流内部为此维护了两个独立标志：

```c
/**
 * 检查流的 EOF 标志是否被置位
 *
 * @return 非 0 表示已到文件末尾；0 表示未到
 */
int feof(FILE *stream);

/**
 * 检查流的错误标志是否被置位
 *
 * @return 非 0 表示发生过错误；0 表示无错误
 */
int ferror(FILE *stream);

/**
 * 同时清除流的 EOF 标志和错误标志
 */
void clearerr(FILE *stream);
```

关键在于 **`feof` 是「事后」标志**：它只在某次读取**已经尝试并撞到**文件末尾之后才置位，而不是「下一次读会到末尾」的预判。所以下面这种写法是错的：

```c
// 错误：最后一行会被处理两次
while (!feof(fp)) {
    fgets(buf, sizeof(buf), fp);
    process(buf);
}
```

读到最后一行时 `feof` 仍为假，循环继续；下一次 `fgets` 失败但 `buf` 未被修改，于是同一行被处理第二次。正确写法是**直接判读取函数的返回值**：

```c
while (fgets(buf, sizeof(buf), fp) != NULL) {
    process(buf);
}
if (ferror(fp)) {           // 循环结束后再区分原因
    perror("fgets");
}
```

**示例：文件复制**

和 `unistd.h` 版本对照看，能直观感受两套接口的差异：不用处理短读短写、不用处理 `EINTR`，但多了「刷新缓冲」这一步。

```c++
#include <stdio.h>
#include <unistd.h>     // fsync
#include <errno.h>

int main() {
    int ret = 1;        // 默认失败，只有走完成功路径才置 0
    FILE *src = NULL;
    FILE *dst = NULL;
    char buf[4096];

    src = fopen("src.txt", "rb");
    if (src == NULL) {
        perror("fopen src.txt");
        goto cleanup;
    }
    dst = fopen("dst.txt", "wb");
    if (dst == NULL) {
        perror("fopen dst.txt");
        goto cleanup;
    }

    for (;;) {
        // size 取 1，返回值即字节数
        size_t n = fread(buf, 1, sizeof(buf), src);
        if (n == 0) {
            break;                      // EOF 或出错，循环外统一判定
        }
        if (fwrite(buf, 1, n, dst) != n) {
            perror("fwrite");
            goto cleanup;
        }
    }
    if (ferror(src)) {                  // 区分正常 EOF 与读取出错
        perror("fread");
        goto cleanup;
    }

    if (fflush(dst) != 0) {             // 用户态缓冲 → 内核
        perror("fflush");
        goto cleanup;
    }
    if (fsync(fileno(dst)) < 0) {       // 内核页缓存 → 磁盘
        perror("fsync");
        goto cleanup;
    }
    ret = 0;

cleanup:
    if (src != NULL) {
        fclose(src);
    }
    // fclose 会隐式 fflush，其失败可能是延迟暴露的写错误，要计入返回值
    if (dst != NULL && fclose(dst) != 0) {
        perror("fclose dst.txt");
        ret = 1;
    }
    return ret;
}
```

## vs unistd.h

| 特性        | `unistd.h`                    | `stdio.h`         |
| --------- | ----------------------------- | ----------------- |
| **接口类型**  | 系统调用接口（POSIX）                 | C 标准库接口           |
| **操作对象**  | `int fd`（文件描述符）               | `FILE *`（文件流）     |
| **缓冲**    | 仅内核缓冲，无用户态缓冲                  | 用户态缓冲 + 内核缓冲      |
| **效率**    | 每次调用都进内核，系统调用频繁               | 缓冲合并写出，系统调用少      |
| **可移植性**  | POSIX 系统可用，非跨平台               | ANSI C 标准，跨平台     |
| **格式化**   | 无                             | `printf` / `scanf` 系列 |
| **短读短写**  | 必须自己循环处理                      | 库内部已处理            |
| **信号打断**  | 需自行处理 `EINTR`                 | 库内部已处理            |
| **精细控制**  | `dup`、`pipe`、`fcntl` 文件锁等     | 不支持，需 `fileno` 降级 |

两者可以混用，但**不要对同一个文件同时用两套接口读写**：`stdio.h` 的用户态缓冲和 fd 的内核偏移量各自独立，混用会导致数据顺序错乱。必须混用时，每次切换前都要 `fflush`。

### 使用场景

**选 `unistd.h`** —— 需要精细控制或使用 POSIX 独有能力时：

* 文件复制、socket 通信、设备读写、守护进程
* 需要 `pread` / `pwrite` 做并发定位读写
* 需要 `fcntl` 文件锁、`dup2` 重定向、`pipe` 进程通信
* 需要非阻塞 I/O 或参与 `select` / `epoll` 事件循环

**选 `stdio.h`** —— 需要易用性和可移植性时：

* 文本处理、配置文件解析、日志写入
* 需要格式化输入输出
* 代码要在非 POSIX 平台（如 Windows 原生）编译

## 注意事项

* `fread` / `fwrite` 的返回值是**元素个数**，不是字节数。把 `size` 设为 1 可以规避混淆。
* 不要用 `while (!feof(fp))` 控制读取循环，直接判读取函数的返回值。
* `fflush` 只到内核，落盘要 `fsync(fileno(fp))`。
* `fclose` 的返回值要检查，延迟的写错误在这里暴露。
* 双向流（`"r+"` 等）在读写切换之间必须插入 `fflush` 或定位操作。
* `printf` / `fprintf` 的格式字符串绝不能来自外部输入。
* `fseek` / `ftell` 用 `long`，大文件要换 `fseeko` / `ftello`。
* `stdio.h` 的流**不是线程安全的组合操作**：单个函数调用是原子的（POSIX 要求内部加锁），但「读一行再写一行」这样的序列需要自己用 `flockfile` / `funlockfile` 保护。






