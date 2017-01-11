#!/bin/bash
set -ex

if [[ "$1" == "install" ]]; then
	# $ useradd steam
	# $ su steam
	# and then run this script (or pick any other name than steam)

	if [[ ! -d "$HOME/Steam" ]]; then
		mkdir $HOME/Steam

		cd $HOME/Steam/
		curl -sqL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxvf -
	fi
	mkdir -p $HOME/arksrv
	if [[ ! -d "$HOME/arksrv/ShooterGame" ]]; then
		$HOME/Steam/steamcmd.sh +login anonymous +force_install_dir $HOME/arksrv +app_update 376030 +quit
	fi

	[[ -f "$QUDIR/private" ]] || echo "Create $QUDIR/private (see private.example) before starting server"
	exit
fi

QUDIR=$(dirname "$(readlink -f "$0")")
QUCFG="${QUDIR}/DefaultGameUserSettings.ini"
CFG="$HOME/arksrv/ShooterGame/Config/DefaultGameUserSettings.ini"
[[ ! -h "$CFG" ]] && rm "$CFG"
[[ -f "$CFG" ]] || ln -snf "$QUCFG" "$CFG"

OPTS=""
source "$QUDIR/private"
OPTS="${OPTS} -server -log -NoBattlEye"

cd $HOME/arksrv/ShooterGame/Binaries/Linux/
./ShooterGameServer $OPTS
