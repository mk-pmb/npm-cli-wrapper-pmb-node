#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function token_kiss_cli_core () {
  local DBGLV="${DEBUGLEVEL:-0}"
  [ "$DBGLV" -ge 8 ] && echo "D: $FUNCNAME invocation:$(
    printf ' ‹%s›' "$0" "$@")" >&2

  local RC_FILES=(
    "$HOME"/.config/nodejs/npm/rc*.{j,ce}son
    )

  if [ "$1" == --bash-source-plugins ]; then
    shift
    while [[ "$1" == *[./]* ]]; do
      source -- "$1" --lib || return $?
      shift
    done
  fi

  [ -n "$REAL_NPM_BIN" ] || local REAL_NPM_BIN="$(guess_real_npm_bin)"
  [ -x "$REAL_NPM_BIN" ] || return 4$(
    echo "E: not executable: $REAL_NPM_BIN" >&2)

  case "$#:$1" in
    1:--real-npm-bin )
      echo "$REAL_NPM_BIN"
      return 0;;
  esac

  local RUNFLAGS=
  while [[ "$1" == +[a-z]* ]]; do RUNFLAGS+="$1"; shift; done
  local RUNMODE="$1"; shift
  unabbreviate_runmode || return $?
  RUNFLAGS="${RUNMODE}${RUNFLAGS}+"
  RUNMODE="${RUNFLAGS%%\+*}"
  RUNFLAGS="${RUNFLAGS#*\+}"
  RUNFLAGS="+${RUNFLAGS//\+/++}+"

  local ORIG_ENV_TOKEN="$NPM_TOKEN"
  local NPM_TOKEN=
  decide_token || return $?$(echo "E: Token selection failed" >&2)
  # local -p; return 4
  [ -n "$NPM_EMAIL" ] || local NPM_EMAIL="$(
    guess_npm_cfgvar email || echo 'nobody@example.net')"
  export NPM_EMAIL NPM_TOKEN
  # echo "D: $(env | grep -Pe '^NPM_' | tr '\n' ' ')." >&2

  npm_cmd_with_hooks "$@"
  return $?
}











return 0
