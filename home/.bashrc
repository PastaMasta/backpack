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
  if [[ -x tig ]] ; then
    tig $*
  else
    git log --graph --decorate --oneline $*
  fi
}

# Typos
alias gerp='grep'
alias sl='ls'
