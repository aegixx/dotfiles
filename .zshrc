source ~/.iterm2_shell_integration.`basename $SHELL`
source ~/.zshrc_protected
if command -v pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# export KUBECONFIG=~/.kube/config:`find ~/.kube/conf.d -type f | tr '\n' ':'`
JAVA_HOME=`/usr/libexec/java_home -v 11`
GOPATH=~/go
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$(brew --prefix dvm)/dvm.sh" ]] && source "$(brew --prefix dvm)/dvm.sh"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
PERL5LIB=/usr/local/lib/perl5/site_perl:${PERL5LIB}
AWS_CREDENTIAL_FILE=~/.aws/credentials
PATH="/usr/local/opt/openssl/bin:$PATH"
LDFLAGS="-L/usr/local/opt/openssl/lib"
CPPFLAGS="-I/usr/local/opt/openssl/include"
PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"

# $(aws ecr get-login) &>> /dev/null

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  EDITOR='vim'
else
  EDITOR="$(command -v code) -a"
fi
GIT_EDITOR="$(command -v code) -aw"
KUBE_EDITOR="$(command -v code) -aw"

export JAVA_HOME && export GOPATH && export PERL5LIB && \
export AWS_CREDENTIAL_FILE && export PATH && export LDFLAGS && \
export CPPFLAGS && export PKG_CONFIG_PATH && export EDITOR && \
export GIT_EDITOR && export KUBE_EDITOR

alias ls="ls -G"
alias ll="ls -AlhG"
alias t="tree"
alias e="$EDITOR"
alias edit="e"
alias truncate="cp /dev/null $@"
alias listening="sudo lsof -nP -iTCP -sTCP:LISTEN"
alias rails-reset="rails db:drop db:create db:migrate db:seed && RAILS_ENV=test rails db:drop db:create db:migrate db:seed"
alias gs="git status"
alias brewup='brew update; brew upgrade; brew cleanup; brew doctor'
alias sysup="brewup; mas upgrade"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]"'
alias ssh-fwd-ls="sudo lsof -i -n | egrep '\<ssh\>'"
alias ifconfig="env ifconfig -v \$(env ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active' | egrep -o -m 1 '^[^\t:]+')"

killzombies() {
  procs=$(pgrep -xaw -o state -o ppid Z | grep -v PID | awk '{print $2}')
  echo "$procs" | xargs kill -9
}

zipedit(){
    echo "Usage: zipedit archive.zip folder/file.txt"
    curdir=$(pwd)
    unzip "$1" "$2" -d /tmp 
    cd /tmp
    vi "$2" && zip --update "$curdir/$1"  "$2" 
    # remove this line to just keep overwriting files in /tmp
    rm -f "$2" # or remove -f if you want to confirm
    cd "$curdir"
}

ssh-fwd() {
  echo "COMMAND: ssh -f $1 -L $3:$2:$3 -N"
  ssh -f $1 -L $3:$2:$3 -N
}

aws-sh() {
  echo "COMMAND: aws-vault exec --no-session --assume-role-ttl 1h ${1:-default} $SHELL"
  aws-vault exec --no-session --assume-role-ttl 1h ${1:-default} $SHELL
}

aws-tmp() {
  echo "COMMAND: aws-vault exec --no-session --assume-role-ttl 1h ${1:-default} $SHELL -- -c \"echo \\\"[${2:-default}]\\\naws_access_key_id=\\\${AWS_ACCESS_KEY_ID}\\\naws_secret_access_key=\\\${AWS_SECRET_ACCESS_KEY}\\\naws_session_token=\\\${AWS_SESSION_TOKEN}\" > ~/.aws/credentials"
  aws-vault exec --no-session --assume-role-ttl 1h ${1:-default} $SHELL -- -c "echo \"[${2:-default}]\naws_access_key_id=\${AWS_ACCESS_KEY_ID}\naws_secret_access_key=\${AWS_SECRET_ACCESS_KEY}\naws_session_token=\${AWS_SESSION_TOKEN}\" > ~/.aws/credentials"
}

kstatus() {
  echo "COMMAND: watch -ctd \"kubectl get appstatus --all-namespaces -o json | jq -jr '.items[] | (.metadata | \"\(.namespace) | \(.name)\"), (.spec.charts[-1] | \" | \(.name) | \(.status) | \(.output)\n\")' | sort -t'|' -k4 | column -c $(tput cols) -t -s '|'\""
  watch -ctd "kubectl get appstatus --all-namespaces -o json | jq -jr '.items[] | (.metadata | \"\(.namespace) | \(.name)\"), (.spec.charts[-1] | \" | \(.name) | \(.status) | \(.output)\n\")' | sort -t'|' -k4 | column -c $(tput cols) -t -s '|'"
}

git-release-notes() {
  TAG=${1:-$(git describe --tags --abbrev=0)}
  echo "Changes since ${TAG}"
  git log ${TAG}..HEAD --oneline | grep -v Merge | xargs -l echo '*'
}

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

docker-sh() {
  echo "COMMAND: docker exec -it $1 ${2:-bash}"
  docker exec -it $1 ${2:-bash}
}

docker-gc() {
  docker pull spotify/docker-gc &>> /dev/null
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker-gc
}

docker-cleanup() {
  echo "Cleaning containers..."
  docker ps -aq | xargs docker rm -fv
  echo "Cleaning volumes..."
  docker volume ls -qf dangling=true | xargs docker volume rm
  echo "Cleaning networks..."
  docker network ls -q | xargs docker network rm
}

git-upstream() {
  echo "git fetch ${1=upstream}" && git fetch ${1=upstream}
  echo "git rebase ${1=upstream}/${2=master}" && git rebase ${1=upstream}/${2=master}
}

git-prune() {
  echo "COMMAND: git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d"
  git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
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

krun() {
  NAME=bas
  KUBE_NAMESPACE=${KUBE_NAMESPACE:-default}

  kubectl delete -n $KUBE_NAMESPACE deploy/$NAME &> /dev/null

  IMAGE=docker.trebuchetdev.com/lme-tester
  CMD=/bin/sh
  if [ $# -gt 1 ]; then
    IMAGE=$1
    shift 1
    CMD=$@
  elif [ $# -gt 0 ]; then
    CMD=$@
  fi
  echo "COMMAND: kubectl run --quiet -n $KUBE_NAMESPACE bas -i --tty --rm --image=$IMAGE -- $CMD"
  kubectl run --quiet -n $KUBE_NAMESPACE bas -i --tty --rm --image=$IMAGE -- $CMD
  kubectl delete -n $KUBE_NAMESPACE deploy/$NAME &> /dev/null
}

# Fire kubectl command for selected namespace
k() {
  if [[ "${KUBE_NAMESPACE}x" != "x" ]]; then
    echo "COMMAND: kubectl -n $KUBE_NAMESPACE "$@""
    kubectl -n $KUBE_NAMESPACE "$@"
  else
    echo "COMMAND: kubectl "$@""
    kubectl "$@"
  fi
}

# Setup background port-forwarding to a specific pod
kport() {
  if [ $# -gt 1 ]; then
      echo "COMMAND: while kubectl --namespace $KUBE_NAMESPACE port-forward $1 $2 &>> /dev/null; do :; done &"
      while kubectl --namespace $KUBE_NAMESPACE port-forward $1 $2 &>> /dev/null; do :; done &
  else
    echo "USAGE: kport [pod] [port]"
  fi
}

klog() {
  echo "COMMAND: kubectl --namespace $KUBE_NAMESPACE logs --timestamps --since=1h -f $@"
  kubectl --namespace $KUBE_NAMESPACE logs --timestamps --since=1h -f $@
}

ktail() {
  echo "COMMAND: kubetail --namespace $KUBE_NAMESPACE --timestamps --since 1h $@"
  kubetail --namespace $KUBE_NAMESPACE --timestamps --since 1h $@
}

# Switch namespaces
kswitch() {
  echo "COMMAND: kubectl config use-context $1"
  kubectl config use-context $1
}

# Watch K8s resources globally or for a specific namespace
kwatch() {
  if [ -z $1 ]; then
    echo "COMMAND: watch -ct \"kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc,crd -o wide --no-headers=true --all-namespaces | grep -v ^kube-system\""
    watch -ct "kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc,crd -o wide --no-headers=true --all-namespaces | grep -v ^kube-system"
  else
    NS=$1
    shift 1
    echo "COMMAND: watch -ct \"kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc,crd -o wide --no-headers=true --namespace $NS $@\""
    watch -ct "kubectl get po,ds,deploy,hpa,ing,statefulsets,jobs,configmap,rs,rc,svc,pvc,crd -o wide --no-headers=true --namespace $NS $@"
  fi
}

# Watch events globally or from a specific namespace
kevent() {
  if [ -z $1 ]; then
    echo "COMMAND: while kubectl get ev --watch-only --all-namespaces --no-headers -o wide ; do :; done"
    while kubectl get ev --watch-only --all-namespaces --no-headers -o wide ; do :; done
  else
    echo "COMMAND: while kubectl --namespace $1 get ev --watch-only --no-headers -o wide ; do :; done"
    while kubectl --namespace $1 get ev --watch-only --no-headers -o wide ; do :; done
  fi
}

# Migrates K8s secrets from one namespace to another
ksecret() {
  if [ $# -lt 3 ]; then
    echo "USAGE: ksecret <secret_name> <old-ns> <new-ns>"
  else
    SECRET_NAME=$1
    OLD_NS=$2
    NEW_NS=$3
    echo "COMMAND: kubectl --namespace $OLD_NS get secret $SECRET_NAME -o json | jq '{apiVersion,data,kind,type} + {metadata: (.metadata | { name: (.name)})}' | kubectl --namespace $NEW_NS create -f -"
    kubectl --namespace $OLD_NS get secret $SECRET_NAME -o json | jq '{apiVersion,data,kind,type} + {metadata: (.metadata | { name: (.name)})}' | kubectl --namespace $NEW_NS create -f -
    echo "COMMAND: kubectl --namespace $NEW_NS patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"$SECRET_NAME\"}]}'"
    kubectl --namespace $NEW_NS patch serviceaccount default -p '{"imagePullSecrets": [{"name": "$SECRET_NAME"}]}'
  fi
}

# Wait for a given host or ip to be listening on a specific port
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

get-user-profiles() {
  if [ $# -lt 1 ]; then
    echo "USAGE: STAGE=prod get-user-profiles <profile-type>"
  else
    echo "COMMAND: aws dynamodb scan --table-name jobspring-${STAGE:-prod}-user-profiles --no-paginate | jq -c \".Items[] | select(.type.S==\"$1\") | {name: (.firstName.S + \" \" + .lastName.S), email: .email.S}\" | jq -s '. | unique'"
    aws dynamodb scan --table-name jobspring-${STAGE:-prod}-user-profiles --no-paginate | jq -c ".Items[] | select(.type.S==\"$1\") | {name: (.firstName.S + \" \" + .lastName.S), email: .email.S}" | jq -s '. | unique'
  fi
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

# command -v plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(cp aws gpg-agent sudo jsontools colorize rvm themes osx screen git vagrant brew ruby jira battery web-search command-not-found docker kubectl docker-compose emoji zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/sbin:$HOME/bin:$GOPATH/bin:$PATH"

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

unalias k
source <(helm completion zsh)
# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/bryan.stone/go/src/github.com/LF-Engineering/LFF/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/bryan.stone/go/src/github.com/LF-Engineering/LFF/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/bryan.stone/go/src/github.com/LF-Engineering/LFF/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/bryan.stone/go/src/github.com/LF-Engineering/LFF/node_modules/tabtab/.completions/sls.zsh

# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /Users/bryan.stone/node_modules/tabtab/.completions/slss.zsh ]] && . /Users/bryan.stone/node_modules/tabtab/.completions/slss.zsh
export PATH="/usr/local/opt/openal-soft/bin:$PATH"
