#!/usr/bin/env bash
export _ARGCOMPLETE=1
export _ARGCOMPLETE_DFS="\t"
export _ARGCOMPLETE_IFS=" "
export _ARGCOMPLETE_SUPPRESS_SPACE=1
export _ARGCOMPLETE_SHELL=bash
export COMP_LINE="gcloud"
export COMP_POINT=0
export COMP_TYPE

COMMANDS="$(gcloud 8>&1 9>&2 1>/dev/null 2>&1)"

ROOT="$(git rev-parse --show-toplevel)"
FILE="$ROOT/completions/gcloud.fish"
mkdir -p "$ROOT/completions"

TPDIR="$(mktemp -d)"
PWD="$(pwd)"

function cleanup()
{
  cd "$PWD" || exit
  rm -rf "$TPDIR"
  exit
}
trap cleanup SIGINT

cd "$TPDIR" || exit

FISH_SUBCMD_FUNC=$(cat << EOS
function __fish_equals_subcommands
    set -l cmd (commandline -poc)
    if test "$cmd" = "gcloud $argv"
        return 0
    else
        return 1
    end
end
EOS
)
echo "$FISH_SUBCMD_FUNC" > "$FILE"

function __dig_commands()
{
  COMMANDS="$(gcloud 8>&1 9>&2 1>/dev/null 2>&1 | xargs)"

  if [ "$COMMANDS" != "" ] && [[ "$COMMANDS" != *ERROR:* ]]; then
    if [ "$COMP_LINE" == "gcloud " ]; then
      echo "complete -c gcloud -x -n __fish_use_subcommand -a \"$COMMANDS\"" >> "$FILE"
    else
      local TARGET="gcloud "
      local REPLACE=""
      local USING_COMMAND="${COMP_LINE/$TARGET/$REPLACE}"
      USING_COMMAND="$(echo "$USING_COMMAND" | xargs)"

      echo "complete -c gcloud -x -n \"__fish_equals_subcommands $USING_COMMAND\" -a \"$COMMANDS\"" >> "$FILE"
    fi

    for NEXT_CMD in $COMMANDS; do
      local BEFORE_COMP="$COMP_LINE"

      export COMP_LINE="${COMP_LINE}${NEXT_CMD} "
      export COMP_POINT="${#COMP_LINE}"

      __dig_commands

      export COMP_LINE="$BEFORE_COMP"
    done
  fi
}

export COMP_LINE="gcloud "
__dig_commands
