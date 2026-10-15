[toc]

## 简述

`fcntl.h` 是 POSIX 标准头文件，名字来自 **File Control**，主要用于 **文件描述符的控制与文件打开操作**。

它提供了：
1. **`open` 标志（O\_ 宏）**：控制文件打开方式
2. **`fcntl` 命令（F\_ 宏）**：操作文件描述符
3. **文件锁（struct flock）**：支持进程间互斥/共享访问

### `open` 函数

`open()` 用来打开文件：

```c
int fd = open(const char *pathname, int flags, mode_t mode);
```

**示例：**
用 `open` 打开文件并追加写：

```c
int fd = open("log.txt", O_WRONLY | O_CREAT | O_APPEND, 0644);
```

#### flags

* **基本访问方式（三选一）**

  * `O_RDONLY`：只读
  * `O_WRONLY`：只写
  * `O_RDWR`：可读可写

* **文件不存在时行为**

  * `O_CREAT`：不存在则创建（需要 `mode` 参数）
  * `O_EXCL`：和 `O_CREAT` 一起用，文件已存在则失败
  * `O_TRUNC`：清空已有文件

* **写入方式**

  * `O_APPEND`：每次写都追加到文件末尾
  * `O_SYNC`：写入时同步到磁盘（包括元数据）
  * `O_DSYNC`：写入时同步数据，不保证元数据同步

* **其他常见标志**

  * `O_NONBLOCK`：非阻塞模式
  * `O_NOFOLLOW`：不跟随符号链接
  * `O_CLOEXEC`：设置 `close-on-exec`，避免 `exec` 时泄露文件描述符

##### O_DSYNC / D_SYNC
**一句话对比：**

* **`O_DSYNC`**：每次 `write()` 直到**数据本身**以及为正确读取数据所必需的**最少元数据**（如扩展分配、文件长度变化）落到稳定介质才返回；**不要求**等待时间戳之类的非关键元数据。
* **`O_SYNC`**：每次 `write()` 要等**数据 + 所有关联元数据**（例如 `mtime/ctime`）一并持久化，才返回。是更“重”的同步级别。

等价关系可粗略理解为：

* `O_DSYNC` ≈ 每次写后做一次 `fdatasync()`
* `O_SYNC`  ≈ 每次写后做一次 `fsync()`

**❗️注意：**

* **运行时不可切换**：在 Linux 上，不能用 `fcntl(F_SETFL)` 去开/关 `O_SYNC` 或 `O_DSYNC`；必须在 `open()` 时指定（`F_SETFL` 改这俩会被**静默忽略**）。
* **同时设置**：若同时给出 `O_SYNC | O_DSYNC`，效果等同于 **`O_SYNC`**。

**用法：**

* **日志/数据库 redo log**：`O_DSYNC`（减少时间戳等开销，性能更好）。
* **需要严格“落盘即见”的文件及其元数据**：`O_SYNC`。
* **偶尔需要持久化**：普通打开，关键边界上调用 `fdatasync()`/`fsync()`，避免每次写都付全额同步成本。

**示例：**

```c
// 数据完整性（更快，常用于日志）
int fd = open("log.bin", O_WRONLY | O_CREAT | O_DSYNC, 0644);

// 文件完整性（更强，更慢）
int fd2 = open("meta.bin", O_WRONLY | O_CREAT | O_SYNC, 0644);

// 普通打开 + 关键点再刷（更灵活）
int fd3 = open("batch.bin", O_WRONLY | O_CREAT, 0644);
/* 写入一批数据... */
fdatasync(fd3);   // 或 fsync(fd3);
```

#### mode

`mode` 是 **文件权限掩码**，通常写成八进制（比如 `0644`）。
它定义了新建文件的 **访问权限位**（和 `chmod` 一样）；最终结果收 `umask` 影响。

`mode` **当且仅当 `O_CREAT` 被使用时才有意义**，表示新建文件的权限，如果没带 `O_CREAT`，第三个参数 `mode` **不需要传**，否则会有未定义行为。

常用宏（在 `<sys/stat.h>` 里定义）：

* **用户（owner）权限**

  * `S_IRUSR` (0400)：可读
  * `S_IWUSR` (0200)：可写
  * `S_IXUSR` (0100)：可执行

* **组权限**

  * `S_IRGRP` (0040)
  * `S_IWGRP` (0020)
  * `S_IXGRP` (0010)

* **其他人权限**

  * `S_IROTH` (0004)
  * `S_IWOTH` (0002)
  * `S_IXOTH` (0001)

**`示例：`**

1. 创建一个可读写文件（用户可读写，组/其他只读）

```c
int fd = open("file.txt", O_WRONLY | O_CREAT, 0644);
```

等价于：

```c
int fd = open("file.txt", O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
```

2. 创建一个只有自己能读写的文件

```c
int fd = open("secret.txt", O_WRONLY | O_CREAT, 0600);
```

3. 创建一个所有人都可读写的文件

```c
int fd = open("public.txt", O_WRONLY | O_CREAT, 0666);
```

##### `umask` 的影响

注意：**最终权限 = mode & \~umask**

* `umask` 是一个系统掩码，用来禁止某些默认权限
* 常见默认 `umask = 0022`（禁止组/其他的写权限）

例：

```c
open("demo.txt", O_CREAT | O_WRONLY, 0666);
```

理论上权限是 `rw-rw-rw-` (0666)，但如果 `umask = 0022`，
最终结果 = `0666 & ~0022 = 0644` → `rw-r--r--`。

### `fcntl` 函数

`fcntl()` 是文件描述符的万能控制器：

```c
int fcntl(int fd, int cmd, ...);
```

**常见 `cmd`：**

* **文件描述符复制**

  * `F_DUPFD`：复制文件描述符，返回新的 fd（类似 `dup`）
  * `F_DUPFD_CLOEXEC`：复制时自动设置 `FD_CLOEXEC`

* **文件描述符标志**

  * `F_GETFD`：获取文件描述符标志（比如 `FD_CLOEXEC`）
  * `F_SETFD`：设置文件描述符标志

* **文件状态标志**

  * `F_GETFL`：获取文件状态标志（`O_RDONLY`, `O_NONBLOCK` 等）
  * `F_SETFL`：修改文件状态标志（比如设置/取消 `O_NONBLOCK`）

* **文件锁**

  * `F_GETLK`：查询文件锁状态
  * `F_SETLK`：设置锁（非阻塞）
  * `F_SETLKW`：设置锁（阻塞等待）

文件锁配合 `struct flock` 使用（记录锁）：

```c
struct flock {
  short l_type;   // F_RDLCK (读锁), F_WRLCK (写锁), F_UNLCK (解锁)
  short l_whence; // SEEK_SET, SEEK_CUR, SEEK_END
  off_t l_start;  // 锁定的起始偏移
  off_t l_len;    // 锁定的长度（0 表示到 EOF）
  pid_t l_pid;    // 持有锁的进程 ID（只读）
};
```

**示例：**

1. 把文件描述符设为非阻塞：

```c
int flags = fcntl(fd, F_GETFL, 0);
fcntl(fd, F_SETFL, flags | O_NONBLOCK);
```

2. 文件加锁：

```c
struct flock lock;
lock.l_type = F_WRLCK;
lock.l_whence = SEEK_SET;
lock.l_start = 0;
lock.l_len = 0; // 整个文件

if (fcntl(fd, F_SETLK, &lock) == -1) {
    perror("lock failed");
}
```
