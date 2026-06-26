#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

tmp_home=$(mktemp -d)
export HOME="$tmp_home"

chmod +x task-tracker.sh

./task-tracker.sh add "Test task 1"
./task-tracker.sh add "Test task 2"

tasks_file="$HOME/.cache/task-tracker-cli/tasks.json"

if [ "$(jq '.tasks | length' "$tasks_file")" -ne 2 ]; then
  echo "ERR: expected 2 tasks after add" >&2
  exit 1
fi

./task-tracker.sh update 1 "Updated task 1"
if [ "$(jq -r '.tasks[] | select(.id == 1) | .description' "$tasks_file")" != "Updated task 1" ]; then
  echo "ERR: task 1 description did not update" >&2
  exit 1
fi

./task-tracker.sh mark-in-progress 2
if [ "$(jq -r '.tasks[] | select(.id == 2) | .status' "$tasks_file")" != "in-progress" ]; then
  echo "ERR: task 2 was not marked in-progress" >&2
  exit 1
fi

./task-tracker.sh mark-done 1
if [ "$(jq -r '.tasks[] | select(.id == 1) | .status' "if [ "$(jq -r '.tasks[] | select(.id == 1) | .status' "if [ "$(jq -r '.tasks[] | select(.id =task-tracker.sh delete 2
if [ "$(jq '.tasif [ "$(jq '.tasif [ "$(jq '.tasif [ "$(jq '.tasif ERR: expected 1 task after delete" >&2
  exit 1
fi