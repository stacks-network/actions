# Cargo Check action

Runs `cargo check` commands for different packages and scenarios for the `stacks-core` repository.

## Documentation

## Usage

```yaml
name: Action
on: pull-request
jobs:
  cargo-check:
    name: Cargo Check
    runs-on: ubuntu-latest
    steps:
      - name: Cargo Check
        id: cargo_check
        uses: stacks-network/actions/stacks-core/cargo-check@main
```
