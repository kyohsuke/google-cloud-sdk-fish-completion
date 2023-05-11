#!/usr/bin/env bash
export CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1

ROOT="$(git rev-parse --show-toplevel)"
FILE="$ROOT/completions/bq.fish"
mkdir -p "$ROOT/completions"

COMMANDS="$(bq help | grep '^[^ ][^ ]*  ' | sed 's/ .*//' | tr '\n' ' ' | xargs)"
echo "complete -c bq -x -n __fish_use_subcommand -a \"$COMMANDS\"" > "$FILE"
