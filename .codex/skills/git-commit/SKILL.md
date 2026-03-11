---
name: git-commit
description: 'Execute git commit with conventional commit message analysis, intelligent staging, and message generation. Use when user asks to commit changes, create a git commit, or mentions "/commit". Supports: (1) Auto-detecting type and scope from changes, (2) Generating conventional commit messages from diff, (3) Interactive commit with optional type/scope/description overrides, (4) Intelligent file staging for logical grouping'
license: MIT
allowed-tools: Bash
---

# Git Commit with Conventional Commits

## Overview

Create standardized, semantic git commits using the Conventional Commits specification. Analyze the actual diff to determine appropriate type, scope, and message.

## 한글 주석

- 목적: 변경 내용을 분석해 규격화된 Conventional Commit 메시지로 안전하게 커밋하게 하는 스킬이다.
- 사용 시점: 사용자가 커밋 생성, 변경사항 커밋, `/commit` 실행을 요청할 때 사용한다.
- 핵심 절차: diff 분석 -> 스테이징 정리 -> 메시지 생성 -> 안전 규칙 준수 후 커밋 실행.

## Conventional Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## 한국어 커밋 작성 규칙 (추가)

- 커밋 시 **설명 텍스트 전체를 한국어로 작성**한다.
- 적용 범위: 제목의 `<description>`, 본문(body), 푸터(footer) 설명 문구.
- Conventional Commit 구조 토큰(예: `feat`, `fix`, `BREAKING CHANGE`)은 규격 유지를 위해 그대로 사용한다.
- 예시:
  - `feat(auth): 로그인 실패 안내 문구를 개선한다`
  - `fix(api): 주문 조회 시 타임아웃 재시도 로직을 추가한다`

## Commit Types

| Type       | Purpose                        |
| ---------- | ------------------------------ |
| `feat`     | New feature                    |
| `fix`      | Bug fix                        |
| `docs`     | Documentation only             |
| `style`    | Formatting/style (no logic)    |
| `refactor` | Code refactor (no feature/fix) |
| `perf`     | Performance improvement        |
| `test`     | Add/update tests               |
| `build`    | Build system/dependencies      |
| `ci`       | CI/config changes              |
| `chore`    | Maintenance/misc               |
| `revert`   | Revert commit                  |

## Breaking Changes

```
# Exclamation mark after type/scope
feat!: remove deprecated endpoint

# BREAKING CHANGE footer
feat: allow config to extend other configs

BREAKING CHANGE: `extends` key behavior changed
```

## Workflow

### 1. Analyze Diff

```bash
# If files are staged, use staged diff
git diff --staged

# If nothing staged, use working tree diff
git diff

# Also check status
git status --porcelain
```

### 2. Stage Files (if needed)

If nothing is staged or you want to group changes differently:

```bash
# Stage specific files
git add path/to/file1 path/to/file2

# Stage by pattern
git add *.test.*
git add src/components/*

# Interactive staging
git add -p
```

**Never commit secrets** (.env, credentials.json, private keys).

### 3. Generate Commit Message

Analyze the diff to determine:

- **Type**: What kind of change is this?
- **Scope**: What area/module is affected?
- **Description**: One-line summary of what changed, written in Korean (present tense, imperative mood, <72 chars)

### 4. Execute Commit

```bash
# Single line
git commit -m "<type>[scope]: <한글 설명>"

# Multi-line with body/footer
git commit -m "$(cat <<'EOF'
<type>[scope]: <한글 설명>

<한글 본문>

<한글 푸터>
EOF
)"
```

## Best Practices

- One logical change per commit
- Present tense Korean phrasing: "`추가한다`" style
- Imperative mood in Korean: "`버그를 수정한다`" style
- Reference issues with Korean context when possible: `이슈 #123 해결`, `이슈 #456 참고`
- Keep description under 72 characters

## Git Safety Protocol

- NEVER update git config
- NEVER run destructive commands (--force, hard reset) without explicit request
- NEVER skip hooks (--no-verify) unless user asks
- NEVER force push to main/master
- If commit fails due to hooks, fix and create NEW commit (don't amend)
