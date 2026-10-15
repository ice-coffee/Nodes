### Android 问题集锦 09

@(android BUG记录)

#### 问题描述
安装APK报错 INSTALL_FAILED_TEST_ONLY

#### 解决方案
1. 检查\app\src\main\AndroidMainfest.xml中是否有testOnly属性为true，如果有去掉或者改为false 

2. 检查Android Studio和gradle版本是否为alpha版本，换为稳定版本 

3. 检查是否关闭Instant Run功能，关掉此功能 

4. 检查是否使用alpha版本的依赖库，换成稳定版本

5. 如果以上均无法解决，就在gradle.properties文件中添加android.injected.testOnly=false
