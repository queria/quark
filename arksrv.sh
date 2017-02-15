#!/bin/bash
set -ex

QUDIR=$(dirname "$(readlink -f "$0")")
QUCFG="${QUDIR}/GameUserSettings.ini"
QUPRIV="${QUDIR}/private"
QUMODS="${QUDIR}/Mods"
QUADMCFG="${QUDIR}/AllowedCheaterSteamIDs.txt"

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

CFG="$HOME/arksrv/ShooterGame/Saved/AllowedCheaterSteamIDs.txt"
if [[ -f "${QUADMCFG}" ]]; then
	[[ -d "$(dirname "$CFG")" ]] || mkdir -p "$(dirname "$CFG")"
	[[ -h "$CFG" ]] || rm -f "$CFG"
	[[ -f "$CFG" ]] || ln -snf "$QUADMCFG" "$CFG"
fi

MODS="$HOME/arksrv/ShooterGame/Content/Mods"
if [[ -d "$QUMODS" ]]; then
    cd "$QUMODS"
    [[ -d "$MODS" ]] || mkdir -p "$MODS"
    while read MODID; do
        MODPATH="${MODS}/${MODID}"

        [[ -h "${MODPATH}" ]] || rm -rf "${MODPATH}"
        [[ -f "${MODPATH}" ]] || ln -snf "${QUMODS}/${MODID}" "${MODPATH}"
    done < <(find . -maxdepth 1 -type d|grep -v '^.$'|xargs -n1 basename)
fi

OPTS=""
source "$QUPRIV"
OPTS="${OPTS} -server -log -nomansky -NoBattlEye"

cd $HOME/arksrv/ShooterGame/Binaries/Linux/
exec ./ShooterGameServer $OPTS
