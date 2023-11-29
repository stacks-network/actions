# Create downstream PR

When a PR is merged to:

- `master`: a PR is opened against `develop`, assigned to the user who made the last commit
- `develop`: a PR is opened against `next`, assigned to the user who made the last commit

If a PR already exists, or there are no changes between branches the action will exit successfully with no PR created.

## Documentation

## Usage

```yaml
permissions:
  pull-requests: write

jobs:
  create-pr:
    name: Create Downstream PR (${{ github.ref_name }})
    runs-on: ubuntu-latest
    steps:
      - name: Open Downstream PR
        id: create-pr
        uses: stacks-network/actions/stacks-core/downstream-pr@main
        with:
          token: ${{ secrets.GH_TOKEN }}
```

