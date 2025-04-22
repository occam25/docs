#!/bin/bash

sudo add-apt-repository ppa:neovim-ppa/stable
# add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim python3-dev python3-pip python3-neovim xclip

if [ ! -f ~/.local/share/fonts/MesloLGMNerdFont-Regular.ttf ]; then
	echo "Installing Meslo fonts"
	wget -P /tmp https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip
	unzip /tmp/Meslo.zip -d ~/.local/share/fonts/
	rm *Windows* 2>/dev/null
	fc-cache -fv
fi

sudo apt-get install npm ripgrep bear clangd ninja-build python3.10-venv

if [ ! -d ~/dotfiles ]; then
	git clone https://github.com/occam25/dotfiles.git ~/
fi

if [ -d ~/.config/nvim  ]; then
	echo "Removing old configuration"
	rm -r ~/.config/nvim 
fi
cp -r ~/dotfiles/.config/nvim ~/.config/nvim

