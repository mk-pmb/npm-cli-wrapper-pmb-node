# -*- coding: utf-8, tab-width: 2 -*-


function guess_npm_cfgvar () {
  local CFG_KEY="$1"
  local KEY_RGX='[" ]'"${CFG_KEY//./\\.}"'":'
  # echo "D: looking up config key '$CFG_KEY', regexp '$KEY_RGX'" >&2
  [ -n "${RC_FILES[0]}" ] || return 4$(
    echo "W: $FUNCNAME: no config files found!" >&2)
  </dev/null grep -hPe "$KEY_RGX" -A 1 -- "${RC_FILES[@]}" 2>/dev/null |
    LANG=C sed -nre '/:\s*$/N;s~^.*'"$KEY_RGX"'\s*"([^"\n]+)".*$~\1~p;q' |
    grep . -m 1
  return $?
}


function cfg_read_runmode_hook () {
  local PHASE="$1"
  [[ "$RUNFLAGS" == *+'unhooked'+* ]] \
    || guess_npm_cfgvar "npm_envaug_hook:$PHASE:$RUNMODE"
}


return 0
