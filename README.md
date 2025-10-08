# RepoPilot MVP

This repository contains the RepoPilot MVP implementation - a comment-driven policy management system for GitHub repositories.

Write your name on line 6, save it, and then head back to GitHub Desktop.

## 📚 문서 (Documentation)

### 병합 관련 (Merge Documentation)
- **[빠른 병합 참조 (Quick Merge Reference)](QUICK_MERGE.md)** - 가장 자주 사용하는 병합 방법 요약
- **[병합 가이드 (Merge Guide)](MERGE_GUIDE.md)** - PR 병합, Git 병합, 번들 병합 등 다양한 병합 방법 상세 설명

### 기타 문서 (Other Documentation)
- **[RepoPilot MVP](docs/REPOPILOT_MVP.md)** - 코멘트 기반 정책 관리 시스템
- **[보안 정책 (Security Policy)](SECURITY.md)** - 보안 취약점 보고 방법
## Overview

RepoPilot allows repository maintainers to manage policies (labels, required checks, release templates) through simple comments on issues and pull requests. When you post a `/policy` command, RepoPilot automatically creates a pull request with the requested changes.

## Features

- **Label Management**: Add or remove allowed label values
- **Required Checks**: Update the list of required CI checks
- **Release Templates**: Configure changelog and release note settings
- **Automated PR Creation**: All changes are proposed via pull requests for review

## Usage

### Commands

Post these commands as comments on any issue or pull request:

#### Add a label
```
/policy labels-add type:ui
```

#### Remove a label
```
/policy labels-rm type:hotfix
```

#### Set required checks
```
/policy checks-set build,unit-test,e2e-chrome
```

#### Update release template settings
```
/policy release-set notes_heading=Notes
```

### Permissions

Only repository owners and members can execute `/policy` commands. Comments from outside contributors are automatically ignored.

## How It Works

1. User posts a `/policy` command as a comment
2. GitHub Actions workflow is triggered
3. The command is parsed and validated
4. Policy files are updated automatically
5. A pull request is created with the changes
6. Team reviews and merges the PR

## Policy Files

- `policy.labels.json` - Allowed label prefixes and values
- `policy.required-checks.json` - Required CI checks for merging
- `policy.changelog.json` - Release notes and changelog configuration

## Installation

To install RepoPilot in your repository, run:

```bash
./repopilot-mvp-offline.sh
```

This script will:
- Create the GitHub Actions workflow
- Set up policy files
- Create initial configuration
- Open a pull request with the changes

## Documentation

For more details, see:
- [RepoPilot MVP Documentation](docs/REPOPILOT_MVP.md)
- [Code Review Summary](CODE_REVIEW.md)
