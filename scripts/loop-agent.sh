#!/usr/bin/env bash
set -u

INPUT="$(cat)"
MAX_ITERATIONS="${LOOP_AGENT_MAX_ITERATIONS:-${1:-5}}"
TARGET_COMMAND="${LOOP_AGENT_COMMAND:-}"
DONE_PATTERN="${LOOP_AGENT_DONE_PATTERN:-}"
LOG_DIR="${LOOP_AGENT_LOG_DIR:-.loop-agent-logs}"
LOG_FILE="$LOG_DIR/loop-agent.jsonl"

case "$MAX_ITERATIONS" in
  ''|*[!0-9]*)
    MAX_ITERATIONS=5
    ;;
esac

if [ "$MAX_ITERATIONS" -lt 1 ]; then
  MAX_ITERATIONS=1
fi

if ! mkdir -p "$LOG_DIR"; then
  echo '{"continue":true,"systemMessage":"Loop Agent could not create log directory"}'
  exit 0
fi

ITERATION=0
STATUS="continue"
LAST_EXIT_CODE=0
OBSERVATION="no command configured"

while [ "$ITERATION" -lt "$MAX_ITERATIONS" ] && [ "$STATUS" = "continue" ]; do
  PLAN="plan iteration $ITERATION based on previous observation"

  if [ -n "$TARGET_COMMAND" ]; then
    OUTPUT_FILE="$LOG_DIR/iteration-$ITERATION.out"
    sh -c "$TARGET_COMMAND" > "$OUTPUT_FILE" 2>&1
    LAST_EXIT_CODE=$?
    OBSERVATION="$(tail -n 20 "$OUTPUT_FILE" | tr '\n' ' ')"
  else
    LAST_EXIT_CODE=0
    OBSERVATION="dry run iteration $ITERATION"
  fi

  if [ "$LAST_EXIT_CODE" -eq 0 ]; then
    if [ -z "$DONE_PATTERN" ] || printf '%s' "$OBSERVATION" | grep -Eq "$DONE_PATTERN"; then
      STATUS="done"
    fi
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -n -c \
      --arg phase "loop" \
      --arg plan "$PLAN" \
      --arg observation "$OBSERVATION" \
      --arg status "$STATUS" \
      --argjson iteration "$ITERATION" \
      --argjson exitCode "$LAST_EXIT_CODE" \
      '{
        phase: $phase,
        iteration: $iteration,
        plan: $plan,
        tool_execute: { exit_code: $exitCode },
        observe: $observation,
        evaluate: $status
      }' >> "$LOG_FILE"
  else
    printf 'iteration=%s exit_code=%s status=%s observation=%s\n' \
      "$ITERATION" "$LAST_EXIT_CODE" "$STATUS" "$OBSERVATION" >> "$LOG_FILE"
  fi

  if [ "$STATUS" != "done" ]; then
    STATUS="continue"
  fi

  ITERATION=$((ITERATION + 1))
done

if [ "$STATUS" != "done" ]; then
  STATUS="max_iterations"
fi

if command -v jq >/dev/null 2>&1; then
  jq -n \
    --arg status "$STATUS" \
    --argjson iterations "$ITERATION" \
    --argjson lastExitCode "$LAST_EXIT_CODE" \
    '{
      continue: true,
      systemMessage: ("Loop Agent completed " + ($iterations | tostring) + " iterations with status " + $status),
      hookSpecificOutput: {
        iterations: $iterations,
        status: $status,
        last_exit_code: $lastExitCode
      }
    }'
else
  printf '{"continue":true,"systemMessage":"Loop Agent completed %s iterations with status %s","hookSpecificOutput":{"iterations":%s,"status":"%s","last_exit_code":%s}}\n' \
    "$ITERATION" "$STATUS" "$ITERATION" "$STATUS" "$LAST_EXIT_CODE"
fi
