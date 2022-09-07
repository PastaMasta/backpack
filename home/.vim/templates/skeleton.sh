#! /bin/bash
[[ -n ${DEBUG} ]] && set -x

#
# What does this do?
#

usage() {
  echo "$0"
  exit 1
}
[[ $# -lt 1 ]] && usage
