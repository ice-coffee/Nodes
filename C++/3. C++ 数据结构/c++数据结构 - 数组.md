[toc]
> `c++` 中建议使用 `std::vector` 或 `std::array` 表示数组。

以 `int` 类型数组为例。

## 内置数组
### 声明
**`堆栈声明：`**
```c++
int a[10];

// 设置数组元素默认值
int a[10]{0};
```

**`堆声明：`**
```c++
int* a = new int[10]{0};
```

### 初始化
声明后初始化：
```c++
int a[10];
for (int i = 0; i < 10; ++i)
{
    a[i] = i + 1;
}
```

声明时初始化：
```c++
int a[10]{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
```

### 销毁
```c++
delete[] a;
```

### 将数组传递给函数
将数组传递给函数时，该数组将作为指向第一个元素的指针传递，无论它是基于堆栈的数组还是基于堆的数组。将数组传递给函数时，始终必须在单独的参数中指定元素数量。 若要防止函数修改元素，请将参数指定为指向 `const` 元素的指针。

```c++
void process(const int *a, size_t len)
{
    std::cout << "process:\n";
    for (size_t i = 0; i < len; ++i)
    {
        // do something with p[i]
    }
}
```

## std::vector
[C++ vector 容器浅析](https://www.runoob.com/w3cnote/cpp-vector-container-analysis.html)

> `vector` 是一个`动态大小`数组的`顺序`容器，可以存放`任意类型`数据。

`vector` 特性：
* 动态大小
* 顺序
* 任意类型

### 使用
头文件：
```c++
#include <vector>
```

构造函数：

* `vector()`：创建一个空vector
* `vector(int nSize)`：创建一个vector,元素个数为nSize
* `vector(int nSize, const T& t)`：创建一个vector，元素个数为nSize，且值均为t
* `vector(const vector&)`：复制构造函数
* `vector(begin,end)`：复制[begin,end)区间内另一个数组的元素到vector中

### 常用函数
#### 遍历
* `iterator vector:begin()`：返回指向第一个元素的迭代器。
* `iterator vector:end()`：返回指向尾后位置（末尾元素的下一个位置）的迭代器。
* `const_iterator vector:cbegin()`：返回指向第一个元素的 `const` 迭代器。
* `const_iterator vector:cend()`：返回指向尾后位置（末尾元素的下一个位置）的 `const` 迭代器。

```c++
#include <iostream>
#include <vector>

int main()
{
    std::vector<int> obj{1, 2, 3, 4, 5};

    // 第一种遍历方式：使用下标
    for (size_t i = 0; i < obj.size(); i++)
    {
        std::cout << obj[i] << std::endl;
    }
    // 第二种遍历方式：使用迭代器
    for (auto iter = obj.begin(); iter != obj.end(); iter++)
    {
        std::cout << *iter << std::endl;
    }
    // 第三种遍历方式：使用范围for循环
    for (auto &&i : obj)
    {
        std::cout << i << std::endl;
    }
    // 第四种遍历方式：使用for_each
    std::for_each(obj.begin(), obj.end(), [](auto &&i) { 
        std::cout << i << std::endl
    });
    return 0;
}
```

#### 添加元素

| 函数 | 说明 | 是否产生额外对象 |
| --- | --- | --- |
| `insert(const_iterator position, const value_type& x)` | 在指定位置插入元素 | 是 |
| `vector:push_back(const value_type& x)` | 将元素添加到向量的末尾 | 是 |
| `emplace(const_iterator position, args...)` | 在指定位置就地构造元素，可以接受构造函数的参数 | 否 |
| `emplace_back(args...)` | 在向量的末尾就地构造元素，可以接受构造函数的参数 | 否 |

```c++
#include <iostream>
#include <vector>

class MyClass
{
public:
    MyClass(std::string name):name(name){};
    std::string name;
};

int main()
{
    std::vector<MyClass> obj;
    obj.insert(obj.begin(), MyClass("test1"));
    obj.push_back(MyClass("test2"));
    obj.emplace_back("test3");

    for (auto &item : obj)
    {
        std::cout << item.name << std::endl;
    }

    return 0;
}
```

#### 访问元素

* `at(index)`：按索引访问元素，会进行边界检查。
* `[]`：按索引访问元素，不进行边界检查，如果索引越界可能导致未定义行为。
* `front()`：访问向量的第一个元素。
* `back()`：访问向量的最后一个元素。

```c++
#include <iostream>
#include <vector>

int main()
{
	std::vector<int> obj{1, 2, 3, 4, 5};

	std::cout << obj.at(1) << std::endl;
	std::cout << obj.front() << std::endl;
	std::cout << obj.back() << std::endl;
	return 0;
}
```

#### 删除元素

* `pop_back()`：删除向量的最后一个元素。
* `erase(const_iterator position)`：删除指定位置的元素。
* `erase(const_iterator first, const_iterator last)`：删除指定范围内的元素。
* `remove(_ForwardIterator __first, _ForwardIterator __last, const _Tp& __value_)`：将指定元素移动到数组末尾并返回元素的位置迭代器。
* `remove_if(_ForwardIterator __first, _ForwardIterator __last, _Predicate __pred)`：将匹配的元素的元素都移动到数组末尾并返回被移动的首个元素的位置迭代器。

#### 容量和大小

* `size()`：返回向量中的元素数量。
* `empty()`：检查向量是否为空。
* `capacity()`：返回向量当前的容量。
* `reserve(new_capacity)`：设置向量的容量，可以用来预分配内存以减少动态分配的次数。

#### 清空和重置

* `clear()`：清空向量中的所有元素。
* `resize(new_size)`：重新调整向量的大小。
* `resize(new_size, value)`：重新调整向量的大小，并用指定的值填充新元素。

#### 查找元素

* `find(_InputIterator __first, _InputIterator __last, const _Tp& __value_)`：用于查找元素第一次出现的位置。
* `count(_InputIterator __first, _InputIterator __last, const _Tp& __value_)`：统计指定值在向量中出现的次数。
* `count_if...`：...。

这两个函数都是 `algorithm` 头文件的函数。

```c++
#include <iostream>
#include <algorithm>
#include <vector>
 
int main()
{
    using namespace std;
 
    vector<int> vec;
 
    vec.push_back(1);
    vec.push_back(2);
    vec.push_back(3);
 
    vector<int>::iterator it = find(vec.begin(), vec.end(), 2);
 
    if (it != vec.end())
        cout<<*it<<endl;
    else
        cout<<"can not find"<<endl;
 
    return 0;
}
```

#### 范围操作

* `std::for_each(begin, end, function)`：使用函数操作遍历向量的元素。
* `std::sort(begin, end)`：对向量的元素进行排序。

```c++
#include <iostream>
#include <algorithm>
#include <vector>

int main()
{
    std::vector<int> obj{1, 2, 3, 4, 5};
    std::sort(obj.begin(), obj.end(), [](int first, int second){
        return first > second;
    });
    for (auto &&i : obj)
    {
        std::cout << i << std::endl;
    }
    return 0;
}
```

#### 拷贝

* `std::copy()`：拷贝容器
* `std::copy_if()`：根据
* `assign(InputIterator first, InputIterator last)`：

#### 其他

* `swap(other_vector)`：交换两个 `vector` 的内容。

### 示例
```c++
#include <iostream>
#include <algorithm>
#include <vector>

std::vector<int> obj;

// 使用 find() 查找元素
bool find_is_exit(int value) 
{
    auto iter = find(obj.begin(), obj.end(), value);
    return iter != obj.end();
}

// 使用 erase() 移除元素
void erase_ele(int value) 
{

    for (auto iter = obj.begin(); iter != obj.end();)
    {
        if (*iter == value)
        {
            iter = obj.erase(iter);
        } 
        else
        {
            iter++;
        }
    }
}

// 使用 erase() + remove() 移除元素
void remove_ele(int value) 
{
    std::vector<int>::iterator iter = std::remove(obj.begin(), obj.end(), value);
    obj.erase(iter, obj.end());
}

// 使用 erase() + remove_if() 移除元素
void remove_ele_if() 
{
    std::vector<int>::iterator iter = std::remove_if(obj.begin(), obj.end(), [](int ele){
        return ele % 2 == 0;
    });
    obj.erase(iter, obj.end());
}

// 遍历
void print_vector()
{
    for (auto iter = obj.begin(); iter != obj.end(); iter++)
    {
        if (std::next(iter) != obj.end())
        {
            std::cout << *iter << ",";
        }
        else
        {
            std::cout << *iter << std::endl;
        }
    }
}

void print_vector_c11()
{
    for (const int value : obj)
    {
        if (std::next(iter) != obj.end())
        {
            std::cout << *iter << ",";
        }
        else
        {
            std::cout << *iter << std::endl;
        }
    }
}

int main()
{
    // push_back(elem)在数组最后添加数据
    for(int i = 0; i < 10; i++)  
    {
        obj.push_back(i);  
    }

    bool is_exit = find_is_exit(4);
    std::cout << "find_is_exit:" << is_exit << std::endl;

    remove_ele(4);
    print_vector();
    remove_ele(5);
    print_vector();
    remove_ele_if();
    print_vector();

    return 0;
}
```
> **`注意`**：示例中使用`vector`内元素类型为基本数据类型，若类型为`class`时应在遍历过程中使用引用`&`。

### 扩展
#### push_back 时调用了几次拷贝函数、移动函数

```c++
#include <iostream>
#include <vector>

class MyObject
{
public:
    MyObject(int value);
    MyObject(const MyObject &obj);
    MyObject(MyObject &&obj);
    int32_t length;
};

MyObject::MyObject(int value) {
    length = value;
    std::cout << "初始化" << length << std::endl;
}

MyObject::MyObject(const MyObject &obj)
{
    std::cout << "拷贝" << obj.length << std::endl;
    this->length = obj.length;
}
MyObject::MyObject(MyObject &&obj)
{
    std::cout << "移动" << obj.length << std::endl;
    this->length = obj.length;
    obj.length = 0;
}

int main(int argc, char const *argv[])
{
    std::vector<MyObject> v1;
    v1.push_back(MyObject{1});
    std::cout << "----" << std::endl;
    v1.push_back(MyObject{2});
    std::cout << "----" << std::endl;
    v1.push_back(MyObject{3});
    std::cout << "----" << std::endl;

    return 0;
    }

输出：
初始化1
移动1
----
初始化2
移动2
拷贝1
----
初始化3
移动3
拷贝1
拷贝2
```
> **`结论`**：

#### std::remove_if() 函数说明
```c++
template <class _ForwardIterator, class _Predicate>
_ForwardIterator
remove_if(_ForwardIterator __first, _ForwardIterator __last, _Predicate __pred)
{
    __first = _VSTD::find_if<_ForwardIterator, typename add_lvalue_reference<_Predicate>::type>
                           (__first, __last, __pred);
    if (__first != __last)
    {
        _ForwardIterator __i = __first;
        while (++__i != __last)
        {
            if (!__pred(*__i))
            {
                *__first = _VSTD::move(*__i);
                ++__first;
            }
        }
    }
    return __first;
}
```

## std::array
[C++ array\(STL array\)容器用法详解](http://c.biancheng.net/view/6688.html)

和 `vector` 不同的是 `array` 的大小是固定的，无法动态的扩展或收缩，这也就意味着，在使用该容器的过程无法借由增加或移除元素而改变其大小，它只允许访问或者替换存储的元素。

### 使用
头文件：
```c++
#include <array>
```

创建具有 10 个 `double` 类型元素的 `array` 容器：
```c++
std::array<double, 10> values;
```

初始化：
```c++
// 所有元素初始化为 0 
std::array<double, 10> values {};

// 初始化前四个元素，其他元素初始化为默认值 0
std::array<double, 10> values {0.5,1.0,1.5,2.0};
```

示例：
```c++
#include <iostream>
#include <array>
using namespace std;

int main()
{
    std::array<int, 4> values{};
    //初始化 values 容器为 {0,1,2,3}
    for (int i = 0; i < values.size(); i++) {
        values.at(i) = i;
    }
    //使用 get() 重载函数输出指定位置元素
    cout << get<3>(values) << endl;
    //如果容器不为空，则输出容器中所有的元素
    if (!values.empty()) {
        for (auto val = values.begin(); val < values.end(); val++) {
            cout << *val << " ";
        }
    }
}
```
