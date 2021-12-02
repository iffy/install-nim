# v4.0.1 - 2021-12-02

- **FIX:** `$HOME/.nimble/bin` is always added to PATH now
- **FIX:** Added test for installed nimble binaries being in the path
- **FIX:** `binary:` prefix installations work instead of failing to find `nightlies.txt`
- **FIX:** Revert to running from current dir"

# v4.0.0 - 2021-12-01

- **BREAKING CHANGE:** Run install-nim.sh within the github.action_path directory

# v3.3.0 - 2021-11-11

- **NEW:** Added the `binary:` tag for installing pre-compiled binaries from nightlies, but only having to specify a version. Not supported for all versions.

# v3.2.3 - 2021-11-10

- **FIX:** Added to GitHub Marketplace

# v3.2.2 - 2021-10-04

- **FIX:** Add workaround for permission error in choosenim 0.8.0
- **FIX:** Ensure that SHELL is set during choosenim builds ([#14](https://github.com/iffy/install-nim/issues/14))

# v3.2.1 - 2021-07-15

- **FIX:** Windows DLLs are installed if the installation method fails to do it

# v3.2.0 - 2021-02-23

- **NEW:** Added ability to use `GITHUB_TOKEN` to avoid GitHub rate limits with nightlies
- **NEW:** Added CHANGELOG

