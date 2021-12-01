#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function token_kiss_cli_core () {
  local DBGLV="${DEBUGLEVEL:-0}"
  [ "$DBGLV" -ge 8 ] && echo "D: $FUNCNAME invocation:$(
    printf ' ‹%s›' "$0" "$@")" >&2

  local RC_FILES=(
    "$HOME"/.config/nodejs/npm/rc*.{j,ce}son
    )

  local ARG="$1"; shift
  if [ "$ARG" == --bash-source-plugins ]; then
    while true; do
      ARG="$1"; shift
      case "$ARG" in
        *.* | */* ) source -- "$ARG" --lib || return $?;;
        * ) break;;
      esac
    done
  fi

  local RUNMODE="$ARG"
  unabbreviate_runmode || return $?
  local RUNFLAGS="${RUNMODE}+"
  RUNMODE="${RUNFLAGS%%\+*}"
  RUNFLAGS="${RUNFLAGS#*\+}"
  RUNFLAGS="+${RUNFLAGS//\+/++}+"

  [ -n "$REAL_NPM_BIN" ] || local REAL_NPM_BIN="$(guess_real_npm_bin)"
  [ -x "$REAL_NPM_BIN" ] || return 4$(
    echo "E: not executable: $REAL_NPM_BIN" >&2)

  local NPM_TOKEN=
  decide_token "$NPM_TOKEN" || return $?$(echo "E: Token selection failed" >&2)
  # local -p; return 4
  [ -n "$NPM_EMAIL" ] || local NPM_EMAIL="$(
    guess_npm_cfgvar email || echo 'nobody@example.net')"
  export NPM_EMAIL NPM_TOKEN
  # echo "D: $(env | grep -Pe '^NPM_' | tr '\n' ' ')." >&2

  npm_cmd_with_hooks "$@"
  return $?
}











return 0
