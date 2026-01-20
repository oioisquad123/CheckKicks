#!/usr/bin/env node

/**
 * Claude AI Code Reviewer
 *
 * A GitHub Action script that uses Claude to perform comprehensive code reviews
 * on Pull Requests, checking for:
 * - Security vulnerabilities (XSS, injection, OWASP Top 10)
 * - Best practices and coding standards
 * - Performance issues and optimizations
 */

const Anthropic = require('@anthropic-ai/sdk');
const fs = require('fs');
const { execSync } = require('child_process');

// Configuration
const CONFIG = {
  maxFilesToReview: 20,
  maxFileSizeKB: 100,
  supportedExtensions: [
    '.js', '.jsx', '.ts', '.tsx', '.py', '.swift', '.kt', '.java',
    '.go', '.rs', '.rb', '.php', '.cs', '.cpp', '.c', '.h',
    '.vue', '.svelte', '.html', '.css', '.scss', '.sql'
  ],
  ignoredPaths: [
    'node_modules/', 'vendor/', '.git/', 'dist/', 'build/',
    'package-lock.json', 'yarn.lock', 'Pods/', '.build/'
  ]
};

// Initialize Anthropic client
const anthropic = new Anthropic();

/**
 * System prompt for Claude code reviewer
 */
const SYSTEM_PROMPT = `You are an expert code reviewer with deep knowledge of security, performance, and software engineering best practices. Your role is to review code changes in a Pull Request and provide actionable feedback.

## Review Categories

### 1. Security Vulnerabilities (CRITICAL)
- SQL Injection, XSS, CSRF, Command Injection
- Hardcoded secrets, API keys, passwords
- Insecure authentication/authorization
- Path traversal, unsafe file operations
- Insecure deserialization
- OWASP Top 10 vulnerabilities

### 2. Best Practices
- Code organization and readability
- Proper error handling
- Type safety and null checks
- Naming conventions
- DRY principle violations
- SOLID principles adherence
- Documentation for complex logic

### 3. Performance Issues
- N+1 queries, inefficient loops
- Memory leaks, resource cleanup
- Unnecessary re-renders (React/SwiftUI)
- Missing caching opportunities
- Blocking operations on main thread
- Large bundle/binary size impacts

## Response Format

Respond with a JSON object containing:
{
  "summary": "Brief 1-2 sentence summary of the review",
  "overallRating": "excellent|good|needs_improvement|critical_issues",
  "issues": [
    {
      "severity": "critical|high|medium|low|info",
      "category": "security|best_practice|performance",
      "file": "path/to/file.js",
      "line": 42,
      "title": "Brief issue title",
      "description": "Detailed explanation of the issue",
      "suggestion": "Code or approach to fix the issue"
    }
  ],
  "positives": ["List of good practices observed in the code"]
}

## Guidelines
- Be specific: Reference exact lines and provide concrete examples
- Be constructive: Suggest improvements, not just problems
- Prioritize: Focus on critical/high issues first
- Be concise: Avoid verbose explanations
- If no issues found, acknowledge the good code quality
- Only report real issues, avoid false positives`;

/**
 * Read changed files from git
 */
function getChangedFiles() {
  try {
    const files = fs.readFileSync('changed_files.txt', 'utf-8')
      .split('\n')
      .filter(f => f.trim() !== '');

    return files.filter(file => {
      // Check extension
      const hasValidExtension = CONFIG.supportedExtensions.some(ext =>
        file.toLowerCase().endsWith(ext)
      );

      // Check ignored paths
      const isIgnored = CONFIG.ignoredPaths.some(ignored =>
        file.includes(ignored)
      );

      return hasValidExtension && !isIgnored;
    });
  } catch (error) {
    console.error('Error reading changed files:', error);
    return [];
  }
}

/**
 * Get file content and diff
 */
function getFileContent(filePath) {
  try {
    // Check file size
    const stats = fs.statSync(filePath);
    if (stats.size > CONFIG.maxFileSizeKB * 1024) {
      return { content: null, diff: null, skipped: true, reason: 'File too large' };
    }

    const content = fs.readFileSync(filePath, 'utf-8');

    // Get the diff for this file
    let diff;
    try {
      diff = execSync(
        `git diff origin/${process.env.GITHUB_BASE_REF || 'main'}...HEAD -- "${filePath}"`,
        { encoding: 'utf-8', maxBuffer: 1024 * 1024 }
      );
    } catch {
      diff = 'Unable to get diff';
    }

    return { content, diff, skipped: false };
  } catch (error) {
    return { content: null, diff: null, skipped: true, reason: error.message };
  }
}

/**
 * Review code using Claude
 */
async function reviewCode(files) {
  const fileContents = files.slice(0, CONFIG.maxFilesToReview).map(file => {
    const { content, diff, skipped, reason } = getFileContent(file);

    if (skipped) {
      return { file, skipped: true, reason };
    }

    return {
      file,
      content,
      diff,
      skipped: false
    };
  });

  const reviewableFiles = fileContents.filter(f => !f.skipped);

  if (reviewableFiles.length === 0) {
    return {
      summary: 'No reviewable files found in this PR.',
      overallRating: 'excellent',
      issues: [],
      positives: []
    };
  }

  const prompt = `Please review the following code changes from a Pull Request:

${reviewableFiles.map(f => `
### File: ${f.file}

**Diff:**
\`\`\`diff
${f.diff}
\`\`\`

**Full File Content:**
\`\`\`
${f.content}
\`\`\`
`).join('\n---\n')}

Analyze these changes and provide your review in the specified JSON format.`;

  try {
    const response = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: prompt }]
    });

    const responseText = response.content[0].text;

    // Extract JSON from response (handle markdown code blocks)
    const jsonMatch = responseText.match(/```json\n?([\s\S]*?)\n?```/) ||
                      responseText.match(/\{[\s\S]*\}/);

    if (jsonMatch) {
      const jsonStr = jsonMatch[1] || jsonMatch[0];
      return JSON.parse(jsonStr);
    }

    return JSON.parse(responseText);
  } catch (error) {
    console.error('Error calling Claude API:', error);
    throw error;
  }
}

/**
 * Format review as GitHub comment
 */
function formatReviewComment(review) {
  const severityEmoji = {
    critical: '🚨',
    high: '🔴',
    medium: '🟡',
    low: '🔵',
    info: 'ℹ️'
  };

  const ratingEmoji = {
    excellent: '✅',
    good: '👍',
    needs_improvement: '⚠️',
    critical_issues: '🚨'
  };

  let comment = `## ${ratingEmoji[review.overallRating] || '🔍'} Claude AI Code Review\n\n`;
  comment += `**Summary:** ${review.summary}\n\n`;
  comment += `**Overall Rating:** ${review.overallRating.replace('_', ' ').toUpperCase()}\n\n`;

  // Issues section
  if (review.issues && review.issues.length > 0) {
    comment += `### Issues Found (${review.issues.length})\n\n`;

    // Group by severity
    const grouped = {};
    review.issues.forEach(issue => {
      if (!grouped[issue.severity]) grouped[issue.severity] = [];
      grouped[issue.severity].push(issue);
    });

    ['critical', 'high', 'medium', 'low', 'info'].forEach(severity => {
      if (grouped[severity]) {
        grouped[severity].forEach(issue => {
          comment += `#### ${severityEmoji[severity]} ${issue.title}\n`;
          comment += `- **File:** \`${issue.file}\`${issue.line ? ` (line ${issue.line})` : ''}\n`;
          comment += `- **Category:** ${issue.category}\n`;
          comment += `- **Description:** ${issue.description}\n`;
          if (issue.suggestion) {
            comment += `- **Suggestion:** ${issue.suggestion}\n`;
          }
          comment += '\n';
        });
      }
    });
  } else {
    comment += `### No Issues Found\n\n`;
    comment += `Great job! The code looks clean and follows best practices.\n\n`;
  }

  // Positives section
  if (review.positives && review.positives.length > 0) {
    comment += `### Positive Observations\n\n`;
    review.positives.forEach(positive => {
      comment += `- ✨ ${positive}\n`;
    });
    comment += '\n';
  }

  comment += `---\n`;
  comment += `*Powered by Claude AI | [Anthropic](https://anthropic.com)*`;

  return comment;
}

/**
 * Post comment to GitHub PR
 */
async function postGitHubComment(comment) {
  const { PR_NUMBER, REPO_OWNER, REPO_NAME, GITHUB_TOKEN } = process.env;

  if (!PR_NUMBER || !GITHUB_TOKEN) {
    console.log('GitHub environment variables not set. Printing review to console:');
    console.log(comment);
    return;
  }

  const response = await fetch(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${PR_NUMBER}/comments`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GITHUB_TOKEN}`,
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ body: comment })
    }
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to post comment: ${response.status} - ${error}`);
  }

  console.log('Successfully posted review comment to PR');
}

/**
 * Main execution
 */
async function main() {
  console.log('🔍 Starting Claude AI Code Review...\n');

  // Check for API key
  if (!process.env.ANTHROPIC_API_KEY) {
    console.error('Error: ANTHROPIC_API_KEY environment variable is not set');
    console.log('Please add ANTHROPIC_API_KEY to your repository secrets');
    process.exit(1);
  }

  // Get changed files
  const changedFiles = getChangedFiles();
  console.log(`📁 Found ${changedFiles.length} files to review`);

  if (changedFiles.length === 0) {
    console.log('No reviewable files found. Exiting.');
    return;
  }

  changedFiles.forEach(f => console.log(`  - ${f}`));
  console.log('');

  // Review code
  console.log('🤖 Sending code to Claude for review...\n');
  const review = await reviewCode(changedFiles);

  // Format and post comment
  const comment = formatReviewComment(review);
  await postGitHubComment(comment);

  // Exit with error if critical issues found
  if (review.overallRating === 'critical_issues') {
    console.log('\n⚠️ Critical issues found. Please address them before merging.');
    process.exit(1);
  }

  console.log('\n✅ Code review complete!');
}

main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
