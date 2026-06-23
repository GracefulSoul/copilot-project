#!/bin/bash
# Security Check Hook
# Blocks dangerous operations before execution

# Read hook input from stdin
INPUT=$(cat)

# Extract tool information
TOOL_NAME=$(echo "$INPUT" | jq -r '.hook_event_data.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq '.hook_event_data.tool_input // empty')

# Dangerous patterns to block
DANGEROUS_PATTERNS=(
    "rm -rf"
    "DROP TABLE"
    "DELETE FROM"
    "TRUNCATE"
    "> /dev/null"
    "chmod 777"
)

check_dangerous_patterns() {
    local input_str="$1"
    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if [[ "$input_str" == *"$pattern"* ]]; then
            return 0  # Found dangerous pattern
        fi
    done
    return 1  # Safe
}

# Check if command is dangerous
if [ "$TOOL_NAME" = "run_in_terminal" ]; then
    COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
    if check_dangerous_patterns "$COMMAND"; then
        # Return blocking response
        cat <<EOF
{
  "continue": false,
  "stopReason": "Dangerous command blocked by security hook: $COMMAND",
  "systemMessage": "This command matches a dangerous pattern and requires manual approval"
}
EOF
        exit 2  # Exit code 2 = blocking error
    fi
fi

# Safe operation - allow to continue
echo '{"continue": true}'
exit 0
