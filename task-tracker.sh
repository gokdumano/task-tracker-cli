readonly TASKS_FILE_PATH="${HOME}/.cache/task-tracker-cli/tasks.json"

function ensure_json_file {
    [ -f "$TASKS_FILE_PATH" ] && >&1 echo "INFO: File exists, skipped." && return 0
    
    mkdir -p "$(dirname "$TASKS_FILE_PATH")"    \
    && >"$TASKS_FILE_PATH" echo '{"tasks": []}' \
    && { >&1 echo "OK: Created $TASKS_FILE_PATH"           ; return 0; } \
    || { >&2 echo "ERR: Failed to create $TASKS_FILE_PATH" ; return 1; }
}

ensure_json_file || exit 1

function add {
  if [ "$#" -ne 1 ]; then
    >&2 echo 'Usage: task-tracker.sh add <task>'
    return 1
  fi

  local task="$1"
  local now=$(date -Iseconds)
  local buffer=$(mktemp)

  jq --arg desc "$task" --arg createdAt "$now" '.tasks += [{
      id: ((.tasks | map(.id) | max // 0) + 1), description: $desc,
      status: "todo", createdAt: $createdAt, updatedAt: null
  }]' "$TASKS_FILE_PATH" > "$buffer" && mv "$buffer" "$TASKS_FILE_PATH" \
  && { >&1 echo "Task added successfully"; return 0; } \
  || { >&2 echo "Failed to add task"     ; return 1; }
}

function update {
  if [ "$#" -ne 2 ]; then
    >&2 echo 'Usage: task-tracker.sh update <task-id> <new-task>'
    return 1
  fi
  
  local task_id="$1"
  local new_task="$2"
  local buffer=$(mktemp)

  jq --arg id "$task_id" --arg desc "$new_task" '
    (.tasks[] | select(.id == ($id | tonumber))).description = $desc
  ' "$TASKS_FILE_PATH" > "$buffer" && mv "$buffer" "$TASKS_FILE_PATH" \
  && { >&1 echo "Task updated successfully"; return 0; } \
  || { >&2 echo "Failed to update task"    ; return 1; }
}

function delete {
  if [ "$#" -ne 1 ]; then
    >&2 echo 'Usage: task-tracker.sh delete <task-id>'
    return 1
  fi
  
  local task_id="$1"
  local buffer=$(mktemp)

  jq --arg id "$task_id" '
    .tasks |= map(select(.id != ($id | tonumber)))
  ' "$TASKS_FILE_PATH" > "$buffer" && mv "$buffer" "$TASKS_FILE_PATH" \
  && { >&1 echo "Task deleted successfully"; return 0; } \
  || { >&2 echo "Failed to delete task"    ; return 1; }
}

function mark-in-progress {
  if [ "$#" -ne 1 ]; then
    >&2 echo 'Usage: task-tracker.sh mark-in-progress <task-id>'
    return 1
  fi
  
  local task_id="$1"
  local buffer=$(mktemp)

  jq --arg id "$task_id" '
    (.tasks[] | select(.id == ($id | tonumber))).status = "in-progress"
  ' "$TASKS_FILE_PATH" > "$buffer" && mv "$buffer" "$TASKS_FILE_PATH" \
  && { >&1 echo "Task marked as in-progress"        ; return 0; } \
  || { >&2 echo "Failed to mark task as in-progress"; return 1; }
}

function mark-done {
  if [ "$#" -ne 1 ]; then
    >&2 echo 'Usage: task-tracker.sh mark-done <task-id>'
    return 1
  fi
  
  local task_id="$1"
  local buffer=$(mktemp)

  jq --arg id "$task_id" '
    (.tasks[] | select(.id == ($id | tonumber))).status = "done"
  ' "$TASKS_FILE_PATH" > "$buffer" && mv "$buffer" "$TASKS_FILE_PATH" \
  && { >&1 echo "Task marked as done"        ; return 0; } \
  || { >&2 echo "Failed to mark task as done"; return 1; }
}

function list {
  if [ "$#" -gt 1 ]; then
    >&2 echo 'Usage: task-tracker.sh list [{ done | todo | in-progress }]'
    return 1
  fi
  
  local label="${1:-all}"
  case "$label" in
    'all')  
        jq '.tasks' "$TASKS_FILE_PATH"
    ;;
    'done' | 'todo' | 'in-progress')
        jq --arg status "$label" '.tasks | map(select(.status == $status))' "$TASKS_FILE_PATH"
    ;;
    * ) 
      >&2 echo "Unknown label: ${label}"
      >&2 echo "Valid labels are: '<none>', 'done', 'todo', and 'in-progress'"
      return 1
    ;;
  esac
  >&1 echo "list(Label: '$label')";  
}

function main {
  local action="$1"
  shift 1
  
  case "$action" in
    'add'              ) add "$@"              ;;
    'update'           ) update "$@"           ;;
    'delete'           ) delete "$@"           ;;
    'mark-in-progress' ) mark-in-progress "$@" ;;
    'mark-done'        ) mark-done "$@"        ;;
    'list'             ) list "$@"             ;; 
    * ) 
      >&2 echo "Unknown action: ${action}"
      >&2 echo "Valid actions are: 'add', 'update', 'delete', 'mark-done', 'mark-in-progress', and 'list'"
      return 1
    ;;
  esac
}

main "$@"