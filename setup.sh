#! /bin/bash

# Setup symlinks in ~/ to these config files

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/dotfiles"
configs=`ls -A ${DIR} | grep -vE ".git$|setup.sh"`

for config in ${configs} ; do

  if [[ -f ~/${config} ]] ; then
    echo "Backing up ~/${config} to ~/${config}.old"
    mv ~/${config} ~/${config}.old
  fi

  echo "Linking ${DIR}/${config} to ~/${config}"
  ln -fs ${DIR}/${config} ~/${config}

done

exit $?
