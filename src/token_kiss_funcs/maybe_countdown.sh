# -*- coding: utf-8, tab-width: 2 -*-


function maybe_countdown () {
  [[ "$RUNFLAGS" == *+countdown+* ]] || return 0
  local DURA_SEC=
  let DURA_SEC="$(guess_npm_cfgvar token-kiss-countdown-dura-sec \
    || echo 15)"
  [ "$DURA_SEC" == 0 ] && return 0
  [ "$DURA_SEC" -ge 1 ] || return 4$(echo "E: invalid countdown duration" >&2)
  echo -n 'D:'
  [ -z "$NPM_TOKEN" ] || echo -n ' (with npm token)'
  printf ' ‹%s›' "$@"
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
