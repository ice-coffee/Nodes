## Android 问题集锦 08

@(android BUG记录)

### 描述

```
com.android.tools.aapt2.Aapt2Exception: AAPT2 error: check logs for details
```

### 问题原因
图片格式修改过, 我当时的操作是替换一张logo, 设计给的是jpg的, 我项目里的是png, 我在复制的时候, 在copy 确认框里, 修改了新logo的名字和图片格式.

### 解决方案
在google里找了三种解决方案, 
1. 解决这个问题之前先看一下 自己的android studio版本是多少

3. 0以下的解决方案  找到项目根目录下面的 gradle.properties加一句：`android.enableAapt2=false`  

如果android studio 升级了3.0以后的小伙伴

1. 先按上面的方法加一句试一下，因为3.0默认这个是打开的

2. 如果还是不好用，检查一下自己项目里面的图片，Android studio对图片的要求很高，可以检查出项目中图片的问题，如果项目中的图片有问题（格式被改过等等），就会报错，换掉图片就没问题了。

### 参考
[Aapt2Exception](http://www.voidcn.com/article/p-wberlryn-bro.html)
