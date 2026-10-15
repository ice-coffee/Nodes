MethodHandle 是 Java 中用于支持动态方法调用的一种机制，它在 Java 7 引入，并位于 java.lang.invoke 包中。它与传统的 Java 反射相比，提供了更加灵活和高效的方法调用方式。

实际测试下 `MethodHandle` 性能并没有优于反射。

```java
import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodType;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.invoke.LambdaMetafactory;

public class MethodHandleVsReflect {
    public static void main(String[] args)  {
        MethodHandleVsReflect methodHandleVsReflect = new MethodHandleVsReflect();
        try {
            methodHandleVsReflect.testDirect();
            methodHandleVsReflect.testReflect();
            methodHandleVsReflect.testMethodHandle();
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        }
    }

    public void testDirect(){
        A a = new A();
        B b = new B();
        //预热
        for (long i = 0; i < 100_0000_0000L; i++) {
            if ((i&1)==0){
                a.count(1);
            }else{
                b.count(1);
            }
        }
        //统计性能
        long startNano=System.nanoTime();
        for (long i = 0; i < 100_0000_0000L; i++) {
            if ((i&1)==0){
                a.count(1);
            }else{
                b.count(1);
            }
        }
        System.out.format("计算结果为: a: %d b: %d",a.i,b.i);
        double average = (System.nanoTime() - startNano) / 100_0000_0000.0;
        System.out.println("直接调用平均耗时(ns)："+average);
    }

    public void testReflect() throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        //反射
        Method countA = A.class.getMethod("count", Integer.class);
        Method countB = B.class.getMethod("count",Integer.class);
        A a = new A();
        B b = new B();
        //预热
        for (long i = 0; i < 100_0000_0000L; i++) {
            if ((i&1)==1){
                countA.invoke(a,1);
            }else{
                countB.invoke(b,1);
            }
        }
        //统计性能
        long startNano=System.nanoTime();
        for (long i = 0; i < 100_0000_0000L; i++) {
            if ((i&1)==1){
                countA.invoke(a,1);
            }else{
                countB.invoke(b,1);
            }
        }
        System.out.format("计算结果为: a: %d b: %d",a.i,b.i);
        double average = (System.nanoTime() - startNano) / 100_0000_0000.0;
        System.out.println("反射平均耗时(ns)："+average);
    }

    static final MethodHandles.Lookup publicLookup = MethodHandles.publicLookup();
    static final MethodType mt = MethodType.methodType(void.class,Integer.class);
    private static final MethodHandle countA=getCountA();
    private static final MethodHandle countB=getCountB();
    private static MethodHandle getCountA(){
        try {
            return publicLookup.findVirtual(A.class, "count", mt);
        } catch (Throwable e) {
            e.printStackTrace();
            return null;
        }
    }

    private static MethodHandle getCountB(){
        try {
            return publicLookup.findVirtual(B.class, "count", mt);
        } catch (Throwable e) {
            e.printStackTrace();
            return null;
        }
    }

    public void testMethodHandle() throws Throwable {
        A a = new A();
        B b = new B();
        // MethodHandles.Lookup publicLookup = MethodHandles.publicLookup();
        // MethodType mt = MethodType.methodType(void.class,Integer.class);
        // MethodHandle countA = publicLookup.findVirtual(A.class, "count", mt);
        // MethodHandle countB = publicLookup.findVirtual(B.class, "count", mt);
        // Integer int_1 = new Integer(1);
        //预热
        for (long i = 0; i < 100_0000_0000L; i++) {
            if ((i&1)==1){
                countA.invoke(a,1);
            }else{
                countB.invoke(b,1);
            }
        }
        //统计性能
        long startNano=System.nanoTime();
        for (long i = 0; i < 100_0000_0000L; i++) {
            if ((i&1)==1){
                countA.invoke(a,1);
            }else{
                countB.invoke(b,1);
            }
        }
        System.out.format("计算结果为: a: %d b: %d",a.i,b.i);
        double average = (System.nanoTime() - startNano) / 100_0000_0000.0;
        System.out.println("methodHandle平均耗时(ns)："+average);
    }


    public void testLambda() throws Throwable {
        
    }

    public class A{
        long i=0;
        public void count(Integer a){
            i++;
        }
    }

    public class B{
        long i=0;
        public void count(Integer a){
            i++;
        }
    }
}
```
