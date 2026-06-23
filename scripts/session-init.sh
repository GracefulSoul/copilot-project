#!/bin/bash
# Session Initialization Hook
# Sets up environment and loads project context

# Read hook input
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TIMESTAMP=$(echo "$INPUT" | jq -r '.timestamp // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

echo "=== Copilot Session Initialized ==="
echo "Session ID: $SESSION_ID"
echo "Time: $TIMESTAMP"
echo "Working Directory: $CWD"
echo ""

# Load project context
if [ -f ".env" ]; then
    echo "Loading .env file..."
    export $(cat .env | xargs)
fi

# Load project metadata
if [ -f "package.json" ]; then
    PROJECT_NAME=$(jq -r '.name' package.json)
    PROJECT_VERSION=$(jq -r '.version' package.json)
    echo "Project: $PROJECT_NAME (v$PROJECT_VERSION)"
fi

if [ -f "pyproject.toml" ]; then
    echo "Project: Python project detected"
fi

# Set up hooks context
CONTEXT_MESSAGE="Project initialized. Ready for development tasks."

# Return context injection
cat <<EOF
{
  "continue": true,
  "systemMessage": "$CONTEXT_MESSAGE",
  "hookSpecificOutput": {
    "context_added": true,
    "project_initialized": true
  }
}
EOF
