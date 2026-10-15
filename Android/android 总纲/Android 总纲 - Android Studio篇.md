### Asset与raw都能存放资源，他们有什么区别？
1. res/raw和assets的相同点：
- 两者目录下的文件在打包后会原封不动的保存在apk包中，不会被编译成二进制。

2. res/raw和assets的不同点：
- res/raw中的文件会被映射到R.Java文件中，访问的时候直接使用资源ID即R.id.filename；assets文件夹下的文件不会被映射到R.java中，访问的时候需要AssetManager类。
- res/raw不可以有目录结构，而assets则可以有目录结构，也就是assets目录下可以再建立文件夹
3. 读取文件资源：
- 读取res/raw下的文件资源，通过以下方式获取输入流来进行写操作
- 读取assets下的文件资源，通过以下方式获取输入流来进行写操作

```
	InputStream is = getResources().openRawResource(R.id.filename);  
```

```
	AssetManager am = null;  
	am = getAssets();  
	InputStream is = am.open("filename"); 
```

### Android V1、V2、v3签名
### apk 打包流程
### Android 组件化
组件化就是指将项目中不同的业务模块拆分到不同的module中，各自的module可以单独运行，测试。

### Android 插件化
？？？
