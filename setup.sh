#! /bin/bash
[[ $DEBUG ]] && set -x

# 
# Sets up symlinks my custom configs, dot files and other items
#

# Checks and validates links
function link {
  typeset source=$1
  typeset target=$2

  if [[ ! -e ${target} ]] ; then
    ln -s ${source} ${target}
  elif [[ -L ${target} ]] ; then
    if [[ $(readlink ${target}) == ${source} ]] ; then
      [[ $DEBUG ]] && echo "${target} is already linked to $(readlink ${target}) !"
    else
      echo "${target} is linked to $(readlink ${target}) !"
    fi
  else
    echo "${target} already exists!"
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

# main

# full path to the repo so symlinks aren't relative
repodir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repohome="${repodir}/home"

findandlink ${repohome} ${HOME}

exit $?
