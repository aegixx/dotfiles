source ~/.iterm2_shell_integration.`basename $SHELL`
source ~/.zshrc_protected
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

export KUBECONFIG=~/.kube/config:`find ~/.kube/conf.d -type f | tr '\n' ':'`
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export GOPATH=~/go
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[[ -s "$(brew --prefix dvm)/dvm.sh" ]] && source "$(brew --prefix dvm)/dvm.sh"
export KOPS_STATE_STORE=s3://oscar-ai-k8s-dev
export PERL5LIB=/usr/local/lib/perl5/site_perl:${PERL5LIB}

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR="`which atom` -a"
fi
export GIT_EDITOR="vim"

alias ls="ls -G"
alias ll="ls -AlhG"
alias t="tree"
alias e="$EDITOR"
alias edit="e"
alias truncate="cp /dev/null $@"
alias listening="sudo lsof -nP -iTCP -sTCP:LISTEN"

docker-rm-all() {
  echo "COMMAND: docker ps -aq | xargs docker rm -fv"
  docker ps -aq | xargs docker rm -fv
}

git-upstream() {
  echo "git fetch ${1=upstream}" && git fetch ${1=upstream}
  echo "git rebase ${1=upstream}/${2=master}" && git rebase ${1=upstream}/${2=master}
}

md-preview() {
	cat $1 | pandoc -f markdown_github | browser
}

kuse() {
  export KUBE_NAMESPACE=$1
}

ksh() {
  if [[ "${KUBE_NAMESPACE}x" != "x" ]]; then
    echo "COMMAND: kubectl --namespace $KUBE_NAMESPACE exec -it $@ bash"
    kubectl --namespace $KUBE_NAMESPACE exec -it $@ bash
  else
    echo "COMMAND: kubectl exec -it $@ bash"
    kubectl exec -it $@ bash
  fi
}

k() {
  if [[ "${KUBE_NAMESPACE}x" != "x" ]]; then
    echo "COMMAND: kubectl --namespace $KUBE_NAMESPACE "$@""
    kubectl --namespace $KUBE_NAMESPACE "$@"
  else
    echo "COMMAND: kubectl "$@""
    kubectl "$@"
  fi
}

kport() {
  if [ $# -gt 1 ]; then
      echo "COMMAND: while kubectl --namespace $KUBE_NAMESPACE port-forward $1 $2 &>> /dev/null; do :; done &"
      while kubectl --namespace $KUBE_NAMESPACE port-forward $1 $2 &>> /dev/null; do :; done &
  else
    echo "USAGE: kport [pod] [port]"
  fi
}

kswitch() {
  echo "COMMAND: kubectl config use-context $1"
  kubectl config use-context $1
}

kwatch() {
  if [ -z $1 ]; then
    echo "COMMAND: watch -ct \"kubectl get po,ds,deploy,hpa,ing,petsets,jobs,rs,svc,pvc -o wide --no-headers=true --all-namespaces | grep -v ^kube-system\""
    watch -ct "kubectl get po,ds,deploy,hpa,ing,petsets,jobs,rs,svc,pvc -o wide --no-headers=true --all-namespaces | grep -v ^kube-system"
  else
    NS=$1
    shift 1
    echo "COMMAND: watch -ct \"kubectl get po,ds,deploy,hpa,ing,petsets,jobs,rs,svc,pvc -o wide --no-headers=true --namespace $NS $@\""
    watch -ct "kubectl get po,ds,deploy,hpa,ing,petsets,jobs,rs,svc,pvc -o wide --no-headers=true --namespace $NS $@"
  fi
}

kevent() {
  if [ -z $1 ]; then
    echo "COMMAND: while kubectl get ev --watch-only --all-namespaces --no-headers -o wide ; do :; done"
    while kubectl get ev --watch-only --all-namespaces --no-headers -o wide ; do :; done
  else
    echo "COMMAND: while kubectl --namespace $1 get ev --watch-only --no-headers -o wide ; do :; done"
    while kubectl --namespace $1 get ev --watch-only --no-headers -o wide ; do :; done
  fi
}

# Wait for a given host or ip to be listening
daemon-wait() {
	if [ $# -gt 1 ]; then
    local private_ip=
    if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      private_ip=$1
    elif arp $1 2> /dev/null | grep -Eq "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
      private_ip=$1
    else
      echo "Locating $1 via AWS CLI..."
      local vals=$(get-instance-detail $1)
      read -r -a vals <<< "$vals"
      local profile="${vals[0]}"
      local instance_id="${vals[1]}"
      private_ip="${vals[2]}"
      if [ -z $profile ]; then
        echo "ERROR: $1 could not be located"
        return 1
      else
        echo "  Found $private_ip ($profile)"
      fi
    fi

    echo "Waiting on $1:$2 to be listening..."
		while ! nc -z $1 $2 > /dev/null 2>&1; do
      sleep 0.5
    done
		shift 2
    echo "Executing $@"
		"$@"
  else
    echo "$1 cannot be resolved, please check your hostname"
  fi
}

alias docker-gc="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker-gc"

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="afowler"
ZSH_THEME="bira-squared"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(cp aws gpg-agent chucknorris sudo jsontools colorize rvm themes osx screen git vagrant brew ruby jira knife battery web-search command-not-found docker kubectl)

source $ZSH/oh-my-zsh.sh

export PATH="$PATH:$HOME/bin:$HOME/.rvm/bin"
