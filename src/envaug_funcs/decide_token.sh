# -*- coding: utf-8, tab-width: 2 -*-


function decide_token () {
  local TOK="${NPM_VARS[token]}"
  if [[ "$RUNFLAGS" == *+token+* ]]; then
    [ -n "$TOK" ] || TOK="$(guess_npm_cfgvar '//registry.npmjs.org/')"
  fi
  TOK="${TOK// /}"
  [ -n "$TOK" ] || TOK='npm_'SecretSecretSecretSecretSecret'Chksum'
  maybe_input_token_holes || return $?
  NPM_VARS[token]="$TOK"
}


return 0
