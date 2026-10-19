
在 C++（特别是 Linux / Unix 系统）中 `dirent.h` 提供了访问目录（directory）的接口。它定义了用于操作目录的函数和结构体，主要用于读取目录下的文件和子目录的名称。

---

### 常用的类型和函数说明

#### 1. `DIR` 结构体

这是一个目录流对象的类型（opaque type），用于表示打开的目录。

#### 2. `struct dirent`

表示目录中的一个条目（entry），通常对应一个文件或子目录。

```cpp
struct dirent {
    ino_t          d_ino;       // inode 号
    off_t          d_off;       // 到目录文件开头的偏移
    unsigned short d_reclen;    // 此记录长度
    unsigned char  d_type;      // 文件类型（仅某些系统支持）
    char           d_name[256]; // 文件名（以 null 结尾）
};
```

`d_type` 的常见值（注意：并非所有系统支持）：

* `DT_REG`：普通文件
* `DT_DIR`：目录
* `DT_LNK`：符号链接
* `DT_FIFO`：FIFO/命名管道
* `DT_SOCK`：Socket
* `DT_CHR`：字符设备
* `DT_BLK`：块设备
* `DT_UNKNOWN`：未知类型

---

### 常用函数

1. `DIR *opendir(const char *name);`：打开一个目录，返回 `DIR*` 指针。
2. `struct dirent *readdir(DIR *dirp);`：读取目录中的下一个条目。返回指向 `struct dirent` 的指针。读取完毕返回 `NULL`。
3. `int closedir(DIR *dirp);`：关闭目录。
4. `void rewinddir(DIR *dirp);`：将目录流的位置重置到开头。
5. `int dirfd(DIR *dirp);`：获取与目录流关联的文件描述符（用于低级操作）。

---

### 示例代码

```cpp
#include <iostream>
#include <dirent.h>
#include <cstring>

int main() {
    const char* path = "/tmp";  // 要打开的目录路径
    DIR* dir = opendir(path);

    if (dir == nullptr) {
        std::cerr << "无法打开目录: " << path << std::endl;
        return 1;
    }

    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        std::cout << entry->d_name;

        if (entry->d_type == DT_DIR) {
            std::cout << " [DIR]";
        }
        std::cout << std::endl;
    }

    closedir(dir);
    return 0;
}
```

---

### 注意事项

* `.` 和 `..` 是每个目录默认包含的特殊条目，分别表示当前目录和上一级目录，通常要跳过它们。
* `d_type` 字段在部分系统上（如某些版本的 NFS）可能总是返回 `DT_UNKNOWN`。这时可以使用 `stat()` 或 `lstat()` 来获取详细信息。
* 这个 API 属于 POSIX 标准，在 Windows 上不可用。
