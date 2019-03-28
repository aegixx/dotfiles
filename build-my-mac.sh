#!/bin/sh

set -o errexit

if [ ! command -v brew >/dev/null 2>&1 ]; then
	# Install Homebrew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Use `brew bundle dump` to get `Brewfile`
brew upgrade
brew cleanup

brew bundle

# Zsh
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# RVM
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby

# kymsu (https://github.com/welcoMattic/kymsu)
git clone git@github.com:welcoMattic/kymsu.git && ( cd kymsu && ./install.sh ) ; rm -rf kymsu

# Kaspersky Internet Security
wget -O /tmp/kis.dmg https://products.s.kaspersky-labs.com/homeuser/kismac18/18.0.2.60/multilanguage-INT-20180517_134818/kaspersky%20internet%20security.dmg
sudo hdiutil attach /tmp/kis.dmg
open /Volumes/Kaspersky\ Internet\ Security/Kaspersky\ Downloader.app
read \?"Press [Enter] to continue..."
sudo hdiutil unmount /Volumes/Kaspersky\ Internet\ Security/
rm /tmp/kis.dmg

# Linking
ln -s ~/projects/dotfiles/.oh-my-zsh/custom/plugins/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
ln -s ~/projects/dotfiles/.oh-my-zsh/custom/themes/bira-squared.zsh-theme ~/.oh-my-zsh/custom/themes/bira-squared.zsh-theme
ln -s ~/projects/dotfiles/.* ~/

SUDOER_LINE="$USER\tALL = (ALL) NOPASSWD: ALL"
if [ ! sudo fgrep "$SUDOER_LINE" /etc/sudoers ]; then
  echo "Copy/Paste the following line to your 'sudoers' file to give yourself sudo access WITHOUT a password:"
  echo "$SUDOER_LINE"
  read \?"Press [Enter] to continue..."
  EDITOR=vi sudo visudo
fi
