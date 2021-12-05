#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function envaug () {
  # envaug = environment augmenter.
  # Also a wanna-be pun on french "en vogue".
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local WRAPPER_BINDIR="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"
  local WRAPPER_BASEDIR="$(dirname -- "$WRAPPER_BINDIR")"
  local ITEM="$WRAPPER_BASEDIR/src/${FUNCNAME}_funcs"
  for ITEM in "$ITEM"/*.sh; do source -- "$ITEM" --lib || return $?; done
  envaug_cli_core "$@"
  return $?
}


envaug "$@"; exit $?
