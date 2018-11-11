#!/usr/bin/zsh

echo 'source ~/.dotfiles/zsh/init.zsh' >> ~/.zshrc

## terminal
ln -s ~/.dotfiles/.tmux.conf       ~/.tmux.conf
ln -s ~/.dotfiles/.peco            ~/.peco

## git
ln -s ~/.dotfiles/.gitconfig       ~/.gitconfig
ln -s ~/.dotfiles/.gitattributes_global ~/.gitattributes_global

## X
ln -s ~/.dotfiles/xmonad/          ~/.xmonad
ln -s ~/.dotfiles/xmonad/.xmobarrc ~/.xmobarrc
ln -s ~/.dotfiles/.Xresources      ~/.Xresources
ln -s ~/.dotfiles/.Xdefaults       ~/.Xdefaults


## Mac home
# .chunkwm_plugins            -> .dotfiles/chunkwm/.chunkwm_plugins/
# .chunkwmrc                  -> .dotfiles/chunkwm/.chunkwmrc
# .khdrc                      -> .dotfiles/khd/.khdrc
# .tmux.conf                  -> .dotfiles/.tmux.conf.mac
# com.googlecode.iterm2.plist -> .dotfiles/com.googlecode.iterm2.plis
# .hammaerspoon               -> .dotfiles/
