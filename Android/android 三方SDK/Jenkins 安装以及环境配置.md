## Jenkins 安装以及环境配置

@(android 三方插件)


[TOC]

### 功能目标


### 准备
- [Jenkins](https://jenkins.io/)
- [tomact](http://tomcat.apache.org/download-90.cgi)

### 安装
如果成功共安装`Jenkins`和`Tomcat`之后, 在Tomact的`webapps`目录下新建一个Jenkins目录, 再把安装好的Jenkins目录打开找到`war`目录并拷贝目录下全部的文件到webapps下新建的Jenkins目录中. 这样就可以通过`http://localhost:8080/jenkins`进入引导页了.

首次进入Jenkins时会在本地生成一个密码, 并让你输入, 密码的地址页面中有显示, 可点开查看, 也可以通过命令查看

```
type 'initialAdminPassword文件路径'
```

![Alt text](<../../attachment/:999.png>)

点击继续, 进入插件安装界面, 选择左侧`Install suggested plugins`

![enter image description here](http://images2015.cnblogs.com/blog/1108350/201703/1108350-20170308163638063-2051219571.png)

插件	安装完成之后, 点击继续, 创建用户

![enter image description here](http://images2015.cnblogs.com/blog/1108350/201703/1108350-20170308163646922-1319814609.png)

之后就可以使用Jenkins了.

![enter image description here](http://images2015.cnblogs.com/blog/1108350/201703/1108350-20170308163656609-1844646058.png)

### Jenkins插件准备
> 系统管理 -- 管理插件, 选择需要安装的插件进行安装, 需要安装的插件如下:

jenkins插件下载地址
[地址1](http://mirror.xmission.com/jenkins/plugins/)
[地址2](http://updates.jenkins-ci.org/download/plugins/)

- Branch API Plugin
- build timeout plugin
- build-name-setter
- Credentials Binding Plugin
- description setter plugin
- Dynamic Parameter Plug-in
- Environment Injector Plugin
- fir-plugin（可选）
- Git plugin（可选）
- GIT server Plugin(可选)
- Gradle Plugin
- Pipeline: Basic Steps
- Pipeline: Build Step
- Pipeline: Input Step
- Pipeline: Nodes and Processes
- Pipeline: Stage Step
- Post-Build Script Plug-in
- SSH Slaves plugin
- Subversion Release Manager plugin(可选)
- Timestamper
- Workspace Cleanup Plugin
- Subversion Plug-in(可选)

可使用`过滤`功能查看插件是否安装

![Alt text](./粘贴图片.png)

如果`可选插件`中不存在某个插件, 可下载后使用`高级`功能插入提交.

![Alt text](./粘贴图片1.png)

### 全局配置
> 参数配置完成后要点击页面底部的`Save`和`Apply`按钮进行保存
> AndroidSdk: 系统设置 -- 系统设置

![Alt text](<../../attachment/:environment.png>)

> JDK/Gradle: 系统设置 -- Global Tool Configuration

![Alt text](<../../attachment/:JDK.png>)

![Alt text](<../../attachment/:Gradle.png>)

### 创建项目
在主页面点击`新建`, 选择`构建一个自由风格的软件项目`

![Alt text](<../../attachment/:xinjian.png>)

点击`OK`后会进入参数的配置页面

#### 参数化构建过程
> 选中`参数化构建过程`, 点击`添加参数`
> `NAME`字段可随意添加, 但需要与`gradle.properties`中的配置一致
> 注意: 添加这些参数的主要目的是为了匹配新的打包的apk文件.

![Alt text](<../../attachment/:BUILD_TIME.png>)
![Alt text](<../../attachment/:buildtype.png>)
![Alt text](<../../attachment/:IS_JENKINS.png>)
![Alt text](<../../attachment/:LABEL.png>)
![Alt text](<../../attachment/:PRODUCT_FLAVOR.png>)
![Alt text](<../../attachment/:VERSION_NAME.png>)

#### 源码管理
> Git用户可参照http://birdinroom.blog.51cto.com/7740375/1404930 上面的配置来拉取不同的版本。

![Alt text](<../../attachment/:svn.png>)

#### 构建环境
> `Set Build Name` -- 动态生成每次显示在构建页上的名称方便查看

```
#${BUILD_NUMBER}_${LABEL}_${ENVIRONMENT}_v-${VERSION_NAME}
```

![Alt text](<../../attachment/:setbuildname.png>)

#### 构建
> 点击`增加构建步骤` -- `Invoke Gradle script`,  添加需要执行的Gradle命令

```
clean 
assemble${PRODUCT_FLAVOR}${BUILD_TYPE}
```

- `clean` : 清除build文件夹
- `assemble${PRODUCT_FLAVOR}${BUILD_TYPE}` :  构建指定的包

![Alt text](<../../attachment/:ivokegradlescript.png>)

> 注意: 必须勾选上`Pass job parameters as gradle properties(或Pass all job parameters as Project properties)` , 不然之前配置的参数无法传递给项目中的 gradle.properties.

```
curl -F "file=@D:\Java\apk\v%VERSION_CODE%-%PRODUCT_FLAVOR%-%BUILD_TIME%-%ENVIRONMENT%.apk" -F "uKey=8ef4179e300b3525d9da95c7b27d513f" -F "_api_key=59fc4f6ec0701a8aa2ff98a8e3d2cc9e" https://qiniu-storage.pgyer.com/apiv1/app/upload
```

![Alt text](<../../attachment/:batchcommand.png>)


#### 构建后操作
> 要生成下载链接和二维码有两种方式:
> - 配合[蒲公英](https://www.pgyer.com/doc/view/jenkins)
> - [Android-解放双手告别测试-使用Jenkins自动化打包
](http://www.jianshu.com/p/915c1ae69144)

```
"appKey":"（.*）","userKey"
<img src="\2"/><a href="https://www.pgyer.com/\1" style="font-size:12px">下载实创工程v-${VERSION_NAME}-${ENVIRONMENT}-${LABEL}</a>
```

![Alt text](<../../attachment/:setbuilddescription.png>)

### 开始
选中构建项目 -- `Build with Parameters`
![Alt text](<../../attachment/:pro_control.png>)

配置参数, 点击开始构建

![Alt text](<../../attachment/:pro_config.png>)

若构建成功, 在`Console Output`中,会出现如下json串

```
{"code":0,"message":"","data":{"appKey":"e8ab7007a0040385d08c4e4f1f6004a0","userKey":"8ef4179e300b3525d9da95c7b27d513f","appType":"2","appIsLastest":"1","appFileSize":"1445534","appName":"Jenkins","appVersion":"1.0.1","appVersionNo":"101","appBuildVersion":"3","appIdentifier":"com.example.jenkins","appIcon":"d46bb5e9da9264ef7561faa6a665cf05","appDescription":"","appUpdateDescription":"","appScreenshots":"","appShortcutUrl":"md7K","appCreated":"2017-09-19 11:18:33","appUpdated":"2017-09-19 11:18:33","appQRCodeURL":"https:\/\/www.pgyer.com\/app\/qrcodeHistory\/3c523d03895e28aad8bd3cac5ce6fcaabec8690ad01bef4489087671f04825b4"}}
```

其中`appQRCodeURL`中保存的就是二维码链接格式为是：

```
"appQRCodeURL":"http:\/\/static.pgyer.com\/app\/qrcodeHistory\/*****(长度64的hash)" 。
```

怎么用呢？要知道 Jenkins description setter 本来就支持 正则式的！换言之，它可以用正则式在log输出中找匹配，并且将匹配到的 match 用于description。

```
Regular expression : .*qrcodeHistory\\/(\S{64})

Description : <img src="http://static.pgyer.com/app/qrcodeHistory/\1">
```

其中 \1 表示引用第一个匹配。（注意，匹配是从0开始算的，不过 \0 是整个匹配行）

### 蒲公英
#### curl安装
[curl](http://curl.haxx.se/download.html) 
[cacert](http://curl.haxx.se/docs/caextract.html)

1. 下载curl下zip包但是不用解压, 直接把包里面的curl.exe文件复制粘贴到新建的一个文件夹`curl`里面
2. 下载cacert.pm, 如果需要框架ssl这种东西就需要用了.
3. 把这个文件重命名为: `curl-ca-bundle.crt `, 粘贴到curl文件夹中
4. 配置环境变量, cmd打开文件, 输入curl, 查看是否安装成功.

### 参考
[利用Jenkins玩转Android自动打包发包](http://blog.csdn.net/mabeijianxi/article/details/52680283)
[Android-解放双手告别测试-使用Jenkins自动化打包](http://www.jianshu.com/p/915c1ae69144)
[Android Gradle 常用命令参数及解释](http://www.jianshu.com/p/a03f4f6ae31d)

### 遇到的问题

#### Unable to open PNG file
1. 问题描述
![Alt text](<../../attachment/:pngerrror.png>)

2. 解决方案
在`gradle.properties`中加个配置：`android.buildCacheDir=D:/android-build-cache`当然后面的路径自己新建就行；
