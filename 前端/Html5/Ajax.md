## Ajax
Ajax可以让你能向服务器异步发送和接收数据, 然后用JavaScript解析. Ajax是Asynchronous JavaScript and XML的缩写.

### Ajax的简单使用
首先看下面的例子:
	
```
<script>
	function handleButtonPress(e) {
		//创建新的XMLHttpRequest对象
		var httpRequest = new XMLHttpRequest();
		//设置事件处理器
		httprequest.onreadystatechange = handleResponse;
		//设置请求方式和请求路径
		httprequest.open("POST", "***.html");
		//发送请求
		httprequest.send();
	}

	//异步事件处理器
	function handleResponse(e) {
		if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
			document.getElementById("***").innerHTML = e.target.responseText;
		}
	}
</script>
```

由以上代码可知Ajax的简单操作流程如下:
1. 创建新的XMLHttpRequest对象
2. 设置事件处理器
3. 设置请求方式和请求路径
4. 发送请求

#### 处理响应
一旦脚本调用了send方法, 浏览器就会在后台发送请求到服务器. 请求会在后台进行处理, 当readystatechange 事件触发后, 浏览器会把一个Event对象传递给指定的处理函数. Event对象的target属性则会被设为与此事件关联的XMLHttpRequest. 可以通过XMLHttpRequest.readState属性来判断当前异步请求阶段.

| 值      |   数值   |   说明   |
| :-------- | :--------:| :------: |
|  UNSENT   |  0  |  已创建XMLHttpRequest对象  |
|  OPENED   |  1  |  已调用open方法  |
|  HEADERS_RECEIVED   |  2  |  已收到服务器相应的标头  |
|  LOADING   |  3  |  已收到服务器相应  |
|  DONE   |  4  |  相应完成或已失败  |

DONE状态并不意味着请求成功, 它只代表请求已完成. 只有结合`readyState和status`属性的值才能够确定某个请求的结果(参看上方代码).

#### 处理Opear中的响应
Opera浏览器的XMLHttpRequest标准实现方式与其他浏览器相比有一下几点差别
1. Opera在触发readystatechange事件时不会生成一个Event对象. 这就意味着必须把XMLHttpRequest对象指派给一个全局变量, 这样才能在以后引用它. 这看上去不是什么大问题, 但如果用户在请求处理过程中按下按钮, 全局变量就会被指派给一个新的XMLHttpRequest对象, 你就无法再与原来那个请求交互了.
2. Opera没有在XMLHttpRequest对象上定义就绪状态常量, 这就意味着必须用数值来对比readyState属性的值.

具体代码如下 :
```
<script>

	var httpRequest;
	
	function handleButtonPress(e) {
		//创建新的XMLHttpRequest对象
		httpRequest = new XMLHttpRequest();
		//设置事件处理器
		httprequest.onreadystatechange = handleResponse;
		//设置请求方式和请求路径
		httprequest.open("POST", "***.html");
		//发送请求
		httprequest.send();
	}

	//异步事件处理器
	function handleResponse() {
		if (httpRequest.readyState == 4 && httpRequest.status == 200) {
			document.getElementById("***").innerHTML = e.target.responseText;
		}
	}
</script>
```

### Ajax事件
下面开始深入了解XMLHttpRequest对象支持的功能以及如何在你的请求中使用它们.  下表示XMLHttpRequest对象定义的事件.
| 名称      |   说明   |   事件类型   |
| :-------- | :--------:| :------: |
|  abort  |  在请求被终止时触发  |  ProgressEvent  |
|  error  |  在请求失败时触发  |  ProgressEvent  |
|  load  |  在请求成功完成时触发  |  ProgressEvent  |
|  loadend  |  在请求已完成时触发, 无论成功还是发生错误  |  ProgressEvent  |
|  loadstart  |  在请求开始时触发  |  ProgressEvent  |
|  progress  |  触发以提示请求的进度  |  ProgressEvent  |
|  readystatechange  |  在请求生命周期的不同阶段触发  |  Event  |
|  timeout  |  如果请求超时则触发  |  ProgressEvent  |

由上表可以看出事件类型除了Event还有ProgressEvent, 它定义了Event对象的所有成员, 并增加了下表中的这些成员:
| 名称      |   说明   |   事件类型   |
| :-------- | :--------:| :------: |
|  lengthComputable  |  如果能够计算数据流的总长度则返回true  |  布尔值  |
|  loaded  |  返回当前已载入的数据量  |  数值  |
|  total  |  返回可用的数据总量  |  数值  |

#### 处理错误
1. 处理设置错误
使用try...catch...语句
2. 处理请求错误
注册error事件
3. 处理应用程序错误
判断status是否等于200

### 获取和设置标头
XMLHttpRequest对象让你可以设置发送给服务器的请求标头和读取服务器相应里的标头, 相关方法如下表:
| 方法      |   说明   |   返回   |
| :-------- | :--------:| :------: |
|  setRequestHeader(header, value)  |  用指定值设置标头  |  void  |
|  getRequestHeader(head)  |  获取指定标头的值  |  字符串  |
|  getAllResponseHeader()  |  以单个字符串的形式获取所有标头   |  字符串  |
一般情况下, 并不需要我们添加或修改Ajax请求里的标头. 浏览器知道需要发送什么, 服务器也知道如何响应.

### 终止请求
XMLHttpRequest对象定义了一个让你可以终止请求的方法.
| 方法      |   说明   |   返回   |
| :-------- | :--------:| :------: |
|  abort()  |  中断当前请求  |  void  |

### 发送表单数据

#### 默认表单提交

```
<!DOCTYPE HTML>
<html>
	<head>Example</head>
	<body>
		<form id="fruitform" method="post" action="******">
			<div class="table">
				<div class="row">
					<div class="cell label">Bananas:</div>
					<div class="cell"><input name="bananas" value="2" /></div>
				</div>
				<div class="row">
					<div class="cell label">Apples:</div>
					<div class="cell"><input name="apples" value="2" /></div>
				</div>
				<div class="row">
					<div class="cell label">Cherries:</div>
					<div class="cell"><input name="cherries" value="2" /></div>
				</div>
				<div class="row">
					<div class="cell label">Total:</div>
					<div id="results" class="cell">0 items</div>
				</div>
				<button id="submit" type="submit">Submit Form</button>
			</div>
		</form>
	</body>
</html>
```
配置表单属性method设置提交方式, action设置指定服务器地址, 通过submit按钮的默认操作, 提交表单数据到指定服务器

#### 自己收集表单数据并提交
Html5代码不变, 通过JS来监听和操作提交按钮的点击事件, 收集表单数据然后通过Ajax提交

```
<script>
	document.getElementById("submit").onclick = handleButtonPress;

	var httpRequest;

	function handleButtonPress(e) {
		e.preventDefault();

		var form = document.getElementById("fruitform");

		var formData = "";
		var inputElements = document.getElementsByTagName("input");
		for (var i = 0; i < inputElements.length; i++) {
			formData += inputElements[i].name + "=" + inputElements[i].value + "&";
		}

		//创建新的XMLHttpRequest对象
		var httpRequest = new XMLHttpRequest();
		//设置事件处理器
		httpRequest.onreadystatechange = handleResponse;
		//设置请求方式和请求路径
		httpRequest.open("POST", form.action);
		//由于Ajax默认编码和表单数据默认编码不一致, 所以需要添加标头告诉服务器处理的是表单数据
		httpRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
		//将字符串作为参数发送到服务器
		httpRequest.send(formData);
	}

	//异步事件处理器
	function handleResponse(e) {
		if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
			document.getElementById("***").innerHTML = e.target.responseText;
		}
	}
</script>
```

这段js代码中需要注意两点:
1. 在提交按钮点击事件的处理函数开头调用preventDefault方法防止submit按钮的默认操作, 而且这句代码必须放到开头, 这样就能防止代码出错后导致执行终止并启动默认行为
2. 由于Ajax默认编码和表单数据默认编码不一致, 所以需要添加标头告诉服务器处理的是表单数据

#### 使用FormData对象发送表单数据
> 在使用FormData时需要查看浏览器的支持情况

```
<script>
	document.getElementById("submit").onclick = handleButtonPress;

	var httpRequest;

	function handleButtonPress(e) {
		e.preventDefault();

		var form = document.getElementById("fruitform");

		var formData = new FormData(form);
		
		//创建新的XMLHttpRequest对象
		var httpRequest = new XMLHttpRequest();
		//设置事件处理器
		httpRequest.onreadystatechange = handleResponse;
		//设置请求方式和请求路径
		httpRequest.open("POST", form.action);
		//将字符串作为参数发送到服务器
		httpRequest.send(formData);
	}

	//异步事件处理器
	function handleResponse(e) {
		if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
			document.getElementById("***").innerHTML = e.target.responseText;
		}
	}
</script>
```
注意, 如果使用FormData对象, 数据总是会被编码为`multipart/form-data`, 所以不用再设置标头了.
FormData对象定义了一个方法, 下表介绍了这个方法:

| 方法      |   说明   |   返回   |
| :-------- | :--------:| :------: |
|  append(name, value)  |  给数据集附加名称和值  |  void  |

### 发送JSON数据
先来看代码:

```
<script>
	document.getElementById("submit").onclick = handleButtonPress;

	var httpRequest;

	function handleButtonPress(e) {
		e.preventDefault();

		var form = document.getElementById("fruitform");

		var formData = "";
		var inputElements = document.getElementsByTagName("input");
		for (var i = 0; i < inputElements.length; i++) {
			formData += inputElements[i].name + "=" + inputElements[i].value + "&";
		}

		//创建新的XMLHttpRequest对象
		var httpRequest = new XMLHttpRequest();
		//设置事件处理器
		httpRequest.onreadystatechange = handleResponse;
		//设置请求方式和请求路径
		httpRequest.open("POST", form.action);
		//告诉浏览器处理的数据是JSON格式的
		httpRequest.setRequestHeader('Content-Type', 'application/json');
		//发送请求
		httpRequest.send(JSON.stringify(formData));
	}

	//异步事件处理器
	function handleResponse(e) {
		if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
			document.getElementById("***").innerHTML = e.target.responseText;
		}
	}
</script>
```
和之前的代码基本一致, 但需要将请求的标头设置为application/json, 还需要使用JSON对象对数据进行JSON编码. JSON对象提供了如下两个方法:
| 方法      |   说明   |   返回   |
| :-------- | :--------:| :------: |
|  parse(json)  |  解析用JSON编码的字符串并创建一个对象  |  对象  |
|  stringify(object)  |  为指定对象创建用JSON编码的数据表示  |  字符串  |

### 发送文件
可以使用FormData对象和type属性为file的input元素向服务器发送文件
代码如下:

```
<!DOCTYPE HTML>
<html>
<head>Example</head>
<body>
    <form id="fruitform" method="post" action="*****">
        <div class="row">
            <div class="cell label">File:</div>
            <div class="cell">
                <input type="file" name="file" />
            </div>
            <button id="submit" type="submit">Submit Form</button>
        </div>
    </form>
    <script>
	    document.getElementById("submit").onclick = handleButtonPress;

	    var httpRequest;

	    function handleButtonPress(e) {
	        e.preventDefault();

	        var form = document.getElementById("fruitform");

	        var formData = new Formdata(form);

	        //创建新的XMLHttpRequest对象
	        var httpRequest = new XMLHttpRequest();
	        //设置事件处理器
	        httpRequest.onreadystatechange = handleResponse;
	        //设置请求方式和请求路径
	        httpRequest.open("POST", form.action);
	        //发送请求
	        httpRequest.send(formData);
	    }

	    //异步事件处理器
	    function handleResponse(e) {
	        if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
	            document.getElementById("***").innerHTML = e.target.responseText;
	        }
	    }
    </script>
</body>
</html>
```

### 追踪上传进度
可以通过使用XMLHttpRequest对象的upload属性追踪数据发送到服务器的进度;
| 方法      |   说明   |   返回   |
| :-------- | :--------:| :------: |
|  upload  |  返回一个可用于监控进度的对象  |  XMLHttpRequestUpload  |

通过读取XMLHttpRequest对象的upload属性获得了一个XMLHttpRequestUpload对象,并注册函数以响应progress和load事件

```
<!DOCTYPE HTML>
<html>
<head>Example</head>
<body>
    <form id="fruitform" method="post" action="*****">
        <div class="row">
            <div class="cell label">File:</div>
            <div class="cell">
                <input type="file" name="file" />
            </div>
        </div>
        <div class="row">
           	<div class="cell label">Total:</div>
           	<div class="cell"><progress id="progress" value="0"/></div>
        </div>

        <button id="submit" type="submit">Submit Form</button>
    </form>
    <script>
	    document.getElementById("submit").onclick = handleButtonPress;

	    var httpRequest;

	    function handleButtonPress(e) {
	        e.preventDefault();

	        var form = document.getElementById("fruitform");
	        var progress = document.getElementById("progress");

	        var formData = new Formdata(form);

	        //创建新的XMLHttpRequest对象
	        var httpRequest = new XMLHttpRequest();

	        var upload = httpRequest.upload;
	        upload.onprogress = function(e) {
	        	progress.max = e.total;
	        	progress.value = e.loaded;
	        }
	        upload.onload = function(e) {
	        	progress.max = 1;
	        	progress.value = 1;
	        }
	        //设置事件处理器
	        httpRequest.onreadystatechange = handleResponse;
	        //设置请求方式和请求路径
	        httpRequest.open("POST", form.action);
	        //发送请求
	        httpRequest.send(formData);
	    }

	    //异步事件处理器
	    function handleResponse(e) {
	        if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
	            document.getElementById("***").innerHTML = e.target.responseText;
	        }
	    }
    </script>
</body>
</html>
```

### 处理不同内容类型

#### 接收HTML片段
如果你有服务器的控制权, 你可以确保Content-Type标头被设置成"text/html", 但是如果服务器归类数据的方式不是你想要的, 那么你可以使用`overrideMimeType`方法自己指定数据类型.
```
function handleResponse(e) {
	        if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
	        	e.tareet.overrideMimeType("text/html");
	            document.getElementById("***").innerHTML = e.target.responseText;
	        }
	    }
```

#### 接收XML片段
```
function handleResponse(e) {
	        if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
	        	e.tareet.overrideMimeType("application/xml");
	        	var xmlDoc = e.target.responseXML;
	        	var val = xmlDoc.getElementsByTagName("***")[0].getAttribute("***");
	            document.getElementById("***").innerHTML = val;
	        }
	    }
```
在使用XML片段是, 必须明确告诉浏览器你正在处理XML, 否则XMLHttpRequest对象不会正确支持responseXML属性. responseXML属性是responseText的替代属性, 它解析接收到的XML, 然后将其作为一个Document对象返回. 之后你就可以针对HTML的DOM功能在XML中导航了, 如上述代码.
#### 接收JSON片段
```
function handleResponse(e) {
	        if (e.target.readyState == XMLHttpRequest.DONE && e.target.status == 200) {
	        	var data = JSON.parse(e.target.responseText);
	            document.getElementById("***").innerHTML = data.bananas;
	        }
	    }
```
数据模型:
{"bananas":"3", "apples":"4"}
JSON数据处理可将其先转化为JSON对象, 然后再根据KEY值获取VALUE.
