#!/usr/bin/env bash

PROJECT_NAME="dotfiles"
SRC_INSTALL_HOME="$HOME/.$PROJECT_NAME"

rm -rf "$SRC_INSTALL_HOME"
git clone --depth 1 https://github.com/shaonianche/dotfiles.git ~/.dotfiles
rm -rf "$SRC_INSTALL_HOME/{README.md,license}"

[ -d "$SRC_INSTALL_HOME" ] && echo "Clone successful" || echo "Clone failed"

create_soft_link() {
  local src_file=$1
  local link_name=$HOME/$(basename "$src_file")

  # Check if the symlink already exists and remove it
  if [ -f "$link_name" ] || [ -d "$link_name" ]; then
    echo "Removing existing symlink: $link_name"
    rm "$link_name"
  fi

  # Create the symlink
  echo "Creating symlink: $link_name >> $src_file"
  ln -s "$src_file" "$link_name"
}

list_dot_files() {
  local dir_path=$1
  for file in "$dir_path"/.[^.]*; do
    if [ -f "$file" ]; then
      create_soft_link "$file"
    fi
  done
}

list_config_files() {
  local dir_path=$1
  for folder in "$dir_path"/*/; do
    if [ -d "$folder" ]; then
      create_soft_link "$folder" "$HOME/.config/$(basename "$folder")"
    fi
  done
}

list_dot_files "$SRC_INSTALL_HOME"
list_config_files "$SRC_INSTALL_HOME/.config"

OS=$(uname)

case "$OS" in
  Darwin*)
    echo "Current system is macOS"
    create_soft_link "$SRC_INSTALL_HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
    rm -rf "$SRC_INSTALL_HOME/{windows,linux,.git}"
    echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.bashrc
    echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.zshrc
    ;;
  Linux*)
    echo "Current system is Linux"
    create_soft_link "$SRC_INSTALL_HOME/.config/bash/.bashrc" "$HOME/.bashrc"
    rm -rf "$SRC_INSTALL_HOME/{windows,linux,.git}"
    echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.bashrc
    ;;
  *)
    echo "Unsupported system"
    ;;
esacs
