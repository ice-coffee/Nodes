## React

### 开发环境配置
#### 1. Atom地址
https://atom.io/

#### 2. Atom插件
https://atom.io/packages

常用插件：
  浏览器浏览功能 open-in-browser (可设置快捷键)
  分页展示html页面效果 atom-html-preview (可设置快捷键)
  文件路径补全 autocomplete-path

#### 3. React官网
https://facebook.github.io/react/

#### 4. browser.min.js文件链接
https://cdnjs.cloudflare.com/ajax/libs/babel-core/5.8.24/browser.min.js

### React文件介绍
- react.js，React的核心库
- react-dom.js，提供与DOM相关的功能
- browser.min.js，将JSX语法转换成JavaScript语法

### React函数介绍

#### 1. ReactDOM.render()
> React的最基本方法， 用于将模板转换成html语言，渲染DOM，并插入指定的DOM节点。

三个参数：
- 模板的渲染内容（HTML形式）
- 模板需要插入的DOM节点
- 渲染后的回调，一般不用

```
<script type="text/babel">
    ReactDOM.render(
      <h1>Hello world!</h1>,
      document.getElementById("container")
    );
</script>
```

### JSX入门
JSX不是一门新的语言， 是个语法（语法糖）。

1. JSX必须借助React环境运行
2. JSX标签其实就是HTML标签，只不过我们在JavaScript中书写这些标签的时候，不用使用“”括起来，可以像xml一样书写。
3. 转换：JSX语法能让我们更直观的看到组件的DOM结构，不能直接在浏览器上运行，最终会转化成JavaScript代码在浏览器运行。
4. 在JSX中运行JavaScript代码。需要将表达式使用{}括起来。
5. 属性、设置样式、事件绑定。

```
<script type="text/babel">
	let name = "React";
    ReactDOM.render(
      <h1>Hello {name}!</h1>,
      document.getElementById("container")
    );
</script>
```

### 组件
- React中创建的组件类以大写字母开头，驼峰命名法。
- 在React中使用`React.createClass`方法创建一个组件类。
- 核心代码：每个组件类都必须实现自己的`render`方法，输出定义好的组件模板。返回值：null，false，组件模板。
- 注意：组件类只能包含一个顶层标签。

```
  <script type="text/babel">
    let HelloMessage = React.createClass({
      render:function(){
        return <h1>hello react</h1>
      }
    });

    ReactDOM.render(
      <HelloMessage/>,
      document.getElementById("container")
    );
  </script>
```

### 组件的样式

1. 内联样式
2. 对象样式
3. 选择器样式

> 注意：在React和HTML5中设置样式是有区别的
> - HTML5以`;`结尾，React以`,`结尾。
> - HTML5中key、value都不加引号，React中属于JavaScript对象，key的名字不能出现“`-`”，需要使用驼峰命名法。如果value为字符串，需要加`引号`。
> - HTML5中，value如果是数字需要带单位，React中不需要带单位。
> - 在React中使用选择器样式设置组件样式时，属性名不能使用`class`，需要使用`className`替换。类似的：使用`htmlFor`替换`for`。

```
<!DOCTYPE html>
<html>
  <head>
	...
	//选择器样式
    <style>
      .pStyle{
        font-size: 20px;
      }
    </style>
  </head>
  <body>
    <div id="aa"></div>
  </body>
  <script type="text/babel">
	//对象样式
    let hStyle = {
      backgroundColor:"green",
      color:"red"
    }

    let ShowMessage = React.createClass({
      render: function() {
        return (
	      //内联样式
          <div style={{backgroundColor:"yellow", borderWidth:5, borderColor:"black", borderstyle:"solid"}}>
            <h1 style={hStyle}>{this.props.fistRow}</h1>
            <p className="pStyle">{this.props.secondRow}</p>
          </div>
        );
      }
    });

    ReactDOM.render(
      <ShowMessage fistRow="nihao" secondRow="miaomaio"/>,
      document.getElementById("aa")
    );
  </script>
</html>
```

### props
> props是组件自身的属性，一般用于嵌套的内外层组件中，负责传递信息（通常是由父层组件向子层组件传递）
> 注意：props对象中的属性与组件的属性一一对应，不要直接去修改props中属性的值。

### children

### 属性默认设置

### state
#### 1. 事件处理
React中的事件名称，首字母小写，驼峰命名法。

```
<script type="text/babel">
    let MyButton = React.createClass({
      //定义事件绑定的方法，方法名可以随意起
      handleClick: function() {
        alert("点击按钮触发的效果");
      },

      //绑定事件通过 {this.事件名}
      render: function() {
        return <button onClick={this.handleClick}>{this.props.buttonTitle}</button>
      }
    });

    ReactDOM.render(
      <MyButton buttonTitle="按钮" />，
      document.getElementById("aa");
    );
  </script>
```

#### 2. state
当state发生变化时，会调用组件内部的render方法。

```
<script type="text/babel">
    let MyButton = React.createClass({

      //getInitialState 用于初始状态
      getInitialState : function() {
        return {
            liked : false
        };
      },

      //this.setState 方法修改状态值，
      //this.state.liked 读取
      handleClick: function() {
        this.setState({liked: !this.state.liked});
      },

      //绑定事件通过 {this.事件名}
      render: function() {
        let text = this.state.liked ? "like" : "haven\`t liked";
        return <button onClick={this.handleClick}>{text}</button>
      }
    });

    ReactDOM.render(
      <MyButton />,
      document.getElementById("aa")
    );
  </script>
```

### 表单

### 组件生命周期

#### 1. 生命周期
组件的生命周期可分为四个阶段：
创建、实例化、更新、销毁

组件的生命周期可分为三个状态：
- Mounting：组件挂载，已插入真实DOM。
- Updating：组件更新，正在被重新渲染。
- Unmounting：组件移出，已移出真是DOM。

#### 2. Mounting/组件挂载相关
1. componentWillMount
> 组件将要挂载。在render之前执行，但仅执行一次，即使多次重复渲染该组件，或者改变了组件的state。
2. componentDIdMount
> 组件已经挂载。在render之后执行，同一个组件重复渲染只执行一次。

#### 3. Updating/组件更新相关
1. componentWillReceiveProps(object nextProps)
> 已加载组件收到新的props之前调用，注意组件初始化渲染时不会执行
2. shouldComponentUpdate(object nextProps, object nextState)
> 组件判断是否重新渲染时调用。该接口实际是在组件接收到了新的props或者新的state的时候回立即调用，然后通过
3. componentWillUpdate(object nextProps, object nextState)
> 组件将要更新
4. componentDidUpdate(object prevProps, object prevState)
> 组件已更新

#### 4. Unmounting/组件移除相关
1. componentWillUnmount
> 在组件要被移除之前的时间点触发，可以利用该方法来执行一些必要的清理组件将要移除

#### 5. 生命周期中与props和state相关
1. getDefaultProps
> 设置props属性默认值
2. getInitialState
> 设置state属性chusi

#### 6. 生命周期流程
1. 创建阶段

```
  只调用getDefaultProps方法
```

2. 实例化阶段

```
  getInitialState
  componentWillMount
  render
  componentDidMount
```

3. 更新阶段

```
  componentWillReceiveProps
  shouldComponentUpdate 如果返回值是false，后三个方法不执行
  componentWillUpdate
  render
  componentDidUpdate
```

4. 销毁阶段

```
  componentWillUnMount
```
