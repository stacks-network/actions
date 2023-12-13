# Logger Mutants action

Check whether to log the mutants to cache, or to create a new cache if it doesn't exist.

## Documentation

### Inputs

| Input | Description | Required | Default |
| ------------------------------- | ----------------------------------------------------- | ------------------------- | ------------------------- |
| `gh-token` | The github token from the main workflow for cache deletion | true | `""` |

## Usage

```yaml
name: Action
on: push
jobs:
  build:
    name: Job
    runs-on: ubuntu-latest
    steps:
      - name: Log Mutants
        id: log-mutants
        uses: stacks-network/actions/mutation-testing/logger@main
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
```
