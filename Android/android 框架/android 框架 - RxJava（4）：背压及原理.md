### 背压
背压是指在异步场景中，被观察者发送事件速度远快于观察者的处理速度的情况下，一种告诉上游的被观察者降低发送速度的策略。

根据定义可知，背压产生的条件：

- 异步场景
- 数据发送速度远大于数据的处理速度

解决背压问题的两种方式：

- 提高下游处理数据的速度
- 上游选择合适的背压策略

### 使用背压

- `Flowable.create(source, mode)`
- `toFlowable(mode)`

* 在订阅的时候如果使用 `FlowableSubscriber`，那么需要通过 `s.request(Long.MAX_VALUE)` 去主动请求上游的数据项。如果遇到背压报错的时候，`FlowableSubscriber` 默认已经将错误 `try-catch`，并通过 `onError()` 进行回调，程序并不会崩溃。
* 在订阅的时候如果使用 `Consumer`，那么不需要主动去请求上游数据，默认已经调用了 `s.request(Long.MAX_VALUE)`。如果遇到背压报错、且没有添加对 `Throwable` 的 `Consumer`，则程序直接崩溃。
* 背压策略的上游的默认缓存池是 `128`。

### 背压策略

**`下游处理`**：下游缓存池满则报错，并停止发送。
- `MISSION`：表示上游不对数据源进行任何处理。

**`上游处理`**：
* `ERROR`：超过 `bufferSize` 则调用观察者的 `onError` 方法。
* `DROP`：先处理 `bufferSize` 个数据，接着每次处理最新的 `bufferSize - (bufferSize >> 2)` 个数据。
* `LATEST`：通过 `AtomicReference` 保存最新从上游发送的数据，若数据未来得及处理则会被新的数据所替换。
* `BUFFER`：在上游创建一个缓存，把所有上游的数据先保存到缓存中，下游从缓存中取出数据。

### 背压产生的原理
根据背压产生的条件，可以判断只有调用了 `observeOn` 函数才会产生背压。

``` java
public final Flowable<T> observeOn(@NonNull Scheduler scheduler) {
    return observeOn(scheduler, false, bufferSize());
}

/**
 * @param scheduler：观察者所在的线程
 * @param delayError：是否延迟调用 onError，直到
 * @param bufferSize：上游发送数据的缓存大小
 */
public final Flowable<T> observeOn(@NonNull Scheduler scheduler, boolean delayError, int bufferSize) {
    }
```

在创建的 `FlowableObserveOn` 内生成了一个大小为 `bufferSize` 的数组用于保存未处理的数据。

数据放入数组调用 `queue.offer(t)`，调用 `q.poll()` 取出数据，并通过 `checkTerminated` 方法判断，若缓存数组已满则执行 `Subscrier.onError`。
