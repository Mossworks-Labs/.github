#!/usr/bin/env bash
# Apply org-wide base repository settings.
#
# Usage:
#   apply-repo-settings.sh <org> <settings-file> [--dry-run]
#
# Reads the JSON `settings` block from the file and PATCHes every repo
# in the org with it. Repos in `exclude_repos` are skipped; archived
# repos are skipped when `exclude_archived: true`.
#
# Requires: gh, jq, and an authenticated `gh` session with org-wide
# Administration: write (covers the PATCH /repos/{owner}/{repo} call
# on every active repo). In CI, set GH_TOKEN to a PAT/fine-grained
# token with `Administration: Read and write` scoped to all org repos.
#
# This script is idempotent — PATCH is safe to repeat. We don't diff
# before patching; the API just no-ops when the desired and current
# values match.

set -euo pipefail

ORG="${1:-}"
FILE="${2:-}"
DRY_RUN=false
if [ "${3:-}" = "--dry-run" ]; then
  DRY_RUN=true
fi

if [ -z "$ORG" ] || [ -z "$FILE" ]; then
  echo "usage: $0 <org> <settings-file> [--dry-run]" >&2
  exit 2
fi

for cmd in gh jq; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "$cmd not found in PATH" >&2; exit 2; }
done

if [ ! -f "$FILE" ]; then
  echo "::error::settings file not found: $FILE" >&2
  exit 2
fi

SETTINGS=$(jq -c '.settings // {}' "$FILE")
EXCLUDE_REPOS=$(jq -c '.exclude_repos // []' "$FILE")
EXCLUDE_ARCHIVED=$(jq -r '.exclude_archived // false' "$FILE")

if [ "$SETTINGS" = "{}" ] || [ -z "$SETTINGS" ]; then
  echo "::error::settings block is empty in $FILE" >&2
  exit 2
fi

echo "Settings to apply:"
jq . <<<"$SETTINGS"
echo "Exclude repos: $EXCLUDE_REPOS"
echo "Exclude archived: $EXCLUDE_ARCHIVED"
echo

# Pull every repo in the org with one paginated call.
REPOS=$(gh api "/orgs/${ORG}/repos?per_page=100" --paginate \
  --jq '[.[] | {name, archived}]')

is_excluded() {
  local name="$1"
  jq -e --arg n "$name" 'index($n)' <<<"$EXCLUDE_REPOS" >/dev/null
}

failed=0
applied=0
skipped=0
total=$(jq -r 'length' <<<"$REPOS")

for i in $(seq 0 $((total - 1))); do
  name=$(jq -r ".[$i].name" <<<"$REPOS")
  archived=$(jq -r ".[$i].archived" <<<"$REPOS")

  if [ "$EXCLUDE_ARCHIVED" = "true" ] && [ "$archived" = "true" ]; then
    echo "skip  ${name}  (archived)"
    skipped=$((skipped + 1))
    continue
  fi

  if is_excluded "$name"; then
    echo "skip  ${name}  (excluded)"
    skipped=$((skipped + 1))
    continue
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "would PATCH /repos/${ORG}/${name}"
    continue
  fi

  if gh api -X PATCH "/repos/${ORG}/${name}" --input - <<<"$SETTINGS" >/dev/null 2>&1; then
    echo "apply ${name}"
    applied=$((applied + 1))
  else
    echo "::error::failed to apply settings to ${name}"
    failed=$((failed + 1))
  fi
done

echo
echo "summary: total=${total} applied=${applied} skipped=${skipped} failed=${failed}"

if [ "$failed" -ne 0 ]; then
  exit 1
fi
