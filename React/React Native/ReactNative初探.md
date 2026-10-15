## ReactNative初探

### 开发环境搭建
[ReactNative官网](http://reactnative.cn/docs/0.45/getting-started.html#content)

[使用Atom开发ReactNative配置](http://blog.csdn.net/hello_hwc/article/details/51612139)

[3分钟带你玩转React Native研发所有调试技巧](http://www.52learn.wang/archives/1071)

### index.xxx.js文件介绍
#### 1. 导入

ES6写法：

```
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
```

ES5写法：

```
let React = require("react-native");
let {
  AppRegistry,
  StyleSheet,
  Text,
  View
} = React;

require函数，搜索目录加载文件
```

- 导入ReactNative包，导入ReactNative组件
- AppRegistry：JS运行所有ReactNative应用的入口。
- StyleSheet：ReactNative中使用的样式表，类似CSS样式表。
- 各种开发中需要使用的组件（已定义很多）

#### 2. 创建ReactNative组件
ES6语法：

```
export default class HelloReactNative extends Component {
  render() {
    return ();
  }
}
```

ES5语法：

```
var HelloWork = React.createClass({
	render: function(){
		return {};
	}
});
```

#### 3. 创建样式实例

使用StyleSheet.create创建实例，在应用中只会被`创建一次`，不用每次在渲染周期中重新创建

```
<View style={styles.container}></View>

...

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
});
```

#### 4. 注册入口组件

```
AppRegistry.registerComponent('HelloReactNative', () => HelloReactNative);
```

- AppRegistry：负责注册运行ReactNative应用程序的JavaScript入口。
- registerComponent：注册应用程序的入口组件，告知ReactNative哪一个组件被注册为应用的根容器。
- 第一个参数是项目名，不然注册无法完成。
- 第二个参数使用了ES6语法，箭头函数；返回值必须是定义的组件类的名字。
