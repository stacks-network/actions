# PR Merge Process for stacks-network/actions

## Overview

This document outlines the required process for merging pull requests to the `stacks-network/actions` repository. Since composite actions in this repository are used across multiple repositories in the stacks-network organization, breaking changes can have widespread impact. This process ensures changes are properly validated before merging.

## Table of Contents

1. [Branch Protection Rules](#branch-protection-rules)
2. [Required Checks](#required-checks)
3. [Approval Requirements](#approval-requirements)
4. [Testing Requirements](#testing-requirements)
5. [Pre-Merge Checklist](#pre-merge-checklist)
6. [Breaking Changes](#breaking-changes)
7. [PR Merge Process Flowchart](PR-Merge-Process-Flowchart)

---

## Branch Protection Rules

### Main Branch

The `main` branch must be protected with the following settings:

- **Require pull request before merging**: ✅ Enabled
- **Require approvals**: Minimum of **2 approvals** from code owners
- **Dismiss stale pull request approvals when new commits are pushed**: ✅ Enabled
- **Require review from Code Owners**: ✅ Enabled
- **Require status checks to pass before merging**: ✅ Enabled
- **Require branches to be up to date before merging**: ✅ Enabled
- **Require conversation resolution before merging**: ✅ Enabled
- **Require signed commits**: ✅ Recommended
- **Include administrators**: ✅ Enabled (administrators must follow same rules)
- **Restrict who can push to matching branches**: Limit to repository administrators and CI/CD service accounts

---

## Required Checks

All PRs must pass the following checks before merging:

### 1. **Validation Workflow**

A workflow that validates the composite action changes in isolation:

```yaml
name: Validate Composite Action Changes

on:
  pull_request:
    branches:
      - main

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout PR
        uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      
      - name: Validate action.yml files
        run: |
          # Check all action.yml files are valid
          for action in */action.yml; do
            echo "Validating $action"
            # Add validation logic here
          done
```

### 2. **Integration Testing**

For changes to composite actions, a test workflow must demonstrate the updated action works correctly:

- **Test Repository**: Create a test workflow in this repository under `.github/workflows/test-*.yml`
- **Test Coverage**: The test workflow must exercise all inputs and outputs of the modified action
- **Test Execution**: The test workflow must run successfully on the PR branch before merging

**Example test workflow structure:**

```yaml
name: Test Updated Action

on:
  pull_request:
    paths:
      - 'action-name/**'

jobs:
  test-action:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Test the action
        uses: ./action-name
        with:
          # Test all required inputs
          input1: value1
          input2: value2
      
      - name: Verify outputs
        run: |
          # Validate expected outputs
          echo "Testing completed successfully"
```

### 3. **Documentation Check**

- All changes must include updated documentation
- README files must reflect current functionality
- Breaking changes must be documented in CHANGELOG.md

### 4. **Linting and Formatting**

- YAML linting must pass
- Shell scripts must pass shellcheck
- Any code must meet repository formatting standards

---

## Approval Requirements

### Minimum Approvals: **2**

**Who can approve:**
- Repository maintainers
- Code owners (as defined in CODEOWNERS file)
- Team members with write access

**Approval criteria:**
1. Reviewer has verified the changes don't introduce breaking changes (or breaking changes are properly documented)
2. Reviewer has confirmed test coverage is adequate
3. Reviewer has validated that dependent repositories won't be negatively impacted
4. For composite action changes: reviewer has verified the test workflow passes

**When additional review is required:**
- Changes affecting critical actions (e.g., `cleanup`, `docker`, `stacks-core/*`)
- Changes to action interfaces (inputs/outputs)
- Changes to archive building or artifact handling
- Any breaking changes

---

## Testing Requirements

### For New Composite Actions

1. Create a test workflow in `.github/workflows/test-[action-name].yml`
2. Test must cover all inputs and expected outputs
3. Test must run on PR and pass before merge
4. Document test coverage in the action's README

### For Modified Composite Actions

1. **Update existing test workflow** to cover new/changed functionality
2. **Run integration test** showing the action works with the changes
3. **Test in dependent repository** (optional but recommended):
   - Create a test PR in a repository that uses the action
   - Point the action reference to the PR branch
   - Verify the workflow completes successfully
   - Example: `uses: stacks-network/actions/action-name@pr-branch`

### For Archive/Artifact Changes

When changes affect how test archives or artifacts are built (e.g., in `stacks-core/cache-*` actions):

1. **Create integration test** demonstrating:
   - Archives are created correctly
   - Archives can be extracted and used
   - Downstream jobs can consume the artifacts
   
2. **Test with actual workload**:
   - Run a workflow in stacks-core that uses the modified action
   - Verify tests pass with the new archive format/structure
   
3. **Document migration path** if format changes:
   - How to handle existing caches
   - Whether cache invalidation is needed
   - Timeline for deprecation of old formats

---

## Pre-Merge Checklist

Before merging any PR, ensure:

- [ ] All status checks are passing
- [ ] Minimum 2 approvals from code owners/maintainers
- [ ] All conversations are resolved
- [ ] Documentation is updated (README, CHANGELOG, comments)
- [ ] Test workflows exist and pass for modified actions
- [ ] Breaking changes are clearly documented
- [ ] Dependent repositories have been identified
- [ ] Migration guide exists for breaking changes (if applicable)
- [ ] PR description clearly explains the changes and rationale

---

## Breaking Changes

### Definition

A breaking change is any modification that:
- Changes required inputs to a composite action
- Removes or renames outputs
- Changes the behavior of an action in a way that could break existing workflows
- Modifies artifact/archive formats that dependent workflows rely on
- Changes environment requirements (e.g., new dependencies)

### Process for Breaking Changes

1. **Label PR** with `breaking-change` label
2. **Document in CHANGELOG.md**:
   - What is breaking
   - Why the change is necessary
   - Migration path for users
   - Timeline for deprecation (if applicable)

3. **Create Migration Guide**:
   - Step-by-step instructions for updating dependent workflows
   - Example before/after workflow snippets
   - List of all known affected repositories

4. **Notify Affected Teams**:
   - Post in relevant Slack channels
   - Tag affected repository maintainers in the PR
   - Provide timeline for when the change will be merged

5. **Deprecation Period** (when possible):
   - Support both old and new behavior for at least 2 weeks
   - Add deprecation warnings
   - Update all known dependent workflows before removing old behavior

6. **Require 3 Approvals** instead of 2 for breaking changes

### Breaking Change PR Template

```markdown
## Breaking Change Notice

**What's breaking:**
[Describe what is changing]

**Why this change:**
[Explain the rationale]

**Migration guide:**
1. [Step-by-step instructions]
2. [Include code examples]

**Affected repositories:**
- [ ] stacks-core
- [ ] [list all affected repos]

**Timeline:**
- PR merged: [date]
- Deprecation period ends: [date]
- Old behavior removed: [date]
```

---
## PR Merge Process Flowchart

Process Flow Diagram
┌─────────────────────────────────────────────────────────────────┐
│                    CONTRIBUTOR CREATES PR                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PR TEMPLATE AUTO-FILLS                          │
│  • Description sections                                          │
│  • Checklist items                                               │
│  • Breaking change notice (if applicable)                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              AUTOMATED VALIDATION STARTS                         │
│                                                                   │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 1. Detect Changes                                 │           │
│  │    - Which actions modified?                      │           │
│  │    - YAML files changed?                          │           │
│  └──────────────┬───────────────────────────────────┘           │
│                 │                                                 │
│                 ▼                                                 │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 2. Validate YAML Syntax                           │           │
│  │    ✓ All action.yml files valid                   │           │
│  │    ✓ Composite action structure correct           │           │
│  └──────────────┬───────────────────────────────────┘           │
│                 │                                                 │
│                 ▼                                                 │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 3. Check Documentation                            │           │
│  │    ⚠ README exists?                               │           │
│  │    ⚠ CHANGELOG updated?                           │           │
│  └──────────────┬───────────────────────────────────┘           │
│                 │                                                 │
│                 ▼                                                 │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 4. Detect Breaking Changes                        │           │
│  │    • Inputs removed?                              │           │
│  │    • Outputs changed?                             │           │
│  │    • Required inputs added?                       │           │
│  └──────────────┬───────────────────────────────────┘           │
│                 │                                                 │
│                 ▼                                                 │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 5. Validate Shell Scripts                        │           │
│  │    ✓ Shellcheck passes                            │           │
│  └──────────────┬───────────────────────────────────┘           │
│                 │                                                 │
│                 ▼                                                 │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 6. Check Test Coverage                            │           │
│  │    • Test workflow exists?                        │           │
│  │    • Test workflow runs?                          │           │
│  └──────────────┬───────────────────────────────────┘           │
│                 │                                                 │
│                 ▼                                                 │
│  ┌──────────────────────────────────────────────────┐           │
│  │ 7. Check PR Description                           │           │
│  │    ✓ Sufficient detail                            │           │
│  │    ⚠ Has required sections?                       │           │
│  └──────────────┬───────────────────────────────────┘           │
└─────────────────┴───────────────────────────────────────────────┘
                  │
                  ▼
         ┌────────┴────────┐
         │ All Checks Pass? │
         └────────┬────────┘
                  │
         ┌────────┴────────┐
         │                 │
    YES  │                 │  NO
         ▼                 ▼
┌─────────────────┐  ┌──────────────────────┐
│ Proceed to      │  │ Fix Issues and       │
│ Review Process  │  │ Push New Commits     │
└────────┬────────┘  └──────────┬───────────┘
         │                      │
         │                      │ (Restarts validation)
         │                      └────────────┐
         │                                   │
         ▼                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                   CODEOWNERS AUTO-ASSIGNED                       │
│  • Based on files changed                                        │
│  • Requests reviews automatically                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────┴────────┐
                    │ Breaking Change? │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
               YES  │                 │  NO
                    ▼                 ▼
         ┌──────────────────┐  ┌─────────────────┐
         │ Require:         │  │ Require:        │
         │ • 3 Approvals    │  │ • 2 Approvals   │
         │ • Migration docs │  │                 │
         │ • Team notif.    │  │                 │
         │ • Label          │  │                 │
         └────────┬─────────┘  └────────┬────────┘
                  │                     │
                  └──────────┬──────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      REVIEW PROCESS                              │
│                                                                   │
│  Reviewer 1:                                                     │
│  ├─ Check code quality                                           │
│  ├─ Verify tests exist and pass                                  │
│  ├─ Review documentation                                         │
│  ├─ Check for breaking changes                                   │
│  └─ Approve or request changes                                   │
│                                                                   │
│  Reviewer 2:                                                     │
│  ├─ Independent review                                           │
│  ├─ Verify dependent repos won't break                          │
│  ├─ Check migration guide (if breaking)                         │
│  └─ Approve or request changes                                   │
│                                                                   │
│  Reviewer 3 (if breaking change):                               │
│  ├─ Senior maintainer approval                                   │
│  ├─ Verify impact assessment                                     │
│  └─ Approve or request changes                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────┴────────┐
                    │ All Approved?   │
                    │ Changes Resolved?│
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
               YES  │                 │  NO
                    ▼                 ▼
         ┌──────────────────┐  ┌──────────────────┐
         │ Ready to Merge   │  │ Address Feedback │
         └────────┬─────────┘  └─────────┬────────┘
                  │                      │
                  │                      └──────┐
                  │                             │
                  │                             │ (Back to Review)
                  │                             │
                  ▼                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FINAL CHECKS                                │
│  ✓ Branch up to date with main                                  │
│  ✓ All conversations resolved                                    │
│  ✓ All status checks passing                                     │
│  ✓ Required approvals obtained                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────┴────────┐
                    │ Merge PR        │
                    │ (Squash & Merge)│
                    └────────┬────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      POST-MERGE                                  │
│                                                                   │
│  Automatic:                                                      │
│  ├─ Branch deleted                                               │
│  ├─ Issue linked (if any)                                        │
│  └─ Notifications sent                                           │
│                                                                   │
│  Manual:                                                         │
│  ├─ Monitor dependent workflows (48 hours)                       │
│  ├─ Update CHANGELOG for release                                 │
│  ├─ Create git tag (if releasing)                               │
│  └─ Update dependent repos (if breaking)                        │
└─────────────────────────────────────────────────────────────────┘
 ## Decision Points
1. Is This Change Small?
- YES → Continue with standard process
- NO → Consider opening an issue first to discuss
2. Does This Modify a Composite Action?
- YES → Must have test workflow
- NO → Standard validation only
3. Is This a Breaking Change?
- YES →

Add breaking-change label
Update CHANGELOG with migration guide
Get 3 approvals instead of 2
Notify affected teams

NO → Standard 2-approval process
4. Is This an Emergency Hotfix?
YES →

## Version Tagging

After merging changes:

1. **Tag releases** using semantic versioning:
   - Major version (v2.0.0): Breaking changes
   - Minor version (v1.1.0): New features, backwards compatible
   - Patch version (v1.0.1): Bug fixes

2. **Update version references** in dependent repositories:
   - Use major version tags for stability (e.g., `@v1`)
   - Pin to specific versions for critical workflows (e.g., `@v1.2.3`)

3. **Maintain version branches**:
   - Create `v1`, `v2` branches for major versions
   - Backport critical fixes to supported versions

---

## Emergency Hotfix Process

For critical issues requiring immediate merge:

1. **Create hotfix PR** with `hotfix` label
2. **Requires 1 approval** from repository admin
3. **Must include**:
   - Clear description of the issue being fixed
   - Impact assessment
   - Rollback plan if hotfix causes issues
4. **Post-merge**:
   - Monitor dependent workflows for 24 hours
   - Document incident and resolution
   - Create follow-up PR for proper testing/documentation

---

## CODEOWNERS

Create a `CODEOWNERS` file to automatically request reviews from appropriate maintainers:

```
# Default owners for everything
* @stacks-network/actions-maintainers

# Specific action ownership
/stacks-core/ @stacks-network/core-maintainers
/docker/ @stacks-network/infrastructure-team
/cleanup/ @stacks-network/infrastructure-team
```

---

## Monitoring and Rollback

### Post-Merge Monitoring

After merging changes to composite actions:

1. **Monitor dependent workflows** for 48 hours
2. **Check for**:
   - Increased failure rates
   - Performance regressions
   - Unexpected behavior
3. **Set up alerts** for workflow failures in dependent repos

### Rollback Procedure

If a merged change causes issues:

1. **Immediate**: Revert the PR
2. **Notify**: Alert in team channels
3. **Investigate**: Create issue to track root cause
4. **Fix Forward**: Create new PR with proper fix and testing
5. **Post-Mortem**: Document what went wrong and how to prevent it

---

## Questions or Issues?

If you have questions about this process:

- Open an issue in this repository
- Ask in #actions-help Slack channel
- Tag @stacks-network/actions-maintainers

---

