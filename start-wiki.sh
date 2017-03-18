#! /bin/bash -x

if [[ -n $SSH_CONNECTION ]] ; then
  gollum --page-file-dir wiki
else
  gollum --page-file-dir wiki -h localhost
fi

