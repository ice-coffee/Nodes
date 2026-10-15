## Vue
@(JavaScript)

Vue v-model
Vue computed

https://vuejs.org/js/vue.js

### 一、Vue对象

```
var vue = new Vue({
	el: '#app', //绑定元素
	data: {     //数据
		items: [
			{ message: 'Foo' }
			{ message: 'Bar' }
			{ message: 'Had' }
		]
	},
	computed: { //计算属性

	},
	method: { //函数
		
	}
})
```

#### 1、data
> 存放数据

1. 可以是基本类型

```
name: 'vue',
old: 12,
isMan: false
```

2. 对象

```
student: {
	name: 'vue',
	old: 12,
	isMan: false
}
```

3. 数组

```
students: [
	{ name: '小明' }
	{ name: '小红' }
	{ name: '小菜' }
]
```

#### 2、computed

#### 3、watch
> 通过监听器watcher能够监听到任何属性的更新。监听器在watch对象中声明，类型为函数，函数名与需要被监听的data对象中的属性同名，每当被监听的属性改变一次，监听器函数就会被自动调用执行一次。
> `监听器适用于当属性改变时需要进行某些额外处理的情形`

```
var vm = new Vue({
  el: '#demo',
  data: {
    firstName: 'Foo',
    lastName: 'Bar',
    fullName: 'Foo Bar'
  },
  watch: {
	//// 监听器函数名必须跟需要被监听的data对象中的属性num同名
    firstName: function (val) {
      this.fullName = val + ' ' + this.lastName
    }
  }
})
```

### 二、指令
> 定义为带有 v- 前缀的特殊特性。指令的职责是，当表达式的值改变时，将其产生的连带影响，响应式地作用于 DOM。

#### 1、{{ msg }}
> 最常见的数据绑定形式

```
<span>Message: {{ msg }}</span>
```

#### 2、v-html
> 双大括号会将数据解释为普通文本，而非 HTML 代码。为了输出真正的 HTML，你需要使用`v-html` 指令

#### 3、v-bind
> 用于响应式地更新 HTML 特性

```
<!-- 完整语法 -->
<a v-bind:href="url"> ... </a>

<!-- 简写 -->
<a :href="url"> ... </a>
```

以下使用`class`举例，在`style`上效果相同

```
// 绑定数据
<div class="static"
     v-bind:class="{ active: isActive, 'text-danger': hasError }">
</div>

data: {
  isActive: true,
  hasError: false
}

//---------------------------
//绑定对象
<div v-bind:class="classObject"></div>

data: {
  classObject: {
    active: true,
    'text-danger': false
  }
}

//---------------------------
//绑定函数
<div v-bind:class="classObject"></div>

data: {
  isActive: true
},
computed: {
  classObject: function () {
    return {
      active: this.isActive && !this.error
    }
  }
}

//---------------------------
//绑定数组
<div v-bind:class="[activeClass, errorClass]"></div>

data: {
  activeClass: 'active',
  errorClass: 'text-danger'
}
```

#### v-on
>

```
<!-- 完整语法 -->
<a v-on:click="doSomething"> ... </a>

<!-- 简写 -->
<a @click="doSomething"> ... </a>
```

### 三、组件
> 当你在自定义组件中使用 `class` 属性，这些 class 会被添加到组件的根元素上。根元素上已经存在的 class 不会被覆盖。

例如，如果你这样声明组件：

```
Vue.component('my-component', {
  template: '<p class="foo bar">Hi</p>'
})
```

然后，在调用组件时，再添加一些 class：

```
<my-component class="baz boo"></my-component>
```

那么，最终渲染的 HTML 就是：

```
<p class="foo bar baz boo">Hi</p>
```
