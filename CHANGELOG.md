# v5.1.0 - 2025-07-16

- **NEW:** When installing a `binary:` version, if the version isn't found in `nightlies.txt` cache, the cache is refreshed and it tries again.

# v5.0.12 - 2025-07-11

- **FIX:** Stick with choosenim 0.8.12 due to bugs in 0.8.14 on Windows

# v5.0.11 - 2025-07-11

- **FIX:** Add `binary:2.0.16` and `binary:2.2.4`

# v5.0.10 - 2025-02-07

- **FIX:** Add `binary:2.2.2`

# v5.0.9 - 2024-12-31

- **FIX:** Add `binary:2.0.14`

# v5.0.8 - 2024-11-04

- **FIX:** Add `binary:2.0.12`

# v5.0.7 - 2024-10-07

- **FIX:** Added new binary versions

# v5.0.6 - 2024-07-08

- **FIX:** Add `binary:2.0.8`

# v5.0.5 - 2024-06-27

- **FIX:** Add `binary:2.0.6`

# v5.0.4 - 2024-04-22

- **FIX:** Add `binary:1.6.20` and `binary:2.0.4`

# v5.0.3 - 2024-02-19

- **FIX:** Add `binary:1.6.18` and `binary:2.0.2`

# v5.0.2 - 2023-10-23

- **FIX:** Use GITHUB_TOKEN authentication when downloading prebuilt binaries

# v5.0.1 - 2023-10-18

- **FIX:** Add `binary:1.6.16`

# v5.0.0 - 2023-09-22

- **BREAKING CHANGE:** Remove Python dependency when for computing absolute paths. This is listed as breaking as a precaution -- all the existing tests still pass.

# v4.7.3 - 2023-08-01

- **FIX:** Support Nim v2.0.0 ([#38](https://github.com/iffy/install-nim/issues/38))

# v4.7.2 - 2023-07-03

- **FIX:** When run outside of CI, inform the user what needs to be added to the PATH
- **FIX:** Add nightly for v1.6.14

# v4.7.1 - 2023-03-21

- **FIX:** Allow installing Nim within a container in GitHub Actions

# v4.7.0 - 2023-03-10

- **NEW:** Add `binary:1.6.12`
- **FIX:** You can now install nightlies from a URL other than the official Nim URL

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

