#!/bin/bash
if [[ "$1" == "--help" ]]; then
	echo ""
	echo "$0 [install|update|listmods]"
	echo ""
	echo "Install, update or start Ark server."
	echo ""
	echo "Before starting the server, update is always performed"
	echo "as also configs replaced with the ones recorded in this repo."
	echo ""
    echo "listmods   Print urls pointing to Steam for each mod in ActiveMods."
	exit 0
fi

set -ex

QUDIR=$(dirname "$(readlink -f "$0")")
QUCFG="${QUDIR}/GameUserSettings.ini"
QUCFGAME="${QUDIR}/Game.ini"
QUPRIV="${QUDIR}/private"
QUADMCFG="${QUDIR}/AllowedCheaterSteamIDs.txt"

if [[ "$1" == "listmods" ]]; then
    set +ex
    if [[ ! -f "$QUCFG" ]]; then
        echo "Missing config file $QUCFG" >&2
        exit 1
    fi
    IFS=, read -ra ARR <<<"$(sed -nr 's/^ActiveMods=//p' "$QUCFG")"
    if [[ "0" == "${#ARR[*]}" ]]; then
        echo "No ActiveMods found in config $QUCFK" >&2
        exit 1
    fi
    for F in ${ARR[*]}; do
        echo "https://steamcommunity.com/sharedfiles/filedetails/?id=$F";
    done
    exit 0
fi

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

	[[ -f "$QUPRIV" ]] || echo "Create $QUDIR/private (see private.example) before starting server"
	[[ -f "$QUADMCFG" ]] || echo "Possibly create also AllowedCheaterSteamIDs.txt (admins steamid64 per line)"
	exit
fi

$HOME/Steam/steamcmd.sh +login anonymous +force_install_dir $HOME/arksrv +app_update 376030 +quit
if [[ "$1" == "update" ]]; then
    exit
fi


# for GameUserSettings, always overwrite, no symlink
# as game server is going to be writing into it on the fly
CFG="$HOME/arksrv/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini"
[[ -d "$(dirname "$CFG")" ]] || mkdir -p "$(dirname "$CFG")"
[[ -f "$QUCFG" ]] && cp "$QUCFG" "$CFG"

CFG="$HOME/arksrv/ShooterGame/Saved/Config/LinuxServer/Game.ini"
[[ -d "$(dirname "$CFG")" ]] || mkdir -p "$(dirname "$CFG")"
[[ -f "$QUCFGAME" ]] && cp "$QUCFGAME" "$CFG"
[[ -f "${QUCFGAME}.append_quantity" ]] && cat "${QUCFGAME}.append_quantity" >> "$CFG"

CFG="$HOME/arksrv/ShooterGame/Saved/AllowedCheaterSteamIDs.txt"
[[ -d "$(dirname "$CFG")" ]] || mkdir -p "$(dirname "$CFG")"
if [[ -f "${QUADMCFG}" ]]; then
	[[ -h "$CFG" ]] || rm -f "$CFG"
	[[ -f "$CFG" ]] || ln -snf "$QUADMCFG" "$CFG"
fi

OPTS=""
source "$QUPRIV"
OPTS="${OPTS} -server -log -nomansky -NoBattlEye"

cd $HOME/arksrv/ShooterGame/Binaries/Linux/
ulimit -c 0
exec ./ShooterGameServer $OPTS
