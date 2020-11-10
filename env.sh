#!/bin/bash

kali_apt_source="http://mirrors.tuna.tsinghua.edu.cn/kali"
ubuntu_apt_ver="xenial"
is_ports=""
tools_url="http://124.70.24.97/tools"

unix_s=$(uname -s)

function _get_release() {
    if [ "$unix_s" = "Linux" ]; then 
        echo $HOME | grep com.termux > /dev/null
        if [ $? == 0 ]; then
            echo "termux"
        else
            cat /etc/issue | grep -v '^$' | awk '{print $1}'; 
        fi
    elif [ "$unix_s" = "Darwin" ]; then 
        sw_vers | grep ProductName | awk '{print $2" "$3" "$4}'; 
    fi
}
unix_release=$(if [ "$unix_s" = "Linux" ]; then cat /etc/issue | grep -v '^$' | awk '{print $1}'; elif [ "$unix_s" = "Darwin" ]; then sw_vers | grep ProductName | awk '{print $2" "$3" "$4}'; fi)
unix_release=$(_get_release)
trap 'onCtrlC' INT
function onCtrlC() {
    echo ""
    echo "Bye"
    exit
}

function ubuntu_apt_source() {
    echo "#script generated
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu$is_ports/ $ubuntu_apt_ver-proposed main restricted universe multiverse
"
}

###################### color part ###############################################
function color_red() { echo -n -e "\033[31m"$*"\033[0m\n"; }
function color_green() { echo -n -e "\033[32m"$*"\033[0m\n"; }
function color_yellow() { echo -n -e "\033[33m"$*"\033[0m\n"; }
function color_blue() { echo -n -e "\033[34m"$*"\033[0m\n"; }
function color_pink() { echo -n -e "\033[35m"$*"\033[0m\n"; }
function color_lightblue() { echo -n -e "\033[36m"$*"\033[0m\n"; }
function color_white() { echo -n -e "\033[37m"$*"\033[0m\n"; }
function color_black() { echo -n -e "\033[30m"$*"\033[0m\n"; }
function color_gold() { echo -n -e "\033[38;5;214m"$*"\033[0m\n"; }
function color_gray() { echo -n -e "\033[38;5;59m"$*"\033[0m\n"; }
function color_lightlightblue() { echo -n -e "\033[38;5;63m"$*"\033[0m\n"; }

###################### help part ################################################
help_banner="====== 当前系统 $unix_release-"$(uname -m)"("$(whoami)") ======"
help_help="获取帮助菜单"
help_install_zsh="安装zsh和oh-my-zsh并替换主题"
help_switch_package="替换包管理的源为国内"
help_install_brew="安装Homebrew并替换为国内源"
help_install_pyenv="安装pyenv并配置PATH"
help_neofetch="在线运行neofetch"
function linux_help() {
    color_gold $help_banner
    if [ "$(whoami)" != "root" ]; then color_red "你当前为非 root 用户，可能没有权限执行，请先切换为 root 权限！"; fi
    color_green "[1]:  "$help_switch_package
    color_green "[2]:  "$help_install_zsh
    color_green "[3]:  "$help_neofetch

    color_green "[h|help]: "$help_help && color_green "[q|exit]: 退出脚本"
}
function darwin_help() {
    color_gold $help_banner
    color_green "[1]:  "$help_install_brew
    color_green "[2]:  "$help_install_zsh
    color_green "[3]:  "$help_neofetch

    color_green "[h|help]: "$help_help && color_green "[q|exit]: 退出脚本"
}

function operate_confirm() {
    echo -n $(color_yellow "$1 [Y/n]  ")
    read operate
    operate=$(echo $operate | tr A-Z a-z)
    if [[ "$operate" = "y" || "$operate" = "" ]]; then
        return 0
    else
        return 1
    fi
}

function run_neofetch() {
    curl -o /tmp/neofetch -s https://gitee.com/mirrors/neofetch/raw/master/neofetch && chmod +x /tmp/neofetch && /tmp/neofetch && rm /tmp/neofetch
}

###################### exec part ################################################
function exec_case() {
    case $unix_s in
    "Linux")
        case $1 in
        1) linux_switch_package ;;
        2) install_zsh ;;
        3) run_neofetch ;;
        # Default
        help | h) linux_help ;; q | exit) color_yellow Bye && exit ;; "") ;; *) color_red "Unknown command: "$2 ;;
        esac
        ;;
    "Darwin")
        case $1 in
        1) install_homebrew ;;
        2) install_zsh ;;
        3) run_neofetch ;;
        # Default
        help | h) darwin_help ;; q | exit) color_yellow Bye && exit ;; "") ;; *) color_red "Unknown command: "$2 ;;
        esac
        ;;
    esac
}

function detect_aliyun_tencentyun() {
    r=$(cat /etc/apt/sources.list | grep -E "aliyun|tencent|tuna｜ustc")
    if [ "$r" = "" ]; then
        return 1
    else
        color_yellow "监测到你当前的镜像源已经是阿里云/腾讯云/清华源/中科大源，我猜你应该不需要再配包管理源了"
        echo -n "$(color_yellow 是否继续配置包管理？[y/N]) "
        read operate
        operate=$(echo $operate | tr A-Z a-z)
        if [[ "$operate" = "y" ]]; then
            return 1
        else
            return 0
        fi
    fi
}

function install_homebrew() {
    cd /tmp
    git clone https://github.com/Homebrew/install.git
    sed -ie 's/BREW_REPO="https:\/\/github.com\/Homebrew\/brew"/BREW_REPO="https:\/\/mirrors.tuna.tsinghua.edu.cn\/git\/homebrew\/brew.git"/g' install/install.sh
    HOMEBREW_CORE_GIT_REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git bash install/install.sh &&
        git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git &&
        git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git &&
        git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git 2>/dev/null &&
        git -C "$(brew --repo homebrew/cask-fonts)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git 2>/dev/null &&
        git -C "$(brew --repo homebrew/cask-drivers)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git 2>/dev/null &&
        brew update
}

function install_software() {
    if [ "$unix_s" = "Linux" ]; then
        case $unix_release in
        "Kali" | "Ubuntu" | "Debian" | "Raspbian" | 'Pop!_OS') sudo apt install $1 -y ;;
        esac
    elif [ "$unix_s" = "Darwin" ]; then
        brew install $1
    fi
}

function install_test() {
    which $1 >/dev/null
    if [ $? != 0 ]; then
        operate_confirm "$1 还没有安装，是否确认安装？" && install_software $1
    fi
}

function install_zsh() {
    install_test git && install_test curl && install_test zsh && install_test vim && install_test sl
    if [ $? != 0 ]; then return; fi
    curl https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh -o /tmp/install-3cr4.sh
    sed -ie 's/REPO=${REPO:-ohmyzsh\/ohmyzsh}/REPO=${REPO:-mirrors\/oh-my-zsh}/g' /tmp/install-3cr4.sh
    sed -ie 's/REMOTE=${REMOTE:-https:\/\/github.com\/${REPO}.git}/REMOTE=${REMOTE:-https:\/\/gitee.com\/${REPO}.git}/g' /tmp/install-3cr4.sh
    chmod +x /tmp/install-3cr4.sh
    /tmp/install-3cr4.sh
    cd ~/.oh-my-zsh
    if [ $? != 0 ]; then
        color_red "oh-my-zsh安装失败！"
    fi
    cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/
    if [ $? != 0 ]; then
        curl $tools_url/archive/zsh-autosuggestions.tar.gz -o /tmp/zsh-autosuggestions.tar.gz &&
            cd /tmp && tar -zxvf zsh-autosuggestions.tar.gz &&
            mv zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/
    fi
    color_green "正在更换主题为 daveverwer"
    sed -ie 's/^ZSH_THEME=.*/ZSH_THEME="daveverwer"/g' ~/.zshrc

    #color_green "正在优化历史记录"
    #echo -e "HISTFILE=\"\$HOME/.zsh_history\"\nHISTSIZE=10000000\nSAVEHIST=10000000" >> ~/.zshrc

    color_green "正在启用扩展..."
    if [ "$(sed -n '/^plugins=(git)/p' ~/.zshrc)" = "" ]; then
        echo -n $(color_yellow "你已经修改过 .zshrc 的插件了，请手动添加 z sudo！(Press y to open vim or ENTER to continue)")
        read ys
        if [ "$ys" = "y" ]; then
            vim ~/.zshrc "+/^plugins"
        fi
    else
        sed -ie 's/plugins=(git)/plugins=(git z sudo)/g' ~/.zshrc
    fi
    color_green "zsh和oh-my-zsh已安装！"
    cd $re
}

function linux_switch_package() {
    case $unix_release in
    "Kali") # Kali脚本目前只支持x86架构的
        key=$(cat /etc/apt/sources.list | awk '{print $1}' | head -n 1)
        if [ "$key" != "#script" ]; then
            echo "正在备份原 /etc/apt/sources.list ..."
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.old
            a_source="#script generated\ndeb $kali_apt_source kali-rolling main contrib non-free\ndeb-src $kali_apt_source kali-rolling main contrib non-free"
            echo -e $a_source | sudo tee /etc/apt/sources.list
            color_green 成功替换为国内，正在update
        fi
        sudo apt update
        ;;
    "Ubuntu")
        key=$(cat /etc/apt/sources.list | awk '{print $1}' | head -n 1)
        if [ "$key" != "#script" ]; then
            detect_aliyun_tencentyun && return
            echo "正在备份原 /etc/apt/sources.list ..."
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.old

            # 判断ubuntu版本和架构
            if [ "$(arch)" = "x86_64" ]; then # 当前是x86架构
                ubuntu_apt_ver=$(lsb_release -c | awk '{print $2}')
                is_ports=""
                ubuntu_apt_source | sudo tee /etc/apt/sources.list
            elif [ "$(arch)" = "aarch64" ]; then
                ubuntu_apt_ver=$(lsb_release -c | awk '{print $2}')
                is_ports="-ports"
                ubuntu_ports_apt_source | sudo tee /etc/apt/sources.list
            else
                color_red "当前架构暂不支持！"
                break
            fi
            color_green 成功替换为国内，正在update
        fi
        sudo apt update
        ;;
    *)
        color_red "不支持的发行版：$unix_release"
        ;;
    esac
}

function main() {
    if [ "$unix_s" = "Linux" ]; then
        linux_help
    elif [ "$unix_s" = "Darwin" ]; then
        darwin_help
    else
        color_red "Unknown unix operating system name: "$unix_s
        return 1
    fi
    color_gray "Powered by 缝合怪crazywhale"
    while true; do
        echo -n "> $ "
        read cmdline
        if [[ $? == 1 ]]; then
            echo ""
            echo "Bye"
            break
        fi
        exec_case $cmdline
    done
}

re=$(pwd)

main
