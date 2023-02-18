# v4.6.1 - 2023-02-18

- **FIX:** Fix installing from source on Windows for versions 1.6.x and greater

# v4.6.0 - 2023-02-17

- **NEW:** Support installing from Git repos other than the official Nim repo
- **FIX:** Enable `binary:1.2.6`

# v4.5.0 - 2022-11-23

- **NEW:** Add Nim 1.6.10

# v4.4.0 - 2022-10-17

- **NEW:** You can now select `binary:stable` as a version to install

# v4.3.1 - 2022-10-17

- **FIX:** Sort nightlies

# v4.3.0 - 2022-10-13

- **NEW:** Support supplying `1.4` and `binary:1.4` instead of the full version string
- **FIX:** Stop using now-deprecated set-output GitHub Actions command

# v4.2.0 - 2022-09-27

- **NEW:** Add `binary:1.6.8`

# v4.1.3 - 2022-05-05

- **FIX:** Add `binary:1.6.6`
- **FIX:** Anchored the regex that searches for `binary:` versions so that it no longer searches within the URL/Hash for each version ([#23](https://github.com/iffy/install-nim/issues/23))

# v4.1.2 - 2022-02-14

- **FIX:** Add binary:1.2.18 and binary:1.6.4

# v4.1.1 - 2021-12-17

- **FIX:** Add `binary:1.2.16` and `binary:1.6.2`

# v4.1.0 - 2021-12-13

- **NEW:** Added `binary:1.2.14` as an install option

# v4.0.2 - 2021-12-02

- **FIX:** For real... look for nightlies.txt in the right spot

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

