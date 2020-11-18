Github Action to install Nim.

Put the following in `.github/workflows/tests.yml`

## Use latest stable Nim version

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: iffy/install-nim@v2
  - run: nimble install -y
  - run: nimble test
```

## Use specific Nim versions

```yaml
jobs:
  tests:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        version:
        - stable
        - devel
        - 1.4
        - 1.2
        - 1.0
        - git:bbe49a14ae827b6474d692042406716a3b3dd71f
        os:
        - ubuntu-latest
        - macOS-latest
        - windows-latest
    steps:
    - uses: actions/checkout@v1
    - uses: iffy/install-nim@v1.1
      with:
        nimversion: ${{ matrix.version }}
    - name: Test
      continue-on-error: ${{ matrix.version == 'devel' }}
      run: |
        nimble install -y
        nimble test
```

## Implementation

This attempts to use the fastest method for installing Nim for the specified version.  For most cases [choosenim](https://github.com/dom96/choosenim/) is used.  For macOS, a nightly binary is sometimes used.

You can also explicitly request a particular build method by prefixing the version with a tag (e.g. `git:` as above).  See [.github/workflows/main.yml](.github/workflows/main.yml) for examples.


## Alternatives

- https://github.com/alaviss/setup-nim 
