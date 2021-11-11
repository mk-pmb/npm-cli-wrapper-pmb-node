#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function tmpdocker () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  local SELFPATH="$(dirname -- "$SELFFILE")"
  local SELFNAME="$(basename -- "$SELFFILE" .sh)"
  local INVOKED_AS="$(basename -- "$0" .sh)"
  # cd -- "$SELFPATH" || return $?

  local REPO_TOP="$(git rev-parse --show-toplevel)"
  [ -d "$REPO_TOP/.git" ] || return $?$(
    echo "E: Failed to detect REPO_TOP" >&2)
  local REPO_SUB="$(git rev-parse --show-prefix)"

  local DK_CMD=(
    docker
    run
    --rm
    --tty
    --interactive
    --volume "$REPO_TOP:/repo"
    node:16
    /bin/bash
    -c 'cd "/repo/$1" && shift && exec "$@"'
    --
    "$REPO_SUB"
    npm
    "$@"
    )
  echo "D: cmd:$(printf -- ' ‹%s›' "${DK_CMD[@]}")" >&2
  exec "${DK_CMD[@]}" || return $?
}










tmpdocker "$@"; exit $?
