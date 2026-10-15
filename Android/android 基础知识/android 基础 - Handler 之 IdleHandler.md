[toc]

### 转自
[承香墨影 - 面试官：“看你简历上写熟悉 Handler 机制，那聊聊 IdleHandler 吧？”](https://juejin.cn/post/6844904068129751047)

Handler 机制算是 Android 基本功，面试常客。但现在面试，多数已经不会直接让你讲讲 Handler 的机制，Looper 是如何循环的，MessageQueue 是如何管理 Message 等，而是基于场景去提问，看看你对 Handler 机制的掌握是否扎实。
本文就来聊聊 Handler 中的 IdleHandler，这个我们比较少用的功能。它能干什么？怎么使用？有什么合适的使用场景？哪些不是合适的使用场景？在 Android Framework 中有哪些地方用到了它？

### IdleHandler
#### 简单说说 Handler 机制
在说 IdleHandler 之前，先简单了解一下 Handler 机制。
Handler 是标准的事件驱动模型，存在一个消息队列 MessageQueue，它是一个基于消息触发时间的优先级队列，还有一个基于此消息队列的事件循环 Looper，Looper 通过循环，不断的从 MessageQueue 中取出待处理的 Message，再交由对应的事件处理器 Handler/callback 来处理。
其中 MessageQueue 被 Looper 管理，Looper 在构造时同步会创建 MessageQueue，并利用 ThreadLocal 这种 TLS，将其与当前线程绑定。而 App 的主线程在启动时，已经构造并准备好主线程的 Looper 对象，开发者只需要直接使用即可。
Handler 类中封装了大部分「Handler 机制」对外的操作接口，可以通过它的 send/post 相关的方法，向消息队列 MessageQueue 中插入一条 Message。在 Looper 循环中，又会不断的从 MessageQueue 取出下一条待处理的 Message 进行处理。
IdleHandler 使用相关的逻辑，就在 MessageQueue 取消息的 next() 方法中。

#### IdleHandler 是什么？怎么用？
IdleHandler 说白了，就是 Handler 机制提供的一种，可以在 Looper 事件循环的过程中，当出现空闲的时候，允许我们执行任务的一种机制。
IdleHandler 被定义在 MessageQueue 中，它是一个接口。

```
// MessageQueue.java
public static interface IdleHandler {
  boolean queueIdle();
}
```

复制代码可以看到，定义时需要实现其 queueIdle() 方法。同时返回值为 true 表示是一个持久的 IdleHandler 会重复使用，返回 false 表示是一个一次性的 IdleHandler。
既然 IdleHandler 被定义在 MessageQueue 中，使用它也需要借助 MessageQueue。在 MessageQueue 中定义了对应的 add 和 remove 方法。

```
// MessageQueue.java
public void addIdleHandler(@NonNull IdleHandler handler) {
	// ...
  synchronized (this) {
    mIdleHandlers.add(handler);
  }
}
public void removeIdleHandler(@NonNull IdleHandler handler) {
  synchronized (this) {
    mIdleHandlers.remove(handler);
  }
}
```

复制代码可以看到 add 或 remove 其实操作的都是 mIdleHandlers，它的类型是一个 ArrayList。
既然 IdleHandler 主要是在 MessageQueue 出现空闲的时候被执行，那么何时出现空闲？
MessageQueue 是一个基于消息触发时间的优先级队列，所以队列出现空闲存在两种场景。

- MessageQueue 为空，没有消息；
- MessageQueue 中最近需要处理的消息，是一个延迟消息（when>currentTime），需要滞后执行；

这两个场景，都会尝试执行 IdleHandler。
处理 IdleHandler 的场景，就在 Message.next() 这个获取消息队列下一个待执行消息的方法中，我们跟一下具体的逻辑。

```
Message next() {
	// ...
  int pendingIdleHandlerCount = -1; 
  int nextPollTimeoutMillis = 0;
  for (;;) {
    nativePollOnce(ptr, nextPollTimeoutMillis);

    synchronized (this) {
      // ...
      if (msg != null) {
        if (now < msg.when) {
          // 计算休眠的时间
          nextPollTimeoutMillis = (int) Math.min(msg.when - now, Integer.MAX_VALUE);
        } else {
          // Other code
          // 找到消息处理后返回
          return msg;
        }
      } else {
        // 没有更多的消息
        nextPollTimeoutMillis = -1;
      }
      
      if (pendingIdleHandlerCount < 0
          && (mMessages == null || now < mMessages.when)) {
        pendingIdleHandlerCount = mIdleHandlers.size();
      }
      if (pendingIdleHandlerCount <= 0) {
        mBlocked = true;
        continue;
      }

      if (mPendingIdleHandlers == null) {
        mPendingIdleHandlers = new IdleHandler[Math.max(pendingIdleHandlerCount, 4)];
      }
      mPendingIdleHandlers = mIdleHandlers.toArray(mPendingIdleHandlers);
    }

    for (int i = 0; i < pendingIdleHandlerCount; i++) {
      final IdleHandler idler = mPendingIdleHandlers[i];
      mPendingIdleHandlers[i] = null; 

      boolean keep = false;
      try {
        keep = idler.queueIdle();
      } catch (Throwable t) {
        Log.wtf(TAG, "IdleHandler threw exception", t);
      }

      if (!keep) {
        synchronized (this) {
          mIdleHandlers.remove(idler);
        }
      }
    }

    pendingIdleHandlerCount = 0;
    nextPollTimeoutMillis = 0;
  }
}
```

复制代码我们先解释一下 next() 中关于 IdleHandler 执行的主逻辑：

准备执行 IdleHandler 时，说明当前待执行的消息为 null，或者这条消息的执行时间未到；
当 pendingIdleHandlerCount < 0 时，根据 mIdleHandlers.size() 赋值给 pendingIdleHandlerCount，它是后期循环的基础；
将 mIdleHandlers 中的 IdleHandler 拷贝到 mPendingIdleHandlers 数组中，这个数组是临时的，之后进入 for 循环；
循环中从数组中取出 IdleHandler，并调用其 queueIdle() 记录返回值存到 keep 中；
当 keep 为 false 时，从 mIdleHandler 中移除当前循环的 IdleHandler，反之则保留；

可以看到 IdleHandler 机制中，最核心的就是在 next() 中，当队列空闲的时候，循环 mIdleHandler 中记录的 IdleHandler 对象，如果其 queueIdle() 返回值为 false 时，将其从 mIdleHander 中移除。
需要注意的是，对 mIdleHandler 这个 List 的所有操作，都通过 synchronized 来保证线程安全，这一点无需担心。

#### IdleHander 是如何保证不进入死循环的？
当队列空闲时，会循环执行一遍 mIdleHandlers 数组并执行 IdleHandler.queueIdle() 方法。而如果数组中有一些 IdleHander 的 queueIdle() 返回了 true，则会保留在 mIdleHanders 数组中，下次依然会再执行一遍。
注意现在代码逻辑还在 MessageQueue.next() 的循环中，在这个场景下 IdleHandler 机制是如何保证不会进入死循环的？
有些文章会说 IdleHandler 不会死循环，是因为下次循环调用了 nativePollOnce() 借助 epoll 机制进入休眠状态，下次有新消息入队的时候会重新唤醒，但这是不对的。
注意看前面 next() 中的代码，在方法的末尾会重置 pendingIdleHandlerCount 和 nextPollTimeoutMillis。

```
Message next() {
	// ...
  int pendingIdleHandlerCount = -1; 
  int nextPollTimeoutMillis = 0;
  for (;;) {
		nativePollOnce(ptr, nextPollTimeoutMillis);
    // ...
    // 循环执行 mIdleHandlers
    // ...
    pendingIdleHandlerCount = 0;
    nextPollTimeoutMillis = 0;
  }
}
```

复制代码nextPollTimeoutMillis 决定了下次进入 nativePollOnce() 超时的时间，它传递 0 的时候等于不会进入休眠，所以说 natievPollOnce() 进入休眠所以不会死循环是不对的。
这很好理解，毕竟 IdleHandler.queueIdle() 运行在主线程，它执行的时间是不可控的，那么 MessageQueue 中的消息情况可能会变化，所以需要再处理一遍。
实际不会死循环的关键是在于 pendingIdleHandlerCount，我们看看下面的代码。

```
Message next() {
	// ...
  // Step 1
  int pendingIdleHandlerCount = -1; 
  int nextPollTimeoutMillis = 0;
  for (;;) {
    nativePollOnce(ptr, nextPollTimeoutMillis);

    synchronized (this) {
      // ...
      // Step 2
      if (pendingIdleHandlerCount < 0
          && (mMessages == null || now < mMessages.when)) {
        pendingIdleHandlerCount = mIdleHandlers.size();
      }
     	// Step 3
      if (pendingIdleHandlerCount <= 0) {
        mBlocked = true;
        continue;
      }
      // ...
    }
		// Step 4
    pendingIdleHandlerCount = 0;
    nextPollTimeoutMillis = 0;
  }
}
```

复制代码我们梳理一下：

* Step 1，循环开始前，pendingIdleHandlerCount 的初始值为 -1；
* Step 2，在 pendingIdleHandlerCount<0 时，才会通过 mIdleHandlers.size() 赋值。也就是说只有第一次循环才会改变 pendingIdleHandlerCount 的值；
* Step 3，如果 pendingIdleHandlerCount<=0 时，则循环 continus；
* Step 4，重置 pendingIdleHandlerCount 为 0；

在第二次循环时，pendingIdleHandlerCount 等于 0，在 Step 2 不会改变它的值，那么在 Step 3 中会直接 continus 继续下一次循环，此时没有机会修改 nextPollTimeoutMillis。
那么 nextPollTimeoutMillis 有两种可能：-1 或者下次唤醒的等待间隔时间，在执行到 nativePollOnce() 时就会进入休眠，等待再次被唤醒。
下次唤醒时，mMessage 必然会有一个待执行的 Message，则 MessageQueue.next() 返回到 Looper.loop() 的循环中，分发处理这个 Message，之后又是一轮新的 next() 中去循环。

#### framework 中如何使用 IdleHander？
到这里基本上就讲清楚 IdleHandler 如何使用以及一些细节，接下来我们来看看，在系统中，有哪些地方会用到 IdleHandler 机制。
在 AS 中搜索一下 IdleHandler。

简单解释一下：

* ActivityThread.Idler 在 ActivityThread.handleResumeActivity() 中调用。
* ActivityThread.GcIdler 是在内存不足时，强行 GC；
* Instrumentation.ActivityGoing 在 Activity onCreate() 执行前添加；
* Instrumentation.Idler 调用的时机就比较多了，是键盘相关的调用；
* TextToSpeechService.SynthThread 是在 TTS 合成完成之后发送广播；

有兴趣可以自己追一下源码，这些都是使用的场景，具体用 IdleHander 干什么，还是要看业务。

### 一些面试问题
到这里我们就讲清楚 IdleHandler 干什么？怎么用？有什么问题？以及使用中一些原理的讲解。
下面准备一些基本的问题，供大家理解。
Q：IdleHandler 有什么用？

IdleHandler 是 Handler 提供的一种在消息队列空闲时，执行任务的时机；
当 MessageQueue 当前没有立即需要处理的消息时，会执行 IdleHandler；

Q：MessageQueue 提供了 add/remove IdleHandler 的方法，是否需要成对使用？

不是必须；
IdleHandler.queueIdle() 的返回值，可以移除加入 MessageQueue 的 IdleHandler；

Q：当 mIdleHanders 一直不为空时，为什么不会进入死循环？

只有在 pendingIdleHandlerCount 为 -1 时，才会尝试执行 mIdleHander；
pendingIdlehanderCount 在 next() 中初始时为 -1，执行一遍后被置为 0，所以不会重复执行；

Q：是否可以将一些不重要的启动服务，搬移到 IdleHandler 中去处理？

不建议；
IdleHandler 的处理时机不可控，如果 MessageQueue 一直有待处理的消息，那么 IdleHander 的执行时机会很靠后；

Q：IdleHandler 的 queueIdle() 运行在那个线程？

陷进问题，queueIdle() 运行的线程，只和当前 MessageQueue 的 Looper 所在的线程有关；
子线程一样可以构造 Looper，并添加 IdleHandler；

### 应用场景
实现和 `View.post()` 一样的功能，区别就是 `IdleHandler` 会在消息队列空闲时执行。

### 小结
到这里就把 IdleHandler 的使用和原理说清除了。
IdleHandler 是 Handler 提供的一种在消息队列空闲时，执行任务的时机。但它执行的时机依赖消息队列的情况，那么如果 MessageQueue 一直有待执行的消息时，IdleHandler 就一直得不到执行，也就是它的执行时机是不可控的，不适合执行一些对时机要求比较高的任务。
本文就到这里，对你有帮助吗？有任何问题欢迎留言。觉得有帮助
