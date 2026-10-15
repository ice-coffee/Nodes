## Web事件
事件简单来说可用来定义一些JavaScript函数, 使它们响应某个元素状态的改变.

### 使用简单事件处理器
简单的事件处理可以设置元素内部的事件属性的值, 给它指派一组JavaScript语句即可.

```
<p onmouseover="this.style.background='white'" onmouseout="this.style.removeProperty('background')"></p>
```

还可以定义函数, 在一定程度上解决繁琐和重复添加的问题:

js:
```
function handleMouseOver(elem) {
	elem.style.background='white';
}

function handleMouseOut(elem) {
	elem.style.removeProperty('background');
}
```
html:
```
<p onmouseover="handleMouseOver(this)" onmouseout="handleMouseOut(this)"></p>
```

> 注: 这里的this 指代触发事件的元素;

### 使用DOM和Event对象
DOM和Event对象可以进行更为复杂的处理(以及更优雅地定义事件处理器); 如下: 
html:
```
<p></p>
<p></p>
```
js:
```
var pElems = document.getElementsByTagName(p);

for(var i = 0; i < pElems.length; i++) {
	pElems[i].onmouseover = handleMouseOver;
	pElems[i].onmouseout = handleMouseOut;
}

function handleMouseOver(e) {
	e.taret.style.background = 'white';
}

function handleMouseOut(e) {
	e.taret.style.removeProperty('background');
}
```
> 注: 在使用函数名注册事件监听器时请不要加括号;

#### 理解Event

首先要说的第一点就是事件属性的命名方式: `以on开头, 后接事件名称.`
然后就是如何注册一个事件处理器, 方法有两种:

```
1. pElems[i].onmouseover = handleMouseOver;
2. pELems[i].addEventListener("mouseover", handleMouseOver);
```

我们还可以使用`removeEventListener`方法来取消函数与事件之间的关联:

```
pELems[i].removeEventListener("mouseover", handleMouseOver);
```

最后, 在以上代码中处理事件的函数定义了一个名为e的参数, 他会被设成浏览器所创建的一个Event对象, 它提供了发生事件的信息, 下表是Event对象的函数和属性:

| 名称      |     说明 |   返回   |
| :-------- | :--------| :------: |
|  type  |  事件的名称  |  字符串  |
|  target  |  事件指向的元素  |  HTMLElement  |
|  currentTarget  |  带有当前被触发事件监听器的元素  |  HTMLElement  |
|  eventPhase  |  事件生命周期的阶段  |  数值  |
|  bubbles  |  如果事件会在文档里冒泡则返回true, 否则返回false  |  布尔值  |
|  cancelable  |  如果事件带有可撤销的默认行为则返回true, 否则返回false  |  布尔值  |
|  timeStamp  |  事件的创建时间, 如果时间不可测则为0  |  字符串  |
|  stopPropagation()  |  在当前元素的时间监听器呗触发后终止事件在元素树种的流动  |  void  |
|  stopImmediatePropagation()  |  立即终止事件在元素树中的流动. 当前元素上未被触发的事件监听器会被忽略  |  void  |
|  preventDefault()  |  防止浏览器执行与事件关联的默认操作  |  void  |
|  defaultPrevented  |  如果调用过preventDefault()则返回true  |  布尔值  |

#### 理解事件流
一个事件的生命周期包括三个阶段: `捕捉`, `目标`和`冒泡`;
1. 捕捉阶段
当某个事件被触发时, 浏览器会找出body元素和目标元素在元素树之间的所有元素并分别检查他们是否带有事件处理器且要求获得其后代元素触发事件的通知.浏览器会先触发这些事件处理器, 然后才会轮到目标自身的处理器. 
2. 目标阶段
目标阶段是三个阶段中最简单的, 当捕捉阶段完成后, 浏览器会触发目标元素上已添加的事件类型监听器.
3. 冒泡
完成目标阶段之后, 浏览器开始转而沿着上级元素链朝body元素前进. 在沿途的每个元素上,浏览器都会检查是否存在针对该事件类型但没有启动捕捉的监听器, 这就是所谓的事件冒泡.

> 注: 上级元素的事件处理器可以通过对Event对象调用`stopPropagation`或`stopImmediatePropagation`函数阻止事件流向目标, 这两者的区别是前者会确保调用当前元素上注册的所有事件监听器, 而后者会忽略任何未触发的监听器.

举个栗子:

```
<script type="text/javascript">
			var banana = document.getElementById("banana");
			var textblock = document.getElementById("block1");

			banana.addEventListener("mouseover", handleMouseEvent);
			banana.addEventListener("mouseout", handleMouseEvent);
			textblock.addEventListener("mouseover", handleDescendantEvent, true);
			textblock.addEventListener("mouseout", handleDescendantEvent, true);

			function handleDescendantEvent(e) {
				console.log("handleDescendantEvent" + "," + e.type + "," + e.eventPhase);
				if (e.type == "mouseover" && e.eventPhase == Event.CAPTURING_PHASE) {
					e.target.style.border = "thick solid red";
					e.currentTarget.style.border = "thick double black";
				}else if (e.type == "mouseout" && e.eventPhase == Event.CAPTURING_PHASE) {
					e.target.style.removeProperty("border");
					e.currentTarget.style.removeProperty("border");
				}
			}

			function handleMouseEvent(e) {
				console.log("handleMouseEvent" + "," + e.type + "," + e.eventPhase);
				if (e.type == "mouseover") {
					e.target.style.background = "red";
					e.target.style.color = "black";
				}else if (e.type == "mouseout") {
					e.target.style.removeProperty("background");
					e.target.style.removeProperty("color");
				}
			}
		</script>
```
html中仅为一p元素,不多写了;

首先要说一下 Event.eventPhase属性的值

| 名称      |    说明   |   数值   |
| :-------- | :--------| :--------:|
| CAPTURING_PHASE    |  此事件处于捕捉阶段  |1|
| AT_TARGET    |  此事件处于目标阶段  |2|
| BUBBLING_PHASE    |  此事件处于冒泡阶段  |3|

上述代码通过修改addEventListener()函数的第三个参数告诉浏览器是否想让p元素在捕捉阶段接收后代元素的事件.如果为true,打印结果为:
![Alt text](<../../attachment/:K0M6-XTIE@-G-QSIDX-%60X.png>)
如果为false,打印结果为:
![Alt text](<../../attachment/:F@WVWOWL8NOIE8XWFTJOESE.png>)
从这两个结果中可以的出这样的结论:
> - 父元素的事件处理器总是先于子元素被调用, 如果有的话
> - 父元素的事件处理器被再次调用在事件捕捉阶段还是冒泡阶段,取决于addEventListener()函数的第三个参数的布尔值.

#### 使用可撤销事件
有些事件定义了一种默认行为, 会在事件被触发时执行. 举个例子, a元素click事件的默认行为是浏览器会载入href属性所指定的URL的内容. 当某一事件拥有默认行为时, 它的cancelable属性就会使true. 你可以调用`preventDefault函数`来阻止默认行为的执行.

#### Window对象的事件

| 名称       |   说明   | 
| :-------- | :--------| 
|  onabort  |  在文档或资源加载过程被终止时触发  | 
|  onafterprint  |  在已调用Window.print()方法,但尚未给用户提供打印选项时触发  | 
|  onbeforeprint  |  在用户完成文档打印后触发  | 
|  onerror  |  在文档或资源的加载发生错误时触发  | 
|  onhashchange  |  在锚部分发生变化时触发  | 
|  onload  |  在文档或资源加载完成时触发  | 
|  onpopstate  |  触发后提供一个关联浏览器历史的状态对象  | 
|  onresize  |  在窗口缩放时触发  | 
|  onunload  |  在文档从窗口或浏览器中卸载时触发  | 

#### 鼠标相关事件
| 名称       |   说明   | 
| :-------- | :--------| 
|  click  |  在点击并释放鼠标键时触发  |
|  dblclick  |  在两次点击并释放鼠标键时触发  |
|  mousedown  |  在点击鼠标键时触发  |
|  mouseenter  |  在光标移入元素或某个后代元素所占据的屏幕区域时触发  |
|  mouseleave  |  在光标移出元素或某个后代元素所占据的屏幕区域时触发  |
|  mousemove  |  当光标在元素上移动时触发  |
|  mouseout  |  与mouseleave基本相同, 除了当光标仍然在某个后代元素上时也会触发  |
|  mouseover  |  与mouseenter基本相同, 除了当光标仍然在某个后代元素上时也会触发  |
|  mouseup  |  在释放鼠标键时触发  |

当某个鼠标事件被触发时, 浏览器会指派一个MouseEvent对象. 它是一个Event对象, 但带有以下额外属性和方法.
| 名称       |   说明   |   返回  |
| :-------- | :--------| :-------:|
|  button  |  标明点击的是那个键. 0是鼠标主键, 1是中键, 2是次键/右键  |   数值 |
|  altkey  |  如果在事件触发时按下了alt/option键则返回true  |  布尔值  |
|  clientX  |  返回事件触发时鼠标相对于元素视口的X坐标  |  数值  |
|  clientY  |  返回事件触发时鼠标相对于元素视口的Y坐标  |  数值  |
|  screenX  |  返回事件触发时鼠标相对于屏幕坐标系的X坐标  |  数值  |
|  screenY  |  返回事件触发时鼠标相对于屏幕坐标系的Y坐标  |  数值  |
|  shiftKey  |  如果在事件触发时按下了Shift键则返回true  |  布尔值  |
|  ctrlKey  |  如果在事件触发时按下了ctrl键则返回true  |  布尔值  |

#### 键盘焦点事件
| 名称       |   说明   | 
| :-------- | :--------| 
|  blur  |  在元素失去焦点时触发  |
|  focus  |  在元素获得焦点时触发  |
|  focusin  |  在元素即将获得焦点时触发  |
|  focusout  |  在元素即将失去焦点时触发  |

keyboardEvent对象代表了这些事件, 相对于Event对象的核心功能, 它还增加了以下属性:
| 名称       |   说明   |   返回  |
| :-------- | :--------| :-------:|
|  char  |  返回按键代表的字符  |  字符串  |
|  key  |  返回所按的键  |  字符串  |
|  ctrlKey  |  如果在按键时Ctrl键处于按下状态则返回true  |  布尔值  |
|  shiftKey  |  如果在按键时Shift键处于按下状态则返回true  |  布尔值  |
|  altKey  |  如果在按键时Alt键处于按下状态则返回true  |  布尔值  |
|  repeat  |  如果该键一直处于按下状态则返回true  |  布尔值  |

#### 表单事件
| 名称       |   说明   | 
| :-------- | :--------| 
|  submit  |  在表单提交时触发  |
|  reset  |  在表单重置时触发  |
