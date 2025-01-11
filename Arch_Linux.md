# Arch Linux

参考资料：[Guide](https://arch.icekylin.online/guide/)、[Arch LinuxTutorial](https://archlinuxstudio.github.io/ArchLinuxTutorial/#/)

[toc]

### 网络和磁盘准备

现今系统安装基本都以 UEFI + GPT 形式进行，另外 arch linux 的安装需要依赖网络，其中如果使用无线网络安装建议使用英文 WiFi 名称，否则只能依赖于 TAB 补全。

如果安装的目的是实现双系统不是全新安装，且两个系统共存在同一块设备上，需要先在磁盘中压缩出分配给另一个系统的空闲磁盘大小（这里，只需要有空闲空间即可，不要为分出来的空间创建分区）

> 注意：如果 Arch Linux 和 Windows 需要共存在同一个 EFI 分区上，需要提前检查该分区的容量，如果小于256 或者 521 MB，建议扩容，否则需要分开启动。[挂载点](https://wiki.archlinuxcn.org/wiki/EFI_%E7%B3%BB%E7%BB%9F%E5%88%86%E5%8C%BA#%E5%85%B8%E5%9E%8B%E6%8C%82%E8%BD%BD%E7%82%B9)

### 刻录 U 盘，启动盘

在[下载页面](https://archlinux.org/download/)下选择最新的镜像和签名（可选）Windows 下可以使用 [Ventoy](https://www.ventoy.net/cn/doc_start.html)、Rufus 等刻录软件，Linux 下也可以使用 dd 命令进行刻录（/dev/sdx 即为 U 盘）：

```bash
$ sudo dd bs=4M if=/path/to/archlinux.so of=/dev/sdx status=progress oflag=sync
```

> 推荐 Ventoy，只需安装一次，无需频繁格式化，剩下的就是把各种 .iso 文件拷贝后 U 盘即可。注意：将签名文件和 iso 镜像置于同一文件夹，随后进行对镜像的签名校验。
>
> ```bash
> $ gpg --keyserver-options auto-key-retrieve --verify archlinux-20xx.xx.01-x86_64.iso.sig archlinux-20xx.xx.01-x86_64.iso
> ```

### 进入 BIOS 进行设置

插入 U 盘开机，按下 F2 或 DEL 等键（或者在 Window 中摁住 `Shift` 键同时点击 `重启`）进入 BIOS 界面，找到 **Secure Boot** 选项，Disable 将其禁用；检查 boot 或 **Boot Mode** 选项为 UEFI（only）；调整 **Boot Options** 选项，将 USB 启动顺序调至首位。最后退出保存，系统重启。

### 进入 Arch Linux 安装环境

选择 Arch Linux install medium (x86_64, UEFI) 进入安装环境。

1. 推荐：查看、禁用 reflector 服务

   ```bash
   $ systemctl stop reflector.service
   $ systemctl status reflector.service
   ```

2. 个人推荐：禁用蜂鸣器模块：

   ```bash
   $ rmmod pcspkr
   ```

   > 可根据情况，考虑永久禁用蜂鸣器！真的很吵。

   ```bash
   $ sudoedit /etc/modprobe.d/blacklist.conf
   $ blacklist pcspkr
   ```

3. 连接网络

   ```bash
   $ iwctl                           #执行iwctl命令，进入交互式命令行
   $ device list                     #列出设备名，比如无线网卡看到叫 wlan0
   $ station wlan0 scan              #扫描网络
   $ station wlan0 get-networks      #列出网络 比如想连接YOUR-WIRELESS-NAME这个无线
   $ station wlan0 connect YOUR-WIRELESS-NAME #进行连接 输入密码即可
   $ exit                            #成功后exit退出
   $ ping bilibili.com 			  #测试网络连接
   ```

   > 注意：安装环境中，可以使用 TAB 补全，和常见的 Emacs 风格的 terminal 终端 shortcut 快捷键。

4. 查看磁盘分区

   ```bash
   $ fdisk -l
   # 如果需要在一整块磁盘上进行系统全新安装：
   $ parted /dev/sdx # 执行 parted，进行磁盘类型变更
   (parted) mktable # 输入 mktable 建议新的分区表
   New disk label type? gpt # 输入 gpt，将磁盘类型转换为 GPT 类型。如磁盘有数据会警告，输入 Yes
   (parted) quit # 退出 parted 命令行交互
   ```

   > 重建分区表会使磁盘所有数据丢失，请事先确认。
   >
   > 安装的磁盘名称为 sdx。如果使用 NVME 的固态硬盘，设备名称为 nvme0n1

   分区与格式化（Btrfs）

   ```bash
   # 分区，危险！请仔细检查命令和操作的正确性，否则将出现不可预料的情况。
   # Confirm partition content
   # EFI 分区（可以和现存 Windows 系统并存，需要有，且不能太小）Swap 分区，再只需要一个分区即可
   $ cfdisk /dev/sdx
   # 当不确定分区内容时，可以使用下面命令挂载查看后再解挂，尽量只对空闲空间操作，除非全新安装。
   $ sudo mount /dev/sdXn /mnt
   $ ls /mnt
   $ sudo umount /mnt
   # 格式化
   $ mkfs.vfat /dev/efi_partition 	   # EFI 分区，兼容性
   $ mkfs.fat -F32 /dev/efi_partition # EFI 分区，两选一即可
   $ mkswap /dev/swap_partition
   $ mkfs.btrfs -L Arch /dev/next_partition # -L 选项后指定该分区的 LABLE
   ```

   挂载已分区（格式化）磁盘

   ```bash
   # 如果分区修改后有分区表不同步的情况，导致格式化失败，可 reboot 后重置。
   $ mount -t btrfs -o compress=zstd /dev/sdxn /mnt
   $ btrfs subvolume create /mnt/@ # 创建 / 目录子卷
   $ btrfs subvolume create /mnt/@home # 创建 /home 目录子卷
   $ btrfs subvolume list -p /mnt
   $ umount /mnt
   # 挂载时，挂载是有顺序的，先挂载根分区，再挂载 EFI 分区
   $ mount -t btrfs -o subvol=/@,compress=zstd /dev/sdxn /mnt # 挂载 / 目录
   $ mkdir /mnt/home # 创建 /home 目录
   $ mount -t btrfs -o subvol=/@home,compress=zstd /dev/sdxn /mnt/home # 挂载 /home 目录
   $ mkdir -p /mnt/boot # 创建 /boot 目录
   $ mount /dev/efi_partition /mnt/boot # 挂载 EFI 分区（注意！！！） /boot 目录
   $ swapon /dev/swap_partition # 挂载交换分区
   ```

5. 更换镜像源

   使用如下命令编辑镜像列表：

   ```bash
   $ vim /etc/pacman.d/mirrorlist
   ```

   其中的首行是将会使用的镜像源。添加中科大或者清华的放在最上面即可。

   ```
   Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
   Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
   # Below Need Magic.
   Server = https://mirror.archlinux.tw/ArchLinux/$repo/os/$arch   #东亚地区:中华民国
   Server = https://mirror.aktkn.sg/archlinux/$repo/os/$arch    #东南亚地区:新加坡
   Server = https://mirrors.cat.net/archlinux/$repo/os/$arch    #东亚地区:日本
   ```

6. 安装系统

   ```bash
   $ pacstrap /mnt base base-devel linux linux-headers linux-firmware btrfs-progs
   $ pacstrap /mnt networkmanager vim sudo zsh zsh-completions
   ```

   > 如果提示 GPG 证书错误，可能是因为使用的不是最新的镜像文件，可以通过更新 `sudo pacman -S archlinux-keyring` 解决此问题

7. 生成 fstab 文件

   ```bash
   $ genfstab -U /mnt > /mnt/etc/fstab
   $ cat /mnt/etc/fstab	# 可以看下，已然迟矣，聊表慰藉。
   ```

8. change root

   ```bash
   $ arch-chroot /mnt
   $ vim /etc/hostname
   # 键入主机名
   $ vim /etc/hosts
   127.0.0.1   localhost
   ::1         localhost
   127.0.1.1   <hostname> <hostname>.localdomain
   $ passwd root
   ```

9. 时区设置，Locale 本地化

   ```bash
   $ ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
   $ hwclock --systohc
   
   $ vim /etc/locale.gen
   # 去掉 en_US.UTF-8 所在行以及 zh_CN.UTF-8 所在行的注释符号（#）
   $ locale-gen
   $ echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
   
   # 安装微码
   $ pacman -S intel-ucode   #Intel
   $ pacman -S amd-ucode     #AMD，二选一即可
   ```

10. 安装引导程序

    ```bash
    $ pacman -S grub efibootmgr os-prober  #grub 是启动引导器，efibootmgr被 grub 脚本用来将启动项写入 NVRAM。os-prober 为了能够引导 win10 双系统，需要安装 os-prober 以检测到它
    $ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
    $ vim /etc/default/grub
    # 去掉 GRUB_CMDLINE_LINUX_DEFAULT 一行中最后的 quiet 参数
    # 把 loglevel 的数值从 3 改成 5。这样是为了后续如果出现系统错误，方便排错
    # 加入 nowatchdog 参数，这可以显著提高开关机速度，nowatchdog 参数无法禁用英特尔的看门狗硬件，改为 modprobe.blacklist=iTCO_wdt 即可
    # KDE6 默认使用 wayland session 为默认，如果你需要使用 wayland,则需开启 DRM。同样编辑/etc/default/grub 文件，在GRUB_CMDLINE_LINUX_DEFAULT一行中最后的加入参数：nvidia_drm.modeset=1
    # 为了引导 win10，则还需要添加或取消 GRUB_DISABLE_OS_PROBER=false 这一行的注释
    $ grub-mkconfig -o /boot/grub/grub.cfg
    # 注意一下，如果这里还检测不到 Windows，需要手动干预一下。 
    $ mkdir /boot/EFI/win #创建Windows的启动项挂载路径
    $ mount /dev/nvme0n1p1 /boot/EFI/win #挂载Windows的启动项
    $ grub-mkconfig -o /boot/grub/grub.cfg #再次更新
    ```

11. 完成基础安装

    ```bash
    $ exit                # 退回安装环境#
    $ umount -R  /mnt     # 卸载新分区
    $ reboot              # 重启
    
    $ systemctl enable --now NetworkManager # 设置开机自启并立即启动 NetworkManager 服务
    $ ping www.bilibili.com # 测试网络连接
    $ nmtui				  # 配置网络
    $ useradd -m -G wheel -s /bin/zsh <user> # 添加用户
    $ passwd <user>		  # 设置新用户密码
    $ vim /etc/pacman.conf
    # 去掉[multilib]一节中两行的注释，来开启 32 位库支持。
    $ pacman -Syyu  	  # 更新系统
    ```

    > 重启时，记得拔掉 U 盘。

### 完成桌面、基础用户配置

```bash
$ EDITOR=vim visudo  # 需要以 root 用户运行 visudo 命令
# 取消 #%wheel ALL=(ALL:ALL) ALL 的注释
#  %wheel 代表是 wheel 组，百分号是前缀 ALL= 代表在所有主机上都生效(如果把同样的sudoers文件下发到了多个主机上) (ALL) 代表可以成为任意目标用户 ALL 代表可以执行任意命令
# 用户名/%用户组名 主机名=(目标用户名:目标用户组) 命令1, 命令2, !命令3
$ pacman -S plasma-meta konsole dolphin # plasma-meta 元软件包、konsole 终端模拟器和 dolphin 文件管理器
$ pacman -S  plasma-workspace xdg-desktop-portal
# N 卡用户需要额外安装 pacman -S egl-wayland
$ systemctl enable sddm
$ reboot

$ sudo vim /etc/profile
#export EDITOR='vim' 
$ sudo pacman -S sof-firmware alsa-firmware alsa-ucm-conf      #一些可能需要的声音固件
$ sudo pacman -S ntfs-3g                                       #识别NTFS格式的硬盘
$ sudo pacman -S adobe-source-han-serif-cn-fonts wqy-zenhei    #安装几个开源中文字体 一般装上文泉驿就能解决大多wine应用中文方块的问题
$ sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra	#安装谷歌开源字体及表情
$ sudo pacman -S firefox chromium                              #安装常用的火狐、谷歌浏览器
$ sudo pacman -S ark                                           #与dolphin用右键解压
$ sudo pacman -S p7zip unrar unarchiver lzop lrzip             #安装ark可选依赖
$ sudo pacman -S packagekit-qt6 packagekit appstream-qt appstream  #确保Discover(软件中心）可用 需重启
$ sudo pacman -S gwenview                                      #图片查看器
$ sudo pacman -S git wget kate bind  						   #一些工具

# 搜索如何安装yay,简单的 $pacman -S yay 是不可以的哦。
# clone the Repository and Build 或 se Precompiled Binaries in mirror
$ sudo systemctl enable --now bluetooth							# 启动蓝牙
```

1. 设置 DNS：

   ```bash
   $ vim /etc/resolv.conf
   
   # 删除已有条目，并将如下内容加入其中
   #nameserver 8.8.8.8
   #nameserver 2001:4860:4860::8888
   #nameserver 8.8.4.4
   #nameserver 2001:4860:4860::8844
   
   #如果你的路由器可以自动处理 DNS,resolvconf 会在每次网络连接时用路由器的设置覆盖本机/etc/resolv.conf 中的设置，执行如下命令加入不可变标志，使其不能覆盖如上加入的配置。
   
   $ sudo chattr +i /etc/resolv.conf
   ```

2. 设置中文输入法：

   ```bash
   $ sudo pacman -S fcitx5-im #基础包组
   $ sudo pacman -S fcitx5-chinese-addons #官方中文输入引擎
   $ sudo pacman -S fcitx5-anthy #日文输入引擎
   $ sudo pacman -S fcitx5-pinyin-zhwiki #中文维基百科词库
   $ sudo pacman -S fcitx5-material-color #主题
   
   $ sudo vim /etc/environment 或者 $ vim ~/.config/environment.d/im.conf
   # X11 加入以下内容
   GTK_IM_MODULE=fcitx
   QT_IM_MODULE=fcitx
   XMODIFIERS=@im=fcitx
   SDL_IM_MODULE=fcitx
   GLFW_IM_MODULE=ibus
   # Wayland 加入以下内容
   XMODIFIERS=@im=fcitx
   # 在基于 Chromium 的程序（包括浏览器和使用 Electron 的程序）中加入 --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime 启动参数。
   
   打开 系统设置 > 区域设置 > 输入法
   点击提示信息中的 运行 Fcitx，再点击 添加输入法 > 找到简体中文下的 Pinyin > 点击 添加 即可加入拼音输入法，Pinyin 右侧的配置按钮 > 点选 云拼音 和 在程序中显示预编辑文本 > 最后点击 应用。
   ```

3. 设置 Timeshift 快照：

   ```bash
   $ sudo pacman -S timeshift
   $ sudo systemctl enable --now cronie.service
   # 打开 Timeshift,启动设置向导
   ```

4. 显卡驱动

   ```bash
   # Intel
   $ sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel
   # ANMD 开源驱动
   $ sudo pacman -S mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
   # Nvidia 英伟达显卡建议使用闭源驱动
   $ sudo pacman -S nvidia nvidia-settings lib32-nvidia-utils
   # 上述显卡驱动，推荐区官方或者 Arch Linux 论坛，详细看看。
   
   $ sudo pacman -S nvidia-prime
   $ yay -S optimus-manager optimus-manager-qt
   $ sudo systemctl enable optimus-manager.service
   ```

### Proxy 的 Magic 魔法学院

```bash
$ sudo pacman -S v2ray v2raya
$ yay -S v2raya-bin	# $sudo pacman -S v2raya 失败时
$ sudo systemctl enable --now v2raya
$ sudo systemctl enable --now v2raya
# 搜索 v2rayA，点击即可打开浏览器页面。在其中加入订阅，设置中建议开启全局透明代理(选择大陆白名单)，同时开启防止 DNS 劫持功能。
# 设置系统代理。KDE 的系统设置 -> 网络设置 -> 代理中设置 SOCKS5 代理以及 HTTP 代理。
# 如果对于一个应用，KDE 系统代理不生效，在终端 export 了 ALL_PROXY 变量再用终端启动此应用代理也不生效，并且这个应用自身也没有配置代理的选项，此时可以尝试使用 proxychains-ng。
```

### Easter Egg

[copy.sh](https://copy.sh/v86/?profile=archlinux) 打开看看呗！不会害你的，嘻嘻！
