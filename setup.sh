#! /bin/bash

# Setup symlinks in ~/ to these config files

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/dotfiles"
configs=`ls -A ${DIR} | grep -vE ".git$|setup.sh"`

for config in ${configs} ; do

  if ln -s ${DIR}/${config} ~/${config} ; then
    echo "Linked ${DIR}/${config} to ~/${config}"
  fi

done

exit $?
