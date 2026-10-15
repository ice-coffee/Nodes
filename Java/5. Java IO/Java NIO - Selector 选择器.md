### 概述
`Java NIO（New I/O）` 引入了一种新的 `非阻塞IO` 机制，旨在提高 `I/O` 操作的效率和性能。`非阻塞IO` 主要通过以下几个关键组件和概念来实现：

#### 1. 通道（`Channel`）
通道是对原始 `I/O` 的一种抽象，它可以通过文件、套接字等来读写数据。通道本身可以是非阻塞的，这意味着通道的 `I/O` 操作（如读写）可以立即返回，而不必等待操作完成。常见的通道有：

* `FileChannel`：用于文件 `I/O`。
* `SocketChannel`：用于网络 `I/O`。
* `ServerSocketChannel`：用于服务器套接字的 `I/O`。

> **`注意`**：仅 `SelectableChannel` 的子类支持非阻塞操作，所以 `FileChannel` 无法用于 `非阻塞IO`。

#### 2. 缓冲区（`Buffer`）
缓冲区用于存储数据，通道读写数据时都通过缓冲区。缓冲区是一个内存块，它有四个重要属性：`position`、`limit`、`capacity` 和 `mark`。常见的缓冲区类型有：

* `ByteBuffer`
* `CharBuffer`
* `IntBuffer`

#### 3. 选择器（`Selector`）
选择器是 `Java NIO` 中实现 `非阻塞I/O` 的核心。一个选择器可以注册多个通道，并通过选择操作来监听这些通道的事件（如连接就绪、读就绪、写就绪）。选择器使得一个线程可以管理多个通道，从而避免了传统 `I/O` 中每个通道一个线程的高开销。

#### 4. 选择键（`SelectionKey`）
选择键表示选择器和通道之间的注册关系。当通道注册到选择器上时，会生成一个选择键。选择键包含了通道、选择器以及通道感兴趣的操作集合。


### 非阻塞I/O工作流程

1. **`创建通道和选择器`**：首先，创建一个或多个通道，并将其配置为非阻塞模式。然后，创建一个选择器。
2. **`注册通道`**：将通道注册到选择器上，并指定感兴趣的事件（如连接就绪、读就绪、写就绪）。
3. **`选择操作`**：调用选择器的select方法，阻塞等待，直到至少有一个通道准备就绪。这种阻塞是相对短暂的，并且在任何通道就绪时立即返回。
4. **`处理就绪事件`**：从选择器获取就绪的通道，并根据事件类型进行相应的读写操作。
5. **`重复步骤3和4`**：不断循环选择操作和事件处理，直到所有I/O操作完成。

**`示例：`**
```java
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;

public class NonBlockingNIOServer {

    public static void main(String[] args) throws IOException {
        // 创建选择器
        Selector selector = Selector.open();

        // 打开服务器套接字通道
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        serverSocketChannel.bind(new InetSocketAddress(8080));
        serverSocketChannel.configureBlocking(false);

        // 注册通道到选择器，并监听连接事件
        serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT);

        while (true) {
            // 选择就绪的通道
            selector.select();

            // 获取选择键集合
            Iterator<SelectionKey> keyIterator = selector.selectedKeys().iterator();
            
            while (keyIterator.hasNext()) {
                SelectionKey key = keyIterator.next();
                keyIterator.remove();

                if (key.isAcceptable()) {
                    // 处理连接就绪事件
                    ServerSocketChannel serverChannel = (ServerSocketChannel) key.channel();
                    SocketChannel socketChannel = serverChannel.accept();
                    socketChannel.configureBlocking(false);
                    socketChannel.register(selector, SelectionKey.OP_READ);
                } else if (key.isReadable()) {
                    // 处理读就绪事件
                    SocketChannel socketChannel = (SocketChannel) key.channel();
                    ByteBuffer buffer = ByteBuffer.allocate(256);
                    int bytesRead = socketChannel.read(buffer);
                    if (bytesRead == -1) {
                        socketChannel.close();
                    } else {
                        buffer.flip();
                        while (buffer.hasRemaining()) {
                            socketChannel.write(buffer);
                        }
                    }
                }
            }
        }
    }
}
```
