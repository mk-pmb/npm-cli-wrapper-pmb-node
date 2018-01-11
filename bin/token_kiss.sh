#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function token_kiss () {
  # kiss = keep it simple, stupid. (or stable, if you prefer that.)

  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"

  local RC_FILES=(
    "$HOME"/.config/nodejs/npm/rc*.{j,ce}son
    )

  local RUNMODE="$1"; shift
  unabbreviate_runmode || return $?

  [ -n "$REAL_NPM_BIN" ] || local REAL_NPM_BIN="$(
    chkexec guess_npm_cfgvar real_npm_bin \
      || find_npm_by_npx \
      || require_resolve 'npm/bin/npm-cli.js' \
      || echo /usr/bin/npm)"
  [ -x "$REAL_NPM_BIN" ] || return 4$(
    echo "E: not executable: $REAL_NPM_BIN" >&2)
  [ -n "$NPM_TOKEN" ] || local NPM_TOKEN="$(
    guess_npm_cfgvar '//registry.npmjs.org/' \
      || printf '%08d-%04d-%04d-%04d-%012d\n')"
  [ -n "$NPM_EMAIL" ] || local NPM_EMAIL="$(
    guess_npm_cfgvar email || echo 'nobody@example.net')"
  export NPM_EMAIL NPM_TOKEN
  # echo "D: $(env | grep -Pe '^NPM_' | tr '\n' ' ')." >&2

  local HOOK=
  local NPM_CMD=( "$REAL_NPM_BIN" "$RUNMODE" )
  case "$RUNMODE" in
    [a-z]* )
      HOOK="$(guess_npm_cfgvar "npm_cmd_hook:$RUNMODE")"
      [ "${HOOK:0:2}" == '~/' ] && HOOK="$HOME${HOOK:1}"
      [ -n "$HOOK" ] && NPM_CMD=( "$HOOK" )
      ;;
    ::* )
      RUNMODE="${RUNMODE#::}"
      "$RUNMODE" "$@"
      return $?;;
    --real-npm-bin )
      if [ "$#" == 0 ]; then
        echo "$REAL_NPM_BIN"
        return 0
      else
        NPM_CMD=( "$REAL_NPM_BIN" "$1" )
        shift
      fi;;
    * )
      echo "E: runmode expected as first argument for $0 = $SELFFILE" >&2
      return 3;;
  esac

  exec "${NPM_CMD[@]}" "$@"
  return $?
}


function chkexec () {
  local GUESS="$( "$@" 2>/dev/null )"
  # echo "$FUNCNAME: <$GUESS>" >&2
  [ -x "$GUESS" ] || return 2
  echo "$GUESS"
}


function require_resolve () {
  nodejs "$SELFPATH"/../require_resolve.js "$@" 2>/dev/null; return $?
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


function guess_npm_cfgvar () {
  local CFG_KEY="$1"
  local KEY_RGX='[" ]'"${CFG_KEY//./\\.}"'":'
  # echo "D: looking up config key '$CFG_KEY', regexp '$KEY_RGX'" >&2
  grep -hPe "$KEY_RGX" -A 1 -- "${RC_FILES[@]}" 2>/dev/null | sed -nre '
    /:\s*$/N;s~^.*'"$KEY_RGX"'\s*"([^"\n]+)".*$~\1~p;q
    ' | grep . -m 1
  return $?
}


function unabbreviate_runmode () {
  local CMDS=(
    install
    login
    logout
    publish
    run
    test
    unpublish
    )
  local MAYBES=()
  local ITEM=
  for ITEM in "${CMDS[@]}"; do
    [[ "$ITEM" == "$RUNMODE"* ]] && MAYBES+=( "$ITEM" )
  done
  [ "${#MAYBES[@]}" == 0 ] && return 0
  [ "${#MAYBES[@]}" -le 1 ] || return 4$(
    echo "E: runmode '$RUNMODE' is ambiguous: could be ${MAYBES[*]}" >&2)
  RUNMODE="${MAYBES[0]}"
}











token_kiss "$@"; exit $?
