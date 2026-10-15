---
id: 20260704-001
tags: [C++, 并发编程, 互斥锁, RAII, 线程同步]
aliases: [unique_lock, std unique lock, 独占锁, 灵活锁]
created: 2026-07-04
updated: 2026-07-04
source: ""
status: draft
---

# std::unique_lock

## 一句话定义
`std::unique_lock` 是 C++ 标准库中一个灵活的 RAII 互斥锁包装器，相比 `std::lock_guard` 支持延迟加锁、手动解锁、重新加锁、所有权转移和配合条件变量使用。

## 核心理解
- **是什么**：一个管理互斥锁生命周期的 RAII 类，既记录关联哪把 `mutex`，也记录当前是否真的持有锁。
- **为什么需要它**：`std::lock_guard` 只能构造时加锁、析构时解锁，无法表达延迟加锁、中途释放、条件变量等待、多锁协同等更灵活的场景。
- **它解决了什么问题**：在保留异常安全自动解锁能力的同时，让锁的获取、释放、转移和状态检查变得可控。

## 详细解释

### 工作机制
`unique_lock` 内部通常会记录两类信息：它关联的是哪一把 `mutex`，以及当前对象是否已经成功持有这把锁；析构时只有在“确实持锁”的情况下才会自动解锁。

这也是它比 `lock_guard` 更灵活的根本原因：`lock_guard` 只表达“从构造到析构一直持锁”，而 `unique_lock` 可以表达“先绑定但暂不加锁”“中途解锁”“之后再加锁”“把所有权转移给另一个对象”等状态变化。

### API 能力分类总览
理解 `std::unique_lock` 时，建议先把它的能力分成几类，而不是把所有名字都当成同一种“函数”：

| 类别 | 代表用法 | 作用 |
|------|----------|------|
| 构造方式 | 默认构造、`std::defer_lock`、`std::adopt_lock`、`std::try_to_lock` | 决定构造 `unique_lock` 时是否加锁、是否接管已有锁 |
| 加解锁成员函数 | `lock()`、`try_lock()`、`unlock()` | 构造后手动控制锁的获取与释放 |
| 状态查询 | `owns_lock()`、`operator bool()`、`mutex()` | 查询当前是否持锁、关联的是哪把 mutex |
| 所有权操作 | 移动构造/移动赋值、`release()` | 转移或放弃对锁的管理权 |
| 典型组合场景 | `std::condition_variable::wait()`、`std::lock()` | 需要锁状态可变化的高级同步场景 |

### 构造标签不是成员函数
`std::defer_lock`、`std::adopt_lock`、`std::try_to_lock` 是“构造标签”，它们只在构造 `unique_lock` 时表达策略：

```cpp
std::unique_lock<std::mutex> lock(mtx, std::defer_lock);
```

这里的 `std::defer_lock` 不是调用某个函数，而是在告诉构造函数：“先关联这把 `mutex`，但暂时不要加锁”。

### 所有权转移
`unique_lock` 支持移动语义，可以把“管理并可能持有某把锁”的责任转移给另一个 `unique_lock`；但它不支持复制，因为同一把锁不能被两个 RAII 对象同时认为自己负责解锁。

## 常用用法

### 构造方式与构造标签

#### 默认构造：立即加锁
最常见写法，构造 `unique_lock` 时立即对 `mutex` 加锁；如果只需要简单临界区保护，通常优先考虑更轻量的 `std::lock_guard`。

```cpp
std::unique_lock<std::mutex> lock(mtx);
// 临界区代码
// 析构时自动解锁
```

#### std::defer_lock：先关联，暂不加锁
适合需要先创建锁对象、稍后再手动加锁，或者需要配合 `std::lock()` 同时锁多把 mutex 的场景。

```cpp
std::unique_lock<std::mutex> lock(mtx, std::defer_lock);
// 这里还没有加锁
lock.lock();
```

配合 `std::lock()` 同时加多把锁，避免不同线程按相反顺序加锁导致死锁：

```cpp
std::unique_lock<std::mutex> lock1(mtx1, std::defer_lock);
std::unique_lock<std::mutex> lock2(mtx2, std::defer_lock);
std::lock(lock1, lock2);
```

#### std::adopt_lock：接管已经持有的锁
适合当前线程已经成功锁住 `mutex`，然后希望交给 `unique_lock` 负责后续自动解锁的场景。

```cpp
mtx.lock();
std::unique_lock<std::mutex> lock(mtx, std::adopt_lock);
// 从这里开始由 lock 负责析构解锁
```

常见于先用 `std::lock()` 锁住多把裸 mutex，再用 RAII 对象接管：

```cpp
std::lock(mtx1, mtx2);
std::unique_lock<std::mutex> lock1(mtx1, std::adopt_lock);
std::unique_lock<std::mutex> lock2(mtx2, std::adopt_lock);
```

注意：使用 `adopt_lock` 的前提是当前线程确实已经持有这把锁，否则析构时可能错误解锁。

#### std::try_to_lock：构造时尝试加锁
适合不能阻塞等待锁的场景；构造后要用 `owns_lock()` 判断是否成功。

```cpp
std::unique_lock<std::mutex> lock(mtx, std::try_to_lock);
if (!lock.owns_lock()) {
    return;
}
// 成功持锁后执行临界区代码
```

### 加解锁成员函数

#### lock()
对已经关联但尚未持有的 `mutex` 加锁；常和 `std::defer_lock` 搭配。

```cpp
std::unique_lock<std::mutex> lock(mtx, std::defer_lock);
lock.lock();
```

如果当前对象已经持锁，再调用 `lock()` 是错误用法，通常会导致异常或未定义风险，具体取决于 mutex 类型和实现。

#### try_lock()
尝试加锁但不阻塞，成功返回 `true`，失败返回 `false`。

```cpp
std::unique_lock<std::mutex> lock(mtx, std::defer_lock);
if (lock.try_lock()) {
    // 成功持锁
}
```

#### unlock()
释放当前持有的锁，但 `unique_lock` 仍然关联原来的 `mutex`，之后可以再次 `lock()`。

```cpp
std::unique_lock<std::mutex> lock(mtx);
// 临界区 A
lock.unlock();
// 执行不需要持锁的耗时操作
lock.lock();
// 临界区 B
```

注意：对没有持锁的 `unique_lock` 调用 `unlock()` 是错误用法，可能抛出 `std::system_error`。

### 状态查询函数

#### owns_lock()
判断当前 `unique_lock` 是否真的持有锁，是理解 `unique_lock` 状态的核心函数。

```cpp
std::unique_lock<std::mutex> lock(mtx, std::defer_lock);
if (!lock.owns_lock()) {
    lock.lock();
}
```

#### operator bool()
`unique_lock` 可以在布尔上下文中使用，效果类似 `owns_lock()`。

```cpp
std::unique_lock<std::mutex> lock(mtx, std::try_to_lock);
if (lock) {
    // 成功持锁
}
```

#### mutex()
返回当前关联的 `mutex` 指针；一般较少直接使用，更多用于底层封装或调试。

```cpp
std::mutex* p = lock.mutex();
```

### 所有权管理

#### 移动语义：转移锁管理权
`unique_lock` 可以移动但不能复制，移动后原对象不再负责解锁。

```cpp
std::unique_lock<std::mutex> lock1(mtx);
std::unique_lock<std::mutex> lock2 = std::move(lock1);
// lock2 接管；lock1 不再持锁
```

#### release()：放弃管理权，但不解锁
`release()` 返回底层 `mutex` 指针，并让 `unique_lock` 放弃管理责任；锁本身是否仍被持有不会改变。

```cpp
std::unique_lock<std::mutex> lock(mtx);
std::mutex* raw = lock.release();
raw->unlock();
```

注意：`release()` 不会解锁，只是把“谁负责解锁”的责任交出去；忘记手动解锁会导致死锁。

### 典型组合场景

#### 配合 std::condition_variable
条件变量的 `wait()` 需要能在等待时临时释放锁、被唤醒后重新加锁，因此要求传入 `std::unique_lock`，不能传 `std::lock_guard`。

```cpp
std::unique_lock<std::mutex> lock(mtx);
cv.wait(lock, [] { return ready; });
```

#### 配合 timed_mutex 做超时等待
如果底层锁是 `std::timed_mutex`，`unique_lock` 可以使用 `try_lock_for()` 或 `try_lock_until()`。

```cpp
std::unique_lock<std::timed_mutex> lock(mtx, std::defer_lock);
if (lock.try_lock_for(std::chrono::milliseconds(100))) {
    // 100ms 内成功拿到锁
}
```

## 关键要点
- `unique_lock` 的核心价值是“有状态”：它知道自己关联哪把锁，也知道自己当前是否持锁。
- 构造标签和成员函数不是一类东西：标签控制构造策略，成员函数控制构造后的锁状态。
- `condition_variable::wait()` 必须搭配 `unique_lock`，因为等待过程中需要自动释放并重新获取锁。
- `release()` 不解锁，只放弃管理权；`unlock()` 才是真正释放锁。
- 如果只是简单临界区保护，`lock_guard` 或 `scoped_lock` 往往更直接。

## 例子与边界

### 正例：生产者-消费者 + 条件变量
```cpp
#include <condition_variable>
#include <mutex>
#include <queue>

std::mutex mtx;
std::condition_variable cv;
std::queue<int> tasks;

void producer(int val) {
    {
        std::lock_guard<std::mutex> lock(mtx);
        tasks.push(val);
    }
    cv.notify_one();
}

int consumer() {
    std::unique_lock<std::mutex> lock(mtx);
    cv.wait(lock, [] { return !tasks.empty(); });
    int val = tasks.front();
    tasks.pop();
    return val;
}
```

### 正例：同时锁两把 mutex
```cpp
std::unique_lock<std::mutex> lock1(mtx1, std::defer_lock);
std::unique_lock<std::mutex> lock2(mtx2, std::defer_lock);
std::lock(lock1, lock2);
// 同时持有 mtx1 和 mtx2
```

### 反例：误把 release() 当成 unlock()
```cpp
std::unique_lock<std::mutex> lock(mtx);
lock.release();  // 错误：锁仍然被持有，只是不再由 lock 管理
```

### 反例：没有持锁却使用 adopt_lock
```cpp
std::unique_lock<std::mutex> lock(mtx, std::adopt_lock);  // 错误：当前线程并未先 lock mtx
```

### 边界情况
- 不需要中途解锁、延迟加锁或条件变量时，`std::lock_guard` 更简单。
- C++17 同时锁多把 mutex 时，`std::scoped_lock` 更直接。
- `unique_lock` 多了状态记录，通常比 `lock_guard` 略有额外开销。

## 关系与连接
- **前置知识**：`std::mutex`、RAII、临界区、线程同步、移动语义。
- **关联概念**：`std::lock_guard`、`std::scoped_lock`、`std::condition_variable`、`std::lock()`、`std::shared_lock`。
- **容易混淆**：`std::defer_lock` / `std::adopt_lock` / `std::try_to_lock` 是构造标签；`lock()` / `unlock()` / `try_lock()` 是成员函数。
- **上位/下位知识**：上位是 C++ 并发同步；下位包括 RAII 锁管理、条件变量等待、多 mutex 加锁策略。

### 与相近概念对比
| 特性 | `lock_guard` | `unique_lock` | `scoped_lock`（C++17） |
|------|--------------|---------------|------------------------|
| 构造时自动加锁 | 是 | 默认是，可配置 | 是 |
| 手动 `unlock()` | 否 | 是 | 否 |
| 延迟加锁 | 否 | 是 | 否 |
| 条件变量等待 | 否 | 是 | 否 |
| 多 mutex 支持 | 否 | 可配合 `std::lock()` | 原生支持 |
| 移动语义 | 否 | 是 | 否 |

选择建议：简单临界区用 `lock_guard`；需要条件变量、延迟加锁、中途解锁或移动所有权时用 `unique_lock`；C++17 同时锁多把 mutex 时优先考虑 `scoped_lock`。

## 常见误区
- 以为 `std::defer_lock`、`std::adopt_lock` 是函数；它们其实是构造标签。
- 以为 `release()` 会释放锁；它只释放管理权，不会调用 `unlock()`。
- 使用 `adopt_lock` 前没有先成功加锁，导致 RAII 对象接管了并不存在的锁所有权。
- 忘记检查 `std::try_to_lock` 后的 `owns_lock()`，以为构造成功就一定持锁。
- 在不需要灵活锁状态的场景滥用 `unique_lock`，让代码比必要的更复杂。

## 应用场景
- **适合用在**：条件变量等待、需要临时释放锁的长流程、需要延迟加锁或尝试加锁、需要移动锁所有权、需要配合 `std::lock()` 同时管理多把锁。
- **不适合用在**：只有一小段简单临界区、没有锁状态变化、对极简表达和最低开销更敏感的场景。

## 参考来源
- C++ 标准库 `<mutex>`
- cppreference: `std::unique_lock`

## 我的理解
`std::unique_lock` 可以理解成“可变状态的锁管家”：它不只是帮你在作用域结束时解锁，还能记住自己有没有拿到锁、什么时候暂时放下锁、什么时候重新拿锁、什么时候把管理权交给别人。正因为它能表达这些变化，所以比 `lock_guard` 灵活，也比 `lock_guard` 更需要小心使用。
