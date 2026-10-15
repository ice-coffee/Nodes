## WePY

@(JavaScript)

this.$apply();

asyc / wait

使用ES6
![Alt text](<../../attachment/:1527851979012.jpg>)


[微信小程序wepy开发资源汇总 !](https://segmentfault.com/a/1190000013214768?utm_source=channel-hottest)

使用WePY开发前后的开发目录结构对比如下：

原生小程序的目录结构：

![Alt text](<../../attachment/:WechatIMG242.jpeg>)

使用WePY框架后的开发目录结构(主要为src目录的结构，dist目录除外)：
> 注：dist目录为WePY通过build指令生成的目录，除额外增加的npm目录外，其目录结构与原生小程序的目录结构类似。

![Alt text](<../../attachment/:WechatIMG241.jpeg>)

### 一、实例

在 WePY 中，小程序被分为三个实例：小程序实例`App`、页面实例`Page`、组件实例`Component`。其中`Page`实例继承自`Component`。各自的声明方式如下：

```
import wepy from 'wepy';

// 声明一个App小程序实例
export default class MyAPP extends wepy.app {
}

// 声明一个Page页面实例
export default class IndexPage extends wepy.page {
}

// 声明一个Component组件实例
export default class MyComponent extends wepy.component {
}
```

#### 1、App小程序实例
> 在Page页面实例中，可以通过`this.$parent`来访问App实例。eg：`this.$parent.customFun()`
```
import wepy from 'wepy';

export default class MyAPP extends wepy.app {
	// 自定义数据
    customData = {};

	// 自定义方法
    customFunction () {}

	// 生命周期函数
    onLaunch () {}

    onShow () {}

	// 全局页面配置对应 app.json 文件
    config = {
        "pages":[],
        "window":{}
    };

	// 全局数据对象
    globalData = {}
}
```

#### 2、Page页面实例和Component组件实例
```
import wepy from 'wepy';

// export default class MyPage extends wepy.page {
export default class MyComponent extends wepy.component {
	// 自定义数据
    customData = { name = '哈哈'; }

	//自定义方法
    customFunction ()　{ return 'sth'; }  

	// 在Page和Component共用的生命周期函数
    onLoad () {}  

	// 只在Page中存在的页面生命周期函数
    onShow () {}

	// 只在Page实例中存在的配置数据，对应于原生的page.json文件
    config = {}

	// 页面所需数据均需在这里声明，可用于模板数据绑定
    data = {}

	// 声明页面中所引用的组件，或声明组件中所引用的子组件
    components = {}

	// 声明页面所引用的Mixin实例
    mixins = []

	// 声明计算属性, 实现与Vue相同
    computed = {}

	// 数据监听，监听器函数名必须跟需要被监听的data对象中的属性num同名，其参数中的newValue为属性改变后的新值，oldValue为改变前的旧值
    watch = {}

	// 声明页面wxml中标签的事件处理函数。注意，此处只用于声明页面wxml中标签的bind、catch事件，自定义方法需以自定义方法的方式声明
    methods = {}

	//WePY组件事件处理函数对象，存放响应组件之间通过$broadcast、$emit、$invoke所传递的事件的函数
    events = {}
}
```

### 二、组件
> WePY中的组件都是静态组件，是以组件ID作为唯一标识的，每一个ID都对应一个组件实例，当页面引入两个相同ID的组件时，这两个组件共用同一个实例与数据，当其中一个组件数据变化时，另外一个也会一起变化。

```
<view class="child1">
    <child></child>
</view>

<view class="child2">
    <anotherchild></anotherchild>
</view>
```

```
components = {
    //为两个相同组件的不同实例分配不同的组件ID，从而避免数据同步变化的问题
    child: Child,
    anotherchild: Child
};
```
