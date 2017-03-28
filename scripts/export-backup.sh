#! /bin/bash

#
# Copies borgbackup repos to external media for offsite backups.
# Handles borg lockfiles as required.
#

config_file="${HOME}/.borg-backups.conf"
lock_timeout=15 # seconds

function usage {
  echo "Could not read config file or find variables!"
  echo "Please check if ${config_file} exists with repos_to_backup and export_target exported
  repos_to_backup - list of paths to borg repos
  export_target - dir to export backups to"
  exit 1
}

if [[ -r "${config_file}" ]] ; then
  . ${config_file}
else
  echo "Couldn't read ${config_file} !"
  usage
fi

[[ -z ${repos_to_backup} ]] && usage
[[ -z ${export_target} ]] && usage

###############################

function lock_repo {
  repo=$1
  echo '{"exclusive": [["backup-export", '"$$"', 0]]}' > ${repo}/lock.roster
  mkdir ${repo}/lock.exclusive 2> /dev/null
  touch ${repo}/lock.exclusive/backup-export.$$-0
}

function unlock_repo {
  repo=$1
  rm -rf ${repo}/lock.exclusive
  rm ${repo}/lock.roster
}

function check_if_locked {
  repo=$1
  if [[ -e ${repo}/lock.exclusive ]] ; then
    echo "${repo} is locked"
    return 1
  else
    return 0
  fi
}

###############################
# main

for repo in ${repos_to_backup} ; do
  if [[ `cat ${repo}/README 2>/dev/null` == "This is a Borg repository" ]] ; then

    timeout=0
    while true ; do
      if [[ ${timeout} -ge ${lock_timeout} ]] ; then
        echo "Timed out waiting for lock (${lock_timeout}s)"
        exit 1
      fi
      check_if_locked ${repo} && break
      timeout=`expr ${timeout} + 1`
      sleep 1
    done

    lock_repo ${repo}
    cp -a ${repo} ${export_target}
    unlock_repo ${repo}
    unlock_repo ${export_target}/`basename ${repo}`

    echo "Backed up ${repo} to ${export_target}"

  else
    echo "${repo} is not a borg repo! Skipping."
    continue
  fi
done

