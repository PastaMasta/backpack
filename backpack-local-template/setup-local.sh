#! /bin/bash
[[ -n ${DEBUG} ]] && set -x

#
# Sets up a local-specific backpack, prioratising these files over the main backpack
#

usage() {
  echo "$0"
  exit 1
}
[[ $# -lt 1 ]] && usage

