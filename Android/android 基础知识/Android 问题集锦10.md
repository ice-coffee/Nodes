### Android 问题集锦10

#### 问题描述：
Error:
	Attribute application@allowBackup value=(false) from AndroidManifest.xml:26:9-36
	is also present at [:common] AndroidManifest.xml:10:9-35 value=(true).
	Suggestion: add 'tools:replace="android:allowBackup"' to <application> element at AndroidManifest.xml:24:5-443:19 to override.

#### 解决方案
根据问题描述在application节点添加

```
 tools:replace="android:allowBackup" 
```

#### allowBackup属性
> 是否允许备份系统和用户数据的属性，应因此而引发Android的安全性问题。
