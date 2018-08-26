#!/bin/sh

set -o errexit

if [ ! command -v brew >/dev/null 2>&1 ]; then
	# Install Homebrew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew tap caskroom/drivers
brew tap caskroom/versions

brew cask install \
bit-slicer \
aws-vault \
intellij-idea-ce \
steam \
tower \
atom \
microsoft-office \
google-chrome \
goland \
docker \
iterm2 \
istat-menus \
adobe-acrobat-reader \
adobe-creative-cloud \
vnc-viewer \
rubymine \
caffeine \
minikube \
discord \
java \
alfred \
xmind \
slack \
spectacle \
google-backup-and-sync \
parallels \
appcleaner \
mysqlworkbench \
flux \
postman \
logitech-options \
quicken \
quickbooks-online \
little-snitch \
micro-snitch \
teamviewer \
evernote \
nvidia-geforce-now \
virtualbox \
malwarebytes \
bitbar \
microsoft-intellitype \
gimp

brew install \
htop \
wget \
nmap \
nodejs \
geoip \
go \
tree \
watch \
zsh \
git \
coreutils \
zsh-completions \
zsh-syntax-highlighting \
gpg \
awscli \
awsebcli \
awslogs \
aws-elasticbeanstalk \
jq \
mysql \
python \
mas \
kubernetes-helm \
jenv \
php

mas install 497799835  # XCode
mas install 926036361  # Lastpass
mas install 1295203466 # Microsoft Remote Desktop
mas install 410628904  # Wunderlist
mas install 1208561404 # Kaspersky VPN
mas install 1176895641 # Spark
mas install 1278508951 # Trello
mas install 430798174  # Hazeover
mas install 1142578753 # Omnigraffle

# Zsh
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
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


echo "Copy/Paste the following line to your 'sudoers' file to give yourself sudo access WITHOUT a password:"
echo "$USER\tALL = (ALL) NOPASSWD: ALL"
echo "Press <enter> to begin editing..."
read
EDITOR=vi sudo visudo
