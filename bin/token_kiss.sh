#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function token_kiss () {
  # kiss = keep it simple, stupid. (or stable, if you prefer that.)
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local WRAPPER_BINDIR="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"
  local WRAPPER_BASEDIR="$(dirname -- "$WRAPPER_BINDIR")"
  local ITEM="$WRAPPER_BASEDIR/src/${FUNCNAME}_funcs"
  for ITEM in "$ITEM"/*.sh; do source -- "$ITEM" --lib || return $?; done
  token_kiss_cli_core "$@"
  return $?
}


token_kiss "$@"; exit $?
