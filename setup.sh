#! /bin/bash
[[ -n ${DEBUG} ]] && set -x

#
# Personal environment setup script:
# - Sets up symlinks for all my custom configs, dot files and other items between ./home and $HOME
# - Runs ansible to handle everyhting else
#

#------------------------------------------------------------------------------+
# Functions
#------------------------------------------------------------------------------+

# Checks and validates links
function link {
  typeset source=$1
  typeset target=$2

  if [[ ! -e ${target} ]] ; then # Target doesn't exist
    ln -s ${source} ${target}
  elif [[ -L ${target} ]] ; then # Check where the link goes

    if [[ $(readlink ${target}) == ${source} ]] ; then # nothing to do
      [[ -n ${DEBUG} ]] && echo "${target} is already linked to: $(readlink ${target})"
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
  typeset files=`find ${source} -mindepth 1 -maxdepth 1 ! -name "*.swp"`

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

#------------------------------------------------------------------------------+
# main()
#------------------------------------------------------------------------------+

# full path to the repo so symlinks aren't relative
repodir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repohome="${repodir}/home"
repoversioned="${repodir}/versioned"

# Handle if we've got any files for specific package versions,
case $(tmux -V) in
  *1*) ln -f -s ${repoversioned}/.tmux.conf.v1 ${repohome}/.tmux.conf ;;
  *2*) ln -f -s ${repoversioned}/.tmux.conf.v2 ${repohome}/.tmux.conf ;;
  *3*) ln -f -s ${repoversioned}/.tmux.conf.v3 ${repohome}/.tmux.conf ;;
  *) ln -f -s ${repoversioned}/.tmux.conf.v3 ${repohome}/.tmux.conf ;; # Assume latest
esac

# Link everything under ./home to ${HOME}
findandlink ${repohome} ${HOME}

# WSL extras
if [[ -n ${WSL_DISTRO_NAME} ]] ; then
  source home/.bashbag/wsl
  downloads=$(win2lin_path $(cmd.exe /Q /C "echo %userprofile%\Downloads" 2>/dev/null)|dos2unix)
  link ${downloads} ~/Downloads
  link ~/Downloads ~/downloads
fi

# Install all the packages!
if [[ -x $(type -p ansible-playbook) ]] ; then
  ansible-galaxy collection install community.general
  ansible-playbook ./setup.ansible.yaml --ask-become-pass
else
  echo "Ansible not installed or executable!"
fi

#------------------------------------------------------------------------------+
# Misc extra tasks
#------------------------------------------------------------------------------+

# tmux plugins
if [[ ! -d ~/.tmux/plugins/tpm ]] ; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install vim plugins if it's the first time
[[ ! -d ~/.vim/plugged/ ]] && vim -c PlugInstall

# Ensure man db is setup and updated
sudo mandb > /dev/null

# Clone other git repos if missing
[[ -d ~/notes ]] || git clone git@github.com:PastaMasta/notes.git ${repodir}/../notes
[[ -d ~/scripts ]] || git clone git@github.com:PastaMasta/scripts.git ${repodir}/../scripts

exit $?
