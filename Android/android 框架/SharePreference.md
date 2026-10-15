#### 参考
[SharedPreference为什么不适合存储大量数据](https://blog.csdn.net/u010335298/article/details/72884644)
[彻底搞懂 SharedPreferences](https://juejin.im/entry/597446ed6fb9a06bac5bc630)
[SharedPreferences分析](https://xucanhui.com/2019/04/18/SharedPreferences-analysis/)
[SharedPreferences 存在什么问题？](https://mp.weixin.qq.com/s/cyouNcCkC0yCMGK0doLENQ)

#### 性能优化
##### IO瓶颈
IO瓶颈是造成SP性能差的最大原因，解决IO瓶颈，80%的性能问题就解决了。

SP的IO瓶颈包括读取数据到内存与数据写入磁盘两部分。

读取数据到内存有两个场景会触发：

1. SP文件没有被加载到内存时，调用getSharedPreferences方法会初始化文件并读入内存。

2. 版本低于Android-H或使用了MULTI_PROCESS标记时，每次调用getSharedPreference方法时都会读入。
 
优化：

> 我们可以优化的便是第二点了，每次加载数据到内存太过影响效率，但H以下版本已经很低了，基本可以忽略。

> 对于MULTI_PROCESS，可以采用ContentProvider等其他方式，效率更好，而且可避免SP数据丢失的情况。

数据写入到磁盘也有两个场景会触发：

1. Editor的commit方法，每次执行时同步写入磁盘。

2. Editor的apply方法，每次执行时在单线程池中写入磁盘，异步写入。

优化：

> commit和apply的方法区别在于同步写入和异步写入，以及是否需要返回值。

> 在不需要返回值的情况下，使用apply方法可以极大的提高性能。

> 同时，多个写入操作可以合并为一个commit/apply，将多个写入操作合并后也能提高IO性能。

锁性能差
SP的get操作，会锁定SharedPreferences对象，互斥其他操作。

SP的put操作，edit()及commitToMemory会锁定SharedPreferences对象，put操作会锁定Editor对象，写入磁盘更会锁定一个写入锁。

优化：

> 由于锁的缘故，SP操作并发时，耗时会增加。减少锁耗时，是一个优化点。

> 由于读写操作的锁均是SP实例对象的，将数据分拆到不同的sp文件中，便是减少锁耗时的直接方案。

> 降低单文件访问频率，多文件均摊访问，以减少锁耗时。

优化总结
- 强烈建议不要在sp里面存储特别大的key/value, 有助于减少卡顿/anr；
- 请不要高频地使用apply, 尽可能地批量提交;commit直接在主线程操作, 更要注意了；
- 不要使用MODE_MULTI_PROCESS；
- 高频写操作的key与高频读操作的key可以适当地拆分文件, 由于减少同步锁竞争；
- 不要一上来就执行getSharedPreferences().edit(), 应该分成两大步骤来做, 中间可以执行其他代码；
- 不要连续多次edit(), 应该获取一次获取edit(),然后多次执行putxxx(), 减少内存波动; 经常看到大家喜欢封装方法, 结果就导致这种情况的出现；
- 每次commit时会把全部的数据更新的文件, 所以整个文件是不应该过大的, 影响整体性能。
