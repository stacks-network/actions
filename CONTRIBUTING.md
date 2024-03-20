# Contributing to the Stacks Network github actions monorepo

_Modified version of the [stacks-core CONTRIBUTING.md](https://github.com/stacks-network/stacks-core/blob/master/CONTRIBUTING.md)_

The governing idea behind this monorepo of [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) can be summarized in a single sentence:

- _Make things easier for developers_

If there is a way to improve a CI workflow that would benefit other repos in the [stacks-network](https://github.com/stacks-network) org, it belongs here.

## Code of Conduct

This project and everyone participating in it is governed by this [Code of Conduct](./CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Repo Structure

This repo is structured as a typical monorepo, with agnostic [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) at the top level.
Repository specific [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) are added at the top level, i.e. `./stacks-core/cargo`.

_At a minimum_, any new [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) will need the following 2 files:

1. `action.yml` - The composite action workflow (ex: [docker/action.yml](./docker/action.yml))
2. `README.md`- How to use the composite action (ex: [docker/README.md](./docker/README.md))

There may or may not be additional folders/logic depending upon the complexity of the workflow, the above 2 files are the minimum requirement.

#### Branch naming

Branch names should use a prefix that conveys the overall goal of the branch:

- `feat/some-fancy-new-thing` for a new composite action
- `fix/some-broken-thing` for hot fixes and bug fixes
- `docs/something-needs-a-comment` for documentation

#### Merging PRs from Forks

PRs from forks or opened by contributors without commit access require
some special handling for merging. Any such PR, after being reviewed,
must get assigned to a contributor with commit access. This merge-owner
is responsible for:

1. Creating a new branch in this repository based on the base branch
   for the PR.
2. Retargeting the PR toward the new branch.
3. Merging the PR into the new branch.
4. Opening a new PR from `new_branch -> original_base`
5. Tagging reviewers for re-approval.
6. Merging the new PR.

### Git Commit Messages

Aim to use descriptive git commit messages. We try to follow [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/).
The general format is as follows:

```
<type>[optional scope]: <one-line description>

[optional body]
[optional footer(s)]
```

Common types include build, ci, docs, fix, feat, test, refactor, etc.

When a commit is addressing or related to a particular Github issue, it
should reference the issue in the commit message. For example:

```
fix: incorporate unlocks in mempool admitter, #3623
```

## Coding Conventions

### Simplicity of implementation

The most important consideration when accepting or rejecting a contribution is
the simplicity (i.e. ease of understanding) of its implementation.

### Minimal dependencies

Adding new external package dependencies is very much discouraged. Exceptions will be
granted on a case-by-case basis, and only if deemed absolutely necessary.

Additionally, all external dependencies are required to be version locked to a specific commit hash
ex:

```yaml
name: Action
on: push
jobs:
  build:
    name: Job
    runs-on: ubuntu-latest
    steps:
      ## Setup docker buildx
      - name: Set up Docker Buildx
        id: docker_buildx
        uses: docker/setup-buildx-action@2b51285047da1547ffb1b2203d8be4c0af6b1f20 # v3.2.0
```

Which uses [this commit](https://github.com/docker/setup-buildx-action/commit/f95db51fddba0c2d1ec667646a06c2ce06100226)
Although not required, it is encouraged to add a comment for which release an external action is using, i.e. `# v3.0.0.`

### Data Input

_If relevant_, all composite workflows should have clearly defined inputs.
ex:

```yaml
inputs:
  input-1:
    description: "Brief description of what input-1 is"
    required: false
    default: "sample input"
  input-2:
    description: "Brief description of what input-2 is"
    required: true
    default: ""
```

### Data Output

_If relevant_, all composite workflows should have clearly defined outputs.
example (from [stacks-core/cache/bitcoin/action.yml](./stacks-core/cache/bitcoin/action.yml)):

```yaml
outputs:
  cache-hit:
    description: "Cache Hit"
    value: ${{ steps.check_cache.outputs.cache-hit }}
```

Where `check_cache` is the step reporting if a cache already exists.

### Formatting

This repository uses the default github action yaml formatting style. Refer to https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

### Comments

Comments are very important for the readability and correctness of the action. The purpose of comments is:

- Allow readers to understand the roles of an operation in the action.
- Allow readers to check the correctness of the action against the comments.
