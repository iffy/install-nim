#!/bin/bash
# Heavily borrowed from https://github.com/alaviss/setup-nim/blob/master/setup.sh
# So I guess that makes this GPL?  Can someone add a license here if it's needed.


usage() {
  cat <<EOF
This script will install Nim for GitHub Actions from a variety of
sources.  Provide a single command-line argument of the following
format:

  Using choosenim:

    $0 stable
    $0 1.4.0
    $0 1.4
    $0 choosenim:stable
  
  From prebuilt, published binaries:
  
    $0 binary:1.4.0
    $0 binary:1.4
    $0 binary:stable
  
  From a prebuilt nightly binary:
  
    $0 nightly:https://github.com/nim-lang/nightlies/releases/latest-version-1-0/
    $0 nightly:https://github.com/nim-lang/nightlies/releases/tag/2020-10-26-version-1-0-0ca09f64cf6ecf2050b58bc26ebc622f856b4dc2

  From source by downloading a tarball:

    $0 sourcetar:https://github.com/nim-lang/nightlies/releases/download/latest-version-1-0/source.tar.xz
  
  From a published release version:

    $0 release:1.4.0
  
  From a specific Git SHA or branch of the github.com/nim-lang/Nim.git repo:
  
    $0 git:2382937843092342342556456
    $0 git:devel
  
  From a specific Git SHA or branch of your own Nim repo:

    $0 'git:bbe49a14ae827b6474d692042406716a3b3dd71f https://github.com/iffy/Nim.git'

Set NIMDIR=path/where/nim/will/be
Set GITHUB_TOKEN= to a GitHub API Token generated at
  https://github.com/settings/tokens/new with the `public_repo` scope.
EOF
}
set +x
abspath() {
  thepath="$1"
  ch1="$(echo $thepath | cut -c1)"
  ch2="$(echo $thepath | cut -c2)"
  ch3="$(echo $thepath | cut -c3)"
  if [ "$ch1" == "/" ]; then
    # already absolute linux path
    echo "$thepath"
  elif [ "$ch2" == ":" ]; then
    # already absolute Windows path
    echo "$thepath"
  else
    echo "$(pwd)/${thepath}"
  fi
}
linuxpath() {
  # C:\Users\runneradmin\.nimble\bin -> /c/Users/runneradmin/.nimble/bin
  thepath="$1"
  ch1="$(echo $thepath | cut -c1)"
  ch2="$(echo $thepath | cut -c2)"
  ch3="$(echo $thepath | cut -c3)"
  if [ "$ch1" == "/" ]; then
    # Absolute linux path
    echo "$thepath"
  elif [ "$ch2" == ":" ] && [ "$ch3" == "\\" ]; then
    # X:\ style absolute windows path
    rest="$(echo "$thepath" | cut -c4- | sed -e 's_\\_/_g')"
    echo "/${ch2}/${rest}"
  else
    # relative path
    echo "$thepath" | sed -e 's_\\_/_g'
  fi
}
windowspath() {
  # /c/Users/runneradmin/.nimble/bin -> C:\Users\runneradmin\.nimble\bin
  thepath="$1"
  ch1="$(echo $thepath | cut -c1)"
  ch2="$(echo $thepath | cut -c2)"
  ch3="$(echo $thepath | cut -c3)"
  if [ "$ch1" == "/" ]; then
    # absolute linux-like path
    rest="$(echo "$thepath" | cut -c4- | sed -e 's_/_\\_g')"
    echo "${ch2^}:\\${rest}"
  elif [ "$ch2" == ":" ] && [ "$ch3" == "\\" ]; then
    # X:\ style windows path
    echo "$thepath"
  else
    # relative path?
    echo "$thepath" | sed -e 's_/_\\_g'
  fi
}
iswindows() {
  if [ "$(osname)" == "windows" ]; then
    return 0
  else
    return 1
  fi
}

NIMDIR=${NIMDIR:-nimdir}
THISDIR="$(abspath "$(dirname "$0")")"

add-path() {
  if [ ! -z "$GITHUB_PATH" ]; then
    # Running on GitHub Actions
    echo "$1" >> "$GITHUB_PATH"
    export PATH="$1:$PATH"
    echo "Directory '$1' has been added to PATH via GITHUB_PATH"
  elif [ ! -z "$AZURE_HTTP_USER_AGENT" ]; then
    # Running on Azure Pipelines
    echo "##vso[task.prependpath]$1"
    echo "Directory '$1' has been added to PATH via vso[task.prependpath]"
  else
    # Tell the user to add the path
    echo "export PATH="'"'"\${PATH}:$1"'"'""
  fi
}

osname() {
  case "$(uname -sr)" in
    Darwin*)
      echo 'macos'
      ;;
    Linux*Microsoft*)
      echo 'wsl'  # Windows Subsystem for Linux
      ;;
    Linux*)
      echo 'linux'
      ;;
    CYGWIN*|MINGW*|MINGW32*|MSYS*)
      echo 'windows'
      ;;
    *)
      echo 'other' 
      ;;
  esac
}

guess_archive_name() {
  # Guess the archive name 
  local ext=.tar.xz
  local os; os=$(uname)
  os=$(tr '[:upper:]' '[:lower:]' <<< "$os")
  case "$os" in
    'darwin')
      os=macosx
      ;;
    'windows_nt'|mingw*)
      os=windows
      ext=.zip
      ;;
  esac
  local arch; arch=$(uname -m)
  case "$arch" in
    aarch64)
      arch=arm64 ;;
    armv7l)
      arch=arm ;;
    i*86)
      arch=x32 ;;
    x86_64)
      arch=x64 ;;
  esac
  echo "${os}_${arch}${ext}"
}

unpack_prebuilt() {
  archive_url=$1
  archive_name=${archive_url##*/}
  echo "archive name: $archive_name"

  echo "Creating output dir..."
  mkdir -p "$NIMDIR"
  cd "$NIMDIR"

  echo "Downloading $archive_url ..."
  AUTHARGS=()
  if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "Using GITHUB_TOKEN for authenticated request"
    AUTHARGS+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
  fi
  if ! curl -f "${AUTHARGS[@]}" -LO "$archive_url"; then
    echo "Failed to download"
    exit 1
  fi
  echo "Extracting $archive_name to $(pwd)"
  if [[ $archive_name == *.zip ]]; then
    tmpdir=$(mktemp -d)
    7z x "$archive_name" "-o$tmpdir"
    extracted=( "$tmpdir"/* )
    mv "${extracted[0]}/"* .
    rm -rf "$tmpdir"
    unset tmpdir
  else
    tar -xf "$archive_name" --strip-components 1
  fi
}

build_nim() {
  OSNAME="$(osname)"
  echo "$OSNAME"
  if [ -e ci/build_autogen.bat ] && [ "$OSNAME" == "windows" ]; then
    echo "Using build_autogen.bat"
    ci/build_autogen.bat
  elif [ -e build.sh ]; then
    echo "Using build.sh"
    sh build.sh
  else
    echo "Using build_all.sh"
    sh build_all.sh
  fi
  bin/nim c koch
  ./koch boot -d:release
  ./koch tools
}

ensure_dlls() {
  bindir="$1"
  if [ ! -f "${bindir}/nim" ]; then
    return
  fi
  local os; os=$(uname)
  if [ "$os" != "Darwin" ] && [ "$os" != "Linux" ]; then
    # Make sure DLLs made it. This is a hack to overcome https://github.com/dom96/choosenim/issues/251
    echo "Making sure DLLs are installed"
    if [ $(ls "$bindir" | grep dll | wc -l) -lt 13 ]; then
      echo "Installing missing DLLs into ${bindir} ..."
      curl -L http://nim-lang.org/download/dlls.zip -o dlls.zip
      unzip dlls.zip -d "$bindir"
      rm dlls.zip
    else
      echo "DLLs appear to have already been installed to ${bindir}"
    fi
  fi
}

ensure_libpcre() {
  local os; os="$(uname)"
  if [ "$os" == "Linux" ]; then
    if ! dpkg -l | grep libpcre3-dev; then
      if which sudo; then
        sudo apt-get update -qqq
        sudo apt-get install -y libpcre3-dev
      else
        apt-get update -qqq
        apt-get install -y libpcre3-dev
      fi
    fi
  fi
}

#------------------------------------------------
# Install a published released version of Nim
#------------------------------------------------
install_release() {
  version=$1
  echo "Installing Nim ${version}"
  local os; os=$(uname)
  if [ "$os" == "Darwin" ]; then
    # macos: install from source
    install_sourcetar "https://nim-lang.org/download/nim-${version}.tar.xz"
  elif [ "$os" == "Linux" ]; then
    # linux: install from binary
    archive_name=$(guess_archive_name)
    echo "Archive pattern: $archive_name"
    url="https://nim-lang.org/download/nim-${version}-${archive_name}"
    echo "Guessed URL: $url"
    unpack_prebuilt "$url"
  else
    # windows: install from binary
    archive_name=$(guess_archive_name)
    if echo "$archive_name" | grep x64; then
      url="https://nim-lang.org/download/nim-${version}_x64.zip"
    else
      url="https://nim-lang.org/download/nim-${version}_x32.zip"
    fi
    echo "Guessed URL: $url"
    unpack_prebuilt "$url"
  fi
}

#------------------------------------------------
# Install from a git SHA/branch
#------------------------------------------------
install_git() {
  shalike=$1
  url="$(echo "$shalike" | awk '{print $2;}')"
  shalike="$(echo "$shalike" | awk '{print $1;}')"
  if [ -z "$url" ]; then
    url="https://github.com/nim-lang/Nim.git"
  fi
  echo "Installing from Git: ${shalike} from ${url}"
  git clone -n "$url" "$NIMDIR"
  cd "$NIMDIR"
  git checkout "$shalike"
  ls -al
  build_nim
}

#------------------------------------------------
# Install from a source tarball URL
#------------------------------------------------
install_sourcetar() {
  tarurl=$1
  echo "Installing from source: $tarurl"
  curl -L -o source.tar.xz "$tarurl"
  mkdir -p nimtmp
  tar xf source.tar.xz -C nimtmp
  cd nimtmp
  mv $(ls) "../$NIMDIR"
  cd ..
  rm source.tar.xz
  rm -r nimtmp
  cd "$NIMDIR"
  build_nim
}

#------------------------------------------------
# Install nightly prebuild binaries
# from a GitHub release URL
#------------------------------------------------
install_nightly() {
  url=${1%/}
  echo "Installing prebuilt binaries from: $url"
  archive_name=$(guess_archive_name)
  echo "Archive pattern: $archive_name"
  local archive_url; archive_url=
  tag=${url##*/}
  echo "tag=$tag"
  repo="$(echo $url | cut -d/ -f4-5)"
  echo "repo=$repo"
  nightlydataurl="https://api.github.com/repos/${repo}/releases/tags/${tag}"
  AUTHARGS=()
  if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "Using GITHUB_TOKEN for authenticated request"
    AUTHARGS+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
  fi
  curl -o nightlydata.json "${AUTHARGS[@]}" --header "Accept: application/vnd.github.v3+json" "$nightlydataurl"
  archive_url=$(cat nightlydata.json | grep '"browser_download_url"' | grep "$archive_name" | head -n1 | cut -d'"' -f4)
  if [ -z "$archive_url" ]; then
    echo "ERROR: nightly data from $nightlydataurl --------------------"
    cat nightlydata.json
    echo "ERROR: unable to find archive matching pattern $archive_name"
    exit 1
  fi
  echo "archive_url=$archive_url"
  unpack_prebuilt "$archive_url"
}

#------------------------------------------------
# Install nightly prebuild binaries
# from a version number. This relies on precompiling
# a mapping of version number to nightly using
# `nim c -r getnightlies.nim`
#------------------------------------------------
install_binary() {
  version=${1}
  echo "install_binary $version"
  if [ "$version" == "stable" ]; then
    version=$(tail -n1 "${THISDIR}/nightlies.txt" | cut -d' ' -f1)
    echo "stable -> ${version}"
  fi
  URL="$(grep "^$version" "${THISDIR}/nightlies.txt" | cut -d' ' -f2 | tail -n 1)"
  if [ ! -z "$URL" ] && [ ! "$URL" == "none" ]; then
    echo "Found nightly URL for ${version}: ${URL}"
    install_nightly "$URL"
  else
    echo "ERROR: no nightly found for ${version}"
    exit 1
  fi
}

#------------------------------------------------
# Install using choosenim
#------------------------------------------------
install_choosenim() {
  target="$1"
  echo "Installing via choosenim for: $target"
  if [ "$(echo "${target}" | grep -o "\." | wc -l)" -lt 2 ]; then
    # a "1.4" style version
    target="$(grep "^${target}" "${THISDIR}/nightlies.txt" | cut -d' ' -f1 | tail -n 1)"
    echo "Found version ${target}"
  fi
  export CHOOSENIM_VERSION="0.8.12"
  export CHOOSENIM_NO_ANALYTICS=1
  export CHOOSENIM_CHOOSE_VERSION="$target"
  cat "${THISDIR}/choosenim-unix-init.sh" | sh -s -- -y
  add-path "$HOME/.nimble/bin"
  add-path "$(abspath "$HOME/.nimble/bin")"
  if iswindows; then
    add-path "$(windowspath "$(abspath "$HOME/.nimble/bin")")"
  fi

  #------------------------------------------------
  # Temporary workaround for https://github.com/dom96/choosenim/issues/272
  #------------------------------------------------
  echo "Temporary permission fix for issue https://github.com/dom96/choosenim/issues/272"
  chmod u+x "${HOME}"/.choosenim/toolchains/*/bin/*
}

#------------------------------------------------
# main
#------------------------------------------------
set -e
TARGET=$1
if [ -z "$TARGET" ]; then
  usage
  exit 1
fi

install_type=$(echo "$TARGET" | cut -d: -f1)
install_arg=$(echo "$TARGET" | cut -d: -f2-)
if [ "$install_type" == "$install_arg" ]; then
  install_type="choosenim"
fi

ensure_libpcre

#------------------------------------------------
# Install Nim
#------------------------------------------------
echo "Install type: $install_type"
echo "       param: $install_arg"
(install_${install_type} "${install_arg}")

#------------------------------------------------
# Set up PATH
#------------------------------------------------
echo "Setting up PATH"
if [ -f "$NIMDIR/bin/nim" ]; then
  add-path "$(abspath "$NIMDIR/bin")"
  if iswindows; then
    add-path "$(windowspath "$(abspath "$NIMDIR/bin")")"
  fi
fi
if [ -f "$(pwd)/$NIMDIR/bin/nim" ]; then
  add-path "$(pwd)/$NIMDIR/bin"
  if iswindows; then
    add-path "$(windowspath "$(pwd)/$NIMDIR/bin")"
  fi
fi
add-path "$HOME/.nimble/bin"
add-path "$(abspath "$HOME/.nimble/bin")"
if iswindows; then
  add-path "$(windowspath "$(abspath "$HOME/.nimble/bin")")"
fi
#[ -f "$HOME/.nimble/bin/nim" ] && add-path "$HOME/.nimble/bin" && add-path "$(abspath "$HOME/.nimble/bin")"


#------------------------------------------------
# DLLs
#------------------------------------------------
if [ -f "$HOME/.nimble/bin/nim" ]; then
  ensure_dlls "$HOME/.nimble/bin"
elif [ -f "$NIMDIR/bin/nim" ]; then
  ensure_dlls "$NIMDIR/bin"
else
  echo "Nim doesn't seem to have been installed"
fi

