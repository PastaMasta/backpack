# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mounted='mount | column -t'

# misc
set -o vi
export PS1='[\u@\h]\$ '
