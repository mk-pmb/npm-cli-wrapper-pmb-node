# -*- coding: utf-8, tab-width: 2 -*-


function npm_cmd_countdown () {
  local DURA_SEC=
  let DURA_SEC="$(guess_npm_cfgvar token-kiss-countdown-dura-sec \
    || echo 15)"
  [ "$DURA_SEC" == 0 ] && return 0
  [ "$DURA_SEC" -ge 1 ] || return 4$(echo "E: invalid countdown duration" >&2)
  echo -n 'D:'
  [ -z "${NPM_VARS[token]}" ] || echo -n ' (with npm token)'

  local PROG="$1"; shift
  PROG="${PROG/#*\/node_modules\/npm\/*\//…/npm/}"
  printf ' ‹%s›' "$PROG" "$@"

  echo -n '? '
  local CTD="$DURA_SEC"
  while [ "$CTD" -ge 1 ]; do
    echo -n "$CTD… "
    sleep 1s
    (( CTD -= 1 ))
  done
  echo '!'
}


return 0
