#!/bin/bash

sudo apt-get update
sudo apt-get install tmux

if [ ! -d ~/.tmux/plugins/tpm ]; then
	echo "Cloning tmux plugin"
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ ! -d ~/docs ]; then
	echo "Cloning docs repo"
	git clone https://github.com/occam25/docs.git ~/
fi

if [ -f ~/.tmux.conf ]; then
	echo "Removing old config file"
	rm ~/.tmux.conf
fi
echo "Copying tmux configuration"
cp -r ~/docs/tmux/.tmux.conf ~/.tmux.conf

echo "Start a tmux session and press Ctrl+<Space> + I"
