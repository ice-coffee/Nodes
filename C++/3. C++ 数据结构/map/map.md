### std::map

导入头文件：
```c++
#include <map>
```

```c++
#include <iostream>
#include <map>

int main() {
    // 声明，初始化
    std::map<int, std::string> myMap {
        {1, "One"},
        {2, "Two"}
    };

    // 插入数据
    // 1.使用 insert 插入键值对
    myMap.insert(std::make_pair(3, "Three"));
    // 2.或者使用 std::pair 构造键值对
    myMap.insert(std::pair<int, std::string>(4, "Four"));
    // 3.使用 []
    myMap[4] = "Four";

    // 遍历
    // 1.迭代器遍历
    std::map<int, std::string>::iterator it;
    for (it = myMap.begin(); it != myMap.end(); ++it) {
        std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
    }
    // 2.等价于，使用 auto 替代迭代器类型
    for (auto it = myMap.begin(); it != myMap.end(); ++it) {
        std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
    }
    // 3.C++11 或更高版本
    for (const auto& pair : myMap) {
        std::cout << "Key: " << pair.first << ", Value: " << pair.second << std::endl;
    }

    return 0;
}
```

遍历过程中移除元素：
```c++
for (auto it = myMap.begin(); it != myMap.end(); /* no increment here */) {
    if (it->first == 2) {
        it = myMap.erase(it);  // erase返回下一个迭代器
    } else {
        ++it;
    }
}
```

#### 常用函数

* `erase()`：删除元素，它有多个重载方法，入参可以是 `key` 值，也可以迭代器。

```c++
myMap.erase(1);  // 删除键为1的元素
auto it = myMap.find(2);
if (it != myMap.end())
    myMap.erase(it);  // 删除迭代器指向的元素
```

* `clear()`：清除元素。
* `find()`：查找指定键的元素，返回指向该元素的迭代器。

```c++
auto it = myMap.find(1);
if (it != myMap.end()) {
    // 元素找到
    std::cout << "Value for key 1: " << it->second << std::endl;
} else {
    // 元素未找到
    std::cout << "Key 1 not found." << std::endl;
}
```

* `size()`：返回容器中元素的个数。
* `empty()`：判断容器是否为空。
* `begin()`：返回指向容器中第一个元素的迭代器。
* `end()`：返回指向容器中最后一个元素所在位置的下一个位置的迭代器。
