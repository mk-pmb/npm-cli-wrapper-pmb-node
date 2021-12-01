# -*- coding: utf-8, tab-width: 2 -*-


function guess_real_npm_bin () {
  chkexec guess_npm_cfgvar real_npm_bin && return 0
  find_npm_by_npx && return 0
  require_resolve 'npm/bin/npm-cli.js' && return 0
  echo /usr/bin/npm
}


function chkexec () {
  local GUESS="$( "$@" 2>/dev/null )"
  # echo "$FUNCNAME: <$GUESS>" >&2
  [ -x "$GUESS" ] || return 2
  echo "$GUESS"
}


function require_resolve () {
  nodejs "$SELFPATH"/../require_resolve.js -- -- "$@" 2>/dev/null; return $?
}


function find_npm_by_npx () {
  local NPX_CLI="$(require_resolve 'npm/bin/npx-cli.js')"
  local NPM_CLI=
  case "$NPX_CLI" in
    */npx-cli.js )
      NPM_CLI="${NPX_CLI%x*}m${NPX_CLI##*x}"
      [ -f "$NPM_CLI" ] || return 2
      echo "$NPM_CLI";;
    * ) return 2;;
  esac
}


return 0
