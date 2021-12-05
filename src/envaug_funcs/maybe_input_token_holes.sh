# -*- coding: utf-8, tab-width: 2 -*-


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
    "Please type the $N_HOLES missing characters, then press [Enter]: " \
    >&$UI_OUT_FD
  local INPUT=
  read -r INPUT || return 3$(echo "E: Failed to read token holes." >&2)
  while [[ "$TOK" == *'?'* ]]; do
    TOK="${TOK/\?/${INPUT:0:1}}"
    INPUT="${INPUT:1}"
  done
}


return 0
