[toc]
### 参考
[从 CLASSLOADER 到热修复](http://yinshudi.com/2018/07/13/%E4%BB%8E%20ClassLoader%20%E5%88%B0%E7%83%AD%E4%BF%AE%E5%A4%8D/)

[JVM 类加载机制](https://juejin.im/post/6844904002090434568)

[Android ClassLoader详解](https://cloud.tencent.com/developer/article/1036505)

### 类加载机制

每个编写的 `.java` 拓展名类文件都存储着需要执行的程序逻辑，这些 `.java` 文件经过 `Java` 编译器编译成拓展名为 `.class` 的文件，`.class` 文件中保存着 `Java` 代码经转换后的虚拟机指令，当需要使用某个类时，虚拟机将会加载它的 `.class` 文件，并创建对应的 `class` 对象，将 `class` 文件加载到虚拟机的内存，这个过程称为类加载，这里我们需要了解一下类加载的过程，如下：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/classloader_process.png)

- **加载**：通过一个类的完全限定符查找此类字节码文件，并利用字节码文件创建一个 `Class` 对象，`Class` 对象存放在堆中，`而且每个通过关键字 class 标识的类，无论创建多少个实例对象，在内存中有且只有一个与之对应的 Class 对象来描述其类型信息`。
- **验证**：目的在于确保 `Class` 文件的字节流中包含信息符合当前虚拟机要求，不会危害虚拟机自身安全。主要包括四种验证，文件格式验证，元数据验证，字节码验证，符号引用验证。
- **准备**：为类变量(即 `static` 修饰的字段变量)分配内存并且设置该类变量的初始值即0(如static int i=5;这里只将i初始化为0，至于5的值将在初始化时赋值)，这里不包含用 `final` 修饰的 `static`，因为 `final` 在编译的时候就会分配了，注意这里不会为实例变量分配内存，类变量会分配在方法区中，而实例变量是会随着对象一起分配到Java堆中。
- **解析**：主要将常量池中的符号引用替换为直接引用的过程。符号引用就是一组符号来描述目标，可以是任何字面量，而直接引用就是直接指向目标的指针、相对偏移量或一个间接定位到目标的句柄。有类或接口的解析，字段解析，类方法解析，接口方法解析(这里涉及到字节码变量的引用，如需更详细了解，可参考《深入Java虚拟机》)。
- **初始化**：类加载最后阶段，若该类具有超类，则对其进行初始化，执行静态初始化器和静态初始化成员变量(如前面只初始化了默认值的static变量将会在这个阶段赋值，成员变量也将被初始化)。

### Java 中的 ClassLoader
提供了3种类加载器：

- `BootstrapClassLoader`：启动类加载器；
- `ExtensionClassLoader`：扩展类加载器；
- `AppClassLoader`：系统类加载器（也称应用类加载器）

#### BootStrapClassLoader
启动类加载器。这是 Java 中最顶层的类加载器，属于 JVM 的一部分，负责加载 JDK 中的核心类库。它由 C++ 编写，因此其他类加载器不能直接引用它。

#### ExtensionClassLoader
扩展类加载器。负责加载 Java 的扩展类库。默认加载JAVA_HOME/jre/lib/ext/目下的所有jar。

#### AppClassLoader
系统类加载器，负责加载应用程序classpath目录下的所有jar和class文件。一般来说，Java 应用的类都是由它来完成加载的。可以通过 ClassLoader.getSystemClassLoader()来获取它。

### ClassLoader 的基本规则
`JVM` 在运行时，并不会一次性加载所有的类到内存中，而是只在需要的时候加载。

`JVM` 在判定两个 `class` 是否相同时，不仅要判断两个类名是否相同，而且要判断是否由同一个类加载器实例加载的。只有两者同时满足的情况下，`JVM` 才认为这两个 `class` 是相同的。

#### 全盘负责
全盘负责是指，当一个 ClassLoder 加载一个类时，这个类所依赖和引用的类如果没有显式地指定其他 ClassLoder，那么这些类还是由这个 ClassLoader 来加载。

#### 双亲委托模型（Parent Delegation Model ）
双亲委托模型这个翻译有很强的误导性，因为每个 ClassLoader 只有一个父加载器，并不存在什么双亲，实际翻译为父委托模型更为妥当。但这个翻译流传甚广，大家都默认了这种叫法。

每个 ClassLoader 对象中都有一个 parent 引用，在构造器中传入，这个就是他的父加载器。因此这里的父加载器并不是继承的关系，而是引用的关系。

双亲委托模型是指，类加载器在加载时遵循以下规则：

1. 源 ClassLoader先判断这个类是否加载过，如果已加载，则直接返回，如果未加载，则委托父加载器进行加载。
2. 父加载器进行和第一步同样的判断，如果已加载，则直接返回，如果未加载，则委托祖父加载器进行加载。
3. 这样一直上溯，一直到有个加载器的父加载器为 null，这时系统会指定 BootstrapClassLoader 进行加载，这个就是始祖类加载器。因为这个类使用 C++ 实现，不能被 Java对象直接引用，所以它的子加载器的 parent 都为 null。
4. 始祖类加载器判断是否加载过，如果没有，则尝试从指定的路径下寻找 class文件并加载，找到了则返回，找不到则委托给子加载器加载。
5. 重复上面的步骤，如果始终找不到，会一直下溯到源 ClassLoader。
6. 源 ClassLoader 加载成功的话就直接返回，加载不成功的话会抛出 ClassNotFoundException。

这个机制和 Android中的事件分发类似，只不过顺序相反。先上溯，父加载器处理不了再下溯交给子加载器处理。说了这么多，其实代码实现很简单（删除了无关代码）：

``` java
protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
    synchronized (getClassLoadingLock(name)) {
        // 先在缓存中查找，加载过就直接返回
        Class c = findLoadedClass(name);
        if (c == null) {
            try {
                if (parent != null) {
                    //委托父加载器加载
                    c = parent.loadClass(name, false);
                } else {
                    //如果父加载器为 null，说明到了最顶层，这时委托祖先bootstrap类加载器加载
                    c = findBootstrapClassOrNull(name);
                }
            } catch (ClassNotFoundException e) {
                // ClassNotFoundException thrown if class not found
                // from the non-null parent class loader
            }
    
            if (c == null) {
                // 如果此时依然为空，说明父辈加载器都没加载。此时自己调用方法加载
                c = findClass(name);
            }
        }
        if (resolve) {
            resolveClass(c);
        }
        return c;
    }
}
```

为什么要如此设计
- 防止类重复加载。遵循双亲委托原则的话，同一个类只会由一个类加载器加载。避免混乱。
- 保证安全。防止插入 Java 核心类到 Java 类库中。
- 当然，在遵循双亲委托的前提下上面两点才成立。双亲委托模型是由 ClassLoader 的 loadClass 方法实现的，这是个 protected 的方法，因此子类可以重写，并实现自己的逻辑。这会破坏了双亲委托模型，但为插件化提供了方便。

### Android 中的 ClassLoader

而 Android 中的虚拟机 Dalvik/ART 无法和 JVM 一样直接加载 class 文件和 jar 文件中的 class，只能通过 dex 文件或包含 dex 的 jar 包或 apk 包来加载。因此 Android 和 Java 的 ClassLoader 略有不同，但他们都遵守 ClassLoader 的基本规则。

Android 中的 ClassLoader 还是符合双亲委托模型的，其 loadClass 没有什么变化。但是，defineClass 方法会直接抛出异常，提示“can’t load this type of class file”。这是因为Android 中的虚拟机 Dalvik/ART 无法和 JVM 一样直接加载 class 文件和 jar 文件中的 class。

Android 有以下三种类加载器:

#### BootClassLoader

这是 Android 虚拟机中的祖先类加载器。==和 Java 不同的是，它是 ClassLoader 的内部类，由 Java 实现。==

#### PathClassLoader

应用默认的类加载器。父加载器是 BootClassLoader。

``` java
public class PathClassLoader extends BaseDexClassLoader {
    public PathClassLoader(String dexPath, ClassLoader parent) {
        super(dexPath, null, null, parent);
    }

    public PathClassLoader(String dexPath, String librarySearchPath, ClassLoader parent) {
       super(dexPath, null, librarySearchPath, parent);
    }
}
```

#### DexClassLoader

==在看源码时，发现 DexClassLoader 在 8.1.0 版本已经废弃了。==代码如下：


``` java
//Android 8.1.0
public class DexClassLoader extends BaseDexClassLoader {
    public DexClassLoader(String dexPath, String optimizedDirectory,
            String librarySearchPath, ClassLoader parent) {
       super(dexPath, null, librarySearchPath, parent);
    }
}

//Android 8.0.0 及以前
public class DexClassLoader extends BaseDexClassLoader {
    public DexClassLoader(String dexPath, String optimizedDirectory,
            String librarySearchPath, ClassLoader parent) {
       super(dexPath, new File(optimizedDirectory), librarySearchPath, parent);
    }
}
```

可以看见，DexClassLoader 构造方法中的 optimizedDirectory 参数在8.1.0版本被废弃了。这样 DexClassLoader 实际上和 PathClassLoader 没有区别了。

看看Android 8.0的行为变更描述

> DexFile API is now deprecated, and you are strongly encouraged to use one of the platform classloaders, including PathClassLoader or BaseDexClassLoader, instead.

DexFile API 现已弃用，强烈建议您改为使用此平台的类加载器之一，包括 PathClassLoader 或 BaseDexClassLoader。

应该是出于防止代码注入的原因，官方已经弃用了 DexFile 的机制。下面我们就根据最新的8.1代码进行分析。在看代码的时候始终记得一点就行，optimizedDirectory参数始终为空！！！

#### BaseDexClassLoader
BaseDexClassLoader 继承自 ClassLoader，是 PathClassLoader 的父类。代码很简单，将主要功能都交给了 DexPathList 去处理。

在构造方法中新建一个 DexPathList，将 DexPath 传入，optimizedDirectory的参数位传 null。

``` java
public BaseDexClassLoader(String dexPath, File optimizedDirectory,String librarySearchPath, ClassLoader parent) {
    super(parent);
    this.pathList = new DexPathList(this, dexPath, librarySearchPath, null);
    
    if (reporter != null) {
        reporter.report(this.pathList.getDexPaths());
    }
}
```

在 findClass 中委托 DexPathList 去查找类


``` java
@Override
protected Class<?> findClass(String name) throws ClassNotFoundException {
   List<Throwable> suppressedExceptions = new ArrayList<Throwable>();
   Class c = pathList.findClass(name, suppressedExceptions);
   if (c == null) {
      ClassNotFoundException cnfe = new ClassNotFoundException("Didn't find class \"" + name + "\" on path: " + pathList);
      for (Throwable t : suppressedExceptions) {
          cnfe.addSuppressed(t);
      }
      throw cnfe;
    }
    return c;
}
```

#### DexPathList
DexPathList 也只干了两件事:

新建 Element 数组。其中所有 dex 文件包装成 DexFile，其他文件或文件夹包装成 File 对象传入 Element
在 findClass 中遍历 Element 数组，调用 Element 的 findClass 方法，找到类立即返回，不再继续寻找。

``` java
public Class<?> findClass(String name, List<Throwable> suppressed) {
    for (Element element : dexElements) {
        Class<?> clazz = element.findClass(name, definingContext, suppressed);
        if (clazz != null) {
           return clazz;
       }
    }

    if (dexElementsSuppressedExceptions != null) {
        suppressed.addAll(Arrays.asList(dexElementsSuppressedExceptions));
    }
    return null;
}
```

==以上这段代码至关重要，它意味着一个类只加载一次，并且优先加载排在前面的 dex 文件中的类。这给热修复提供了机会。==

#### Element
Element 是 DexPathList 的静态内部类。调用 findClass 时，如果 dexFile 不为空，则用dexFile查找类，为空则直接返回 null。

``` java
public Class<?> findClass(String name, ClassLoader definingContext, List<Throwable> suppressed) {
   return dexFile != null ? dexFile.loadClassBinaryName(name, definingContext, suppressed)
            : null;
}
```

#### DexFile
DexFile 就是实际处理 .dex 文件的类。


``` java
public Class loadClassBinaryName(String name, ClassLoader loader, List<Throwable> suppressed) {
    return defineClass(name, loader, mCookie, this, suppressed);
}

private static Class defineClass(String name, ClassLoader loader, Object cookie,DexFile dexFile, List<Throwable> suppressed) {
    Class result = null;
    try {
        result = defineClassNative(name, loader, cookie, dexFile);
    } catch (NoClassDefFoundError e) {
        if (suppressed != null) {
            suppressed.add(e);
        }
   } catch (ClassNotFoundException e) {
        if (suppressed != null) {
            suppressed.add(e);
       }
   }
   return result;
}
```

我们终于找到了熟悉的 defineClass 方法！！！
它最终调用了 defineClassNative 方法，从一个 dex 文件中查找类，加载到内存并返回 class 对象。这是一个 native 方法，具体就不深究了。
官方不建议应用开发者使用这个类，因为会有损性能，并可能造成不正确的字节码操作。后续会被移除出源码。官方建议我们标准的 ClassLoader 类，如 PathClassLoader。

### QA
#### 类加载器本身由谁加载？
前面说了，BootStrap ClassLoader 是 JVM 的一部分，由 JVM 自身管理，我们无法访问。程序启动时，BootStrap ClassLoader 会先加载 Extension ClassLoader，然后加载 App ClassLoader。其中 Extension ClassLoader 是 App ClassLoader 的父加载器。BootStrap ClassLoader 是 Extension ClassLoader 的父加载器。

#### 默认的父加载器是谁？
父加载器在 ClassLoader 的构造方法中传入。如果不传，会指定一个系统加载器给它，这个系统加载器就是 App ClassLoader。

#### 如何自定义 ClassLoader
- 继承 ClassLoader 类，重写 findClass 方法。
- 在 findClass方法中根据类名找到对应文件，并将文件转成 byte 数组。
- 调用 defineClass 方法将 byte 数组转为 Class 对象返回。
- 没事不要重写loadClass方法。会破坏双亲委托模型。
