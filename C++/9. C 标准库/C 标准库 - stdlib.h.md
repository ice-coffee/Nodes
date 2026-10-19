[toc]
## 简介

`<stdlib.h>` 是 C 标准库中提供“通用工具函数”的头文件，主要功能包括：

1. **动态内存分配**：管理程序运行时的堆内存。
2. **程序控制**：如退出程序、环境变量操作等。
3. **数学相关**：如整数取整、绝对值、随机数。
4. **排序与搜索**：提供通用的排序和二分搜索函数。
5. **类型转换**：字符串与数字的相互转换。

它可以看作是一个“多功能工具箱”，大多数 C 程序都会使用它。

## 内存管理

* **malloc / calloc / realloc / free**

```c
int *arr = (int*)malloc(10 * sizeof(int)); // 分配内存
if (!arr) exit(EXIT_FAILURE);             // 分配失败退出
free(arr);                                // 释放内存

int *arr2 = (int*)calloc(10, sizeof(int)); // calloc 会初始化为 0
arr2 = (int*)realloc(arr2, 20 * sizeof(int)); // 扩展或缩小内存
```

## 程序控制

* **exit(int status)**：正常或非正常退出程序。
* **abort()**：非正常终止程序（生成 core dump）。
* **atexit(void (\*func)(void))**：注册程序结束时调用的函数。

```c
void goodbye() { printf("Goodbye!\n"); }

int main() {
    atexit(goodbye);
    exit(0); // 结束程序时会调用 goodbye
}
```

## 字符串与数值转换

* **atoi / atol / atoll**：字符串转整数。
* **strtol / strtoul / strtod / strtof / strtold**：更安全的转换函数，可以检查错误。

```c
const char *s = "12345";
int n = atoi(s);
long l = strtol(s, NULL, 10); // 支持进制转换
```

## 随机数

* **rand()**：生成 0\~RAND\_MAX 的伪随机整数。
* **srand(unsigned int seed)**：设置随机种子。

```c
srand(time(NULL));
int r = rand() % 100; // 生成 0~99 的随机数
```

## 排序与搜索

* **qsort(void *base, size\_t nmemb, size\_t size, int (*compar)(const void*, const void*))**：通用排序。
* **bsearch(const void \*key, const void *base, size\_t nmemb, size\_t size, int (*compar)(const void*, const void*))**：二分查找。

```c
int cmp(const void *a, const void *b) {
    return *(int*)a - *(int*)b;
}

int arr[5] = {5, 2, 3, 1, 4};
qsort(arr, 5, sizeof(int), cmp);

int key = 3;
int *found = (int*)bsearch(&key, arr, 5, sizeof(int), cmp);
```

## 其他工具函数

* **abs / labs / llabs**：求整数绝对值。
* **div / ldiv / lldiv**：求商和余数。
* **getenv(const char \*name)**：获取环境变量。
* **system(const char \*command)**：执行 shell 命令。

```c
char *path = getenv("PATH");
printf("PATH = %s\n", path);

system("ls -l");
```

---

## 注意事项

1. **内存分配失败**：`malloc` / `calloc` 可能返回 `NULL`，需要检查。
2. **类型转换安全**：`atoi` 不会报错，推荐使用 `strtol` 系列函数。
3. **`system()` 的安全性**：可能存在安全风险，尤其是处理用户输入时。
4. **排序与搜索函数**：`qsort` 和 `bsearch` 都需要提供比较函数，并且数组必须是连续内存。
