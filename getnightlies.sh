#!/bin/bash
## Check to see that no tags are missing from nightlies.txt
## If any are missing, attempt to fix it.
##
## Exit codes
##  0 = Success
##  1 = Found some missing nightlies
##  else = Error

set -e
NIM_REPO="https://github.com/nim-lang/Nim.git"
OUTFILE="${2:-nightlies.txt}"
TMPOUT="_getnightlies.txt"
echo > "$TMPOUT"

log() {
  echo >&2 "INFO $@"
}

# sample
# https://github.com/nim-lang/nightlies/releases/tag/2020-10-16-version-1-4-018ae963ba83934a68d815c3c1c44c06e8ec6178
RC=0

for tag in $(git ls-remote --tags "${NIM_REPO}" | cut -f2 | grep '\^' | cut -d'^' -f1 | cut -d'/' -f3); do
  log "tag: ${tag}"
  version="$(echo $tag | cut -c2-)"
  if grep "$version https:" "$OUTFILE" > /dev/null; then
    log "  DONE: already has a URL"
    grep "$version https:" "$OUTFILE" | tee  -a "$TMPOUT"
    continue
  elif grep "$version none" "$OUTFILE" > /dev/null; then
    grep "$version " "$OUTFILE" | tee -a "$TMPOUT"
    log "  DONE: is none"
    continue
  fi
  # Not present, let's get more details about this tag
  log "  missing..."
  if [ ! -d _nim ]; then
    log "Cloning $NIM_REPO to _nim"
    git clone "$NIM_REPO" _nim
  fi
  pushd _nim
    git fetch origin
    log "  attempting to get the release_date"
    release_date="$(git log -n 1 --format="format:%cs" "$tag")"
    log "  release_date=${release_date}"
    log "  attempting to get the sha"
    sha="$(git log -n 1 --format="format:%H" "$tag")"
    log "  sha=${sha}"
  popd
  if [[ "$release_date" < "2019-06-14" ]]; then
    log "  SKIP: this tag was from before nightlies existed"
    echo "$version none" | tee -a "$TMPOUT"
    continue
  fi

  
  major="$(echo $version | cut -d. -f 1)"
  minor="$(echo $version | cut -d. -f 2)"
  found_one=""
  for i in 0 1 2 3 4; do
    # try the release_date and subsequent dates
    thedate="$(python -c 'from datetime import datetime, timedelta; import sys; print((datetime.strptime(sys.argv[1], "%Y-%m-%d") + timedelta(days=int(sys.argv[2]))).strftime("%Y-%m-%d"))' "$release_date" "$i")"
    log "date: $thedate"
    tagname="${thedate}-version-${major}-${minor}-${sha}"
    url="https://github.com/nim-lang/nightlies/releases/tag/${tagname}"
    log "attempting $url"
    if curl -I "$url" 2>/dev/null | grep 404 2>/dev/null >&2; then
      # nothing
      log "  no"
    else
      echo "$version $url" | tee -a "$TMPOUT"
      found_one=yes
      RC=1
      break
    fi
  done
  if [ -z "$found_one" ]; then
    echo "$version none" | tee -a "$TMPOUT"
  fi
done
# log "See $TMPOUT for output"
mv "$TMPOUT" "$OUTFILE"
log "wrote: $OUTFILE"
cat $OUTFILE
exit "$RC"
