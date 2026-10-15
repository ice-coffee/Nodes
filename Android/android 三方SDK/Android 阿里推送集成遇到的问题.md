### Android 阿里推送集成遇到的问题

@(android 工具)

#### 1. 设备收不到推送如何排查
[Android推送失败排查步骤](https://help.aliyun.com/knowledge_detail/40002.html?spm=a2c4g.11186623.2.10.47a55e9372ED14)
如果是vivo、oppo设备，应用的通知是默认关闭的，这种情况有两种解决方案：
- 提示用户手动打开
- 集成vivo、oppo推送然后联系客服添加白名单（没试过）

#### 2. Android 8.0 以上设备收不到通知
[移动推送Android SDK: Android 8.0以上设备通知接收不到？](https://help.aliyun.com/knowledge_detail/67398.html)

1. 问题
在Andorid 8.0以上的设备集成推送SDK后，推送接收不到，日志显示通知已经从服务端发送到客户端，但是并未创建通知，这是怎么回事？应该如何解决？

2. 问题原因
自8.0(API Level 26)起，Android 推出了NotificationChannel机制，旨在对通知进行分类管理。如果用户App的targetSdkVersion大于等于26，且并未设置NotificaitonChannel，创建的通知是不会弹出的。

3. 解决方案
在注册阿里云推送之前创建通知渠道，保存渠道ID，服务端调用时指定通知渠道ID
    
```
pushRequest.setAndroidNotificationChannel("1"); 
```

#### 3. Android 自定义推送样式
> 建议使用推送的时候使用消息推送，本地代码发送通知，可操作性更强

自定义通知有两种方式：
- 使用自定义通知样式，自定义通知栏布局。具体使用方式参考:[自定义样式通知](https://help.aliyun.com/document_detail/30066.html#h3-3-5-advancedcustompushnotification-api)。注：自定义样式通知只支持标准视图，即通知栏高度不可变。如需改变通知栏高度请参考方式二，采用扩展视图实现。
- 后台推送消息，在onMessage回调中自行创建通知。

扩展：
[Android 自定义Notification颜色适配问题](https://blog.csdn.net/superxlcr/article/details/79253088)
[正确地设置安卓通知栏图标尺寸](https://blog.csdn.net/icyfox_bupt/article/details/26149145)
[Android通知栏介绍与适配总结](https://iluhcm.com/2017/03/12/experience-of-adapting-to-android-notifications/)
