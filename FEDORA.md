# Fedora ricing

```sh
gh auth login
gh repo clone shawal-mbalire/root_home_shawal
cp -r root_home_shawal/.git/ .git/
git pull
rm -rf root_home_shawal
```
```sh
sudo dnf install lua lua-devel luarocks go lua5.1
sudo dnf install fish alacritty rofi blueman pavucontrol waybar gh google-chrome nm-applet
```

## remove

```sh
sudo dnf install hyprland sddm
sudo dnf remove gnome-shell --setopt protected_packages=
```

```sh
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/bin/fish
```

```sh
sudo dnf remove gnome-** plasma-** kde-**
sudo dnf install nautilus
```

## Rawhide
changing to raw hide gives you a more rolling release distro giving you the latest fixes and patches

```sh
sudo dnf config-manager setopt rpmfusion-free.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates-debuginfo.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates-source.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates-testing.enabled=0
sudo dnf config-manager setopt rpmfusion-nonfree-updates-testing.enabled=0
```

```sh
sudo dnf autoremove
sudo dnf clean all
```

```sh
sudo dnf system-upgrade download --releasever=rawhide
```

## Copr

```sh
sudo copr enable zawertun/hack-fonts
sudo dnf enable alxhr0/Obsidian
```

## Repo

```sh
sudo dnf repo list
```

```sh
sudo dnf config-manager setopt repository.enabled=0
```

## Groups

```sh
dnf repo list
```

```sh
sudo dnf group rmove libreoffice
```

## Google chrome
```sh
echo " [google-chrome]
    1 name=google-chrome
    2 baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
    3 enabled=1
    4 gpgcheck=1
    5 gpgkey=https://dl.google.com/linux/linux_signing_key.pub  " >> /etc/yum.repos.d/google-chrome.repo
sudo dnf install google-chrome
sudo dnf remove firefox**
```
