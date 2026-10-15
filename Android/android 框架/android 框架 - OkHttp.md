[Okhttp 面试](https://cloud.tencent.com/developer/article/1601358)

[OkHttp源码深度解析](https://zhuanlan.zhihu.com/p/116777864)

`Dispatcher` 调度器内部创建的线程池，数量 Int.MAX_VALUE

### 七层拦截器

`Okhttp` 通过责任链模式链接：

* `用户自定义拦截器`：；
* `retryAndFollowUpInterceptor`：失败和重定向拦截器；
* `BridgeInterceptor`：封装request和response拦截器；
* `CacheInterceptor`：缓存相关的过滤器，负责读取缓存直接返回、更新缓存；
* `ConnectInterceptor`：连接服务，负责和服务器建立连接 这里才是真正的请求网络；
* `CallServerInterceptor`：执行流操作(写出请求体、获得响应数据) 负责向服务器发送请求数据、从服务器读取响应数据 进行http请求报文的封装与请求报文的解析；

#### 用户自定义拦截器
用户自定义拦截器是在所有其他拦截器之前，开发者可根据业务需求进行网络拦截器的自定义，例如我们常常自定义Token处理拦截器，日志打印拦截器等。

#### retryAndFollowUpInterceptor
内部开启了一个 `while(true)` 的循环，并在循环内部完成两个重要的判定，如图中的蓝色方框：

* 当请求内部抛出异常时，判定是否需要重试
* 当响应结果是3xx重定向时，构建新的请求并发送请求

#### BridgeInterceptor
BridageInterceptor 拦截器的功能如下：

* 负责把用户构造的请求转换为发送到服务器的请求 、把服务器返回的响应转换为用户友好的响应，是从应用程序代码到网络代码的桥梁
* 设置内容长度，内容编码
* 设置gzip压缩，并在接收到内容后进行解压。省去了应用层处理数据解压的麻烦
* 添加cookie
* 设置其他报头，如User-Agent,Host,Keep-alive等。其中Keep-Alive是实现连接复用的必要步骤。

#### CacheInterceptor
处理请求缓存。
通过 `cache` 以 `key = request.url, value = response` 的方式缓存请求，缓存逻辑依据请求头的 `cache_control` 字段处理请求缓存，例如：

```
cache-control: private, must-revalidate, no-cache, no-store, max-age=0
```

`cache` 是一个 `DiskLruCache`。

`OkhttpClient.Builder` 中 `cache` 默认为空，也就是默认不缓存请求，并且 `cache-control` 需要客户端配置请求头实现？

#### ConnectInterceptor
实现请求连接复用，重点在于请求头内的 `"Connection = Keep-Alive` 表示连接可复用。

连接池由 `ArrayDeque` 实现，这是一个由数组实现的双端队列。

#### NetworkInterceptors

#### CallServerInterceptor

* 向服务器发送 request header
* 如果有 request body，就向服务器发送
* 读取 response header，先构造一个 Response 对象
* 如果有 response body，就在 3 的基础上加上 body 构造一个新的 Response 对象

这里我们可以看到，核心工作都由 HttpCodec 对象完成，而 HttpCodec 实际上利用的是 Okio，而 Okio 实际上还是用的 Socket，只不过一层套一层，层数有点多。

#### Interceptors和NetworkInterceptors的区别

前面提到，在OkHttpClient.Builder的构造方法有两个参数，使用者可以通过addInterceptor 和 addNetworkdInterceptor 添加自定义的拦截器，分析完 RetryAndFollowUpInterceptor 我们就可以知道这两种自动拦截器的区别了。

从前面添加拦截器的顺序可以知道 Interceptors 和 networkInterceptors 刚好一个在 RetryAndFollowUpInterceptor 的前面，一个在后面。

结合前面的责任链调用图可以分析出来，假如一个请求在 RetryAndFollowUpInterceptor 这个拦截器内部重试或者重定向了 N 次，那么其内部嵌套的所有拦截器也会被调用N次，同样 networkInterceptors 自定义的拦截器也会被调用 N 次。而相对的 Interceptors 则一个请求只会调用一次，所以在OkHttp的内部也将其称之为 Application Interceptor。

#### Okhttp 连接复用实现
> 注意：`Response` 只有读取后 `RealCall.exchange` 才会释放，才会去复用连接。当然正常情况下我们是一定会去读取 `Response` 中的数据的。

获取复用连接流程如下：

1. 从连接池中查找：如果存在可用连接则返回；
2. 传入Route，从连接池中查找：查找符合 url host 和端口号的链接；
3. 自己创建连接：自己创建；
4. 多路复用置为true，依然从连接池中查找：查找支持多路复用的链接；

连接池数据结构：`ConcurrentLinkedQueue`，线程安全的单链表，线程安全由 `CAS` 维护，节点遵循先进先出的原则。

#### Okhttp 缓存策略
[OKHTTP之缓存配置详解](https://cloud.tencent.com/developer/article/1383143)

> 注意：`Okhttp` 在项目中应使用同一个实例对象。

首先需要新建 `Cache`，并加入 `OkhttpClient` 对象：
```
//缓存文件夹
val cacheFile = File(directoryPath: String)
//缓存大小为10M
val cacheSize = 10 * 1024 * 1024
//创建缓存对象
val cache = Cache(cacheFile, cacheSize.toLong())

val client: OkHttpClient = OkHttpClient.Builder()
    .cache(cache)
    .build()
```

这样就可以对 `Response` 进行缓存了。

缓存配置分两种情况：

相应缓存设置：添加 `NetworkInterceptor`。

```
class CacheInterceptor implements Interceptor{

    @Override
    public Response intercept(Chain chain) throws IOException {

        Response originResponse = chain.proceed(chain.request());

        //设置缓存时间为60秒，并移除了pragma消息头，移除它的原因是因为pragma也是控制缓存的一个消息头属性
        return originResponse.newBuilder().removeHeader("pragma")
                .header("Cache-Control","max-age=60").build();
    }
}
```

> 应该可以通过判断请求连接动态配置缓存设置。

请求缓存设置：`CacheControl`。

```
//设置缓存时间为60秒
CacheControl cacheControl = new CacheControl.Builder()
        .maxAge(60, TimeUnit.SECONDS)
        .build();
Request request = new Request.Builder()
        .url("http://blog.csdn.net/briblue")
        .cacheControl(cacheControl)
        .build();
```
