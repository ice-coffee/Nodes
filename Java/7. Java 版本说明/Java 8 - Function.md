[toc]

### 概述
`Java 8` 引入的 `java.util.function` 包含了许多函数式接口，这些接口是 `lambda` 表达式和方法引用的基础。

`function` 中主要包含如下种类型接口：

* `xxxFunction`：接收参数，有返回值
* `xxxConsumer`：接收参数，没有返回值
* `xxxSupplier`：不接收参数，有返回值
* `xxxPredicate`：接收参数，返回布尔值
* `xxxOperator`：`Function` 接口的特殊化接口。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/java_funcation.png)

### 使用场景

* 替代简单的回调函数

### 示例

```java
import java.util.function.*;

publicclassFunctionExamples {
    publicstaticvoidmain(String[] args) {
        // Function example
        Function<String, Integer> stringLength = s -> s.length();
        System.out.println("Length of 'hello': " + stringLength.apply("hello"));

        // BiFunction example
        BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
        System.out.println("Sum of 5 and 3: " + add.apply(5, 3));

        // Consumer example
        Consumer<String> print = s -> System.out.println(s);
        print.accept("Hello, world!");

        // Supplier example
        Supplier<Double> randomSupplier = () -> Math.random();
        System.out.println("Random number: " + randomSupplier.get());

        // Predicate example
        Predicate<Integer> isEven = n -> n % 2 == 0;
        System.out.println("Is 4 even? " + isEven.test(4));

        // UnaryOperator example
        UnaryOperator<String> toUpperCase = s -> s.toUpperCase();
        System.out.println("Uppercase of 'hello': " + toUpperCase.apply("hello"));

        // BinaryOperator example
        BinaryOperator<Integer> multiply = (a, b) -> a * b;
        System.out.println("Product of 5 and 3: " + multiply.apply(5, 3));
    }
}
```

### 扩展

#### @FunctionalInterface
上面提到的 `Function` 等接口都是函数式接口 `@FunctionalInterface` 注解的作用是标识函数式接口。

函数式接口首先必须是一个接口，且接口内只能存在一个抽象方法（允许有默认方法、静态方法）。实际上编译器会将任何符合函数式接口定义的视为函数式接口而不管是否存在 `@FunctionalInterface` 注解

函数式接口可以使用 `lambda` 表达式、方法引用或构造函数引用创建接口实例。

```java
public interface Dog {
    void eat(String food);
}
```

```java
Dog dog = food -> Log.e("TAG", food);
dog.eat("骨头");
```

#### Callable
`Java 5` 引入了 `Callable`：
```java
@FunctionalInterface
public interface Callable<V> {
    V call() throws Exception;
}
```
