# C++ 线程知识卡片整理方案

## 需求场景与处理逻辑

将现有 `C++多线程 - thread.md` 中关于 `std::thread` 的零散 API 记录整理为一张可复习、可实践的知识卡片，主题聚焦 C++ 标准线程对象及其生命周期管理，不扩展为完整的互斥锁、条件变量或线程池教程。

处理逻辑如下：

1. 保留 `std::thread` 的核心定位、构造与移动语义。
2. 按“定义 → 生命周期/所有权 → API 分类 → 最小示例 → 易错边界 → 关联概念”的顺序重组内容。
3. 修正原笔记中可能造成误解的表述：`joinable()` 表示线程对象关联可执行线程，不等价于“线程当前活跃”；`detach()` 不阻塞但会放弃直接管理线程生命周期；`std::thread` 对象在析构时仍 `joinable()` 会调用 `std::terminate()`。
4. 补充线程函数参数传递、异常场景、线程安全输出和 `hardware_concurrency()` 返回值仅为提示等实践要点。
5. 依据知识卡片规范生成 YAML frontmatter，并更新原文件为完整笔记。

## 架构与技术方案

- 知识卡片标题：`std::thread`。
- 标签：以 `C++`、`并发编程`、`线程`、`RAII` 为主，便于保存到现有 `C++/2. C++ 多线程/` 目录。
- API 分组：
  - 构造与移动：默认构造、可调用对象构造、移动构造、拷贝禁用。
  - 赋值与状态：移动赋值、`joinable()`、`get_id()`。
  - 生命周期管理：`join()`、`detach()`、析构约束。
  - 线程控制：`std::this_thread::yield()`、`sleep_for()`、`sleep_until()`。
  - 平台能力：`native_handle()`、`hardware_concurrency()`、`swap()`。
- 示例采用 C++11 及以上标准，优先展示“创建线程后明确 `join()`”的安全模式，并补充 lambda/参数传递示例。

## 受影响文件

### 主要修改文件

- `/Users/miaozepeng/Desktop/Nodes/C++/2. C++ 多线程/C++多线程 - thread.md`
  - 类型：重组并补充现有知识笔记内容。
  - 影响章节：全文，重点是 `thread`、`pthread` 前的 API 说明和示例。
  - 不修改外部业务代码，不新增 C++ 源文件。

### 规范产物

- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-thread-knowledge-card/doc.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-thread-knowledge-card/tasks.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-thread-knowledge-card/summary.md`

## 实现细节

笔记将采用以下结构：

```markdown
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
...

## 核心理解
...

## 详细解释
### 生命周期与状态
### 所有权与移动语义
### API 能力地图
...

## 常用用法
### 创建并等待线程
### 传递参数与 lambda
### `detach()` 的受限使用
### 当前线程休眠与让出调度
### 查询硬件并发提示
...

## 关键要点
...

## 例子与边界
### 正确的生命周期管理
### 反例：可 join 线程直接析构
### 反例：detach 后访问失效对象
### 异常处理边界
...

## 关系与连接
...

## 常见误区
...

## 应用场景
...

## 参考来源
...

## 我的理解
...
```

关键代码语义包括：

```cpp
std::thread worker([] { /* work */ });
if (worker.joinable()) {
    worker.join();
}
```

以及参数传递时明确对象生命周期：

```cpp
std::string value = "data";
std::thread worker([](std::string text) {}, value);
worker.join();
```

## 边界条件与异常处理

- 默认构造的线程对象不关联执行线程，不能直接调用 `join()` 或 `detach()`。
- 线程函数返回后，线程对象仍可能处于 `joinable()` 状态，必须显式 `join()` 或 `detach()`。
- 对仍 `joinable()` 的 `std::thread` 对象析构会导致 `std::terminate()`，示例和误区章节必须突出这一点。
- `join()` 只能调用一次；对不可 join 的对象调用 `join()`/`detach()` 会抛出 `std::system_error`。
- 线程函数抛出的未捕获异常不会传播到创建线程，应在线程函数内部处理，或通过 `std::promise`/`std::future` 等机制传递错误。
- `detach()` 后不能再通过该 `std::thread` 对象等待或控制线程，线程函数不得依赖已离开作用域的引用或对象。
- `hardware_concurrency()` 可能返回 `0`，且返回值只是实现提供的并发数提示，不能当作严格资源保证。
- 示例中的共享输出应避免暗示多个线程对 `std::cout` 进行无保护复杂组合操作是业务同步方案。

## 数据流路径

线程创建路径：调用方 → `std::thread` 构造函数 → 新线程执行可调用对象 → 线程函数结束 → 由调用方 `join()` 回收，或由 `detach()` 转为独立执行。

状态路径：

- 默认构造/移动后源对象：`joinable() == false`
- 构造成功且线程对象关联执行线程：`joinable() == true`
- `join()` 或 `detach()` 完成后：`joinable() == false`

控制路径：创建线程后，调用方根据生命周期策略选择等待回收或分离；当前线程可通过 `yield`、`sleep_for`、`sleep_until` 影响调度时机。

## 预期结果

- 原笔记从 API 清单升级为结构化 `std::thread` 知识卡片。
- 读者能够区分线程对象状态、线程执行状态与线程生命周期管理。
- 读者能够写出创建后正确回收线程的基础代码，并识别 `detach()`、析构和异常相关风险。
- 笔记保存至现有目录 `/Users/miaozepeng/Desktop/Nodes/C++/2. C++ 多线程/`，文件名保持为 `C++多线程 - thread.md`。