### Android 关于OOM的解决方案 

[原文链接](http://blog.csdn.net/leehong2005/article/details/8056608)

在Android平台上面，应用程序OOM异常永远都是值得关注的问题。通常这一块也是程序这中的重点之一。这下我就如何解决OOM作一点简单的介绍。

- 首先，OOM就是内存溢出，即Out Of Memory。也就是说内存占有量超过了VM所分配的最大。

- 怎么解决OOM，通常OOM都发生在需要用到大量内存的情况下（创建或解析Bitmap，分配特大的数组等），在这样的一种情况下，就可能出现OOM，据我现在了解到，多数OOM都是因为Bitmap太大。所以，这里我就专门针对如何解决Bitmap的OOM。其实最核发的就是只加载可见范围内的Bitmap，试想这样一种情况，在GridView或ListView中，数据量有5000，每一屏只显示20个元素，那么不可见的，我们是不需要保存Bitmap在内在中的。所以我们就是只把那么可见的Bitmap保留在内存中，那些不可见的，就释放掉。当元素滑出来时，再去加载Bitmap。

这里我有两种方式，都可以避免OOM。
#### 1. 主动释放Bitmap的内存

这种方式我简单说一下，不太推荐，这也是我最开始使用的一种方法，但最后证明它不是最好的。（不推荐）
它的本质思路是：

1. 只加载可见区域的Bitmap

2. 滑动时不加载

3. 停止滑动（Idle）后，开始重新加载可见区域的图片

4. 释放滑出可见区域的Bitmap的内在。

它比较复杂：
- 我们需要监听GridView/ListView的滑动事件，这个很简单做到，AbsListView#setOnScrollListener(OnScrollListener l)
- 主动调用Bitmap#recycle()方法，它会导致一个问题，必须判断这个Bitmap是否被一个View(ImageView等）所引用，如果被引用，我们不能简单地调用recycle()方法，这样会导致异常，说是View使用了一个已经被回收的Bitmap。
- 我们必须设计自己的线程来控制开始/暂停等，因为GridView/ListView的滑动状态可能不断地变化，也就是说滑动->停止->滑动，这种状态可能不断变化，这样就会导致我们的线程中的run()方法里面的逻辑比较复杂，一旦复杂，问题就可能就得更多。

基于以上几点，这种方式不是最好的，所以不推荐。
#### 2. 设计Cache

这种方式，我觉得是比较好的一种，它首先利用了cache，我认为cache是一个很重要的东西，把Bitmap的内存单独放在一个地方来管理，这个地方就是cache，它的容量是一定的，我们可能会不断的向这个cache中添加元素，也可能不断的移除元素。

为了更好的说明这种方式，先要介绍一下LruCache。
##### LruCache

1. 这其实就是一个LinkedHashMap，任意时刻，当一个值被访问时，它就会被移动到队列的开始位置，所以这也是为什么要用LinkedHashMap的原因，因为要频繁的做移动操作，为了提高性能，所以要用LinkedHashMap。当cache满了时，此时再向cache里面添加一个值，那么，在队列最后的值就会从队列里面移除，这个值就有可能被GC回收掉。

2. 如果我们想主动释放内存，也是可以的，我们可以重写entryRemoved(Boolean, K, V, V)方法。

3. 这个类是线程安全的，在多线程下面使用这个类，没不会存在问题。

```
 synchronized (cache) {  
         if (cache.get(key) == null) {  
             cache.put(key, value);  
       }}  
```

4. LruCache的APILevel是12，也就是说，我们在SDK 2.3.x以下是无法使用的，但是没关系，LruCache的源码不算复杂，我们可以直接把它拷贝到自己的工程目录就可以了。

##### AsyncTask<>

这个类也是一个很重要也很常用的类。它封装了Thread和Handler，我们使用就更加方便，不用关注Handler，我们知道，在后台线程中是不能更新UI，而很多情况下，我们在后台线程做完一件事情后，一般都会更新UI，一般的做法是向关联到UI线程的Handler发送一个message，在Handler里面去处理这个message，从而更新UI。用了AsyncTask之后，我们就不用关注Handler了。这个类有几个重要的方法：

1. onPreExecute(): 在UI线程里面调用，它在这个task执行后会立即调用。我们在这个方法里面通常是用于建立一个任务，比如显示一个等待对话框来通知用户。

2. doInBackground(Params...)：这个方法从名字就可以看出，它是运行在后台线程的，在这个方法里面，去做耗时的事情，比如下载访问网络，操作文件等。这这个方法里面，我们可以调用publishProgress(Progress...)来调用当前任务的进度，调用了这个方法后，对应的onProgressUpdate(Progress...)方法会被调用，这个方法是运行在UI线程的。

3. onProgressUpdate(Progress...)：运行在UI线程，在调用publishProgress()方法之后。这个方法用来在UI上显示任何形式的进度，比如你可以显示一个等待对话框，也可以显示一个文本形式的log，还可以显示toast对话框。

4. onPostExecute(Result)：当task结束后调用，它运行在UI线程。

5. 取消一个task，我们可以在任何时候调用cancel(Boolean)来取消一个任务，当调用了cancel()方法后，onCancelled(Object)方法就会被调用，onPostExecute(Object)方法不会被调用，在doInBackground(Object[])方法中，我们可以用isCancelled()方法来检查任务是否取消。

6. 几点规则

    - AsyncTask实例必须在UI线程中创建   
    - execute(Params...)方法必须在UI线程中调用。
    - 不用手动调用onPreExecute(), onPostExecute(), doInBackground(), onProgressUpdate()方法。
    - 一个任务只能被执行一次。

总的思路

1. 始终从cache中去取Bitmap，如果取到Bitmap，就直接把这个Bitmap设置到ImageView上面。

2. 如果缓存中不存在，那么启动一个task去加载（可能从文件来，也可能从网络）。

3. 每一个ImageView上面都可能绑定一个task，所以，这个ImageView必须提供一个方法能得到与之相关联的task，为什么要这样做？因为在给一个ImageView绑定task之前，必须要把原先的task取消。

4. 思路很简单，但细节很多，用文字来一一说明也不太现实。我上传一个demo，大家可以参考代码和文章来理解。

5. 点击下载Demo：[ImageCache](http://download.csdn.net/detail/leehong2005/4632609)
