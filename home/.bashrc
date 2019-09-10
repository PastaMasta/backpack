# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

set -o vi

export PATH=~/bin/:~/.local/bin/:${PATH}
export PS1='[\u@\h]\$ '

# Aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls -A --color=auto'
alias whence='type -p'

# Gitconfigs
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

# Typos
alias gerp='grep'
alias sl='ls'
# These don't seem to work as alias?
function ls- {
  ls -$*
}
function sl- {
  ls -$*
}
