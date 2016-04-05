#! /bin/bash

# Setup symlinks in ~/ for dotfiles

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/dotfiles"
configs=`ls -A ${DIR} | grep -vE ".git$|setup.sh"`

for config in ${configs} ; do

  if ln -sf ${DIR}/${config} ~/.${config} ; then
    echo "Linked ${DIR}/${config} to ~/${config}"
  fi

done

# Setup config
if ln -sf ${DIR}/config ~/.config ; then
    echo "Linked ${DIR}/config to ~/.config"
fi

exit $?
