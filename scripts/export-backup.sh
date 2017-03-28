#! /bin/bash

#
# Copies borgbackup repos to external media for offsite backups.
# Handles borg lockfiles as required.
#

config_file="${HOME}/.borg-backups.conf"

if [[ -r "${config_file}" ]] ; then
  . ${config_file}
else
  echo "Couldn't read ${config_file} !"
fi

[[ -z ${repos_to_backup} ]] && exit 1
[[ -z ${export_target} ]] && exit 1

lock_timeout=15 # seconds
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
      [[ ${timeout} -ge ${lock_timeout} ]] && exit 1
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

