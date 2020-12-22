#!/bin/bash

set -euf -o pipefail

CWD=$(pwd) # TODO: Pick tmp folder somewhere
RUN_NUMBER=$RANDOM
RUN_DIR=$CWD/runs/$RUN_NUMBER


if [ -d "$RUN_DIR" ]
then
  echo "$RUN_DIR" already exists >&2
  exit 1
fi

echo running $RUN_NUMBER

mkdir -p "$RUN_DIR"

cd "$RUN_DIR"

mkdir steam

curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz" | tar zxf - -C steam/