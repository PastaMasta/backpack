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
      tmux rename-window $(basepwd $1)
    else
      tmux rename-window $1
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
      file) vim $(type -p $i) ;;
      alias) # Search bashrc files for the definition
        sources="
        ${HOME}/.bashrc
        ${HOME}/.bashbag/*
        /etc/bashrc
        "
        for source in ${sources} ; do
          IFS=: read -r sourcefile line _ <<<$(grep -n -H "alias ${i}=" ${source})
          [[ -n ${sourcefile} ]] || continue
          vim ${sourcefile} +${line}
        done
      ;;
      function) # Find where the funciton is defined
        shopt -s extdebug
        read -r _ line file <<<$(declare -F $i)
        shopt -u extdebug
        vim ${file} +${line}
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
  File=${1:-*} # Defaults to all files
  grep -R -H -o -n -E "TODO:.*"  ${File} | awk -F: '{print "vim",$1,"+"$2,"#",substr($0, index($0,$3))}'
}
