### Activity
- 生命周期
- screenOrientation属性
- configChange属性
- 启动模式、各种Flag、taskAffinity
- Intent 中各个属性
- Context、Activity、Application的关系和区别

### Service
- 服务中的函数
- Service与Activity如何通讯
- Service 运行在主线程吗？
- IntentService
- aidl

### Broadcast
- 广播的分类
- 修改广播内容
- 本地广播
- 广播 Android 8.0 问题

### ContentProvider

### Fragment
- 生命周期
- Fragment 动态添加
- Fragment 嵌套问题
- Fragment 与 Activity 间的通讯
- Fragment 数据传递
- add() 和 replace()
- setUserVisibleHint 调用时机

### 内存不足时，怎么保持Activity的一些状态，在哪个方法里面做具体操作？

### Android 启动模式、各种Flag、taskAffinity
Android singleTask、singleInstance启动模式隐式设置了Intent.FLAG_ACTIVITY_NEW_TASK，设置了此标志标识在启动时会判断taskAffinity(亲和性)是否一致，若一致则在同一task中创建或显示，当然singleInstance是一定会创建新的task的

Intent.FLAG_ACTIVITY_NEW_TASK
Intent.FLAG_ACTIVITY_CLEAR_TASK
Intent.FLAG_ACTIVITY_CLEAR_TOP
Intent.FLAG_ACTIVITY_SINGLE_TOP
