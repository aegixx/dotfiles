source ~/.iterm2_shell_integration.`basename $SHELL`
source ~/.zshrc_protected
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

export KUBECONFIG=~/.kube/config:`find ~/.kube/conf.d -type f | tr '\n' ':'`
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export GOPATH=~/go
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$(brew --prefix dvm)/dvm.sh" ]] && source "$(brew --prefix dvm)/dvm.sh"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
export PERL5LIB=/usr/local/lib/perl5/site_perl:${PERL5LIB}
export ECR_SANDBOX=bstone

# $(aws ecr get-login) &>> /dev/null

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR="`which atom` -aw"
fi
export GIT_EDITOR="`which atom` -aw"
export KUBE_EDITOR="`which atom` -aw"

alias ls="ls -G"
alias ll="ls -AlhG"
alias t="tree"
alias e="$EDITOR"
alias edit="e"
alias truncate="cp /dev/null $@"
alias listening="sudo lsof -nP -iTCP -sTCP:LISTEN"
alias rails-reset="rails db:drop db:create db:migrate db:seed && RAILS_ENV=test rails db:drop db:create db:migrate db:seed"
alias killzombies="kill -9 `ps -xaw -o state -o ppid | grep Z | grep -v PID | awk '{print $2}'`"
alias gs="git status"

docker-last() {
  echo "docker run -it --entrypoint /bin/sh $(docker images -aq | head -1)"
  docker run -it --entrypoint /bin/sh $(docker images -aq | head -1)
}

docker-rm-all() {
  echo "COMMAND: docker ps -aq | xargs docker rm -fv"
  docker ps -aq | xargs docker rm -fv
}

docker-rmi-all() {
  echo "COMMAND: docker images -aq | xargs docker rmi -fv"
  docker images -aq | xargs docker rmi -f
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

klog() {
  echo "COMMAND: kubectl --namespace $KUBE_NAMESPACE logs --timestamps=true -f $@"
  kubectl --namespace $KUBE_NAMESPACE logs --timestamps=true -f $@
}

kswitch() {
  echo "COMMAND: kubectl config use-context $1"
  kubectl config use-context $1
}

kwatch() {
  if [ -z $1 ]; then
    echo "COMMAND: watch -ct \"kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc -o wide --no-headers=true --all-namespaces | grep -v ^kube-system\""
    watch -ct "kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc.svc,pvc -o wide --no-headers=true --all-namespaces | grep -v ^kube-system"
  else
    NS=$1
    shift 1
    echo "COMMAND: watch -ct \"kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc -o wide --no-headers=true --namespace $NS $@\""
    watch -ct "kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc -o wide --no-headers=true --namespace $NS $@"
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

ksecret() {
  if [ $# -lt 3 ]; then
    echo "USAGE: ksecret <secret_name> <old-ns> <new-ns>"
  else
    SECRET_NAME=$1
    OLD_NS=$2
    NEW_NS=$3
    echo "COMMAND: kubectl --namespace $OLD_NS get secret $SECRET_NAME -o json | jq '{apiVersion,data,kind,type} + {metadata: (.metadata | { name: (.name)})}' | kubectl --namespace $NEW_NS create -f -"
    kubectl --namespace $OLD_NS get secret docker-trebuchetdev-com -o json | jq '{apiVersion,data,kind,type} + {metadata: (.metadata | { name: (.name)})}' | kubectl --namespace $NEW_NS create -f -
    echo "COMMAND: kubectl --namespace $NEW_NS patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"$SECRET_NAME\"}]}'"
    kubectl --namespace $NEW_NS patch serviceaccount default -p '{"imagePullSecrets": [{"name": "$SECRET_NAME"}]}'
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
    fi

    echo "Waiting on $1:$2 to be listening..."
		while ! nc -z $1 $2 &>> /dev/null; do
      sleep 0.5
    done
		shift 2
    echo "Executing $@"
		"$@"
  else
    echo "$1 cannot be resolved, please check your hostname"
  fi
}

docker-gc() {
  docker pull spotify/docker-gc &>> /dev/null
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker-gc
}

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

export PATH="$PATH:$HOME/bin:$HOME/.rvm/bin:$GOROOT/bin"

unalias gc
gc() {
  echo "COMMAND: git commit -asm \"$1\""
  git commit -asm "$1"
}

unalias gpu
gpu() {
  echo "COMMAND: git push upstream HEAD:${1:-master}"
  git push upstream HEAD:${1:-master}
}

function splat-pull ()
{
  docker pull ${SPLAT_IMAGE}
}

function splat ()
{
  WORKDIR=~/.splat/$(basename $PWD)

  docker run -it --rm \
    -e HOME=/home \
    -v ${HOME}:/home \
    -v ${PWD}:${WORKDIR} \
    -v /etc/group:/etc/group:ro \
    -v /etc/passwd:/etc/passwd:ro \
    -w ${WORKDIR} \
    --env-file <(env | grep "^SPLAT_") \
    -e DEBUG=${DEBUG} \
    -e NODE_DEBUG=${NODE_DEBUG} \
    --user=$(id -u) \
    ${SPLAT_IMAGE} "$@"
}

source <(helm completion zsh)
