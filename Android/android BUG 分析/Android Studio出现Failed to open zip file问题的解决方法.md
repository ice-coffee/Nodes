## Android Studio出现Failed to open zip file问题的解决方法

@(android BUG记录)

[Android Studio出现Failed to open zip file问题的解决方法](http://www.jcodecraeer.com/a/anzhuokaifa/Android_Studio/2017/0317/7691.html)

最近从github上下载的项目总是遇到这样的编译问题：

![enter image description here](http://www.jcodecraeer.com/uploads/20170317/1489732119945623.png)

在网上搜索了一下，发现问题出在gradle-wrapper.properties

一般出现这种问题的项目都是因为使用了gradle-3.3-all.zip，而gradle-3.3-all.zip无法直接在studio中下载下来。

```
distributionUrl=https\://services.gradle.org/distributions/gradle-3.3-all.zip
```

解决这个问题的办法有好几个：

- 可以把gradle-wrapper.properties里修改了gradle的版本，与之前没有报错的gradle版本一致，然后再修改项目build.gradle文件中的com.android.tools.build:gradle的版本号，具体是多少也是参照以前那些没有报错的项目。

- 直接在网上找到gradle-3.3-all.zip下载下来，不要解压缩，放在类似下面的目录中 C:\Users\Administrator\.gradle\wrapper\dists\gradle-3.3-all\55gk2rcmfc6p2dg9u9ohc3hw9，这个办法没有试过，按理说是可以的。下载地址在这里找：http://services.gradle.org/distributions/ ，里面各个版本都有。

- 最简单的方法，也是我采用的方法，就是改一下gradle-wrapper.properties中的distributionUrl将

```
distributionUrl=https\://services.gradle.org/distributions/gradle-3.3-all.zip
```

改成

```
distributionUrl=http\://services.gradle.org/distributions/gradle-3.3-all.zip
```

其实这里的区别就是https和http。因为我发现`http://services.gradle.org/distributions/`中也是没带s的，所以就这样试了下，但奇怪的是每个版本的包文件其实下载地址也是带s的，在浏览器中可以直接下载，那么问题应该出在studio了。

ps：微博上有人说多点几次Re-download就能解决问题，但是我这边是不行的。跟我一样的同学可以直接试我的第三种方法啦。
