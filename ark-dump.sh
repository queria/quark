#!/bin/bash

THISDIR="$(dirname "$(readlink -f "$0")")"
VENVDIR="$THISDIR/.venv"

[[ -z "$VIRTUAL_ENV" ]] || deactivate
[[ -d "$VENVDIR" ]] || virtualenv "$VENVDIR"
source "$VENVDIR/bin/activate"
python -c 'import arkpy' &> /dev/null || pip install arkgamepy

"$THISDIR/ark-dump.py" "$@"
