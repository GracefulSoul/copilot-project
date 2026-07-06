#!/bin/bash
# Subagent lifecycle logging for Claude Code
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
SUBAGENT_ID=$(echo "$INPUT" | jq -r '.hook_event_data.subagent_id // "unknown"')

mkdir -p .subagent-logs
LOG_FILE=".subagent-logs/$SESSION_ID-$SUBAGENT_ID.log"

echo "{\"event\": \"$EVENT\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"payload\": $INPUT}" >> "$LOG_FILE"

echo '{"continue": true}'
