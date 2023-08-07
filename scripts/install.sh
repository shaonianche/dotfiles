#!/usr/bin/env bash

PROJECT_NAME="dotfiles"
SRC_INSTALL_HOME="$HOME/.$PROJECT_NAME"

rm -rf "$SRC_INSTALL_HOME"
git clone --depth 1 https://github.com/shaonianche/dotfiles.git ~/.dotfiles
rm -rf "$SRC_INSTALL_HOME/{README.md,license}"

[ -d "$SRC_INSTALL_HOME" ] && echo "Clone successful" || echo "Clone failed"

create_soft_link() {
  local src_file=$1
  local link_name=$2

  if [ -z "$link_name" ]; then
    link_name=$HOME/$(basename "$src_file")
  fi

  # Create the symlink
  echo "Creating symlink: $link_name >> $src_file"
  ln -sf "$src_file" "$link_name"
}

list_dot_files() {
  local dir_path=$1
  for file in "$dir_path"/*; do
    if [ -f "$file" ] && [[ "$file" == .* ]]; then
      create_soft_link "$file"
    fi
  done
}

function delete_files() {
  local src_dir="$SRC_INSTALL_HOME"
  local files=("$@")
  for file in "${files[@]}"; do
    rm -rf "${src_dir/$file/:?}"
  done
}

list_dot_files "$SRC_INSTALL_HOME"

create_soft_link "$SRC_INSTALL_HOME/.config/git/config" "$HOME/.gitconfig"
create_soft_link "$SRC_INSTALL_HOME/.config/git/.gitignore" "$HOME/.gitignore"
create_soft_link "$SRC_INSTALL_HOME/.config/git/.gitattributes" "$HOME/.gitattributes"
create_soft_link "$SRC_INSTALL_HOME/.config/tmux/.tmux.conf" "$HOME/.tmux.conf"
create_soft_link "$SRC_INSTALL_HOME/.config/bash/.bash_profile" "$HOME/.bash_profile"
create_soft_link "$SRC_INSTALL_HOME/.config/bash/.bash_logout" "$HOME/.bash_logout"

create_soft_link "$SRC_INSTALL_HOME/.config/.cargo" "$HOME/.config/.cargo"
create_soft_link "$SRC_INSTALL_HOME/.config/.gnupg" "$HOME/.config/.gnupg"
create_soft_link "$SRC_INSTALL_HOME/.config/.kitty" "$HOME/.config/kitty"

del_linux=(".git" "README.md" "install.ps1" "macos" "windows" "license")
del_macos=(".git" "README.md" "install.ps1" "linux" "windows" "license")

OS=$(uname)
case "$OS" in
Darwin*)
  echo "Current system is macOS"
  create_soft_link "$SRC_INSTALL_HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
  echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.bashrc
  echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.zshrc
  delete_files "${del_macos[@]}"
  ;;
Linux*)
  echo "Current system is Linux"
  create_soft_link "$SRC_INSTALL_HOME/.config/bash/.bashrc" "$HOME/.bashrc"
  create_soft_link "$SRC_INSTALL_HOME/linux/git/config.linux.conf" "$HOME/.gitconfig.local"
  create_soft_link "$SRC_INSTALL_HOME/linux/.export" "$HOME/.export"
  delete_files "${del_linux[@]}"
  echo "source $SRC_INSTALL_HOME/linux/.export" >>"$HOME"/.bashrc
  ;;
*)
  echo "Unsupported system"
  ;;
esac
