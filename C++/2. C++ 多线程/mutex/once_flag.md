---
id: 20260706-001
tags: [C++, 并发编程, 线程同步, 一次性初始化]
aliases: [once_flag, std once_flag, 一次性标志, call_once flag]
created: 2026-07-06
updated: 2026-07-06
source: ""
status: draft
---

# std::once_flag

## 一句话定义
`std::once_flag` 是 C++ 标准库中配合 `std::call_once` 使用的状态标志，用来保证某段初始化逻辑在多线程环境下只成功执行一次。

## 核心理解
- **是什么**：一个不可复制、不可赋值的同步状态对象，本身不执行逻辑，只记录 `std::call_once` 的一次性执行状态。
- **为什么需要它**：多线程可能同时触发懒初始化，如果只用普通布尔变量判断，很容易出现竞态、重复初始化或看到半初始化状态。
- **它解决了什么问题**：把“一次且仅一次”的并发控制交给标准库，避免手写双重检查锁、手动状态位和复杂异常恢复逻辑。

## 详细解释
### 基本角色
`std::once_flag` 不是锁，也不是函数包装器，它更像是 `std::call_once` 的“状态存储”。

```cpp
#include <mutex>

std::once_flag flag;

void init();

void use() {
    std::call_once(flag, init);
}
```

这里真正执行控制的是 `std::call_once`，而 `flag` 负责保存这组调用是否已经有一次成功完成。

### 工作机制
多个线程使用同一个 `std::once_flag` 调用 `std::call_once` 时：

1. 第一个进入的线程会尝试执行传入函数。
2. 其他线程会等待这次执行完成，或者在执行失败后参与下一轮尝试。
3. 如果函数正常返回，`once_flag` 被标记为完成。
4. 之后再用同一个 `once_flag` 调用 `std::call_once`，传入函数不会再执行。
5. 如果函数抛出异常，本次不算成功，后续调用还会重新尝试。

### 对象特性
`std::once_flag` 通常作为静态对象、全局对象或类成员存在：

```cpp
class Service {
public:
    void use();

private:
    std::once_flag init_flag_;
    void init();
};
```

它不能复制，也不能赋值，因为复制一次性状态会让“到底初始化过没有”变得不明确。

### 内存可见性
`std::call_once` 成功完成后，对初始化过程中的写入会对后续通过同一个 `once_flag` 返回的线程可见。也就是说，其他线程不会看到一个标准意义上的“半初始化成功状态”。

## 常用用法
### 全局一次性初始化
作用：多个线程都可能调用入口函数，但资源只初始化一次。

```cpp
#include <mutex>

std::once_flag init_flag;
Resource* resource = nullptr;

void init_resource() {
    resource = new Resource();
}

void use_resource() {
    std::call_once(init_flag, init_resource);
    resource->use();
}
```

注意：`once_flag` 要和被保护的一次性逻辑对应，不能多个不相关初始化流程混用同一个标志。

### 类成员中的懒初始化
作用：对象内部某个资源需要在首次使用时才创建，同时要保证线程安全。

```cpp
class Logger {
public:
    void log(const std::string& msg) {
        std::call_once(init_flag_, [this] { init_file(); });
        write(msg);
    }

private:
    std::once_flag init_flag_;

    void init_file() {
        // 打开日志文件
    }

    void write(const std::string& msg) {
        // 写日志
    }
};
```

注意：lambda 捕获 `this` 时，要保证对象生命周期覆盖所有可能调用 `log()` 的线程。

### 函数局部静态变量的替代选择
作用：当初始化不只是构造一个对象，而是需要调用多步流程、带参数逻辑或显式异常重试时，可以用 `once_flag`。

```cpp
std::once_flag config_flag;
Config config;

void load_config_once(const std::string& path) {
    std::call_once(config_flag, [&] {
        config.load(path);
        config.validate();
    });
}
```

注意：第一次成功调用传入的参数会决定初始化结果；后续调用即使传入不同参数，也不会重新执行。

### 异常后重试
作用：初始化函数抛异常时，本次不标记完成，后续调用仍会再次尝试。

```cpp
std::once_flag flag;
int value = 0;

void init() {
    if (!connect()) {
        throw std::runtime_error("connect failed");
    }
    value = 42;
}

void use() {
    std::call_once(flag, init);
    // 只有 init 正常返回后，才会走到这里
}
```

注意：如果初始化一直失败，每次调用都可能继续抛异常；调用方仍然需要处理失败路径。

### 不要重置或复用状态
作用：`std::once_flag` 没有重置接口，设计上表达“一生只成功一次”。

```cpp
std::once_flag flag;

std::call_once(flag, init_a);
std::call_once(flag, init_b); // init_b 不会执行，因为同一个 flag 已经完成
```

注意：如果需要两个独立初始化流程，就应该使用两个 `std::once_flag`。

## 关键要点
- `std::once_flag` 本身只是状态标志，必须配合 `std::call_once` 才有意义。
- 同一个 `once_flag` 只会允许一次成功执行；异常退出不算成功，后续可以重试。
- `once_flag` 不能复制、不能赋值，也没有重置接口。
- 第一次成功调用的参数和捕获状态会决定最终初始化结果，后续调用不会再覆盖。
- 适合一次性初始化，不适合需要反复启停、重载或重新配置的生命周期管理。

## 例子与边界
### 正例：线程安全初始化日志系统
```cpp
#include <mutex>
#include <string>

std::once_flag log_init_flag;

void init_logger() {
    // 打开文件、创建目录、设置格式等一次性操作
}

void log_info(const std::string& message) {
    std::call_once(log_init_flag, init_logger);
    // 写入日志
}
```

这个写法适合“初始化一次，后面一直复用”的资源，例如日志系统、配置缓存、动态库符号加载等。

### 典型用法：单例初始化
```cpp
class Singleton {
public:
    static Singleton& instance() {
        std::call_once(flag_, [] {
            instance_ = new Singleton();
        });
        return *instance_;
    }

private:
    Singleton() = default;

    static std::once_flag flag_;
    static Singleton* instance_;
};

std::once_flag Singleton::flag_;
Singleton* Singleton::instance_ = nullptr;
```

现代 C++ 中，函数局部静态变量通常更简单：

```cpp
Singleton& instance() {
    static Singleton obj;
    return obj;
}
```

所以只有当初始化流程更复杂、需要显式控制异常或不能直接用局部静态对象时，才更倾向 `once_flag`。

### 反例：把一个 flag 用给多个初始化逻辑
```cpp
std::once_flag flag;

void init_network();
void init_logger();

void start() {
    std::call_once(flag, init_network);
    std::call_once(flag, init_logger); // 错误：不会执行
}
```

同一个 `once_flag` 代表同一个“一次性事件”，不是“每个函数各执行一次”的容器。

### 反例：期待它能重新初始化
```cpp
std::once_flag flag;

void reload_config() {
    std::call_once(flag, load_config); // 只会成功执行一次，不适合 reload
}
```

如果需求是配置热更新、连接重建或资源重新加载，应该使用普通互斥锁、读写锁、原子指针或专门的生命周期状态机。

### 边界情况
`std::once_flag` 的粒度很粗：它只表达“是否成功执行过一次”，不表达初始化中、已失败、已销毁、需要重载等复杂状态。需要多阶段状态时，不要强行用它承载业务状态。

## 关系与连接
- **前置知识**：线程、互斥锁、临界区、RAII、异常传播、对象生命周期。
- **关联概念**：`std::call_once`、函数局部静态变量、单例模式、懒初始化、双重检查锁、`std::mutex`。
- **容易混淆**：`std::once_flag` 不是 `bool`，不能手动读写，也不能判断当前是否已初始化；它的状态只能由 `std::call_once` 使用。
- **上位/下位知识**：上位是 C++ 并发同步机制；下位包括一次性初始化、线程安全单例、资源懒加载。

### 与相近概念对比
- `std::mutex`：用于保护可重复进入的临界区；`std::once_flag` 用于一次性成功执行。
- `std::atomic<bool>`：可以表达状态位，但不能自动保证初始化函数只执行一次，也难以正确处理异常和等待。
- 函数局部静态变量：适合构造一个静态对象，语法更简单；`once_flag` 更适合多步初始化、传参初始化或非对象构造流程。
- 双重检查锁：手写复杂且容易出错；`std::once_flag` + `std::call_once` 是标准库提供的更稳妥方案。

## 常见误区
- 以为 `std::once_flag` 可以像 `bool` 一样查询或重置；实际上它没有公开状态接口。
- 多个不同初始化任务共用一个 `once_flag`，导致后面的任务永远不执行。
- 忽略第一次成功调用的参数，误以为后续传入的新参数还能影响初始化。
- 在成员函数 lambda 中捕获 `this`，但没有保证对象生命周期，导致异步线程访问已销毁对象。
- 把它用于需要 reload、reset、stop/start 的业务流程，最后发现“一次性”语义太死。

## 应用场景
- **适合用在**：全局资源初始化、日志系统初始化、配置首次加载、插件或动态库符号解析、线程安全单例、缓存懒加载。
- **不适合用在**：需要反复初始化和销毁的资源、配置热更新、每次调用都要执行的临界区、需要查询初始化状态的业务状态机、需要按参数多次初始化的场景。

## 参考来源
- C++ 标准库 `<mutex>`
- cppreference: `std::once_flag`
- cppreference: `std::call_once`

## 我的理解
可以把 `std::once_flag` 理解成“一次性门票的验票章”：`std::call_once` 是验票员，初始化函数是入场动作；只有第一次真正入场成功后，这张票才会被盖章，之后再来都不会重新入场。如果第一次入场失败抛异常，票还没盖章，下一次还能再试。
