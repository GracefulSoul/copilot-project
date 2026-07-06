#!/bin/bash
# Loop Agent sample script
INPUT=$(cat)
MAX_ITERATIONS=${1:-5}
LOG_DIR=".loop-agent-logs"
mkdir -p "$LOG_DIR"

ITERATION=0
STATUS="continue"

while [ "$ITERATION" -lt "$MAX_ITERATIONS" ] && [ "$STATUS" != "done" ]; do
  echo "Iteration $ITERATION" >> "$LOG_DIR/loop-agent.log"
  echo "input: $INPUT" >> "$LOG_DIR/loop-agent.log"

  # 실제 구현에서는 여기에 도구 실행 및 결과 평가 로직 추가
  if [ "$ITERATION" -ge 2 ]; then
    STATUS="done"
  else
    STATUS="continue"
  fi

  ITERATION=$((ITERATION + 1))
done

cat <<EOF
{
  "continue": true,
  "systemMessage": "Loop Agent completed $ITERATION iterations with status $STATUS",
  "hookSpecificOutput": {
    "iterations": $ITERATION,
    "status": "$STATUS"
  }
}
EOF
