# My Linux Configuration.


## Accepting this configuratoin on a new install

```fish
git clone https://github.com/shawal-mbalire/root_home_shawal
rsync -avhu --progress root_home_shawal ~
```

## installing nerdfonts

```bash
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
```

 ## hyprland

 ```
yay -Syyu hyprland-git wofi drun
```

## Nvim packer
```fish
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

for fedora
```fish
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
