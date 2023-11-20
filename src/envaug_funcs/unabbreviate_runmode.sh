# -*- coding: utf-8, tab-width: 2 -*-


function unabbreviate_runmode () {
  local KNOWN_TASKS=(
    deprecate+token
    install
    login
    logout+token
    owner+token
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


return 0
