[toc]

## 简介

`<sys/stat.h>` 是 **POSIX 标准** 提供的头文件，主要用于 **获取和修改文件属性**（metadata），包括：

* 文件类型（普通文件、目录、符号链接等）
* 文件权限（读、写、执行）
* 文件大小
* 文件的时间戳（创建、修改、访问时间）
* inode 信息、硬链接数等


## 使用

### 结构体

最常用的结构体，`stat()` 系统调用会把文件信息填充到这个结构体中：

```c
struct stat {
    dev_t     st_dev;     // 设备ID
    ino_t     st_ino;     // inode编号
    mode_t    st_mode;    // 文件类型 & 权限
    nlink_t   st_nlink;   // 硬链接数
    uid_t     st_uid;     // 所有者用户ID
    gid_t     st_gid;     // 所有者组ID
    dev_t     st_rdev;    // 若为设备文件，表示设备号
    off_t     st_size;    // 文件大小（字节）
    blksize_t st_blksize; // 文件系统I/O块大小
    blkcnt_t  st_blocks;  // 占用的块数（512字节块）

    struct timespec st_atim; // 最后访问时间
    struct timespec st_mtim; // 最后修改时间
    struct timespec st_ctim; // 状态改变时间（如权限修改）
};
```

### 获取文件状态

* **`int stat(const char *path, struct stat *buf)`**
  获取指定路径的文件状态。

* **`int fstat(int fd, struct stat *buf)`**
  根据文件描述符获取文件状态。

* **`int lstat(const char *path, struct stat *buf)`**
  与 `stat` 类似，但如果是符号链接，返回的是 **符号链接本身的信息**，而不是目标文件。

---

### 修改文件权限和属性

* **`int chmod(const char *path, mode_t mode)`**
  修改文件权限（如 `chmod 755`）。

* **`int fchmod(int fd, mode_t mode)`**
  用文件描述符修改权限。

* **`int mkdir(const char *pathname, mode_t mode)`**
  创建目录时指定权限。

* **`int mkfifo(const char *pathname, mode_t mode)`**
  创建 FIFO（命名管道）。

---

### 文件类型宏

`st_mode` 里包含文件类型和权限，可以用以下宏判断：

```c
S_ISREG(m)   // 是否是普通文件
S_ISDIR(m)   // 是否是目录
S_ISLNK(m)   // 是否是符号链接
S_ISCHR(m)   // 是否是字符设备
S_ISBLK(m)   // 是否是块设备
S_ISFIFO(m)  // 是否是FIFO/管道
S_ISSOCK(m)  // 是否是Socket
```

### 文件权限

权限信息也存储在 `st_mode` 里：

* **用户/组/其他**

  * `S_IRUSR` (0400)：用户可读
  * `S_IWUSR` (0200)：用户可写
  * `S_IXUSR` (0100)：用户可执行
  * `S_IRGRP` (0040)：组可读
  * `S_IWGRP` (0020)：组可写
  * `S_IXGRP` (0010)：组可执行
  * `S_IROTH` (0004)：其他可读
  * `S_IWOTH` (0002)：其他可写
  * `S_IXOTH` (0001)：其他可执行

* **特殊位**

  * `S_ISUID` (04000)：设置用户 ID 位（执行时使用文件所有者权限）
  * `S_ISGID` (02000)：设置组 ID 位
  * `S_ISVTX` (01000)：sticky bit（目录下只有文件所有者/根才能删除）

### 简单示例

```c
#include <sys/stat.h>
#include <stdio.h>

int main() {
    struct stat st;
    if (stat("test.txt", &st) == 0) {
        printf("文件大小: %ld 字节\n", st.st_size);
        if (S_ISDIR(st.st_mode)) {
            printf("这是一个目录\n");
        } else if (S_ISREG(st.st_mode)) {
            printf("这是一个普通文件\n");
        }
    } else {
        perror("stat");
    }
    return 0;
}
```

## 扩展
* **`sys/stat.h`**：想知道“文件是什么”；典型场景：获取大小、权限、类型、时间戳，修改权限，创建目录/FIFO。

* **`stdio.h`**：想操作“文件内容”；典型场景：读取配置文件、写日志、CSV 解析。

* **`unistd.h`**：想做“底层系统调用”；典型场景：系统调用级别的 `open/read/write/unlink`，性能要求高。
