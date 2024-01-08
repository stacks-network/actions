# PR Differences Mutants action

Run mutants for differences in pull requests, and fail the workflow if:
- There are missed/timeout/unviable mutants
- Building or testing the unmutated crate fails

## Usage

```yaml
name: Action
on: pull_request
jobs:
  build:
    name: Job
    runs-on: ubuntu-latest
    steps:
      - name: PR Differences Mutants
        id: pr-differences-mutants
        uses: stacks-network/actions/mutation-testing/pr-differences@main
```
