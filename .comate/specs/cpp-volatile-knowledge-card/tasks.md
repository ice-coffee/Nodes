# 整理 C++ `volatile` 知识卡片任务计划

- [✓] Task 1: 重构 volatile 笔记基础结构
    - 1.1: 添加知识卡片 YAML frontmatter
    - 1.2: 将现有参考链接保留到参考来源章节
    - 1.3: 建立定义、核心理解、详细解释、关键要点和应用场景等标准章节
    - 1.4: 明确 `volatile` 的核心语义不是通用禁止优化开关

- [✓] Task 2: 解释 volatile 访问语义与声明形式
    - 2.1: 说明 volatile 对象可能被程序常规执行路径之外的因素改变
    - 2.2: 说明编译器需要保留对 volatile 对象的可观察访问
    - 2.3: 区分 `volatile int*`、`int* volatile` 和 `const volatile int*`
    - 2.4: 说明 `const` 与 `volatile` 组合的读取和修改限制

- [✓] Task 3: 补充 volatile 的正确使用场景
    - 3.1: 添加内存映射 I/O 的示例和平台依赖说明
    - 3.2: 说明异步信号处理中的传统使用边界
    - 3.3: 解释 volatile 访问、编译器优化、CPU 缓存和硬件行为之间不能简单等同

- [✓] Task 4: 纠正多线程场景中的 volatile 误用
    - 4.1: 添加 `volatile` 停止标志和计数器的错误示例
    - 4.2: 解释 volatile 不提供原子性、同步、内存顺序或数据竞争保护
    - 4.3: 使用 `std::atomic<bool>` 展示线程停止标志的正确替代方案
    - 4.4: 对比 `volatile`、`std::atomic` 和 `std::mutex` 的能力边界
    - 4.5: 补充 `const_cast` 去除 volatile、复合操作和对象生命周期相关误区

- [✓] Task 5: 校验并完成 volatile 知识卡片
    - 5.1: 检查 Markdown 结构、代码块和表格格式
    - 5.2: 检查现有链接、术语和多线程结论是否准确
    - 5.3: 检查笔记是否覆盖适用场景、不适用场景和关键边界
    - 5.4: 更新任务状态并生成最终 summary.md
