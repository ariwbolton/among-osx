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

if pgrep -x "steam_osx" > /dev/null
then
    echo "Steam is currently running; please quit Steam to continue"
    exit 1
fi

echo Running $RUN_NUMBER!

mkdir -p "$RUN_DIR"

cd "$RUN_DIR"

mkdir steam
mkdir install_folder

curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz" | tar zxf - -C steam/

echo "Installing SteamCMD"
echo

# Silence loading output
./steam/steamcmd.sh +quit >> /dev/null

echo "Downloading Game!"
echo

./steam/steamcmd.sh\
 +login ariwbolton\
 +@sSteamCmdForcePlatformType windows\
 +force_install_dir ../install_folder\
 +app_update 764030 validate\
 +quit