  #!/bin/sh

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
omnigraffle \
xmind \
slack \
spectacle \
google-backup-and-sync \
parallels \
appcleaner \
mysqlworkbench \
league-of-legends \
microsoft-teams \
flux \
lastpass \
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
flycut \
malwarebytes \
bitbar \
battle-net \
microsoft-intellitype \
intel-power-gadget \
hazeover

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

mas install 926036361 # lastpass
mas install 1295203466 # Microsoft Remote Desktop
mas install 410628904 # Wunderlist
mas install 1208561404 # Kaspersky VPN
mas install 1176895641 # Spark
mas install 975937182 # Fantastical 2

# Zsh
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# RVM
\curl -sSL https://get.rvm.io | bash -s stable

# Other stuff to add later:
# https://github.com/welcoMattic/kymsu
# Kaspersky Internet Security

echo "Copy/Paste the following line to your 'sudoers' file to give yourself sudo access WITHOUT a password:"
echo "$USER\tALL = (ALL) NOPASSWD: ALL"
echo "Press <enter> to begin editing..."
read
EDITOR=vi sudo visudo
