# -*- coding: utf-8, tab-width: 2 -*-


function npm_cmd_with_hooks () {
  local HOOK=
  local NPM_CMD=( "$REAL_NPM_BIN" )

  case "$RUNMODE" in
    --version ) ;;
    --versions ) ;;

    [a-z]* )
      if [[ "$RUNFLAGS" != *+'unhooked'+* ]]; then
        HOOK="$(guess_npm_cfgvar "npm_envaug_hook:cmd:$RUNMODE")"
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
  [[ "$RUNFLAGS" != *+countdown+* ]] \
    || npm_cmd_countdown "${NPM_CMD[@]}" || return $?
  "${NPM_CMD[@]}"
  return $?
}


return 0
