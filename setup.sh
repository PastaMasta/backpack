#! /bin/bash
[[ -n ${DEBUG} ]] && set -x

#
# Personal environment setup script:
# - Sets up symlinks for all my custom configs, dot files and other items between ./home and $HOME
# - Runs ansible to handle package installs
# - Setup tmux and vim plugins
# - Clones other git repos next to where this repo has been cloned down
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
esac

# Link everything under ./home to ${HOME}
findandlink ${repohome} ${HOME}

# Install all the packages!
if [[ -x $(type -p ansible-playbook) ]] ; then
  ansible-galaxy collection install community.general
  ansible-playbook ./packages.ansible.yaml
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

# Setup Vagrant if we're in WSL
if [[ -n ${WSL_DISTRO_NAME} ]] ; then
  if [[ -x $(type -p vagrant) ]] ; then
    if ! vagrant plugin list | grep -q virtualbox_WSL2 ; then
     vagrant plugin install virtualbox_WSL2
     vagrant plugin repair
    fi
  fi
fi

# Ensure man db is setup and updated
sudo mandb > /dev/null

# Clone other git repos if missing
[[ -d ~/notes ]] || git clone git@github.com:PastaMasta/notes.git ${repodir}/../notes
[[ -d ~/scripts ]] || git clone git@github.com:PastaMasta/scripts.git ${repodir}/../scripts

exit $?
