#!/bin/bash

sudo add-apt-repository ppa:neovim-ppa/stable
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt install neovim python3-dev python3-pip python3-neovim xclip

if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
	echo "Cloning packer repo"
	git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi

if [ ! -f ~/.local/share/fonts/MesloLGMNerdFont-Regular.ttf ]; then
	echo "Installing Meslo fonts"
	wget -P /tmp https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip

	unzip /tmp/Meslo.zip -d ~/.local/share/fonts/
	rm *Windows* 2>/dev/null
	fc-cache -fv
fi

apt install python3.10-venv

sudo apt-get install npm ripgrep bear clangd ninja-build python3.10-venv

if [ ! -d ~/docs ]; then
	git clone https://github.com/occam25/docs.git ~/
fi

if [ -d ~/.config/nvim  ]; then
	echo "Removing old configuration"
	rm -r ~/.config/nvim 
fi
cp -r ~/docs/neovim/.config/nvim ~/.config/nvim 
rm -r ~/.config.nvim/plugin 2>/dev/null

echo "WARNING: The script pylsp is installed in '/home/javiercasas/.local/bin' which is not on PATH."
