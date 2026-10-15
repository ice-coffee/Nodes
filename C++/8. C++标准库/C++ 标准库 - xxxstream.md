[toc]

## 概述

`c++` 中常用流头文件如下：

* `iostream`(`istream`、`ostream`)：输入输出流基类。
* `fstream`(`ifstream`、`ofstream`)：文件输入输出流。
* `sstream`(`istringstream`、`ostringstream`)：`string` 格式字符串输入输出流。
* `strstream`(`istrstream`、`ostrstream`)：`char` 数组格式字符串输入输出流。

其中 `iostream` 相当于其他流文件的父类，`fstream` 等都是派生自 `iostream`。这些头文件中都包含一个输入流、一个输出流。

在 `iosfwd` 头文件中，定义了这些头文件中所包含类的别名，以方便使用。 `iosfwd` 头文件引用关系：

> `istream、ostream` --> `ios` --> `iosfwd`

## iostream
在对应输入输出流类的定义中，可以看到它们重写了 `<<` 运算符，用于输入或输出各种类型数据。

`basic_ostream` 中定义的方法：

* `put(char_type __c)`：用于将指定的字符写入输出流
* `write(const char_type* __s, streamsize __n)`：用于将指定数量的字符数组写入输出流
* `flush()`：刷新输出流的缓冲区，确保所有等待写入的数据都被实际写入设备。
* `pos_type tellp()`：返回当前输出位置的绝对位置。
* `seekp(pos_type)`：设置输出位置到指定的绝对位置。

`basic_istream` 中定义的方法：

[c++中istream类的超详细说明](https://www.zhihu.com/tardis/zm/art/365268763?source_id=1003)

## fstream
文件输入输出流。

`fstream` 头文件包含如下3个类：

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

四、读取、写入信息
写入信息到文件 ：<<

读取文件内容 ： >> 读取到空格停止

cin.getline() 读取一行信息

cin >> data; 读取遇到空格停止

实例：

```c++
/*
文件读写流（NOI允许使用fstream头文件
*/
#include <iostream>
#include <fstream>
#include <cstring>

using namespace std;

int main(int argc, char **argv)
{
    //从标准输入cin读取一行字符串， 写入到文件
    char data[1024] = {0};
    cin.getline(data, sizeof(data));
    ofstream ofile;
    ofile.open("out.txt", ios::app);
    if (!ofile.is_open())
    {
        cerr << "Error: open file!" << endl;
        return -1;
    }

    ofile << data << endl;
    ofile.clear();
    ofile.close();

    //1. 读取一个单词(遇到空格停止), <<
    ifstream ifile;
    ifile.open("out.txt");
    if (!ifile.is_open())
    {
        cerr << "Error: open file!" << endl;
        return -1;
    }
    memset(data, 0, sizeof(data));
    ifile >> data;
    cout << "data:" << data << endl;
    ifile.close();

    //2. 循环读取文件每一行 getline
    ifile.open("out.txt");
    if (!ifile.is_open())
    {
        cerr << "Error: open file!" << endl;
        return -1;
    }
    while (ifile.getline(data, sizeof(data)))
    {
        cout  << "read line:" << data << endl;
		memset(data, 0, sizeof(data));
    }
    ifile.close();

    return 0;
}
```
五、文件位置指针
`istream` 和 `ostream` 都提供了用于重新定位文件位置指针的成员函数。

* `istream`：`seekg("seek get")` 读文件流
* `ostream`：`seekp("seek put")` 写文件流

seekg 和 seekp 的参数通常是一个长整型。第二个参数可以用于指定查找方向。

* `ios::beg` 流开始位置
* `ios::cur` 流当前位置
* `ios::end` 流末尾位置

文件位置指针是一个整数值，指定了从文件的起始位置到指针所在位置的字节数。下面是关于定位 "get" 文件位置指针的实例：

```c++
// 定位到 fileObject 的第 n 个字节（假设是 ios::beg）
ifile.seekg(n);
 
// 把文件的读指针从 fileObject 当前位置向后移 n 个字节
ifile.seekg(n, ios::cur);
 
// 把文件的写指针从 fileObject 末尾往回移 n 个字节
ofile.seekp(n, ios::end);
 
// 定位到 fileObject 的末尾
ofile.seekp(0, ios::end);
```

## sstream
`string` 格式字符串输入输出流。

## strstream
`char` 数组格式字符串输入输出流。

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

## iomanip
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
