[图解LinkedHashMap原理](https://www.jianshu.com/p/8f4f58b4b8ab)

`LinkedHashMap` 继承与 `HashMap`，并且没有重写 `put` 方法，所以其也是基于数据 + 链表的方式实现的。

`LinkedHashMap` 和 `HashMap` 不同的是它可以保存元素的顺序，可以是插入顺序或访问顺序。

### `LinkedHashMap` 如何保持顺序
在 `HashMap` 的 `putVal()` 方法中，新插入的节点会通过 `newNode()` 方法生成。`LinkedHashMap` 重写了此方法。

``` java
Node<K,V> newNode(int hash, K key, V value, Node<K,V> e) {
    LinkedHashMapEntry<K,V> p =
        new LinkedHashMapEntry<K,V>(hash, key, value, e);
    linkNodeLast(p);
    return p;
}
```

生成 `LinkedHashMapEntry` 节点，并调用 `linkNodeLast` 方法插入节点到链表尾部。

``` java
private void linkNodeLast(LinkedHashMapEntry<K,V> p) {
    LinkedHashMapEntry<K,V> last = tail;
    tail = p;
    if (last == null)
        head = p;
    else {
        p.before = last;
        last.after = p;
    }
}
```

这样就保证了 `Map` 结构中数据的顺序。

### `LinkedHashMap` 根据节点的访问排序
`LinkedHashMap` 没有重写 `HashMap` 的 `put` 方法，但重写了 `get` 方法。

``` java
public V get(Object key) {
    Node<K,V> e;
    if ((e = getNode(hash(key), key)) == null)
        return null;
    if (accessOrder)
        afterNodeAccess(e);
    return e.value;
}
```

根据 `accessOrder` 设置，会在访问数据节点时对数据进行排序。排序的逻辑是，将节点放到链表末尾。

### 应用

- `LruCache`；
- `DiskLruCache`；

注意：`LruCache` 仅保证数据容量，排序操作在 `LinkedHahMap` 中实现。
