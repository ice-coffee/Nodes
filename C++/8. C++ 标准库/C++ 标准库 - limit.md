`std::numeric_limits` 是 C++ 标准库中的一个模板类，用于获取 **数值类型的各种属性**，如最大值、最小值、是否有符号、是否支持无穷大等。

它定义在头文件：

```cpp
#include <limits>
```

适用类型示例：

* 整型：`int`, `short`, `long`, `uint32_t`, `int64_t`
* 浮点型：`float`, `double`, `long double`

### 常用函数

| 成员函数或属性        | 说明                     |
| -------------- | ---------------------- |
| `min()`        | 最小正值（注意，不是最小负数）        |
| `max()`        | 最大值                    |
| `lowest()`     | 最小负数值（C++11 起）         |
| `epsilon()`    | 浮点类型最小可分辨差值（仅对浮点类型有意义） |
| `is_signed`    | 是否有符号                  |
| `is_integer`   | 是否是整数类型                |
| `is_exact`     | 是否精确（整数是精确的，浮点不是）      |
| `has_infinity` | 是否支持无穷大（浮点支持）          |
| `infinity()`   | 返回无穷大值                 |
| `quiet_NaN()`  | 返回一个非抛出式的 NaN 值        |
| `digits`       | 有效位数（二进制位数）            |
| `digits10`     | 有效十进制位数                |

**`示例：`**

```cpp
#include <iostream>
#include <limits>

int main() {
    std::cout << "int max: " << std::numeric_limits<int>::max() << std::endl;
    std::cout << "int min: " << std::numeric_limits<int>::min() << std::endl;
    std::cout << "unsigned int max: " << std::numeric_limits<unsigned int>::max() << std::endl;

    std::cout << "float lowest: " << std::numeric_limits<float>::lowest() << std::endl;
    std::cout << "float max: " << std::numeric_limits<float>::max() << std::endl;
    std::cout << "float epsilon: " << std::numeric_limits<float>::epsilon() << std::endl;

    std::cout << "double is signed: " << std::numeric_limits<double>::is_signed << std::endl;

    return 0;
}
```

**`注意事项：`**

* `min()` 对于整型返回的是**最小可表示值**（负数）。
* 对于浮点类型，`min()` 返回的是 **最小正数**（非 0），若要最小负数应使用 `lowest()`。

```cpp
std::numeric_limits<int>::min();      // -2147483648
std::numeric_limits<float>::min();    // 1.17549e-38
std::numeric_limits<float>::lowest(); // -3.40282e+38
```


### 使用示例：边界检查

```cpp
template<typename T>
bool will_overflow(T a, T b) {
    return (b > 0 && a > std::numeric_limits<T>::max() - b);
}
```
