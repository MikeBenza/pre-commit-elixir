#! /bin/bash
# TODO: I don't know enough about git to know whether `HEAD` is right or `git rev-parse --verify HEAD` is right,
# or maybe something else.  I'm just going to use `HEAD` for now.
REV='HEAD'

WORKDIR=$(mktemp -d)
trap 'rm -rf "${WORKDIR}"' exit

ERRORS=0

for filename in "$@" ; do
  # Copy the old file to a temporary location
  OLD_FILE="${WORKDIR}/$(basename "$filename")"
  git show "$REV:$filename" > "$OLD_FILE"

  # Compare credo on the old file and the new file
  OLD_CREDO_COUNT=$(mix credo --format oneline "$OLD_FILE" | wc -l | tr -d ' ')
  NEW_CREDO_COUNT=$(mix credo --format oneline "$filename" | wc -l | tr -d ' ')
  if (( NEW_CREDO_COUNT > OLD_CREDO_COUNT )) ; then
    printf 2<&1 "❌ Credo listed more errors in \033[0;36m%s\033[0m: %d -> %d\n" \
      "$filename" "$OLD_CREDO_COUNT" "$NEW_CREDO_COUNT"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ $ERRORS -gt 0 ]] ; then
  exit 1
fi
