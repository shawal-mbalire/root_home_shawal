# My Linux Configuration.

Snaps – obsidian, codeinsiders
flatpacks – zen, quran companion

 ## checking file usage
For linux
 ``` sh
du --all --human-readable --threshold 1G
```
For Macos
```sh
du -h -d 4 | sort -hr | head -30
```

## Accepting this configuratoin on a new install
```sh
git clone https://github.com/shawal-mbalire/root_home_shawal
rsync -avhu --progress root_home_shawal ~
```

## installing auth agent
```sh
sudo dnf install lxpolkit
```

## twin gate

### Installation

The following command will download and install the Linux Client on any supported Linux distribution.

```sh
curl -s https://binaries.twingate.com/client/linux/install.sh | sudo bash
```

Headless Mode is available for server, services, or container instances.

### Setup

Once installation completes, you need to configure the Linux Client by running the following command:


```sh
sudo twingate setup
```

## installing nerdfonts
on arch
```sh
yay -S ttf-hack-nerd
```
on fedora
```sh
sudo dnf copr enable zawertun/hack-fonts
sudo dnf install hack-fonts
```
install otf-font-awesome on fedora.. don't know when it was installed
```sh
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
```

 ## hyprland

 ```sh
yay -Syyu hyprland-git wofi drun
```

## Nvim packer
```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

for fedora
```sh
sudo dnf install lua lua-devel luarocks go lua5.1
```
```fish
wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz
tar zxpf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1
./configure && make && sudo make install
sudo luarocks install luasocket
lua
```
on fedora obsidian is a snap
## Vim plug

### vim
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### nvim
```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

### waybar bluetooth and nmtui support

install blueman and nmtui
suprisingly this blueman installs sway controlcenter
if only there was something like this for hyprland instead of different prgrams
