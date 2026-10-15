[toc]

[ThreadLocal 解析](https://xucanhui.com/2019/04/23/ThreadLocal-analysis/#ThreadLocal%E5%A6%82%E4%BD%95%E5%81%9A%E5%88%B0%E7%BA%BF%E7%A8%8B%E5%AE%89%E5%85%A8)

[ThreadLocal 的总结思考](https://toutiao.io/posts/w8j9fu/preview)

[将ThreadLocal变量设置为private static的好处是啥？](https://www.zhihu.com/question/35250439)

### 概述
`ThreadLocal` 用于提供线程局部变量，`ThreadLocal` 会给每个访问它的线程提供一份互不影响的变量副本，线程可以安全的访问 `ThreadLocal` 变量。

示例代码：

```java
import java.util.concurrent.atomic.AtomicInteger;

public class ThreadId {
   private static final AtomicInteger nextId = new AtomicInteger(0);

   private static final ThreadLocal<Integer> threadId =
       new ThreadLocal<Integer>() {
           @Override protected Integer initialValue() {
               return nextId.getAndIncrement();
       }
   };

   public static int get() {
       return threadId.get();
   }
}
```

首先 `ThreadLocal` 是线程安全的，但是 `initialValue()` 方法初始化值时并没有和当前线程关联所以需要保证初始化值时的线程安全。

通常在使用 `ThreadLocal` 变量时会将其设为 `static` 以防止 `TheadLocal` 对象被多次创建。

### 源码分析
#### ThreadLocalMap 哈希算法
斐波那契哈希算法

#### 为什么 ThreadLocalMap 要使用 WeakReference 封装 key
为了让线程销毁之后 `Key` 可以在下一次 `GC` 时被回收，

#### ThreadLocal 为什么不使用 HashMap 而是自定义的 ThreadLocalMap
`开放寻址方式`：

- 优点：只用数组一种数据结构存储，继承了数组的优点，对CPU缓冲友好，易于序列化。
- 缺点：内存的利⽤率低（数组的特性）。删除操作不宜实现。
- 总结：当数据量⽐较⼩、装载因⼦⼩的时候，适合采⽤开放寻址法。这也是Java中的ThreadLocalMap使⽤开放寻址法解决散列冲突的原因。

`链表法`：

- 优点：内存利用率高（链表的特性）。
- 缺点：指针需要额外的空间。
- 总结：基于链表的散列冲突处理⽅法⽐较适合存储⼤对象、⼤数据量的散列表，⽽且，⽐起开放寻址法，它更加灵活，⽀持更多的优化策略，⽐如⽤红⿊树代替链表。

结合实际，线程本地变量数量大概率不多，而且访问操作大概率比增删操作要多，所以这里选择开放寻址法就顺理成章了。总结使用开放寻址法有以下的考虑因素：

1. 节省内存空间，链表使用的空间大于数组；
2. ThreadLocal设计的哈希key可以尽可能避免哈希冲突；
3. 清理数据效率高，毕竟遍历数组比遍历链表效率高；

### QA
#### 内存泄漏
一般说 `ThreadLocal` 存在内存泄漏风险是因为在存储到 `ThreadLocalMap` 时，虽然作为 `key` 的 `ThreadLocal` 被封装为了弱引用对象，但是 `value` 值还是强引用。
解决方式就是在不使用时调用 `remove` 将其移除。

至于说为什么 `key、value` 一个封装成弱引用一个没有，我觉的可能有这样几个原因：

1. `ThreadLocal` 百分百是一个引用对象存在于某个类中，如果使用强引用，但类对象被销毁时会造成内存泄漏。
2. 至于真正存储的 `value` 可能是基本数据类型也可能是引用类型，那么概率来说即使不调用 `remove` 也不会产生泄漏。
3. 而直接将 `value` 也封装成弱引用会导致使用变的繁琐，每次使用前必须先判空。所以不如添加 `remove` 方法在不使用时移除来的方便。

结合上述几点原因也就理解了`ThreadLocal` 这么设计的原因。

#### ThreadLocal 如何做到线程安全
- 每个线程都拥有独立的 `threadLocals` 变量（指向 `ThreadLocalMap` 对象）;
- 每当线程访问 `threadLocals` 变量时，访问的都是各自线程自己的 `ThreadLocalMap` 对象；
- `ThreadLocalMap` 访问的 `key` 值为当前的`ThreadLocal` 实例。

上述3点，保证了线程间的数据访问隔离，即线程安全。
