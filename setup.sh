#! /bin/bash

# Setup symlinks in ~/ for dotfiles

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/dotfiles"
dotfiles=`ls ${basedir} | grep -vE ".git$|setup.sh"`

for dotfile in ${dotfiles} ; do

  file="${basedir}/${dotfile}"

  if ln -s ${file} ~/.${dotfile} ; then
    echo "Linked ${file} to ~/${dotfile}"
  fi

done

# Setup config
if ln -s ${basedir}/config ~/.config ; then
    echo "Linked ${DIR}/config to ~/.config"
fi

exit $?
