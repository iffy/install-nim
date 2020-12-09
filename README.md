Github Action to install Nim.

Put the following in `.github/workflows/tests.yml`

## Use latest stable Nim version

```yaml
on:
  pull_request:
  push:

jobs:
  default:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: iffy/install-nim@v3
      - run: nimble install -y
      - run: nimble test
```

## Use specific Nim versions

```yaml
on:
  pull_request:
  push:

jobs:
  tests:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        version:
          - stable
          - devel
          - 1.4.0
          - 1.2.8
          - 1.0.10
          - git:bbe49a14ae827b6474d692042406716a3b3dd71f
        os:
          - ubuntu-latest
          - macOS-latest
          - windows-latest
    steps:
    - uses: actions/checkout@v1
    - uses: iffy/install-nim@v3
      with:
        version: ${{ matrix.version }}
    - name: Test
      continue-on-error: ${{ matrix.version == 'devel' }}
      run: |
        nimble install -y
        nimble test
```

## Implementation

By default, this action uses [choosenim](https://github.com/dom96/choosenim/) to install Nim.

You can also explicitly request a particular build method by prefixing the version with a tag (e.g. `git:` as above).  See [.github/workflows/main.yml](.github/workflows/main.yml) for examples.


## Alternatives

These other GitHub actions might suit your needs better (they're worth checking out):

- https://github.com/alaviss/setup-nim
- https://github.com/jiro4989/setup-nim-action
