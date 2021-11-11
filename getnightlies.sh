#!/bin/bash
set -e
NIM_REPO="$1"
OUTFILE="${2:-$(pwd)/nightlies.txt}"
TMPOUT="$(pwd)/_getnightlies.txt"
echo > "$TMPOUT"

log() {
  echo >&2 "INFO $@"
}

(
  # sample
  # https://github.com/nim-lang/nightlies/releases/tag/2020-10-16-version-1-4-018ae963ba83934a68d815c3c1c44c06e8ec6178
  cd "$NIM_REPO" >/dev/null
  for tag in $(git tag); do
    log "tag: ${tag}"
    version="$(echo $tag | cut -c2-)"
    if grep "$version https:" "$OUTFILE"; then
      log "already here"
      grep "$version https:" "$OUTFILE" | tee  -a "$TMPOUT"
      continue
    elif grep "$version none" "$OUTFILE"; then
      log "set to none"
      continue
    fi
    release_date="$(git log -n 1 --format="format:%cs" "$tag")"
    if [[ "$release_date" < "2019-06-14" ]]; then
      log "Before nightlies existed"
      echo "$version none" | tee -a "$TMPOUT"
      continue
    fi
    sha="$(git log -n 1 --format="format:%H" "$tag")"
    major="$(echo $version | cut -d. -f 1)"
    minor="$(echo $version | cut -d. -f 2)"
    found_one=""
    for i in 0 1 2 3 4; do
      # try the release_date and subsequent dates
      thedate="$(python -c 'from datetime import datetime, timedelta; import sys; print((datetime.strptime(sys.argv[1], "%Y-%m-%d") + timedelta(days=int(sys.argv[2]))).strftime("%Y-%m-%d"))' "$release_date" "$i")"
      echo "date: $thedate"
      tagname="${thedate}-version-${major}-${minor}-${sha}"
      url="https://github.com/nim-lang/nightlies/releases/tag/${tagname}"
      log "attempting $url"
      if curl -I "$url" 2>/dev/null | grep 404 2>/dev/null >&2; then
        # nothing
        log "  no"
      else
        echo "$version $url" | tee -a "$TMPOUT"
        found_one=yes
        break
      fi
    done
    if [ -z "$found_one" ]; then
      echo "$version none" | tee -a "$TMPOUT"
    fi
  done
  # mv "$TMPOUT" "$OUTFILE"
  # log "wrote: $OUTFILE"
)
