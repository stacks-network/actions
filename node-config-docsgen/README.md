# Node Configuration Documentation Generator Action

Generates and uploads Stacks Core configuration documentation.

## Inputs

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
| `output` | Output file for generated documentation | no | `./node-parameters.md` |
| `min-doc-size` | Minimum file size in bytes – build fails if below | no | `50000` |
| `rust-nightly-version` | Rust nightly toolchain version used to build the generator | no | `nightly-2025-06-17` |

## Usage

```yaml
jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: stacks-network/actions/node-config-docsgen@main
```

### Custom example

```yaml
- uses: stacks-network/actions/node-config-docsgen@main
  with:
    artifact-name: "node-docs-${{ github.sha }}.md"
    output-dir: "./documentation"
    min-doc-size: "75000"
```

## How it works

1. Sets up required system deps (`jq`) and a nightly Rust toolchain.
2. Runs `stacks-core/contrib/tools/config-docs-generator/generate-config-docs.sh`,
   exporting `PROJECT_ROOT`, `OUTPUT_FILE` (set from `output`).
3. The generator writes directly to the specified filename—no post-run rename required.
4. Validates size / structure, uploads the file as an artifact and appends a job summary.

## Documentation

### Outputs

The action generates and uploads the following files as artifacts:
- **`node-parameters.md`** – Complete configuration reference in Markdown format

## Related Tools

- **Source**: `stacks-core/contrib/tools/config-docs-generator/`
- **Shell Script**: `generate-config-docs.sh`
