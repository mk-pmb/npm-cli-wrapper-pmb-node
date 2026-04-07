# -*- coding: utf-8, tab-width: 2 -*-


function npm_cmd_download () {
  local VAL="$(npm help download 2>&1 | head --lines=1)"
  case "${VAL,,}" in
    'no results for '* ) RUNMODE='exit';;
    * ) return 0;;  # Don't intercept, use real npm.
  esac
  local TRACE="$NPMWR_PROG: download:"
  case "$#:$1" in
    1:[a-z]* | 1:@[a-z]* ) ;;
    * )
      echo E: $TRACE 'Expected exactly one package name.' >&2
      return 4;;
  esac
  set -- npm view "$1" dist.tarball
  echo D: $TRACE "querying: $*"
  VAL="$("$@")"
  case "$VAL" in
    '' ) echo E: $TRACE 'tarball URL lookup failed' >&2; return 4;;
    https://* ) ;;
    * )
      echo E: $TRACE 'Expected tarball URL to start with https:// but got' \
        "<$VAL>" >&2
      return 4;;
  esac
  wget --continue -- "$VAL"
}


return 0
