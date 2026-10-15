---
id: 20260704-001
tags: [C++, STL, 哈希表, 关联容器]
aliases: [unordered_map, std unordered map, 哈希映射, 无序映射, hash map]
created: 2026-07-04
updated: 2026-07-04
source: ""
status: draft
---

# std::unordered_map

## 一句话定义
`std::unordered_map` 是 C++ 标准库中基于哈希表实现的键值对关联容器，用于通过唯一 key 快速查找、插入、更新和删除 value。

## 核心理解
- **是什么**：一个保存 `Key -> T` 映射关系的无序关联容器，key 唯一，底层通常按 bucket 和哈希冲突链组织元素。
- **为什么需要它**：当代码更关心“按 key 快速定位数据”，而不是“按 key 排序遍历”时，哈希表比树结构更直接。
- **它解决了什么问题**：用平均接近 O(1) 的复杂度完成查找、插入和删除，适合字典、索引、缓存、频次统计和去重辅助结构。

## 详细解释
### 能力分类总览
`std::unordered_map<Key, T, Hash, KeyEqual, Allocator>` 的核心能力可以按几类理解：

- **元素访问**：`operator[]`、`at()`。
- **查找判断**：`find()`、`contains()`、`count()`、`equal_range()`。
- **插入更新**：`insert()`、`emplace()`、`try_emplace()`、`insert_or_assign()`。
- **删除与清空**：`erase()`、`clear()`。
- **容量管理**：`size()`、`empty()`、`reserve()`、`rehash()`。
- **哈希策略**：`bucket_count()`、`load_factor()`、`max_load_factor()`。
- **自定义行为**：自定义 `Hash` 与 `KeyEqual`，让结构体、组合 key 等类型可以作为 key。

### 工作机制
容器会用哈希函数把 key 转换成哈希值，再根据哈希值定位到某个 bucket。不同 key 可能落到同一个 bucket，这叫哈希冲突；发生冲突时，容器会继续用相等比较函数判断两个 key 是否真的相同。

因此，`std::unordered_map` 的正确性依赖两个条件：

- 如果两个 key 相等，那么它们的哈希值必须一致。
- `Hash` 和 `KeyEqual` 的逻辑必须匹配，不能一个按字段 A 判断，一个按字段 B 计算。

### 无序的含义
`unordered` 表示容器不按 key 排序，也不保证遍历顺序稳定。插入、删除、rehash、实现差异、标准库版本变化，都可能改变遍历顺序。

如果业务逻辑依赖稳定输出顺序、按 key 升序遍历或范围查询，`std::unordered_map` 通常不是合适选择。

### 负载因子与 rehash
负载因子可以粗略理解为“每个 bucket 平均装了多少元素”：

```cpp
load_factor = size() / bucket_count()
```

当元素数量增长导致负载因子超过 `max_load_factor()`，容器可能触发 rehash：重新分配 bucket，并把所有元素重新分布到新 bucket 中。rehash 能降低冲突概率，但会带来一次性开销，并使所有迭代器失效。

### 复杂度
`std::unordered_map` 的查找、插入、删除平均复杂度接近 O(1)，但最坏情况可能退化到 O(n)。退化通常来自哈希冲突过多、哈希函数质量差、bucket 过少，或者 key 被恶意构造。

## 常用用法
### 基础声明与初始化
作用：创建 key 到 value 的映射，适合字典、配置表、ID 索引等场景。

```cpp
#include <unordered_map>
#include <string>

std::unordered_map<std::string, int> score = {
    {"alice", 90},
    {"bob", 85}
};
```

注意：遍历 `score` 时，输出顺序不一定是 `alice`、`bob` 的插入顺序。

### operator[]：访问、插入默认值、更新
作用：返回 key 对应 value 的引用；如果 key 不存在，会先插入一个默认构造的 value。

```cpp
std::unordered_map<std::string, int> freq;
++freq["apple"];
freq["banana"] = 3;
```

适合频次统计、累加、需要“没有就创建”的场景。风险是它会修改容器，不适合只做存在性检查。

### at()：访问已存在的 key
作用：只访问已有 key；如果 key 不存在，会抛出 `std::out_of_range`。

```cpp
const std::unordered_map<std::string, int> score = {{"alice", 90}};
int alice_score = score.at("alice");
```

适合 key 应该存在、缺失代表逻辑错误的场景。对于不确定是否存在的 key，通常先用 `find()` 或 `contains()`。

### find()：查找且不修改容器
作用：查找 key 是否存在，存在时返回迭代器，不存在时返回 `end()`。

```cpp
auto it = score.find("alice");
if (it != score.end()) {
    int value = it->second;
}
```

这是 C++17 及更早版本里最常见的存在性判断方式，也适合需要拿到 value 的场景。

### contains()：只判断是否存在
作用：C++20 起提供，语义比 `find() != end()` 更直接。

```cpp
if (score.contains("alice")) {
    // key exists
}
```

注意：`contains()` 只返回 `bool`，如果后续还要访问 value，`find()` 可以避免二次查找。

### insert() / emplace()：只在 key 不存在时插入
作用：插入新键值对；如果 key 已存在，不覆盖旧 value。

```cpp
std::unordered_map<std::string, int> score;

auto [it1, inserted1] = score.insert({"alice", 90});
auto [it2, inserted2] = score.emplace("bob", 85);
```

返回值通常包含迭代器和是否插入成功的布尔值。`emplace()` 可以原地构造元素，但如果 key 已存在，构造参数是否仍会产生额外成本和具体实现有关；需要避免无谓构造时优先看 `try_emplace()`。

### try_emplace()：key 不存在时才构造 value
作用：C++17 起提供，只有在 key 不存在时才用参数构造 value。

```cpp
std::unordered_map<int, std::string> users;
users.try_emplace(1, "alice");
users.try_emplace(1, "ignored");  // key 已存在，不覆盖
```

适合 value 构造成本较高、不可拷贝或不希望 key 已存在时浪费构造成本的场景。

### insert_or_assign()：不存在则插入，存在则覆盖
作用：C++17 起提供，把“插入或更新”的意图写清楚。

```cpp
std::unordered_map<std::string, int> score;
score.insert_or_assign("alice", 90);
score.insert_or_assign("alice", 95);  // 覆盖旧值
```

它比 `operator[] = value` 更明确，也不要求 mapped type 必须默认构造。

### erase()：删除元素
作用：按 key、迭代器或迭代器范围删除元素。

```cpp
score.erase("bob");

for (auto it = score.begin(); it != score.end(); ) {
    if (it->second < 60) {
        it = score.erase(it);
    } else {
        ++it;
    }
}
```

按迭代器删除时，使用 `erase()` 的返回值继续遍历，可以避免使用已经失效的迭代器。

### reserve() / rehash()：提前控制 bucket
作用：批量插入前预留容量，减少多次扩容和 rehash 的成本。

```cpp
std::unordered_map<int, std::string> id_to_name;
id_to_name.reserve(10000);

for (const auto& user : users) {
    id_to_name.emplace(user.id, user.name);
}
```

`reserve(n)` 表示希望容器能容纳大约 `n` 个元素；`rehash(n)` 表示希望 bucket 数至少为 `n`。日常批量插入更常用 `reserve()`。

### 自定义 key：提供 hash 与相等比较
作用：让自定义结构体、组合 key、坐标等类型可以作为 key。

```cpp
struct Point {
    int x;
    int y;

    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

struct PointHash {
    std::size_t operator()(const Point& p) const {
        std::size_t h1 = std::hash<int>{}(p.x);
        std::size_t h2 = std::hash<int>{}(p.y);
        return h1 ^ (h2 << 1);
    }
};

std::unordered_map<Point, std::string, PointHash> names;
names[{1, 2}] = "start";
```

注意：如果 `operator==` 认为两个 `Point` 相等，`PointHash` 必须为它们生成相同哈希值，否则容器行为会不符合预期。

## 关键要点
- `std::unordered_map` 的 key 唯一，value 可修改；一个 key 对多个 value 时考虑 `std::unordered_multimap` 或 `std::unordered_map<Key, std::vector<T>>`。
- 平均查找、插入、删除接近 O(1)，但最坏情况可能退化到 O(n)。
- 它不保证遍历顺序，不能把输出顺序当作业务语义。
- `operator[]` 会在 key 不存在时插入默认值；只查找时优先用 `find()` 或 `contains()`。
- rehash 会让所有迭代器失效；批量插入前可以用 `reserve()` 降低 rehash 次数。

## 例子与边界
### 正例：统计单词出现次数
```cpp
std::unordered_map<std::string, int> freq;

for (const auto& word : words) {
    ++freq[word];
}
```

这里 `operator[]` 很合适：单词第一次出现时会插入默认值 `0`，随后自增为 `1`。

### 典型用法：建立 ID 到对象的索引
```cpp
std::unordered_map<int, User> users_by_id;
users_by_id.reserve(users.size());

for (const auto& user : users) {
    users_by_id.emplace(user.id, user);
}

auto it = users_by_id.find(query_id);
if (it != users_by_id.end()) {
    use(it->second);
}
```

适合需要频繁按 ID 查找对象的场景。`reserve()` 可以减少批量构建索引时的扩容成本。

### 典型用法：缓存计算结果
```cpp
std::unordered_map<int, int> cache;

int fib(int n) {
    if (n <= 1) {
        return n;
    }

    auto it = cache.find(n);
    if (it != cache.end()) {
        return it->second;
    }

    int value = fib(n - 1) + fib(n - 2);
    cache.emplace(n, value);
    return value;
}
```

这种模式中，map 负责把输入参数映射到已经计算出的结果，避免重复计算。

### 反例：用 operator[] 做存在性检查
```cpp
std::unordered_map<std::string, int> score;

if (score["alice"] > 0) {
    // ...
}
```

如果 `alice` 原本不存在，这段代码会把 `alice` 插入 map，并创建默认值 `0`。只判断存在性时应使用：

```cpp
if (score.find("alice") != score.end()) {
    // ...
}
```

### 反例：依赖遍历顺序
```cpp
for (const auto& [name, value] : score) {
    std::cout << name << " " << value << '\n';
}
```

这段代码可以遍历所有元素，但不能假设输出顺序等于插入顺序或字典序。如果输出顺序重要，应把结果拷贝到 `std::vector` 后排序，或者直接使用 `std::map`。

### 边界情况
如果需要按 key 有序遍历、范围查询、找前驱后继，应优先考虑 `std::map`。如果数据量很小，线性扫描 `std::vector<std::pair<K, V>>` 可能更简单，也可能因为缓存局部性更好而足够快。如果 key 来自不可信输入且存在哈希碰撞攻击风险，要关注哈希函数质量和最坏情况性能。

## 关系与连接
- **前置知识**：模板、迭代器、pair、哈希函数、相等比较、时间复杂度、RAII。
- **关联概念**：`std::map`、`std::unordered_set`、`std::unordered_multimap`、bucket、load factor、rehash、哈希冲突。
- **容易混淆**：`std::unordered_map` 不排序；`std::map` 按 key 排序；`std::unordered_multimap` 允许重复 key；`std::unordered_set` 只保存 key，不保存 key 到 value 的映射。
- **上位/下位知识**：上位是 STL 关联容器；下位包括哈希表、字典索引、频次统计、缓存映射和邻接表映射。

### 与相近概念对比
- `std::map`：底层通常是平衡树，按 key 有序，查找/插入/删除通常是 O(log n)，适合有序遍历和范围查询。
- `std::unordered_map`：底层通常是哈希表，平均 O(1)，不保证顺序，适合快速点查。
- `std::unordered_multimap`：允许多个元素拥有相同 key，适合一对多关系，但查找后还需要遍历同 key 区间。
- `std::vector<std::pair<K, V>>`：适合数据量小、需要保持插入顺序、批量排序或顺序扫描的场景。

## 常见误区
- 以为 `std::unordered_map` 的遍历顺序是插入顺序；它既不保证插入顺序，也不保证排序。
- 用 `operator[]` 判断 key 是否存在，导致不存在的 key 被默认插入。
- 忽略 rehash 的迭代器失效问题，在批量插入后继续使用旧迭代器。
- 自定义结构体作为 key 时只写 `operator==`，却没有提供匹配的 hash 函数。
- 认为平均 O(1) 等于永远 O(1)，忽略哈希质量、负载因子和最坏情况退化。

## 应用场景
- **适合用在**：频次统计、ID 到对象索引、缓存、快速字典查询、去重辅助结构、图的邻接表、字符串到枚举或处理函数的映射。
- **不适合用在**：需要有序遍历、范围查询、稳定输出顺序、极小数据集简单查找、对最坏情况性能非常敏感或哈希函数难以可靠定义的场景。

## 参考来源
- C++ 标准库 `<unordered_map>`
- cppreference: `std::unordered_map`

## 我的理解
可以把 `std::unordered_map` 理解成“用 key 找抽屉”的容器：哈希函数先告诉你大概在哪个抽屉，冲突处理再在抽屉里确认是哪一项。它的优势是点查快，代价是无序、可能 rehash、需要好的哈希函数，并且不能把平均 O(1) 当成所有情况下都稳定的承诺。
