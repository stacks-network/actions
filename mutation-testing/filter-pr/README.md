# Filter PR Mutants action

Run filtering phase for pull requests, and fail the workflow if:
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
      - name: Filter PR Mutants
        id: filter-pr-mutants
        uses: stacks-network/actions/mutation-testing/filter-pr@main
```
