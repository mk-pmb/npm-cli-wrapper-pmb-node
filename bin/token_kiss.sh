#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function token_kiss () {
  # kiss = keep it simple, stupid. (or stable, if you prefer that.)

  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  local RC_FILES=(
    "$HOME"/.config/nodejs/npm/rc*.{j,ce}son
    )

  local RUNMODE="$1"; shift
  case "$RUNMODE" in
    --guess-npm-cfgvar )
      RUNMODE="${RUNMODE#--}"
      "${RUNMODE//-/_}" "$@"
      return $?;;
  esac

  [ -n "$ORIG_NPM_BIN" ] || local ORIG_NPM_BIN="$(
    chkexec "$FUNCNAME" --guess-npm-cfgvar orig_npm_bin \
      || require_resolve 'npm/bin/npm-cli.js' \
      || echo /usr/bin/npm)"
  [ -x "$ORIG_NPM_BIN" ] || return 4$(
    echo "E: not executable: $ORIG_NPM_BIN" >&2)
  [ -n "$NPM_TOKEN" ] || local NPM_TOKEN="$("$FUNCNAME" --guess-npm-cfgvar \
    '//registry.npmjs.org/' || printf '%08d-%04d-%04d-%04d-%012d\n')"
  [ -n "$NPM_EMAIL" ] || local NPM_EMAIL="$("$FUNCNAME" --guess-npm-cfgvar \
    email || echo 'nobody@example.net')"
  export NPM_EMAIL NPM_TOKEN
  # echo "D: $(env | grep -Pe '^NPM_' | tr '\n' ' ')." >&2
  exec "$ORIG_NPM_BIN" "$RUNMODE" "$@"
  return $?
}


function chkexec () {
  local GUESS="$( "$@" 2>/dev/null )"
  # echo "$FUNCNAME: <$GUESS>" >&2
  [ -x "$GUESS" ] || return 2
  echo "$GUESS"
}


function require_resolve () {
  nodejs "$SELFPATH"/../require_resolve.js "$@"; return $?
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










token_kiss "$@"; exit $?
