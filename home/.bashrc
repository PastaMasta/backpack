# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Shell settings
set -o vi
set +H

export PATH=~/bin/:~/.local/bin/:~/scripts/:${PATH}
export PS1='[\u@\h:$?]\$ ' # [user@host:exitcode]$
export EDITOR="vim"

#-----------------------------------------------------------------------------+
# Aliases
#-----------------------------------------------------------------------------+
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls -A --color=auto'
alias whence='type -p'
alias v='vim'
alias view='vim -R' # /bin/view doesn't have syntax
function basepwd {
  basename `pwd`
}

#
# Dir shortcuts
#
alias backpack='cd ~/backpack'
alias notes='cd ~/notes'
alias scripts='cd ~/scripts'

#
# Git stuff
#
alias s='git status ; git stash list'
alias b='git branch -av'
alias d='git diff'
alias dc='git diff --cached'
alias r='git remote -v'
alias t='git tag | sort -V'
function l {
  if [[ -x `type -p tig` ]] ; then
    tig $*
  else
    git log --graph --all --full-history --color --oneline $*
  fi
}
alias lo='git log --oneline'

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

#-----------------------------------------------------------------------------+
# Functions
#-----------------------------------------------------------------------------+

# AIX like pretty mount, because /bin/mount is pretty much unreadable
function mounted {
  if [[ $# -ge 1 ]] ; then
    /bin/mount $*
  else
    printf "====== ========== ==== =======\n` \
    /bin/mount 2>&1 | grep -v cgroup| awk '{print $1,$3,$5,$6}' | sort -k 2 -r \
    `" | column -t --table-columns Device,Mountpoint,Type,Options
  fi
}
