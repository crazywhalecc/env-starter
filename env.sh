#!/bin/bash

tmp_dir="/tmp" # 临时目录
tools_url="http://env.crazywhale.cn" # 工具的源仓库地址
unix_s=$(uname -s)
initial_download_cmdline="curl"
unix_release=$(
    marked_release=""
    if [ "$unix_s" = "Linux" ]; then
        echo $HOME | grep com.termux >/dev/null
        if [ $? == 0 ]; then
            marked_release="termux"
        elif [ -f "/etc/redhat-release" ]; then
            if [ "$(cat /etc/redhat-release | awk '{print $1}' | grep -v '^$')" = "CentOS" ]; then
                marked_release="CentOS"
            else
                marked_release="unknown"
            fi
        elif [ -f "/etc/os-release" ]; then
            cat /etc/os-release | grep Alpine > /dev/null
            if [ $? == 0 ]; then
                marked_release="Alpine"
            fi
        fi
        if [ "$marked_release" = "" ]; then
            if [ -f "/etc/issue" ]; then
                marked_release=$(cat /etc/issue | grep -v '^$' | awk '{print $1}')
            else
                marked_release="unknown"
            fi
        fi
    elif [ "$unix_s" = "Darwin" ]; then
        marked_release=$(sw_vers | grep ProductName | awk '{print $2" "$3" "$4}')
    fi
    echo $marked_release
)
unix_release=$(echo $unix_release | xargs)
help_banner="====== $unix_release-"$(uname -m)"("$(whoami)") ======"
kali_apt_source="http://mirrors.tuna.tsinghua.edu.cn/kali"
ubuntu_apt_ver="xenial"
centos_ver=""
is_ports=""

trap 'onCtrlC' INT
function onCtrlC() {
    echo "" && echo "Bye" && exit
}

# 一些特殊的发行版进行的操作
case $unix_release in
"termux") tmp_dir=$(cd "$HOME/../usr/tmp" && pwd) ;;
"CentOS") centos_ver=$(cat /etc/redhat-release | sed -r 's/.* ([0-9]+)\..*/\1/') ;;
"Mac OS X") unix_release=$unix_release"-"$(sw_vers -productVersion) ;;
esac

if command -v curl >/dev/null 2>&1; then initial_download_cmdline="curl"; else initial_download_cmdline="wget"; fi

function down_file() {
    if [ "$initial_download_cmdline" = "curl" ]; then curl -fsSL $1 -o $2; else wget -O $2 $1; fi
}

_lib_list=$tmp_dir"/list_input_a384.sh"
if [ ! -f "$_lib_list" ]; then
    _lib_list="./lib/list_input.sh"
    if [ ! -f "$_lib_list" ]; then
        _lib_list=$tmp_dir"/list_input_a384.sh"
        down_file $tools_url/lib/list_input.sh $_lib_list
    fi
fi
source $_lib_list

###################### tools part ###############################################
function install_test() {
    which $1 >/dev/null
    if [ $? != 0 ]; then
        operate_confirm "$1 还没有安装，是否确认安装？" && install_software $1
    fi
}
function install_software() {
    if [ "$unix_s" = "Linux" ]; then
        case $unix_release in
        "Kali" | "Ubuntu" | "Debian" | "Raspbian" | 'Pop!_OS') sudo apt-get install $1 -y ;;
        "termux") pkg install $1 -y ;;
        "CentOS") sudo yum install $1 -y ;;
        "Alpine") apk add $1 ;;
        esac
    elif [ "$unix_s" = "Darwin" ]; then
        brew install $1
    fi
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

function debian_apt_source() {
    echo "#script generated
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ $ubuntu_apt_ver main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ $ubuntu_apt_ver main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ $ubuntu_apt_ver-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ $ubuntu_apt_ver-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ $ubuntu_apt_ver-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ $ubuntu_apt_ver-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security $ubuntu_apt_ver/updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security $ubuntu_apt_ver/updates main contrib non-free
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

####################### 功能函数 part #############################################
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

function run_neofetch() {
    if [ ! -x "$tmp_dir/neofetch" ]; then
        curl -o $tmp_dir/neofetch -H 'User-Agent: Chrome' -s https://gitee.com/mirrors/neofetch/raw/master/neofetch && chmod +x $tmp_dir/neofetch 
    fi
    if [ ! -x "$tmp_dir/neofetch" ]; then
        color_red "neofetch 下载失败！"
    else
        $tmp_dir/neofetch
    fi
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
        sudo apt-get update
        ;;
    "Ubuntu")
        key=$(cat /etc/apt/sources.list | awk '{print $1}' | head -n 1)
        if [ "$key" != "#script" ]; then
            detect_aliyun_tencentyun && return
            echo "正在备份原 /etc/apt/sources.list ..."
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.old

            # 判断ubuntu版本和架构
            if [[ "$(arch)" = "x86_64" || "$(arch)" = "i686" ]]; then # 当前是x86架构
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
        sudo apt-get update
        ;;
    "termux")
        sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
        sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
        sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
        apt update
        ;;
    "CentOS")
        operate_confirm "CentOS 貌似默认会自动根据位置寻找合适的镜像站，不需要手动换源，是否继续？"
        if [ $? != 0 ]; then return; fi
        echo "正在备份原 /etc/yum.repos.d/CentOS-Base.repo"
        sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
        ;;
    "Debian")
        key=$(cat /etc/apt/sources.list | awk '{print $1}' | head -n 1)
        if [ "$key" != "#script" ]; then
            detect_aliyun_tencentyun && return
            echo "正在备份原 /etc/apt/sources.list ..."
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.old
            sudo apt install apt-transport-https ca-certificates -y
            # 判断debian版本和架构
            if [[ "$(arch)" = "x86_64" || "$(arch)" = "i686" ]]; then # 当前是x86架构
                ubuntu_apt_ver=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F\= '{print $2}')
                debian_apt_source | sudo tee /etc/apt/sources.list
            elif [ "$(arch)" = "aarch64" ]; then
                ubuntu_apt_ver=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F\= '{print $2}')
                debian_apt_source | sudo tee /etc/apt/sources.list
            else
                color_red "当前架构暂不支持！"
                break
            fi
            color_green 成功替换为国内，正在update
        fi
        sudo apt-get update
        ;;
    "Alpine") sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ;;
    *) color_red "不支持的发行版：$unix_release" ;;
    esac
}

function install_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        install_test git && install_test curl && install_test zsh && install_test vim
        if [ $? != 0 ]; then return; fi
        curl https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh -o $tmp_dir/install-3cr4.sh -H 'User-Agent: Chrome' && \
        sed -ie 's/REPO=${REPO:-ohmyzsh\/ohmyzsh}/REPO=${REPO:-mirrors\/oh-my-zsh}/g' $tmp_dir/install-3cr4.sh && \
        sed -ie 's/REMOTE=${REMOTE:-https:\/\/github.com\/${REPO}.git}/REMOTE=${REMOTE:-https:\/\/gitee.com\/${REPO}.git}/g' $tmp_dir/install-3cr4.sh && \
        chmod +x $tmp_dir/install-3cr4.sh && \
        $tmp_dir/install-3cr4.sh && \
        cd ~/.oh-my-zsh
        if [ $? != 0 ]; then
            color_red "oh-my-zsh安装失败！"
            return 1
        fi
        cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/
        if [ $? != 0 ]; then
            curl $tools_url/archive/zsh-autosuggestions.tar.gz -o $tmp_dir/zsh-autosuggestions.tar.gz &&
                cd $tmp_dir && tar -zxvf zsh-autosuggestions.tar.gz &&
                mv zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/
        fi
        color_green "正在更换主题为 daveverwer"
        sed -ie 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="daveverwer"/g' ~/.zshrc

        #color_green "正在优化历史记录"
        #echo -e "HISTFILE=\"\$HOME/.zsh_history\"\nHISTSIZE=10000000\nSAVEHIST=10000000" >> ~/.zshrc
    fi

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

function run_submenu() {
    echo -n -e "\x1b[A"
    er=(
        "给加鸡腿" 
        "返回上级菜单 ->"
    )
    list_input "$help_banner" er selected
    case $selected in
    "返回上级菜单 ->")  ;;
    "给加鸡腿") theme_color=$red ;;
    esac
    echo -n -e "\x1b[A"
}

function exec_case() {
    case $1 in
    "替换包管理的源为国内") linux_switch_package ;;
    "安装zsh和oh-my-zsh并替换主题") install_zsh ;;
    "在线运行neofetch") run_neofetch ;;
    "安装Homebrew并替换为国内源") install_homebrew ;;
    "子菜单") run_submenu ;;
    esac
}

function main() {
    case $unix_s in
    "Linux")
        help_ls=(
            "替换包管理的源为国内"
            "安装zsh和oh-my-zsh并替换主题"
            "安装Homebrew并替换为国内源"
            "在线运行neofetch"
            "退出"
        )
        ;;
    "Darwin")
        help_ls=(
            "安装Homebrew并替换为国内源"
            "安装zsh和oh-my-zsh并替换主题"
            "在线运行neofetch"
            "退出"
        )
        ;;
    "MINGW64_NT-10.0-19041"|"CYGWIN_NT-10.0")
        help_ls=("在线运行neofetch" "子菜单" "退出")
        ;;
    *)
        color_red "Unknown unix operating system name: "$unix_s
        return 1
    esac
    while true; do
        list_input "$help_banner" help_ls selected ssd
        if [ "$selected" = "退出" ]; then
            return 0
        fi
        exec_case "$selected"
    done
}
#printf '\033[2J' # 这两行用来清屏的
#printf '\033[H'
main
