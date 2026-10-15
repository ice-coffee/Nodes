

### 1. 热修复方案

出名的热修复解决方案腾讯的Tinker、阿里的AndFix、美团的Robust和QZone

![热修复方案](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/hotfix_plan.jpg)

### 2. 不同热修复方案的实现原理

#### Dexposed 和 AndFix
这两种都是修改 ArtMethod 结构体中的字段。其中 Dexposed 只支持 dalvik 平台，Andfix 两种都支持。但这两种方案会有兼容问题，因为手机厂商可能会修改ArtMethod结构体，导致方法替换失败。
由于是 hook 方法体，所以不支持新增变量，方法和类。局限性较大。

- 类加载 + 反射
- JNI

#### Robust
[美团技术团队](https://tech.meituan.com/2016/09/14/android-robust.html)

基于Install Run的原理

Robust插件对代码的每个函数在编译打包阶段自动插入了一段代码，Robust为每个class增加了个类型为ChangeQuickRedirect的静态成员，而在每个方法前都插入了使用changeQuickRedirect相关的逻辑，当 changeQuickRedirect不为null时，可能会执行到accessDispatch从而替换掉之前老的逻辑，达到fix的目的。

- 类加载 + 反射
- 字节码插桩：如bytex（抖音开源）
- gradle

增多代码量

#### tinker
生成修复后的apk文件（补丁包）
下载补丁包
获取当前手机对应的apk文件
合并
![tinker](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/hotfix_tinker.jpg)

如何获取
ApplicationInfo - sourceDir

- 类加载
- 差分算法

#### Qzone
生成修复后的dex文件（补丁包）

![qzone](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/hotfix_qzone.jpg)

- 类加载
- 差分算法

tinker、qzone基于multidex的原理，利用了classloader 和 dex插桩实现bug修复

差分算法：
bsdiff：资源、so差分
dexdiff：代码差分

### 3 热修复简单实现
- 获取当前应用的PathClassloader;
- 反射获取到DexPathList的属性对象pathList;
- 反射修改pathList的dexElements属性：
    1. 把补丁包path.dex转化为Element[](path)。
    2. 反射修改pathList的dexElements属性。
    3. path + old合并，并反射复制给pathList的dexElements属性。


### 4 总结

Android ClassLoader 加载类流程图

热修复原理，绘制dex插桩式热修复流程图

source insight android 源码

反射

Dalvik、ART

dex2aot

Android N 混合编译 - 影响热修复

octotree chrome 查看github 插件

gradle task

ASM、JAVASISST - CLASS文件操作

aspectJ -> ASM实现库
