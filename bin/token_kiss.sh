#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function token_kiss () {
  # kiss = keep it simple, stupid. (or stable, if you prefer that.)

  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"
  local DBGLV="${DEBUGLEVEL:-0}"
  [ "$DBGLV" -ge 8 ] && echo "D: $FUNCNAME invocation:$(
    printf ' ‹%s›' "$0" "$@")" >&2

  local RC_FILES=(
    "$HOME"/.config/nodejs/npm/rc*.{j,ce}son
    )

  local RUNMODE="$1"; shift
  unabbreviate_runmode || return $?
  local RUNFLAGS="${RUNMODE}+"
  RUNMODE="${RUNFLAGS%%\+*}"
  RUNFLAGS="${RUNFLAGS#*\+}"
  RUNFLAGS="+${RUNFLAGS//\+/++}+"

  [ -n "$REAL_NPM_BIN" ] || local REAL_NPM_BIN="$(
    chkexec guess_npm_cfgvar real_npm_bin \
      || find_npm_by_npx \
      || require_resolve 'npm/bin/npm-cli.js' \
      || echo /usr/bin/npm)"
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


function npm_cmd_with_hooks () {
  local HOOK=
  local NPM_CMD=( "$REAL_NPM_BIN" )
  case "$RUNMODE" in
    --version ) ;;
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
        RUNMODE="$1"
        shift
      fi;;
    * )
      echo "E: expected runmode as first argument for $0 = $SELFFILE" \
        "but got '$RUNMODE'" >&2
      return 3;;
  esac

  NPM_CMD+=(
    "$RUNMODE"
    "${NPM_ARGS[@]}"
    "$@"
    )
  "${NPM_CMD[@]}"
  return $?
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
  local KNOWN_TASKS=(
    install
    login
    logout+token
    publish+token
    run
    test
    unpublish+token
    whoami
    )
  local MAYBES=()
  local ITEM=
  for ITEM in "${KNOWN_TASKS[@]}"; do
    [[ "${ITEM%%\+*}" == "$RUNMODE"* ]] && MAYBES+=( "$ITEM" )
  done
  [ "${#MAYBES[@]}" == 0 ] && return 0
  [ "${#MAYBES[@]}" -le 1 ] || return 4$(
    echo "E: runmode '$RUNMODE' is ambiguous: could be ${MAYBES[*]}" >&2)
  RUNMODE="${MAYBES[0]}"
}


function decide_token () {
  local ORIG_ENV_TOKEN="$1"
  local TOK="$ORIG_ENV_TOKEN"
  if [[ "$RUNFLAGS" == *+token+* ]]; then
    [ -n "$TOK" ] || TOK="$(guess_npm_cfgvar '//registry.npmjs.org/')"
  fi
  TOK="${TOK// /}"
  [ -n "$TOK" ] || TOK='npm_'SecretSecretSecretSecretSecret'Chksum'
  maybe_input_token_holes || return $?
  NPM_TOKEN="$TOK"
}


function maybe_input_token_holes () {
  [ -n "$TOK" ] || return 0
  TOK="${TOK//,/?}"
  [[ "$TOK" == *'?'* ]] || return 0   # no holes

  # Last 6 chars are checksum:
  # https://github.blog/2021-09-23-announcing-npms-new-access-token-format/
  # Details: https://github.blog/2021-04-05-behind-githubs-new-authentication-token-formats/
  local SECRET="${TOK%??????}"
  local CKSUM="${TOK:${#SECRET}}"
  # echo "D: token secret: '$SECRET' checksum: '$CKSUM'" >&2

  local N_HOLES="${TOK//[^?]/}"
  N_HOLES="${#N_HOLES}"

  [[ "$SECRET" == *'?'* ]] || echo "W: Your token is lacking holes in the" \
    "random secret part!" >&2
  [[ "$CKSUM" == *'?'* ]] || echo "W: Your token is lacking holes in the" \
    "checksum part!" >&2

  echo -n "Your saved token for npm action $RUNMODE is holey." \
    "Please type the $N_HOLES missing characters, then press [Enter]: "
  local INPUT=
  read -r INPUT || return 3$(echo "E: Failed to read token holes." >&2)
  while [[ "$TOK" == *'?'* ]]; do
    TOK="${TOK/\?/${INPUT:0:1}}"
    INPUT="${INPUT:1}"
  done
}











token_kiss "$@"; exit $?
