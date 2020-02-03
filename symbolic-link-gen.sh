#!/usr/bin/zsh

echo 'source ~/.dotfiles/zsh/init.zsh' >> ~/.zshrc

## terminal
ln -s ~/.dotfiles/.tmux.conf       ~/.tmux.conf

mkdir -p ~/.config
ln -s ~/.dotfiles/.config/peco     ~/.config/

## git
ln -s ~/.dotfiles/.gitconfig       ~/.gitconfig
ln -s ~/.dotfiles/.gitattributes_global ~/.gitattributes_global

## X
#ln -s ~/.dotfiles/xmonad/          ~/.xmonad
#ln -s ~/.dotfiles/xmonad/.xmobarrc ~/.xmobarrc
#ln -s ~/.dotfiles/.Xresources      ~/.Xresources
#ln -s ~/.dotfiles/.Xdefaults       ~/.Xdefaults

## skk jisyo
ln -s ~/.dotfiles/SKK-JISYO.L.utf8 ~/.SKK-JISYO.L.utf8


## Mac home
ln -s ~/.dotfiles/chunkwm/.chunkwm_plugins/    ~/.chunkwm_plugins           
ln -s ~/.dotfiles/chunkwm/.chunkwmrc           ~/.chunkwmrc                 
ln -s ~/.dotfiles/khd/.khdrc                   ~/.khdrc                     
ln -s ~/.dotfiles/.tmux.conf.mac               ~/.tmux.conf                 
ln -s ~/.dotfiles/com.googlecode.iterm2.plis   ~/com.googlecode.iterm2.plist
ln -s ~/.dotfiles/                             ~/.hammaerspoon              
