#!/usr/bin/zsh

touch ~/.zshrc
echo 'source ~/.dotfiles/zsh/init.zsh' > ~/.zshrc

sudo ln -s ~/.dotfiles/xmonad/          ~/.xmonad
sudo ln -s ~/.dotfiles/xmonad/.xmobarrc ~/.xmobarrc
sudo ln -s ~/.dotfiles/.tmux.conf       ~/.tmux.conf
sudo ln -s ~/.dotfiles/.peco            ~/.peco
sudo ln -s ~/.dotfiles/.Xresources      ~/.Xresources
sudo ln -s ~/.dotfiles/.Xdefaults       ~/.Xdefaults
sudo ln -s ~/.dotfiles/.gitconfig       ~/.gitconfig

## Mac home
# .chunkwm_plugins            -> .dotfiles/chunkwm/.chunkwm_plugins/
# .chunkwmrc                  -> .dotfiles/chunkwm/.chunkwmrc
# .khdrc                      -> .dotfiles/khd/.khdrc
# .tmux.conf                  -> .dotfiles/.tmux.conf.mac
# com.googlecode.iterm2.plist -> .dotfiles/com.googlecode.iterm2.plis
# .hammaerspoon               -> .dotfiles/
