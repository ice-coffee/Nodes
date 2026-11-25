## 概述

`c++` 中常用流头文件如下：

* `<iostream>`：输入输出流基类。
* `<fstream>`：文件输入输出流。
* `<sstream>`：`string` 格式字符串输入输出流。
* `<strstream>`：`char` 数组格式字符串输入输出流。

其中 `<iostream>` 相当于其他流头文件的父类，`<fstream>` 等都是派生自它。这些头文件中都包含一个输入流、一个输出流。

## `<iosfwd>`

即 `ios forward`，是流体系的前置声明头文件：只声明类模板和类型别名，不包含任何类定义，也不定义流对象。

### 声明内容

```c++
namespace std {
    // 类模板前置声明（只声明，不定义）
    template<class CharT, class Traits = char_traits<CharT>> class basic_ios;
    template<class CharT, class Traits = char_traits<CharT>> class basic_streambuf;
    template<class CharT, class Traits = char_traits<CharT>> class basic_istream;
    template<class CharT, class Traits = char_traits<CharT>> class basic_ostream;
    template<class CharT, class Traits = char_traits<CharT>> class basic_iostream;
    // 以及 basic_ifstream / basic_ofstream / basic_fstream
    //     basic_istringstream / basic_ostringstream / basic_stringstream
    //     basic_filebuf / basic_stringbuf
}
```

* 别名：`istream`、`ostream`、`iostream`、`ifstream`、`ofstream`、`fstream`、`istringstream`、`ostringstream`、`stringstream` 及对应的 `w` 版本。
* 辅助类型：`streamsize`、`streamoff`、`streampos`、`wstreampos`、`fpos`、`char_traits` 的特化声明。

> `<iosfwd>` 中既没有 `cin`、`cout`、`cerr`，也没有成员函数，因此不能构造对象、不能调用方法，只适合用于声明函数签名。

### 作用

* 降低编译依赖：头文件中只写 `std::ostream& operator<<(...)` 之类的签名时，无需包含整个 `<iostream>`。
* 打破循环包含：类之间互相引用流类型时不会形成 include 环。
* 保证模板默认参数只声明一次：`char_traits<CharT>` 不能重复指定默认实参，标准库将其统一收敛在 `<iosfwd>` 中。

### 用法示例

```c++
// my_class.h
#pragma once
#include <iosfwd>        // 仅需要 std::ostream 的声明

class MyClass {
public:
    void dump(std::ostream& os) const;
};
```

```c++
// my_class.cpp
#include "my_class.h"
#include <iostream>      // 真正用到成员函数时才包含完整定义

void MyClass::dump(std::ostream& os) const { os << "MyClass\n"; }
```

## `<iostream>`
标准输入输出流，包含输入流 `istream` 与输出流 `ostream`：前者负责从流中读取数据，后者负责向流中写入数据。`<iostream>` 同时包含 `<istream>` 与 `<ostream>` 的内容，并定义了 `cin`、`cout` 等标准流对象。

### 预定义对象

* `cin`：标准输入（键盘），类型 `istream`，带缓冲区。
* `cout`：标准输出（屏幕），类型 `ostream`，带缓冲区，缓冲区满或刷新时才真正写出。
* `cerr`：标准错误，类型 `ostream`，**不带缓冲**，适合输出需要立即看到的错误信息。
* `clog`：标准错误，类型 `ostream`，带缓冲。

`wcin`、`wcout`、`wcerr`、`wclog` 是对应的宽字符版本。

### 输入输出运算符

* `>>` 提取：从流中读取数据，默认以空白符（空格、制表、换行）为分隔。
* `<<` 插入：向流中写入数据。

两个运算符都返回流自身的引用，因此支持链式写法：

```c++
int age = 0;
std::string name;
std::cin >> name >> age;                   // 输入：Tom 18
std::cout << name << " " << age << '\n';   // 输出：Tom 18
```

### `basic_ostream` 中定义的方法

* `put(char_type __c)`：用于将指定的字符写入输出流
* `write(const char_type* __s, streamsize __n)`：用于将指定数量的字符数组写入输出流
* `flush()`：刷新输出流的缓冲区，确保所有等待写入的数据都被实际写入设备。
* `pos_type tellp()`：返回当前输出位置的绝对位置。
* `seekp(pos_type)`：设置输出位置到指定的绝对位置。

### `basic_istream` 中定义的方法

* `get(char_type& c)`：读取单个字符，不跳过空白。
* `getline(char_type* s, streamsize n)`：读取一行，最多 `n-1` 个字符并自动补 `\0`。
* `read(char_type* s, streamsize n)`：读取固定长度的字符，数量不足时置 `failbit`。
* `peek()`：返回下一个字符但不取走。
* `ignore(streamsize n = 1)`：跳过 `n` 个字符，常用于丢弃缓冲区里残留的换行。

[c++中istream类的超详细说明](https://www.zhihu.com/tardis/zm/art/365268763?source_id=1003)

### 读取整行

* `std::getline(std::cin, std::string)`：读入一整行到 `std::string`，推荐写法。
* `cin.getline(char* s, streamsize n)`：读入 C 风格字符数组，最多 `n-1` 个字符。

```c++
std::string line;
while (std::getline(std::cin, line)) {
    std::cout << line << '\n';
}
```

> `cin >> x` 会跳过前导空白，并在读完数据后把分隔符留在缓冲区；紧接着调用 `getline` 会读到一个空行，必要时先 `std::cin.ignore()`。

### 状态标志

* `good()` / `eof()` / `fail()` / `bad()`：判断流是否可用、是否到达末尾、是否提取失败或发生严重错误。
* `clear()`：清除状态标志，让流重新可用。
* `rdstate()`：返回当前状态位。

```c++
int n;
if (!(std::cin >> n)) {           // 提取失败（例如输入了字母）
    std::cin.clear();             // 清除 failbit
    std::cin.ignore(1024, '\n');  // 丢弃本行剩余内容
}
```

### 位置指针

* `seekg(pos)` / `seekg(offset, dir)`：设置读位置（g 取自 get）。
* `tellg()`：返回当前读位置。
* `seekp(pos)` / `seekp(offset, dir)`：设置写位置（p 取自 put）。
* `tellp()`：返回当前写位置。
* 定位基准 `dir`：`ios::beg` 流开始、`ios::cur` 当前位置、`ios::end` 流末尾。

位置值是从流起始位置到当前位置的字节数。这些函数主要用于文件流和字符串流。

> 格式化（宽度、精度、进制、对齐）由 `<iomanip>` 中的操纵器提供，见下文 `<iomanip>` 小节。

## `<fstream>`
文件输入输出流，把磁盘文件当作流来读写：`ifstream` 只负责读文件，`ofstream` 只负责写文件，`fstream` 可读可写。

`<fstream>` 头文件包含如下3个类：

* `basic_ofstream`：别名 `ofstream`，用于写文件。
* `basic_ifstream`：别名 `ifstream`，用于读文件。
* `basic_fstream`：别名 `fstream` 既可用于读也可用于写文件。

### 常用函数

```c++
/**
 * 打开文件
 * @param __s 文件名
 * @param __mode 文件打开模式，ofstream 默认为 out，ifstream 默认为 in，fstream 默认为 out|in
 */
void open(const char* __s, ios_base::openmode __mode = ios_base::out);
```

`openmode` 可选值如下：

* `std::ios::app` 追加模块
* `std::ios::ate` 文件打开后定位到文件末尾。（at'e: Anchor(锚定点） To End）
* `std::ios::in` 读模式打开
* `std::ios::out` 写模式
* `std::ios::trunc` 如果文件存在，直接清0

```c++
/**
 * 关闭文件
 */
void close();
```

## `<sstream>`
`string` 格式字符串输入输出流，把 `string` 当作流来读写：`istringstream` 从字符串中读取并解析，`ostringstream` 把数据格式化成字符串，`stringstream` 两者皆可。

## `<strstream>`
`char` 数组格式字符串输入输出流，把 `char` 数组当作流来读写：`istrstream` 从 `char` 数组读取，`ostrstream` 向 `char` 数组写入。

> 这些类已废弃，新代码应改用 `<sstream>`。

```c++
#include <iostream> 
#include <strstream> 

using namespace std; 

int main()  
{ 
    const char *iname = "www.cppblog.com/andxie99"; 
    int arraysize = strlen(iname)+1; 
    istrstream is(iname,arraysize); 

    char *oname = new char(arraysize);
    ostrstream os(oname, arraysize, ios::out);

    for (int i = 0; i < strlen(iname); i++) {
        char temp; 
        is>>temp; 
        os<<temp;
    }

    cout<<oname<<endl;   
}
```

## `<iomanip>`
控制输入输出流中的数据格式。

### 常见应用

**1. 控制浮点数精度**：

```c++
#include <iostream>
#include <iomanip>
#include <sstream>

// 函数定义，参数为浮点数和输出精度
double customPrecision(double value, int precision) {
    // 创建输出流
    std::ostringstream oss;

    // 将浮点数输出到流中，设置精度
    oss << std::fixed << std::setprecision(precision) << value;

    // 从流中获取字符串表示的浮点数
    std::string resultString = oss.str();

    // 将字符串转换为浮点数并返回
    return std::stod(resultString);
}

int main() {
    double number = 3.14159;

    // 默认精度输出
    std::cout << "Default precision: " << number << std::endl;

    // 设置精度为2输出
    std::cout << "Custom precision (2): " << customPrecision(number, 2) << std::endl;

    // 设置精度为4输出
    std::cout << "Custom precision (4): " << customPrecision(number, 4) << std::endl;

    return 0;
}
```

* `std::fixed`：防止浮点数输出时使用科学计数法。
* `std::setprecision`：设置输出流输出浮点数时的精度。

[详解C++中fixed，setprecision\(\),setw\(\)的用法](https://blog.csdn.net/xian__xian/article/details/114017770)

**2. 格式化日期、解析格式化日期**：
```c++
#include <iostream>
#include <iomanip>
#include <ctime>
#include <sstream>

int main() {
    // 获取当前时间
    std::time_t currentTime = std::time(nullptr);

    // 将当前时间转换为 tm 结构
    std::tm *localTime = std::localtime(&currentTime);

    // 输出当前日期和时间
    std::cout << "Current Date and Time: "
              << std::put_time(localTime, "%Y-%m-%d %H:%M:%S")
              << std::endl;

    // 格式化日期字符串
    std::string dateString = "2022-12-31 15:30:00";
    std::tm parsedTime = {};

    // 解析日期字符串
    std::istringstream dateStream(dateString);
    dateStream >> std::get_time(&parsedTime, "%Y-%m-%d %H:%M:%S");

    if (dateStream.fail()) {
        std::cerr << "Failed to parse date string." << std::endl;
    } else {
        // 输出解析后的日期和时间
        std::cout << "Parsed Date and Time: "
                  << std::put_time(&parsedTime, "%Y-%m-%d %H:%M:%S")
                  << std::endl;
    }

    return 0;
}
```

* `std::put_time`：格式化日期字符串并输出。
* `std::get_time`：解析日期字符串并将结果保存到 `tm` 中。

## 附
[C++的iostream标准库介绍+使用详解](https://blog.csdn.net/dgyanyong/article/details/46517467)
