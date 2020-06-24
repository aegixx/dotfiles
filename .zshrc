#!/bin/bash

[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
[[ -s "$HOME/.zshrc_protected" ]] && source "$HOME/.zshrc_protected" # Load protected zsh values
[[ -s "$HOME/.antigenrc" ]] && source "$HOME/.antigenrc" # Load antigen config (oh-my-zsh)
[[ -s "$HOME/.aliasrc" ]] && source "$HOME/.aliasrc" # Load aliases / bash functions
# [[ -s "$(brew --prefix dvm)/dvm.sh" ]] && source "$(brew --prefix dvm)/dvm.sh"
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
source <(helm completion zsh)

export ZSH=~/.oh-my-zsh
export PATH="/usr/local/sbin:$HOME/bin:$GOPATH/bin:$PATH:/usr/local/opt/openssl/bin:/usr/local/opt/openal-soft/bin"
# KUBECONFIG=~/.kube/config:$(find ~/.kube/conf.d -type f | tr '\n' ':') && export KUBECONFIG
JAVA_HOME=$(/usr/libexec/java_home -v 11) && export JAVA_HOME
export PATH_TO_FX=/usr/local/lib/javafx-sdk-14.0.1/lib
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export GOPATH=~/go
export PERL5LIB=/usr/local/lib/perl5/site_perl:${PERL5LIB}
export AWS_CREDENTIAL_FILE=~/.aws/credentials
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
GIT_EDITOR="$(command -v code) -aw" && export GIT_EDITOR
KUBE_EDITOR="$(command -v code) -aw" && export KUBE_EDITOR

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  EDITOR="$(command -v code) -n" && export EDITOR
fi

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/bryan.stone/projects/lf-portal/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/bryan.stone/projects/lf-portal/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/bryan.stone/projects/lf-portal/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/bryan.stone/projects/lf-portal/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /Users/bryan.stone/projects/lf-portal/node_modules/tabtab/.completions/slss.zsh ]] && . /Users/bryan.stone/projects/lf-portal/node_modules/tabtab/.completions/slss.zsh