### Android 微信支付

@(android 三方插件)
> `特别注意`：友盟+中的微信分享jar包：`SocialSDK_WeiXin_1.jar`,`SocialSDK_WeiXin_2.jar`和从微信开放平台下载的jar包：`libammsdk.jar`有冲突，因为他们都包含有`微信登录/分享`的功能。友盟自3.3.8版本已经兼容微信支付sdk，SocialSDK_WeiXin_X.jar里包含了微信支付需要的类可以直接使用支付的api

> 提前准备一张28*28像素和一张108*108像素的logo还有应用的MD5签名�

[微信开放平台](https://open.weixin.qq.com/)
[微信SDK下载地址](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=11_1)
[集成步骤](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=8_5)

#### 1. 申请开发者资质
![Alt text](<../../attachment/:111.png>)

#### 2. 创建应用, 获得APP_ID/APP_KEY 
![Alt text](<../../attachment/:__-D_8RC-K48WTX9RB9B.png>)

#### 3. 申请支付能力 
![Alt text](<../../attachment/:YGHO1WC4@WSXU5PL--IVM.jpg>)


#### 4. 代码集成微信支付 
支付流程图 
![Alt text](<../../attachment/:chapter8_3_1.png>)

#### 5. 微信统一下单 
> 注意:
1. 统一下单的url地址和需要传递的参数可以在微信支付开发文档中找到
2. 微信的统一下单接口接收的参数是一段xml代码
3. 把所有需要传递的参数组合成一段xml代码，`要有换行符`，不然微信服务端无法识别

```
	StringBuilder xml = new StringBuilder();
        xml.append("<xml>"+"\n");
        xml.append("<appid>"+map.get(WXPayPresenter.APPID)+"</appid>"+"\n");
        xml.append("<mch_id>"+map.get(WXPayPresenter.MCH_ID)+"</mch_id>"+"\n");
        xml.append("<nonce_str>"+map.get(WXPayPresenter.NONCE_STR)+"</nonce_str>"+"\n");
        xml.append("<body>"+map.get(WXPayPresenter.BODY)+"</body>"+"\n");
        xml.append("<out_trade_no>"+map.get(WXPayPresenter.OUT_TRADE_NO)+"</out_trade_no>"+"\n");
        xml.append("<total_fee>"+map.get(WXPayPresenter.TOTAL_FEE)+"</total_fee>"+"\n");
        xml.append("<spbill_create_ip>"+map.get(WXPayPresenter.SPBILL_CREATE_IP)+"</spbill_create_ip>"+"\n");
        xml.append("<notify_url>"+map.get(WXPayPresenter.NOTIFY_URL)+"</notify_url>"+"\n");
        xml.append("<trade_type>"+map.get(WXPayPresenter.TRADE_TYPE)+"</trade_type>"+"\n");
        xml.append("<sign>"+map.get(WXPayPresenter.SIGNN)+"</sign>"+"\n");
        xml.append("</xml>");
```

3. 在统一下单的参数中生成sign签名是最麻烦的，通过以下代码可以实现

```
/**
     * 微信支付签名算法sign
     *
     * @param parameters
     * @return
     */
    @SuppressWarnings("unchecked")
    public static String createSign(SortedMap<String, String> parameters)
    {
        StringBuffer sb = new StringBuffer();
        Set es = parameters.entrySet();//所有参与传参的参数按照accsii排序（升序）
        Iterator it = es.iterator();
        while (it.hasNext())
        {
            Map.Entry entry = (Map.Entry) it.next();
            String k = (String) entry.getKey();
            Object v = entry.getValue();
            if (null != v && !"".equals(v) && !"sign".equals(k) && !"key".equals(k))
            {
                sb.append(k + "=" + v + "&");
            }
        }
        sb.append("key=" + KEY);
        String sign = MD5Util.MD5Encode(sb.toString(), "UTF-8").toUpperCase();
        return sign;
    }
```

4. 在统一下单的参数中获取用户端实际IP也麻烦，通过以下代码可以实现

```
/**
     * 获取wifi状态下的ip地址
     * @return
     */
    private String getWifiIpAddress()
    {
        //获取wifi服务
        WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        //判断wifi是否开启
        if (!wifiManager.isWifiEnabled())
        {
            wifiManager.setWifiEnabled(true);
        }
        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        int ipAddress = wifiInfo.getIpAddress();
        return intToIp(ipAddress);
    }

    private String intToIp(int i)
    {

        return (i & 0xFF) + "." +
                ((i >> 8) & 0xFF) + "." +
                ((i >> 16) & 0xFF) + "." +
                (i >> 24 & 0xFF);
    }

    /**
     * 获取移动网络状态下的IP地址
     * @return
     */
    public String getLocalIpAddress()
    {
        try
        {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); )
            {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); )
                {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress())
                    {
                        return inetAddress.getHostAddress().toString();
                    }
                }
            }
        } catch (SocketException ex)
        {
            Log.e("IpAddress", ex.toString());
        }
        return null;
    }
```

5. 我是通过使用HttpUrlConnection来传递xml数据的

```
URL url = new URL(params[0]);

byte[] xmlbyte = params[1].getBytes("UTF-8");

HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setConnectTimeout(5000);
conn.setDoOutput(true);// 允许输出
conn.setDoInput(true);
conn.setUseCaches(false);// 不使用缓存
conn.setRequestMethod("POST");
conn.setRequestProperty("Connection", "Keep-Alive");// 维持长连接
conn.setRequestProperty("Charset", "UTF-8");
conn.setRequestProperty("Content-Length", String.valueOf(xmlbyte.length));
conn.setRequestProperty("Content-Type", "text/xml; charset=UTF-8");
conn.setRequestProperty("X-ClientType", "2");//发送自定义的头信息

conn.getOutputStream().write(xmlbyte);
conn.getOutputStream().flush();
conn.getOutputStream().close();


if (conn.getResponseCode() != 200)
{
	loadListener.onError("http error");
}
else
{
	InputStream is = conn.getInputStream();// 获取返回数据
}
```

6. 统一下单接口调取成功后会又会返回一段xml代码，这时候就需要解析获取需要的信息了
> 这里需要注意一下，返回值中的sign不是用于支付接口的sign

```
		Map<String, String> payParams = new HashMap<>();
		//取得DocumentBuilderFactory实例
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();  
        //从factory获取DocumentBuilder实例
        DocumentBuilder builder = factory.newDocumentBuilder(); 
        //解析输入流 得到Document实例
        Document doc = builder.parse(is);   
        NodeList properties = doc.getChildNodes();
        for (int i = 0; i < properties.getLength(); i++)
        {
            Node property = properties.item(i);

            NodeList childNodes = property.getChildNodes();

            for (int j = 0; j < childNodes.getLength(); j++)
            {

                Node node = childNodes.item(j);
                String nodeName = node.getNodeName();
                if (nodeName.equals("return_code"))
                {
                    payParams.put("return_code", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("return_msg"))
                {
                    payParams.put("return_msg", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("appid"))
                {
                    payParams.put("appid", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("mch_id"))
                {
                    payParams.put("mch_id", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("nonce_str"))
                {
                    payParams.put("nonce_str", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("sign"))
                {
                    payParams.put("sign", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("result_code"))
                {
                    payParams.put("result_code", node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("prepay_id"))
                {
                    payParams.put(WXPayPresenter.PAY_PREPAY_ID, node.getFirstChild().getNodeValue());
                } else if (nodeName.equals("trade_type"))
                {
                    payParams.put("trade_type", node.getFirstChild().getNodeValue());
                }
            }
        }
```

#### 6. 微信支付代码： 
1. 客户端代码得到用户购买的商品信息，将之传给自己公司app服务器，参数包含但不限于以下：

    params.put("appid", appID);// 微信appid，选择性上传，服务器写死亦可
	params.put("money", money);// 支付金额，单位：分
	params.put("name", goodsName);// 商品名称
	params.put("currencytype", "CNY");// 支付币种，只能填CNY，代表人民币

备注1：以上是参数字段是我们公司服务器定义，给服务器用以获取预支付订单号prePayId用。 
备注2：详细字段请参考：https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=9_1 
2. app服务器调用微信“统一下单”接口，得到prePayId订单号并返回prePayId给手机客户端； 
3. 手机客户端使用prePayId及商品信息调起微信客户端进行支付； 
4. 用户操作：输入密码进行支付；返回键取消支付；网络无连接支付失败等； 
5. 微信客户端回调支付结果给咱们的APP客户端； 
6. 微信服务器异步通知咱们公司app服务器支付结果（服务器的工作，与客户端无关）

微信支付代码：

```
IWXAPI api = WXAPIFactory.createWXAPI(context, IConstants.WX_APP_ID);
//将应用的appid注册到微信
api.registerApp(IConstants.WX_APP_ID);
PayReq req = new PayReq();
//应用ID
req.appId			= ""
//商户号
req.partnerId		= "";
//预支付交易回话ID（这个是通过调用统一下单接口获得的）
req.prepayId		= "";
//扩展字段（暂填写固定值"Sign=WXPay")
req.packageValue	= "Sign=WXPay";
//随机字符串
req.nonceStr		= "";
//时间戳
req.timeStamp		= "";
//签名
req.sign			= "";

// 在支付之前，如果应用没有注册到微信，应该先调用IWXMsg.registerApp将应用注册到微信
api.sendReq(req);
```

在app包下新建wxapi包，比如app包名为com.xiongit.app，那个新建的包路径为com.xiongit.app.wxapi，该包下新建WXPayEntryActivity，继承自任意Activity。该Activity用以接收支付结果回调,清单声明此Activity的格式为
> 特别注意：wxapi文件夹是放在app包名下的文件夹，这样WXPayEntryActivity才会被回调
> WXPayEntryActivity的代码示例可以查看微信支付提供的demo

    <activity
       android:name=".wxapi.WXPayEntryActivity"
       android:exported="true"
       android:launchMode="singleTop"/>

回调中errCode值列表：
`0` : 支付成功 
`-1` : 发生错误 可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。 
`-2` : 用户取消 发生场景：用户不支付了，点击取消，返回APP。
清单menifest申明所需权限

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

> 每次操作调用接口时都需要生成sign，非常建议使用微信支付提供的签名验证工具
