### Android 支付宝支付

@(android 三方插件)

> 在使用个人账户进行开发的时候, 提交的营业执照资料必须和账户实名认证信息一致不然, 签约服务的时候会被驳回
> 需提前准备一张应用Logo和应用签名在应用添加时使用
![Alt text](<../../attachment/:LCE41%60NGQYZE-4R67VJM9.png>)


#### 1. 商户签约审核

[签约地址](b.alipay.com)

#### 2. 商户密钥管理
1. [RSA私钥及公钥生成](https://doc.open.alipay.com/doc2/detail.htm?treeId=58&articleId=103242&docType=1)
2. [上传RSA公钥](https://doc.open.alipay.com/doc2/detail.htm?treeId=58&articleId=103578&docType=1)

获取商户的PID, 以及pkcs8格式的商户私钥(RSA_PRIVATE)
#### 代码接入
[代码接入流程](https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7629140.0.0.01urgQ&treeId=59&articleId=103681&docType=1)
1. 导入开发包

2. 修改Manifest并声明权限

```
<activity
            android:name="com.alipay.sdk.app.H5PayActivity"
            android:configChanges="orientation|keyboardHidden|navigation"
            android:exported="false"
            android:screenOrientation="behind" >
</activity>
<activity
            android:name="com.alipay.sdk.auth.AuthActivity"
            android:configChanges="orientation|keyboardHidden|navigation"
            android:exported="false"
            android:screenOrientation="behind" >
 </activity>
```

```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

3. 添加混淆规则

```
-libraryjars libs/alipaySDK-20150602.jar
 
-keep class com.alipay.android.app.IAlixPay{*;}
-keep class com.alipay.android.app.IAlixPay$Stub{*;}
-keep class com.alipay.android.app.IRemoteServiceCallback{*;}
-keep class com.alipay.android.app.IRemoteServiceCallback$Stub{*;}
-keep class com.alipay.sdk.app.PayTask{ public *;}
-keep class com.alipay.sdk.app.AuthTask{ public *;}
```

4. 订单数据生成
> 这个就让服务端的小盆友来帮忙吧!

5. 支付接口调用

```
		final String orderInfo = info;   // 订单信息
 
        Runnable payRunnable = new Runnable() 
        {
            @Override
            public void run() 
            {
                PayTask alipay = new PayTask(DemoActivity.this);
                String result = alipay.pay(orderInfo,true);
 
                Message msg = new Message();
                msg.what = SDK_PAY_FLAG;
                msg.obj = result;
                mHandler.sendMessage(msg);
            }
        };
        // 必须异步调用
        Thread payThread = new Thread(payRunnable);
        payThread.start();
```

6. 支付结果获取和处理

```
private Handler mHandler = new Handler() 
{
    public void handleMessage(Message msg) 
    {
        Result result = new Result((String) msg.obj);
        Toast.makeText(DemoActivity.this, result.getResult(),       Toast.LENGTH_LONG).show();
    };
};
```
