# Upload Initial Cache action

Create a new cache with the initial output for the current branch.

## Usage

```yaml
name: Action
on: push
jobs:
  build:
    name: Job
    runs-on: ubuntu-latest
    steps:
      - name: Upload Initial Cache
        id: upload-initial-cache
        uses: stacks-network/actions/mutation-testing/upload-initial-cache@main
```
