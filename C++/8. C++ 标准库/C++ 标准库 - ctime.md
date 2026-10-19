[toc]

## `<ctime>`

### 类型

* `time_t`：`time_t` 实际上是 `long` 类型的别名，用于保存从1970年1月1日零时开始流逝的秒数。
* `struct tm`：用于表示日期和时间的结构体，包括秒、分钟、小时、日期等成员。

### 函数

#### 1. time
获取从1970年1月1日零时开始流逝的秒数。
```c++
time_t time(time_t *);
```
使用：
```c++
#include <iostream>
#include <ctime>

using namespace std;

int main() {

    // 获取当前时间
    // time_t currentTime;
    // time(&currentTime);
    time_t currentTime = time(nullptr);

    cout << currentTime << endl;

    return 0;
}
```

#### 2. localTime

将 `time_t` 类型的时间值转换为 `tm` 类型;

```c++
struct tm *localtime(const time_t *);
```

## chrono
在 `chrono` 引入了 `ctime` 头文件。

### clock
`chrono` 中包含如下 `clock`：

* `system_clock`：表示当前系统时间的时钟，适合用于与日历时间和实际日期时间相关的操作；
* `steady_clock`：不受系统时间调整影响的时钟，它提供了一个稳定的、递增的时间点序列。适合用于测量时间间隔、计时器等场景；

`clock` 的主要方法有3个，分别是：

```c++
// 获取当前时间
static time_point now() _NOEXCEPT;
// 将系统时间转变为std::time_t类型
static time_t     to_time_t  (const time_point& __t) _NOEXCEPT;
// 将std::time_t类型转换为系统时间点
static time_point from_time_t(time_t __t) _NOEXCEPT;
```

因为它们都是静态的方法所以可以使用 `::` 直接调用。

### duration
`duration` 是一个表示一段时间的类，定义如下：

```c++
/**
 * _Rep：多少个 _Period
 * _Period：时间单位
 */
template <class _Rep, class _Period>
class duration
```

时间单位常用 `ratio` 类表示，定义如下：

```c++
/**
 * _Num：分母
 * _Den：分子，默认为1
 * 两者相除的值为秒数
 */
template <intmax_t _Num, intmax_t _Den = 1>
class ratio
```

例如：`Num` 为60，`Denom` 为1，那么表示 60 / 1s，也即相当于1min。

已定义 `duration`：

```c++
typedef duration<long long,         nano> nanoseconds;
typedef duration<long long,        micro> microseconds;
typedef duration<long long,        milli> milliseconds;
typedef duration<long long              > seconds;
typedef duration<     long, ratio<  60> > minutes;
typedef duration<     long, ratio<3600> > hours;
```

`duration` 还重载了运算符，可以进行 `+、-` 等运算。

常用方法

* `count()`：`duration` 类方法，返回 `_Rep` 的值。
* `duration_cast(const duration)`：`chrono` 命名空间方法，用以转换 `duration` 单位。例如将秒转换为毫秒，示例在下方。

### time_point

`time_since_epoch()`：`time_point` 类方法，用于获取一个时间点（time point）相对于纪元（epoch）的时间间隔（duration）

`time_point_cast()`：强转函数，`chrono` 命名空间方法，用于在不同的时钟（clock）之间转换时间点。

实现和 `System.currentTime()` 一样的功能：

```c++
#include <iostream>
#include <chrono>

int main() {
    // 获取当前时间点
    auto now = std::chrono::system_clock::now();

    // 将时间点转换为毫秒
    auto duration = now.time_since_epoch();
    auto millis = std::chrono::duration_cast<std::chrono::milliseconds>(duration);

    // 输出毫秒级别的当前时间
    std::cout << "Current time in milliseconds: " << millis.count() << " ms\n";

    return 0;
}
```
