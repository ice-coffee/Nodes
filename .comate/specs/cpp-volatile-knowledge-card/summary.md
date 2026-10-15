# C++ `volatile` 知识卡片整理总结

## 完成内容

- 将原本只有一个参考链接的待整理文件重构为完整知识卡片。
- 添加 YAML frontmatter、标签、别名、来源和日期信息。
- 解释 `volatile` 的核心语义：保留对特殊对象的可观察访问，不是通用禁止优化开关。
- 补充 `volatile int*`、`int* volatile`、`const volatile int*` 等声明形式。
- 说明 `volatile` 与 CPU 缓存、指令重排序、内存屏障和 happens-before 的区别。
- 添加内存映射 I/O 和异步信号状态标记的使用场景及平台边界。
- 添加 `volatile` 停止标志和 `volatile` 计数器的多线程错误示例。
- 使用 `std::atomic<bool>` 展示线程停止标志的正确替代方式。
- 对比 `volatile`、`std::atomic` 和 `std::mutex` 的能力边界。
- 补充 `const_cast`、复合操作、数据竞争和对象生命周期相关误区。
- 保留原始参考链接，并补充 `std::atomic` 和内存序参考资料。

## 修改文件

- `/Users/miaozepeng/Desktop/Nodes/C++/2. C++ 多线程/C++多线程 - volatile（待）.md`

## 规范产物

- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-volatile-knowledge-card/doc.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-volatile-knowledge-card/tasks.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/cpp-volatile-knowledge-card/summary.md`

## 校验结果

- `tasks.md` 中 5 个顶层任务均已标记完成。
- 已检查 Markdown 章节、表格、代码块和参考来源。
- 已检查关键结论：`volatile` 不提供原子性、线程同步、内存序或数据竞争保护。
- 未执行独立 C++ 编译；内存映射 I/O 示例依赖具体平台地址和硬件环境，不能在普通用户态环境直接运行。
