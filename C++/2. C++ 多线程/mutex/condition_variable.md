---
id: 20260704-002
tags: [C++, 并发编程, 条件变量, 线程同步]
aliases: [condition_variable, std condition variable, 条件变量, 条件等待]
created: 2026-07-04
updated: 2026-07-04
source: ""
status: draft
---

# std::condition_variable

## 一句话定义
`std::condition_variable` 是 C++ 标准库中用于线程间等待与通知的同步原语，让线程在条件未满足时阻塞，并在共享状态变化后被唤醒重新检查条件。

## 核心理解
- **是什么**：一个配合 `std::mutex`、`std::unique_lock` 和共享状态使用的等待/通知工具。
- **为什么需要它**：避免线程用忙等方式反复检查条件，浪费 CPU 且容易写出竞态代码。
- **它解决了什么问题**：让等待线程在条件未满足时睡眠，让修改状态的线程在状态变化后通知等待者醒来重新判断条件。

## 详细解释

### 工作机制
条件变量本身不保存“条件是否成立”，真正的条件必须由共享状态表示，例如队列是否为空、任务是否完成、停止标志是否为 `true`。

典型流程是：等待线程先持有锁并检查共享状态；如果条件不满足，`wait()` 会原子地释放锁并阻塞当前线程；收到通知后，等待线程会重新竞争锁，拿到锁之后再次检查条件是否满足。

### 为什么 wait() 需要 unique_lock
`std::condition_variable::wait()` 需要在等待时临时释放锁，并在被唤醒后重新加锁。`std::lock_guard` 只能在构造时加锁、析构时解锁，不能在中途释放和重新获取，因此 `wait()` 要求传入 `std::unique_lock<std::mutex>`。

### API 能力分类总览
理解 `std::condition_variable` 时，可以先把它的能力分成几类：

| 类别 | 代表用法 | 作用 |
|------|----------|------|
| 基础等待 | `wait(lock)`、`wait(lock, pred)` | 阻塞当前线程，直到被通知并重新检查条件 |
| 通知函数 | `notify_one()`、`notify_all()` | 唤醒一个或多个等待线程 |
| 超时等待 | `wait_for()`、`wait_until()` | 最多等待一段时间或等到某个时间点 |
| 共享状态模式 | 队列非空、完成标志、停止标志 | 用真实变量表达“条件是否成立” |
| 典型组合场景 | 生产者-消费者、线程池、后台线程停止 | 在线程间协调状态变化 |

### 通知不是条件本身
`notify_one()` / `notify_all()` 只是“叫醒等待线程”，不代表条件一定成立。被唤醒的线程必须重新检查共享状态，因为可能发生虚假唤醒，也可能被其他线程先抢走资源。

## 常用用法

### 基础等待函数

#### wait(lock, predicate)：推荐写法
这是最常用、最安全的写法。谓词为 `false` 时线程阻塞；被唤醒后会重新检查谓词，直到谓词为 `true` 才继续执行。

```cpp
std::unique_lock<std::mutex> lock(mtx);
cv.wait(lock, [] { return ready; });
```

它等价于内部用循环反复判断：

```cpp
while (!ready) {
    cv.wait(lock);
}
```

注意：谓词中读取的共享状态应由同一把 `mutex` 保护。

#### wait(lock)：基础等待，必须自己循环检查条件
`wait(lock)` 只负责等待通知，不负责判断条件是否成立，因此外层必须写循环。

```cpp
std::unique_lock<std::mutex> lock(mtx);
while (!ready) {
    cv.wait(lock);
}
```

不要只写一次 `wait(lock)` 后就直接使用共享资源，因为醒来不代表条件一定满足。

### 通知函数

#### notify_one()
唤醒一个等待线程，适合每次只新增一个任务、只需要一个消费者继续工作的场景。

```cpp
{
    std::lock_guard<std::mutex> lock(mtx);
    tasks.push(task);
}
cv.notify_one();
```

通常建议先在锁保护下修改共享状态，再通知等待线程。通知可以放在解锁之后，以减少被唤醒线程立刻又阻塞在同一把锁上的机会。

#### notify_all()
唤醒所有等待线程，适合广播状态变化，例如关闭线程池、全局停止、配置更新等。

```cpp
{
    std::lock_guard<std::mutex> lock(mtx);
    stopped = true;
}
cv.notify_all();
```

注意：`notify_all()` 可能造成多个线程同时醒来竞争锁，不适合只新增一个资源却唤醒所有等待者的高频场景。

### 超时等待函数

#### wait_for(lock, duration, predicate)
最多等待一段相对时间，适合后台线程定期醒来检查状态，或避免永久等待。

```cpp
std::unique_lock<std::mutex> lock(mtx);
bool ok = cv.wait_for(lock, std::chrono::seconds(1), [] {
    return ready;
});
```

返回 `true` 表示谓词成立；返回 `false` 通常表示超时后条件仍未满足。

#### wait_until(lock, time_point, predicate)
等待到某个绝对时间点，适合截止时间固定的任务。

```cpp
std::unique_lock<std::mutex> lock(mtx);
auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(3);
cv.wait_until(lock, deadline, [] { return ready; });
```

对需要避免系统时间调整影响的场景，通常优先使用 `std::chrono::steady_clock`。

### 共享状态模式

#### 队列非空
生产者-消费者模型中，条件通常是队列不为空。

```cpp
cv.wait(lock, [] { return !queue.empty(); });
```

#### 完成标志
等待某个任务完成时，条件可以是 `done == true`。

```cpp
cv.wait(lock, [] { return done; });
```

#### 停止标志
线程池或后台线程退出时，条件常常包含停止标志，避免线程永远等待。

```cpp
cv.wait(lock, [] { return stopped || !tasks.empty(); });
```

## 关键要点
- 条件变量必须和共享状态一起使用，不能只依赖通知本身。
- `wait()` 阻塞前会释放锁，醒来后会重新获取锁。
- 优先使用 `wait(lock, predicate)`，它能自然处理虚假唤醒。
- 修改共享状态和检查共享状态应受同一把 `mutex` 保护。
- `notify_one()` / `notify_all()` 只是唤醒，不保证条件一定成立。

## 例子与边界

### 正例：生产者-消费者队列
```cpp
#include <condition_variable>
#include <mutex>
#include <queue>

std::mutex mtx;
std::condition_variable cv;
std::queue<int> queue;

void producer(int value) {
    {
        std::lock_guard<std::mutex> lock(mtx);
        queue.push(value);
    }
    cv.notify_one();
}

int consumer() {
    std::unique_lock<std::mutex> lock(mtx);
    cv.wait(lock, [] { return !queue.empty(); });

    int value = queue.front();
    queue.pop();
    return value;
}
```

### 正例：支持停止的消费者循环
```cpp
void worker() {
    while (true) {
        std::unique_lock<std::mutex> lock(mtx);
        cv.wait(lock, [] { return stopped || !tasks.empty(); });

        if (stopped && tasks.empty()) {
            return;
        }

        auto task = tasks.front();
        tasks.pop();
        lock.unlock();

        task();
    }
}
```

这里把 `stopped` 放进谓词，是为了让线程在没有新任务时也能被通知退出。

### 反例：醒来后不检查条件
```cpp
std::unique_lock<std::mutex> lock(mtx);
cv.wait(lock);
queue.pop();  // 错误：醒来不代表 queue 一定非空
```

### 反例：只通知，不记录共享状态
```cpp
cv.notify_one();

std::unique_lock<std::mutex> lock(mtx);
cv.wait(lock);  // 可能永远等不到，因为条件变量不保存历史通知
```

### 边界情况
- 如果只是等待一次异步结果，`std::future` / `std::promise` 可能更直接。
- 如果需要计数型资源控制，信号量（如 C++20 `std::counting_semaphore`）可能更贴合。
- 如果只需要互斥访问共享数据，不需要等待条件成立，直接使用 `std::mutex` + RAII 锁即可。

## 关系与连接
- **前置知识**：线程、互斥锁、临界区、共享状态、RAII、`std::unique_lock`。
- **关联概念**：`std::mutex`、`std::unique_lock`、`std::future`、`std::promise`、信号量、生产者-消费者模型、线程池。
- **容易混淆**：条件变量不是事件队列，也不会记住历史通知；条件是否满足必须由受锁保护的共享状态决定。
- **上位/下位知识**：上位是 C++ 并发同步机制；下位包括等待通知模型、阻塞队列、线程池任务调度、优雅停止。

### 与相近概念对比
| 概念 | 适合场景 | 不适合场景 |
|------|----------|------------|
| `std::condition_variable` | 多线程等待某个共享条件变化 | 单次结果交付、计数资源管理 |
| `std::future` / `std::promise` | 一次性异步结果传递 | 多次生产/消费、复杂共享状态等待 |
| 信号量 | 计数型资源、许可数量控制 | 需要检查复杂共享谓词 |
| `std::mutex` | 保护共享数据互斥访问 | 等待某个条件变为真 |

## 常见误区
- 以为 `notify_one()` 一定会让等待线程继续执行；实际上它只是唤醒，线程醒来后仍要重新检查条件。
- 忽略虚假唤醒，认为 `wait()` 返回就代表条件满足。
- 以为条件变量会保存通知；如果没有共享状态记录变化，先通知后等待可能丢失语义。
- 修改共享状态时不加锁，导致等待线程看到不一致的数据。
- 谓词里检查的状态和通知前修改的状态不是同一套锁保护，容易产生竞态。

## 应用场景
- **适合用在**：生产者-消费者队列、线程池任务等待、后台线程停止、状态变更通知、多线程协作等待某个共享条件成立。
- **不适合用在**：只需要简单互斥访问、只等待一个异步返回值、需要记录通知次数或管理计数资源的场景。

## 参考来源
- C++ 标准库 `<condition_variable>`
- cppreference: `std::condition_variable`

## 我的理解
可以把 `std::condition_variable` 理解成“带条件的睡眠与叫醒机制”：线程不是一直盯着条件看，而是在条件不满足时睡下；别人改变共享状态后叫醒它，但醒来后它还要自己确认条件真的满足。真正可靠的不是“有没有被叫醒”，而是“被锁保护的共享条件是否成立”。
