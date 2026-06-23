#!/bin/bash
# Audit Logging Hook
# Logs all tool usage for compliance and debugging

INPUT=$(cat)

# Extract event information
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.hook_event_data.tool_name // "N/A"')
TIMESTAMP=$(echo "$INPUT" | jq -r '.timestamp // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "N/A"')

# Create log directory if not exists
mkdir -p .audit-logs

# Log entry
LOG_ENTRY=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "session_id": "$SESSION_ID",
  "event": "$HOOK_EVENT",
  "tool": "$TOOL_NAME",
  "full_event": $INPUT
}
EOF
)

# Append to audit log
echo "$LOG_ENTRY" >> .audit-logs/session-$SESSION_ID.log

# For PostToolUse events, also log the result
if [ "$HOOK_EVENT" = "PostToolUse" ]; then
    TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.hook_event_data.tool_output // "N/A"')
    echo "Tool completed: $TOOL_NAME at $TIMESTAMP" >> .audit-logs/audit.log
fi

# Return success
echo '{"continue": true}'
