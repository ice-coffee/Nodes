[toc]

`APT（Annotation Processing Tool）`它是 `Java` 编译期注解处理器，它可以让开发人员在编译期对注解进行处理，通过APT可以获取到注解和被注解对象的相关信息，并根据这些信息在编译期按我们的需求生成java代码模板或者配置文件（比如SPI文件或者spring.fatories）等。APT获取注解及生成代码都是在代码编译时候完成的，相比反射在运行时处理注解大大提高了程序性能。

## 注解处理器工作流程
![3e4e818ef66f76ef4ac2c74c6478c9f4.png](<../../attachment/953C7FC9-2DD7-4CE0-A8A7-251C61E0581F.png>)

如上图所示，**`Java 源代码的编译过程可分为三个步骤：`**

1. 将源文件解析为抽象语法树；
2. 调用已注册的注解处理器；
3. 生成字节码。

如果在第 2 步调用注解处理器过程中生成了新的源文件，那么编译器将重复第 1、2 步，解析并且处理新生成的源文件。每次重复我们称之为一轮（Round）。也就是说，第一轮解析、处理的是输入至编译器中的已有源文件。如果注解处理器生成了新的源文件，则开始第二轮、第三轮，解析并且处理这些新生成的源文件。当注解处理器不再生成新的源文件，编译进入最后一轮，并最终进入生成字节码的第 3 步。

**`APT的工作流程包括以下阶段：`**

1. 扫描阶段：编译器会扫描源代码，找出带有特定注解的元素。

    * 编译器检查源码中所有的注解元素，如果没有则整个流程直接结束，否则继续
    * 编译器检查开发者注册了哪些AnnotationProcessor，如果没有则整个流程直接结束，否则继续
    * 编译器拿着所有收集到的注解元素去问Processor们进行认领
    * 当所有注解类型被认领完毕，此阶段结束，进入下一阶段
    * 若仍有注解类型没有被认领，但已经没有多余的处理器了，同样此阶段结束，进入下一阶段


2. 处理阶段：注解处理器将被触发，对扫描到的元素进行处理，并生成新的源代码或资源文件。

    * 编译器将从源码中收集到的注解元素作为输入开启一轮处理
    * 所有开发者注册的注解处理器将排好队串行处理编译器传入的注解元素，在这里需要注意的是注解处理器之间并没有明确的排序规则，可以认为是乱序的，而且每一次可能不一样，不可依赖
    * 若某个注解处理器在处理过程中生产出了新的源码文件，那么此轮处理会立即结束。新生成的源码文件及目前还没处理完的源码元素加在一起作为下一轮的输入（若新生成的源码中没有注解元素，其实是没有意义的）
    * 新一轮处理中，所有的注解处理器依然会被触发，所以需要开发者做好识别，不要产生重复生成新文件的BUG
    * 直到所有注解处理器串行处理后不再产生新文件，处理阶段结束


3. 生成阶段：生成的代码或资源会被编译器包含在编译结果中，最终生成可执行的应用程序。

## 自定义注解处理器

### 实现流程
1、创建 `Java Library` 模块，在 `Android` 模块中无法继承 `AbstractProcessor`。
2、创建自定义注解处理器继承 `AbstractProcessor`；
3、实现抽象方法；
4、注册自定义注解处理器。

### AbstractProcessor 解析
注解处理器示例如下：
```java
package com.example;

public class MyProcessor extends AbstractProcessor {

    @Override
    public synchronized void init(ProcessingEnvironment env){ }

    @Override
    public boolean process(Set<? extends TypeElement> annoations, RoundEnvironment env) { }

    @Override
    public Set<String> getSupportedAnnotationTypes() { }

    @Override
    public SourceVersion getSupportedSourceVersion() { }

}
```

| 方法 | 说明 |
| --- | --- |
| `init(ProcessingEnvironment env)` | 注解处理器初始化时调用，用于生成 `Elements`, `Types` 和 `Filer` 等工具类 |
| `process(Set<? extends TypeElement> annoations, RoundEnvironment env)` | 相当于每个处理器的主函数main()。你在这里写你的扫描、评估和处理注解的代码，以及生成Java文件 |
| `getSupportedAnnotationTypes()` | 用于指定这个注解处理器是注册给哪个注解的 |
| `getSupportedSourceVersion()` | 用来指定你使用的Java版本。通常这里返回 `SourceVersion.latestSupported()` |

在 `Java 7` 中，你也可以使用注解来代替 `getSupportedAnnotationTypes()` 和 `getSupportedSourceVersion()`，像这样：

```java
@SupportedSourceVersion(SourceVersion.latestSupported())
@SupportedAnnotationTypes({
   // 合法注解全名的集合
 })
public class MyProcessor extends AbstractProcessor {

    @Override
    public synchronized void init(ProcessingEnvironment env){ }

    @Override
    public boolean process(Set<? extends TypeElement> annoations, RoundEnvironment env) { }
}
```

因为兼容的原因，特别是针对 `Android` 平台不建议使用注解的方式。

#### init
在 `init(ProcessingEnvironment env)` 中，`ProcessingEnvironment` 的主要功能如下：

| 函数 | 返回值 | 说明 |
| --- | --- | --- |
| `getElementUtils()` | `Elements` | 工具类，用于处理 `Element` 对象 |
| `getTypeUtils()` | `Types` | 工具类，用于处理 `TypeMirror` 对象 |
| `getFiler()` | `Filer` | 正如这个名字所示，使用 `Filer` 你可以创建文件 |
| `getMessager()` | `Messager` | 报告错误、警告和其他消息 |

**`Elements`**：可以说注解处理器中主要工作就是操作 `Element`。通过 `Element` 可以得到目标元素的数据类型、名称等信息（可以类比于反射），用于后续生成代码等操作。

**`Types`**：`TypeMirror` 代表数据类型，它是 `Element` 的一个属性。

下面是 `Element` 和 `TypeMirror` 的继承关系，可以看到它们有相同的父类 `AnnotatedConstruct`。这说明 `Element` 和 `TypeMirror` 两者都是可以被注解。

![faede0e5956cecf42612d3b666b69879.png](<../../attachment/AnnotatedConstruct.png>)

**`Messager`**：提供给注解处理器一个报告错误、警告以及提示信息的途径。它不是注解处理器开发者的日志工具，而是用来写一些信息给使用此注解器的第三方开发者的。示例如下：

```java
public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
    for (Element annotatedElement : roundEnv.getElementsAnnotatedWith(Factory.class)) {
      // 检查被注解为@Factory的元素是否是一个类
      if (annotatedElement.getKind() != ElementKind.CLASS) {
        error(annotatedElement, "Only classes can be annotated with @%s",
            Factory.class.getSimpleName());
        return true; // 退出处理
      }
      ...
    }

private void error(Element e, String msg, Object... args) {  
    messager.printMessage(
        Diagnostic.Kind.ERROR,
        String.format(msg, args),
        e);
  }
}
```

#### process

`Java` 官方文档给出的注解处理过程的定义：**`注解处理过程是一个有序的循环过程。在每次循环中，一个处理器可能被要求去处理那些在上一次循环中产生的源文件和类文件中的注解`**。

```java
/**
 * process 是注解处理器核心方法，注解的处理和生成代码或者配置资源都是在这个方法中完成。每次循环都会调用process方法。
 * @param annotations 请求处理注解类型的集合（也就是我们通过重写getSupportedAnnotationTypes方法所指定的注解类型）；
 * @param roundEnv 有关当前和上一次循环的信息的环境；
 * @return 返回值表示这些注解是否由此 Processor 声明，如果返回 true，则这些注解已声明并且不要求后续 Processor 处理它们；如果返回 false，则这些注解未声明并且可能要求后续 Processor 处理它们。
 */
public abstract boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv);
```

**`RoundEnvironment`**：

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `processingOver()` | boolean | 如果循环处理完成返回true，否则返回false |
| `errorRaised()` | boolean |  |
| `getRootElements()` | `Set<? extends Element>` | 返回前一轮生成的注释处理的根元素 |
| `getElementsAnnotatedWith(TypeElement a)` | `Set<? extends Element>` | 获取被特定注解标记的元素 |
| `getElementsAnnotatedWith(Class<? extends Annotation> a)` | `Set<? extends Element>` | 获取被特定注解标记的元素 |

### 注册注解处理器

使用 `AutoService` 注册注解处理器：
[Java 进阶 - SPI](https://app.yinxiang.com/shard/s58/nl/10744683/833b22a3-6dac-4eaf-a2bf-9f55f25f09db/)

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/java_annotation_processor.png)

## 参考
[Java 注解处理器 \(Annotation Processor\)](https://www.jianshu.com/p/0aaa68263892)
[Java注解处理器APT](https://juejin.cn/post/7268945005749354552)
