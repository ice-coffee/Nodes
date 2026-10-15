### Android SDK在线更新SDK的方法(使用国内镜像)

本文讲述了Android使用国内镜像在线更新SDK的方法。分享给大家供大家参考，具体如下：
#### 什么是Android SDK：
SDK：（software development kit）软件开发工具包。被软件开发工程师用于为特定的软件包、软件框架、硬件平台、操作系统等建立应用软件的开发工具的集合。而 Android SDK 就是 Android 专属的软件开发工具包。
加速下载的方法：
由于 Google 服务器在中国大陆无法正常访问，Android SDK 无法正常更新，给安卓开发者带来诸多不便。下面介绍几种网上找到的加速 Android SDK 更新的方法。
##### 修改 hosts 文件
在使用 Android SDK Manager 的时候，主要会连接到两个地址 dl.google.com 和 dl-ssl.google.com，key发现这两个地址都是无法正常访问的，如何解决呢？我们可以通过修改 hosts 文件，将上面的地址定向到能正常访问的 Google 服务器。我们可以使用站长工具的超级 ping 来查找可用IP。
打开地址：http://ping.chinaz.com/，分别测试 dl.google.com 和 dl-ssl.google.com 的IP地址，将获取到的IP写入C:\Windows\System32\drivers\etc\hosts文件。
![enter image description here](http://files.jb51.net/file_images/article/201512/20151214151445439.png?2015111415151)
写好后测试是否能正常更新，不行的话，再次测试，再换，总有可以用的IP。

##### 使用国内镜像源
先在这里推荐几个：
1. mirrors.neusoft.edu.cn //东软信息学院
2. ubuntu.buct.edu.cn/ubuntu.buct.cn //北京化工大学
3. mirrors.opencas.cn (mirrors.opencas.org/mirrors.opencas.ac.cn) //中国科学院开源协会
4. sdk.gdgshanghai.com 端口：8000 //上海GDG镜像服务器
5. mirrors.dormforce.net //（栋力无限）电子科技大学(`强烈推荐`)

使用方法：
启动 Android SDK Manager ，打开主界面，依次选择「Tools」、「Options…」，弹出『Android SDK Manager – Settings』窗口；
在『Android SDK Manager – Settings』窗口中，在「HTTP Proxy Server」和「HTTP Proxy Port」输入框内填入mirrors.neusoft.edu.cn和80，并且选中「Force https://… sources to be fetched using http://…」复选框。设置完成后单击「Close」按钮关闭『Android SDK Manager – Settings』窗口返回到主界面；
依次选择「Packages」、「Reload」。
如下图所示：
![enter image description here](http://files.jb51.net/file_images/article/201512/20151214151132472.png?20151114151528)

希望本文所述对大家Android程序设计有所帮助。
