# 扩展 C++ `volatile` 实际作用示例任务计划

- [x] Task 1: 扩展 volatile 基础访问示例
    - 1.1: 增加普通变量与 volatile 变量的循环读取对比
    - 1.2: 说明 volatile 影响的是编译器对访问的处理
    - 1.3: 明确 volatile 不等于通用禁止优化或 CPU 缓存刷新

- [x] Task 2: 补充硬件和底层场景示例
    - 2.1: 增加内存映射状态寄存器读取示例
    - 2.2: 增加向控制寄存器写入命令的示例
    - 2.3: 说明硬件寄存器多次读取可能产生不同结果
    - 2.4: 增加 `const volatile` 只读状态寄存器示例
    - 2.5: 补充平台地址、访问宽度、内存屏障和硬件文档边界

- [x] Task 3: 补充指针、信号和声明形式示例
    - 3.1: 通过代码对比 `volatile int*` 与 `int* volatile`
    - 3.2: 说明 volatile 修饰指针本身和指向数据时的访问差异
    - 3.3: 补充 `volatile std::sig_atomic_t` 简单信号状态示例
    - 3.4: 说明信号处理函数的操作限制

- [x] Task 4: 扩展多线程错误与正确方案对比
    - 4.1: 增加 volatile 停止标志错误示例
    - 4.2: 增加 volatile 计数器和 `++` 非原子示例
    - 4.3: 增加 volatile 多变量状态不一致示例
    - 4.4: 补充 `std::atomic<bool>` 停止标志示例
    - 4.5: 补充 release/acquire 发布数据和 `std::mutex` 保护复合状态示例

- [x] Task 5: 校验并完成笔记更新
    - 5.1: 检查新增代码示例的语义、注释和边界说明
    - 5.2: 检查 `volatile`、`std::atomic`、`std::mutex` 的职责表述
    - 5.3: 检查 Markdown 章节、代码块和参考来源完整性
    - 5.4: 更新任务状态并生成 summary.md
