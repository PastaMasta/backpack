# .bashrc

[[ ${DEBUG} ]] && set -x

# Source global definitions
if [[ -f /etc/bashrc ]] ; then
  source /etc/bashrc
fi

# Shell settings
set -o vi
set +H

export PATH=~/bin/:~/.local/bin/:~/scripts/:${PATH}
export PS1='[\u@\h:$?]\$ ' # [user@host:exitcode]$
export EDITOR="vim"

# Import all other bits
for i in ~/.bashbag/* ; do
  source $i
done

# Start ssh-agent if not already running
if [[ -z ${SSH_AGENT_PID} ]] ; then
  eval $(ssh-agent)
  if [[ -n ${TMUX} ]] ; then
    tmux set-environment SSH_AUTH_SOCK ${SSH_AUTH_SOCK}
    tmux set-environment SSH_AGENT_PID ${SSH_AGENT_PID}
  fi
fi
# And add ssh keys if missing
for key in id_github_pastamasta id_rsa id_git ; do
  [[ ! -s ~/.ssh/${key} ]] && continue
  ssh-add -l | grep -q -E "/${key}\s" || ssh-add ~/.ssh/${key}
done

# tmux
# Connect to open session
# if already connected just bash it up

#------------------------------------------------------------------------------+
# Aliases
#------------------------------------------------------------------------------+
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls -A --color=auto -h --time-style=long-iso'
alias whence='type -p'
alias v='vim'
alias vi='vim'
alias view='vim -R' # /bin/view doesn't have syntax
alias c='clear'

alias vimrc='${EDITOR} ~/.vimrc'
alias bashrc='${EDITOR} ~/.bashrc'

#
# Dir shortcuts
#
alias downloads='cd ~/downloads ; tw'
alias Downloads=downloads
alias backpack='cd ~/backpack ; tw'
alias notes='cd ~/notes ; tw'
alias scripts='cd ~/scripts ; tw'

#
# Typos
#
alias it='git'
alias gerp='grep'
alias sl='ls'
alias vm='mv'
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

# Returns the basename of $PWD or a given path
function basepwd {
  if [[ -n $1 ]] ; then
    basename $(realpath $1)
  else
    basename $(pwd)
  fi
}
alias bpwd=basepwd

# Renames a tmux window to current dir name, or given string, or basename if it's a dir
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

# AIX like pretty mount, because /bin/mount is pretty much unreadable
function mounted {
  if [[ $# -ge 1 ]] ; then
    /bin/mount $*
  else
    echo -e "------ ---------- --- -------\n$( \
    /bin/mount 2>&1 | grep -v cgroup| awk '{print $1,$3,$5,$6}' \
    )" | column -t --table-columns 'Device,Mountpoint,vfs,Options'
  fi
}
alias mount="mounted"

# Begone proxy
function noproxy {
  unset http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
}

# Opens vim on the given file from $PATH or where an alias or function is defined
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

# Find which RPM something in $PATH is from
function rpmtype {
  rpm -qf $(type -p $*)
}
complete -c rpmtype

# Changes directory to where something in $PATH is from
function cdtype {
  cd $(dirname $(type -p $*))
}
complete -c cdtype

# finds any TODO: tags in files
function todo {
  Files=${*:-*} # Defaults to all files
  grep -R -H -o -n -E "TODO:.*"  ${Files} | awk -F: '{print '"${EDITOR}"',$1,"+"$2,"#",substr($0, index($0,$3))}'
}

# sorted df
function df {
  if [[ $# -le 0 ]] | [[ $1 == '-h' ]] ; then
    /usr/bin/df -h | sort -r -k 5 -i
  else
    /usr/bin/df $*
  fi
}

# Retries a command until exit 0
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
