---
id: 20260718-001
tags: [C++, 并发编程, 线程, RAII]
aliases: [std::thread, thread, C++线程]
created: 2026-07-18
updated: 2026-07-18
source: "C++多线程 - thread.md"
status: draft
---

# std::thread

## 一句话定义

`std::thread` 是 C++11 提供的线程对象，用于启动并管理一个独立执行线程的生命周期。

## 核心理解

- **是什么**：`<thread>` 中的标准线程封装，内部关联一个可执行线程或为空。
- **为什么需要它**：将并发执行能力纳入 C++ 标准库，避免基础线程代码直接依赖平台 API。
- **它解决了什么问题**：负责线程创建、线程身份查询、等待回收、分离执行和基础调度控制。

## 详细解释

### 生命周期与状态

`std::thread` 对象的状态与线程函数是否正在运行不是同一个概念：

| 状态 | `joinable()` | 含义 |
| --- | :---: | --- |
| 默认构造 | `false` | 对象不关联线程 |
| 构造线程成功 | `true` | 对象关联一个线程，即使线程函数已经很快返回 |
| `join()` 完成 | `false` | 创建线程等待结束并解除关联 |
| `detach()` 完成 | `false` | 对象放弃关联，线程独立运行 |
| 移动后的源对象 | `false` | 线程所有权转移给目标对象 |

线程函数执行完毕并不会自动让 `std::thread` 对象变为不可 joinable；仍需调用 `join()` 或 `detach()`。如果对象析构时仍为 `joinable()`，程序会调用 `std::terminate()`。

### 所有权与移动语义

线程对象不可拷贝，只能移动。这是因为一个底层线程句柄不应同时由多个对象负责回收：

```cpp
std::thread source(work);
std::thread target = std::move(source);
// source.joinable() == false
// target.joinable() == true
```

移动赋值前，目标对象不能仍关联可执行线程；否则会因目标线程未被处理而终止程序。实际使用中应先对目标对象执行 `join()` 或 `detach()`。

### API 能力地图

- **构造与所有权**：默认构造、可调用对象构造、移动构造、移动赋值。
- **状态与生命周期**：`joinable()`、`join()`、`detach()`、`get_id()`。
- **句柄与交换**：`swap()`、`native_handle()`。
- **并发能力提示**：`hardware_concurrency()`。
- **当前线程控制**：`yield()`、`sleep_for()`、`sleep_until()`。

## 常用用法

### 构造线程

默认构造只创建空对象；传入函数、lambda 或函数对象时才会启动线程：

```cpp
#include <thread>

void work() {}

// 默认构造：只创建空的线程对象，不会启动线程
// empty.joinable() == false
std::thread empty;

// 初始化构造：创建线程对象，并立即启动线程执行 work
// worker.joinable() == true
std::thread worker(work);
```

### `join()`：等待并回收

适合调用方必须等待任务完成的场景。调用完成后线程对象不再关联线程：

```cpp
std::thread worker([] {
    // 执行任务
});

if (worker.joinable()) {
    worker.join();
}
```

`join()` 会阻塞当前线程，直到 `worker` 执行结束。

### `detach()`：分离执行

适合生命周期独立、调用方不需要等待结果的后台任务，但必须保证线程函数不访问已经失效的引用或对象：

```cpp
std::thread worker([] {
    // 只能访问自身拥有或生命周期足够长的数据
});
worker.detach();
```

分离后不能再通过原 `std::thread` 对象等待该线程。

### 传递参数与 lambda

`std::thread` 创建线程时，会把传入的参数保存到线程对象内部；默认情况下，参数会被复制一份，线程函数使用的是这份副本，而不是调用处的原对象。

因此，是否使用 `std::ref` 取决于线程函数的参数类型：

- 参数是普通值类型：直接传递，线程使用副本。
- 参数是引用类型，并且需要访问原对象：使用 `std::ref`，线程使用原对象。
- 参数是只读引用，并且需要避免复制：使用 `std::cref`，线程以 `const` 引用访问原对象。

#### 直接传递：线程使用副本

```cpp
#include <string>
#include <thread>

void append_copy(std::string value) {
    value += "!";
    // 修改的是线程内部的副本
}

std::string text = "data";
std::thread worker(append_copy, text);
worker.join();

// text 仍然是 "data"
```

这里的 `text` 会被复制给线程函数的 `value`，所以线程中对 `value` 的修改不会影响外部的 `text`。

#### 使用 `std::ref`：线程使用原对象

```cpp
#include <functional>
#include <string>
#include <thread>

std::string text = "data";

std::thread ref_worker([](std::string& value) {
    value += "!";
}, std::ref(text));

ref_worker.join();

// text 变成 "data!"
```

`std::ref(text)` 的作用不是创建一个新的字符串，而是创建一个“引用包装器”，告诉 `std::thread`：

> 不要复制 `text`，在线程函数中把参数绑定到原来的 `text`。

调用关系可以理解为：

```text
text ──直接传递──> 复制出线程内部的字符串 ──> 修改副本
text ──std::ref──> 引用包装器 ──> 访问原来的 text ──> 修改原对象
```

`std::ref` 也解释了为什么下面的写法不对：

```cpp
std::thread worker([](std::string& value) {
    value += "!";
}, text); // 错误：没有明确要求传递引用
```

lambda 明确要求 `std::string&`，但 `std::thread` 默认按值保存参数；使用 `std::ref(text)` 才能把“按值保存参数”改为“引用原对象”的语义。

#### 使用 `std::cref`：只读访问原对象

```cpp
std::string text = "data";

std::thread reader([](const std::string& value) {
    // 只能读取原来的 text，不能修改它
}, std::cref(text));

reader.join();
```

#### 使用引用时的生命周期要求

`std::ref` 不会延长对象生命周期。原对象必须在线程结束前一直存在，因此引用传递通常要配合 `join()`：

```cpp
void start() {
    std::string text = "data";

    std::thread worker([](std::string& value) {
        value += "!";
    }, std::ref(text));

    worker.join(); // 确保 text 销毁前线程已经结束
}
```

如果使用 `detach()`，函数返回后 `text` 可能已经销毁，后台线程继续访问它就会产生悬空引用。

### 查询线程状态和身份

```cpp
std::thread worker(work);
std::thread::id id = worker.get_id();

if (worker.joinable()) {
    worker.join();
}
```

`get_id()` 返回线程标识；线程完成 `join()` 或执行 `detach()` 后，线程对象通常返回默认构造的 `id`。

### `yield()`、`sleep_for()` 与 `sleep_until()`

```cpp
#include <chrono>
#include <thread>

std::this_thread::yield();
std::this_thread::sleep_for(std::chrono::milliseconds(100));

const auto deadline = std::chrono::steady_clock::now()
                    + std::chrono::seconds(1);
std::this_thread::sleep_until(deadline);
```

- `yield()`：提示调度器当前线程暂时让出执行机会，不保证一定切换线程。
- `sleep_for()`：至少休眠指定时长，实际唤醒时间受系统调度影响。
- `sleep_until()`：休眠到指定时间点，适合基于截止时间的等待。

### `hardware_concurrency()`

```cpp
unsigned count = std::thread::hardware_concurrency();
if (count == 0) {
    // 实现无法提供并发数提示，使用应用层默认值
}
```

返回值是实现提供的并发数提示，可能为 `0`，不能直接视为可创建线程数或性能保证。

### `swap()` 与 `native_handle()`

```cpp
std::thread first(work1);
std::thread second(work2);
first.swap(second);

auto handle = first.native_handle();
```

`swap()` 交换两个线程对象关联的线程；`native_handle()` 暴露平台相关句柄，只有在必须调用操作系统线程 API 时使用，会降低可移植性。

## 关键要点

- `std::thread` 不可拷贝，只能移动；移动后源对象不再关联线程。
- 线程函数结束不等于线程对象自动完成回收，必须 `join()` 或 `detach()`。
- 析构时仍 `joinable()` 会调用 `std::terminate()`，创建线程后应明确生命周期策略。
- `detach()` 会放弃直接管理线程的能力，引用捕获和对象生命周期尤其危险。
- `hardware_concurrency()` 只是提示值，可能返回 `0`。

## 例子与边界

### 完整示例：创建并等待两个线程

```cpp
#include <chrono>
#include <iostream>
#include <thread>

void print_message(const char* name, int count) {
    for (int i = 0; i < count; ++i) {
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
        std::cout << name << ": " << i << '\n';
    }
}

int main() {
    std::thread first(print_message, "first", 3);
    std::thread second([] {
        std::this_thread::sleep_for(std::chrono::milliseconds(20));
    });

    first.join();
    second.join();
}
```

编译时使用 C++11 或更高标准；在部分平台还需要链接线程支持，例如 GCC/Clang 常用 `-pthread`。

### 反例：可 join 线程直接析构

```cpp
void start() {
    std::thread worker(work);
} // 错误：worker 仍 joinable，析构时调用 std::terminate()
```

正确做法是让 `worker` 在离开作用域前完成 `join()` 或 `detach()`。

### 反例：分离线程访问局部引用

```cpp
void start() {
    int value = 42;
    std::thread worker([&] {
        // 线程可能在 value 销毁后才执行到这里
        use(value);
    });
    worker.detach();
} // value 先销毁，线程继续访问会产生悬空引用
```

如果任务必须使用局部数据，优先按值传递，或使用明确管理生命周期的共享状态，并优先选择 `join()`。

### 异常处理边界

线程函数内部抛出的异常如果没有被捕获，会导致调用 `std::terminate()`，不会自动传播到创建线程：

```cpp
std::thread worker([] {
    try {
        do_work();
    } catch (const std::exception& error) {
        report(error);
    }
});
worker.join();
```

如果需要把线程结果或异常交给调用方，应考虑 `std::promise`/`std::future` 或 `std::async`。

## 关系与连接

- **前置知识**：函数对象、lambda、右值引用、移动语义、RAII、异常处理。
- **关联概念**：`std::mutex`、`std::condition_variable`、`std::future`、`std::promise`、线程池。
- **容易混淆**：`joinable()` 只表示线程对象是否关联线程，不表示线程是否正在运行；`detach()` 也不是“后台线程自动安全管理”。
- **上位/下位知识**：`std::thread` 属于 C++ 并发基础；更高层的任务抽象包括 `std::async`、线程池和执行器。

### 与相近方案对比

- `pthread`：POSIX 平台线程 API，控制更底层、可移植范围不同；优先使用 `std::thread` 编写标准 C++ 代码。
- `std::async`：更关注异步任务结果和异常传播，适合不需要直接控制线程生命周期的任务。
- `std::jthread`：C++20 提供自动 join 和停止请求能力，能减少部分 `std::thread` 生命周期错误。

## 常见误区

- 认为线程函数返回后可以不处理 `std::thread` 对象。
- 认为 `joinable()` 等价于线程仍在运行。
- 在 `detach()` 后捕获局部变量引用。
- 对同一个线程重复调用 `join()` 或 `detach()`。
- 把 `hardware_concurrency()` 当作固定可用线程数。
- 认为线程函数异常会被 `join()` 调用方捕获。

## 应用场景

- **适合用在**：明确需要创建和等待工作线程、封装底层线程执行、学习线程生命周期和所有权管理。
- **不适合用在**：大量短任务调度、需要统一取消和自动回收的线程池、只关心异步结果的简单任务；这些场景可考虑线程池、`std::jthread` 或 `std::async`。

## 参考来源

- C++ 标准库 `<thread>`。
- [C++多线程并发基础入门教程](https://zhuanlan.zhihu.com/p/194198073)
- [C++11多线程编程详解](http://c.biancheng.net/view/8638.html)
- [C++11中std::thread的使用](https://zhuanlan.zhihu.com/p/389140084)

## 我的理解

`std::thread` 像一张“线程所有权凭证”：创建线程时拿到凭证，移动就是转交凭证，`join()` 是等它完成后收回，`detach()` 是放弃凭证让它自行完成；离开作用域前不处理凭证，程序就会终止。