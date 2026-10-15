[Android本地数据存储：Shared Preferences安全风险浅析](https://jaq.alibaba.com/blog.htm?id=56)
[SharedPreferences 的commit和apply分析](https://blog.csdn.net/u010198148/article/details/51706483)
[SharedPreference为什么不适合存储大量数据](https://blog.csdn.net/u010335298/article/details/72884644)
[彻底搞懂 SharedPreferences](https://juejin.im/entry/597446ed6fb9a06bac5bc630)
> 使用SharedPreferences存储数据要比文件存储简单,因为它是使用键值对的方式保存数据的

1. 如何得到SharedPreferences对象
	1. Context.getSharedPreferences(String name,  int mode);
    
	2. Activity.getPreferences(int mode);
            它只接受一个参数表示操作模式,而SharedPreferences文件的名字将自动为当前活动的类名;

	3. PreferenceManager 类中的 getDefaultSharedPreferences(Context context)方法
            这是一个静态方法，它接收一个 Context 参数，并自动使用当前应用程序的包名作为前缀来命名 SharedPreferences 文件。

> - Context.MODE_PRIVATE------------默认的操作模式和直接传入0效果相同,表示只有当前应用程序才可以对SharedPreferences文件进行读写.
> - Context.MODE_MULTI_PROCESS------在API 11以前的系统上，如果sp已经被读取进内存，再次获取这个sp的时候，如果有这个flag，会重新读一遍文件.
> - Context.MODE_WORLD_READABLE-----android4.2版本中已经废弃因为这个表示允许其他应用程序对我们程序中的文件进行读写操作
> - Context.MODE_WORLD_WRITEABLE----~~~~~同上~~~~~~

特别注意：MODE_MULTI_PROCESS，没有多进程操作

2. 向SharedPreferences文件中存储数据
- 调用 SharedPreferences 对象的 edit()方法来获取一个 SharedPreferences.Editor 对象。
- 向 SharedPreferences.Editor 对象中添加数据，比如添加一个布尔型数据就使用putBoolean 方法，添加一个字符串则使用 putString()方法，以此类推。
- 调用 commit()方法将添加的数据提交，从而完成数据存储操作。

3. 从SharedPreferences文件中读取数据
- SharedPreferences 对象中提供了一系列的get方法用于对存储的数据进行读取，每种get方法都对应了SharedPreferences.Editor 中的一种put 方法，比如读取一个布尔型数据就使用 getBoolean()方法，读取一个字符串就使用 getString()方法。这些 get 方法都接收两个参数，第一个参数是,传入存储数据时使用的键就可以得到相应的值了，第二个参数是默认值，即表示当传入的键找不到对应的值时，会以什么样的默认值进行返回。

4. SharedPreferences文件存储在/data/data/`packagename`/shared_prefs/目录下
