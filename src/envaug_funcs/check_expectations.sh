# -*- coding: utf-8, tab-width: 2 -*-


function check_expectations () {
  local KNOWN_EXPECTATIONS=(
    expect_git_default_branch
    expect_git_repo_clean
    expect_git_tracks_all_tarball_files
    )
  local TRACE="D: npm-cli-wrapper-pmb envaug $FUNCNAME"
  local ITEM=
  for ITEM in "${KNOWN_EXPECTATIONS[@]}"; do
    [ "$DBGLV" -le 8 ] || echo "$TRACE ? $ITEM ?" >&2
    [[ "$RUNFLAGS" == *+"$ITEM"+* ]] || continue
    [ "$DBGLV" -le 2 ] || echo "$TRACE + $ITEM +" >&2
    "$ITEM" || return $?$(echo "E: failed to verify $ITEM" >&2)
  done
}


function expect_git_repo_clean () {
  git status --porcelain | grep -Pe . -m 10 | sed -rf <(echo '
    s~^~W:    ~
    1s~^~W: unclean files in git repo:\n~
    ') >&2
  [ "${PIPESTATUS[*]}" == '0 1 0' ] || return 4$(
    echo "E: git repo not clean" >&2)
}


function expect_git_default_branch () {
  local BRANCH="$(git branch | sed -nre 's~^\* (\S+)$~\1~p')"
  [ -n "$BRANCH" ] || return 3$(
    echo "E: failed to detect current branch name" >&2)
  local ACCEPT="$GIT_DEFAULT_BRANCH_NAMES"
  [ -n "$ACCEPT" ] || ACCEPT="$(guess_npm_cfgvar git_default_branch_names)"
  [ -n "$ACCEPT" ] || ACCEPT='
    main
    master
    release
    stable
    '
  ACCEPT="${ACCEPT//,/ }"
  ACCEPT="$(<<<"$ACCEPT" grep -oPe '\S+' \
    | LANG=C sort --version-sort --unique)"
  ACCEPT="${ACCEPT//$'\n'/ }"
  [[ " $ACCEPT " == *" $BRANCH "* ]] || return 4$(
    echo "E: current branch '$BRANCH' is not in the list of acceptable" \
      "default branch names ('$ACCEPT')." >&2)
}


function expect_git_tracks_all_tarball_files () {
  local FILES=()
  readarray -t FILES < <(npm-preview-tarball-fileslist-pmb \
    | sed -nre 's~^[0-9.]+[a-z]?B\s+~~p')
  [ -n "${FILES[0]}" ] || return 4$(echo "E: would-be empty tarball?" >&2)
  local ITEM= ERR_CNT=0
  for ITEM in "${FILES[@]}"; do
    expect_git_tracks_this_one_tarball_file "$ITEM" || (( ERR_CNT += 1 ))
  done
  [ "$ERR_CNT" == 0 ] || return 4$(echo "E: see warnings above" >&2)
}


function expect_git_tracks_this_one_tarball_file () {
  local FN="$1"
  [ -f "$FN" ] || [ -L "$FN" ] || return 3$(
    echo "W: tarball would include non-existing file: $FN" >&2)
  git whatchanged --format=oneline --max-count=1 -- "$FN" | grep -qPe '^:' \
    || return 4$(echo "W: cannot find any git history for: $FN" >&2)
}









return 0
