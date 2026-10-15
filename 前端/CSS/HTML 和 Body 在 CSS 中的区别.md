## HTML 和 Body 在 CSS 中的区别
在 HTML 文档中，:root 选择符对应 `<html>` 元素。

```
:root {
}

html {
}
```

需要注意的是，:root 选择符（伪类）的优先级大于 html 选择符：(0, 0, 1, 0) vs (0, 0, 0, 1)。

### 哪些全局样式应该应用在 HTML
- 使用 rem 时

```
html {
  font-size: 62.5%;
}
```

- 古怪的 background-color

CSS 中有一些古怪的行为，将 background-color 应用到 <body> 以后，即便 <body> 里的元素没有占满视口，背景颜色也会蔓延到整个视口。

给 html 设置 background-color 可以解决这个问题。

- height: 100%

> 如果 `<body>` 及其子元素的高度需要设置为窗口高度时，`<html>` 元素上也需要添加：

```
html,
body {
  height: 100%;
}
```

### 哪些全局样式应该应用在 Body
早期的规范中，`<body>` 有以下行内属性：

- background
- bgcolor
- marginbottom
- marginleft
- marginright
- margintop
- text

这些行内属性对应的 CSS 样式应该应用在 `<body>`。

| Inline Attribute      |     CSS Property |
| :--------: | :--------:|
|background|	background|
|bgcolor|	background background-color|
|marginbottom|	margin-bottom|
|marginleft|	margin-left|
|marginright	|margin-right|
|margintop|	margin-top|
|text|	font|
