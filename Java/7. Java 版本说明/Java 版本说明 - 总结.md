[toc]

### 参考

[Java Version Release Notes](https://www.oracle.com/java/technologies/javase/jdk-relnotes-index.html)

[Java 新特性概述](https://pdai.tech/md/java/java8up/java-8-up-overview.html)

### Java 8.0
#### 1. 接口中可以存在静态方法和默认方法

```java
interface MyInterface {
    // 抽象方法
    void abstractMethod();

    // 默认方法
    default void defaultMethod() {
        System.out.println("This is a default method in the interface.");
    }
    
    // 静态方法
    static void staticMethod() {
        System.out.println("This is a static method in the interface.");
    }
}
```

#### 2. Function 接口

#### 3. Stream API

#### 4. Optional

#### 5. Lambda 表达式

#### 6. StampedLock

### Java 9
#### 1. 允许在接口中使用私有方法

```java
public interface SayHi {
    private String buildMessage() {
        return "Hello";
    }
    void sayHi(final String message);
    default void sayHi() {
        sayHi(buildMessage());
    }
}
```

#### 2. 变量句柄（`Var Handle`）



### Java 10
#### 1. 局部变量类型推断（`var`）
引入 `var`，允许开发人员省略通常不必要的局部变量类型初始化声明。

```java
// ArrayList<String>
var list = new ArrayList<String>(); 
// Stream<String>
var stream = list.stream(); 
```

> 注意：为保证代码的可读性不建议使用。
