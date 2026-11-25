## 引入
```c++
#include <cstdlib>
```

`cstdlib` 是 C 标准库头文件 `<stdlib.h>` 在 C++ 中的对应形式（"c" 前缀 + 去掉 `.h`），其中的名称通常位于 `std` 命名空间，同时也保证在全局命名空间可见。

## 能力分类总览

`<cstdlib>` 提供的都是"C 风格"的通用基础工具，可按用途分为以下几类：

| 类别 | 代表名称 | 用途 |
| --- | --- | --- |
| 程序终止 | `exit`、`abort`、`atexit`、`EXIT_SUCCESS` / `EXIT_FAILURE` | 结束程序、注册退出处理函数 |
| 动态内存 | `malloc`、`calloc`、`realloc`、`free` | C 风格内存分配（C++ 中一般用 `new`/智能指针） |
| 随机数 | `rand`、`srand`、`RAND_MAX` | 伪随机数（质量低，一般用 `<random>`） |
| 字符串与数值转换 | `atoi`、`atol`、`atof`、`strtol`、`strtod` 等 | 字符串转数字（C++ 中可用 `std::stoi` 等） |
| 整数算术 | `abs`、`labs`、`llabs`、`div`、`ldiv`、`lldiv` | 绝对值、整除取商和余数 |
| 环境访问 | `getenv`、`system` | 读取环境变量、执行外部命令 |
| 搜索与排序 | `qsort`、`bsearch` | C 风格排序与二分查找（C++ 中一般用 `<algorithm>`） |
| 多字节字符 | `mbstowcs`、`wcstombs`、`mblen` 等 | 多字节与宽字符转换 |

## 示例
```c++
#include <cstdlib>
#include <iostream>

int main()
{
    if (std::atoi("42") == 42) {
        std::cout << "parse ok" << std::endl;
    }
    std::srand(42);               // 设置随机种子
    int r = std::rand() % 100;    // 生成 0~99 的伪随机数
    std::cout << r << std::endl;
    return 0;
}
```

## 程序终止
### exit / _Exit / abort
```c++
void exit(int status);   // 正常终止：先执行 atexit 注册的函数，再销毁静态对象
void _Exit(int status);  // 立即终止：不执行 atexit 函数、不刷新流
void abort(void);        // 异常终止：产生 SIGABRT，可能生成 core dump
```

* `exit(0)`：正常退出，`status` 会返回给操作系统；通常用 `EXIT_SUCCESS`（0）、`EXIT_FAILURE`（1）表示。
* `abort()`：用于不可恢复的错误，不做任何清理。

```c++
#include <cstdlib>

int main(int argc, char* argv[])
{
    if (argc < 2) {
        std::exit(EXIT_FAILURE);  // 参数不足，直接退出
    }
    return 0;  // return main 等价于 exit(0)
}
```

> 注意：`exit` 只终止程序，不会析构局部对象；从 `main` 中 `return` 才会销毁局部对象后再按 `exit` 语义终止。

### atexit
注册在 `exit` 时执行的函数，注册得越晚越先执行（逆序执行）。

```c++
#include <cstdlib>
#include <iostream>

void cleanup() {
    std::cout << "cleanup" << std::endl;
}

int main() {
    std::atexit(cleanup);      // 正常退出时执行
    std::at_quick_exit(cleanup); // quick_exit 时执行
    return 0;
}
```

## 动态内存管理
C 风格的四件套，C++ 中一般不直接使用（优先 `new`/`delete` 或智能指针），但在维护 C 代码或与 C 接口交互时会遇到：

```c++
void* malloc(size_t size);              // 分配未初始化内存
void* calloc(size_t n, size_t size);    // 分配并清零
void* realloc(void* p, size_t size);    // 调整大小（可能搬家）
void  free(void* p);                    // 释放；只能 free malloc/calloc/realloc 的产物
```

```c++
#include <cstdlib>

int main() {
    int* arr = static_cast<int*>(std::malloc(4 * sizeof(int)));
    if (arr == nullptr) {
        return EXIT_FAILURE;
    }
    arr[0] = 1;
    std::free(arr);   // 必须配对释放，否则内存泄漏
    return 0;
}
```

> 混用错误：`malloc` 分配的内存用 `delete` 释放、`new` 分配的用 `free` 释放，都是未定义行为；`realloc` 之后的旧指针不可再用。

## 随机数
### rand / srand
```c++
int rand(void);                 // 返回 [0, RAND_MAX] 的伪随机数
void srand(unsigned seed);      // 设置随机种子，常见写法 srand(time(nullptr))
```

* 只设置一次种子即可，在循环里反复 `srand` 会让结果重复。
* 同一程序每次运行若不换种子，序列完全相同（便于调试复现）。
* `rand() % n` 会让低位分布不均匀，且 `RAND_MAX` 可能只有 32767。

```c++
#include <cstdlib>
#include <ctime>

int main() {
    std::srand(static_cast<unsigned>(std::time(nullptr)));
    int dice = std::rand() % 6 + 1;  // 1~6
    return 0;
}
```

> C++ 中更好的做法是用 `<random>`（`std::mt19937` + `std::uniform_int_distribution`），`rand` 仅供简单场景或教学使用。

## 字符串与数值转换
### atoi / atol / atof 系列
```c++
int       atoi(const char* str);    // 字符串转 int
long      atol(const char* str);    // 字符串转 long
double    atof(const char* str);    // 字符串转 double
```

* 转换失败不报错、直接返回 0，无法区分"字符串本身就是 0"和"解析失败"。

```c++
int n = std::atoi("123");     // 123
int m = std::atoi("abc");     // 0（静默失败）
double d = std::atof("3.14"); // 3.14
```

### strtol / strtod 系列
带错误检测和进制支持的转换函数，是 `atoi` 系列的强化版：

```c++
long strtol(const char* str, char** str_end, int base);   // base 可为 2~36 或 0（自动判断）
double strtod(const char* str, char** str_end);
```

```c++
#include <cstdlib>

int main() {
    const char* s = "1A";
    char* end;
    long value = std::strtol(s, &end, 16);  // 按十六进制解析，value = 26
    if (end == s) {
        // 没有解析到任何数字
    }
    return 0;
}
```

> C++ 中优先用 `std::stoi`、`std::stol`、`std::stod`（`<string>`），它们用异常报告错误，且支持 `std::string` 参数。

## 整数算术
```c++
int        abs(int n);        // 绝对值
long      labs(long n);
long long llabs(long long n);
div_t      div(int numer, int denom);      // 同时求商和余数
ldiv_t     ldiv(long numer, long denom);
```

```c++
std::div_t r = std::div(17, 5);  // r.quot = 3, r.rem = 2
```

> 注意 `div` 是"一次除法同时得商和余"，而 `/` 和 `%` 是两次运算；此外 C++ 中 `abs` 有 `<cmath>` 版本处理浮点数，注意不要混淆整型 `abs` 与浮点 `fabs`。

## 环境访问
### getenv
```c++
char* getenv(const char* name);  // 返回环境变量值；不存在返回 nullptr
```

```c++
const char* path = std::getenv("PATH");
if (path != nullptr) {
    std::cout << path << std::endl;
}
```

### system
```c++
int system(const char* command);  // 把命令交给 shell 执行
```

* `system(nullptr)` 用于检测是否存在命令解释器。
* 命令来自用户输入时存在命令注入风险；可移植性也依赖目标系统的 shell。

```c++
int ret = std::system("ls -l");  // Unix-like 下列目录
```

> C++ 中更安全的做法是使用 `<filesystem>` 遍历目录、`popen`/进程 API 或第三方库执行外部命令。

## 搜索与排序
### qsort / bsearch
C 风格排序与查找，通过函数指针决定比较方式：

```c++
#include <cstdlib>
#include <iostream>

int compare_ints(const void* a, const void* b) {
    int x = *static_cast<const int*>(a);
    int y = *static_cast<const int*>(b);
    return (x > y) - (x < y);
}

int main() {
    int arr[] = {3, 1, 2};
    std::qsort(arr, 3, sizeof(int), compare_ints);  // arr = {1, 2, 3}

    int key = 2;
    int* p = static_cast<int*>(std::bsearch(&key, arr, 3, sizeof(int), compare_ints));
    if (p) {
        std::cout << "found: " << *p << std::endl;
    }
    return 0;
}
```

> C++ 中优先使用 `<algorithm>` 的 `std::sort` / `std::binary_search`：类型安全（无需 `void*` 强转）、无函数指针开销、支持自定义比较器。`qsort` 在维护 C 代码或需要与 C 接口保持一致时使用。

## 多字节字符
用于多字节字符串与宽字符字符串之间的转换，属于 C 遗留接口，实践中较少直接使用：

```c++
size_t mbstowcs(wchar_t* dest, const char* src, size_t max);
size_t wcstombs(char* dest, const wchar_t* src, size_t max);
int mblen(const char* s, size_t n);
```

C++ 中的现代替代是 `std::wstring_convert`（已废弃但常见）或平台专用 API、第三方库（如 ICU）。

## 附
- cppreference: [C++ 标准库头文件 `<cstdlib>`](https://en.cppreference.com/w/cpp/header/cstdlib)
- cppreference: [C 标准库头文件 `<stdlib.h>`](https://en.cppreference.com/w/c/program_control)
