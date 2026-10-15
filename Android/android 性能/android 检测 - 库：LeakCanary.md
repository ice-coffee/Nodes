androidx.metrics:metrics-performance[LeakCanary2 源码分析](https://juejin.cn/post/6844904065739014157#heading-10)

通过 `ContentProvider` 初始化

#### `Activity` 泄漏监听

`Application` 注册 `Activity` 声明周期监听：

``` kotlin
application.registerActivityLifecycleCallbacks(lifecycleCallbacks)
```

销毁回调中，将 `Activity` 对象包装为弱引用：

``` kotlin
override fun onActivityDestroyed(activity: Activity) {
    reachabilityWatcher.expectWeaklyReachable(activity, "${activity::class.java.name} received Activity#onDestroy() callback"
    )
}
```

#### Fragment 及 Fragment.View 泄漏监听
`LeakCanary 2.0` 之前是没有 `Fragment` 监听的，之后才提供了对 `Android O` 以及 `androidx` 版本中的 `Fragment` 的内存泄露检测。

通过 `FragmentManager` 注册声明周期监听：

``` kotlin
val fragmentManager = activity.fragmentManager
fragmentManager.registerFragmentLifecycleCallbacks(fragmentLifecycleCallbacks, true)
```

#### Service 泄漏监听
各种反射花活儿

反射获取 `ActivityThread` 中的 `Handler`，监听 `CallBack` 回调的 `SERVICE_STOP` 事件。
反射获取 `ActivityManagerService` 并通过代理监听 `serviceDoneExecuting` 方法。此方法中将 `Service` 包装成弱引用以监听回收。

#### RootView 泄露监听
反射获取 `WindowManagerGlobal` 内 `mViews` 列表，然后设置 `addOnAttachStateChangeListener` 监听 `视图` 移除。

#### 配合弱引用
`ObjectWatcher` 内部维护两个数据结构：
`ReferenceQueue` 队列：当弱引用被 `GC` 回收时，弱引用会被添加到此队列中。
`watchedObjects`：是 `LinkedHashMap`。

每次有新检测的对象加入，会发送 `Handler` 延迟 `5` 秒检测 `ReferenceQueue` 内是否存在此对象，若存在说明被 `GC` 移除，若不存在，说明发生了泄露，通过 `gcTrigger.runGc()` 手动掉用GC。遍历 `ReferenceQueue` 中所有的记录，当未回收对象个数大于 `5` 个时, `dump heap` 获取内存快照 `hprof` 文件。
