[Android跨进程通信：图文详解 Binder机制 原理](https://blog.csdn.net/carson_ho/article/details/73560642)
[为什么systemServer进程与zygote进程的通信是使用socket而不是binder？](https://blog.csdn.net/anhenzhufeng/article/details/106444099)
[为什么 Android 要采用 Binder 作为 IPC 机制](https://www.zhihu.com/question/39440766)
[https://cloud.tencent.com/developer/article/1780764](Android中怎么跨进程传输大图片)
[写给 Android 应用工程师的 Binder 原理剖析](https://zhuanlan.zhihu.com/p/35519585)

`IPC` 是指进程间通信，在 `Linux` 中进程空间分为 `用户空间和内核空间`，为保证安全性进程间用户空间不可互相访问，要做到跨进程通信只能通过内核空间，内核空间是所有进程共享的。

跨进程通信的方式：

- `共享内存`：速度最快，但需要考虑并发问题。
- `Socket`：性能低，需要两次拷贝，接收数据缓存大小不确定。
- `Binder`：性能较高，仅需要一次拷贝。
- `ContentProvider`：内部使用 `Binder` 实现。

传统的 `IPC` 做法是首先在内核空间中开辟一块内核缓存区，通过系统调用 `copy_from_user` 和 `copy_to_user` 完成两次 `copy` 操作，将数据传输到目标进程。

![image](https://pic1.zhimg.com/80/v2-aab2affe42958a659ea8a517ffaff5a0_1440w.jpg)

这种传统的 IPC 通信方式有两个问题：

- 性能低下，一次数据传递需要经历 2 次数据拷贝；
- 接收数据的缓存区由数据接收进程提供，但是接收进程并不知道需要多大的空间来存放将要传递过来的数据，因此只能开辟尽可能大的内存空间或者先调用 API 接收消息头来获取消息体的大小，这两种做法不是浪费空间就是浪费时间。

`Binder` 是一种在 `Android` 中实现跨进程通信（IPC）的方式。`Binder` 是通过 `mmap：内存映射` 实现的。`mmap` 可以在内核空间中创建一个数据接收缓存区，并映射到用户空间，这样发送进程只需要通过系统将数据拷贝进内核空间，由于映射关系的存在也就相当于发送到了接收进程的用户空间。

![](https://pic4.zhimg.com/80/v2-cbd7d2befbed12d4c8896f236df96dbf_1440w.jpg)

`Binder` 跨进程通信优点：

- 传输效率高，仅需要一次拷贝；
- 节省缓存区内存。

在 `Android` 中用到的跨进程通信方式还有 `Socket`，`SystemServer` 进程和 `Zygote` 进程就是通过 `Socket` 进行通信的。

`Socket` 和 `Binder` 的区别：

- Socket 需两次拷贝，Binder 仅需一次；
- Android 为每个进程都分配了UID，`Binder` 通过 C/S 架构，仅暴露用户端，这样服务端可以根据用户端UID判断是否安全。而 `Socket` 等传统方式无法获取进程的 UID/PID，无法判断其安全性。

手写 `Binder` 跨进程通信，`Android AIDL` 就是通过 `Binder` 实现的。具体步骤如下：

- `init`进程：init是所有linux程序的起点，是Zygote的父进程。解析init.rc孵化出Zygote进程。
- `Zygote`进程：Zygote是所有Java进程的父进程，所有的App进程都是由Zygote进程fork生成的。
- `SystemServer`进程：System Server是Zygote孵化的第一个进程。SystemServer负责启动和管理整个Java framework，包含AMS，PMS等服务。
- `Launcher`：Zygote进程孵化的第一个App进程是Launcher。

#### 为什么systemServer进程与zygote进程的通信是使用socket而不是binder？
首先，Binder通信需要使用Binder线程池。然后，Zygote 在fork进程之前，会把多余的线程（包括Binder线程）都杀掉只保留一个线程。所以此时就无法把结果通过Binder把消息发送给system_server。fork()进程完成之后Zygote也会把其他线程重新启动，这时候即使有了Binder线程，也无法重新建立连接。由于fork进程（Zygote）出来的进程A只有一个线程，如果Zygote有多个线程，那么A会丢失其他线程。这时可能造成死锁。
