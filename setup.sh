#! /bin/bash

# 
# Sets up symlinks my custom configs, dot files and other items
#

# Checks and validates links
function link {
  source=$1
  target=$2

  if [[ -L ${target} ]] ; then

    if [[ ! $(readlink ${target}) == ${source} ]] ; then
      echo "${target} is linked to $(readlink ${target}) !"
    fi

  elif [[ -f ${target} || -d ${target} ]] ; then
    echo "${target} already exists!"
  else
    ln -s ${source} ${target}
  fi
}

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#
# Setup symlinks in ~/ for dotfiles (.bashrc etc)
#
dotfile_dir="${basedir}/home/dotfiles"
dotfiles=`ls ${dotfile_dir}`

for dotfile in ${dotfiles} ; do
  file="${dotfile_dir}/${dotfile}"
  link ${file} ~/.${dotfile}
done

#
# Setup dotdirs (~/.ssh etc)
#
dotdir_dir="${basedir}/home/dotdirs"
dotdirs=`ls ${dotdir_dir}`

for dotdir in ${dotdirs} ; do
  dir="${dotdir_dir}/${dotdir}"

  # Just link if it's not there, merge if the dir is.
  if [[ ! -d ~/.${dotdir} ]] ; then
    link ${dir} ~/.${dotdir}
  else
    for dotdirfile in `ls ${dir}` ; do
      link ${dir}/${dotdirfile} ~/.${dotdir}/${dotdirfile}
    done
  fi

done
