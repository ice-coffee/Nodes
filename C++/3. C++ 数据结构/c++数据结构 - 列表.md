### std::list
`std::list` 容器是双向链表结构，也就是说每个元素都配备了 `2` 个指针，分别指向它的前一个元素和后一个元素。

对比于其它容器，`list` 插入、删除效率高（时间复杂度为 `O(1)`）。但是不能像 `array` 和 `vector` 那样，通过 `容器对象名[6]` 直接访问元素，正确的做法是从容器中第一个元素或最后一个元素开始遍历容器，直到找到该位置。

导入头文件：
```c++
#include <list>
```

```c++
#include <iostream>
#include <list>

int main() {
    // 声明初始化
    // 1.空 list
    std::list<int> myList;
    // 2.初始化元素个数：std::list<int> values(10);
    // 3.初始化元素个数并指定初始值：std::list<int> values(10, 5);
    // 4.列表初始化：std::list<int> myList({1, 2, 3, 4, 5});

    // 遍历
    // 1.迭代器遍历
    for(std::list<int>::iterator it = myList.begin(); it != myList.end(); it++) {
        std::cout<<*it<<std::endl;
    }
    // 2.等价于
    for(auto it = myList.begin(); it != myList.end(); it++) {
        std::cout<<*it<<std::endl;
    }
    // 3.c++ 11 或更高版本
    for (const auto& element : myList) {
        std::cout << element << " ";
    }

    return 0;
}
```

#### 数组转list

```c++
#include <iostream>
#include <vector>
#include <list>

int main() {
    // 假设有一个数组
    int arr[] = {1, 2, 3, 4, 5};

    // 获取数组的长度
    int arrSize = sizeof(arr) / sizeof(arr[0]);

    // 使用 std::vector 将数组转换为列表
    std::vector<int> vec(arr, arr + arrSize);
    
    // 使用 std::list 构造函数将 std::vector 转换为 std::list
    std::list<int> myList(vec.begin(), vec.end());
    // std::list<int> myList(arr, arr + arrSize);

    // 输出转换后的列表元素
    for (const auto& element : myList) {
        std::cout << element << " ";
    }

    return 0;
}
```

遍历过程中移除元素：
```c++
#include <iostream>
#include <list>

int main() {
    std::list<int> myList = {1, 2, 3, 4, 5};

    // 使用迭代器遍历 std::list，并在遍历过程中删除元素
    for (auto it = myList.begin(); it != myList.end(); /* no increment here */) {
        if (*it % 2 == 0) {
            it = myList.erase(it);  // erase 返回下一个迭代器
        } else {
            ++it;
        }
    }

    // 输出遍历结果
    for (const auto& element : myList) {
        std::cout << element << " ";
    }

    return 0;
}
```

#### 常用函数

插入元素：
```c++
// 在指定位置插入元素
auto it = std::find(myList.begin(), myList.end(), 3);
if (it != myList.end()) {
    myList.insert(it, 100);  // 在迭代器指定的位置插入元素
}
// 在开头插入元素
myList.push_front(200);
// 在结尾插入元素
myList.push_back(300);
```

| 成员函数 | 功能 |
| --- | --- |
| begin() | 返回指向容器中第一个元素的双向迭代器。 |
| end() |   返回指向容器中最后一个元素所在位置的下一个位置的双向迭代器。 |
| rbegin() |    返回指向最后一个元素的反向双向迭代器。 |
| rend() |  返回指向第一个元素所在位置前一个位置的反向双向迭代器。 |
| empty() | 判断容器中是否有元素，若无元素，则返回 true；反之，返回 false。 |
| size() |  返回当前容器实际包含的元素个数。 |
| front() | 返回第一个元素的引用。 |
| back() |  返回最后一个元素的引用。 |
| assign() |    用新元素替换容器中原有内容。 |
| emplace_front() | 在容器头部生成一个元素。该函数和 push_front() 的功能相同，但效率更高。 |
| push_front() |    在容器头部插入一个元素。 |
| pop_front() | 删除容器头部的一个元素。 |
| emplace_back() |  在容器尾部直接生成一个元素。该函数和 push_back() 的功能相同，但效率更高。 |
| push_back() | 在容器尾部插入一个元素。 |
| pop_back() |  删除容器尾部的一个元素。 |
| emplace() |   在容器中的指定位置插入元素。该函数和 insert() 功能相同，但效率更高。 |
| insert() |    在容器中的指定位置插入元素。 |
| erase() | 删除容器中一个或某区域内的元素。 |
| swap() |  交换两个容器中的元素，必须保证这两个容器中存储的元素类型是相同的。 |
| resize() |    调整容器的大小。 |
| clear() | 删除容器存储的所有元素。 |
| splice() |    将一个 list 容器中的元素插入到另一个容器的指定位置。 |
| remove(val |) 删除容器中所有等于 val 的元素。 |
| remove_if() | 删除容器中满足条件的元素。 |
| merge() | 合并两个事先已排好序的 list 容器，并且合并之后的 list 容器依然是有序的。 |
| sort() |  通过更改容器中元素的位置，将它们进行排序。 |
