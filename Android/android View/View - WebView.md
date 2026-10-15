[TOC]
### 关联地址

1. [ Android-使用JsBridge来优化js与本地webview的交互](http://blog.csdn.net/jdsjlzx/article/details/52343818)
2. [Android中JS与Java的极简交互库－SimpleJavaJsBridge](http://android.jobbole.com/84930/)
3. [关于 Android WebView 的内存泄露问题](http://mp.weixin.qq.com/s?__biz=MzA4NDM2MjAwNw==&mid=2650576213&idx=1&sn=63fd4d779843953021ee232e78d59cc2&chksm=87e0632db097ea3b1f1e655d7a0e25839d5295b5b5d390e4b2b483e105bf1b7c76e892333b4c&mpshare=1&scene=1&srcid=1014zNZTM09UYkLpfkPHn0NP#rd)
4. [WebView详解与简单实现Android与H5互调](http://blog.csdn.net/hytfly/article/details/8552483#comments)

### WebView

微信，QQ空间等大量软件都内嵌了H5，不得不说是一种趋势。Android与H5互调可以让我们的实现混合开发，至于混合开发就是在一个App中内嵌一个轻量级的浏览器，一部分原生的功能改为Html 5来开发。 
优势：使用H5实现的功能能够在不升级App的情况下动态更新，而且可以在Android或iOS的App上同时运行，节约了成本，提高了开发效率。 
原理：其实就是Java代码和JavaScript之间的调用。

### WebView的使用

低版本和高版本的 Android 系统中 WebView 采用不同的内核， Android 4.4 之后直接使用了 Chrome 的内核。

#### 1. WebView常用方法

1. loadUrl

加载界面，其次还有LoadData和LoadDataWithBase方法

```
//加载assets目录下的test.html文件
webView.loadUrl("file:///android_asset/test.html");
//加载网络资源(注意要加上网络权限)
webView.loadUrl("http://blog.csdn.net");
```

setWebViewClient（如果用户设置了WebViewClient，则在点击新的链接以后就不会跳转到系统浏览器了，而是在本WebView中显示。注意：并不需要覆盖 shouldOverrideUrlLoading 方法，同样可以实现所有的链接都在 WebView 中打开。）

WebViewClient主要用来辅助WebView处理各种通知、请求等事件，通过setWebViewClient方法设置。以下是它的几种常见用法：

实现对网页中超链接的拦截(比如如果是极客导航的主页，则直接拦截转到百度主页)： 
当点击页面中的链接后，会在WebView加载URL前回调shouldOverrideUrlLoading(WebView view, String url)方法，一般点击一个链接此方法调用一次。

```
webView.setWebViewClient(new WebViewClient()
{
	@Override
	public boolean shouldOverrideUrlLoading(WebView view, String url) 
	{
	    if("http://www.jikedaohang.com/".equals(url))                   
	    {
	        view.loadUrl("https://www.baidu.com/");
	    }

		return true;
	}
});
```

关于shouldOverrideUrlLoading返回值的误区：网上很多解释是return true代表在本WebView中打开链接，return false代表调用系统浏览器打开链接。其实只要设置了WebViewClient，则就不会调用系统浏览器。 

那么shouldOverrideUrlLoading的返回值到底代表什么呢？return true，则在打开新的url时WebView就不会再加载这个url了，所有处理都需要在WebView中操作，包含加载；return false，则系统就认为上层没有做处理，接下来还是会继续加载这个url的；默认return false。具体的区别展示如下： 
加载百度主页，设置WebViewClient后，重写shouldOverrideUrlLoading(WebView view, String url)方法，第一张是返回false的截图（点击后正常跳转），第二章是返回true的截图（点击无反应，如果希望能够跳转，则需要我们自己进行处理）： 
![enter image description here](http://img.blog.csdn.net/20161026173528377)
![enter image description here](http://img.blog.csdn.net/20161026170817791)
还有一点需要注意的是，如果我们拦截了某个url，那么return false 和 return true区别不大，所以一般建议 return false。

加载网页时替换某个资源（比如在加载一个网页时，需要加载一个logo图片，而我们想要替换这个logo图片，用我们assets目录下的一张图片替代） 
我们知道我们在加载一个网页的同时也会加载js,css,图片等资源，所以会多次调用shouldInterceptRequest方法，我们可以在shouldInterceptRequest中进行图片替换。 
注意：shouldInterceptRequest有两个重载： 
①public WebResourceResponse shouldInterceptRequest (WebView view, String url) 【已过时】 
②public WebResourceResponse shouldInterceptRequest (WebView view, WebResourceRequest request) 
这两种方法主要是第二个参数的不同，WebResourceRequest 将能够获取更多的信息，提供了getUrl(),getMethod,getRequestHeaders等方法。这里主要是为了展示效果，使用了第一种回调方法。实现方法如下：

```
mWebView.setWebViewClient(new WebViewClient(){
            @Override
            public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
                WebResourceResponse response = null;
                if (url.contains("logo")) {
                    try {
                        InputStream logo = getAssets().open("logo.png");
                        response = new WebResourceResponse("image/png", "UTF-8", logo);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                return response;
            }
        });
```

设置开始加载网页、加载完成、加载错误时处理

```
webView.setWebViewClient(new WebViewClient() {    

    @Override  
    public void onPageStarted(WebView view, String url, Bitmap favicon) {  
        super.onPageStarted(view, url, favicon);  
        // 开始加载网页时处理 如：显示"加载提示" 的加载对话框  
        ...
    }  

    @Override  
    public void onPageFinished(WebView view, String url) {  
        super.onPageFinished(view, url);  
        // 网页加载完成时处理  如：让 加载对话框 消失  
        ...
    }  

    @Override  
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {  
        super.onReceivedError(view, errorCode, description, failingUrl);  
        // 加载网页失败时处理 如：提示失败，或显示新的界面
        ...
    }    
});  
```

处理https请求，为WebView处理ssl证书设置WebView默认是不处理https请求的，需要在WebViewClient子类中重写父类的onReceivedSslError函数

```
webView.setWebViewClient(new WebViewClient() {    

    @Override  
    public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {  
        handler.proceed();  // 接受信任所有网站的证书  
        // handler.cancel();   // 默认操作 不处理  
        // handler.handleMessage(null);  // 可做其他处理  
    }   
});   
```

2. setWebChromeClient

WebChromeClient主要用来辅助WebView处理Javascript的对话框、网站图标、网站标题以及网页加载进度等。通过WebView的setWebChromeClient()方法设置。

显示页面加载进度在WebChromeClient子类中重写父类的onProgressChanged函数，progress表示当前页面加载的进度，为1至100的整数

```
webView.setWebChromeClient(new WebChromeClient() {    

    public void onProgressChanged(WebView view, int progress) {    
        setTitle("页面加载中，请稍候..." + progress + "%");    
        setProgress(progress * 100);    

        if (progress == 100) {    
            //... 
        }    
    }    
});  
```

加快HTML网页加载完成速度（默认情况html代码下载到WebView后，webkit开始解析网页各个节点，发现有外部样式文件或者外部脚本文件时，会异步发起网络请求下载文件，但如果在这之前也有解析到image节点，那势必也会发起网络请求下载相应的图片。在网络情况较差的情况下，过多的网络请求就会造成带宽紧张，影响到css或js文件加载完成的时间，造成页面空白loading过久。解决的方法就是告诉WebView先不要自动加载图片，等页面finish后再发起图片加载。）

```
//1.首先在WebView初始化时添加如下代码
if(Build.VERSION.SDK_INT >= 19) 
{  
	/*对系统API在19以上的版本作了兼容。因为4.4以上系统在onPageFinished时再恢复图片加载时,如果存在多张图片引用的是相同的src时，会只有一个image标签得到加载，因而对于这样的系统我们就先直接加载。*/        
	webView.getSettings().setLoadsImagesAutomatically(true);  
} else {  
	webView.getSettings().setLoadsImagesAutomatically(false);  
}  

//2.在WebView的WebViewClient子类中重写onPageFinished()方法添加如下代码： 
@Override  
public void onPageFinished(WebView view, String url)
{  
    if(!webView.getSettings().getLoadsImagesAutomatically()) 
    {  
        webView.getSettings().setLoadsImagesAutomatically(true);  
    }  
}  
```

3. setDownloadListener

通常webview渲染的界面中含有可以下载文件的链接，点击该链接后，应该开始执行下载的操作并保存文件到本地中。

- 创建DownloadListener

```
class MyDownloadListenter implements DownloadListener
{
      @Override
      public void onDownloadStart(String url, String userAgent,String contentDisposition, String mimetype, long contentLength) 
      {
          //下载任务...，主要有两种方式
          //（1）自定义下载任务
          //（2）调用系统的download的模块
          Uri uri = Uri.parse(url);
          Intent intent = new Intent(Intent.ACTION_VIEW, uri);
          startActivity(intent);
      }
}
```

- 给webview加入监听

```
webview.setDownloadListener(new MyDownloadListenter());
```

4. goBack()

返回上一浏览页面，通过重写onKeyDown方法实现点击返回键返回上一浏览页面而非退出程序

```
public boolean onKeyDown(int keyCode, KeyEvent event) {  
//其中webView.canGoBack()在webView含有一个可后退的浏览记录时返回true

        if ((keyCode == KeyEvent.KEYCODE_BACK) && webView.canGoBack()) {       
            webView.goBack();       
            return true;       
        }       
        return super.onKeyDown(keyCode, event);       
    }
}
```

#### 2. WebSettings配置

获取WebSettings对象

```
WebSettings webSettings = webView.getSettings();
```

常用设置方法

```
1. 支持js
settings.setJavaScriptEnabled(true);

2. 设置缓存方式，主要有以下几种： 
- LOAD_CACHE_ONLY: 不使用网络，只读取本地缓存数据。 
- LOAD_DEFAULT: 根据cache-control决定是否从网络上取数据。 
- LOAD_CACHE_NORMAL: API level 17中已经废弃, 从API level 11开始作用同LOAD_DEFAULT模式。 
- LOAD_NO_CACHE: 不使用缓存，只从网络获取数据。 
- LOAD_CACHE_ELSE_NETWORK：只要本地有，无论是否过期，或者no-cache，都使用缓存中的数据。

settings.setCacheMode(WebSettings.LOAD_NO_CACHE);

3. 开启DOM storage API功能（HTML5 提供的一种标准的接口，主要将键值对存储在本地，在页面加载完毕后可以通过 JavaScript 来操作这些数据。）
settings.setDomStorageEnabled(true);

4. 设置数据库缓存路径
settings.setDatabasePath(cacheDirPath);

5. 设置Application Caches缓存目录
settings.setAppCachePath(cacheDirPath);

6. 设置默认编码
settings.setDefaultTextEncodingName(“utf-8”);

7. 将图片调整到适合webview的大小
settings.setUseWideViewPort(false);

8. 支持缩放
settings.setSupportZoom(true);

9. 支持内容重新布局
settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);

10. 多窗口
settings.supportMultipleWindows();

11. 设置可以访问文件
settings.setAllowFileAccess(true);

12. 当webview调用requestFocus时为webview设置节点
settings.setNeedInitialFocus(true);

13. 设置支持缩放
settings.setBuiltInZoomControls(true);

14. 支持通过JS打开新窗口
settings.setJavaScriptCanOpenWindowsAutomatically(true);

15. 缩放至屏幕的大小
settings.setLoadWithOverviewMode(true);

16. 支持自动加载图片
settings.setLoadsImagesAutomatically(true);
```

#### 3. WebViewClient 的回调方法列表

WebViewClient主要用来辅助WebView处理各种通知、请求等事件，通过setWebViewClient方法设置。

```
1. 更新历史记录
doUpdateVisitedHistory(WebView view, String url, boolean isReload)

2. 应用程序重新请求网页数据
onFormResubmission(WebView view, Message dontResend, Message resend)

3. 在加载页面资源时会调用，每一个资源（比如图片）的加载都会调用一次。
onLoadResource(WebView view, String url)

4. 开始载入页面调用，通常我们可以在这设定一个loading的页面，告诉用户程序在等待网络响应。
]
onPageStarted(WebView view, String url, Bitmap favicon)

5. 在页面加载结束时调用。同样道理，我们知道一个页面载入完成，于是我们可以关闭loading 条，切换程序动作。
onPageFinished(WebView view, String url)

6. 报告错误信息
onReceivedError(WebView view, int errorCode, String description, String failingUrl)

7. 获取返回信息授权请求
onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host,String realm)

8. 重写此方法可以让webview处理https请求。
onReceivedSslError(WebView view, SslErrorHandler handler, SslError error)

9. WebView发生改变时调用
onScaleChanged(WebView view, float oldScale, float newScale)

10. Key事件未被加载时调用
onUnhandledKeyEvent(WebView view, KeyEvent event)

11. 重写此方法才能够处理在浏览器中的按键事件。
shouldOverrideKeyEvent(WebView view, KeyEvent event)

12. 在网页跳转时调用，这个函数我们可以做很多操作，比如我们读取到某些特殊的URL，于是就可以不打开地址，取消这个操作，进行预先定义的其他操作，这对一个程序是非常必要的。
shouldOverrideUrlLoading(WebView view, String url)

13. 在加载某个网页的资源的时候多次调用（已过时）
shouldInterceptRequest(WebView view, String url)

14. 在加载某个网页的资源的时候多次调用
shouldInterceptRequest(WebView view, WebResourceRequest request)
```

注意：
shouldOverrideUrlLoading在网页跳转的时候调用，且一般每跳转一次只调用一次。 
shouldInterceptRequest只要是网页加载的过程中均会调用，资源加载的时候都会回调该方法，会多次调用。

### Java和JavaScript互调

为方便展示，使用addJavascriptInterface方式实现与本地js交互（存在漏洞）。也可通过其他方式实现，比如拦截ur进行参数解析l等。

1. Java调JS

首先是JS的一段代码：

```
function javaCallJs(arg){
         document.getElementById("content").innerHTML =
             ("欢迎："+arg );
    }
```

然后是在java中调用JS中的方法

```
webView.loadUrl("javascript:javaCallJs("+"'"+name+"'"+")");
```

以上代码就是调用了JS中一个叫javaCallJs(arg)的方法，并传入了一个name参数。（具体效果下面有展示）

2. JS调java

配置Javascript接口

```
webView.addJavascriptInterface(new JSInterface (),"Android");
```

实现Javascript接口类

```
class JSInterface {
    @JavascriptInterface
     public void showToast(String arg){
                   Toast.makeText(MainActivity.this,arg,Toast.LENGTH_SHORT).show();
     }
}
```

JS中调用java代码

```
<input type="button" value="点击Android被调用" onclick="window.Android.showToast('JS中传来的参数')"/>
```

window.Android.showToast(‘JS中传来的参数’)”中的”Android”即addJavascriptInterface（）中指定的，并且JS向java传递了参数，类型为String。而showToast(String arg)会以Toast的形式弹出此参数。

参考链接：安卓webview的一些坑

1. webView.addJavascriptInterface()方法在API 17之前有一些漏洞（有兴趣的可以参考本篇文章，WebView 远程代码执行漏洞浅析），所以在API 17以后，需要在JavaScript接口类的方法加上@JavascriptInterface注解。

2. 仔细看的话你会发现我们上面的WebView对象并不是直接写在布局文件中的，而是通过一个LinearLayout容器，使用addview(webview)动态向里面添加的。另外需要注意创建webview需要使用applicationContext而不是activity的context，销毁时不再占有activity对象，最后离开的时候需要及时销毁webview，onDestory()中应该先从LinearLayout中remove掉webview,再调用webview.removeAllViews();webview.destory();

3. 如果想要webView在产生OOM的时候不影响主进程，可以另开一个进程，在androidmanifest.xml的activity标签里加上Android:process属性就可以了。

4. 在activity被杀死之后，依然保持webView的状态，方便用户下次打开的时候可以回到之前的状态。webview支持saveState(bundle)和restoreState(bundle)方法。

保存状态

```
@Override  
protected void onSaveInstanceState(Bundle outState) {  
    super.onSaveInstanceState(outState);  
    wv.saveState(outState);  
    Log.e(TAG, "save state...");  
}  
```

恢复状态（在activity的onCreate(bundle savedInstanceState)里）

```
if(null!=savedInstanceState){  
    wv.restoreState(savedInstanceState);  
    Log.i(TAG, "restore state");  
}else{  
    wv.loadUrl("http://3g.cn");  
}  
```

其他一些常见问题：

1. WebViewClient.onPageFinished()。 
你永远无法确定当WebView调用这个方法的时候，网页内容是否真的加载完毕了。当前正在加载的网页产生跳转的时候这个方法可能会被多次调用，StackOverflow上有比较具体的解释（How to listen for a Webview finishing loading a URL in Android?）， 但其中列举的解决方法并不完美。所以当你的WebView需要加载各种各样的网页并且需要在页面加载完成时采取一些操作的话，可能WebChromeClient.onProgressChanged()比WebViewClient.onPageFinished()都要靠谱一些。

2. WebView后台耗电问题。 
当你的程序调用了WebView加载网页，WebView会自己开启一些线程（？），如果你没有正确地将WebView销毁的话，这些残余的线程（？）会一直在后台运行，由此导致你的应用程序耗电量居高不下。对此我采用的处理方式比较偷懒，简单又粗暴（不建议），即在Activity.onDestroy()中直接调用System.exit(0)，使得应用程序完全被移出虚拟机，这样就不会有任何问题了。

3. 切换WebView闪屏问题。 
如果你需要在同一个ViewGroup中来回切换不同的WebView（包含了不同的网页内容）的话，你就会发现闪屏是不可避免的。这应该是Android硬件加速的Bug，如果关闭硬件加速这种情况会好很多，但无法获得很好的浏览体验，你会感觉网页滑动的时候一卡一卡的，不跟手。

4. 在某些手机上，Webview有视频时，activity销毁后，视频资源没有被销毁，甚至还能听到在后台播放。即便是像刚才那样各种销毁webview也无济于事，解决办法：在onDestory之前修改url为空地址。

5. WebView硬件加速导致页面渲染闪烁问题 
关于Android硬件加速 开始于Android 3.0 (API level 11),开启硬件加速后，WebView渲染页面更加快速，拖动也更加顺滑。但有个副作用就是容易会出现页面加载白块同时界面闪烁现象。解决这个问题的方法是设置WebView暂时关闭硬件加速 代码如下： 
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) { 
webview.setLayerType(View.LAYER_TYPE_SOFTWARE, null); 
}

## #WebView JS注入
> Android中向webview注入js代码可以通过webview.loadUrl("javascript:xxx")来实现，然后就会执行javascript后面的代码。

#### 注入HTML代码
```
override fun onPageFinished(view: WebView, url: String?) {
	view.loadUrl("javascript:" + getInputJsCode())
}
```

```
fun getInputJsCode(): String {
        val sb = StringBuilder()
        sb.append("function insertNewHtml(){")
        sb.append("var contentNode = document.getElementsByTagName('body')[0];")
        sb.append("var newNode = document.createElement('div');")
        sb.append("newNode.innerHTML = \"<img src=\\\"https://goss.veer.com/creative/vcg/veer/800water/veer-150912567.jpg\\\" style=\\\"width:100%;height: 78.66666666666667px;background: #0000FF;margin: 5px 0;\\\" id=\\\"by2\\\" onclick='window.open(\\\"http://www.baidu.com\\\")'>\";")
        sb.append("contentNode.appendChild(newNode);")
        sb.append("};")
        sb.append("insertNewHtml();")

        return sb.toString()
    }
```

#### 注入JS
> 在方法中为加入script标签添加onload事件，确保该script已加载完成。

```
override fun onPageFinished(view: WebView, url: String?) {
	view.loadUrl("javascript:" + getInputJsCode())
}
```

```
fun getInputJsCode(): String {
        val sb = StringBuilder()
        sb.append("var newscript = document.createElement(\"script\");")
        sb.append("newscript.src=\"http://www.123.456/789.js\";")
        sb.append("newscript.onload=function(){xxx();};")
        sb.append("document.body.appendChild(newscript);")

        return sb.toString()
    }
```

### WebView 删除缓存

在项目中如果使用到 WebView 控件,当加载 html 页面时,会在/data/data/包名目录下生成 database 与 cache 两个文件夹（我的手机没有root，就不截图了）。
请求的 url 记录是保存在 WebViewCache.db,而 url 的内容是保存在 WebViewCache 文件夹下. 大家可以自己动手试一下,定义一个html文件,在里面显示一张图片,用WebView加载出来,然后再试着从缓存里把这张图片读取出来并显示 .

其实已经知道缓存保存的位置了，那么删除就很简单了，获取到这个缓存，然后删掉他就好了。
//删除保存于手机上的缓存

```
	private int clearCacheFolder(File dir, long numDays)
    {
        int deletedFiles = 0;
        if (dir != null && dir.isDirectory())
        {
            try
            {
                for (File child : dir.listFiles())
                {
                    if (child.isDirectory())
                    {
                        deletedFiles += clearCacheFolder(child, numDays);
                    }
                    if (child.lastModified() < numDays)
                    {
                        if (child.delete())
                        {
                            deletedFiles++;
                        }
                    }
                }
            } catch (Exception e)
            {
                e.printStackTrace();
            }
        }
        return deletedFiles;
    }
```

是否启用缓存功能也是可以控制的

```
	//优先使用缓存: 
	WebView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK); 
	//不使用缓存: 
	WebView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
```

在退出应用的时候加上如下代码，可以完整的清空缓存

```
	File file = CacheManager.getCacheFileBaseDir();
	if (file != null && file.exists() && file.isDirectory()) 
	{
		for (File item : file.listFiles()) 
		{
			item.delete();
		}
		file.delete();
	}
	context.deleteDatabase("WebView.db"); 
	context.deleteDatabase("WebViewCache.db");
```

### WebView 处理 404 错误

显示网页还会遇到一个问题，就是网页有可能会找不到，WebView当然也是可以处理的（代码如果全部贴出来实在太多了，这里就只贴重要部分了）

```
public class WebView_404 extends Activity
    {
        private Handler handler = new Handler()
        {
            public void handleMessage(Message msg)
            {
                if (msg.what == 404)
                {
                    //主页不存在, 载入本地 assets 文件夹下面的错误提示页面 404.html
                    web.loadUrl("file:///android_asset/404.html");
                } else
                {
                    web.loadUrl(HOMEPAGE);
                }
            }
        };

        @Override
        protected void onCreate(Bundle savedInstanceState)
        {
            web.setWebViewClient(new WebViewClient()
            {
                public boolean shouldOverrideUrl(WebView view, String url)
                {
                    if (url.startsWith("http://") && getRespStatus(url) == 404)
                    {
                        view.stopLoading();
                        //载入本地 assets 文件夹下面的错误提示页面 404.html
                        view.loadUrl("file:///android_asset/404.html");
                    } else
                    {
                        view.loadUrl(url);
                    }
                    return true;
                }
            });
            new Thread(new Runnable()
            {
                public void run()
                {
                    Message msg = new Message();
                    //此处判断主页是否存在,因为主页是通过 loadUrl 加载的,
                    //此时不会执行 shouldOverrideUrlLoading 进行页面是否存在的判断
                    // 进入主页后,点主页里面的链接,链接到其他页面就一定会执行shouldOverrideUrlLoading 方法了
                    if (getRespStatus(HOMEPAGE) == 404)
                    {
                        msg.what = 404;
                    }
                    handler.sendMessage(msg);
                }

            }).start();
        }
```

### 判断 WebView 是否已经滚动到页面底端
在View中有一个getScrollY()方法，可以返回当前可见区域的顶端距整个页面顶端的距离,也就是当前内容滚动的距离。
还有getHeight()或者 getBottom()方法都返回当前 View 这个容器的高度
在ViewView中还有getContentHeight() 方法可以返回整个 html 页面的高度,但并不等同于当前整个页面的高度 ,因为 WebView 有缩放功能。你可以通过如下代码来启动或关闭webview的缩放功能。

```
mWebView.getSettings().setSupportZoom(true);
mWebView.getSettings().setBuiltInZoomControls(true);
```

所以当前整个页面的高度实际上应该是原始 html 的高度再乘上缩放比例. 因此,更正后的结果 ,准确的判断方法应该是:

```
	// 如果已经处于底端
	if(WebView.getContentHeight*WebView.getScale() -
	(webview.getHeight()+WebView.getScrollY()))
	{ 
	  //XXX
	}
```

### WebView获取服务器中的 session 问题
接下来我们讲如下两个问题：
1. Android 中的 WebView 如何获取服务器页面的 jsessionid 的值
2. Android 的 WebView 又是如何把得到的 jsessionid 的值在 set 到服务器中,一致达到他们在同一个 jsessionid 的回话中.
其实非常非常简单，只不过是几个方法罢了:

```
CookieManager cm = CookieManager.getInstance(); 
cm.removeAllCookie();
cm.getCookie(url);
cm.setCookie(url, cookie);
```

另外还有个 CookieSyncManager,也许你会在一些旧的项目中看到它。从名字来理解，它实际上应该是一个异步缓存器。不过我们看到这个方法已经被标记为过时了，查看源码可以看到过时原因是现在WebView已经是自动的异步缓存了，所以这个类已经没有存在的意义了。 CookieSyncManager

### WebView清除本地cookies
首先，要清除肯定要会添加，这里给大家提供一个工具方法：

```
	/***
     * 如果用户已经登录，则同步本地的cookie到webview中
     */
    public void synCookies() 
    {
        if (!CacheUtils.isLogin(this)) 
        {
	        return;
        }
        CookieSyncManager.createInstance(this);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.removeSessionCookie();//移除
        String cookies = PreferenceHelper.readString(this, AppConfig.COOKIE_KEY, AppConfig.COOKIE_KEY);
        cookieManager.setCookie(url, cookies);
        CookieSyncManager.getInstance().sync();
    }
```

在使用网页版淘宝或百度登录时,WebView会自动登录上次的帐号!(因为WebView 记录了帐号和密码的cookies) 所以,需要清除 SessionCookie也是有必要的。
那么CookieManager同样也为我们提供了清除cookie的方法 

```
CookieManager.getInstance().removeSessionCookie();
```

这里顺便说一下WebView本身也是会记录html缓存的，上一篇博客中我讲了一种通过文件操作去清理缓存的方法，后来我又发现，其实webview本身就提供了清理缓存的方法，其中参数true是指是否包括磁盘文件也一并清除，传true就和我们昨天的讲的效果是一样的了：

```
webview.clearCache(true);
webview.clearHistory();
```
