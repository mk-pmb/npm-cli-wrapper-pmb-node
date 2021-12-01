# -*- coding: utf-8, tab-width: 2 -*-


function npm_cmd_with_hooks () {
  local HOOK=
  local NPM_CMD=( "$REAL_NPM_BIN" )

  case "$RUNMODE" in
    --version ) ;;

    [a-z]* )
      if [[ "$RUNFLAGS" != *+'unhooked'+* ]]; then
        HOOK="$(guess_npm_cfgvar "npm_cmd_hook:$RUNMODE")"
        [ "${HOOK:0:2}" == '~/' ] && HOOK="$HOME${HOOK:1}"
        [ -n "$HOOK" ] && NPM_CMD=( "$HOOK" )
      fi
      ;;

    --func )
      RUNMODE="$1"
      shift
      "$RUNMODE" "$@"
      return $?;;

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
  maybe_countdown \
    "${NPM_CMD[0]/#*\/node_modules\/npm\/*\//…/npm/}" \
    "${NPM_CMD[@]:1}" \
    || return $?
  "${NPM_CMD[@]}"
  return $?
}


return 0
