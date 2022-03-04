#! /bin/bash
[[ -n ${DEBUG} ]] && set -x

#
# Sets up symlinks for my custom configs, dot files and other items.
# Also installs packages I like and sets up vim plugins.
#

#------------------------------------------------------------------------------+
# Checks and validates links
#------------------------------------------------------------------------------+
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

#------------------------------------------------------------------------------+
# Recursive function to Find files in source dir and symlink to target
#------------------------------------------------------------------------------+
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
# Takes a list of packages and retuns a list of those not installed
# so output isn't spammed with "already installed" etc
#------------------------------------------------------------------------------+
function packagecheck {
  typeset type=$1
  shift
  typeset packages=""
  case ${type} in
    rpm)
      for rpm in $* ; do
        rpm -q ${rpm} > /dev/null || packages="${packages} ${rpm}"
      done
    ;;
    gem)
      for gem in $* ; do
        gem info -i ${gem} > /dev/null || packages="${packages} ${gem}"
      done
    ;;
  esac
  echo ${packages}
}

#------------------------------------------------------------------------------+
# main()
#------------------------------------------------------------------------------+

# full path to the repo so symlinks aren't relative
repodir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
repohome="${repodir}/home"
repoversioned="${repodir}/versioned"

#------------------------------------------------------------------------------+
# Package installs # TODO: move this to ansible ?
#------------------------------------------------------------------------------+
rpms="
git
tig
vim-enhanced
tmux
findutils
psmisc
xpanes
lsof
nmap
nmap-ncat
vagrant
curl
wget
tree
jq
pipenv
ansible
rsync
man-db
man-pages
bash-completion
"

# Check what platform we're on for different install lists
platform=""
if [[ -f /etc/os-release ]] ; then
  source /etc/os-release
  platform=${ID}
fi

# Install all the fun os packages
case ${platform} in
 centos|amzn|fedora)
   rpms_to_install=$(packagecheck rpm ${rpms})
   if [[ -n ${rpms_to_install} ]] ; then
     echo "Installing missing packages: ${rpms_to_install}"
     sudo yum install ${rpms_to_install}
   fi
  ;;
esac

# Install gems
gems="
pry
mdl
"
gems_to_install=$(packagecheck gem ${gems})
if [[ -n ${gems_to_install} ]] ; then
  echo "Installing missing gems: ${gems_to_install}"
  gem install ${gems_to_install}
fi

# TODO: Install pips
pips="
"

#------------------------------------------------------------------------------+
# Compile and build our own versions of tmux and vim # TODO: ???
#------------------------------------------------------------------------------+

#------------------------------------------------------------------------------+
# Handle if we've got any files for specific package versions,
# then link everything up
#------------------------------------------------------------------------------+
case $(tmux -V) in
  *1*) ln -f -s ${repoversioned}/.tmux.conf.v1 ${repohome}/.tmux.conf ;;
  *2*) ln -f -s ${repoversioned}/.tmux.conf.v2 ${repohome}/.tmux.conf ;;
esac

# Link everything under ./home to ${HOME}
findandlink ${repohome} ${HOME}

#------------------------------------------------------------------------------+
# Misc extra tasks
#------------------------------------------------------------------------------+

# Install vim plugins if it's the first time
[[ ! -d ~/.vim/plugged/ ]] && vim -c PlugInstall

# Setup Vagrant if we're in WSL
if [[ -n ${WSL_DISTRO_NAME} ]] ; then
  if ! vagrant plugin list | grep -q virtualbox_WSL2 ; then
   vagrant plugin install virtualbox_WSL2
   vagrant plugin repair
  fi
fi

# Ensure man db is setup
sudo mandb > /dev/null

# Clone other git repos if missing
[[ -d ~/notes ]] || git clone git@github.com:PastaMasta/notes.git ~/notes
[[ -d ~/scripts ]] || git clone git@github.com:PastaMasta/scripts.git ~/scripts

exit $?
