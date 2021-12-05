#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function envaug_cli_core () {
  local DBGLV="${DEBUGLEVEL:-0}"
  [ "$DBGLV" -ge 8 ] && echo "D: $FUNCNAME invocation:$(
    printf ' ‹%s›' "$0" "$@")" >&2

  local UI_OUT_FD=1
  tty --silent <&1 || UI_OUT_FD=2

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

  local RC_FILES=(
    "$HOME"/.config/nodejs/npm/rc*.{j,ce}son
    )

  local -A NPM_VARS=(
    [token]="$NPM_TOKEN"
    [email]="$NPM_EMAIL"
    )
  [ -n "$NPM_EMAIL" ] || NPM_VARS[email]="$(
    guess_npm_cfgvar email || echo 'nobody@example.net')"
  decide_token || return $?$(echo "E: Token selection failed" >&2)

  case "$RUNFLAGS" in
    *+'inject_npm_env_updates'+* )
      local -p | grep -Pe '^NPM_VARS=' || return $?
      inject_npm_env_updates
      return $?;;
    *+'dump_npm_env_updates'+* )
      local -p | grep -Pe '^NPM_VARS='
      return $?;;
  esac
  export_npm_vars || return $?
  # echo "D: $(env | grep -Pe '^NPM_' | tr '\n' ' ')." >&2

  npm_cmd_with_hooks "$@"
  return $?
}


function export_npm_vars () {
  # to reuse in external scripts: npm --func declare -f export_npm_vars
  local KEY=
  for KEY in "${!NPM_VARS[@]}"; do
    export "NPM_${KEY^^}=${NPM_VARS[$KEY]}"
  done
}


function inject_npm_env_updates () {
  local PFX='tmp__inject_npm_env_updates__'
  local FN='export_npm_vars'
  echo -n "function $PFX"
  declare -f "$FN"
  FN="$PFX$FN"
  echo "$FN || return $?"
  echo "unset $FN"
}











return 0
