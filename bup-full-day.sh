#!/bin/bash

SRCDIR="$1"
DESTDIR="$2"

if [[ ! -d "$SRCDIR" || ! -d "$DESTDIR" ]]; then
    echo "SRCDIR=$SRCDIR"
    echo "DESTDIR=$DESTDIR"
    echo ""
    echo "One of folders is missing."
    exit 1
fi

TSTAMP="$(date "+%y-%m-%d")"
SRCPARENT="$(dirname "$(readlink -f "$SRCDIR")")"
SRCBASE="$(basename "$(readlink -f "$SRCDIR")")"
tar c -C "$SRCPARENT" "$SRCBASE" | xz -1 --stdout > "${DESTDIR}/${TSTAMP}.tar.xz"
