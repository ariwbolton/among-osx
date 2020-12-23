#!/bin/bash

set -euf -o pipefail

USE_SAVED_ARCHIVES=0
POSITIONAL=()

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --use-saved-archives)
    USE_SAVED_ARCHIVES=1
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ ${#POSITIONAL[@]} -gt 0 ]; then
    echo "Found unknown params: " "${POSITIONAL[@]}"
    exit 1
fi

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

mkdir master_wrapper
mkdir engine
mkdir steam
mkdir install_folder

###############
# Set up Wine #
###############

if [ $USE_SAVED_ARCHIVES -eq 0 ]
then
  echo "Downloading Engine..."
  curl -sqL "https://github.com/Gcenx/WineskinServer/releases/download/V1.8.4.2/WS11WineCX64Bit19.0.2.tar.7z"\
   -o "$RUN_DIR/engine/WS11WineCX64Bit19.0.2.tar.7z"
else
  echo "Copying saved Engine..."
  cp "$CWD/archives/WS11WineCX64Bit19.0.2.tar.7z" "$RUN_DIR/engine/WS11WineCX64Bit19.0.2.tar.7z"
fi

7za x "$RUN_DIR/engine/WS11WineCX64Bit19.0.2.tar.7z" "-o$RUN_DIR/engine" 1> /dev/null

tar zxf "$RUN_DIR/engine/WS11WineCX64Bit19.0.2.tar" -C "$RUN_DIR/engine"

rm "$RUN_DIR/engine/WS11WineCX64Bit19.0.2.tar.7z"
rm "$RUN_DIR/engine/WS11WineCX64Bit19.0.2.tar"

###################
# Set up SteamCMD #
###################

if [ $USE_SAVED_ARCHIVES -eq 0 ]
then
  echo "Downloading SteamCMD..."
  curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz" | tar zxf - -C steam/
else
  echo "Copying saved SteamCMD..."
  tar zxf "$CWD/archives/steamcmd_osx.tar.gz" -C steam/
fi

echo "Installing SteamCMD..."

# Silence extremely verbose and confusing output
./steam/steamcmd.sh +quit >> /dev/null

###################
# Download Game!! #
###################

echo "Downloading Game..."
echo
echo

./steam/steamcmd.sh\
 +login ariwbolton\
 +@sSteamCmdForcePlatformType windows\
 +force_install_dir ../install_folder\
 +app_update 764030 validate\
 +quit

echo "Success!!"