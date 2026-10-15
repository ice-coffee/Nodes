---
id: 20260704-002
tags: [C++, STL, 关联容器, map]
aliases: [C++ map 数据结构, C++ 映射容器, associative containers, map 容器对比]
created: 2026-07-04
updated: 2026-07-04
source: ""
status: draft
---

# C++ 中常用的 map 数据结构

C++ 里的 map 类容器都用于保存 `key -> value` 映射关系。选它们时主要看两个问题：

- 是否需要按 key 排序。
- 一个 key 是否允许对应多个 value。

可以先记一个简单选择规则：

```text
需要有序：map / multimap
不需要有序、追求平均快速查找：unordered_map / unordered_multimap
key 唯一：map / unordered_map
key 可重复：multimap / unordered_multimap
```

## std::map

`std::map` 是最常见的有序映射容器。

特点：

- key 唯一。
- 按 key 自动排序。
- 底层通常是红黑树等平衡树。
- 查找、插入、删除通常是 O(log n)。
- 支持有序遍历、范围查询，例如 `lower_bound()`、`upper_bound()`。

适合：

- 需要按 key 升序遍历。
- 需要范围查询。
- 需要稳定的排序语义。

简单示例：

```cpp
std::map<int, std::string> users;
users[2] = "bob";
users[1] = "alice";

// 遍历时会按 key 排序输出：1, 2
for (const auto& [id, name] : users) {
    std::cout << id << ": " << name << '\n';
}
```

## std::unordered_map

`std::unordered_map` 是最常用的哈希映射容器。

特点：

- key 唯一。
- 不保证遍历顺序。
- 底层通常是哈希表。
- 平均查找、插入、删除接近 O(1)。
- 最坏情况下可能退化到 O(n)。
- 扩容或 rehash 可能导致迭代器失效。

适合：

- 快速按 key 查找。
- 频次统计。
- ID 到对象的索引。
- 缓存、字典表、去重辅助结构。

简单示例：

```cpp
std::unordered_map<std::string, int> count;
++count["apple"];
++count["apple"];
++count["banana"];
```

注意：不要依赖 `unordered_map` 的遍历顺序，它既不是插入顺序，也不是 key 排序。

## std::multimap

`std::multimap` 可以理解为“允许重复 key 的 `std::map`”。

特点：

- key 可以重复。
- 按 key 自动排序。
- 底层通常是平衡树。
- 查找、插入、删除通常是 O(log n)。
- 适合表达一对多关系。

适合：

- 一个 key 对应多个 value。
- 同时还需要按 key 有序组织。

简单示例：

```cpp
std::multimap<std::string, int> scores;
scores.emplace("alice", 90);
scores.emplace("alice", 95);

for (auto [it, end] = scores.equal_range("alice"); it != end; ++it) {
    std::cout << it->second << '\n';
}
```

注意：`find()` 只返回某一个匹配元素；如果要处理同一个 key 下的全部 value，通常用 `equal_range()`。

## std::unordered_multimap

`std::unordered_multimap` 可以理解为“允许重复 key 的 `std::unordered_map`”。

特点：

- key 可以重复。
- 不保证遍历顺序。
- 底层通常是哈希表。
- 平均查找、插入、删除接近 O(1)。
- 适合无序的一对多快速查找。

适合：

- 一个 key 对应多个 value。
- 不关心 key 顺序。
- 更关心平均查找速度。

简单示例：

```cpp
std::unordered_multimap<std::string, int> tag_to_ids;
tag_to_ids.emplace("cpp", 101);
tag_to_ids.emplace("cpp", 102);
```

## 线程安全的 map 数据结构

C++ 标准库里的 `std::map`、`std::unordered_map`、`std::multimap`、`std::unordered_multimap` 本身都不是线程安全容器。

更准确地说：

- 多个线程只读同一个容器，通常可以并发进行。
- 只要有线程写入，就必须同步。
- 一个线程写、另一个线程读，如果没有锁保护，也属于数据竞争。
- 不能一边遍历容器，一边让其他线程插入、删除或触发 rehash。

常见做法有几类。

### std::mutex + map / unordered_map

最简单的线程安全方案：用一把互斥锁保护整个容器。

```cpp
std::mutex mtx;
std::unordered_map<int, std::string> users;

void put(int id, std::string name) {
    std::lock_guard<std::mutex> lock(mtx);
    users[id] = std::move(name);
}

std::optional<std::string> get(int id) {
    std::lock_guard<std::mutex> lock(mtx);
    auto it = users.find(id);
    if (it == users.end()) {
        return std::nullopt;
    }
    return it->second;
}
```

特点：

- 实现简单，最不容易写错。
- 所有读写都会互斥，并发性能一般。
- 适合数据量不大、访问频率不高、先保证正确性的场景。

### std::shared_mutex + map / unordered_map

读多写少时，可以用读写锁：读操作加共享锁，写操作加独占锁。

```cpp
std::shared_mutex mtx;
std::unordered_map<int, std::string> users;

std::optional<std::string> get(int id) {
    std::shared_lock<std::shared_mutex> lock(mtx);
    auto it = users.find(id);
    if (it == users.end()) {
        return std::nullopt;
    }
    return it->second;
}

void put(int id, std::string name) {
    std::unique_lock<std::shared_mutex> lock(mtx);
    users[id] = std::move(name);
}
```

特点：

- 多个读线程可以并发访问。
- 写线程仍然需要独占访问。
- 适合读多写少的缓存、配置表、索引表。
- 如果写很多，读写锁收益可能不明显，甚至比普通 mutex 更复杂。

### 分片锁 unordered_map

如果 `unordered_map` 很大、并发访问很多，可以按 key 的 hash 把数据分成多个分片，每个分片一把锁。

特点：

- 不同分片可以并发读写。
- 比单把锁吞吐更好。
- 实现复杂度更高。
- 涉及全量遍历、size 统计、批量清理时会更麻烦。

适合高并发缓存、连接表、会话表等场景。

### 三方并发 map

标准库没有直接提供 `concurrent_map`。如果项目已经引入并发容器库，可以考虑：

- **TBB `concurrent_hash_map` / `concurrent_unordered_map`**：适合高并发读写场景。
- **Folly `ConcurrentHashMap`**：Meta/Folly 提供的并发哈希表。
- **oneTBB / Intel TBB 容器**：工程里已有 TBB 时比较自然。

特点：

- 通常比自己手写分片锁更成熟。
- API 和标准库 map 不完全一致。
- 引入依赖后，要关注构建、平台兼容和团队熟悉度。

### 线程安全选择建议

- 普通业务代码：优先 `std::mutex + std::unordered_map`，简单可靠。
- 读多写少：考虑 `std::shared_mutex + std::unordered_map`。
- 高并发、热点明显：考虑分片锁或成熟三方并发 map。
- 需要有序遍历：用 `std::map + mutex/shared_mutex`，不要为了线程安全牺牲排序语义。
- 需要 lock-free map：标准库没有现成方案，除非有非常明确的性能瓶颈，否则不要轻易自研。

## 简要对比

| 容器 | 是否有序 | key 是否唯一 | 常见底层 | 查询特点 | 典型场景 |
| --- | --- | --- | --- | --- | --- |
| `std::map` | 有序 | 唯一 | 平衡树 | O(log n) | 有序遍历、范围查询 |
| `std::unordered_map` | 无序 | 唯一 | 哈希表 | 平均 O(1) | 快速点查、缓存、统计 |
| `std::multimap` | 有序 | 可重复 | 平衡树 | O(log n) | 有序的一对多映射 |
| `std::unordered_multimap` | 无序 | 可重复 | 哈希表 | 平均 O(1) | 快速的一对多查找 |
| `map + mutex` | 取决于底层 map | 取决于底层 map | 标准容器 + 锁 | 正确性优先 | 普通多线程读写 |
| `map + shared_mutex` | 取决于底层 map | 取决于底层 map | 标准容器 + 读写锁 | 读读并发 | 读多写少 |
| 分片锁 `unordered_map` | 无序 | 通常唯一 | 多个哈希表 + 多把锁 | 并发吞吐更好 | 高并发缓存、索引 |
| 三方并发 map | 通常无序 | 视实现而定 | 专用并发结构 | 高并发读写 | 性能敏感模块 |

## 常见选择建议

优先用 `std::unordered_map` 的场景：

- 只是根据 key 查 value。
- 不关心遍历顺序。
- 数据量较大，查找频繁。
- key 有合适的哈希函数。

优先用 `std::map` 的场景：

- 需要按 key 排序输出。
- 需要范围查询。
- 需要找某个 key 附近的元素。
- 希望性能更稳定，不依赖哈希质量。

考虑 `multimap` / `unordered_multimap` 的场景：

- 一个 key 天然对应多个 value。
- 例如一个标签对应多个文章 ID，一个用户名对应多条记录，一个分数对应多个学生。

也可以不用 `multimap`，改用下面这种结构，通常更直观：

```cpp
std::unordered_map<std::string, std::vector<int>> tag_to_ids;
tag_to_ids["cpp"].push_back(101);
tag_to_ids["cpp"].push_back(102);
```

这种写法在业务代码里很常见，因为每个 key 下的多个 value 可以作为一个整体处理。

## 容易踩的点

- `std::map` 不是按插入顺序遍历，而是按 key 排序。
- `std::unordered_map` 不保证任何稳定顺序。
- `operator[]` 在 key 不存在时会插入默认值；只判断是否存在时用 `find()` 或 C++20 的 `contains()`。
- `unordered_map` 平均 O(1) 不代表永远 O(1)，哈希冲突严重时会退化。
- `multimap` 允许重复 key，查找同一个 key 的所有值时要用 `equal_range()`。

## 我的记忆方式

把 C++ 的 map 家族按两个维度记就够了：

```text
map                 = 有序 + key 唯一
unordered_map       = 无序 + key 唯一
multimap            = 有序 + key 可重复
unordered_multimap  = 无序 + key 可重复
```

日常开发里最常用的是 `std::unordered_map` 和 `std::map`。前者适合快速查找，后者适合需要顺序；`multimap` 系列只有在一对多关系很自然、并且不想手动维护 `vector` 时才更值得考虑。
