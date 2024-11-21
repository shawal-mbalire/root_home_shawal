# Fedora ricing

## Rawhide 
changing to raw hide gives you a more rolling release distro giving you the latest fixes and patches
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
