### 作用
`std::function` 是一个可用于存储任何可调用对象（函数、函数指针、成员函数、lambda 表达式等）的模板类。

### 引入
```c++
#include <functional> 
```

### 定义
```c++
template<class _Rp, class ..._ArgTypes>
class _LIBCPP_TEMPLATE_VIS function<_Rp(_ArgTypes...)>
```

### 示例
存储函数指针：

```c++
#include <iostream>
#include <functional>

// 函数指针的类型
int add(int a, int b) {
    return a + b;
}

int main() {
    // 使用 std::function 存储函数指针
    std::function<int(int, int)> funcPtr = add;

    // 调用存储的函数指针
    int result = funcPtr(2, 3);
    std::cout << "Result: " << result << std::endl;

    return 0;
}
```

存储成员函数：

```c++
#include <iostream>
#include <functional>

class MyClass {
public:
    int multiply(int a, int b) {
        return a * b;
    }
};

int main() {
    MyClass obj;

    // 使用 std::function 存储成员函数
    std::function<int(MyClass&, int, int)> memberFunc = &MyClass::multiply;

    // 调用存储的成员函数
    int result = memberFunc(obj, 2, 3);
    std::cout << "Result: " << result << std::endl;

    return 0;
}
```

存储 lambda 表达式：

```c++
#include <iostream>
#include <functional>

int main() {
    // 使用 std::function 存储 lambda 表达式
    std::function<int(int, int)> lambdaFunc = [](int a, int b) {
        return a * b;
    };

    // 调用存储的 lambda 表达式
    int result = lambdaFunc(2, 3);
    std::cout << "Result: " << result << std::endl;

    return 0;
}
```

作为参数：
```c++
#include <iostream>
#include <functional>

// 定义一个函数，接受一个函数对象作为参数
void applyFunction(std::function<int(int, int)> func, int a, int b) {
    int result = func(a, b);
    std::cout << "Result: " << result << std::endl;
}

// 定义一个函数对象类，用于相加两个整数
struct Add {
    int operator()(int a, int b) const {
        return a + b;
    }
};

int main() {
    // 使用 lambda 表达式创建一个函数对象
    auto multiply = [](int x, int y) { return x * y; };

    // 使用函数对象作为参数调用 applyFunction 函数
    applyFunction(Add(), 3, 4); // 调用 Add 函数对象
    applyFunction(multiply, 5, 6); // 调用 lambda 函数对象

    return 0;
}

```
