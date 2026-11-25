# Ubuntu 24.04 LTS 安装（刷机）教程

> **目标系统**：Ubuntu 24.04 LTS "Noble Numbat"
> **建议版本**：下载最新的 24.04.x 点版本（如 24.04.3+），自带 HWE 新内核，对新硬件支持更好
> **适用范围**：普通 PC / 笔记本 / 迷你主机 / 双系统 / 服务器版；ARM 板卡与移动设备见第七节
> **文档日期**：2026-11-24

---

## 目录

1. [最短路径（老手版）](#一最短路径老手版)
2. [准备阶段](#二准备阶段)
3. [BIOS/UEFI 设置](#三biosuefi-设置刷机失败的高发区)
4. [安装过程（桌面版）](#四安装过程桌面版-2404-新安装器)
5. [装完后的必做配置](#五装完后的必做配置国内环境)
6. [服务器版 / 无人值守安装](#六服务器版--无人值守可选)
7. [特殊设备（ARM / 手机等）](#七特殊设备刷机的另一种含义)
8. [常见故障速查](#八常见故障速查)
9. [安装后验证](#九验证安装)
10. [安全检查清单](#十安全检查清单)

---

## 一、最短路径（老手版）

1. 备份数据
2. 下载 ISO 并校验 SHA256
3. 用 Rufus / Etcher 写 U 盘（GPT + UEFI）
4. BIOS 关 Secure Boot / Fast Boot，Intel RST 改 AHCI
5. U 盘启动 → 选 "Erase disk and install Ubuntu"
6. 装完执行 `sudo apt update && sudo apt full-upgrade -y`

下面是要点、坑位和细节。

---

## 二、准备阶段

### 2.1 确认硬件与架构

| 设备类型 | 架构 | 说明 |
|---|---|---|
| 普通 PC / 笔记本 / 迷你主机 | `amd64` (x86_64) | 本教程主流程 |
| 树莓派 / Jetson / 国产 ARM 板卡 | `arm64` | 安装方式不同，见第七节 |
| 老式 32 位机器 | `i386` | 24.04 已**不再支持** 32 位 x86，需用 18.04 或换设备 |

硬件最低要求：

- 内存：桌面版 ≥ 4 GB（推荐 8 GB+）
- 硬盘：≥ 25 GB（实际建议 60 GB+）
- U 盘：≥ 8 GB（会被完全清空）

### 2.2 备份

刷机会清空目标磁盘，务必先备份：

- **Windows 文件**：文档、照片、浏览器书签、软件许可证
- **Windows 激活**：数字许可证绑定主板，一般无需额外操作；零售密钥请记录
- **双系统用户**：记录分区布局（磁盘管理截图）
- **驱动与软件清单**：截图或导出列表，方便重装后恢复

### 2.3 下载 ISO 与校验

官方地址：<https://releases.ubuntu.com/24.04/>

需要下载三个文件：

```
ubuntu-24.04.x-desktop-amd64.iso
SHA256SUMS
SHA256SUMS.gpg
```

**校验哈希**（强烈建议，避免半包下载或镜像被篡改）：

```bash
# Linux
sha256sum -c SHA256SUMS --ignore-missing

# macOS
shasum -a 256 -c SHA256SUMS --ignore-missing
```

```powershell
# Windows PowerShell
Get-FileHash .\ubuntu-24.04.x-desktop-amd64.iso -Algorithm SHA256
```

将输出与 `SHA256SUMS` 中对应行逐位比对。

**校验签名**（可选，更严谨）：

```bash
gpg --keyid-format long --verify SHA256SUMS.gpg SHA256SUMS
```

### 2.4 制作启动 U 盘

U 盘会被清空，容量 ≥ 8 GB。

| 平台 | 工具 | 关键设置 |
|---|---|---|
| Windows | **Rufus** | 分区类型 **GPT**；目标系统 **UEFI (非 CSM)**；写入模式优先 ISO，失败切 DD |
| 全平台 | **balenaEtcher** | 默认设置即可，最省心 |
| 多 ISO 复用 | **Ventoy** | 先装 Ventoy 到 U 盘，再把 ISO 拷进去；老主板需在 Ventoy 菜单切 Grub2/Normal 模式 |
| Linux | `dd` | 见下方命令 |
| macOS | `dd` | 用 `/dev/rdiskN`（raw 设备）速度更快 |

```bash
# Linux
lsblk                                   # 先确认设备名，别写错盘！
sudo dd if=ubuntu-24.04.x-desktop-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync

# macOS
diskutil list                            # 找到 U 盘编号 diskN
diskutil unmountDisk /dev/diskN
sudo dd if=ubuntu-24.04.x-desktop-amd64.iso of=/dev/rdiskN bs=4m
```

> ⚠️ `dd` 无任何确认提示，会直接覆盖整块盘。执行前务必用 `lsblk` / `diskutil list` 反复确认设备名，不要选中系统盘。

### 2.5 在 macOS 上制作启动盘（详细步骤）

Mac 上做 Ubuntu 启动盘有两条路，任选其一。Apple Silicon（M1/M2/M3/M4）与 Intel Mac 流程完全一致。

#### 方案 A：balenaEtcher（推荐，最省心）

1. 下载 macOS 版：<https://etcher.balena.io/>（`.dmg` 文件），拖入「应用程序」后打开
2. `Flash from file` → 选择下载好的 ISO
3. `Select target` → 勾选 U 盘（**只勾 U 盘，别勾内置硬盘**）
4. 点 `Flash`，输入 Mac 登录密码授权
5. 若提示"无法打开，因为 Apple 无法检查其是否包含恶意软件"：
   打开 **系统设置 → 隐私与安全性**，在底部点「仍要打开」
6. 写入完成后 Etcher 会自动校验，显示 `Flash Complete!` 即可拔盘

#### 方案 B：命令行 dd（无需安装任何软件）

```bash
# 1. 校验 ISO（建议执行）
cd ~/Downloads
shasum -a 256 ubuntu-24.04.x-desktop-amd64.iso
# 与 SHA256SUMS 中的值比对

# 2. 找到 U 盘设备编号（重点看 SIZE 与 NAME，确认不是 Macintosh HD）
diskutil list

# 3. 卸载 U 盘（不要用 eject，eject 会弹出设备导致无法写）
diskutil unmountDisk /dev/diskN        # N 换成上一步看到的编号

# 4. 写入镜像（注意目标是 /dev/rdiskN，带 r 的 raw 设备）
sudo dd if=~/Downloads/ubuntu-24.04.x-desktop-amd64.iso of=/dev/rdiskN bs=4m

# 5. 查看进度：在原终端按 Ctrl+T；
#    或在另一个终端执行：sudo kill -INFO $(pgrep -x dd)

# 6. 写入完成后弹出
diskutil eject /dev/diskN
```

#### macOS 特有的注意事项

| 问题 | 说明与处理 |
|---|---|
| 用 `diskN` 而非 `rdiskN` | 不带 `r` 也能写，但速度慢数倍，务必用 `/dev/rdiskN` |
| `status=progress` 报错 | macOS 自带的是 BSD 版 dd，不支持该参数；看进度用 `Ctrl+T` 或 `kill -INFO` |
| 写完提示"此电脑不能读取您插入的磁盘" | **正常现象**，点「忽略」或「推出」即可，说明写入的是 ISO9660 混合镜像 |
| `dd: /dev/rdiskN: Resource busy` | 先执行 `diskutil unmountDisk /dev/diskN`；仍报错则重启 Mac 再试 |
| 找不到 Ventoy | Ventoy 官方没有 macOS 版本；需要 Ventoy 请借 Windows/Linux 机器制作一次 |
| 担心选错盘 | 执行前用 `diskutil list` 核对容量；内置盘通常显示 `Macintosh HD` 或 `Apple APFS`，切勿选中 |
| U 盘写完后在 Finder 中不可见 | 正常，启动盘不是普通存储盘；需要复用时用「磁盘工具」重新格式化为 exFAT |
| 写入后想恢复 U 盘 | 打开「磁盘工具」→ 选中 U 盘 → 抹掉 → 格式选 `exFAT` 或 `MS-DOS (FAT)` |

#### 验证启动盘是否写成功（可选）

```bash
diskutil list
# 正常会看到 U 盘上出现一个 Ubuntu/ISO9660 类型的分区
```

之后按第三节进入目标机器的 BIOS，选择 `UEFI: <U盘名>` 启动即可。用 Mac 做盘不影响后续在任何 x86 机器上安装。

---

## 三、BIOS/UEFI 设置（刷机失败的高发区）

### 3.1 进入启动菜单 / BIOS 的按键

| 品牌 | 启动菜单 | BIOS 设置 |
|---|---|---|
| 联想 | F12 | F2 / Fn+F2 |
| 联想 ThinkPad | F12 | F1 |
| 戴尔 | F12 | F2 |
| 惠普 | F9 | F10 |
| 华硕 | Esc / F8 | F2 / Del |
| 宏碁 | F12 | F2 |
| 微星 / 技嘉 | F11 / F12 | Del |

### 3.2 必须检查的项

- **Secure Boot（安全启动）**
  - Ubuntu 官方镜像支持 Secure Boot，可保持开启
  - 但安装 NVIDIA 闭源驱动、VirtualBox 等 DKMS 模块时，需要完成 **MOK 注册**：安装过程中会弹出蓝色界面，选择 `Enroll MOK` → `Continue` → 输入密码；重启后再进一次 MOK 界面确认
  - 不想折腾可先关闭 Secure Boot，装完再开
- **Fast Boot / 快速启动**：**关闭**（否则可能直接跳过 U 盘）
- **Intel RST / RAID / Optane 模式**：必须改成 **AHCI**，否则安装器看不到硬盘
  ```cmd
  :: Windows 下先执行，避免改 AHCI 后蓝屏
  bcdedit /set {current} safeboot minimal
  ```
  重启进 BIOS 改成 AHCI → 进 Windows 执行 `bcdedit /deletevalue {current} safeboot` → 正常重启
- **CSM / Legacy Boot**：**关闭**，使用纯 UEFI 模式
- **TPM**：仅在需要 24.04 的 TPM 全盘加密时开启

---

## 四、安装过程（桌面版，24.04 新安装器）

### 4.1 启动安装器

1. 插入 U 盘，开机按启动菜单键
2. 选择 `UEFI: <U盘名称>`
3. 在 GRUB 菜单选 **Try or Install Ubuntu**

**卡在黑屏 / 花屏 / LOGO 时的处理**：

- GRUB 菜单按 `e` 编辑启动项，在 `linux` 行末追加 `nomodeset`，按 `Ctrl+X` 启动
- 或直接在启动菜单选 **Safe graphics** 模式
- 装好后想永久生效：编辑 `/etc/default/grub` 中的 `GRUB_CMDLINE_LINUX_DEFAULT`，然后 `sudo update-grub`

### 4.2 双系统特别注意

1. Windows 中关闭「快速启动」：控制面板 → 电源选项 → 选择电源按钮功能 → 取消勾选
2. BitLocker 先 **暂停保护**（不是关闭），装完 Ubuntu 再恢复
3. Windows 磁盘管理中压缩卷，留出 ≥ 60 GB **未分配**空间
4. 安装时选择 **Install alongside** 或 **Manual installation**，指定这块未分配空间
5. 时间同步问题（Ubuntu 用 UTC，Windows 用本地时间）：
   ```bash
   timedatectl set-local-rtc 0     # Ubuntu 侧改为 UTC
   ```
   或在 Windows 侧改注册表 `HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation` 添加 `RealTimeIsUniversal=1`（DWORD），两边统一用 UTC

### 4.3 安装向导逐项说明

1. **语言 / 键盘**：中文环境选「中文（简体）」，键盘选 `Chinese` / `English (US)`
2. **网络**：建议联网，安装器会顺带下载更新与第三方驱动
3. **安装类型**（24.04 新安装器分两类）：
   - **Interactive installation**：常规交互式安装
   - **Automated installation**：读取 autoinstall.yaml 无人值守（见第六节）
   - 交互式内还可选 **Default selection**（最小安装）或 **Extended selection**（含办公套件、工具等完整包）
4. **第三方软件**：勾选 "Install third-party software for graphics and Wi-Fi hardware"——NVIDIA 显卡、部分无线网卡必需
5. **磁盘方案**：
   - **Erase disk and install Ubuntu**：整盘清空，最简单
   - **Manual installation**：自定义分区，推荐见 4.4
   - **Install alongside**：保留 Windows 双系统
   - 可选 **LUKS 全盘加密**：会要求设置密码，**务必牢记**，丢失即数据不可恢复
6. **账户**：用户名全小写、无空格；密码用于 sudo
7. **时区**：`Asia/Shanghai`
8. 等待完成 → **Restart Now** → **拔掉 U 盘**

### 4.4 手动分区建议（UEFI + GPT）

| 挂载点 | 大小 | 文件系统 | 说明 |
|---|---|---|---|
| `/boot/efi` | 1 GB | FAT32 (EFI System) | 已有 Windows 时**复用现有 ESP**，不要新建 |
| `/` | 60–100 GB | ext4 | 系统与软件 |
| `/home` | 剩余空间 | ext4 | 数据独立，便于日后重装保留 |
| swap | 不建分区 | — | 24.04 默认使用 `/swapfile`；内存 ≥ 16 GB 可不配 |

> **注意**：24.04 的新安装器**默认不再提供 ZFS 根**（旧版有）。需要 ZFS 根请用服务器版或手动安装。TPM 全盘加密属于实验特性，谨慎用于生产。

---

## 五、装完后的必做配置（国内环境）

```bash
# 1. 更新系统
sudo apt update && sudo apt full-upgrade -y

# 2. 换国内源（24.04 使用 deb822 格式）
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
sudo sed -i \
  -e 's|http://archive.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' \
  -e 's|http://security.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' \
  /etc/apt/sources.list.d/ubuntu.sources
sudo apt update

# 3. 驱动（NVIDIA 等）
ubuntu-drivers devices
sudo ubuntu-drivers install

# 4. 中文输入法（fcitx5）
sudo apt install -y fcitx5 fcitx5-chinese-addons \
  fcitx5-frontend-gtk4 fcitx5-frontend-qt5
im-config -n fcitx5          # 注销重新登录后生效

# 5. 常用工具
sudo apt install -y build-essential git curl vim htop
```

**其他建议**：

- 用 **Timeshift** 做系统快照，折腾前先打点：`sudo apt install timeshift`
- 笔记本电源管理：`sudo apt install tlp tlp-rdw && sudo systemctl enable --now tlp`
- 确认启动模式：`[ -d /sys/firmware/efi ] && echo UEFI || echo Legacy`

### 可选：其他国内镜像源

| 镜像 | 地址 |
|---|---|
| 清华 TUNA | `https://mirrors.tuna.tsinghua.edu.cn/ubuntu/` |
| 阿里云 | `https://mirrors.aliyun.com/ubuntu/` |
| 中科大 USTC | `https://mirrors.ustc.edu.cn/ubuntu/` |
| 华为云 | `https://mirrors.huaweicloud.com/ubuntu/` |

---

## 六、服务器版 / 无人值守（可选）

### 6.1 服务器版交互安装

服务器版 ISO 同样 U 盘启动，安装器为 **subiquity**，流程：

语言 → 网络 → 存储 → 用户 → SSH → 快照包（可选）→ 安装

### 6.2 autoinstall 无人值守

1. 准备 `user-data`（cloud-init 格式，顶层含 `#cloud-config` 和 `autoinstall:` 段）与空的 `meta-data`
2. 放到 HTTP 服务，或第二块 U 盘（卷标设为 `CIDATA`）
3. 启动时 GRUB 按 `e`，内核行追加：

   ```text
   # 网络方式
   autoinstall ds=nocloud-net;s=http://<server>/
   # 本地 CIDATA 方式
   autoinstall ds=nocloud;s=/cdrom/
   ```

4. 最小示例：

   ```yaml
   #cloud-config
   autoinstall:
     version: 1
     identity:
       hostname: node01
       username: ubuntu
       password: "$6$..."          # mkpasswd -m sha-512 生成
     storage:
       layout:
         name: direct
     ssh:
       install-server: true
     packages: [vim, curl]
     late-commands:
       - curtin in-target -- timedatectl set-timezone Asia/Shanghai
   ```

生成密码哈希：

```bash
mkpasswd -m sha-512
# 或
openssl passwd -6
```

---

## 七、特殊设备（"刷机"的另一种含义）

| 设备 | 方法 |
|---|---|
| **树莓派 4 / 5** | 官方 **Raspberry Pi Imager** 直接选 Ubuntu 24.04 Desktop/Server (arm64)；写盘前可预配置 Wi-Fi、SSH、用户名 |
| **NVIDIA Jetson** | 宿主 Ubuntu 上运行 **SDK Manager** 刷 JetPack；或用官方镜像 + Etcher |
| **安卓手机 / 平板** | 解锁 bootloader → 刷 recovery（TWRP）→ 刷 **Ubuntu Touch**（基于 24.04 的适配仍在推进，机型支持有限）；非官方适配有变砖风险 |
| **路由器 / 开发板** | 使用厂商镜像 + `dd` 或厂商工具；注意 U-Boot 与分区布局差异 |

> 以上设备差异极大，建议提供**具体型号**后再执行，避免刷错镜像变砖。

---

## 八、常见故障速查

| 现象 | 原因 / 解决方法 |
|---|---|
| 安装器看不到硬盘 | Intel RST/RAID 模式未改 AHCI；或 NVMe 需更新 BIOS 固件 |
| U 盘启动直接进 Windows | BIOS 未关 Fast Boot；启动项顺序不对；U 盘是 Legacy 写入但机器为纯 UEFI |
| 卡在 Ubuntu LOGO / 花屏 | 加 `nomodeset` 或选 Safe graphics；NVIDIA 新卡可试 `nomodeset nouveau.modeset=0` |
| `Failed to enroll MOK` / 驱动不生效 | Secure Boot 下需完成 MOK 注册，或关闭 Secure Boot |
| 装完 GRUB 找不到 Windows | `sudo os-prober` + `sudo update-grub`；确认 Windows 的 ESP 未被覆盖 |
| 双系统时间差 8 小时 | `timedatectl set-local-rtc 0`；Windows 侧设 `RealTimeIsUniversal=1` |
| 安装到一半报错退出 | 重新校验 ISO；更换 U 盘；换 USB 2.0 接口；Rufus 改 DD 模式重写 |
| 开机直接进 `grub>` 提示符 | 引导损坏，用 Live USB + `boot-repair` 修复 |
| Wi-Fi 不识别 | 安装时勾选第三方驱动；或事后 `ubuntu-drivers install`；Broadcom 需 `bcmwl-kernel-source` |
| 亮度 / 休眠异常 | 更新 BIOS；NVIDIA 卡加内核参数 `acpi_backlight=vendor` |

---

## 九、验证安装

```bash
lsb_release -a          # 应显示 Ubuntu 24.04.x LTS
uname -r                # 内核版本
[ -d /sys/firmware/efi ] && echo "UEFI 启动"
sudo fdisk -l           # 分区是否符合预期
systemctl --failed      # 应无失败单元
```

---

## 十、安全检查清单

安装完成后逐项确认：

- [ ] ISO 已完成 SHA256 校验
- [ ] 系统为 UEFI 启动，Secure Boot 状态符合预期
- [ ] 全盘加密密码 / 恢复密钥已妥善保存（若有）
- [ ] 已安装所有安全更新：`sudo apt update && sudo apt full-upgrade`
- [ ] 防火墙已启用：`sudo ufw enable && sudo ufw status`
- [ ] SSH 已按需配置（禁用密码登录、改端口、限制用户）
- [ ] 已创建系统快照（Timeshift）
- [ ] 双系统用户：Windows BitLocker 已恢复保护
- [ ] 时间同步正常：`timedatectl status` 显示 `System clock synchronized: yes`

---

## 附录：官方资源

- Ubuntu 24.04 下载：<https://releases.ubuntu.com/24.04/>
- 官方桌面安装文档：<https://ubuntu.com/tutorials/install-ubuntu-desktop>
- 服务器 autoinstall 文档：<https://ubuntu.com/server/docs/install/autoinstall>
- Ubuntu 论坛：<https://discuss.ubuntu.com/>
- Ask Ubuntu：<https://askubuntu.com/>

---

*本文档基于 Ubuntu 24.04 LTS 编写，24.04.x 点版本界面可能略有差异，核心流程一致。*
