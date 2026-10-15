### get_filename_component
> 在 `3.20` 以上版本中，推荐使用 `cmake_path` 来操作文件路径。

### cmake_path
在 `CMake 3.20` 以上版本中，`cmake_path` 提供了灵活操作文件路径的方式。

1. `cmake_path(SET)`

`SET` 用于构造一个路径，允许将多个路径组件拼接成一个完整路径。

```cmake
cmake_path(SET result_path
    BASE_DIRECTORY /home/user
    APPEND subdir file.txt)
```

这个示例会将 result_path 设置为 /home/user/subdir/file.txt。

2. `cmake_path(GET)`

`GET` 用于提取路径的特定部分，如文件名、扩展名、目录等。

```cmake
cmake_path(GET /home/user/file.txt PARENT_PATH parent_path)
```
