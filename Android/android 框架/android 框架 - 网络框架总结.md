> 区分
- HttpClient
- HttpUrlConnection
- Okhttp
- Retrofit
- Android-Async-Http
- Volley
- NoHttp

简单说一下,这里的

一下选择恐惧症就上来了, 看了知乎和简书里大神的指导, 稍微总结下:


### 纠错:
> [stay4it](http://www.jianshu.com/users/6e4c6553a7f9/latest_articles)
> [原文链接](http://www.jianshu.com/p/77d418e7b5d6)

我们来先说一个常识性的错误：
volley, retrofit, android-async-http 帮你封装了具体的请求，线程切换以及数据转换。

而OkHttp 是基于http协议封装的一套请求客户端，虽然它也可以开线程，但根本上它更偏向真正的请求，跟HttpClient, HttpUrlConnection的职责是一样的。

所以不要混淆。

### 各个框架分析
1. 首先，我想即使你单纯使用OkHttp，还是会再包一层的，这样就等价于Volley之流的框架，只是封装的好与坏而已。

2. android-async-http内部实现是基于HttpClient, 想必你肯定知道6.0之后HttpClient是不是系统自带的了，不过它在最近的更新中将HttpClient的所有代码copy了一份进来，所以还能使用, 但是应该已经不适合android平台了

3. Volley是官方出的，volley在设计的时候是将具体的请求客户端做了下封装：HurlStack，也就是说可以支持HttpUrlConnection, HttpClient, OkHttp，相当于模版模式吧，这样解耦还是非常方便的，可以随意切换，如果你之前使用过Volley，并习惯使用，那直接写个OkHttp扩展就行了。但是它的缺点也非常明显, 第一: 它不支持同步; 第二: 它对于大量数据的访问处理的并不好.

4. Retrofit因为也是square出的，所以大家可能对它更崇拜些。Retrofit的跟Volley是一个套路，但解耦的更彻底:比方说通过注解来配置请求参数，通过工厂来生成CallAdapter，Converter，你可以使用不同的请求适配器(CallAdapter), 比方说RxJava，Java8, Guava。你可以使用不同的反序列化工具(Converter)，比方说json, protobuff, xml, moshi等等。超级解耦，里面涉及到超多设计模式，个人觉得是很经典的学习案例。虽然支持Java8， Guava你可能也不需要用到。xml，protobuff等数据格式你也可能不需要解析。but，万一遇到鬼了呢。

5. NoHttp

### 总结
> 至于性能上，个人觉得这完全取决于请求client，也就是okhttp的性能，跟这些封装工具没太大关系。
