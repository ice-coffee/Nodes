[toc]

### 数据结构

[数据结构](https://app.yinxiang.com/shard/s58/nl/10744683/0762d8bc-fe96-4e49-b92f-919558e9587c/)
### 算法
#### 哈希算法

#### 冒泡排序、插入排序、选择排序、归并排序、快速排序、二分法查找
```
/**
 * 排序算法
 * 冒泡排序、插入排序、选择排序、归并排序、快速排序、二分法查找
 */
public class Sort {
    /**
     * 冒泡排序
     */
    private void bubbleSort(int[] array) {
        if (array.length == 0) {
            return;
        }

        boolean flag = false;
        for (int i = 0; i < array.length; i++) {
            for (int j = 0; j < array.length - i - 1; j++) {
                if (array[j] > array[j + 1]) {
                    int temp = array[j + 1];
                    array[j + 1] = array[j];
                    array[j] = temp;
                    flag = true;
                }
            }
            if (!flag) {
                break;
            }
        }
    }

    /**
     * 插入排序
     */
    private void insertionSort(int[] array) {
        if (array.length == 0) {
            return;
        }

        for (int i = 1; i < array.length; i++) {
            int value = array[i];
            int j = i - 1;
            for (; j >= 0; j--) {
                if (value < array[j]) {
                    array[j + 1] = array[j];
                } else {
                    break;
                }
            }
            array[j + 1] = value;
        }
    }

    /**
     * 选择排序
     */
    private void selectionSort(int[] array) {
        if (array.length  == 0) {
            return;
        }

        for (int i = 0; i < array.length; i++) {
            int pos = i;
            for (int j = i; j < array.length; j++) {
                if (array[j] < array[pos]) {
                    pos = j;
                }
            }

            if (pos != i) {
                int temp = array[pos];
                array[pos] = array[i];
                array[i] = temp;
            }
        }
    }

    /**
     * 归并排序
     * @param array
     */
    private void mergeSort(int[] array) {
        mergeSortc(array, 0, array.length - 1);
    }

    /**
     * 归并排序 - 递归算法
     */
    private void mergeSortc(int[] array, int p, int r) {
        if (p >= r) {
            return;
        }

        int q = (p + r) / 2;
        mergeSortc(array, p, q);
        mergeSortc(array, q + 1, r);

        merge(array, p, q, r);
    }

    /**
     * 归并排序 - 合并算法
     */
    private void merge(int[] array, int p, int q, int r) {
        int i = p, j = q + 1, k = 0;
        int[] mergeArray = new int[r - p + 1];
        while (i <= q && j <= r) {
            if (array[i] <= array[j]) {
                mergeArray[k++] = array[i++];
            } else {
                mergeArray[k++] = array[j++];
            }
        }

        int start = i, end = q;
        if (j <= r) {
            start = j;
            end = r;
        }
        for (int b = start; b <= end; b++) {
            mergeArray[k++] = array[b];
        }

        for (int a = 0; a < mergeArray.length; a++) {
            array[p + a] = mergeArray[a];
        }
    }

    /**
     * 快速排序
     */
    private void quickSort(int[] array) {
        quickSortc(array, 0, array.length - 1);
    }

    /**
     * 快速排序 - 递归算法
     */
    private void quickSortc(int[] array, int p, int r) {
        if (p >= r) {
            return;
        }

        int q = partition(array, p, r);

        quickSortc(array, p, q - 1);
        quickSortc(array, q + 1, r);
    }

    /**
     * 快速排序 - 中点算法
     */
    private int partition(int[] array, int p, int r) {
        int pivot = array[r];
        int i = p;
        for (int j = p; j < r; j++) {
            if (array[j] < pivot) {
                int temp = array[i];
                array[i] = array[j];
                array[j] = temp;
                i++;
            }
        }

        int temp = array[i];
        array[i] = array[r];
        array[r] = temp;

        return i;
    }

    /**
     * 二分法查找
     */
    private int bsearch(int[] array, int val) {
        int low = 0;
        int high = array.length - 1;

        while (low < high) {
            int middle = low + ((high - low) >> 1);
            if (array[middle] == val) {
                return middle;
            } else if (array[middle] < val) {
                low = middle + 1;
            } else {
                high = middle - 1;
            }
        }
        return -1;
    }

    public static void main(String[] args) {
        Sort mopao = new Sort();
        Random random = new Random();
        int[] array = new int[100];

        for (int i = 0; i < array.length; i++) {
            array[i] = random.nextInt(100);
        }

        mopao.quickSort(array);
        for (int a : array) {
            System.out.print(a + ", ");
        }
        System.out.println();

        int searchResult = mopao.bsearch(array, 72);
        System.out.println(searchResult);
    }
}
```

#### 递归算法
方法或函数调用自身的方式称为递归调用，调用称为递，返回称为归。

一个问题只要同时满足以下3个条件，就可以用递归来解决：
1. 问题的解可以分解为几个子问题的解。何为子问题？就是数据规模更小的问题。
2. 问题与子问题，除了数据规模不同，求解思路完全一样。
3. 存在递归终止条件。

优点：

- 代码的表达力很强，写起来简洁。

缺点：

- 空间复杂度高、有堆栈溢出风险、存在重复计算、过多的函数调用会耗时较多等问题。

缺点解答：

- 空间复杂度高：递归每一次调用都会在内存栈中保存一次现场数据。
- 有堆栈溢出风险：系统栈或者虚拟机栈空间一般都不大。如果递归求解的数据规模很大，调用层次很深，一直压入栈，就会有堆栈溢出风险。可以通过限制最大深度的方式解决这个问题。但是最大深度的计算比较麻烦，需要判断内存空间大小等因素。
- 重复计算：递归分解后的方法调用可能存在重复掉用同一数据计算的情况。可将已处理过的数据和结果保存在某种数据结构中解决（比如Map）。
- 耗时较多：每次函数调用都会有一定的耗时，聚沙层塔。

#### 字符串匹配算法
