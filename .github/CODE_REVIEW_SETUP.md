# Claude AI Code Review - Setup Guide

Automated code review powered by Claude AI that runs on every Pull Request.

## Features

- **Security Scanning**: Detects vulnerabilities (XSS, SQL injection, hardcoded secrets, OWASP Top 10)
- **Best Practices**: Checks coding standards, error handling, type safety, SOLID principles
- **Performance Analysis**: Identifies N+1 queries, memory leaks, blocking operations

## Quick Setup

### 1. Add Anthropic API Key

Go to your repository **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Name | Value |
|------|-------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key from [console.anthropic.com](https://console.anthropic.com) |

### 2. Enable Workflow

The workflow is already configured in `.github/workflows/code-review.yml`. It will automatically run on:

- New Pull Requests
- PR updates (new commits)
- PR reopens

## How It Works

1. **Trigger**: PR is opened or updated
2. **Collect**: Action gathers changed files and diffs
3. **Review**: Claude analyzes code for issues
4. **Report**: Findings posted as PR comment

## Review Output

The action posts a comment with:

```markdown
## ✅ Claude AI Code Review

**Summary:** Code changes look well-structured with proper error handling.

**Overall Rating:** GOOD

### Issues Found (2)

#### 🟡 Missing input validation
- **File:** `src/api/users.js` (line 42)
- **Category:** security
- **Description:** User input not sanitized before database query
- **Suggestion:** Use parameterized queries or input validation

### Positive Observations
- ✨ Good use of TypeScript for type safety
- ✨ Proper error handling with try/catch blocks
```

## Severity Levels

| Level | Emoji | Description |
|-------|-------|-------------|
| Critical | 🚨 | Security vulnerabilities, data exposure |
| High | 🔴 | Bugs, significant issues |
| Medium | 🟡 | Code quality, minor issues |
| Low | 🔵 | Style, minor improvements |
| Info | ℹ️ | Suggestions, FYI |

## Configuration

Edit `.github/scripts/claude-code-review.js` to customize:

```javascript
const CONFIG = {
  maxFilesToReview: 20,        // Max files per review
  maxFileSizeKB: 100,          // Skip files larger than this
  supportedExtensions: [...],   // File types to review
  ignoredPaths: [...]          // Paths to skip
};
```

## Supported Languages

Swift, TypeScript, JavaScript, Python, Go, Rust, Java, Kotlin, C/C++, PHP, Ruby, Vue, Svelte, HTML, CSS, SQL

## Troubleshooting

### "ANTHROPIC_API_KEY not set"
Add the secret to your repository (see Setup step 1)

### Review not posting
Check the Actions tab for workflow errors. Ensure the `GITHUB_TOKEN` has `pull-requests: write` permission.

### Large PRs timing out
Reduce `maxFilesToReview` in config or split the PR into smaller changes.

## Cost Estimation

Each review uses approximately:
- Input: ~2,000-10,000 tokens (depending on diff size)
- Output: ~500-2,000 tokens

Estimated cost: $0.01-0.05 per review with Claude Sonnet.

## Disabling Reviews

To skip review on a specific PR, add `[skip-review]` to the PR title.

To disable entirely, delete `.github/workflows/code-review.yml`.
