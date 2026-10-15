[toc]

### 变换

#### map
`map` 的作用在于，将上游数据根据某种规则进行转换，例如将 `int` 转换为 `String` 型数据。

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/map.png)

``` java
public void onNext(T t) {
    try {
        v = Objects.requireNonNull(mapper.apply(t), "The mapper function returned a null value.");
    } catch (Throwable ex) {
        fail(ex);
        return;
    }
    downstream.onNext(v);
}
```

* `downstream`：下游数据观察者
* `mapper`：`map` 方法的传参，用于转换数据

原理：`map` 操作符，生成 `ObservableMap` 被观察者和 `MapObserver` 观察者。上游发送发送数据，在 `MapObserver.onNext` 内调用 `mapper.apply` 方法对数据进行转换，并调用 `downstream.onNext` 方法传递转换后的数据给下游。

#### flatmap
`flatmap` 的作用在于，根据上游发送数据，生成新的数据源。
使用场景：适合嵌套的数据结构。

![](https://mcxiaoke.gitbooks.io/rxdocs/content/images/operators/flatMap.png)

``` java
ObservableSource<? extends U> p;
try {
    p = Objects.requireNonNull(mapper.apply(t), "The mapper returned a null ObservableSource");
} catch (Throwable e) {
    Exceptions.throwIfFatal(e);
    upstream.dispose();
    onError(e);
    return;
}
```

### 组合

#### merge
`merge` 合并多个被观察者。相当于将下游观察者在每个被观察者内都注册了一遍。

`被观察者之间互不影响`

数据接收顺序：

* 同步：按合并顺序
* 异步：按时间顺序
```
return fromArray(source1, source2).flatMap((Function)Functions.identity(), false, 2);
```

`merge` 操作分为两步：`fromArray`、`flatMap`

#### zip
`zip` 会根据要合并的多个 `Observable`，生成对应数量的 `ZipObserver`。`ZipObserver` 内部维护一个队列。每次从所有 `ZipObserver` 的队列中取一个元素如果某一队列为空，则停止。

#### concat
`concat` 和 `merge` 不同之处在于使用 `concat` 合并的数据源，下周观察者接收数据的顺序一定是 `concat` 函数的传参数据。这是由于 `concat` 内部类的观察者每次只让下游观察者订阅一个被观察者，当 `onError、onComplete` 调用时再订阅下一个被观察者。

``` java
// ConcatMapDelayErrorObserver
@Override
public void onSubscribe(Disposable d) {
    // 被观察者队列
    QueueDisposable<T> qd = (QueueDisposable<T>) d;
    // 队列类型？
    int m = qd.requestFusion(QueueDisposable.ANY);
    if (m == QueueDisposable.SYNC) {
        sourceMode = m;
        queue = qd;
        done = true;

        downstream.onSubscribe(this);
        // 去启动订阅
        drain();
        return;
    }
}

// 

static final class DelayErrorInnerObserver<R> extends AtomicReference<Disposable> implements Observer<R> {
    @Override
    public void onNext(R value) {
        // 向下游发送数据
        downstream.onNext(value);
    }

    @Override
    public void onError(Throwable e) {
        ConcatMapDelayErrorObserver<?, R> p = parent;
        if (p.errors.tryAddThrowableOrReport(e)) {
            if (!p.tillTheEnd) {
                p.upstream.dispose();
            }
            p.active = false;
            // 上有数据源发送 onError 则切换到下一个数据源
            p.drain();
        }
    }

    @Override
    public void onComplete() {
        ConcatMapDelayErrorObserver<?, R> p = parent;
        p.active = false;
        // 上有数据源发送 onComplete 则切换到下一个数据源
        p.drain();
    }
}
```

### 连接
#### public
生成可连接的 `Observable`，当 `connect` 掉用后，上游被观察者发送数据。

``` java
ConnectableObservable observable = Observable.just(1, 2, 3, 4).publish();
observable.subscribe(value -> Log.e("rxjava", "1" + value));
observable.subscribe(value -> Log.e("rxjava", "2" + value));

observable.connect();
```

这是因为调用 `connect` 后才会将下游观察者订阅到被观察者。

而且在 `connect` 之后添加的观察者不能收到已经发送过的数据。

``` java
// ObservablePublish
static final class PublishConnection<T>
extends AtomicReference<InnerDisposable<T>[]>
implements Observer<T>, Disposable {
    @Override
    public void onNext(T t) {
        for (InnerDisposable<T> inner : get()) {
            inner.downstream.onNext(t);
        }
    }
}
```

#### replay
`replay` 保证所有的观察者收到被观察者发送的所有数据，即使它们在 `Observable` 开始发射数据之后才订阅。这是因为被观察者的发送的数据会被保存在一个 `ArrayList` 中。

``` java
ConnectableObservable observable = Observable.just(1, 2, 3, 4).replay();
observable.subscribe(value -> Log.e("rxjava", "1" + value));
observable.subscribe(value -> Log.e("rxjava", "2" + value));

observable.connect();
```

#### refCount
让一个可连接的 `Observable` 行为像普通的 `Observable`。

#### connect
执行订阅。
