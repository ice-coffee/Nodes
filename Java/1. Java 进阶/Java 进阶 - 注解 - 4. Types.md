`Types` 接口提供了多种方法，用于处理和比较类型（`TypeMirror` 对象）。以下是一些常用方法：

| 常用方法 | 说明 |
| --- | --- |
| `boolean isSameType(TypeMirror t1, TypeMirror t2)` | 判断两个类型是否相同 |
| `boolean isSubtype(TypeMirror t1, TypeMirror t2)` | 判断一个类型是否是另一个类型的子类型，包含继承（`extends`）和实现（`implements`） |
| `boolean isAssignable(TypeMirror t1, TypeMirror t2)` | 判断一个类型是否可以赋值给另一个类型，例如：`int -> long` |

### TypeMirror
`TypeMirror` 表示 `Java` 编程语言中的类型。类型包括基本类型、声明类型(类和接口类型)、数组类型、类型变量和空类型。还表示通配符类型参数、可执行文件的签名和返回类型，以及与包和关键字 `void` 对应的伪类型。常用方法如下：

| 常用方法 | 返回值 | 说明 |
| --- | --- | --- |
| `getKind()` | `TypeKind` | 返回一个枚举值，代表是那种类型 |

#### TypeKind

| 数据类型 | 说明 |
| --- | --- |
| BOOLEAN | 布尔类型 |
| INT | 整型 |
| ... | ...基本数据类型 |
| VOID | 无类型 |
| NULL | 空 |
| DECLARED | 类或接口 |
| ... | ... |

#### DeclaredType
`DeclaredType` 表示类、接口或枚举类型，主要看它的两个函数：

```java
/**
 * 转换为 Element
 */
Element asElement();

/**
 * Returns the type of the innermost enclosing instance or a
 * {@code NoType} of kind {@code NONE} if there is no enclosing
 * instance.  Only types corresponding to inner classes have an
 * enclosing instance.
 *
 * @return a type mirror for the enclosing type
 * @jls 8.1.3 Inner Classes and Enclosing Instances
 * @jls 15.9.2 Determining Enclosing Instances
 */
TypeMirror getEnclosingType();
```

### AnnotationMirror
`AnnotationMirror` 接口在 `Java` 注解处理器中用于表示注解类型。而且 `AnnotationMirror` 是一个顶层接口。

| 常用方法 | 返回值 | 说明 |
| --- | --- | --- |
| `getAnnotationType()` | `DeclaredType` | 返回注解的类型 |
| `getElementValues()` | `Map<? extends ExecutableElement, ? extends AnnotationValue>` | 以 `Map` 形式返回在元素上添加注解时设置的参数和值 |

通过遍历返回值 `Map` 可以判断注解中设置的数据。
