#!/usr/bin/env bash
set -u

LABEL="${1:-hook}"
INPUT="$(cat)"
LOG_DIR="${HOOK_PASS_LOG_DIR:-.agent-hook-logs}"
LOG_FILE="$LOG_DIR/development-hooks.jsonl"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if ! mkdir -p "$LOG_DIR"; then
  echo '{"continue":true,"systemMessage":"hook-pass: log directory could not be created"}'
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  printf '%s' "$INPUT" | jq -c \
    --arg label "$LABEL" \
    --arg timestamp "$TIMESTAMP" \
    '{
      label: $label,
      timestamp: $timestamp,
      event: (.hook_event_name // "unknown"),
      session_id: (.session_id // "unknown"),
      payload: .
    }' >> "$LOG_FILE" 2>/dev/null || {
      printf '{"label":"%s","timestamp":"%s","event":"invalid-json"}\n' "$LABEL" "$TIMESTAMP" >> "$LOG_FILE"
    }
else
  {
    printf '{"label":"%s","timestamp":"%s","payload":' "$LABEL" "$TIMESTAMP"
    printf '%s' "$INPUT"
    printf '}\n'
  } >> "$LOG_FILE"
fi

echo '{"continue":true}'
