# Fedora ricing

## remove
```fish
sudo dnf install hyprland sddm
sudo dnf remove gnome-shell --setopt protected_packages=
```
```bash
sudo dnf remove gnome-** plasma-** kde-**
```
## Rawhide 
changing to raw hide gives you a more rolling release distro giving you the latest fixes and patches

```fish
sudo dnf config-manager setopt rpmfusion-free.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates-debuginfo.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates-source.enabled=0
sudo dnf config-manager setopt rpmfusion-free-updates-testing.enabled=0
sudo dnf config-manager setopt rpmfusion-nonfree-updates-testing.enabled=0
```
```fish
sudo dnf system-upgrade download --releasever=rawhide
```

## Copr 
```fish
sudo copr enable zawertun/hack-fonts
```

## Repo
```fish
sudo dnf repo list
```
```fish
sudo dnf config-manager setopt repository.enabled=0
```
## Groups 
