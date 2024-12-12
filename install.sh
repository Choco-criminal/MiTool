#!/bin/bash

echo

arch=$(dpkg --print-architecture)

if [[ "$arch" != "amd64" && "$arch" != "i386" && "$arch" != "arm64" && "$arch" != "armhf" ]]; then
    echo "MiTool does not support architecture $arch"
    exit 1
fi

mitoolusers="/usr/local/bin/.mitoolusersok"
miunlockusers="/usr/local/bin/.miunlockusersok"

if [ ! -f "$mitoolusers" ]; then
    if [ ! -f "$miunlockusers" ]; then
        echo -ne "\rapt upgrade ..."
        sudo apt upgrade -y > /dev/null
    fi
    curl -Is https://github.com/offici5l/MiTool/releases/download/tracking/totalusers > /dev/null 2>&1
    sudo touch "$mitoolusers"
fi

echo -ne "\rURL check ..."

main_repo=$(grep -E '^deb ' /etc/apt/sources.list | awk '{print $2}' | head -n 1)

curl -s --retry 4 $main_repo > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\nRequest to $main_repo failed. Please check your internet connection.\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\nThe $main_repo is blocked in your current country.\n"
    exit 35
fi

git_repo="https://raw.githubusercontent.com"

curl -s --retry 4 $git_repo > /dev/null
exit_code=$?

if [ $exit_code -eq 6 ]; then
    echo -e "\nRequest to $git_repo failed. Please check your internet connection.\n"
    exit 6
elif [ $exit_code -eq 35 ]; then
    echo -e "\nThe $git_repo is blocked in your current country.\n"
    exit 35
fi

echo -ne "\rapt update ..."
sudo apt update > /dev/null

charit=-1
total=29
start_time=$(date +%s)

_progress() {
    charit=$((charit + 1))
    percentage=$((charit * 100 / total))
    echo -ne "\rProgress: $charit/$total ($percentage%)"
    if [ $percentage -eq 100 ]; then
        end_time=$(date +%s)
        elapsed_time=$((end_time - start_time))
        echo -ne "\rProgress: $charit/$total ($percentage%) Took: $elapsed_time seconds\n"
    fi
}

_progress

url="https://raw.githubusercontent.com/nohajc/nohajc.github.io/master/dists/termux/extras/binary-${arch}"

packages=(
    "libprotobuf-dev"
    "adb"
    "python3"
    "python3-pip"
    "libffi-dev"
    "libusb-1.0-0-dev"
    "zlib1g-dev"
    "openssl"
    "pkg-config"
    "wget"
    "curl"
)

for package in "${packages[@]}"; do
    installed=$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep "install ok installed")
    if [ -z "$installed" ]; then
        sudo apt install -y "$package" >/dev/null
    fi
    _progress
done

libs=(
    "urllib3"
    "requests"
    "colorama"
)

for lib in "${libs[@]}"; do
    installed_version=$(pip3 show "$lib" 2>/dev/null | grep Version | awk '{print $2}')
    if [ -z "$installed_version" ]; then
        pip3 install "$lib" -q
    fi
    _progress
done

sudo curl -s "https://raw.githubusercontent.com/offici5l/MiTool/master/MT/mitool.py" -o "/usr/local/bin/mitool" && sudo chmod +x "/usr/local/bin/mitool"

_progress

sudo curl -s "https://raw.githubusercontent.com/offici5l/MiTool/master/MT/mihelp.py" -o "/usr/local/bin/mihelp" && sudo chmod +x "/usr/local/bin/mihelp"

_progress

sudo curl -s "https://raw.githubusercontent.com/offici5l/MiTool/master/MT/miflashf.py" -o "/usr/local/bin/miflashf" && sudo chmod +x "/usr/local/bin/miflashf"

_progress

sudo curl -s "https://raw.githubusercontent.com/offici5l/MiTool/master/MT/miflashs.py" -o "/usr/local/bin/miflashs" && sudo chmod +x "/usr/local/bin/miflashs"

_progress

if [ ! -f "$miunlockusers" ]; then
    sudo curl -sSL -o "/usr/local/bin/miunlock" https://github.com/offici5l/MiUnlockTool/releases/latest/download/MiUnlockTool.py
    sudo touch "$miunlockusers"
else
    sudo curl -sSL -o "/usr/local/bin/miunlock" https://raw.githubusercontent.com/offici5l/MiUnlockTool/master/MiUnlockTool.py
fi

sudo chmod +x "/usr/local/bin/miunlock"

_progress

sudo curl -s "https://raw.githubusercontent.com/offici5l/MiBypassTool/master/MiBypassTool.py" -o "/usr/local/bin/mibypass" && sudo chmod +x "/usr/local/bin/mibypass"

_progress

sudo curl -s -L -o /usr/local/bin/miasst $(curl -s "https://api.github.com/repos/offici5l/MiAssistantTool/releases/latest" | grep "browser_download_url.*miasst_termux_${arch}" | cut -d '"' -f 4) && sudo chmod +x /usr/local/bin/miasst

_progress

echo

curl -L -s https://raw.githubusercontent.com/offici5l/MiTool/main/CHANGELOG.md | tac | awk '/^#/{exit} {print "\033[0;34m" $0 "\033[0m"}' | tac

printf "\nUse command: \e[1;32mmitool\e[0m\n\n"
