# -*- coding: utf-8, tab-width: 2 -*-


function decide_token () {
  local TOK="${NPM_VARS[token]}"
  if [[ "$RUNFLAGS" == *+token+* ]]; then
    [ -n "$TOK" ] || TOK="$(guess_npm_cfgvar '//registry.npmjs.org/')"
    [ -n "$TOK" ] || return 4$(echo E: 'Found no npm token in config!' >&2)
  fi
  TOK="${TOK// /}"
  local DUMMY='npm_'SecretSecretSecretSecretSecret'Chksum'
  case "$TOK" in
    '' )
      [ "$DBGLV" -lt 4 ] || echo D: 'Using dummy npm token.' >&2
      TOK="$DUMMY";;
    npm_* ) ;;
    * )
      echo E: "Expected npm token to start with one of the usual prefixes." >&2
      return 4;;
  esac
  [ "${#TOK}" == "${#DUMMY}" ] || return 4$(echo E: >&2 \
    "Expected the npm token to be ${#DUMMY} characters long, not ${#TOK}.")
  [ -z "${TOK//[A-Za-z0-9'?*, _/-']/}" ] || return 4$(echo E: >&2 \
    'Found unexpected characters in npm token.')
  maybe_input_token_holes || return $?
  NPM_VARS[token]="$TOK"
}


return 0
