#!/usr/bin/env bash
set -euo pipefail

brew tap crisidev/homebrew-chunkwm
brew tap koekeishiya/formulae
brew install chunkwm
ln -s /Users/yuki.osako/.dotfiles/chunkwm/.chunkwmrc ~/
chmod +x ~/.chunkwmrc
ln -s /Users/yuki.osako/.dotfiles/chunkwm/.chunkwm_plugins ~/

brew install khd
ln -s /Users/yuki.osako/.dotfiles/khd/.khdrc ~/

brew services start chunkwm
brew services start khd

