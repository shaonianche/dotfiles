#!/usr/bin/env bash

PROJECT_NAME="dotfiles"
SRC_INSTALL_HOME="$HOME/.$PROJECT_NAME"
_SCRIPT_="$0"

if test -d "$SRC_INSTALL_HOME"; then
  rm -rf "$SRC_INSTALL_HOME"
  git clone --depth 1 https://github.com/shaonianche/dotfiles.git ~/.dotfiles
  rm -rf "$SRC_INSTALL_HOME/README.md"
  rm -rf "$SRC_INSTALL_HOME/license"
else
  git clone --depth 1 https://github.com/shaonianche/dotfiles.git ~/.dotfiles
  rm -rf "$SRC_INSTALL_HOME/README.md"
  rm -rf "$SRC_INSTALL_HOME/license"
fi

detect_os() {
  current_system=$(uname)
  if [ "$current_system" == "Darwin" ]; then
    return 0
  elif [ "$current_system" == "Linux" ]; then
    return 1
  else
    return 2
  fi
}

create_soft_link() {
  local src_file=$1
  local link_name=$2
  ln -f -s "$src_file" "$link_name"
}

list_dot_files() {
  local dir_path=$1
  find "$dir_path" -maxdepth 1 -name ".*" -type f ! -name ".DS_Store" | while read -r file; do
    create_soft_link "$SRC_INSTALL_HOME/$(basename "$file")" "$HOME"
  done
}

list_config() {
  local dir_path=$1
  find "$dir_path" -type d | while read -r folder; do
    create_soft_link "$SRC_INSTALL_HOME/.config/$(basename "$folder")" "$HOME/.config"
  done
}

list_dot_files "$SRC_INSTALL_HOME"
list_config "$SRC_INSTALL_HOME/.config"

detect_os
if [ $? -eq 0 ]; then
  echo "Current system is macOS"
  create_soft_link "$SRC_INSTALL_HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
  rm -rf "$SRC_INSTALL_HOME/{windows,linux,.git}"
  echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.bashrc
  echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.zshrc
elif
  [ $? -eq 1 ]
then
  echo "Current system is Linux"
  create_soft_link "$SRC_INSTALL_HOME/.config/bash/.bashrc" "$HOME/.bashrc"
  rm -rf "$SRC_INSTALL_HOME/{windows,linux,.git}"
  echo "source $HOME/.dotfiles/macos/.export" >>"$HOME"/.bashrc
else
  echo "Current system is not macOS or Linux"
fi
