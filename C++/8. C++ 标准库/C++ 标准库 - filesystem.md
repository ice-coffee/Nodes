##  简介

`<filesystem>` 是 C++17 引入的文件系统库，命名空间为 `std::filesystem`，提供跨平台的路径表示、目录遍历和文件操作能力。在此之前，这些能力依赖平台 API（POSIX `<dirent.h>`、Windows API）。

> 早期编译器注意事项：GCC 8 及更早版本需要额外链接 `-lstdc++fs`，clang 7 / libc++ 需要 `-lc++fs`；更早的标准实现位于 `<experimental/filesystem>`（`std::experimental::filesystem`），已废弃，新代码统一使用 `<filesystem>`。

## 能力分类总览

| 类别 | 代表名称 | 用途 |
| ---- | --- | --- |
| 路径类型 | `path` | 表示路径，处理分隔符等平台差异 |
| 状态查询 | `exists`、`is_directory`、`is_regular_file`、`file_size` | 判断文件/目录存在性与类型 |
| 目录操作 | `create_directory`、`create_directories`、`remove`、`rename`、`current_path` | 创建、删除、重命名、切换目录 |
| 目录遍历 | `directory_iterator`、`recursive_directory_iterator` | 迭代目录内容 |
| 文件复制 | `copy`、`copy_file`、`copy_options` | 复制文件或目录树 |
| 空间查询 | `space`、`space_info` | 查询磁盘容量 |
| 时间与权限 | `last_write_time`、`permissions` | 修改时间和权限（C++17 中为 `perms`） |

## path 基础
`std::filesystem::path` 是库的核心类型，把路径当作字符串对象管理，并屏蔽 Windows（`\`）与 POSIX（`/`）的分隔符差异。

### 构造与拼接
```c++
#include <filesystem>
namespace fs = std::filesystem;

fs::path p1("a/b/c.txt");       // 从字符串构造
fs::path p2 = "a" / "b" / "c.txt";  // 运算符 / 拼接路径，自动处理分隔符
fs::path p3("data");
p3 /= "log.txt";                // 追加成分，p3 = "data/log.txt"
```

> 注意：`/` 是路径拼接，不是整除；`+` 是字符串级拼接（不加分隔符），容易用错。

### 常用成员函数
```c++
fs::path p("/home/user/report.tar.gz");

p.string();        // 转回 std::string（native 编码）
p.filename();      // "report.tar.gz"（含扩展名）
p.stem();          // "report.tar"（最后一部分去掉扩展名）
p.extension();     // ".gz"
p.parent_path();   // "/home/user"
p.root_name();     // Windows 上如 "C:"，POSIX 为空
p.is_absolute();   // 是否绝对路径
p.has_extension(); // 各成分是否存在
```

### path 与字符串
```c++
fs::path p = "hello.txt";
std::string s = p.string();          // 常规转换
const char* raw = p.c_str();         // native 字符串
fs::path q("中文目录");
std::cout << q.u8string();           // UTF-8 表示（C++20 起返回 char8_t 版本，注意类型变化）
```

## 状态查询
```c++
namespace fs = std::filesystem;

fs::path p("test.txt");
if (fs::exists(p)) {
    if (fs::is_regular_file(p)) {
        std::cout << "size: " << fs::file_size(p) << std::endl;  // 字节数
    } else if (fs::is_directory(p)) {
        std::cout << "directory" << std::endl;
    }
}
```

常用查询函数：

* `exists(p)`：路径是否存在。
* `is_directory(p)` / `is_regular_file(p)` / `is_symlink(p)`：判断类型。
* `file_size(p)`：文件字节数，仅对普通文件有意义。
* `equivalent(p1, p2)`：两个路径是否指向同一实体（解析符号链接后比较）。

> `file_size` 对目录调用会抛异常（或设置 error_code），查询前应先用 `is_regular_file` 判断。

## 目录操作
### 创建与删除
```c++
fs::create_directory("a");            // 创建单层目录，已存在返回 false
fs::create_directories("a/b/c");      // 递归创建多级目录（类似 mkdir -p）
fs::remove("a/b/c");                  // 删除文件或空目录
std::uintmax_t n = fs::remove_all("a");  // 递归删除，返回删除的文件数
```

### 重命名与移动
```c++
fs::rename("old.txt", "new.txt");     // 同文件系统内相当于移动
```

### 复制
```c++
fs::copy_file("src.txt", "dst.txt", fs::copy_options::overwrite_existing);

fs::copy("src_dir", "dst_dir",
         fs::copy_options::recursive | fs::copy_options::skip_existing);  // 复制目录树
```

> `copy_file` 默认目标已存在时抛异常；`copy` 作用于目录时默认只复制目录结构本身，复制内容通常要加 `recursive`。

### 当前目录
```c++
fs::current_path();               // 获取当前工作目录
fs::current_path("/tmp");         // 切换当前工作目录（类似 cd）
fs::temp_directory_path();        // 获取临时目录
fs::absolute("a.txt");            // 转绝对路径（基于当前目录拼接）
fs::canonical("a/../a.txt");      // 规范化：解析符号链接和相对成分
fs::relative("a/b", "a");         // 求相对路径，结果 "b"
```

## 目录遍历
### directory_iterator（单层）
```c++
#include <filesystem>
#include <iostream>
namespace fs = std::filesystem;

int main() {
    for (const auto& entry : fs::directory_iterator(".")) {
        std::cout << entry.path() << std::endl;
    }
    return 0;
}
```

### recursive_directory_iterator（递归）
```c++
for (const auto& entry : fs::recursive_directory_iterator(".")) {
    std::cout << entry.path() << (entry.is_directory() ? "  [dir]" : "") << std::endl;
}
```

### directory_entry 常用方法
迭代到的 `entry` 是 `directory_entry` 对象，自带缓存的状态查询：

```c++
entry.path();      // 完整路径
entry.exists();    // 是否存在
entry.is_directory();
entry.file_size();
entry.last_write_time();
```

### 遍历控制
```c++
fs::recursive_directory_iterator it(".");
it.disable_recursion_pending();  // 当前是目录时不递归进入
it.pop();                        // 跳过当前目录的剩余内容
```

> 易错点：在递归遍历中删除或创建文件可能使迭代器失效或产生意外行为；常见做法是先收集路径到容器，再统一处理。另外遍历顺序是未指定的，不要假设按文件名排序。

## 空间查询
```c++
fs::space_info info = fs::space("/");
std::cout << "容量: " << info.capacity / (1 << 30) << " GB" << std::endl;
std::cout << "剩余: " << info.free / (1 << 30) << " GB" << std::endl;
std::cout << "可用(非root): " << info.available / (1 << 30) << " GB" << std::endl;
```

## 错误处理
大多数函数有两种重载：**抛异常版**（默认）和 **error_code 版**（末尾多一个 `std::error_code&` 参数，不抛异常）：

```c++
namespace fs = std::filesystem;

// 1) 异常版
try {
    fs::file_size("not_exist.txt");
} catch (const fs::filesystem_error& e) {
    std::cout << e.what() << std::endl;      // 描述信息
    std::cout << e.path1() << std::endl;     // 涉及的路径
    std::cout << e.code() << std::endl;      // 平台错误码
}

// 2) error_code 版：适合预期可能失败、不想用异常控制流程的场景
std::error_code ec;
auto size = fs::file_size("not_exist.txt", ec);
if (ec) {
    std::cout << "error: " << ec.message() << std::endl;
}
```

## 附
- cppreference: [C++ 标准库头文件 `<filesystem>`](https://en.cppreference.com/w/cpp/header/filesystem)
- cppreference: [`std::filesystem::path`](https://en.cppreference.com/w/cpp/filesystem/path)
