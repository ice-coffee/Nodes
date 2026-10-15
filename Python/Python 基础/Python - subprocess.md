[subprocess --- 子进程管理](https://docs.python.org/zh-cn/3.13/library/subprocess.html#)

```python
import subprocess

# 执行多条命令
result = subprocess.run('ls -l | grep ".py"', shell=True, capture_output=True, text=True)

print("Filtered Output:")
print(result.stdout)
```
