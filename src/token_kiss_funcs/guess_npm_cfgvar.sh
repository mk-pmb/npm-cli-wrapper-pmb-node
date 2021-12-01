# -*- coding: utf-8, tab-width: 2 -*-


function guess_npm_cfgvar () {
  local CFG_KEY="$1"
  local KEY_RGX='[" ]'"${CFG_KEY//./\\.}"'":'
  # echo "D: looking up config key '$CFG_KEY', regexp '$KEY_RGX'" >&2
  grep -hPe "$KEY_RGX" -A 1 -- "${RC_FILES[@]}" 2>/dev/null | sed -nre '
    /:\s*$/N;s~^.*'"$KEY_RGX"'\s*"([^"\n]+)".*$~\1~p;q
    ' | grep . -m 1
  return $?
}


return 0
