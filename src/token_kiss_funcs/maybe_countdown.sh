# -*- coding: utf-8, tab-width: 2 -*-


function maybe_countdown () {
  [[ "$RUNFLAGS" == *+countdown+* ]] || return 0
  local DURA_SEC="$1"; shift
  echo -n 'D:'
  [ -z "$NPM_TOKEN" ] || echo -n ' (with npm token)'
  printf ' ‹%s›' "$@"
  echo -n '? '
  local CTD=
  for CTD in {10..1}; do
    echo -n "$CTD… "
    sleep 1s
  done
  echo '!'
}


return 0
