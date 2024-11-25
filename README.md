# My Linux Configuration.


## Accepting this configuratoin on a new install
 ## checking file usage
 ``` sh
du --all --human-readable --threshold 1G
```
```sh
git clone https://github.com/shawal-mbalire/root_home_shawal
rsync -avhu --progress root_home_shawal ~
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
