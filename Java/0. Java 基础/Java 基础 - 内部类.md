### 内部类隐式持有外部类对象
``` java
public class Test {
    class Inner {
    }
}
```

编译后，使用 `AS` 查看：

``` java
class Test$Inner {
    Test$Inner(Test var1) {
        this.this$0 = var1;
    }
}
```

结论：非静态内部类隐式持有外部类对象。

变化一：静态内部类

``` java
public class Test {
    static class Inner {
    }
}
```

反编译后：

``` java
class Test$Inner {
    Test$Inner() {
    }
}
```

结论：静态内部类和外部类没有关系，且无法访问外部类的非静态方法和变量。

变化二：显示声明无参构造函数

``` java
public class Test {
    class Inner {
        public Inner() {

        }
    }
}
```

反编译后：

``` java
class Test$Inner {
    public Test$Inner(Test var1) {
        this.this$0 = var1;
    }
}
```

猜测：无参构造函数被默认插入外部类对象。

证明：

``` java
public class Test {
    class Inner {
        public Inner(int num) {
        }
    }
}
```

编译后：

``` java
class Test$Inner {
    public Test$Inner(Test var1, int var2) {
        this.this$0 = var1;
    }
}
```

结论：内部类会在构造函数的首位插入外部类的对象，外部类对象隐式持有，不可见。
