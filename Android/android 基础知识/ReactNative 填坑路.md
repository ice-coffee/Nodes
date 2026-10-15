## ReactNative 填坑路

### 特别注意

#### 1. 版本
由于React Native是从android `4.1`开始支持的，因此我们直接创建的工程的最小版本号为`16`。

#### 2. react-native对react的版本有严格要求
react-native对react的版本有严格要求，高于或低于某个范围都不可以。本文无法在这里列出所有react native和对应的react版本要求，只能提醒读者先尝试执行npm install，然后注意观察安装过程中的报错信息，例如require react@某.某.某版本, but none was installed，然后根据这样的提示，执行npm i -S react@某.某.某版本。

#### 3. 三个位置的项目名需一致
package.json
```
"name": "ReactNativeTest"
```

Activity:
```
mReactRootView.startReactApplication(mReactInstanceManager, "ReactNativeTest", null);
```

index.android.js
```
AppRegistry.registerComponent('ReactNativeTest', () => HelloWorld);
```

### bug
错误日志:
Caused by: java.lang.IllegalAccessError: Method 'void android.support.v4.net.ConnectivityManagerCompat.<init>()' is inaccessible to class 'com.facebook.react.modules.netinfo.NetInfoModule' (declaration of 'com.facebook.react.modules.netinfo.NetInfoModule' appears in /data/data/im.yixin.rndemo2/files/instant-run/dex/slice-com.facebook.react-react-native-0.20.1_76f14c344d869afc092625e7670a68a34348b199-classes.dex)
at com.facebook.react.modules.netinfo.NetInfoModule.<init>(NetInfoModule.java:55)

从日志可以看出是ConnectivityManagerCompat的实现获取错误。

解决方案：这里我们主要修改如下的代码，只代码查找的实现错误，之前我们添加了maven，这里我将：

```
 "$rootDir/.../node_modules/react-native/android" 
 改成如下:
 "$rootDir/node_modules/react-native/android"
```
