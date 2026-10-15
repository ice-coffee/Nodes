[toc]

`Elements` 接口是 `Java` 编译器提供的一个工具类，用于在注解处理器中处理程序元素（`Element` 对象）。它提供了一系列方法，用于获取和操作程序元素的信息。常用方法如下：

| 方法 | 说明 |
| --- | --- |
| `PackageElement getPackageElement(CharSequence name)` | 根据名称获取包元素 |
| `TypeElement getTypeElement(CharSequence name)` | 根据名称获取类或接口元素 |
| `ExecutableElement getPackageOf(Element type)` | 获取指定类型元素的包元素 |
| `boolean isDeprecated(Element e)` | 判断元素是否被标记为`Deprecated` |
| `Set<? extends Element> getAllMembers(TypeElement type)` | 获取类或接口类型元素的所有成员元素（字段、方法、构造函数等） |
| `List<? extends AnnotationMirror> getAllAnnotationMirrors(Element e)` | 获取元素的所有注解类型 |

### Element
`Element` 代表程序的元素，例如包、类或者方法。每个Element代表一个静态的、语言级别的构件。

```java
package com.example;    // PackageElement

public class Foo {        // TypeElement

    private int a;      // VariableElement
    private Foo other;  // VariableElement

    public Foo () {}    // ExecuteableElement

    public void setA (  // ExecuteableElement
                     int newA   // VariableElement
                     ) {}
}
```

常用方法：
| 常用方法 | 说明 |
| --- | --- |
| `TypeMirror asType()` | 获取元素类型 |
| `ElementKind getKind()` | 获取元素种类(枚举)，例如类、方法、字段等 |
| `List<? extends AnnotationMirror> getAnnotationMirrors()` | 返回元素上的注解列表 |
| `<A extends Annotation> A getAnnotation(Class<A> annotationType)` | 返回指定类型的注解 |
| `Element getEnclosingElement()` | 下方详细介绍 |
| `List<? extends Element> getEnclosedElements()` | 下方详细介绍 |
| `<R, P> R accept(ElementVisitor<R, P> v, P p)` | 下方详细介绍 |

#### ElementKind

| 元素种类 | 说明 |
| --- | --- |
| PACKAGE | 包 |
| ENUM | 枚举 |
| CLASS | 类 |
| FIELD | 字段 |
| METHOD | 函数 |
| CONSTRUCTOR | 构造 |
| ... | ... |

#### getEnclosingElement()

`getEnclosingElement()` 方法用于获取当前元素的封闭元素，即包含当前元素的最直接的上级元素。

**`对于包元素（Package Element）`**：

* 如果当前元素是一个包，那么它的封闭元素就是空（null）。

**`对于类型元素（Type Element）`**：

* 如果当前元素是一个顶层类，那么它的封闭元素就是包含该类的包（Package Element）。
* 如果当前元素是一个内部类，那么它的封闭元素就是包含该内部类的外部类（Type Element）。
* 如果当前元素是一个匿名类，那么它的封闭元素就是声明该匿名类的外部类（Type Element）。

**`对于可执行元素（Executable Element）`**：

* 如果当前元素是一个方法、构造函数或初始化块，那么它的封闭元素就是声明该方法、构造函数或初始化块的类型元素（Type Element）。
对于其他元素：

**`对于字段、枚举常量、参数等其他类型的元素`**：

它们的封闭元素可能是声明它们的方法、构造函数、初始化块，或者外部类，具体取决于它们所在的上下文。

总的来说，`getEnclosingElement()` 方法返回的是当前元素的直接上级元素。

#### getEnclosedElements()

`getEnclosedElements()` 它用于获取当前元素所包含的子元素列表。以下是各种情况下的使用说明：

**`对于包元素（Package Element）`**：

* 包元素不包含任何子元素，因此调用 `getEnclosedElements()` 方法会返回一个空的列表。

**`对于类型元素（Type Element）`**：

* 如果当前元素是一个类、接口、枚举或注解类型，`getEnclosedElements()` 方法将返回该类型中声明的所有成员变量、方法、内部类等子元素列表。

**`对于可执行元素（Executable Element）`**：

* 如果当前元素是一个方法、构造函数或初始化块，`getEnclosedElements()` 方法将返回该方法、构造函数或初始化块中声明的所有局部变量、参数等子元素列表。

对于其他元素：

**`对于字段、枚举常量、参数等其他类型的元素`**：

* 它们通常不包含子元素，因此调用 `getEnclosedElements()` 方法将返回一个空的列表。

总的来说，`getEnclosedElements()` 方法用于获取当前元素所包含的所有子元素列表。

示例如下：

```java
public class ExampleProcessor {
    public void processElement(Element element) {
        // 获取当前元素直接包含的所有子元素
        for (Element enclosedElement : element.getEnclosedElements()) {
            // 判断子元素的种类
            if (enclosedElement.getKind() == ElementKind.FIELD) {
                
            } else if (enclosedElement.getKind() == ElementKind.METHOD) {
                
            } else if (enclosedElement.getKind() == ElementKind.CLASS) {
                
            } else {
                
            }
        }
    }
}
```

#### <R, P> R accept(ElementVisitor<R, P> v, P p)

这个方法使用访问者模式，允许你在编译期间访问和处理源代码中的各种元素，例如类、方法、字段等。使用 `accept()` 方法，你可以在编译时遍历源代码中的元素，并根据元素的类型执行相应的逻辑。示例如下：

**示例1: 自动生成HashCode和Equals方法**

```java
@AutoGenerateEqualsAndHashCode
public class MyClass {
    private String name;
    private int age;
}
```
```java
public class AutoGenerateEqualsAndHashCodeProcessor extends AbstractProcessor {

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        for (Element element : roundEnv.getElementsAnnotatedWith(AutoGenerateEqualsAndHashCode.class)) {
            ElementVisitor<Void, Void> visitor = new ElementVisitor<Void, Void>() {
                @Override
                public Void visitType(TypeElement e, Void p) {
                    // 生成HashCode和Equals方法的代码
                    // ...
                    return super.visitType(e, p);
                }
            };
            element.accept(visitor, null);
        }
        return true;
    }
}
```

**示例2: 检查自定义注解的使用规范**

```java
@CustomAnnotation
public class MyClass {
    // ...
}
```
```java
public class CustomAnnotationChecker extends AbstractProcessor {

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        for (Element element : roundEnv.getElementsAnnotatedWith(CustomAnnotation.class)) {
            if (!(element.getKind() == ElementKind.CLASS)) {
                processingEnv.getMessager().printMessage(Diagnostic.Kind.ERROR,
                        "@CustomAnnotation can only be applied to classes", element);
            }
        }
        return true;
    }
}
```

#### TypeElement

`TypeElement` 表示类、接口、枚举或注解元素，常用有方法如下：

| 常用方法 | 返回值 | 说明 |
| --- | --- | --- |
| `getSimpleName()` | `Name` | 返回当前类元素的名称 |
| `getQualifiedName()` | `Name` | 返回当前类元素的完全限定名 |
| `getSuperclass()` | `TypeMirror` | 返回当前类元素的父类 |
| `getInterfaces()` | `List<? extends TypeMirror>` | 返回当前类元素实现的接口类型 |

其他 `Element` 子类说明不再一一列举。
