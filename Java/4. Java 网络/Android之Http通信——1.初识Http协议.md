### Android之Http通信——1.初识Http协议

@(android http)


[HTTP权威指南笔记](http://www.cnblogs.com/qcssmd/p/5508150.html)

[HTTP协议详解（真的很经典）](http://www.cnblogs.com/li0803/archive/2008/11/03/1324746.html)

[HTTP协议详解](http://www.cnblogs.com/EricaMIN1987_IT/p/3837436.html)

[HTTP Session、Cookie机制详解](https://www.cnblogs.com/lyy-5518/p/5460994.html)

[Android之Http通信——2.详解Http的消息头与响应头](http://blog.csdn.net/coder_pig/article/details/46324819)

[Android之Http通信——3.Android HTTP请求方式:HttpURLConnection](http://blog.csdn.net/coder_pig/article/details/46333841)

[Android之Http通信——4.Android HTTP请求方式:HttpClient](http://blog.csdn.net/coder_pig/article/details/46355903)

[Android：这是一份很详细的Socket使用攻略](http://blog.csdn.net/carson_ho/article/details/53366856)

[HTTP 缓存](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Caching_FAQ)

[影响Cache的几个HTTP头信息](http://blog.51cto.com/tech110/549764)

[HTTP Get和Post的区别](https://segmentfault.com/a/1190000018129846)
个人理解，Get和Post的区别主要是定义区别，Get是用来获取Uri指向的数据，而Post是用来请求服务器接受请求中包含的数据作为Uri指向数据的下级。其他的Uri长度限制啊，不可缓存这些都是服务端或浏览器为了安全等一些因素做的

HttpClient拥有众多的API，而且实现比较稳定，bug数量也很少。

但同时也由于HttpClient的API数量过多，使得我们很难在不破坏兼容性的情况下对它进行升级和扩展，所以目前Android团队在提升和优化HttpClient方面的工作态度并不积极。

Android 6.0 后HttpClient被弃用.

HttpURLConnection是一种多用途、轻量极的HTTP客户端，使用它来进行HTTP操作可以适用于大多数的应用程序。虽然HttpURLConnection的API提供的比较简单，但是同时这也使得我们可以更加容易地去使用和扩展它。

不过在Android 2.2版本之前，HttpURLConnection一直存在着一些令人厌烦的bug。
