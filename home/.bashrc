# .bashrc

[[ ${DEBUG} ]] && set -x

# Source global definitions
if [ -f /etc/bashrc ]; then
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
alias ls='ls -A --color=auto -h'
alias whence='type -p'
alias v='vim'
alias vi='vim'
alias view='vim -R' # /bin/view doesn't have syntax
function basepwd {
  basename `pwd`
}
alias bpwd=basepwd
alias c='clear'

#
# Dir shortcuts
#
alias backpack='cd ~/backpack ; tw'
alias notes='cd ~/notes ; tw'
alias scripts='cd ~/scripts ; tw'

#
# Typos
#
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

# Renames a tmux window to current dir name
function tw {
  if [[ -n $1 ]] ; then
    tmux rename-window $1
  else
    tmux rename-window `basepwd`
  fi
}

# AIX like pretty mount, because /bin/mount is pretty much unreadable
function mounted {
  if [[ $# -ge 1 ]] ; then
    /bin/mount $*
  else
    echo -e "------ ---------- --- -------\n` \
    /bin/mount 2>&1 | grep -v cgroup| awk '{print $1,$3,$5,$6}' | sort -k 2 -r \
    `" | column -t --table-columns 'Device,Mountpoint,vfs,Options'
  fi
}

function cdmkdir {
  mkdir -p $1 ; cd $1
}

function noproxy {
  export http_proxy=""
  export https_proxy=""
  export no_proxy=""
}

function vimtype {
  vim `type -p $1`
}
