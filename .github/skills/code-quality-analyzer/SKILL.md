---
name: code-quality-analyzer
description: Analyzes code quality, runs linters, formatters, and suggests improvements. Use when you need to review code for style issues, complexity, or potential bugs. Provides detailed reports on code metrics and best practices.
user-invocable: true
disable-model-invocation: false
context: inline
---

# Code Quality Analyzer Skill

This skill helps you analyze code quality across your project using automated tools and best practices. It provides comprehensive reporting on code metrics, style consistency, complexity, and potential issues.

## What This Skill Does

- **Runs linters** to detect code style violations and potential bugs (ESLint, Pylint, etc.)
- **Formats code** automatically to match project standards (Prettier, Black, etc.)
- **Analyzes complexity** to identify functions or methods that may be too complex
- **Suggests improvements** based on code quality metrics and best practices
- **Generates reports** with actionable recommendations

## When to Use

- After writing new code or refactoring existing code
- Before committing changes to ensure quality standards
- When asked to "review code quality" or "improve code"
- When you need metrics on code complexity or maintainability
- To enforce consistent coding standards across a team

## How to Use

### Step 1: Trigger the Skill

Type `/code-quality-analyzer` in the chat to start the analysis. You can optionally specify a file or directory:

```
/code-quality-analyzer src/
/code-quality-analyzer app.js
```

### Step 2: Agent Analyzes Your Code

The skill will:
1. Detect your project type (JavaScript, Python, Java, etc.)
2. Run appropriate linters and formatters
3. Calculate code complexity metrics
4. Identify potential issues and improvements

### Step 3: Review Recommendations

The agent will present:
- **Issues Found**: List of linting errors and style violations
- **Complexity Report**: Functions/methods with high cyclomatic complexity
- **Metrics**: Lines of code, maintainability index, code duplication
- **Suggestions**: Specific improvements with examples

## Key Files in This Skill

- [validate-code.sh](./scripts/validate-code.sh) - Main analysis script
- [complexity-report.py](./scripts/complexity-report.py) - Python-based complexity analyzer
- [samples/](./samples/) - Example project configurations

## Example Usage

**User**: "Analyze the code quality of my src/ directory"

**Agent Response**:
```
I'll run a comprehensive code quality analysis on your src/ directory.

Running linters...
- Found 3 ESLint errors
- Found 2 style warnings

Calculating complexity...
- Function processData() has high complexity (CC: 12)
- Method handleRequest() is well-structured (CC: 4)

Metrics:
- Total Lines: 1,247
- Duplication: 8.2%
- Maintainability Index: 72/100

Recommendations:
1. Split processData() into smaller functions
2. Add missing error handling in asyncHandler()
3. Update JSDoc comments for exported functions
```

## Configuration

### JavaScript/Node.js Projects

The skill automatically detects ESLint and Prettier configurations. To customize:

```json
{
  "eslint": {
    "extends": ["eslint:recommended"],
    "env": { "node": true, "es2020": true }
  }
}
```

### Python Projects

Specify your linting tools in setup.cfg or pyproject.toml:

```ini
[tool:pytest]
testpaths = tests
python_files = test_*.py

[flake8]
max-line-length = 100
```

### Supporting Multiple Languages

This skill supports:
- **JavaScript/TypeScript**: ESLint, Prettier, TSLint
- **Python**: Pylint, Black, Flake8
- **Java**: Checkstyle, PMD, SpotBugs
- **Go**: golangci-lint, go fmt
- **Rust**: Clippy, rustfmt

## Advanced: Complexity Threshold Control

Set complexity thresholds by creating a `.codequalityrc.json` file:

```json
{
  "complexity": {
    "cyclomatic": 10,
    "cognitive": 15
  },
  "coverage": {
    "lines": 80,
    "branches": 75
  }
}
```

## Reference Materials

- [ESLint Documentation](https://eslint.org/docs/latest/)
- [Prettier Formatting](https://prettier.io/docs/en/index.html)
- [Cyclomatic Complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity)
- [Code Maintainability Index](https://en.wikipedia.org/wiki/Maintainability_index)

## Tips

1. **Commit before analysis**: Create a checkpoint before making automated fixes
2. **Review suggestions carefully**: Not all suggestions apply to every project
3. **Use incrementally**: Run on one file first to understand the recommendations
4. **Customize rules**: Disable rules that don't match your team's standards
5. **Track metrics**: Record baseline metrics to measure improvement over time
