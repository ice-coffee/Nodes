---
id: 20260718-002
tags: [C++, 并发编程, volatile, 原子操作]
aliases: [volatile 关键字, volatile qualifier, 易失性类型限定符]
created: 2026-07-18
updated: 2026-07-18
source: "C/C++ 中 volatile 关键字详解"
status: draft
---

# C++ `volatile`

## 一句话定义

`volatile` 告诉编译器：对该对象的访问具有语言之外的可观察影响，不能把这些访问当作普通对象访问随意合并、删除或缓存。

## 核心理解

- **是什么**：C++ 的类型限定符，用于标记可能被硬件、信号处理程序或其他编译器不可见机制改变的对象。
- **为什么需要它**：某些对象的每次读写本身就是有意义的，例如访问内存映射设备寄存器。
- **它解决了什么问题**：约束编译器对 volatile 访问的优化；它不解决线程同步、原子性或数据竞争问题。

### 与 Java `volatile` 的区别

C++ 和 Java 虽然都使用 `volatile` 关键字，但两者的并发语义不同：

| 对比项 | C++ `volatile` | Java `volatile` |
| --- | --- | --- |
| 主要作用 | 保留对特殊对象的访问，常用于硬件寄存器等底层场景 | 保证线程间可见性，并提供规定的内存顺序 |
| 线程间可见性 | 不保证 | 保证对 volatile 变量的写入可被后续读取观察到 |
| happens-before | 不建立 | 对同一 volatile 变量的写入 happens-before 后续读取 |
| 读写原子性 | 不保证 | 单次 volatile 变量读写具有 Java 内存模型规定的原子语义 |
| `++` 等复合操作 | 不原子 | 也不原子 |
| 多线程常用替代 | `std::atomic`、`std::mutex` | `volatile`、`Atomic*`、`synchronized`、`Lock`，按需求选择 |
| 典型场景 | 内存映射 I/O、设备寄存器、受限信号处理 | 停止标志、状态发布、简单线程通信 |

例如，Java 可以用 volatile 标志通知线程停止：

```java
private volatile boolean stop = false;

public void run() {
    while (!stop) {
        doWork();
    }
}
```

同样的写法不能直接移植到标准 C++：

```cpp
volatile bool stop = false; // 错误：不能用于安全的线程通信
```

C++ 应使用：

```cpp
std::atomic<bool> stop{false};
```

两种语言中 `volatile` 都不能让复合更新变成原子操作。例如 Java 的 `count++` 和 C++ 的 `++count` 都包含读—改—写步骤；并发计数应分别使用 Java `AtomicInteger` 或 C++ `std::atomic<int>`。

可以这样记忆：

- **C++ `volatile`**：不要省略这次特殊访问。
- **Java `volatile`**：让线程观察到最新写入，并遵守 Java 内存模型规定的顺序。

## 详细解释

### volatile 的访问语义

```cpp
volatile int status;

int value = status; // 一次 volatile 读取
status = 1;         // 一次 volatile 写入
```

对 volatile 对象的读写属于可观察行为，编译器必须按照规则生成相应访问。它的重点是“这次访问不能被无理由消除或合并”，而不是保证对象一定放在物理内存中。

`volatile` 也不是一个通用的“禁止优化”开关。它只影响涉及 volatile 对象的访问，不能阻止编译器优化其他代码。

#### 普通访问与 volatile 访问对比

```cpp
int ordinary_status = 0;
volatile int device_status = 0;

while (ordinary_status == 0) {
    // 如果当前程序中没有可见的修改路径，编译器可以优化普通读取。
}

while (device_status == 0) {
    // 每轮条件判断都包含一次 volatile 读取，编译器必须保留该访问。
}
```

第二个循环只有在 `device_status` 确实可能被硬件、信号处理程序或实现明确支持的外部机制修改时才有意义。若修改来自另一个 C++ 线程，这仍不是合法的同步方案，应该使用 `std::atomic`。

### 与 CPU 缓存和内存屏障的区别

`volatile` 的约束主要作用在编译器层面，不等于：

- CPU 缓存立即刷新；
- CPU 指令不会重排序；
- 多线程之间建立 happens-before 关系；
- 一个复合操作变成原子操作；
- 多个线程访问时自动避免数据竞争。

如果目标是线程间通信，应使用 `std::atomic`、`std::mutex`、条件变量或其他标准同步原语。

### 声明形式

```cpp
volatile int* p1;          // p1 是普通指针，指向 volatile int
int* volatile p2;          // p2 本身是 volatile 指针，指向普通 int
const volatile int* p3;    // p3 指向只读且 volatile 的 int
volatile int* const p4;    // p4 是不可改指向的普通指针，指向 volatile int
```

判断方法是：限定符靠近谁，就修饰谁。

- `volatile int*`：`p1` 是普通指针，指向的数据按 volatile 方式访问；`p1` 可以重新指向其他地址。
- `int* volatile`：`p2` 本身是 volatile 指针，读取或写入 `p2` 时保留访问；`*p2` 指向普通 int。
- `const volatile int*`：`p3` 指向只读且 volatile 的数据，可以读取但不能通过 `p3` 修改；读取仍具有 volatile 语义。
- `volatile int* const`：`p4` 不能重新指向其他地址，但它指向的数据是 volatile，仍可以通过 `p4` 写入非 const 数据。

```cpp
int normal_a = 1;
int normal_b = 2;
volatile int device_value = 3;

volatile int* p1 = &device_value;
p1 = &device_value; // p1 本身普通，可以改变指向
int* volatile p2 = &normal_a;
p2 = &normal_b;     // p2 本身 volatile，但仍然可以重新指向

int read = *p1;     // volatile 读取
*p2 = 4;            // 普通 int 写入
```

这里不存在“再次把同一个对象变得更 volatile”的问题：对象定义决定对象类型，指针声明则告诉编译器通过这条指针访问时应采用什么类型和访问语义。

### 能力边界总览

| 能力 | `volatile` | `std::atomic` | `std::mutex` |
| --- | :---: | :---: | :---: |
| 保留特殊对象访问 | 是 | 不是主要目的 | 不是主要目的 |
| 单次操作原子性 | 否 | 是，取决于类型和操作 | 临界区内保证 |
| 线程间同步 | 否 | 支持内存序 | 支持 |
| 防止数据竞争 | 否 | 对原子对象的访问不产生数据竞争 | 正确加锁时可以 |
| 保护多个对象组成的不变量 | 否 | 通常不适合 | 适合 |

## 常用用法

### 内存映射 I/O

在嵌入式或操作系统底层代码中，设备寄存器可能映射到固定地址。此时读写动作本身就是与硬件交互，不能被当作普通变量访问删除或合并。

#### 轮询状态寄存器

```cpp
#include <cstdint>

constexpr std::uintptr_t status_address = 0x40000000u;
auto* const status =
    reinterpret_cast<const volatile std::uint32_t*>(status_address);

while ((*status & 0x01u) == 0) {
    // 每轮循环保留一次读取，等待硬件设置 ready 位。
}
```

`const` 表示程序不能通过该指针写寄存器，`volatile` 表示每次读取都必须保留。它适合表达“由硬件更新、程序只读”的状态寄存器。

#### 向控制寄存器写入命令

```cpp
constexpr std::uintptr_t control_address = 0x40000004u;
auto* const control =
    reinterpret_cast<volatile std::uint32_t*>(control_address);

*control = 0x01u; // 这次写入可能表示“启动设备”命令
```

对普通内存而言，连续写入相同值有时可以被优化；对设备寄存器而言，每次写入都可能触发硬件动作，因此需要保留访问。

#### 同一寄存器的多次读取

```cpp
std::uint32_t first = *status;
std::uint32_t second = *status;
```

即使两行之间没有普通 C++ 代码修改寄存器，硬件也可能已经改变其状态，所以 `first` 和 `second` 可能不同。`volatile` 要求保留两次读取，而不是直接复用第一次结果。

这里的示例只说明 volatile 访问语义。真实设备代码还必须遵守平台规定的地址映射、访问宽度、对齐、寄存器副作用、内存属性和屏障要求；`volatile` 本身不等于硬件内存屏障，普通用户态程序也不能直接访问这些示例地址。

### 异步信号处理中的状态标记

传统 C/C++ 代码可能使用 `volatile std::sig_atomic_t` 保存信号处理程序和主流程之间的简单状态：

```cpp
#include <csignal>

volatile std::sig_atomic_t received = 0;

void on_signal(int) {
    received = 1;
}

int main() {
    std::signal(SIGINT, on_signal);

    while (received == 0) {
        // 主流程重复读取标志；不要在这里类比线程同步。
    }
}
```

这里的异步变化来自信号处理程序，而不是另一个普通 C++ 线程。信号处理函数可安全执行的操作受到严格限制，通常只应修改简单标志；不要在其中操作复杂 C++ 对象、执行不安全的库调用或把这种模式泛化成线程通信方案。具体可行性还要遵循 C++ 标准与目标平台约束。

### 普通对象不应为了“防止缓存”而加 volatile

```cpp
int value = read_value();
// 不要仅因为 value 可能被其他线程读取，就改成 volatile int
```

多线程共享普通对象时，应根据需求选择原子变量或锁，而不是添加 `volatile`。

## 关键要点

- `volatile` 保留特殊对象访问，不等于通用禁止优化。
- `volatile` 不提供原子性、线程同步、内存顺序或数据竞争保护。
- `volatile int counter++` 仍然是读—改—写复合操作，不能安全地并发自增。
- 设备寄存器是常见使用场景；线程停止标志通常应使用 `std::atomic<bool>`。
- `std::ref`、`volatile` 和 `std::atomic` 解决的是不同问题，不能互相替代。

## 例子与边界

### 正例：使用原子变量作为线程停止标志

```cpp
#include <atomic>
#include <thread>

std::atomic<bool> stop{false};

void worker() {
    while (!stop.load()) {
        do_work();
    }
}

std::thread thread(worker);
// 请求停止
stop.store(true);
thread.join();
```

`std::atomic<bool>` 保证对停止标志的读写具有原子性，并提供标准定义的线程间同步语义。

### 反例：用 volatile 实现线程停止标志

```cpp
volatile bool stop = false;

void worker() {
    while (!stop) {
        do_work();
    }
}

// 另一个线程修改 stop
stop = true;
```

这段代码不能作为标准 C++ 的线程通信方案。两个线程无同步地读写同一个非原子对象，构成数据竞争，行为未定义；加上 `volatile` 并不会改变这一点。

### 反例：volatile 不能让自增操作原子化

```cpp
volatile int counter = 0;

// 多个线程同时执行
++counter;
```

`++counter` 至少包含读取、加一、写回三个步骤，多个线程可能互相覆盖结果。应改用：

```cpp
std::atomic<int> counter{0};
++counter;
```

或者用互斥锁保护整个临界区。

### 反例：volatile 不能保护多个变量的一致性

```cpp
volatile int width = 0;
volatile int height = 0;

// 线程 A
width = 100;
height = 200;

// 线程 B
int area = width * height;
```

线程 B 可能观察到一个新值和一个旧值，而且这些无同步读写本身就构成数据竞争。`volatile` 既不能把两个赋值合并成一个原子事务，也不能建立线程间顺序。

如果多个字段共同描述一个状态，应使用互斥锁保护整个临界区：

```cpp
#include <mutex>

int width = 0;
int height = 0;
std::mutex dimensions_mutex;

void update_dimensions() {
    std::lock_guard<std::mutex> lock(dimensions_mutex);
    width = 100;
    height = 200;
}

int read_area() {
    std::lock_guard<std::mutex> lock(dimensions_mutex);
    return width * height;
}
```

### 正例：用 release/acquire 发布数据

当一个原子标志还用于通知“其他普通数据已经准备好”时，可以通过 release/acquire 建立同步关系：

```cpp
#include <atomic>

int data = 0;
std::atomic<bool> ready{false};

void producer() {
    data = 42;
    ready.store(true, std::memory_order_release);
}

void consumer() {
    while (!ready.load(std::memory_order_acquire)) {
    }

    use(data); // 读取到 true 后，可以观察到 producer 对 data 的写入
}
```

`volatile bool ready` 无法提供这种 happens-before 关系。若不需要手工控制内存序，使用 `std::atomic` 的默认顺序更简单；若等待时间不可控，还应考虑条件变量，避免持续忙等。

### 反例：通过去除 volatile 规避限制

```cpp
volatile int device_status = 0;
int* ordinary = const_cast<int*>(&device_status);
*ordinary = 1; // 不应以此方式访问实际的 volatile 对象
```

如果对象最初就是以 volatile 类型定义，去掉限定符后按普通对象访问可能导致未定义行为，不能作为优化或兼容问题的通用修复方法。

### 边界情况

- 设备寄存器访问必须配合平台规定的内存属性、屏障、访问宽度和顺序；单独写 `volatile` 不一定完成平台所需的全部工作。
- 如果要保护多个共享变量之间的不变量，单个原子变量通常也不够，应使用互斥锁或更高层同步结构。
- 如果只需要线程之间传递一个状态值，优先考虑 `std::atomic`；如果需要等待状态变化，结合条件变量通常比轮询更合适。

## 关系与连接

- **前置知识**：类型限定符、指针、未定义行为、C++ 内存模型。
- **关联概念**：`std::atomic`、`std::mutex`、内存序、happens-before、内存映射 I/O、信号处理。
- **容易混淆**：`volatile` 关注编译器对特殊访问的保留；`std::atomic` 关注并发访问的原子性与同步。
- **上位/下位知识**：`volatile` 属于 C++ 类型系统和底层编程工具；线程同步属于并发支持库。

### 与相近概念对比

- `volatile`：让特殊访问保持可观察，不负责线程安全。
- `std::atomic<T>`：提供对特定对象的原子操作和内存序，可用于线程通信。
- `std::mutex`：通过互斥保护临界区，适合维护多个变量组成的一致性。
- 编译器屏障/硬件内存屏障：属于更底层的平台或编译器机制，不能简单用 `volatile` 替代。

## 常见误区

- 认为 `volatile` 能解决多线程可见性问题。
- 认为每次读取 volatile 都一定绕过 CPU 缓存访问物理内存。
- 认为 volatile 变量的 `++` 是原子的。
- 认为给普通共享变量加 volatile 就能避免数据竞争。
- 认为 `volatile` 能替代 `std::atomic` 或 `std::mutex`。
- 通过 `const_cast` 去除 volatile 后继续访问设备或信号相关对象。

## 应用场景

- **适合用在**：内存映射设备寄存器、特定平台硬件状态访问、受约束的异步信号状态标记。
- **不适合用在**：线程停止标志、线程计数器、锁、任务队列、多个共享字段的一致性保护和一般意义上的“防止编译器优化”。

## 参考来源

- [C/C++ 中 volatile 关键字详解](https://www.runoob.com/w3cnote/c-volatile-keyword.html)
- C++ 标准类型限定符与并发支持库：`volatile`、`std::atomic`、`std::mutex`
- [cppreference: `std::atomic`](https://en.cppreference.com/w/cpp/atomic/atomic)
- [cppreference: `std::memory_order`](https://en.cppreference.com/w/cpp/atomic/memory_order)

## 我的理解

`volatile` 像是在告诉编译器：“每次访问这个对象都可能有外部意义，请不要把访问当成普通变量随意省略。”但它没有告诉多个线程如何安全协作；线程通信要用 `std::atomic`，保护复杂共享状态要用 `std::mutex`。