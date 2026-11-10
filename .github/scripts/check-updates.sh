#!/bin/sh
# List the versions pinned in the GitHub Actions workflows next to the latest
# releases, and flag the ones that are a major version behind:
#   - actions in "uses: owner/repo@vN" lines
#   - npm packages in "npm install"/"npx" commands in "run:" lines
#
# Needs gh (logged in) and npm. Exits with 1 if anything is outdated.
#
# Usage: .github/scripts/check-updates.sh

set -eu

cd "$(git rev-parse --show-toplevel)"

for tool in gh npm; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "check-updates: ${tool} is required." >&2
        exit 2
    fi
done

workflows=.github/workflows/*.yml
outdated=0

# Major version of a tag such as v7, v7.0.1 or 12.6.2.
major() {
    echo "$1" | sed -E 's/^v//; s/\..*//'
}

report() {
    name=$1 used=$2 latest=$3
    if [ -z "${latest}" ]; then
        status="? latest version not found"
    elif [ "$(major "${used}")" -lt "$(major "${latest}")" ]; then
        status="outdated"
        outdated=1
    else
        status="ok"
    fi
    printf '%-36s used %-6s latest %-8s %s\n' "${name}" "${used}" "${latest}" "${status}"
}

echo "GitHub Actions"
for ref in $(grep -ohE 'uses: +[^ @]+@[^ ]+' ${workflows} | sed -E 's/^uses: +//' | sort -u); do
    repo=${ref%@*}
    used=${ref#*@}
    latest=$(gh api "repos/${repo}/releases/latest" -q .tag_name 2>/dev/null || true)
    report "${repo}" "${used}" "${latest}"
done

echo
echo "npm packages"
for ref in $(grep -hE 'npm (install|i) |npx ' ${workflows} \
        | grep -oE '(@[a-z0-9._-]+/)?[a-z0-9._-]+@[0-9][0-9.]*' | sort -u); do
    package=${ref%@*}
    used=${ref##*@}
    latest=$(npm view "${package}" version 2>/dev/null || true)
    report "${package}" "${used}" "${latest}"
done

exit "${outdated}"
