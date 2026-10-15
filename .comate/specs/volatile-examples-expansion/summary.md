# C++ `volatile` 实际作用示例扩展总结

## 完成内容

- 在 `volatile.md` 的基础访问章节中增加普通变量与 volatile 变量轮询读取对比。
- 明确 `volatile` 约束的是编译器对访问的处理，不是通用禁止优化、CPU 缓存刷新或硬件内存屏障。
- 扩展内存映射 I/O 示例：
  - 轮询只读状态寄存器；
  - 向控制寄存器写入命令；
  - 同一寄存器多次读取可能得到不同结果；
  - 说明 `const volatile` 的只读硬件状态表达。
- 补充平台依赖边界，包括地址映射、访问宽度、对齐、寄存器副作用、内存属性和屏障。
- 通过代码对比 `volatile int*` 与 `int* volatile`，说明 volatile 修饰指向数据还是指针本身。
- 补充 `volatile std::sig_atomic_t` 信号状态示例和信号处理函数限制。
- 扩展多线程反例：
  - volatile 停止标志；
  - volatile 计数器和非原子 `++`；
  - volatile 多变量状态一致性。
- 补充正确方案：
  - `std::atomic<bool>` 停止标志；
  - release/acquire 发布普通数据；
  - `std::mutex` 保护多个字段组成的复合状态。

## 修改文件

- `/Users/miaozepeng/Desktop/Nodes/C++/2. C++ 多线程/volatile.md`

## 规范产物

- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/volatile-examples-expansion/doc.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/volatile-examples-expansion/tasks.md`
- `/Users/miaozepeng/Desktop/Nodes/.comate/specs/volatile-examples-expansion/summary.md`

## 校验结果

- 5 个顶层任务均已标记完成。
- 已检查新增章节、代码块、指针声明和职责对比。
- 已确认笔记没有把 `volatile` 描述为线程同步、原子性或 CPU 缓存刷新机制。
- 未执行硬件寄存器示例；示例地址和访问方式依赖具体平台，不能在普通用户态环境直接运行。
