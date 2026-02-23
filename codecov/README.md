# Code Coverage action

- _optionally_ generate a code coverage file using `grcov`.
- Uploads a code coverage file with retries in case of failure.

## Documentation

### Inputs
| Input | Description | Required | Default |
| ------------------------------- | ----------------------------------------------------- | ------------------------- | ------------------------- |
| `test-name` | Test name that is being uploaded | true | null |
| `binary-path` | Used when generating a report, it's the binary path used by grcov | false | `./target/debug/` |
| `verbose` | Output verbosity when uploading a report | false | null |
| `fail_ci_if_error` | Fail the workflow on an error | false | `false` |
| `upload-only` | Skips grcov step and uploads an existing file | false | `false` |

## Usage

### Generate and upload code coverage file

```yaml
name: Action
on: push
jobs:
  build:
    name: Job
    runs-on: ubuntu-latest
    steps:
      - name: Code Coverage
        id: codecov
        uses: stacks-network/actions/codecov@main
        with:
          test-name: sample_test
```

### Upload an existing code coverage file

```yaml
name: Action
on: push
jobs:
  build:
    name: Job
    runs-on: ubuntu-latest
    steps:
      - name: Code Coverage
        id: codecov
        uses: stacks-network/actions/codecov@main
        with:
          upload-only: true
          test-name: sample_test
```
