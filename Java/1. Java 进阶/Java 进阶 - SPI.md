### SPI
`Java SPI（Service Provider Interface）` 是 `Java` 的一种扩展机制，用于实现模块之间的解耦。它允许开发者定义服务接口（Service Interface），并且为这个接口提供不同的实现，然后在运行时动态地选择和加载具体的实现类。这种机制使得系统更加灵活，能够在不修改代码的情况下替换掉某个实现。
`SPI` 的核心在于两个部分：

* **`服务接口（Service Interface）`**： 定义服务的接口，通常是一个Java接口。
* **`服务提供者实现类（Service Provider Implementation）`**： 实现了服务接口的具体类。

在SPI机制中，服务提供者（即实现了服务接口的类）需要提供一个 `META-INF/services` 目录，其中包含一个以服务接口的全限定类名为名称的文本文件。这个文件里包含了具体的服务提供者实现类的全限定类名。
SPI的加载机制是通过 `java.util.ServiceLoader` 类来实现的。这个类可以在运行时动态地加载服务提供者。通过 `ServiceLoader.load(Class<T> service)` 方法，可以加载指定接口的所有实现。

**``示例：``**
**1. 服务接口定义：**

```java
public interface IMyService {
    void doSomething();
}
```

**2. 服务提供者实现类1：**

```java
public class MyServiceImpl1 implements IMyService {
    @Override
    public void doSomething() {
        System.out.println("Implementation 1");
    }
}
```

**3. 服务提供者实现类2：**

```java
public class MyServiceImpl2 implements IMyService {
    @Override
    public void doSomething() {
        System.out.println("Implementation 2");
    }
}
```

4. 在 `META-INF/services` 目录下创建文件 `com.example.MyService`，并在文件中写入服务提供者的全限定类名：

```
com.example.MyServiceImpl1
com.example.MyServiceImpl2
```

5. 使用 `ServiceLoader` 加载服务提供者：

```java
import java.util.ServiceLoader;

public class Main {
    public static void main(String[] args) {
        ServiceLoader<IMyService> loader = ServiceLoader.load(IMyService.class);
        for (IMyService service : loader) {
            service.doSomething();
        }
    }
}
```

在这个例子中，`ServiceLoader` 会自动加载 `META-INF/services/com.example.MyService` 文件中指定的实现类，并且调用其 `doSomething()` 方法。这样，无论后续增加了多少个实现类，都不需要修改代码，即可在运行时进行加载和调用。

### AutoService
`AutoSerivce` 是 `Google` 提供的可以帮助生成 `META-INF` 文件的库。

集成：
```kotlin
apply plugin: 'kotlin-kapt'
```

```kotlin
kapt 'com.google.auto.service:auto-service:1.0-rc6'
api 'com.google.auto.service:auto-service:1.0-rc6'
```

使用 `@AutoService` 注解标记接口实现类：
```java
@AutoService(MyService.class)
public class MyServiceImpl1 implements IMyService {
}
```

```java
@AutoService(MyService.class)
public class MyServiceImpl2 implements IMyService {
}
```

重新编译后就会自动生成 `META-INF` 相关文件，接下来就可以直接通过 `ServiceLoader.load(Class<T> service)` 获取实现类列表了。

#### AutoService 注解处理器源码分析
`AutoService` 是 `Google` 开发的一个自动生成 SPI 清单文件的框架。可以用来帮助我们注册 `APT` 文件。

**`AutoService` 注解器代码分析：**
```java
public class AutoServiceProcessor extends AbstractProcessor {

  @VisibleForTesting
  static final String MISSING_SERVICES_ERROR = "No service interfaces provided for element!";

  /**
   * key：接口全路径名
   * value：`AutoService` 注解修饰的实现类全路径名
   */
  private final Multimap<String, String> providers = HashMultimap.create();

  @Override
  public ImmutableSet<String> getSupportedAnnotationTypes() {
    return ImmutableSet.of(AutoService.class.getName());
  }

  @Override
  public SourceVersion getSupportedSourceVersion() {
    return SourceVersion.latestSupported();
  }

  @Override
  public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
    try {
      processImpl(annotations, roundEnv);
    } catch (RuntimeException e) {
      // We don't allow exceptions of any kind to propagate to the compiler
      fatalError(getStackTraceAsString(e));
    }
    return false;
  }

  private void processImpl(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
    if (roundEnv.processingOver()) {
      // 如果注解处理完成，生成文件
      generateConfigFiles();
    } else {
      // 否则处理注解
      processAnnotations(annotations, roundEnv);
    }
  }

  private void processAnnotations(Set<? extends TypeElement> annotations,
      RoundEnvironment roundEnv) {

    // 获取所有被 `AutoService` 注解标记的元素
    Set<? extends Element> elements = roundEnv.getElementsAnnotatedWith(AutoService.class);

    log(annotations.toString());
    log(elements.toString());

    for (Element e : elements) {
      // `AutoService` 被定义为仅在类元素上可用，这里直接转换为 `TypeElement`：`ServiceImpl.java`
      TypeElement providerImplementer = MoreElements.asType(e);
      // 获取类元素上设置的 `AutoService` 注解对象： `@AutoService(IService.class)`
      AnnotationMirror annotationMirror = getAnnotationMirror(e, AutoService.class).get();
      // 获取在 `AutoService` 注解上设置的值：`IService.class`
      Set<DeclaredType> providerInterfaces = getValueFieldOfClasses(annotationMirror);
      if (providerInterfaces.isEmpty()) {
        error(MISSING_SERVICES_ERROR, e, annotationMirror);
        continue;
      }
      for (DeclaredType providerInterface : providerInterfaces) {
        TypeElement providerType = MoreTypes.asTypeElement(providerInterface);

        log("provider interface: " + providerType.getQualifiedName());
        log("provider implementer: " + providerImplementer.getQualifiedName());
        // 判断 `AutoService` 注解修饰的类和在注解内设置的value值是否是 `extends` 或 `implements` 关系
        if (checkImplementer(providerImplementer, providerType, annotationMirror)) {
          providers.put(getBinaryName(providerType), getBinaryName(providerImplementer));
        } else {
          String message = "ServiceProviders must implement their service provider interface. "
              + providerImplementer.getQualifiedName() + " does not implement "
              + providerType.getQualifiedName();
          error(message, e, annotationMirror);
        }
      }
    }
  }

  /**
   * 注解处理完成后创建以接口全路径名为名称的文件，文件内容是 `AutoService` 注解修饰的实现类全路径名
   */
  private void generateConfigFiles() {
    ......
  }
}
```
