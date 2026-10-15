### Android 命名规范总结

@(android 基础知识)


### 命名法
- Camel(骆驼)命名法：除首单词外，其余所有单词的第一个字母大写，如：fooBar;
- Pascal命名法:所有单词的第一个字母大写，如：FooBar；
- 下划线命名法:单词与单词间用下划线做间隔，如：foo_bar;
- 匈牙利命名法:广泛应用于微软编程环境中，在以Pascal命名法的变量，首字母小写说明该变量的类型。 变量的取名方式为：scope_ prefix_qualifier 范围前缀，类型前缀，限定词,如: g_foo_bar ("g_"表示全局变量);

### Java命名规范
1. 包(packages): 采用`反域名命名规则`，全部使用小写字母。一级包名为地顶级域名如com，二级包名为xx（可以是公司或则个人的随便），三级包名根据应用进行命名，四级以及之后的包名以模块或层级命名; 

```
com.tinyx.myapp.ui, com.tinyx.myapp.utils
```

2. 类(classes)：用`Pascal命名法`，尽量避免缩写; 类名称中包含单词缩写，则单词缩写的每个字母均应大写

```
MyActivity, PublicHTML，CommonURL
```

3. 接口(interface)：用`Pascal命名法`，多以 able 或 ible 结尾，多用作表示行为;

```
Runnable，Accessible
```

4. 方法(methods)：动词或动名词，采用`Camel命名法`，如：onCreate(),run()；下面是一些建议：

- 初始化相关方法，使用`init`为前缀标识，如：初始化布局initView()；

- boolean型使用`is``或check`为前缀标识, 如：checkValue()、isValidate();

- 返回某个值的方法，使用`get`为前缀标识，如：getName();

- 数据进行处理相关，尽量使用`process`为前缀标识，如：processUpdate();

- 保存数据相关，使用`save`为前缀标识，如：saveData();

- 对数据重置的，使用`reset`前缀标识，如：resetData();

- 清除数据相关，使用`clear`前缀标识，如：clearData();

- 移除某些项目，使用`remove`前缀标识，如:removeItem();

- 绘制数据或效果相关的，使用`draw`前缀标识，如：drawCircle();

5. 变量(variables)：采用`Pascal命名法`，采用有意义的命名如：firstName,lastName; 非模型类全局参数建议加上小写m开头.

6. 常量（constants）: 全部大写,采用`下划线命名法`.

### Android 资源文件命名规范
> 采用下划线命名法,全部小写. 若一个资源文件下不只包含一种资源, 需在文件名前加前缀区分

#### 1. layout 资源文件
> 格式: `前缀_模块_功能_说明.xml`

```
activity_main.xml
fragment_user_list_item.xml
dialog_alert.xml
```

#### 2. anim资源文件
> (anim只有一种资源，所以不必加前缀区分) 格式: `模块_功能_动画_方向.xml`

```
从下方推入    button_main_push_down_in.xml
从上方推出    button_main_push_up_out.xml
```
#### 3. 图片资源文件
> 格式: `前缀_功能_模块_说明.xml/png`

- 图标: ic_xxx; 
- 背景: bg_xxx; 

```
ic_application.png;
bg_main_button_default.png,  bg_main_button_press.png
```

#### 4. menu菜单资源文件
> 格式: `模块_功能_说明.xml`

```
main_activity.xml
user_fragment.xml
```

#### 5. values资源文件
##### ids资源
> 下划线小写命名法，格式: `前缀_模块_功能_说明`
##### strings/arrays/dimens资源
> 下划线小写命名法，不加任何前后缀，格式: `模块_功能_说明`
##### attrs/colors/ids/styles的属性和名称
attrs/colors/ids的属性和名称使用 Camel命名法; styles的属性使用 Camel命名法，名称使用 Pascal命名法;

```
<!--attr-->
<attr name="text" format="string"/>
<!--color-->
<color name="colorPrimary">#009688</color>
<!--item-->
<item name="tabLayout" type="id"/>
```

#### 6. drawable
##### shape
> 下划线小写命名法，格式: `shape_类型_颜色_锐角_描边_描述.xml`

```
长方形 白色 锐减为10像素 边框2像素的shape
shape_rect_white_rad10_stroke2.xml
```

##### selector
> 下划线小写命名法，格式: `selector_模块_功能_说明.xml`
