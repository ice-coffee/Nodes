查看Ubuntu版本命令：
```
lsb_release -a
```

升级过程：
（1）更新apt
```
sudo apt-get update
sudo apt-get upgrade
sudo apt dist-upgrade
```
（2）安装update-manager-core
```
sudo apt-get install update-manager-core
```
（3）更新16.04到18.04
```
sudo do-release-upgrade
```
（4）清理无用的安装包
```
sudo apt-get remove
```
（5）重启
```
sudo reboot
```

### 障碍
#### Failed to connect to dl.google.com
[链接](https://www.jianshu.com/p/01354d90e199)

#### Your python3 install is corrupted. Please fix the '/usr/bin/python3'  symlink.

[链接](https://askubuntu.com/questions/1104052/your-python3-install-is-corrupted)

#### 花屏
https://blog.csdn.net/tom17/article/details/121728969
