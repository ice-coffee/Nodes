# C++ `std::thread` 知识卡片整理总结

## 完成内容

- 将原有 `C++多线程 - thread.md` 从 API 清单重构为结构化知识卡片。
- 添加 YAML frontmatter、标签、别名、创建日期和来源信息。
- 按“定义 → 核心理解 → 生命周期 → 常用用法 → 边界 → 关联概念 → 应用场景”的顺序组织内容。
- 保留并整理原笔记中的构造函数、移动语义、赋值操作、线程状态、线程控制函数及示例。
- 补充 `joinable()`、`join()`、`detach()` 的状态变化和所有权语义。
- 补充 `get_id()`、`swap()`、`native_handle()`、`hardware_concurrency()`、`yield()`、`sleep_for()` 和 `sleep_until()` 的使用说明。
- 添加线程参数传递、lambda、显式 `join()`、受限 `detach()` 和异常捕获示例。
- 补充线程对象析构、悬空引用、重复 `join()`/`detach()`、未捕获异常和硬件并发提示值等边界说明。
- 增加 `pthread`、`std::async` 和 `std::jthread` 的关联与选型对比。

## 修改文件

- `/Users/miaozepeng/Desktop/Nodes/C++/2. C++ 多线程/C++多线程 - thread.md`

## 规范产物

- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-thread-knowledge-card/doc.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-thread-knowledge-card/tasks.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-thread-knowledge-card/summary.md`

## 校验结果

- `tasks.md` 中 5 个顶层任务均已标记完成。
- 已检查 Markdown 章节结构和代码块完整性。
- 已检查原笔记中的有效 API 信息是否在新笔记中保留。
- 已检查关键生命周期和异常边界，未执行独立 C++ 编译；笔记中的示例需要在具体编译环境中补充业务定义（如 `work()`、`use()`、`report()`）后运行。
