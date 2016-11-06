#! /bin/bash

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup symlinks in ~/ for dotfiles
dotfiles=`ls ${basedir}/dotfiles`

for dotfile in ${dotfiles} ; do

  file="${basedir}/${dotfile}"

  if ln -s ${file} ~/.${dotfile} ; then
    echo "Linked ${file} to ~/${dotfile}"
  fi

done

# Setup config
if ln -s ${basedir}/config ~/.config ; then
    echo "Linked ${basedir}/config to ~/.config"
fi

# SSH config for github etc
[[ ! -d ~/.ssh ]] && mkdir -p ~/.ssh
if ln -s ${basedir}/ssh/config ~/.ssh/config; then
    echo "Linked ${basedir}/config to ~/.config"
fi

exit $?
