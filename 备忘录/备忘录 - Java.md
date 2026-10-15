[JVM OOM引发的学习和思考](http://chanpin.family.baidu.com/article/170489)

ProtoBuf 在Android的使用与原理解析

ProGuard 最全混淆规则说明

常用注解
    @IntDef
    
匿名内部类访问的局部变量要用final修饰的原因

[静态内部类何时初始化](https://www.cnblogs.com/maohuidong/p/7843807.html)

[SimpleDateFormat与DateTimeFormatter](https://www.jianshu.com/p/b212afa16f1f)

[CopyOnWriteArrayList](https://juejin.cn/post/6844903576339218440)

[RandomAccessFile](https://www.jianshu.com/p/360e37539266)

[DownloadManager](https://developer.android.com/reference/android/app/DownloadManager)

### Https 验证
OkHttp 内置了 SSL 验证，验证 Android 内置的 ca 证书。
什么时候需要做自定义 SSL 验证呢？
自签名的证书，或者如未做 ca 签名的测试服务器域名

通过 HTTPS 和 SSL 确保安全
https://developer.android.com/training/articles/security-ssl?hl=zh-cn#java

Android App 安全的HTTPS 通信
http://pingguohe.net/2016/02/26/Android-App-secure-ssl.html

Android HTTPS自签名和CA证书验证（基于OkHttp）
https://icode.best/i/18576935189536

Okhttp 内部域名验证级别
SSLSocketFactory sf = new MySSLSocketFactory(trustStore);
sf.setHostnameVerifier(SSLSocketFactory.STRICT_HOSTNAME_VERIFIER);

什么是单向认证，什么是双向认证
根证书、中间证书

[ANR 日志文件获取](https://www.jianshu.com/p/641e1335a4c6)
生成zip文件：adb bugreport /
拉去到本地：adb pull /data/user_de/0/***.zip ./

[StringBuiler vs StringBuffer](https://blog.csdn.net/weixin_41101173/article/details/79677982)

递归堆栈溢出问题

HTTPS 证书验证


### 线程可见性问题

a/b两个函数，结果不同，初步判断可能是 while 循环的问题
```java
public class TestThread {
    static boolean stop = false;

    public static void main(String[] args) {
        Thread a = new Thread(()  -> {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            stop = true;
        });

        a.start();
        a();
    }

    private static void a() {
        while (!stop) {
            System.out.println("a");
        }
    }

    private static void b() {
        while (true) {
            if (stop) {
                break;
            }
        }
        System.out.println("foo end");
    }
}
```
