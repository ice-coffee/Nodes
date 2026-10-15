[toc]

[ReactiveX/RxJava文档中文版](https://mcxiaoke.gitbooks.io/rxdocs/content/)

[RxJava 面经（一）](https://juejin.cn/post/6900870262062120967#heading-18)

[RxJava 面经（二）](https://juejin.cn/post/6905725515521835015#heading-15)

`RxJavaPlugins` 的作用

#### `RxJava` 原理概述
`RxJava` 的核心是由订阅者模式实现，其内最重要的逻辑在于被观察者（`Obserable`）和观察者（`observer`）。在 `RxJava` 使用中，由开发者创建的观察者和被观察者我称为最终观察者和初始被观察者，因为在每次 `API` 如 `map、flapMap、subscribeOn、observeOn` 时都会创建新观察者，由 `API` 的掉用方作为被观察者，也就是说 `API` 的调用方是数据的上游（数据产出方）传参是数据的下游（数据处理方）。

#### `RxJava` 被观察者和观察者之间是如何传递数据的
在订阅过程中：

```
observable.subscribe(observer)
```

观察者被封装为 `Emitter`（发射器），

```
protected void subscribeActual(Observer<? super T> observer) {
    CreateEmitter<T> parent = new CreateEmitter<>(observer);
    observer.onSubscribe(parent);

    try {
        source.subscribe(parent);
    } catch (Throwable ex) {
        Exceptions.throwIfFatal(ex);
        parent.onError(ex);
    }
}
```

在事件发射器执行时也会调用观察者的相关方法，传递事件给下游观察者。

#### `Observer` 处理完 `onComplete` 后会还能 `onNext` 吗
`onComplete、onError` 调用后就不能通过 `onNext` 发送数据了。因为 `onComplete、onError` 调用后会通过 `CAS` 设置 `DISPOSED` 标识，调用 `onNext` 时会检查它。

#### `map` 和 `flatMap` 的区别
map是通过原始数据类型返回另外一种数据类型，而flatMap是通过原始数据类型返回另外一种被观察者。

#### `flatMap` 和 `concatMap` 的区别
concatMap和flatMap的功能是一样的， 将一个发射数据的Observable变换为多个Observables，然后将它们发射的数据放进一个单独的Observable。只不过最后合并ObservablesflatMap采用的merge，而concatMap采用的是连接(concat)。总之一句一话,他们的区别在于：concatMap是有序的，flatMap是无序的，concatMap最终输出的顺序与原序列保持一致，而flatMap则不一定，有可能出现交错。

#### `Maybe、Observer、Single、Flowable、Completable` 几种观察者的区别，以及他们在什么场景用

`Maybe`：可能不发送数据，如果发送数据只会发送单条数据。
```
public interface MaybeObserver<@NonNull T> {  
    void onSubscribe(@NonNull Disposable d);
    void onSuccess(@NonNull T t);  
    void onError(@NonNull Throwable e);
    void onComplete();
}
```

`Observer`：能发送多条数据的。

`Single`：发送单条数据，要么成功要么失败。
```
public interface SingleObserver<@NonNull T> {
    void onSubscribe(@NonNull Disposable d);
    void onSuccess(@NonNull T t);
    void onError(@NonNull Throwable e);
}
```

`Flowable`：被压

`Completable`：不发送数据，只会发送成功或失败的事件。
```
public interface CompletableObserver {
    void onSubscribe(@NonNull Disposable d);
    void onComplete();
    void onError(@NonNull Throwable e);
}
```

> 如果只想发一条数据，或者不发数据就用 `Maybe`，如果想法多条数据或者不发数据就用 `Observable`，如果只发一条数据或者失败就用 `Single`，如果想用背压策略使用 `Flowable`，如果不发数据就用 `Completable`。

#### RxJava 如何切换线程

`Schedulers.io()`：内维护了一个工作线程池，由 `CurrentLinkedQueue` 实现。
用于IO密集型的操作，例如读写SD卡文件，查询数据库，访问网络等，具有线程缓存机制，在此调度器接收到任务后，先检查线程缓存池中，是否有空闲的线程，如果有，则复用，如果没有则创建新的线程，并加入到线程池中，如果每次都没有空闲线程使用，可以无上限的创建新线程。

`Schedulers.newThread()`：
在每执行一个任务时创建一个新的线程，不具有线程缓存机制，因为创建一个新的线程比复用一个线程更耗时耗力，虽然使用Schedulers.io( )的地方，都可以使用Schedulers.newThread()，但是，Schedulers.newThread( )的效率没有Schedulers.io()高。

`Schedulers.computation()`：内部维护了一个工作线程池，由数组实现
用于CPU 密集型计算任务，即不会被 I/O 等操作限制性能的耗时操作，例如xml,json文件的解析，Bitmap图片的压缩取样等，具有固定的线程池，大小为CPU的核数。不可以用于I/O操作，因为I/O操作的等待时间会浪费CPU。

`Schedulers.trampoline()`：
在当前线程立即执行任务，如果当前线程有任务在执行，则会将其暂停，等插入进来的任务执行完之后，再将未完成的任务接着执行。

`Schedulers.single()`：
拥有一个线程单例，所有的任务都在这一个线程中执行，当此线程中有任务执行时，其他任务将会按照先进先出的顺序依次执行。

`Schedulers.from(@NonNull Executor executor)`：
指定一个线程调度器，由此调度器来控制任务的执行策略。

`AndroidSchedulers.mainThread()`：`Handler(Looper.getMainLooper())`
在Android UI线程中执行任务，为Android开发定制。

#### `subscribeOn` 分析

```
parent.setDisposable(scheduler.scheduleDirect(new SubscribeTask(parent)));
```

`SubscribeTask` 是一个 `Runnable`，`scheduler.scheduleDirect()` 以它作为参数那说明，其内会在某个线程中执行它的 `run()` 方法：

```
public void run() {
    source.subscribe(parent);
}
```

`run` 方法内部执行订阅操作，`parent` 作为数据发射器存在，执行 `onNext` 等方法，也即是说数据发射在线程中执行。

> `subscribeOn` 实际是规定了上游数据发送所在的线程。

#### `observerOn` 解析

```
source.subscribe(new ObserveOnObserver<>(observer, w, delayError, bufferSize));
```

`ObserveOnObserver` 作为数据发射器存在，没有线程的操作。但是在其内部，如 `onNext` 方法内：

```
worker.schedule(this);
```

由 `worker` 处理数据，而且 `ObserveOnObserver` 是一个 `Runnable`，也即是说数据的处理在另外的线程处理。

> `observerOn` 实际是规定了下游数据处理所在的线程。对于 `Android` 来说，就是通过 `Handler(Looper.getMainLooper)` 将数据发送到主线程。

#### 多次 `subscribeOn` 只有第一次生效
通过上面对 `subscrieOn` 的介绍，知道它的作用是规定数据在那个线程发送，多次执行了 `subscribeOn` 相当于给数据发送方套上了一层层套娃，套娃的层数并不影响最里层发送线程。区别就是中间可能经过了多个线程，但其都是无效的。

#### 多次 `observeOn` 只有最后一次生效
`observeOn` 也是类似，规定的是数据最终要在那个线程处理。
