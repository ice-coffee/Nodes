[Android面试官装逼失败之：Activity的启动模式](https://juejin.cn/post/6844903494470598669)

#### launchmode 
* `standard`：标准启动模式（默认启动模式），每次都会启动一个新的activity实例。
* `singleTop`：单独使用使用这种模式时，如果Activity实例位于当前任务栈顶，就重用栈顶实例，而不新建，并回调该实例onNewIntent()方法，否则走新建流程。
* `singleTask`：这种模式启动的Activity只会存在相应的Activity的taskAffinit任务栈中，同一时刻系统中只会存在一个实例，已存在的实例被再次启动时，会重新唤起该实例，并清理当前Task任务栈该实例之上的所有Activity，同时回调onNewIntent()方法。
* `singleInstance`：这种模式启动的Activity独自占用一个Task任务栈，同一时刻系统中只会存在一个实例，已存在的实例被再次启动时，只会唤起原实例，并回调onNewIntent()方法。

#### taskAffinity

* `taskAffinity`表示一个任务，这个任务就是当前`activity`所在的任务。
* 在概念上，具有相同的`affinity`的`activity`（即设置了相同`taskAffinity`属性的`activity`）属于同一个任务。
* 一个任务的`affinity`决定于这个任务的根`activity（root activity）`的`taskAffinity`。
* 默认情况下，一个应用中的所有`activity`具有相同的`taskAffinity`，即应用程序的包名。我们可以通过设置不同的`taskAffinity`属性给应用中的`activity`分组，也可以把不同的应用中的`activity`的`taskAffinity`设置成相同的值。
* 为一个`activity`的`taskAffinity`设置一个空字符串，表明这个`activity`不属于任何`task`。

#### 查看 Activity 任务堆栈

```
adb shell dumpsys activity activities
```
