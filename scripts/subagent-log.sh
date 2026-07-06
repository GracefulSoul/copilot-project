#!/usr/bin/env bash
set -u

INPUT="$(cat)"
LOG_DIR="${SUBAGENT_LOG_DIR:-.subagent-logs}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
MAX_LOG_BYTES="${SUBAGENT_LOG_MAX_BYTES:-1048576}"

if ! mkdir -p "$LOG_DIR"; then
  echo '{"continue":true,"systemMessage":"subagent-log: log directory could not be created"}'
  exit 0
fi

rotate_if_needed() {
  file="$1"
  if [ -f "$file" ]; then
    size="$(wc -c < "$file" | tr -d ' ')"
    if [ "$size" -gt "$MAX_LOG_BYTES" ]; then
      mv "$file" "$file.$(date -u +%Y%m%dT%H%M%SZ)"
    fi
  fi
}

if command -v jq >/dev/null 2>&1; then
  EVENT="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // "unknown"' 2>/dev/null || printf 'unknown')"
  SESSION_ID="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || printf 'unknown')"
  AGENT_ID="$(printf '%s' "$INPUT" | jq -r '.agent_id // .hook_event_data.subagent_id // .subagent_id // "unknown"' 2>/dev/null || printf 'unknown')"
  AGENT_TYPE="$(printf '%s' "$INPUT" | jq -r '.agent_type // .hook_event_data.agent_type // .subagent_type // "unknown"' 2>/dev/null || printf 'unknown')"

  LOG_FILE="$LOG_DIR/${SESSION_ID}-${AGENT_ID}.jsonl"
  rotate_if_needed "$LOG_FILE"

  printf '%s' "$INPUT" | jq -c \
    --arg event "$EVENT" \
    --arg timestamp "$TIMESTAMP" \
    --arg sessionId "$SESSION_ID" \
    --arg agentId "$AGENT_ID" \
    --arg agentType "$AGENT_TYPE" \
    '{
      event: $event,
      timestamp: $timestamp,
      session_id: $sessionId,
      agent_id: $agentId,
      agent_type: $agentType,
      payload: .
    }' >> "$LOG_FILE" 2>/dev/null || {
      printf '{"event":"invalid-json","timestamp":"%s","session_id":"%s","agent_id":"%s","agent_type":"%s"}\n' \
        "$TIMESTAMP" "$SESSION_ID" "$AGENT_ID" "$AGENT_TYPE" >> "$LOG_FILE"
    }
else
  EVENT="unknown"
  SESSION_ID="unknown"
  AGENT_ID="unknown"
  LOG_FILE="$LOG_DIR/subagent-raw.log"
  rotate_if_needed "$LOG_FILE"
  {
    printf '{"timestamp":"%s","payload":' "$TIMESTAMP"
    printf '%s' "$INPUT"
    printf '}\n'
  } >> "$LOG_FILE"
fi

if command -v logger >/dev/null 2>&1; then
  logger -t claude-subagent "event=${EVENT:-unknown} session=${SESSION_ID:-unknown} agent=${AGENT_ID:-unknown}"
fi

echo '{"continue":true}'
