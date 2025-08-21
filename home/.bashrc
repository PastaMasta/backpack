# .bashrc

[[ ${DEBUG} ]] && set -x

# Source global definitions
if [[ -f /etc/bashrc ]] ; then
  source /etc/bashrc
fi

# Source all other bits
for i in ~/.bashbag/* ; do
  source $i
done

export PATH=~/bin/:~/.local/bin/:~/scripts/:~/.cargo/bin:~/go/bin:~/.local/share/gem/ruby/3.0.0/bin:${PATH}

# Shell settings
set -o vi
set +H
export PS1='[\u@\h:$?]\$ ' # [user@host:exitcode]$
export PS2='>>'
shopt -s extglob

# The one true editor
export EDITOR="vim"

# SSH keys to add with ssh-keys()
sshkeys="${sshkeys}
${HOME}/.ssh/id_git
${HOME}/.ssh/id_github_pastamasta
"

#------------------------------------------------------------------------------+
# Aliases
#------------------------------------------------------------------------------+
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto -h --time-style=long-iso'
alias whence='type -p'
alias v='vim'
alias vi='vim'
alias view='vim -R' # /bin/view doesn't have syntax
alias c='clear'
alias grep='grep --color=auto'
alias less='less -R'
alias cal='cal -m'

# Commonly edited files
alias vimrc='${EDITOR} ~/.vimrc'
alias bashrc='${EDITOR} ~/.bashrc'
alias gitconfig='${EDITOR} ~/.gitconfig'
alias sshconfig='${EDITOR} ~/.ssh/config'

# Dir shortcuts
alias downloads='cd ~/downloads ; tw'
alias Downloads=downloads
alias backpack='cd -P ~/backpack ; tw'
alias notes='cd ~/notes ; tw'
alias scripts='cd ~/scripts ; tw'
alias bashbag='cd ~/.bashbag ; tw'

#------------------------------------------------------------------------------+
# Typos
#------------------------------------------------------------------------------+
alias it='git'
alias gerp='grep'
alias sl='ls'
alias vm='mv'
alias im='vim'
# These don't seem to work as alias?
function ls- {
  ls -$*
}
function sl- {
  ls -$*
}

#------------------------------------------------------------------------------+
# Functions
#------------------------------------------------------------------------------+

#--------------------------------------+
# Returns the basename of $PWD or a given path
#--------------------------------------+
function basepwd {
  if [[ -n $1 ]] ; then
    basename $(realpath $1)
  else
    basename $(pwd)
  fi
}
alias bpwd=basepwd

#--------------------------------------+
# Renames a tmux window to current dir name, or given string, or basename if it's a dir
# tw => backpack
# tw .. ==> root
# tw ../.. ==> /
# tw dave ==> dave
#--------------------------------------+
function tw {
  if [[ -n $1 ]] ; then
    if [[ -d $1 ]] ; then
      tmux rename-window "$(basepwd $1)"
    else
      tmux rename-window "$1"
    fi
  else
    tmux rename-window $(basepwd)
  fi
}

#--------------------------------------+
# AIX like pretty mount, because /bin/mount is pretty much unreadable
#--------------------------------------+
function mounted {
  if [[ $# -ge 1 ]] ; then # send to real mount if any args
    $(type -fP mount) $*
  else
    echo -e "------ ---------- --- -------\n$( \
      $(type -fP mount) 2>&1 | grep -v cgroup| awk '{print $1,$3,$5,$6}' \
    )" | column -t --table-columns 'Device,Mountpoint,vfs,Options'
  fi
}
alias mount="mounted"

#--------------------------------------+
# Begone proxy
#--------------------------------------+
function noproxy {
  unset http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
}

#--------------------------------------+
# Opens vim on the given file from $PATH or where an alias or function is defined
#--------------------------------------+
function vimtype {
  for i in $* ; do
    case $(type -t $i) in
      file) ${EDITOR} $(type -p $i) ;;
      alias) # Search bashrc files for the definition
        sources="
        ${HOME}/.bashrc
        ${HOME}/.bashbag/*
        /etc/bashrc
        "
        for source in ${sources} ; do
          IFS=: read -r sourcefile line _ <<<$(grep -n -H "alias ${i}=" ${source})
          [[ -n ${sourcefile} ]] || continue
          ${EDITOR} ${sourcefile} +${line}
        done
      ;;
      function) # Find where the funciton is defined
        shopt -s extdebug
        read -r _ line file <<<$(declare -F $i)
        shopt -u extdebug
        ${EDITOR} ${file} +${line}
      ;;
      *) type $i ;;
    esac
  done
}
complete -c vimtype

#--------------------------------------+
# Find which package something in $PATH is from
#--------------------------------------+
function pkgtype {
  if [[ -x $(type -p rpm) ]] ; then
    echo "rpm:"
   rpm -qf $(type -p $*)
  fi
  if [[ -x $(type -p dpkg ) ]] ; then
    echo "dpkg:"
    dpkg -S $(type -p $*)
  fi
  if [[ -x $(type -p gem ) ]] ; then
    echo "gem:"
    gem which $(type -p $*)
  fi
}
complete -c rpmtype
alias rpmtype=pkgtype

#--------------------------------------+
# Changes directory to where something in $PATH is from
#--------------------------------------+
function cdtype {
  cd $(dirname $(type -p $*))
}
complete -c cdtype

#--------------------------------------+
# Runs file on a param
#--------------------------------------+
function filetype {
  file $(type -p $*)
}
complete -c filetype

#--------------------------------------+
# finds any TODO: tags in files
# prints out $EDITOR, the file name, +linenumber and tag/comment
#--------------------------------------+
function todo {
  Files=${*:-*} # Defaults to all files
  grep -R -H -o -n -E "TODO:.*"  ${Files} | awk -F: '{print '"${EDITOR}"',$1,"+"$2,"#",substr($0, index($0,$3))}'
}

#--------------------------------------+
# TODO: make times configureable
# Retries a command until exit 0
#--------------------------------------+
function retry {
  TIMES=5
  SLEEP=1
  for TIME in $(seq 1 ${TIMES}) ; do
    $* && break
    sleep ${SLEEP}
    echo "Retrying: ${TIME} of ${TIMES}"
  done
}
complete -c retry

#--------------------------------------+
# Wrapper around ssh-agent to add variables to tmux
#--------------------------------------+
function ssh-agent-tmux {
  # Start ssh-agent if not already running
  if [[ -z ${SSH_AGENT_PID} ]] ; then
    printf "Starting ssh-agent: "
    eval $($(type -fP ssh-agent))
  fi

  # Add to tmux if we're in it
  if [[ -n ${TMUX} ]] ; then
    tmux set-environment SSH_AUTH_SOCK ${SSH_AUTH_SOCK}
    tmux set-environment SSH_AGENT_PID ${SSH_AGENT_PID}
  fi
}

#--------------------------------------+
# Adds ssh public key files in ${sshkeys} to the agent
# Starts agent if missing.
#--------------------------------------+
function ssh-keys {

  # Start agent if missing
  [[ -z ${SSH_AGENT_PID} ]] && ssh-agent-tmux

  # And add ssh keys if missing and if they actually exist
  for key in ${sshkeys} ; do

    if [[ -s ${key} ]] ; then
      ssh-add -l | grep -q -E "${key}\s" || ssh-add "${key}"
    else
      echo "${key} file does not exist?"
      continue
    fi

  done
}

function weather {
  curl wttr.in
}
