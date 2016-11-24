#! /bin/bash

#
# Uses borg to backup a set of directories to a borg repository
# specified in a configuration file.
#
# Default config file:
config_file="${HOME}/.borg-backups.conf"

[[ $# -gt 0 ]] && config_file=$1

function usage {
  echo "Usage:"
  echo "$* /path/to/config_file"
  exit 1
}

if [[ -r "${config_file}" ]] ; then
  . ${config_file}
else
  echo "Couldn't read ${config_file} !"
  usage $0
fi


borg create -C none ${REPOSITORY}::'{hostname}-{now:%Y-%m-%d_%H:%M:%S}' ${TARGETS} 
# borg prune -v ${REPOSITORY} --prefix '{hostname}-' --keep-within=7d --keep-weekly=4 --keep-monthly=6
