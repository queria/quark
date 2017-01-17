#!/bin/bash
set -e
if [[ "$1" == "--debug" || "$1" == "--verbose" ]]; then
    set -x
fi

ARKDIR="$(readlink -f "${ARKDIR:-$HOME/arksrv}")"
SAVEDIR="${ARKDIR}/ShooterGame/Saved/SavedArks"

BACKUPDIR="${BACKUPDIR:-${ARKDIR}/../ark-backup}"
BACKUPDIR="$(readlink -f "$BACKUPDIR")"

if [[ ! -d "$SAVEDIR" ]]; then
    echo "Not existing $SAVEDIR, override ARKDIR=\$HOME/arksrv to your path."
    exit 1
fi

if [[ "$QUIET" != "1" ]]; then
    echo "Current just cron every 10 minutes, doing something like"
    echo "  rsync -ab --backup-dir=previous $ARKDIR/ShooterGame/Saved/ $BACKUPDIR"
    echo "is used to create copy on different disk."
    echo "This script is for 'minimal' manual backup."
fi

[[ "$QUIET" = "1" ]] || echo "Going to store backup in $BACKUPDIR."
if [[ ! -d "$BACKUPDIR" ]]; then
    mkdir "$BACKUPDIR"
    echo "WARNING: $BACKUPDIR directory was just created"
fi

cd "$BACKUPDIR"
TSTAMP="$(date "+%y%m%d_%H%M%S")"
mkdir "$TSTAMP"
cd "$TSTAMP"

cp $SAVEDIR/*tribe* "$SAVEDIR/"*profile* ./
#"$SAVEDIR/"*NewLaunchBackup* "$SAVEDIR/"*AntiCorruptionBackup* ./
cp $SAVEDIR/TheIsland{.ark,_{NewLaunch*,AntiCorruption*}} ./
while read F; do
    xz -1 "$F";
done < <(find -type f|grep -v ".xz$")
[[ "$QUIET" = "1" ]] || echo "New backup created in $(readlink -f .)"
