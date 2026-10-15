## Android 问题集锦 07

@(android BUG记录)

### 描述

```
Error:(172) Error: "CH_Options" is not translated in "zh-rCN" (Chinese: China) [MissingTranslation]
```

![Alt text](<../../attachment/:international_error.jpg>)

### 问题原因
根据错误信息，是说我没有对string文件进行国际化翻译操作，查看报错位置，原来是当前项目引用的一个Library有国际化操作，包含values-en和values-zh两个文件夹，才导致我到处当前项目的时候报出此错误。

### 临时解决方案
1. 尝试添加translatable=”[true / false]”

```
 <string name="junkchen" translatable="false">Junk Chen!</string>  
```

2. 在resources中添加属性

```
<resources 
    xmlns:tools="http://schemas.android.com/tools"
    tools:ignore="MissingTranslation" >
```

3. 指定语言

```
<resources 
    xmlns:tools="http://schemas.android.com/tools"
    tools:locale="en" >
</resources>
```

4. 使用Android studio可以在build.gradle中的android中添加lintOptions

```
    lintOptions {
        disable 'MissingTranslation'
    }

或者

    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
```

### 最终解决方案
如果你的项目是国际化，或是双语的，那么在项目中创建values-en和values-zh两个文件夹，然后把中文的string.xml放到values-zh问价夹下，把英文的string.xml放到values-en下。
![Alt text](<../../attachment/:en.jpg>)


### 参考
[MissingTranslation如何处理](http://blog.csdn.net/kjunchen/article/details/50043487)
