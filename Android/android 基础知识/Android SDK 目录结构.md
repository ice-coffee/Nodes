### Android SDK 目录结构
![Alt text](<../../attachment/:RW-MQP8PJ1_S1-6QXBE@A8.png>)

1. add-ons
> Google API 。比如GoogleMaps

2. build-tools
> 各版本SDK编译工具。

3. docs
> 离线开发者文档Android SDK API参考文档。

4. extras
> 扩展开发包 如高版本的API在低版本中开发使用。

5. platforms
> 各版本SDK。根据API Level划分的SDK版本，这里就以Android 2.2来说，进入后有 一个android-8的文件夹，android-8进入后是Android 2.2 SDK的主要文件，其中: 
> - ant为ant编译脚本，
> - data保存着一些系统资源，
> - images是模拟器映像文件，
> - skins则是Android模拟器的皮肤，
> - templates是工程创建的默认模板，
> - android.jar则 是该版本的主要framework文件，
> - tools目录里面包含了重要的编译工具，比如aapt、aidl、逆向调试工具dexdump和编译脚本dx。

6. platforms-tools
> 各版本SDK通用工具。比如adb、和aapt、aidl、dx等文件，Android 1 2 3版本提示，
这里和platforms目录中tools文件夹有些重复，主要是从Android 2.3开始这些工具被划分为通用了。

7. samples
> 各版本API使用样例。Android SDK自带的默认示例工程，强烈推荐初学者运行学习。

8. sources
> 各版本SDK源码。

9. system-images
> 模拟器映像文件。从android-14开始将模拟器映像文件整理在这里(原来放在platforms下)

10. temp
> 临时夹，一般在SDK更新安装时用到。

11. tools
> 各版本SDK自带工具。包含了重要的工具，比如DDMS用于启动Android调试工具，比如:
> - LoaCat、屏幕截图和文件管理器，
> - draw9patch则是绘制Android 平台的可缩放png图片的工具，
> - sqlite3可以在PC上操作SQLite数据库， 
> - monkeyrunner则是一个不错的压力测试应用，模拟用户随机按键，
> - mksdcard则是模拟器SD映像的创建工具，
> - emulator是 Android SDK模拟器主程序，不过从Android 1.5开始，需要输入合适的参数才能启动模拟器，
> - traceview作为Android 平台上重要的调试工具。

12. AVD Manager
> Android手机模拟配置工具，用于配置模拟器，只有先配置AVD才可运行模拟器。

13. SDK Manager
> SDK管理器，用于SDK更新、下载、删除。
