---
mode: agent
description: 'Plan the solution for a problem.'
tools: ['codebase', 'fetch', 'findTestFiles', 'githubRepo', 'search', 'searchResults', 'usages', 'vscodeAPI']
---
Your goal is to write a Detailed Plan to fix the bug or add new features. To do this, you first need to:

* Read the issue description and comments to understand the context of bugs or features.
* Read the relevant instruction file to understand the code base.
* If it's a bug, identify the **root cause of the bug and explain it to the user.

The plan must be in Markdown format and save the file name in the 'plan/' directory as "**_plan.md".