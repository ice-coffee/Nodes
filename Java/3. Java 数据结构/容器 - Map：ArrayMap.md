[ArrayMap的hash碰撞和内存优化的原理](http://gaozhipeng.me/posts/arraymap/)

`ArrayMap` 内部由两个数组组成：

- `mHashes`：存放 `key` 的哈希值
- `mArray`：相邻位置存放键值对

```java
mHashes[i] = key.hashCode()
mArray[i<<1] = key 
mArray[i<<1 + 1] = value
```

### 数据存放

```java
public V put(K key, V value) {
    final int osize = mSize;
    final int hash;
    int index;
    if (key == null) {
        hash = 0;
        index = indexOfNull();
    } else {
        hash = mIdentityHashCode ? System.identityHashCode(key) : key.hashCode();
        // 查找目标 key 在 mHashes 数据的下标位置
        index = indexOf(key, hash);
    }

    // 找到 key 的下标
    if (index >= 0) {
        index = (index<<1) + 1;
        final V old = (V)mArray[index];
        mArray[index] = value;
        return old;
    }

    // 目标 key 未找到
    index = ~index;
    if (osize >= mHashes.length) {
        // 计算扩容
        final int n = osize >= (BASE_SIZE*2) ? (osize+(osize>>1))
                : (osize >= BASE_SIZE ? (BASE_SIZE*2) : BASE_SIZE);

        if (DEBUG) Log.d(TAG, "put: grow from " + mHashes.length + " to " + n);

        final int[] ohashes = mHashes;
        final Object[] oarray = mArray;

        // 执行扩容
        allocArrays(n);

        if (CONCURRENT_MODIFICATION_EXCEPTIONS && osize != mSize) {
            throw new ConcurrentModificationException();
        }

        // 数据拷贝
        if (mHashes.length > 0) {
            if (DEBUG) Log.d(TAG, "put: copy 0-" + osize + " to 0");
            System.arraycopy(ohashes, 0, mHashes, 0, ohashes.length);
            System.arraycopy(oarray, 0, mArray, 0, oarray.length);
        }

        // 释放数组
        freeArrays(ohashes, oarray, osize);
    }

    // 移动数组, 为插入数据做准备
    if (index < osize) {
        if (DEBUG) Log.d(TAG, "put: move " + index + "-" + (osize-index)
                + " to " + (index+1));
        System.arraycopy(mHashes, index, mHashes, index + 1, osize - index);
        System.arraycopy(mArray, index << 1, mArray, (index + 1) << 1, (mSize - index) << 1);
    }

    if (CONCURRENT_MODIFICATION_EXCEPTIONS) {
        if (osize != mSize || index >= mHashes.length) {
            throw new ConcurrentModificationException();
        }
    }

    // 插入新数据
    mHashes[index] = hash;
    mArray[index<<1] = key;
    mArray[(index<<1)+1] = value;
    mSize++;
    return null;
}
```

`indexOf` 方法：

```java
int indexOf(Object key, int hash) {
    final int N = mSize;
    // 没有数据的情况，直接放在第一位
    if (N == 0) {
        return ~0;
    }
    // 二分查找位置
    int index = binarySearchHashes(mHashes, N, hash);

    // 没找到位置就直接返回
    if (index < 0) {
        return index;
    }

    // 找到了我们就需要看看是否就是当前的key
    if (key.equals(mArray[index<<1])) {
        return index;
    }

    // 往后查找，找到是否是equals
    int end;
    for (end = index + 1; end < N && mHashes[end] == hash; end++) {
        if (key.equals(mArray[end << 1])) return end;
    }

    // 往前查找，使用equals
    for (int i = index - 1; i >= 0 && mHashes[i] == hash; i--) {
        if (key.equals(mArray[i << 1])) return i;
    }

    return ~end;
}
```

从上面的逻辑我们可以看到，`mHashes` 维护的是一个有序的 `hashcode` 的数组，同时，`array` 的是两两对应的，一个 `key`，一个 `value`，而 `key` 的 `hashcode` 和 `mHashes` 维护的 `index` 是2倍的关系。
如果二分法找到了 `hash` 位置，但是并不是 `equals` 的。那么就说明我们遇到了 `hash` 碰撞了，那么接着可以看一下对应的操作，于是就继续往后或者往前查找，采用 `key` 的 `equals` 的方式来查找 `key`。那么我们就可以断定——`mhashes` 中其实是存在着重复的 `hash` 值，而 `marray` 里面的 `key` 也是按 `hashcode` 的值排列，但是也会考虑 `equals` 的情况。
那么总结一下就是：`ArrayMap` 遇到 `hash` 碰撞的时候，在 `mHashes` 中重复碰撞的值，而在 `mArray` 中保存对应的 `key`，和 `value` 来保证数据的完整。

### 总结

- `1.5` 扩容：扩容阶段，`BaseSize` --> `2*BaseSize` --> `1.5` 倍扩容
- 缩容机制：大于 `2*BaseSize` 且数组使用率小于 `1/3`，缩容为已用大小的 `1.5` 倍。
- 哈希冲突：链表法
- 内存优化：~
- 非线程安全
- 数据结构：一个数组存储 `Hash` 值，一个数组存储 `key、value`
