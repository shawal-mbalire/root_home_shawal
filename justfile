stow:
  stow --dotfiles .

macos: stow
  ./setup-macos.sh

fedora: stow
  ./setup-fedora.sh
