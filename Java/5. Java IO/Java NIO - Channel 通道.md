[toc]
## Channel
`Channel` 是 `Java NIO` 提供的用于 `IO` 操作的连接。`Channel` 提供的函数很简单，只有两个：

* `isOpen()`：通道是否打开
* `close()`：关闭通道

`Channel` 提供的重要子类：

* `FileChannel`：从文件中读写数据；
* `DatagramChannel`：能通过 `UDP` 读写网络中的数据；
* `SocketChannel`：能通过 `TCP` 读写网络中的数据；
* `ServerSocketChannel`：可以监听新进来的 `TCP` 连接，像Web服务器那样，对每一个新进来的连接都会创建一个`SocketChannel`；

## FileChannel
### 简介
`FileChannel` 是 `Java NIO（New I/O）` 包中提供的一种文件通道，用于支持文件的读取和写入操作。它提供了一种更为灵活和高效的方式来进行文件操作，相比传统的基于流的 I/O，`FileChannel` 具有更好的性能和扩展性。下面是详细介绍：

`FileChannel` 是一个抽象类，可以通过如下方式获取它的实例：

* `FileInputStream.getChannel()`
* `FileOutputStream.getChannel()`
* `RandomAccessFile.getChannel()`

在 `getChannel` 函数里可以看到使用的实现类是 `FileChannelImpl`。

### 作用

* **文件读取和写入**：`FileChannel` 提供了读取和写入文件内容的方法，支持对文件的随机访问和操作。
* **文件复制和传输**：`FileChannel` 提供了高效的文件复制和传输方法，可以在不使用中间缓冲区的情况下直接将数据从一个通道传输到另一个通道。
* **文件锁定**：`FileChannel` 允许对文件的部分或全部进行锁定，以防止其他程序同时访问相同的文件。
* **内存映射文件**：`FileChannel` 支持将文件映射到内存中，从而允许直接在内存中对文件进行操作，提高了 I/O 操作的性能。

### 方法说明

#### 文件随机访问
`FileChannel` 提供 `position` 方法用于控制文件指针，对文件进行随机访问。

```java
/**
 * 获取当前文件指针位置
 */
public abstract long position()
```

```java
/**
 * 设置当前文件指针位置
 */
public abstract FileChannel position(long newPosition)
```

> **需验证**：文件指针位置可设置超过文件大小，不会修改文件大小。此时读取字节将立即返回一个文件结束指示；写入字节将导致文件增长以容纳新的字节；前一个文件结束符和新写入的字节之间的任何字节的值都未指定。

#### 文件复制和传输

```java
/**
 * @param src：源通道，必须是实现 ReadableByteChannel 接口的通道。
 * @param position：目标通道中的位置，从该位置开始写入数据。
 * @param count：要传输的最大字节数。
 * @return：实际传输的字节数
 */
public abstract long transferFrom(ReadableByteChannel src, long position, long count)
```

```java
/**
 * @param position：源通道中的位置，从该位置开始读取数据。
 * @param count：要传输的最大字节数。
 * @param target：目标通道，必须是实现 WritableByteChannel 接口的通道。
 * @return：实际传输的字节数
 */
public abstract long transferTo(long position, long count, WritableByteChannel target)
```

示例：
```java
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;

public class TransferToExample {
    public static void main(String[] args) {
        try {
            RandomAccessFile fromFile = new RandomAccessFile("source.txt", "r");
            FileChannel fromChannel = fromFile.getChannel();
            
            RandomAccessFile toFile = new RandomAccessFile("destination.txt", "rw");
            FileChannel toChannel = toFile.getChannel();
            
            long position = 0;
            long count = fromChannel.size();
            
            long bytesTransferred = fromChannel.transferTo(position, count, toChannel);
            System.out.println("Transferred " + bytesTransferred + " bytes from source to destination.");
            
            fromChannel.close();
            toChannel.close();
            fromFile.close();
            toFile.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

#### 文件锁定

**文件锁定的两种类型：**
1. 共享锁定（Shared Lock）：

* 允许多个进程或线程同时`读取`文件，但不允许写入。
* 当一个文件被共享锁定时，其他进程或线程可以获取共享锁定，但不能获取独占锁定。

2. 独占锁定（Exclusive Lock）：

* 允许一个进程或线程读取和`写入`文件，其他进程或线程都不能访问文件。
* 当一个文件被独占锁定时，其他进程或线程不能获取任何类型的锁定。

**获取文件锁定：**

* `lock()`：阻塞当前线程，直到获取到锁定。
* `tryLock()`：立即返回，如果获取不到锁定，返回 null。

```java
/**
 * @param position：锁定区域的开始位置。
 * @param size：锁定区域的大小，Long.MAX_VALUE 表示从 position 开始锁定到文件末尾。
 * @param shared：是否是共享锁定，true 表示共享锁定，false 表示独占锁定。
 */
FileLock lock(long position, long size, boolean shared) throws IOException;
FileLock tryLock(long position, long size, boolean shared) throws IOException;
```

**文件解锁：**
通过 `FileLock` 对象的 `release()` 方法释放：

```java
void release() throws IOException;
```

#### 内存映射文件
`FileChannel.map` 方法可以将文件直接映射到用户空间无需经过内核空间拷贝 `I/O` 效率高，但内存映射开销较大，所以不适合较小文件。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/io/java_mmp_io.jpg)

```java
/**
 * @param mode：打开模式
 * @param position：从指定文件的开始位置映射到内存
 * @param size：指定映射的大小，值为非负值
 */
public abstract MappedByteBuffer map(MapMode mode, long position, long size)
```

打开模式：

* `FileChannel.MapMode.READ_ONLY`：只读模式，表示你只能从映射的内存区域中读取数据，任何写操作都会导致 UnsupportedOperationException 异常。
* `FileChannel.MapMode.READ_WRITE`：读写模式，表示你可以读取和写入映射的内存区域。
* `FileChannel.MapMode.PRIVATE`：私有模式，表示对映射的更改不会写回到原文件中。其他映射同一文件的程序不会看到这些更改。

**使用场景：**

* `高效的文件 I/O 操作`：内存映射文件允许直接在内存中操作文件数据，而不需要通过传统的 I/O 流进行读写操作。这样减少了系统调用的开销，提高了文件 I/O 的性能。
* `大文件的随机访问`：内存映射文件非常适合用于处理大文件，因为它支持文件的随机访问。可以将文件的某个部分映射到内存，而不是将整个文件加载到内存中，这样可以节省内存空间。
* `与外部进程或线程共享数据`：通过内存映射文件，不同的进程或线程可以共享同一块内存，这对于需要共享大量数据的应用程序来说非常有用。
* `实现高效的缓存机制`：内存映射文件可以用于实现高效的缓存机制。由于数据在内存中访问速度更快，可以通过映射文件来缓存频繁访问的数据，从而提升应用程序的性能。

调用 `map()` 方法之后，返回的 `MappedByteBuffer` 就与 `FileChannel` 脱离了关系，关闭 `FileChannel` 对 `MappedByteBuffer` 没有影响。同时如果要确保对 `MappedByteBuffer` 修改的数据能够同步到文件 `I/O` 设备中，需要调用 `MappedByteBuffer` 中的无参数的 `force()` 方法，而调用 `FileChannel` 中的 `force(metaData)` 方法无效。

### mmap vs stream

### 参考
[Java NIO 文件通道 FileChannel 用法 ](https://www.cnblogs.com/robothy/p/14235598.html)
[MappedByteBuffer](https://www.cnblogs.com/crazymakercircle/p/15625329.html)
