#!/bin/sh
# Set the Subresource Integrity hash (sha384) on every local stylesheet and
# script that index.html loads:
#   <link rel="stylesheet" href="style.css" integrity="sha384-…">
#   <script src="script/audio.js" type="module" integrity="sha384-…"></script>
#
# Hashes the staged (index) version of each file, which is what gets committed.
# The pre-commit hook runs this and stages index.html; CI runs it with --check.
#
# Needs GNU coreutils 9.2 or later (cksum --base64).
#
# Usage: .github/scripts/update-sri.sh [--check]
#   --check  change nothing; exit with 1 if any hash is missing or stale

set -eu

cd "$(git rev-parse --show-toplevel)"

check=false
[ "${1:-}" = "--check" ] && check=true

page=index.html

# Each tag sits on one line; take the local href/src of stylesheets and scripts.
subresources=$(
    sed -n \
        -e 's|.*<link rel="stylesheet" href="\([^"]*\)".*|\1|p' \
        -e 's|.*<script src="\([^"]*\)".*|\1|p' \
        "$page" | grep -Ev '^([a-z]+:)?//' || true
)

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
cp "$page" "$tmp"

status=0
for url in $subresources; do
    file=${url#/}
    if ! git cat-file -e ":$file" 2>/dev/null; then
        echo "update-sri: $file is referenced in $page but not staged or tracked." >&2
        status=1
        continue
    fi
    hash=sha384-$(git show ":$file" | cksum -a sha384 --base64 --untagged | cut -d' ' -f1)
    # Drop any old integrity attribute on that tag, then add the current one
    # right after the href/src. Base64 never contains "#" or "&".
    sed -i \
        -e "/\(href\|src\)=\"$(printf '%s' "$url" | sed 's|[.[\*^$/]|\\&|g')\"/{" \
        -e 's# integrity="[^"]*"##' \
        -e "s#\(\(href\|src\)=\"[^\"]*\"\)#\1 integrity=\"$hash\"#" \
        -e '}' \
        "$tmp"
done

if cmp -s "$page" "$tmp"; then
    exit "$status"
fi

if $check; then
    echo "update-sri: integrity hashes in $page are out of date:" >&2
    diff -u "$page" "$tmp" >&2 || true
    exit 1
fi

cat "$tmp" > "$page"
exit "$status"
