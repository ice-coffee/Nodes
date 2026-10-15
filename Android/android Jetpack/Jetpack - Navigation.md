### 如何使用Navigation

#### 添加依赖
Navigation：

``` java
dependencies {
  def nav_version = "2.1.0-beta02"
  def nav_version_ktx = "2.1.0-beta02"

  // Java
  implementation "androidx.navigation:navigation-fragment:$nav_version"
  implementation "androidx.navigation:navigation-ui:$nav_version"

  // Kotlin
  implementation "androidx.navigation:navigation-fragment-ktx:$nav_version_ktx"
  implementation "androidx.navigation:navigation-ui-ktx:$nav_version_ktx"

}
```
SafeArgs:

在根目录下的build.gradle文件添加：

``` java
buildscript {
    repositories {
        google()
    }
    dependencies {
        def nav_version = "2.1.0-beta02"
        classpath "androidx.navigation:navigation-safe-args-gradle-plugin:$nav_version"
    }
}
```
在app目录下的build.gradle文件添加：

``` java
//Java
apply plugin: "androidx.navigation.safeargs"

//Kotlin
apply plugin: "androidx.navigation.safeargs.kotlin"
```

#### 创建导航图
- 选中res文件夹 ---> New resource Directory，resource type 为navigation
- 选中navigation文件夹 ---> new Navigation resource file

#### 在XML文件中添加导航容器

``` java
<fragment
        android:id="@+id/nav_host_fragment"
        android:name="androidx.navigation.fragment.NavHostFragment"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:defaultNavHost="true"
        app:navGraph="@navigation/nav_graph" />
```

- 该android:name属性包含实现的类名NavHost 。
- 该app:navGraph属性将其NavHostFragment与导航图相关联。导航图指定NavHostFragment用户可以导航到的所有目标。
- 该app:defaultNavHost="true"属性确保您NavHostFragment 拦截系统“后退”按钮。请注意，只有一个NavHost可以是默认值。如果您具有相同布局的多个主机（例如，双窗格布局），请确保仅指定一个默认主机NavHost。

#### 在导航图中添加目的地
``` java
<?xml version="1.0" encoding="utf-8"?>
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
            xmlns:app="http://schemas.android.com/apk/res-auto"
            android:id="@+id/nav_graph"
            app:startDestination="@id/oneFragment">
    
    <fragment
            android:id="@+id/oneFragment"
            android:name="com.jide.jetpack.OneFragment"
            android:label="oneFragment">
        <action
                android:id="@+id/jumpTwo"
                app:destination="@id/twoFragment"/>
    </fragment>
    <fragment
            android:id="@+id/twoFragment"
            android:name="com.jide.jetpack.TwoFragment"
            android:label="twoFragment">
        <argument
                android:name="name"
                app:argType="string"
                android:defaultValue="twoDefault"
                app:nullable="true" />
        <action
                android:id="@+id/jumpThree"
                app:destination="@id/threeFragment"/>
    </fragment>
    <fragment
            android:id="@+id/threeFragment"
            android:name="com.jide.jetpack.ThreeFragment"
            android:label="ThreeFragment">
        <action
                android:id="@+id/jumpOne"
                app:destination="@id/oneFragment"/>
    </fragment>
</navigation>
```
- android:id：字段包含将用于在代码中引用目标的ID
- android:name：目标类的绝对路径

argument -- 传参
- android:name：传参名
- app:argType：传参类型
- android:defaultValue：默认值
- app:nullable：传参是否接受null值

action -- 跳转动作
- android:id：Directions生成函数名
- app:destination：跳转目的地

#### 导航到目的地
id导航：
``` java
val bundle = Bundle()
bundle.putString("name", "岳云鹏")

findNavController().navigate(R.id.twoFragment, bundle)
```
Directions导航：
``` java
findNavController().navigate(ThreeFragmentDirections.jumpOne("岳云鹏"))
```

#### 导航和后台堆栈
Android维护一个包含您访问过的目的地的==后备堆栈==。当用户打开应用程序时，应用程序的第一个目标位于堆栈中。每次调用该 ==navigate()== 方法都会将另一个目标放在堆栈顶部。按向上或向后分别调用 ==NavController.navigateUp()==和==NavController.popBackStack()== 方法，以从堆栈中删除（或弹出）顶部目标。

nnavigateUp()和popBackStack()的区别在于:


如下使用则与Activity的singleInstance效果一致。
``` java
<action
        android:id="@+id/jumpOne"
        app:popUpTo="@id/oneFragment"
        app:popUpToInclusive="true"
        app:destination="@id/oneFragment"/>
```
若A -> B -> C，目前堆栈中未startDest、A、B、C，若C在导航视图中设置如上action，则跳转到A后堆栈显示为startDest、A，若popUpToInclusive为false或不添加，则旧的A对象不会被删除，这样的话多操作几遍就会出现大量的A对象。
