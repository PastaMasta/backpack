#! /bin/bash
[[ $DEBUG ]] && set -x

#
# Sets up symlinks for my custom configs, dot files and other items
#

# Checks and validates links
function link {
  typeset source=$1
  typeset target=$2

  if [[ ! -e ${target} ]] ; then # Target doesn't exist
    ln -s ${source} ${target}
  elif [[ -L ${target} ]] ; then # Check where the link goes

    if [[ $(readlink ${target}) == ${source} ]] ; then # nothing to do
      [[ $DEBUG ]] && echo "${target} is already linked to: $(readlink ${target})"
    elif readlink ${target} | grep -q backpack-local ; then # Linked to local copy
      echo "${target} is already linked to local version: $(readlink ${target})"
    else # Linked elsewhere
      echo "${target} is linked to $(readlink ${target})"
      ln -s ${source} ${target} -f -i
    fi

  else # If it's already there but not a link
    echo "${target} already exists!"
    ln -s ${source} ${target} -f -i
  fi
}

# Recursive function to Find files in source dir and symlink to target
function findandlink {
  typeset source=$1
  typeset target=$2
  typeset files=`find ${source} -mindepth 1 -maxdepth 1`

  for file in ${files} ; do
    filebase=`basename ${file}`
    if [[ -d ${file} ]] ; then
      mkdir -p ${target}/${filebase}
      findandlink ${file} ${target}/${filebase}
    else
      link ${file} ${target}/${filebase}
    fi
  done
}

# Takes a list of RPMS and retuns a list of those not installed
function rpmcheck {
  typeset rpms=""
  for rpm in $* ; do
    rpm -q $rpm > /dev/null || rpms="${rpms} ${rpm}"
  done
  echo ${rpms}
}

# main

# full path to the repo so symlinks aren't relative
repodir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repohome="${repodir}/home"
repoversioned="${repodir}/versioned"


# Install all the fun things
platform=""
if [[ -f /etc/os-release ]] ; then
  source /etc/os-release
  platform=${ID}
fi
case ${platform} in
 centos|amzn|fedora)
   rpms=$(rpmcheck git tig vim-enhanced tmux)
   [[ -n ${rpms} ]] && yum install ${rpms}
  ;;
esac

# Handle if we've got any files for specific package versions
case $(tmux -V) in
  *1*) ln -f -s ${repoversioned}/.tmux.conf.v1 ${repohome}/.tmux.conf ;;
  *2*) ln -f -s ${repoversioned}/.tmux.conf.v2 ${repohome}/.tmux.conf ;;
esac

# Link everything under ./home to ${HOME}
findandlink ${repohome} ${HOME}

# Install vim plugins if it's the first time
[[ ! -d ~/.vim/plugged/ ]] && vim -c PlugInstall

exit $?
