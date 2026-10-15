[toc]

### 参考链接
[【BAT面试题系列】面试官：你了解乐观锁和悲观锁吗？](https://www.cnblogs.com/kismetv/p/10787228.html#t3)

### 原子变量类
`原子变量类` 是 `Java` 提供的一系列通过 `volatile` 和 `Unsafe` 保证数据线程安全的数据类型。原子变量保证了单个变量操作的原子性、可见性和有序性。

### 原理简介

#### 原子性：CAS
> 原子性：指一系列操作作为一个整体被执行，不会被其他线程操作干扰。

`CAS（Compare-and-swap）`：比较和替换，它是设计非阻塞并发算法的一种常用技术。使用 `CAS` 操作可用于保证变量更新的原子性。

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

#### 可见性：`volatile + Unsafe`
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

### 原子变量 VS 锁
原子变量是比锁更细粒度、更轻量级的线程安全机制。原子变量将发生竞争的范围缩小到单个变量上，这是我们可以获得最细粒度的情况。

**`性能开销：`**
**锁：** 在多线程场景下通过锁来保证对数据的安全访问，会造成线程的挂起和恢复，在这个过程中存在着很大的开销。而且如果锁范围内是细粒度的操作，那么当锁上存在激烈的竞争时，调度开销与工作开销的比值会非常高。
**原子变量：** 单次 `CAS` 操作的开销远低于线程挂起和恢复。但随着线程竞争越激烈，`CAS` 重试的次数越多消耗的 `CPU` 资源越多。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/cas_vs_lock.png)@w=400

**`安全性：`**
**锁：** 存在死锁、活锁或其他活跃性故障的风险。
**原子变量：** 没有传统锁机制所产生的安全性风险。

### 使用场景
在低竞争且仅需保证单个变量线程安全的情况下可使用 `原子变量` 替代锁（`synchorinzed` / `Lock`）。

### 原子变量分类
原子变量类可分为：

* **标量类**：`AtomicBoolean、AtomicInteger、AtomicLong、AtomicReference<V>`。
* **数组类**：`AtomicIntegerArray、AtomicLongArray、AtomicReferenceArray<E>`。
* **更新器类**：`AtomicIntegerFieldUpdater、AtomicLongFieldUpdater、AtomicReferenceFieldUpdater<T,V>`。
* **复合变量类**：。

#### 标量类
以 `AtomicInteger` 为例：

如果 `int` 变量的新值和旧值没有关系，那么 `AtomicInteger  == volatile int`，它们的效果是一样的。`AtomicInteger` 内部 `get、set` 方法实现如下：

```java
public class AtomicInteger {    
    private volatile int value;

    public final int get() {
        return value;
    }

    public final void set(int newValue) {
        value = newValue;
    }
}
```

如果变量的新值依赖于旧值，例如增加等操作，那使用 `volatile` 就没办法保证数据的安全了，这时候就要使用 `AtomicInteger`：

```java
/**
 * 如果 expect 和当前值相同，则将 update 赋值给当前值，并返回 true。
 * 如果 expect 和当前值不同，返回false。
 */
public final boolean compareAndSet(int expect, int update) {
    return U.compareAndSwapInt(this, VALUE, expect, update);
}
```

自增实现：
> `AtomicInteger` 提供了自增操作的实现 `incrementAndGet()`，下方示例仅作为学习使用。
```java
private AtomicInteger value = new AtomicInteger(0);

 private int get() {
     return value.get();
 }

 public final int incrementAndGet() {
     for (;;) {
         //获取当前值, 此示例中当前值也是本次 `CAS` 的期望值
         int current = get();
         //获取更新值
         int next = current + 1;
         //执行CAS操作
         if (value.compareAndSet(current, next)) {
             //成功后才会返回期望值，否则无线循环
             return next;
         }
     }
 }
```
#### 数组类


#### 更新器类
前几个比较好理解，分别可以保证 `file、int、long、boolean` 类型数据的原子操作，那么如果操作数据为 `String` 或类型不可知怎么办呢？这时候就可以使用 `AtomicReferenceFieldUpdater()` 了。在 `Kotlin.lazy` 的实现中就使用到了 `AtomicReferenceFieldUpdater`：

```kotlin
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
- `vclass`：目标变量的 `class` 对象；
- `fieldName`：目标变量名。

在上述 `kotlin.lazy` 源码中通过比较初始值，保证在多线程环境中仅第一次赋值有效：

```kotlin
valueUpdater.compareAndSet(this, UNINITIALIZED_VALUE, newValue)
```

#### AtomicStampedReference
再来看 `AtomicStampedReference`，它的初始化方法如下：

```java
public AtomicStampedReference(V initialRef, int initialStamp) {
}
```

可以看到初始化方法需要两个参数：

- 初始值
- 暂且看做初始版本号

用法如下：

```kotlin
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
