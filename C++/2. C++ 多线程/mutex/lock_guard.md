---
id: 20260704-003
tags: [C++, 并发编程, 互斥锁, RAII, 线程同步]
aliases: [lock_guard, std lock guard, RAII 锁, 作用域锁]
created: 2026-07-04
updated: 2026-07-04
source: ""
status: draft
---

# std::lock_guard

## 一句话定义
`std::lock_guard` 是 C++ 标准库中最简单的 RAII 互斥锁包装器，在构造时自动加锁，并在离开作用域析构时自动解锁。

## 核心理解
- **是什么**：一个用对象生命周期管理 `mutex` 加锁和解锁的轻量级工具。
- **为什么需要它**：手动调用 `lock()` / `unlock()` 容易因为提前 `return`、异常或分支遗漏导致忘记解锁。
- **它解决了什么问题**：把“进入作用域加锁、离开作用域解锁”变成自动行为，让临界区保护更简单、更异常安全。

## 详细解释

### 工作机制
`std::lock_guard` 在构造函数中调用传入 `mutex` 的 `lock()`，在析构函数中调用 `unlock()`。因为局部对象离开作用域时一定会析构，所以即使中途发生异常或提前 `return`，锁也会被释放。

这就是 RAII（Resource Acquisition Is Initialization）的典型用法：资源获取放在构造函数里，资源释放放在析构函数里。

### API 能力分类总览
`std::lock_guard` 的能力很少，适合先从“它不能做什么”来理解：

| 类别 | 代表用法 | 作用 |
|------|----------|------|
| 默认构造加锁 | `std::lock_guard<std::mutex> lock(mtx)` | 构造时立即加锁，析构时自动解锁 |
| 接管已有锁 | `std::lock_guard<std::mutex> lock(mtx, std::adopt_lock)` | 当前线程已经持锁时，只接管后续解锁责任 |
| 不支持的能力 | 无 `unlock()`、无 `lock()`、无 `try_lock()`、不可移动/复制 | 保持简单，锁生命周期固定为当前作用域 |

### 生命周期就是锁的生命周期
`lock_guard` 的核心特点是：锁的持有时间和 `lock_guard` 对象的生命周期完全一致。

```cpp
{
    std::lock_guard<std::mutex> lock(mtx);
    // 从这里开始持锁
}
// 到这里自动解锁
```

如果你需要中途释放锁、延迟加锁、尝试加锁或把锁转移给其他函数，`lock_guard` 就不适合，应考虑 `std::unique_lock`。

## 常用用法

### 基础用法

#### 构造时自动加锁
最常见用法是在进入临界区时创建 `lock_guard` 对象。

```cpp
std::mutex mtx;
int counter = 0;

void increment() {
    std::lock_guard<std::mutex> lock(mtx);
    ++counter;
}
```

`increment()` 执行时会先加锁，函数结束时自动解锁。

#### 用局部作用域缩短持锁时间
如果函数后半段不需要继续持锁，可以用 `{}` 明确限制 `lock_guard` 的生命周期。

```cpp
void update_and_print() {
    {
        std::lock_guard<std::mutex> lock(mtx);
        ++counter;
    } // 这里已经解锁

    print_result();
}
```

这样能避免不必要地长时间持锁。

### 构造标签

#### std::adopt_lock：接管已经持有的锁
当当前线程已经成功持有 `mutex` 时，可以用 `std::adopt_lock` 告诉 `lock_guard`：“不要再加锁，只负责后续析构解锁”。

```cpp
mtx.lock();
std::lock_guard<std::mutex> lock(mtx, std::adopt_lock);
// 析构时自动 unlock
```

更常见的场景是先用 `std::lock()` 同时锁住多把 mutex，再用多个 RAII 对象接管：

```cpp
std::lock(mtx1, mtx2);
std::lock_guard<std::mutex> lock1(mtx1, std::adopt_lock);
std::lock_guard<std::mutex> lock2(mtx2, std::adopt_lock);
```

注意：使用 `adopt_lock` 的前提是当前线程已经成功持有锁，否则析构时会错误解锁。

### 不支持的用法

#### 不能手动 unlock()
`lock_guard` 没有 `unlock()` 成员函数。如果需要中途释放锁，应使用 `std::unique_lock`。

```cpp
std::lock_guard<std::mutex> lock(mtx);
// lock.unlock(); // 编译错误
```

#### 不能延迟加锁
`lock_guard` 默认构造时立即加锁，不支持 `std::defer_lock`。

```cpp
// std::lock_guard<std::mutex> lock(mtx, std::defer_lock); // 错误
```

#### 不能复制或移动
`lock_guard` 不能复制，也不能移动，因为它表示一个固定作用域内的锁管理责任。

```cpp
std::lock_guard<std::mutex> lock1(mtx);
// auto lock2 = lock1;            // 错误：不能复制
// auto lock3 = std::move(lock1); // 错误：不能移动
```

## 关键要点
- `lock_guard` 是最简单、最轻量的 RAII 锁管理器。
- 它构造时加锁，析构时解锁，中途不能手动释放或重新加锁。
- 它适合保护短小、固定范围的临界区。
- 需要条件变量、延迟加锁、尝试加锁或中途解锁时，应使用 `std::unique_lock`。
- 使用 `std::adopt_lock` 前必须确保当前线程已经持有对应的锁。

## 例子与边界

### 正例：保护共享计数器
```cpp
#include <mutex>

std::mutex mtx;
int counter = 0;

void add_one() {
    std::lock_guard<std::mutex> lock(mtx);
    ++counter;
}
```

这里 `counter` 的修改被 `mtx` 保护，函数结束时自动解锁。

### 正例：异常安全自动解锁
```cpp
void update() {
    std::lock_guard<std::mutex> lock(mtx);
    modify_shared_state();
    may_throw();
} // 即使 may_throw() 抛异常，也会自动解锁
```

如果手动写 `mtx.lock()` / `mtx.unlock()`，异常路径很容易漏掉解锁。

### 反例：需要等待条件变量
```cpp
std::lock_guard<std::mutex> lock(mtx);
// cv.wait(lock, [] { return ready; }); // 错误：condition_variable 需要 unique_lock
```

`condition_variable::wait()` 需要在等待时释放锁、醒来后重新加锁，`lock_guard` 做不到。

### 反例：长时间持锁执行耗时操作
```cpp
std::lock_guard<std::mutex> lock(mtx);
update_shared_state();
do_slow_io(); // 不推荐：IO 期间也一直持锁
```

如果耗时操作不需要访问共享数据，应缩短 `lock_guard` 作用域，或者用 `unique_lock` 中途 `unlock()`。

### 边界情况
- 如果只需要简单保护一个短临界区，`lock_guard` 通常是首选。
- 如果需要同时锁多把 mutex，C++17 起优先考虑 `std::scoped_lock`。
- 如果需要任何可变锁状态，使用 `std::unique_lock` 更合适。

## 关系与连接
- **前置知识**：`std::mutex`、RAII、作用域、析构函数、临界区。
- **关联概念**：`std::unique_lock`、`std::scoped_lock`、`std::condition_variable`、`std::adopt_lock`、`std::lock()`。
- **容易混淆**：`lock_guard` 管理的是“固定作用域锁”；`unique_lock` 管理的是“可变化状态的锁”。
- **上位/下位知识**：上位是 C++ 线程同步与互斥；下位包括作用域锁、异常安全、临界区设计。

### 与相近概念对比
| 特性 | `lock_guard` | `unique_lock` | `scoped_lock`（C++17） |
|------|--------------|---------------|------------------------|
| 构造时自动加锁 | 是 | 默认是，可配置 | 是 |
| 析构自动解锁 | 是 | 持锁时是 | 是 |
| 手动 `unlock()` | 否 | 是 | 否 |
| 延迟加锁 | 否 | 是 | 否 |
| 尝试加锁 | 否 | 是 | 否 |
| 条件变量等待 | 否 | 是 | 否 |
| 多 mutex | 不直接支持 | 可配合 `std::lock()` | 原生支持 |
| 移动语义 | 否 | 是 | 否 |

选择建议：简单短临界区用 `lock_guard`；需要中途解锁、条件变量或锁所有权转移时用 `unique_lock`；C++17 同时锁多把 mutex 时用 `scoped_lock`。

## 常见误区
- 以为 `lock_guard` 可以手动 `unlock()`；它没有这个接口。
- 以为 `lock_guard` 能用于 `condition_variable::wait()`；条件变量等待必须使用 `unique_lock`。
- 在过大的作用域里创建 `lock_guard`，导致锁持有时间过长。
- 使用 `std::adopt_lock` 前没有先成功加锁，导致 RAII 对象接管了不存在的锁所有权。
- 把 `lock_guard` 保存为成员变量来长期持锁；这通常会让锁生命周期不清晰，容易造成死锁。

## 应用场景
- **适合用在**：保护短小临界区、计数器更新、共享容器简单读写、需要异常安全解锁的普通互斥访问。
- **不适合用在**：条件变量等待、需要中途解锁、延迟加锁、尝试加锁、锁所有权需要跨函数转移、复杂多锁协调。

## 参考来源
- C++ 标准库 `<mutex>`
- cppreference: `std::lock_guard`

## 我的理解
`std::lock_guard` 可以理解成“最朴素的自动门锁”：创建对象就上锁，对象离开作用域就开锁，中途不给遥控器。它的价值不在灵活，而在简单、明确、少出错；只要临界区边界清楚，它通常就是最合适的选择。
