**HEY:** Consider using https://github.com/alaviss/setup-nim which installs from pre-built nightlies instead of rebuilding with choosenim.

# install-nim
Github Action to install Nim

Usage (put this in `.github/workflows/tests.yml`):

```yaml
name: tests

on:
  push:
  pull_request:
  schedule:
    - cron: '0 0 * * 1'

jobs:
  tests:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        nimversion:
        - stable
        - devel
        os:
        - ubuntu-latest
        - macOS-latest
        - windows-latest
    steps:
    - uses: actions/checkout@v1
    - uses: iffy/install-nim@v1.1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        nimversion: ${{ matrix.nimversion }}
    - name: Test
      continue-on-error: ${{ matrix.nimversion == 'devel' }}
      run: |
        nimble test
        nimble refresh
```
