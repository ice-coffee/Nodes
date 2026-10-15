[toc]

### 参考链接
[【BAT面试题系列】面试官：你了解乐观锁和悲观锁吗？](https://www.cnblogs.com/kismetv/p/10787228.html#t3)

### 原子变量类
`原子变量类` 是 `Java` 提供的一系列通过 `volatile` 和 `Unsafe` 保证数据线程安全的数据类型。原子变量保证了单个变量操作的原子性和可见性。

原子变量类可分为：

* **标量类**：`AtomicBoolean、AtomicInteger、AtomicLong、AtomicReference<V>`
* **更新器类**：`AtomicIntegerFieldUpdater、AtomicLongFieldUpdater、AtomicReferenceFieldUpdater`
* **数组类**：`AtomicIntegerArray、AtomicLongArray、AtomicReferenceArray`
* **复合变量类**：

### CAS 原理简介
`CAS（Compare-and-swap）`：比较和替换，它是设计非阻塞并发算法的一种常用技术。使用 `CAS` 操作可用于保证变量更新的原子性和可见性。

#### 原子性
> 原子性：指一系列操作作为一个整体被执行，不会被其他线程操作干扰。

`CAS` 操作涉及到 `3` 个值：

- `V` 当前值：变量当前在内存中的值
- `A` 期望值：期望变量当前在内存中的值
- `B` 更新值：准备为变量赋予的新值

`CAS` 操作逻辑如下：`CAS` 比较 `V` 和 `A` 的值，如果值相等则变量值更新为 `B`，否则不进行任何操作。如下图：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/cas_process.jpg)

如果第一次接触到 `CAS` 的概念可能对它的操作逻辑产生疑惑，为什么在相等的情况下执行赋值操作而不等的情况下反而什么都不做呢？下面看一个自增操作的示例：
```java
/**
 * Atomically increments by one the current value.
 *
 * @return the updated value
 */
public final int incrementAndGet() {
    for (;;) {
        //获取当前值, 此示例中当前值也是本次 `CAS` 的期望值
        int current = get();
        //获取更新值
        int next = current + 1;
        //执行CAS操作
        if (compareAndSet(current, next)) {
            //成功后才会返回期望值，否则无线循环
            return next;
        }
    }
}
```

现在有线程 `A、B`，当线程 `A` 执行到 `CAS` 操作, 获取当前值、期望值和更新值分别为 `0、0、1`, 此时线程 `A` 被挂起，线程 `B` 进入执行 `CAS` 操作将变量值成功更新为 `1`, 线程 `A` 继续执行 `CAS` 操作, 由于此时变量当前值已经被修改，所以本次 `CAS` 执行失败，循环继续执行 `CAS` 自增操作，执行成功退出循环。这样就可以保证在多线程场景下数据可以安全的自增。

#### 可见性
原子变量类是通过 `volatile` 关键字和 `Unsafe` 实现的。`volatile` 可以保证所修饰变量的内存可见性，而 `Unsafe` 更是可以直接操作内存。`volatile + Unsafe` 保证了原子变量类数据更新是对其它线程是可见的。

#### ABA 问题
除了上文提到过 `CAS` 的两个缺点：

- 仅能保证单个变量操作的原子性；
- 在高并发情况下 `CAS` 一直失败会一直重试，浪费 `CPU` 资源针。对这个问题的一个思路是引入退出机制，如重试次数超过一定阈值后失败退出。当然，更重要的是避免在高并发环境下使用 `CAS`。

现有线程 `A、B`：

1. 线程 `1` 读取内存中的数据为 `A`；
2. 线程 `2` 修改内存数据为 `B`；
3. 线程 `2` 修改内存数据为 `A`；
4. 线程 `1` 对数据执行 `CAS` 操作。

由于执行到第四步时内存数据仍然为 `A`，但其实数据已经被修改过了。这就是 `ABA` 问题。针对 `ABA` 问题可以通过引入版本号的方式解决，每次修改内存中的值版本号都 `+1`，在执行 `CAS` 操作是不仅比较内存中的值也比较版本号，只有两者都相同时才执行成功。`Java` 中提供的 `AtomicStampedReference` 类也是通过版本号来解决 `ABA` 问题的。

### 非阻塞同步机制


### 原子变量 VS 锁
原子变量是比锁更细粒度、更轻量级的线程安全机制。原子变量将发生竞争的范围缩小到单个变量上，这是我们可以获得最细粒度的情况。

**`性能开销：`**
**锁：** 在多线程场景下通过锁来保证对数据的安全访问，会造成线程的挂起和恢复，在这个过程中存在着很大的开销。而且如果锁范围内是细粒度的操作，那么当锁上存在激烈的竞争时，调度开销与工作开销的比值会非常高。
**CAS：** 单次 `CAS` 操作的开销远低于线程挂起和恢复。但随着线程竞争越激烈，`CAS` 重试的次数越多消耗的 `CPU` 资源越多。

**`安全性：`**
**锁：** 存在死锁、活锁或其他活跃性故障的风险。
**CAS：** 没有传统锁机制所产生的安全性风险。


通过上面的示例知道 `CAS` 可以保证变量更新的原子性，进而可以联想到 `volatile` 关键字的功能缺陷。

先来看 `volatile` 关键字的作用，如下：

- 有序性：防止重排序；
- 可见性：变量更新时所有线程都可以访问到变量的最新值；
- 原子性：只能保证单次读、写操作的原子性。

`volatile` 关键字的缺陷正是其无法保证变量操作的原子性，比如单目运算符 `++、--` 就涉及到读写两个操作。所以经常可以看到 `volatile` 和 `synchorinzed` 关键字共用的场景以保证变量操作的原子性，而 `CAS` 也可以保证变量操作的原子性。那 `CAS` 是否可以替代 `synchorinzed` 呢？在某些情况下是可以的。

比如在上面的示例中，`AtomicInteger().getAndIncrement()` 的内部源码如下：

```java
/**
 * Atomically increments by one the current value.
 * 
 * @return the previous value
 */
public final int getAndIncrement() {
    return U.getAndAddInt(this, VALUE, 1);
}

public final int getAndAddInt(Object var1, long var2, int var4) {
    int var5;
    do {
        var5 = this.getIntVolatile(var1, var2);
    } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

    return var5;
}
```

可以看到这里就是通过 `volatile + CAS` 的操作来保证变量操作安全性的。

那下面对 `CAS` 和 `synchorinzed` 的使用做下对比，主要从如下两方面：

功能限制：

- `CAS` 更加轻量级，`synchorinzed` 升级为重量锁时会影响系统性能；
- `CAS` 仅能保证单个变量操作的原子性，`synchorinzed` 可以保证代码块内所有变量操作的原子性。

并发规模：

- 低并发：`CAS` 更具优势，`synchorinzed` 在少量情况下仍可能升级为重量锁影响系统性能。
- 高并发：`synchorinzed` 更具优势，由于 `CAS` 的很多实现都会使用了自旋操作（如下文将介绍的 `Atomic***` 系列），当在大量线程的情况下 `CAS` 会频繁执行失败进而需要频繁重试，这样会浪费 `CPU` 资源。


### 使用场景
在少量线程且仅需保证单个变量线程安全的情况下可使用 `volatile + CAS` 替代 `synchorinzed`。

> 注意：`volatile + CAS` 和 `synchorinzed` 使用时要理解它们各自的角色和起到的作用：
> - `synchorinzed`：可见性、有序性和原子性；
> - `volatile`：保证有序性和可见性；
> - `CAS`：保证操作原子性；

> 注意：多线程环境下正确使用 `CAS` 必须搭配 `volatile` 关键字。因为 `CAS` 虽然可以保证原子性，但其无法保证变量在不同线程内存空间的安全性，所以需要 `volatile` 来保证变量更新对于不同线程是可见的。

### 原子变量分类
在 `Android` 中我们也可以通过 `Atomic***` 类来使用 `volatile + CAS`。

- `AtomicFile`
- `AtomicInteger`
- `AtomicLong`
- `AtomicBoolean`
- `AtomicReferenceFieldUpdater`
- `AtomicStampedReference`

前几个比较好理解，分别可以保证 `file、int、long、boolean` 类型数据的原子操作，那么如果操作数据为 `String` 或类型不可知怎么办呢？这时候就可以使用 `AtomicReferenceFieldUpdater()` 了。在 `Kotlin.lazy` 的实现中就使用到了 `AtomicReferenceFieldUpdater`：

```
private class SafePublicationLazyImpl<out T>(initializer: () -> T) : Lazy<T>, Serializable {
    @Volatile private var initializer: (() -> T)? = initializer
    @Volatile private var _value: Any? = UNINITIALIZED_VALUE
    // this final field is required to enable safe initialization of the constructed instance
    private val final: Any = UNINITIALIZED_VALUE

    override val value: T
        get() {
            val value = _value
            if (value !== UNINITIALIZED_VALUE) {
                @Suppress("UNCHECKED_CAST")
                return value as T
            }

            val initializerValue = initializer
            // if we see null in initializer here, it means that the value is already set by another thread
            if (initializerValue != null) {
                val newValue = initializerValue()
                if (valueUpdater.compareAndSet(this, UNINITIALIZED_VALUE, newValue)) {
                    initializer = null
                    return newValue
                }
            }
            @Suppress("UNCHECKED_CAST")
            return _value as T
        }

    ......
    
    companion object {
        private val valueUpdater = java.util.concurrent.atomic.AtomicReferenceFieldUpdater.newUpdater(
            SafePublicationLazyImpl::class.java,
            Any::class.java,
            "_value"
        )
    }
}
```

`AtomicReferenceFieldUpdater` 通过静态方法 `newUpdater()` 获取实例对象。`newUpdater()` 方法有三个参数，分别是：

- `tclass`：目标变量所在类的 `class` 对象；
- `vclass`：目标变量的类型 `class` 对象；
- `fieldName`：目标变量名。

在上述 `kotlin.lazy` 源码中通过比较初始值，保证在多线程环境中仅第一次赋值有效：

```
valueUpdater.compareAndSet(this, UNINITIALIZED_VALUE, newValue)
```

再来看 `AtomicStampedReference`，它的初始化方法如下：

```
public AtomicStampedReference(V initialRef, int initialStamp) {
}
```

可以看到初始化方法需要两个参数：

- 初始值
- 暂且看做初始版本号

用法如下：

```
private val atomicObj: AtomicStampedReference<String> = AtomicStampedReference("A", 0)

val t1 = Thread {
    try {
        TimeUnit.SECONDS.sleep(1)
    } catch (e: InterruptedException) {
    }
    println("run thread1")
    atomicObj.compareAndSet("A", "B", atomicObj.stamp, atomicObj.stamp + 1)
    atomicObj.compareAndSet("B", "A", atomicObj.stamp, atomicObj.stamp + 1)
}

val t2 = Thread {
    val stamp: Int = atomicObj.stamp
    try {
        TimeUnit.SECONDS.sleep(2)
    } catch (e: InterruptedException) {
    }
    println("run thread2")
    val result: Boolean = atomicObj.compareAndSet("A", "B", stamp, stamp + 1)
    println(result) // false
}

t1.start()
t2.start()
```

可以看到由于 `Thread2` 提前获取了版本号，及时 `Thread1` 执行之后值依然是 `A`, 但由于版本号已然发生了变化所以 `Thread2` 的执行结果仍然是 `false`。
