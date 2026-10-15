## 函数表达式
定义函数表达式的方式：

1. 函数声明
```markdown
    function functionName(arg0, arg1, arg2) {
      // body...
    }
```

2. 函数表达式
```markdown
    var functionName = function(arg0, arg1, arg2) {
      // body...
    }
```

> 区别：{函数提升}，使用函数声明定义函数在执行代码之前会先读取函数声明，这就意味着可以把函数声明放在调用它的语句后面。函数表达式没有此特点。