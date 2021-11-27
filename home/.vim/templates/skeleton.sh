#! /bin/bash
[[ -n ${DEBUG} ]] && set -x

function usage {
  echo "$0"
  exit 1
}
[[ $# -lt 1 ]] && usage
