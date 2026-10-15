`ArrayList`：
使用数组实现的列表结构，支持列表操作。

优点：

- 数组操作封装。
- 支持动态扩容。

缺点：

- 存储基本类型需要自动装箱和拆箱损耗性能。
- 动态扩容涉及内存申请和数据搬移，比较耗时。如果事先能确定要存储数据的大小，最好在创建ArrayList时事先指定数据大小。

数组 `VS` ArrayList：

- 当数据大小已知，且对性能有要求的使用数组。

`LinkedList`：
使用链表实现的列表结构，支持列表操作。

`ArrayList VS LinkedList`：

- 链表和数组的区别

`ArrayList` VS `Vector`：

- `Vector` 线程安全, `ArrayList` 线程不安全；
- `Vector` 扩容将翻倍，`ArrayList` 扩容只会增加 `50%`。
