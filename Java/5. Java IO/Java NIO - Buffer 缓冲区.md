[toc]

### 概述
`Buffer(缓冲区)` 本质上是一块可以读写的内存。这块内存被包装成 `Buffer` 对象，并提供了一组方法，用来方便的访问该块内存。

### Buffer 详细说明
缓冲区的几个重要属性：

* `position`：当前读写位置
* `capacity`：缓冲区容量大小
* `limit`：读、写模式下最多读取到的位置

写模式下，`limit == capacity`，读模式下，`limit == position`。这很好理解，因为读取数据时一般我们只希望读取到最新写入的数据。

`Buffer` 的读写模式只是帮助开发者更安全的读取数据，但并不是必须的。比如实现类似 `RandomAccessFile` 随机访问的能力就需要 `limit == capacity`。更简单的说法使用读写模式时旧数据相当于全部废弃了，而不使用读写模式时只是对数据的某一部分进行更新。

#### 方法说明

* **`position()`**：

```java
public final int position() {
    return position;
}

public Buffer position(int newPosition) {
    ...
    position = newPosition;
    ...
    return this;
}
```

简单直接的能力，操作 `position` 的值，通过它们可以实现随机访问。

* **`flip()`**：

```java
/**
 * 从写模式切换到读模式
 */
public Buffer flip() {
    limit = position;
    position = 0;
    mark = -1;
    return this;
}
```

调用 `flip` 函数之后就只可以读取之前写入的数据了。

* **`rewind()`**：

```java
/**
 * position归零，limit不变，表示可以重头读取数据了
 */
public Buffer rewind() {
    position = 0;
    mark = -1;
    return this;
}
```

* **`clear()`**：

```java
/**
 * 清空缓冲区
 */
public Buffer clear() {
    position = 0;
    limit = capacity;
    mark = -1;
    return this;
}
```

可以看到 `clear` 函数只是修改了 `position、limit` 的值并没有处理缓冲区内的数据，这是因为 `Buffer` 作为缓冲区的基类并不直接操作数据。具体清理操作由不同子类实现，例如 `HeapBbyteBuffer` 清空数据需要 `GC`，而 `MappedByteBuffer` 需要 `Clear` 来清理。

* **`compact()`**：

`compact` 并不是 `Buffer` 中定义的方法，但是它在各个缓冲区实现类中都有定义。`compact()` 方法会将所有未读的数据拷贝到 `Buffer` 起始处。然后将 `position` 设到最后一个未读元素正后面，`limit` 设置成 `capacity`。简单说 `compact` 并不会覆盖未读的数据。

* **`mark() / reset()`**：

```java
public Buffer mark() {
    mark = position;
    return this;
}

public Buffer reset() {
    int m = mark;
    if (m < 0)
        throw new InvalidMarkException();
    position = m;
    return this;
}
```

简单说这两个函数结合是一个时光回返的能力。

### Buffer 的子类
`Buffer` 继承关系如下：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/io/java_nio_buffer.png)

可以看到 `Java NIO` 提供了所有基本类型的缓冲区：`byte`, `short`, `int`, `long`, `float`, `double` 和 `char`。

它们的实现类有如下三类：

* `Heap*Buffer`：`Heap` 代表申请的缓冲区内存在 `JVM堆` 中；
* `Direct*Buffer`：`Direct` 代表申请的缓冲区在 `JVM直接内存` 中；
* `MappedByteBuffer`：`MappedByteBuffer` 是字节缓冲区独有，用与映射本地文件到文件映射区内；

### ByteBuffer
可以看到 `ByteBuffer` 包含三个个实现类：

* `HeapByteBuffer`
* `MappedByteBuffer`
* `DirectByteBuffer`

#### HeapByteBuffer
`HeapByteBuffer` 不用多说，可以看做是对 `byte[]` 的封装。

创建：
```java
HeapByteBuffer heapByteBuffer = ByteBuffer.allocate(100);
```

销毁：通过 `GC` 回收。

#### MappedByteBuffer、DirectByteBuffer
`MappedByteBuffer` 是一个抽象类，`DirectByteBuffer` 是它的直接子类。所以实际上无论如何我们得到的都是 `DirectByteBuffer` 的实例，那为什么一般会把 `MappedByteBuffer` 单独拿出来说是因为：

> Mapped byte buffers are created via the `FileChannel. map` method.  This class extends the ByteBuffer class with operations that are specific to memory-mapped file regions.

意思是当通过 `FileChannel.map` 函数返回的 `ByteBuffer` 所申请的内存空间在内存文件映射区内。除此之外都是通过 `ByteBuffer.allocateDirect` 函数创建的 `DirectByteBuffer`，它所申请的内存空间在 `JVM 直接内存` 中。

产生这种区别主要在于操作内存地址的区别：

* `FileChannel.map`：

```java
/**
 * FileChannelImpl.java
 */
public MappedByteBuffer map(MapMode mode, long position, long size)
    throws IOException
{

    long addr = -1;
    try {
        begin();
        
        try {
            // 在文件映射区中申请内存并返回内存地址
            addr = map0(imode, mapPosition, mapSize);
        } catch (OutOfMemoryError x) {
            // 发生OOM时触发系统 GC，再重新申请内存
            ...
        }

        int isize = (int)size;
        Unmapper um = new Unmapper(addr, mapSize, isize, mfd);

        // 将申请的内存地址传入 DirectByteBuffer，创建实例
        return new DirectByteBuffer(isize, addr + pagePosition, mfd, um,
                (!writable) || (imode == MAP_RO));
    } finally {
        threads.remove(ti);
        end(IOStatus.checkAll(addr));
    }
}
```

```java
protected DirectByteBuffer(int cap, long addr, FileDescriptor fd, Runnable unmapper)
{
    super(-1, 0, cap, cap, fd);
    address = addr;
}
```

> `SharedMemory` 也是通过在文件映射区申请内存（`Os.mmap`）实现内存共享的。

* `ByteBuffer.allocateDirect`：

```java
public static ByteBuffer allocateDirect(int capacity) {
    return new DirectByteBuffer(capacity);
}
```

```java
DirectByteBuffer(int cap) {
    super(-1, 0, cap, cap);

    long base = 0;
    try {
        // 在堆外内存申请空间并返回内存地址
        base = unsafe.allocateMemory(size);
    } catch (OutOfMemoryError x) {
        Bits.unreserveMemory(size, cap);
        throw x;
    }
    unsafe.setMemory(base, size, (byte) 0);
    if (pa && (base % ps != 0)) {
        // Round up to page boundary
        address = base + ps - (base & (ps - 1));
    } else {
        address = base;
    }
}
```

而在 `DirectByteBuffer` 中读写数据时都是使用 `UnSafe` 类直接操作内存，区别只是文件映射区或直接内存，其它没有什么不同：

```java
public ByteBuffer put(byte x) {
    unsafe.putByte(ix(nextPutIndex()), ((x)));
    return this;
}

public byte get() {
    return ((unsafe.getByte(ix(nextGetIndex()))));
}
```

所以一般说 `MappedByteBuffer` 都是指通过 `FileChannel.map` 返回的数据缓冲区。

> 注意：`Android` 源码中 `DirectByteBuffer` 的实现和 `Java` 源码中略有不同但无伤大雅。

以下是不同 `IO` 操作的过程：

* `Stream`：硬盘 <--> 内核空间 <-[`拷贝`]-> 用户空间(JVM堆) <-[`拷贝`]-> 本地缓冲区；
* `DirectByteBuffer`：硬盘 <--> 内核空间 <-[`拷贝`]-> 用户空间(直接内存：`DirectByteBuffer`) <--> 直接访问 `DirectByteBuffer`；
* `MappedByteBuffer`：硬盘 -[`映射`]-> 用户空间（文件映射区：`MappedByteBuffer`）--> 直接访问 `MappedByteBuffer`；

> **`注意`**：在使用 `Channel` 读写数据时如果传入的数据缓冲区不是 `ByteBuffer.allocateDirect` 创建的那么就会发生两次拷贝。
> ：硬盘 <--> 内核空间 <-[`拷贝`]-> 用户空间(直接内存：`DirectByteBuffer`) <-[`拷贝`]-> `HeapByteBuffer`。

除拷贝次数外 `DirectByteBuffer` 的使用还可以缓解 `GC` 压力。我们知道 `GC` 发生时主要做两件事：

* 回收不被引用的对象；
* 整理内存空间；

首先在堆上操作 IO 时 GC 可能会进行内存空间整理，这导致了一次 IO 写入的内存地址不完整。实际上，JNI 在调用 IO 操作的 C 类库时，规定了写入时地址不能失效，这就导致了不能在堆上直接进行 IO 操作。在 IO 操作的时候禁止 GC 也是一个选项，如果 IO 时间过长，那么则可能会引起堆空间溢出。

而 `DirectByteBuffer` 所申请的内存空间并不在 `Java 堆` 中也就避免了这一问题。

##### 内存回收
那 `DirectByteBuffer` 所申请的内存空间要如何回收呢。答案还是 `GC`。

`Cleaner` 作为虚引用，当对象被回收时会执行 `Unsafe.freeMemory` 函数释放内存。
