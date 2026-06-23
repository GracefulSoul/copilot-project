#!/bin/bash
# Code Quality Validation Script
# Detects project type and runs appropriate linters

PROJECT_PATH="${1:-.}"
REPORT_FILE="code-quality-report.json"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Starting Code Quality Analysis..."
echo "Project Path: $PROJECT_PATH"

# Detect project type
detect_project_type() {
    if [ -f "$PROJECT_PATH/package.json" ]; then
        echo "javascript"
    elif [ -f "$PROJECT_PATH/pyproject.toml" ] || [ -f "$PROJECT_PATH/setup.py" ]; then
        echo "python"
    elif [ -f "$PROJECT_PATH/pom.xml" ]; then
        echo "java-maven"
    elif [ -f "$PROJECT_PATH/build.gradle" ]; then
        echo "java-gradle"
    elif [ -f "$PROJECT_PATH/go.mod" ]; then
        echo "go"
    elif [ -f "$PROJECT_PATH/Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

PROJECT_TYPE=$(detect_project_type)
echo "Detected Project Type: $PROJECT_TYPE"

# Initialize report
cat > "$REPORT_FILE" <<EOF
{
  "project_path": "$PROJECT_PATH",
  "project_type": "$PROJECT_TYPE",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "analysis": []
}
EOF

# JavaScript/Node.js Analysis
if [ "$PROJECT_TYPE" == "javascript" ]; then
    echo -e "${YELLOW}Running ESLint...${NC}"
    if command -v eslint &> /dev/null; then
        eslint "$PROJECT_PATH" --format json > eslint-report.json 2>&1 || true
        echo "ESLint analysis complete"
    else
        echo -e "${RED}ESLint not found. Install with: npm install -g eslint${NC}"
    fi
    
    echo -e "${YELLOW}Running Prettier check...${NC}"
    if command -v prettier &> /dev/null; then
        prettier "$PROJECT_PATH" --check 2>&1 | tee prettier-check.log || true
        echo "Prettier check complete"
    fi
fi

# Python Analysis
if [ "$PROJECT_TYPE" == "python" ]; then
    echo -e "${YELLOW}Running Pylint...${NC}"
    if command -v pylint &> /dev/null; then
        pylint "$PROJECT_PATH" --output-format=json > pylint-report.json 2>&1 || true
        echo "Pylint analysis complete"
    fi
    
    echo -e "${YELLOW}Running Black format check...${NC}"
    if command -v black &> /dev/null; then
        black "$PROJECT_PATH" --check 2>&1 | tee black-check.log || true
        echo "Black check complete"
    fi
fi

echo -e "${GREEN}Code quality analysis complete${NC}"
echo "Report saved to: $REPORT_FILE"
