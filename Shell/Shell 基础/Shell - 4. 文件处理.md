### 逐行读取文件
```sh
#!/bin/bash

target_dir="/path/to/directory"

# 遍历目录中的文件
find "$target_dir" -type f | while IFS= read -r file; do
    echo "Processing $file"
    while IFS= read -r line; do
        # 示例处理逻辑：打印行号和内容
        echo "Line: $line"
    done < "$file"
done
```
