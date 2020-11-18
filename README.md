# env-starter
快速替换系统包管理镜像源和各种一键配环境的万金油脚本，傻瓜式操作，目前处于自用阶段，可大幅减少配环境、换源、装插件的工作量，可自行 fork 或根据自己需要修改

## 使用
```bash
# 直接运行方式 1 (国内服务器克隆仓库)
bash -c "$(curl -fsSL https://api.zhamao.xin/tools/env.sh)"

# 直接运行方式 2 (GitHub Pages)
bash -c "$(curl -fsSL http://env.crazywhale.cn/env.sh)"

# 下载方式 3 (因为 githubusercontent 被墙了，所以只能这么下)
git clone https://github.com/crazywhalecc/env-starter.git && cd env-starter && chmod +x env.sh && ./env.sh
```

然后根据提示直接使用即可。

## 目前有的功能
- [X] Linux 发行版的包管理一键替换清华源
- [X] macOS Homebrew 一键从国内清华源安装和替换仓库地址
- [X] 一键安装 zsh + oh-my-zsh 并添加插件 z sudo 和下载 zsh-autosuggestions 自动补全
- [X] 在线运行 `neofetch` 查看系统信息
- [ ] 一键安装 pyenv 并配置 PATH 等操作
- [ ] 一键安装 LNMP 或其中的一项或几项，可手动选安装套件
- [ ] Hack Things (自动安装自用的一些渗透工具集)
- [ ] macOS Things (自用的一些 macOS 终端配置)
- [ ] 反向操作 (如恢复 Linux 发行版的包管理源和卸载 oh-my-zsh 等)

## 包管理替换支持的发行版
- [X] Ubuntu 12.04 ~ 20.04 (x86_64 / aarch64)
- [X] Kali (x86_64)
- [X] Termux (with Android)
- [ ] CentOS
- [ ] Pop!_OS
- [ ] Debian
- [ ] Raspbian
- [ ] Arch Linux
- [ ] Alpine
- [ ] Deepin

## 支持功能表
|                              | Linux (含 WSL(1/2))              | macOS             | MINGW (NT)             |
| ---------------------------- | ------------------ | ------------------ | ------------------ |
| 替换包管理的源为国内         | :zap: | :x:                | :x:                |
| 安装zsh和oh-my-zsh并替换主题 | :white_check_mark: | :white_check_mark: | :x:                |
| 在线运行neofetch             | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| 安装Homebrew并替换为国内源   | :white_check_mark:                | :white_check_mark: | :x:                |

> :zap:：此类型系统下部分版本可用，:white_check_mark:：此系统下可用，:x:：此系统下不可用，在菜单中不会显示

## 特色（虽然没啥用）
- Ubuntu 包管理替换时检测如果系统是阿里云或腾讯云的镜像则询问用户是否替换
- 支持 termux 环境
- 使用方向键快速选择，比较酷炫（感谢 @kahkhang 开发的 [Inquirer.sh](https://github.com/kahkhang/Inquirer.sh)）

## 效果
<img src="https://i.loli.net/2020/11/15/OokYNQwymUZ92Eq.gif" height="300" />
