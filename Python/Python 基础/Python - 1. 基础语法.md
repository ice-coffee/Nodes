### 作用域
`Python` 中只有模块（`module`），类（`class`）以及函数（`def`、`lambda`）才会引入新的作用域，其它的代码块（如 `if/elif/else/`、`try/except`、`for/while`等）是不会引入新的作用域的，也就是说这些语句内定义的变量，外部也可以访问。

#### 作用域规则 - LEGB

* `L - Local`：最内层，包含局部变量，比如一个函数/方法内部。
* `E - Enclosing`：包含了非局部(non-local)也非全局(non-global)的变量。比如两个嵌套函数，一个函数（或类） A 里面又包含了一个函数 B ，那么对于 B 中的名称来说 A 中的作用域就为 `nonlocal`。
* `G - Global`：当前脚本的最外层，比如当前模块的全局变量。
* `B - Built-in`： 包含了内建的变量/关键字等，最后被搜索。

简单来说就是 **使用** 变量时会一级一级查找。

但是 **赋值** 操作会影响变量所属作用的判断，如下：

```python
#!/usr/bin/python3
 
a = 10
def test():
    # local variable 'a' referenced before assignment
    a = a + 1
test()
```

这里识别函数内部的变量 `a` 是在局部新定义的变量而不是全局变量。
因为在 `Python` 的语法中无法区分定义变量和修改变量，所以 `Python` 在遇到函数等新的作用域时会扫描作用域内是否有赋值操作，如果有就将参数标记为局部变量。

所以如果在新的作用域内修改全局变量时，需要使用到 `global`、`nonlocal` 关键字。当然如果只是访问就不需要了。
