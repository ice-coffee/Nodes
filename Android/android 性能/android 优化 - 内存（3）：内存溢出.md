[toc]
### 转自 
[Android应用中OOM问题剖析和解决方案](https://www.runoob.com/w3cnote/android-oom.html)

* 栈溢出
* 堆溢出

### 什么是OOM
```
03-21 21:05:28.771: E/dalvikvm-heap(13316): Out of memory on a 10485776-byte allocation.
03-21 21:05:28.779: E/AndroidRuntime(13316): java.lang.OutOfMemoryError
```
这几句的意思是，我们程序申请需要 `10485776byte` 太大了，虚拟机无法满足我们，羞愧的 `shutdown` 自杀了。这个现象通常出现在用到很多图片或者很大图片的 `APP` 开发中。通俗讲就是当我们的 `APP` 需要申请一块内存来装图片的时候，系统觉得我们的 `APP` 所使用的内存已经够多了。即使它有 `1G` 的空余内存，它不同意给我的 `APP` 更多的内存里，然后即使系统马上抛出 `OOM` 错误，而程序没有捕捉该错误，故弹框崩溃了。

### 为什么会有OOM
因为 `android` 系统的 `app` 的每个进程或者每个虚拟机有个最大内存限制，如果申请的内存资源超过这个限制，系统就会抛出 `OOM` 错误。跟整个设备的剩余内存没太大关系。比如比较早的 `android` 系统的一个虚拟机最多 `16M` 内存，当一个 `app` 启动后，虚拟机不停的申请内存资源来装载图片，当超过内存上限时就出现 `OOM`。`Android` 系统的 `APP` 内存限制怎么确定？

#### Android的APP内存组成：
APP内存由 `dalvik内存` 和 `native内存` 2部分组成，`dalvik` 也就是 `java堆`，创建的对象就是就是在这里分配的，而 `native` 是通过 `c/c++` 方式申请的内存，`Bitmap` 就是以这种方式分配的。（android3.0以后，系统都默认通过dalvik分配的，native作为堆来管理）。这2部分加起来不能超过android对单个进程，虚拟机的内存限制。

每个手机的内存限制大小是多少？

``` java
ActivityManager activityManager = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE)
activityManager.getMemoryClass();
```

以上方法会返回以M为单位的数字，不同的系统平台或设备上的值都不太一样，比如HTC默认24M, Galaxy36M, emulator-2.3 24M，等等。我的moto xt681是42M。3

上面取到是虚拟机的最大内存资源。

而对于head堆的大小限制，可以查看/system/build.prop文件。

``` java
dalvik.vm.heapstartsize = 5m
dalvik.vm.heapgrowthlimit = 48m
dalvik.vm.heapsize = 256m
```

注： heapsize参数表示单个进程heap可用的最大内存，但如果存在以下参数"dalvik.vm.headgrowthlimit =48m"表示单个进程heap内存被限定在48m，即程序运行过程实际只能使用48m内存。

#### 为什么android系统设定APP的内存限制？

* `要使开发者内存使用更为合理`：限制每个应用的可用内存上限，可以放置某些应用程序恶意或者无意的使用过多的内存。而导致其它应用无法正常运行。Android是有多进程的，如果一个进程（就是一个应用）耗费过多的内存，其他应用就无法运行了。因为有了限制，使得开发者必须好好利用有限资源，优化资源的使用。
* `屏幕显示内容有限，内存足够即可`：即使有万千图片千万数据需要使用到，但在特定时刻需要展示给用户看的总是有限的，因为屏幕显示就那么大，上面可以放的信息就是很有限的。大部分信息都是处于准备显示状态，所以没必要给予太多heap内存。也就是说出现 OOM现象，绝大部分原因是我们的程序设计上有问题，需要优化 。优化方法很多，比如通过时间换空间，不停的加载要用的的图片，不停的回收不用的图片，把大图片解析成适合手机屏幕大小的图片等。
* `多APP多个虚拟机davlik的限制需要`：android上的app使用独立虚拟机，每开一个应用就会打开至少一个独立的虚拟机。这样可以避免虚拟机崩溃导致整个系统崩溃，同时代价就是需要浪费更多的内存。这样设计保证了android的稳定性。

#### 不是GC自动回收资源么，为什么还会OOM?
`Android` 的 `gc` 会按照特定的算法回收程序不用的内存资源，避免 `app` 的内存申请约积越多，但是 `gc` 一般回收的资源是那些无主的对象内存或者软引用的资源，或者更软引用的引用资源。比如：

``` java
Bitmap bt = BitmapFactory.decodeResource( this .getResources(), R.drawable.splash);  //此时的图片资源是强引用，是有主的资源。
bt ＝  null ;  //此时这个图片资源就是无主的了。gc心情号的时候就会去回收它。
SoftReference<Bitmap> softRef =  new  SoftReference<Bitmap>(bt);
bt =  null ;
其他代码...
```

当程序申请很多内存资源时，`gc` 有可能会释放 `softref` 引用的这个图片内存。`bt＝softRef.get()`，此时可能得到的是null，需要重新加载图片。

当然这也说明了用软引用图片资源的好处，就是gc会自动根据需要释放资源，一定程度上避免 `OOM`。

> TIPS:编程要养成习惯，不用的对象设置为null。其实更好的是，不用的图片直接 `recycle`。因为通过设置null让gc来回收，有时候还是会来不及。

#### 怎么查看APP内存分配情况?

1. 通过DDMS中的heap选项卡监视内存情况：

Heap视图中部有一个叫做data object， 即数据对象，也就是我们的程序中大量存在的类类型的对象。

在data object一行中有一列是"Total Size", 其值就是当前进程中所有Java数据对象的内存总量。如果代码中存在没有释放对象引用的情况，则data object的"Total Size"值在每次gc后不会有美线的回落。随着操作次数的增加"Total Size"的值会越来越大。直到到达一个上限 后导致进程被kill掉。

2. 在App里面我们可以通过totalMemory与freeMemory：

``` java
Runtime.getRuntime().freeMemory()
RUntime.getRuntime().totalMemory()
```
3. adb shell dumpsys meminfo com.android.demo

### 常见避免OOM的几个注意点：

#### 适当调整图像大小
因为手机屏幕尺寸有限，分配给图像的显示区域有限，尤其对于超大图片，加载自网络或者sd卡，图片文件提及达到几M或者十几个M的：加载到内存前，先算出该bitmap的大小，然后通过适当调节采样率使得加载的图片刚好，或稍大捷克在手机屏幕上显示就满意了：

``` java
BimtapFactory.Option opts = new BitampFactory.Option();
opts.inJustDecodeBounds = true ;
opts.inSampleSize=computeSample(opts, minSideLength, maxNumOfPixels);  // Android 提供了一种动态计算的方法 computeSampleSize
opts.inJustDecodeBounds = false;
try {
    return  BitmapFactory.decodeFile(imageFile, opts);
} catch (OutOfMemoryError err){
}
```

#### 图像缓存
在listview或Gallery等控件中一次性加载大量图片时，只加载屏幕显示的资源，尚未显示的不加载，移出屏幕的资源及时释放，采用强引用＋软引用2级缓存，提高加载性能。缓存图像到内存，采用软引用缓存到内存，而不是在每次使用的时候都从新加载到内存。

#### 采用低内存占用量的编码方式
比如Bitmap.Config.ARGB_4444比Bitmap.Config.ARGB_8888更省内存。

#### 及时回收图像
如果引用了大量的Bitmap对象，而应用又不需要同时显示所有图片。可以将暂时不用到的Bitmap对象及时回收掉。对于一些明确直到图片使用情况的场景可以主动recycle回收

App的启动splash画面上的图片资源，使用完就recycle。对于帧动画，可以加载一张，画一张，释放一张。

#### 不要在循环中创建过多的本地变量
慎用static，用static来修饰成员变量时，该变量就属于该类，而不是该类实例，它的生命周期是很长的。如果用它来引用一些内存占用太多的实例，这时候就要谨慎对待了。

#### 自定义堆内存分配大小
优化Dalvik虚拟机的堆内存分配。

### App使用图片时避免OOM的几种方式

#### 直接 null 或 recycle

对于app里使用的大量图片，采用方式：使用时加载，不显示时直接置null或recycle。

这样处理是个好习惯，记本可以杜绝OOM，但是缺憾是代码多了，可能会忘记某些资源recycle。

而有些情况下会出现特定图片反复加载，释放，再加载等，低效率的事情。

#### 简单通过 SoftReference 引用方式管理图片资源

建个SoftReference的hashmap

使用图片时先查询这个hashmap是否有softreference， softreference里的图片是否为空，

如果为空就加载图片到softreference并加入hashmap。

无需再代码里显式的处理图片的回收与释放，gc会自动处理资源的释放。

这种方式处理起来简单实用，能一定程度上避免前一种方法反复加载释放的低效率。但还不够优化。

#### 强引用＋软引用二级缓存

Android示范程序ImageDownloader.java, 使用了一个二级缓存机制。就是有一个数据结构直接持有解码成功的Bitmap对象引用，同时使用一个二级缓存数据结构保持淘汰的Bitmap的softreference对象，由于softreference对象的特殊性，系统会再需要内存的时候首先将softreference持有的对象释放掉，也就是说当vm发现可用的内存较少需要出发gc的时候，二级缓存中的bitmap对象将被回收，而持有一级缓存的bitmap对象用于显示。

其实这个解决方案最为关键的一点是使用了一个比较合适的数据结构，那就是LinkedHashMap类型来进行一级缓存Bitmap的容器。由于LinkeHashMap的特殊性，我们可以控制其内存存储对象的个数并且将不在使用的对象从容器中移除，放到softreference二级缓存里，我们可以在一级缓存中一致保存最近被访问到的bitmap对象，而已经被访问过的图片在LinkedHashMap的容量超过我们预设值时将会把容器中存在的时间最长的对象移除，这个时候我么可以将被移除的LinkedHashMap中的放到二级缓存容器，而二级缓存中的对象管理就交给系统来做了，当系统需要gc时就会首先回收二级缓存容器的Bitmap对象了。

在获取图片对象时候先从一级缓存容器中查找，如果有对应对象并可用直接返回，如果没有的话从二级缓存中查找对应的SoftReference, 判断SoftReference对象持有的Bitmap是否可用，可用直接返回，否则返回空。如果二级缓存都找不到图片，那就直接加载图片资源。

#### LruCache  + sd的缓存方式

### 两种容易OOM的场景建议

#### 网络下载大量图片

比如微博客户端： 多线程异步网络，小兔直接用LRUCache+SoftRef+Sd，大图按需下载：

#### 对于需要加载非常多条目信息的listview，gridview等的情况

在adapter的getView函数里有个convertView参数，告知你是否有可重用的view对象。 如果不使用convertView的话，每次调用getView时每次都会重新创建view，这样之前的view可能还没销毁，加之不断的新建view势必会造成内存剧增，从而导致OOM。另外在重用convertView时，里面原有的图片等资源就会变成无主的了。

这里Google官方推荐使用："convertview＋静态类viewholder"

官方给出解释是：

a 重用缓存convertView传递给getView()方法来避免填充不必要的视图。

  b 使用ViewHolder模式来避免没有必要的调用findViewById；因为太多的findViewById也会影响性能。

 

附ViewHolder类的作用：ViewHolder模式通过在getView方法返回的视图的标签（tag）中存储一个数据结构。这个数据结构包含了指向我们要绑定数据的视图的引用，从而避免每次调用getView()的时候调用findViewById();

### 申请超过内存限制的内存分配方式
#### 从Native C分配内存
使用NDK(本地开发工具包)和JNI, 它可能从C级(如malloc/free或新建／删除)分配内存，这样的分配是不计入24MB的限制。这是真的，从本机代码分配内存是为了java方便，但它可以被用来存储在ram的数据（即使图片数据）的一些打击呢。

#### 使用OpenGL的纹理
纹理内存不计入限制，要查看你的应用程序确实分配了多少内存可以使用android.os.Debug.getNativeHeapAllocatedSize(), 可以使用上面介绍的两种技术的Nexus之一，我可以轻松地为一个单一的前台进程分配300MB-10倍以上的默认24MB 的限制，从上面看来使用native代码分配内存是不在24MB的限制内的（开放的GL的质地也是使用native代码分配内存）。

但是，这两个方法的风险就是，本地堆分配内存超过系统可用内存限制的话，通常都是直接崩溃。
