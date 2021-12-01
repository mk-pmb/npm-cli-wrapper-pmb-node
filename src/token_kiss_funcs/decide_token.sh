# -*- coding: utf-8, tab-width: 2 -*-


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


return 0
