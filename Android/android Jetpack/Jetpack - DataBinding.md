[toc]

### 推荐阅读
[DataBinding](https://developer.android.com/topic/libraries/data-binding?hl=zh-cn)

[DataBinding使用教程（三）：各个注解详解](https://juejin.cn/post/6844903494957137927#heading-14)

[Android官方架构组件DataBinding-Ex: 双向绑定篇](https://blog.csdn.net/mq2553299/article/details/86501045)

[每日一问 有没有使用过 DataBinding ，有什么优点、缺点，遇到过哪些坑？](https://www.wanandroid.com/wenda/show/8634)


数据绑定库(`DataBinding`)可以让我们声明式的将布局中的界面组件绑定到应用中的数据源。

### 使用入门

在需要使用 `DataBinding` 模块的 `build.gradle` 文件中添加 `dataBinding` 元素：

```
android {
    ...
    dataBinding {
        enabled = true
    }
}
    
```

> 注意：即使应用模块不直接使用数据绑定，也必须为依赖于使用数据绑定的库的应用模块配置数据绑定。也就是说如果 `app_module` 依赖的 `module` 中使用了 `DataBinding` 那么 `app_module` 中也需要配置 `dataBinding = true`。不然就会报错 `NoClassDefFoundError`。

### 小技巧

#### 快速生成 DataBinding 的 layout 布局
输入光标放到布局最外层，执行快捷键 `alt + enter` 选中 `Covert to data binding layout` 选项即可生成相应布局

### 布局和绑定表达式

#### 绑定数据
`DataBinding` 会为每个布局文件生成一个绑定类。默认情况下，类名称基于布局文件的名称，它会转换为 `Pascal` 大小写形式并在末尾添加 `Binding` 后缀。加入布局文件名为 `activity_main.xml`，因此生成的对应类为 `ActivityMainBinding`。

`activity_main.xml`：

```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <data>
        <variable
            name="user"
            type="com.sample.jetpack.databinding.User" />
    </data>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical">

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{@string/name_format(user.firstName, user.lastName)}" />

    </LinearLayout>
</layout>
```

绑定数据方式如下：

方式一：使用 `DataBindingUtil`
```
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val binding = DataBindingUtil.setContentView<ActivityDataBindBinding>(this, R.layout.activity_data_bind)
    binding.user = User("Test", "User")
}
```

方式二：使用绑定生成类
```
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val binding = ActivityMainBinding.inflate(layoutInflater)
    setContentView(binding.root)
    binding.user = User("Test", "User")
}
```

#### Null 合并运算符
`DataBinding` 中为空判断的语法更简洁了：

```
android:text="@{user.displayName ?? user.lastName}"
```
    
这在功能上等效于：

```
android:text="@{user.displayName != null ? user.displayName : user.lastName}"
```
    
#### 避免出现 Null 指针异常
生成的数据绑定代码会自动检查有没有 `null` 值并避免出现 `Null` 指针异常。例如，在表达式 `@{user.name}` 中，如果 `user` 为 `Null`，则为 `user.name` 分配默认值 `null`。如果您引用 `user.age`，其中 `age` 的类型为 `int`，则数据绑定使用默认值 `0`。

也就是说 `DataBinding` 会为在布局中引用的字段设置默认值。

#### 视图引用
表达式可以通过以下语法按 ID 引用布局中的其他视图：
```
<EditText
    android:id="@+id/example_text"
    android:layout_height="wrap_content"
    android:layout_width="match_parent"/>
<TextView
    android:id="@+id/example_output"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="@{exampleText.text}"/>
```

> 注意：绑定类将 `ID` 转换为驼峰式大小写。

#### 集合
可使用 `[]` 运算符访问常见集合，例如数组、列表、稀疏列表和映射。
```
<data>
    <import type="java.util.List"/>
</data>

android:text="@{list[index]}"
```

#### 字符串字面量
您可以使用单引号括住特性值，这样就可以在表达式中使用双引号：
```
android:text='@{map["firstName"]}'
```

也可以使用双引号括住特性值。如果这样做，则还应使用反单引号将字符串字面量括起来：
```
android:text="@{map[`firstName`]}"
```

#### 资源、填充字符串
在表达式中引用应用资源和正常使用一致：
```
android:padding="@{large? @dimen/largePadding : @dimen/smallPadding}"
```

可以通过提供参数的形式填充字符串：
```
android:text="@{@string/nameFormat(firstName, lastName)}"
```

#### 事件处理
这里的事件处理基本是专指 `onClick` 事件，其它事件处理可通过 `绑定适配器` 实现。`DataBinding` 对于事件处理有两种方式：

- `方法引用`
- `监听器绑定`

在文档中有这样一句话 `方法引用和监听器绑定之间的主要区别在于实际监听器实现是在绑定数据时创建的，而不是在事件触发时创建的。如果您希望在事件发生时对表达式求值，则应使用监听器绑定。` 还没有看它的源码大致猜测一下应该是指绑定监听的时机不同，`方法引用` 是在绑定数据时创建事件监听器，`监听器绑定` 是在事件发生时创建。

##### 方法引用
方法引用的写法如下：

```
<?xml version="1.0" encoding="utf-8"?>
<layout>

    <data>
        <variable
            name="handle"
            type="***.MyHandle" />
    </data>

    <LinearLayout>

        <Button
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="OnClick"
            android:onClick="@{handle::onHandleClick}"/>

    </LinearLayout>
</layout>


override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    binding.handle = MyHandle()
}

class MyHandle {
    fun onHandleClick(view: View) {

    }
}
```

这个写法是不是特眼熟，这不就是 `OnClickListener 的三种实现方式` 中在 `xml` 中指定 `onClick` 事件的写法吗。

它们写法的要求也是一致的，就是参数要和 `Listener` 实现方法的参数一致。对于 `OnClickListener` 来说就是方法的参数必须且只能有一个 `Viiew`。

##### 监听器绑定
监听器绑定的写法是 `lambda` 表达式，如下：

```
<?xml version="1.0" encoding="utf-8"?>
<layout>

    <data>
        <variable
            name="handle"
            type="***.MyHandle" />
    </data>

    <LinearLayout>

        <Button
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="OnClick"
            android:onClick="@{(view) -> handle.onHandleClick()}"/>

    </LinearLayout>
</layout>


override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    binding.handle = MyHandle()
}

class MyHandle {
    fun onHandleClick() {

    }
}
```

`监听器绑定` 的表达式的写法和使用 `Java + lambda` 的写法基本一致
```
button.setOnClickListener { view -> onHandleClick() }

fun onHandleClick() {
}
```

这两种方法的区别是：
`方法引用`：不能修改参数。
`监听器绑定`：可添加任意参数，但返回值需要和监听器实现方法的返回值一致。

#### 导入、变量、包含

导入：
```
import android.view.View
import java.util.List

<import type="android.view.View"/>
<import type="java.util.List"/>
```

变量定义：
```
<variable name="image" type="Drawable"/>
```

`<variable/>` 标签是变量声明，`name` 表示变量名，`type` 属性表示变量类型。

包含：
`include` 可以使用 `bind:变量名` 进行数据绑定的传递：
```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:bind="http://schemas.android.com/apk/res-auto">
    <data>
        <variable
            name="user"
            type="com.example.User" />
    </data>
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent">
        <include
            layout="@layout/name"
            bind:user="@{user}" />
    </LinearLayout>
</layout>

<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:bind="http://schemas.android.com/apk/res-auto">
    <data>
        <variable
            name="user"
            type="com.example.User" />
    </data>
    <merge><!-- Doesn't work -->
        <include
            layout="@layout/name"
            bind:user="@{user}" />
    </merge>
</layout>
```

### 使用可观察的数据对象
略

### 生成的绑定类

#### 带 ID 的视图
数据绑定库会针对布局中具有 `ID` 的每个视图在绑定类中创建不可变字段。字段名与 `ID` 名一致。从此告别 `findViewById` 并且性能比 `butterknife` 更好。

#### 即时绑定
当可变或可观察对象发生更改时，绑定会按照计划在下一帧之前发生更改。但有时必须立即执行绑定。要强制执行，请使用 `executePendingBindings()` 方法。

#### 高级绑定
动态变量
有时，系统并不知道特定的绑定类。例如，针对任意布局运行的 `RecyclerView.Adapter` 不知道特定绑定类。在调用 `onBindViewHolder()` 方法时，仍必须指定绑定值。

在 `RecyclerView` 使用 `DataBinding` 如下：

```
class DataBindingActivity : AppCompatActivity() {
    private val itemColorList = mutableListOf(
            Item("#CD950C"),Item("#8B658B"),Item("#FFC1C1"),
            Item("#EEB4B4"),Item("#CD9B9B"),Item("#8B6969"),
            Item("#FF6A6A"),Item("#EE6363"),Item("#CD5555"))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = MainAdapter(this, itemColorList)
    }
}

class MainAdapter(private val context: Context, private val colorList: List<Item>) :
        RecyclerView.Adapter<MainViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MainViewHolder {
        return MainViewHolder(DataBindingUtil.inflate(LayoutInflater.from(context), R.layout.list_item, parent, false))
    }

    override fun getItemCount(): Int {
        return colorList.size
    }

    override fun onBindViewHolder(holder: MainViewHolder, position: Int) {
        holder.binding.setVariable(BR.item, colorList[position])
        holder.binding.executePendingBindings()
    }
}

class MainViewHolder(val binding: ListItemBinding) : RecyclerView.ViewHolder(binding.root)
```

> `BR` 是自动生成的，其中包含用于数据绑定的资源的 ID。在上面的代码中 `BR` 可能无法自动导入，需要在 `build.gradle` 中添加 `apply plugin: 'kotlin-kapt'`，再手动添加 `import androidx.databinding.library.baseAdapters.BR` 导入。

关于在 `onBindViewHolder` 中绑定视图的方式还可以用如下方式：

```
override fun onBindViewHolder(holder: MainViewHolder, position: Int) {
    holder.binding.item = colorList[position]
    holder.binding.executePendingBindings()
}
```

不需要 `BR` 类，`setVariable` 内部也是通过 `setItem` 的方式。

#### 自定义绑定类名称
默认绑定类名称的生成规则上面写到了，通过 `class` 属性可以自定义绑定类名称。
```
<data class="ContactItem">
</data>
```

### 绑定适配器

以下要使用很多注解，所以要在 `build.gradle` 中添加：
```
apply plugin: 'kotlin-kapt'
```

#### 自动选择方法

对于使用 `DataBinding` 绑定数据的属性来说，`DataBinding` 会自动在源码中尝试查找属性对应的 `setter` 方法。比如 `android:text=""` 对应的 `setter` 方法为 `setText()` 方法。查找过程中 `DataBinding` 不会考虑属性的命名空间，只关注 `属性名称` 和 `参数类型`。

也就是说对于未在 `Android:` 命名空间定义的属性可以使用自定义命名空间 `app:`，如：

```
<android.support.v4.widget.DrawerLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        app:scrimColor="@{@color/scrim}"
        app:drawerListener="@{fragment.drawerListener}">
```

#### 指定自定义方法名称

对于具有不符合规则的 `setter` 方法的属性，如 `android:tint` 它所对应的 `setter` 方法为`setImageTintList()` 和期望的 `setTint()` 不同，这时需要使用 `@BindingMethods、@BindingMethods` 注解手动绑定。

```
@BindingMethods(value = [
    BindingMethod(
        type = android.widget.ImageView::class,
        attribute = "android:tint",
        method = "setImageTintList")])
```

之后，对于使用数据绑定的 `tint` 属性，`DataBinding` 就会去查找 `setImageTintList` 方法并调用了。

`@BindingMethods` 、`@BindingMethod` 的用法如下：
`@BindingMethods`：声明一组 `@BindingMethod`。
`@BindingMethod`：有3个字段，这3个字段都是必填项，少一个都不行：  
- `type`：要操作的属性属于哪个View类，类型为class对象，比如：ImageView.class  
- `attribute`：xml属性，类型为String ，比如：”android:tint”  
- `method`：指定xml属性对应的set方法，类型为String，比如：”setImageTintList”

> 注意：绝大部分情况下不需要我们去使用这两个注解，`Android` 已经为大部分属性设置了 `BindingMethod`。可以查看 `TextViewBindingAdapter` 等绑定类了解。

#### 提供自定义逻辑
上面两种方式都是针对具有相关联 `setter` 方法的属性，那对于不具备关联的 `setter` 属性来说如果需要和某方法进行绑定需要 `@BindingAdapter` 注解。

```
@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, padding: Int) {
    view.setPadding(padding,
                view.getPaddingTop(),
                view.getPaddingRight(),
                view.getPaddingBottom())
}
```

如上添加 `@BindingAdapter` 注解之后，若使用 `android:paddingLeft` 属性时通过 `DataBinding` 绑定数据，则 `DataBinding` 会调用 `setPaddingLeft(view: View, padding: Int)` 方法。

`@BindingAdapter` 注解使用注意：
- 注解的方法必须为 `公共静态方法`；
- 方法的第一个参数类型必须为 `View`。

在 `Kotlin` 中使用 `@BindingAdapter` 注解方法有两种方式：

第一种，使用 `@JvmStatic` 注解标记为静态方法：

```
companion object {
    @BindingAdapter("android:paddingLeft")
    @JvmStatic
    fun setPaddingLeft(view: View, padding: Int) {
        view.setPadding(padding,
            view.getPaddingTop(),
            view.getPaddingRight(),
            view.getPaddingBottom())
    }
}
```

第二种，最简单的就是直接在顶层声明：

```
package com.xxx.xxx

@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, padding: Int) {
    view.setPadding(padding,
                view.getPaddingTop(),
                view.getPaddingRight(),
                view.getPaddingBottom())
}
```

`DataBinding` 的事件处理一般只能处理只具有一种抽象方法的接口或抽象类，如 `OnClickListener`，如果要处理具有多种抽象方法的事件也可以通过 `@BindingAdapter` 实现，如 `TextWatcher`。

`Android` 已经为我们提供了 `TextWatcher` 事件的处理，可以查看 `androidx.databinding.adapters.TextViewBindingAdapter` 中的源码查看。

#### 对象转换

##### 自动转换对象
当绑定表达式返回 `Object` 时，`DataBinding` 会选择用户设置属性值的方法。`Object` 会转换为所选方法的参数类型。

##### 自定义转换
当绑定表达式的返回值类型和设置属性的方法参数不一致时，可以通过 `@BindingConversion` 注解自定义转换。比如 `android:background` 属性：
```
<View
    android:background="@{isError ? @color/red : @color/white}"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
```

每当需要 `Drawable` 且返回整数时，`int` 都应转换为 `ColorDrawable`。

```
@BindingConversion
public static ColorDrawable convertColorToDrawable(int color) {
    return new ColorDrawable(color);
}
```

但是，绑定表达式中提供的值类型必须保持一致。
```
<View
    android:background="@{isError ? @drawable/error : @color/white}"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
```

### 将布局视图绑定到架构组件

#### 使用 LiveData 将数据变化通知给界面
> 注意：当使用 `LiveData` 对象作为数据绑定来源时需要添加 `setLifecycleOwner` 设置声明周期所有者。不然当 `LiveData` 数据值发生变化时，`UI` 不会随之改变。

```
class ViewModelActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        val binding: UserBinding = DataBindingUtil.setContentView(this, R.layout.user)

        binding.setLifecycleOwner(this)
    }
}
```

#### 使用 ViewModel 管理界面相关数据
略

#### 使用 Observable ViewModel 更好地控制绑定适配器
大多我们更喜欢 `ViewModel + LiveData` 的方式来管理页面数据，因为这种方式更简单。但是无法对数据源做更精细的控制，比如对数据的赋值操作做自定义处理，和控制数据更改发送通知的时机。

```
class UserObservable : BaseViewModelObservable() {

    //Bindable 注释会在 BR 类文件中生成一个条目
    @get:Bindable
    var userName: String = ""
        set(value) {
            field = if (value.length > 1) value.substring(0, 1) + "-" + value else value
            
            saveData()
            
            notifyPropertyChanged(BR.userName)
        }

    fun updateUserNameValue() {
        userName = "${Random.nextInt(100)}"
    }
    
    fun saveData() {
        // do something
    }
}
```

### 双向数据绑定
双向数据绑定是指 `源数据` 和 `UI` 之间是互相影响的。其一发生变化另一个也会跟着变化。

要实现双向数据绑定需要满足如下条件：

- 源数据可监听
- `@={}` 表示法

#### 自定义特性的双向数据绑定
`Android` 已为部分常用属性实现了双向数据绑定操作。比如 `TextViewBindingAdapter`。

如果想对自定义属性添加双向数据绑定则需要 `@InverseBindingAdapter` 和 `@InverseBindingMethod` 注解实现。

在 `绑定适配器` 部分介绍了 `@BindingAdapter` 和 `@BindingMethod` 注解，他们和彼此的 `innverse` 注解是一一对应的。 

`@InverseBindingAdapter` 注解包含两个字段：

- `attribute`：属性名
- `event`：因值被更改而要调用的事件

下面是一个自定义视图：
```
class CustomEditText(context: Context, attrs: AttributeSet?) : androidx.appcompat.widget.AppCompatEditText(context, attrs)
```

```
class CustomEditTextBindingAdapter {

    companion object {
        @BindingAdapter("app:customTextAttrChanged")
        @JvmStatic
        fun setChangeListener(view: CustomEditText, attrChange: InverseBindingListener?) {
            val newValue: TextWatcher = object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {
                }

                override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                    attrChange?.onChange()
                }

                override fun afterTextChanged(s: Editable) {
                }
            }
            val oldValue = ListenerUtil.trackListener(view, newValue, R.id.textWatcher)
            if (oldValue != null) {
                view.removeTextChangedListener(oldValue)
            }
            if (newValue != null) {
                view.addTextChangedListener(newValue)
            }
        }

        @BindingAdapter("app:customText")
        @JvmStatic
        fun setCustomText(view: CustomEditText, text: String) {
            val oldText: CharSequence? = view.text
            if (text == oldText) {
                return
            }
            view.setText(text)
        }

        @InverseBindingAdapter(attribute = "app:customText", event = "app:customTextAttrChanged")
        @JvmStatic
        fun getCustomText(view: CustomEditText): String {
            return view.text.toString()
        }
    }
}
```

> 注意：每个双向绑定都会生成 `合成事件特性`。该特性与基本特性具有相同的名称，但包含后缀 `AttrChanged`。合成事件特性允许库创建使用 `@BindingAdapter` 注释的方法，以将事件监听器与相应的 `View` 实例相关联。

实现自定义属性的双向数据绑定要注意如下：

- 必须实现添加 `@BindingAdapter` 注解的 `AttrChanged` 合成事件。
- 必须在事件方法内，执行 `onChange()` 方法回调。

查看源码可知，`AttrChanged` 事件是必须要添加的，`UI` 更改数据源的落在 `绑定类.InverseBindingListener.onChange()` 方法内，也就是说，只有 `onChange()` 方法被调用，数据源才会更新。所以在 `TextViewBindingAdapter` 中 `onChange()` 在 `onTextChanged()` 回调内，才能保证数据的实时双向更新。

文档的双向绑定部分对于 `AttrChanged` 事件的介绍特别轻描淡写很容易让人误入歧途，而且目前 `DataBinding` 问题定位的难度真是让人头疼。

#### 双向数据绑定的无限循环
无限循环的问题很好理解，所以必须要在赋新值前对新老数据进行比对。

#### 转换器
如果要对双向绑定的数据进行转换后再显示到 `UI` 上，那么需要添加 `转换方法` 和 `反转换方法`。

```
object Converter {
    @InverseMethod("stringToInt")
    @JvmStatic
    fun intToString(newValue: Int): String {
        return newValue.toString()
    }

    @JvmStatic
    fun stringToInt(newValue: String): Int {
        return newValue.toInt()
    }
}
```

对转换方法添加 `@InverseMethod` 注解。这个注解只有一个字段就是对应反向转换方法的方法名。

> 注意：经测试 `Android` 文档中 `dateToString` 转换方法的写法是错误的。在 `@InverseMethod` 注释中可以看到对转换方法和反转换方法的规定。`两个方法中参数的数量要一致，并且除最后一个参数外，其他参数要一致，并且最后一个参数互为对放的返回值`。其中说明参数可超过一个，但实际测试时参数超过一个之后也无法进行双向绑定。所以就大家还是添加一个参吧。

最后吐槽一下，双向绑定这部分文档写的这么随意吗 `-_-!`。

### 问题记录

#### `java.lang.NoClassDefFoundError: Failed resolution of: Landroidx/databinding/DataBinderMapperImpl;`

估计遇到这种问题的都用了组件化，组件里写了dataBinding {enabled = true}但是主组件没写，然后运行主组件的时候报错了，只需要在主组件里也加上dataBinding {enabled = true}就可以了。

### findViewById VS ButterKnife VS ViewBinding VS DataBinding

|  | ViewBinding | ButterKnife | Kotlin |
| --- | :---: | :---: | :---: |
| 空安全 | ✅ | ✅ | ❎ |
| 只引用当前布局中的 id | ✅ | ❎ | ❎ |
| 支持 Kotlin 和 Java | ✅ | ✅ | ❎ |
| 需要的代码量 | 少 | 重复 | 少 |

### 思考
`DataBinding` 这篇将近用了有两个周末的时间才把理论大致梳理一遍，这让人不禁思考 `DataBinding` 存在的意义是什么。大家对 `DataBinding` 也是褒贬不一又爱又恨。
由于没有在实际开发中使用过，所以就照搬一套大家对它的褒贬吧。

优点主要集中在：

- 不用再写 `findViewById`，提高性能。
- 视图层和数据层分离。

缺点主要集中在：

- 很难定位 `bug`。出现问题基本就只能看到 `DataBinding` 类无法生成，具体原因没有提示需要自己去排查代码。
- `AS` 对 `DataBinding` 支持不友好，代码补全有点差。
- 学习成本高。

通过对 `Jetpack` 的学习可以很明显发现 `Google` 的意图：为 `Android` 开发者提供一套通用的开发规范和开发架构。而 `DataBinding` 作为 `MVVM` 架构中重要的组成部分，它起到了分离视图层和数据层的作用，虽然它仍然有这样那样的问题，但仍然是一个值得使用的库。
