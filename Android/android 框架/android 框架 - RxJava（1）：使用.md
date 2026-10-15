[toc]

### 名词翻译
- Observable :  被观察者
- Observer : 观察者
- subscribe : 订阅
- Consumer : 消费者

| 单词    |   译   |   作用   |
| :-------- | :--------:| :------: |
| Observable |   被观察者|  上游, 发送事件  |
| Observer |   观察者|  下游, 处理事件  |
| subscribe |   订阅|  连接上下游关系|
| Consumer |   消费者|  同observer  |
| subscribeOn|   订阅线程|  设置上游事件产生所在线程  |
| observeOn|   消费线程|  下游游事件消费所在线程  |

### 函数介绍
- 上游可以发送无限个`onNext`, 下游也可以接收无限个`onNext`.
- 当上游发送了一个`onComplete`后, 上游`onComplete`之后的事件将会`继续`发送, 而下游收到onComplete事件之后将`不再继续`接收事件.
- 当上游发送了一个`onError`后, 上游`onError`之后的事件将`继续`发送, 而下游收到`onError`事件之后将`不再继续`接收事件.
- 上游可以不发送`onComplete`或`onError`.
- 最为关键的是`onComplete`和`onError`必须`唯一并且互斥`, 即`不能`发多个`onComplete`, 也`不能`发多个`onError`, 也不能先发一个onComplete, 然后再发一个onError, 反之亦然

### 操作符介绍
#### map
map是RxJava中最简单的一个变换操作符了, 它的作用就是对上游发送的每一个事件应用一个函数, 使得每一个事件都按照指定的函数去变化. 用事件图表示如下:
![enter image description here](https://user-gold-cdn.xitu.io/2016/12/8/687f0f77b5312ef738169bda56bdee2a)

```
Observable.create(new ObservableOnSubscribe<Integer>() {
            @Override
            public void subscribe(ObservableEmitter<Integer> emitter) throws Exception {
                emitter.onNext(1);
                emitter.onNext(2);
                emitter.onNext(3);
            }
        }).map(new Function<Integer, String>() {
            @Override
            public String apply(Integer integer) throws Exception {
                return "This is result " + integer;
            }
        }).subscribe(new Consumer<String>() {
            @Override
            public void accept(String s) throws Exception {
                Log.d(TAG, s);
            }
        });
```

#### FlatMap
FlatMap将一个发送事件的上游Observable变换为多个发送事件的Observables，然后将它们发射的事件合并后放进一个单独的Observable里.
![enter image description here](https://user-gold-cdn.xitu.io/2016/12/8/a0117e88d166f9b08c9e7316994dc721)
上游每发送一个事件, flatMap都将创建一个新的水管, 然后发送转换之后的新的事件, 下游接收到的就是这些新的水管发送的数据. 这里需要注意的是, flatMap并不保证事件的顺序, 也就是图中所看到的, 并不是事件1就在事件2的前面. 如果需要保证顺序则需要使用concatMap.

```
Observable.create(new ObservableOnSubscribe<Integer>() {
    @Override
    public void subscribe(ObservableEmitter<Integer> emitter) throws Exception {
        emitter.onNext(1);
        emitter.onNext(2);
        emitter.onNext(3);
    }
}).flatMap(new Function<Integer, ObservableSource<String>>() {
    @Override
    public ObservableSource<String> apply(Integer integer) throws Exception {
        final List<String> list = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            list.add("I am value " + integer);
        }
        return Observable.fromIterable(list).delay(10,TimeUnit.MILLISECONDS);
    }
}).subscribe(new Consumer<String>() {
    @Override
    public void accept(String s) throws Exception {
        Log.d(TAG, s);
    }
});
```

#### Zip
Zip通过一个函数将多个Observable发送的事件结合到一起，然后发送这些组合到一起的事件. 它按照严格的顺序应用这个函数。它只发射与发射数据项最少的那个Observable一样多的数据。

![enter image description here](https://user-gold-cdn.xitu.io/2016/12/9/455b326b3b18dc75970e5b48b4d3f2a0)

```
Observable<Integer> observable1 = Observable.create(new ObservableOnSubscribe<Integer>() {            
    @Override                                                                                         
    public void subscribe(ObservableEmitter<Integer> emitter) throws Exception {                      
        Log.d(TAG, "emit 1");                                                                         
        emitter.onNext(1);                                                                            
        Log.d(TAG, "emit 2");                                                                         
        emitter.onNext(2);                                                                            
        Log.d(TAG, "emit 3");                                                                         
        emitter.onNext(3);                                                                            
        Log.d(TAG, "emit 4");                                                                         
        emitter.onNext(4);                                                                            
        Log.d(TAG, "emit complete1");                                                                 
        emitter.onComplete();                                                                         
    }                                                                                                 
});                                                                   

Observable<String> observable2 = Observable.create(new ObservableOnSubscribe<String>() {              
    @Override                                                                                         
    public void subscribe(ObservableEmitter<String> emitter) throws Exception {                       
        Log.d(TAG, "emit A");                                                                         
        emitter.onNext("A");                                                                          
        Log.d(TAG, "emit B");                                                                         
        emitter.onNext("B");                                                                          
        Log.d(TAG, "emit C");                                                                         
        emitter.onNext("C");                                                                          
        Log.d(TAG, "emit complete2");                                                                 
        emitter.onComplete();                                                                         
    }                                                                                                 
});                                                                     

Observable.zip(observable1, observable2, new BiFunction<Integer, String, String>() {                  
    @Override                                                                                         
    public String apply(Integer integer, String s) throws Exception {                                 
        return integer + s;                                                                           
    }                                                                                                 
}).subscribe(new Observer<String>() {                       
    @Override                                                                                         
    public void onSubscribe(Disposable d) {                                                           
        Log.d(TAG, "onSubscribe");                                                                    
    }                                                                                                 

    @Override                                                                                         
    public void onNext(String value) {                                                                
        Log.d(TAG, "onNext: " + value);                                                               
    }                                                                                                 

    @Override                                                                                         
    public void onError(Throwable e) {                                                                
        Log.d(TAG, "onError");                                                                        
    }                                                                                                 

    @Override                                                                                         
    public void onComplete() {                                                                        
        Log.d(TAG, "onComplete");                                                                     
    }                                                                                                 
});
```
输出

```
D/TAG: onSubscribe     
D/TAG: emit 1          
D/TAG: emit 2          
D/TAG: emit 3          
D/TAG: emit 4          
D/TAG: emit complete1  
D/TAG: emit A          
D/TAG: onNext: 1A      
D/TAG: emit B          
D/TAG: onNext: 2B      
D/TAG: emit C          
D/TAG: onNext: 3C      
D/TAG: emit complete2  
D/TAG: onComplete
```

#### zipWith
[RxJava（五）zipWith操作符](http://www.jianshu.com/p/6633e635910f)

#### sample

### Flowable
Flowable 可以作为事件上游也就是被观察者, 发送事件, 此时下游就需要使用Subscriber作为观察者消费事件, 上下游关系的连接还是使用subscribe().

```
Flowable<Integer> upstream = Flowable.create(new FlowableOnSubscribe<Integer>() {
            @Override
            public void subscribe(FlowableEmitter<Integer> emitter) throws Exception {
                Log.d(TAG, "emit 1");
                emitter.onNext(1);
                Log.d(TAG, "emit 2");
                emitter.onNext(2);
                Log.d(TAG, "emit 3");
                emitter.onNext(3);
                Log.d(TAG, "emit complete");
                emitter.onComplete();
            }
        }, BackpressureStrategy.ERROR); //增加了一个参数

        Subscriber<Integer> downstream = new Subscriber<Integer>() {

            @Override
            public void onSubscribe(Subscription s) {
                Log.d(TAG, "onSubscribe");
                s.request(Long.MAX_VALUE);  //注意这句代码
            }

            @Override
            public void onNext(Integer integer) {
                Log.d(TAG, "onNext: " + integer);

            }

            @Override
            public void onError(Throwable t) {
                 Log.w(TAG, "onError: ", t);
            }

            @Override
            public void onComplete() {
                Log.d(TAG, "onComplete");
            }
        };

        upstream.subscribe(downstream);
```

#### BackpressureStrategy
- ERROR : 当事件超过128个时, 报错BackpressureException
- BUFFER : 缓冲所有onNext值，直到下游消耗它。
- DROP :  把存不下的事件丢弃
- LATEST : 只保留最新的事件
#### request
设置事件处理器的处理能力
FlowableEmitter对象可以获取事件处理的能力

#### interval
定时发送请求

```
Flowable.interval(1, TimeUnit.MICROSECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Subscriber<Long>() {
                    @Override
                    public void onSubscribe(Subscription s) {
                        Log.d(TAG, "onSubscribe");
                        mSubscription = s;
                        s.request(Long.MAX_VALUE);
                    }

                    @Override
                    public void onNext(Long aLong) {
                        Log.d(TAG, "onNext: " + aLong);
                        try {
                            Thread.sleep(1000);  //延时1秒
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void onError(Throwable t) {
                        Log.w(TAG, "onError: ", t);
                    }

                    @Override
                    public void onComplete() {
                        Log.d(TAG, "onComplete");
                    }
                });
```

每隔一秒发送请求

### 扩展
- RxBinding
- RxPermissions
- RxBus

### 参考
[RxJava2 浅析](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2016/0907/6604.html)
[给初学者的RxJava2.0教程](https://juejin.im/post/5848d96761ff4b0058c9d3dc)
[是时候学习 RxJava 了](https://juejin.im/entry/5761718880dda4005f6fa9d1)
[RxJava2--操作符](https://blog.csdn.net/shangmingchao/article/details/73502564)
[使用RxBinding响应控件的异步事件](http://www.jianshu.com/p/c2c7c46e6b97)
[RxBus真的能替代EventBus吗？](http://www.jianshu.com/p/669eda5dc5a4)
[这可能是最好的RxJava 2.x 教程](http://www.jianshu.com/p/0cd258eecf60)
