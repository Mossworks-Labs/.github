#!/usr/bin/env bash
# Apply org-level GitHub repository rulesets from JSON files.
#
# Usage:
#   apply-rulesets.sh <org> <rulesets-dir> [--dry-run]
#
# For each `<rulesets-dir>/*.json`, this script:
#   1. Looks up an existing ruleset on the org by `name` (idempotent).
#   2. Creates (POST) when no match is found.
#   3. Updates (PUT) when a match is found.
#
# Requires: gh, jq, and an authenticated `gh` session whose token has
# org-admin scope on the target organization. In CI, set GH_TOKEN to a
# PAT/fine-grained token with `Administration: write` on the org and run
# unattended.
#
# Drift handling: rulesets present on the org but NOT in the dir are
# left alone (we don't delete by default). To remove a ruleset, delete
# it manually via the UI/API — the JSON file removal alone won't.

set -euo pipefail

ORG="${1:-}"
DIR="${2:-}"
DRY_RUN=false
if [ "${3:-}" = "--dry-run" ]; then
  DRY_RUN=true
fi

if [ -z "$ORG" ] || [ -z "$DIR" ]; then
  echo "usage: $0 <org> <rulesets-dir> [--dry-run]" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found in PATH" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found in PATH" >&2
  exit 2
fi

# Pre-fetch every ruleset on the org once. Subsequent name lookups are
# in-memory rather than per-file API calls.
EXISTING="$(gh api "/orgs/${ORG}/rulesets" --paginate)"

apply_one() {
  local file="$1"
  local name id http_status live
  name="$(jq -r '.name' "$file")"
  if [ -z "$name" ] || [ "$name" = "null" ]; then
    echo "::error file=${file}::missing 'name' field"
    return 1
  fi

  echo "::group::${name} (${file})"

  # Match by exact name. Org rulesets allow duplicate names but we
  # treat the JSON file's name as the unique key.
  id="$(jq -r --arg n "$name" '.[] | select(.name==$n) | .id' <<<"$EXISTING" | head -n1)"

  if [ "$DRY_RUN" = true ]; then
    if [ -n "$id" ]; then
      echo "would PUT  /orgs/${ORG}/rulesets/${id}"
    else
      echo "would POST /orgs/${ORG}/rulesets"
    fi

    # Show diff against the live ruleset (only when one exists).
    if [ -n "$id" ]; then
      live="$(gh api "/orgs/${ORG}/rulesets/${id}" \
        | jq 'del(.id, .source_type, .source, .created_at, .updated_at, .node_id, ._links, .current_user_can_bypass)')"
      diff -u \
        <(echo "$live"      | jq -S .) \
        <(jq -S . "$file") \
        && echo "(no changes)" \
        || true
    fi
    echo "::endgroup::"
    return 0
  fi

  if [ -n "$id" ]; then
    echo "PUT /orgs/${ORG}/rulesets/${id}"
    gh api -X PUT "/orgs/${ORG}/rulesets/${id}" --input "$file" >/tmp/rs-out.json
  else
    echo "POST /orgs/${ORG}/rulesets"
    gh api -X POST "/orgs/${ORG}/rulesets" --input "$file" >/tmp/rs-out.json
  fi
  http_status=$?
  if [ $http_status -ne 0 ]; then
    echo "::error file=${file}::failed to apply (exit ${http_status})"
    cat /tmp/rs-out.json >&2 || true
    return 1
  fi
  jq -r '"applied id=\(.id) name=\(.name) enforcement=\(.enforcement)"' /tmp/rs-out.json
  echo "::endgroup::"
}

shopt -s nullglob
files=("$DIR"/*.json)
shopt -u nullglob

if [ "${#files[@]}" -eq 0 ]; then
  echo "no JSON files found in $DIR — nothing to apply"
  exit 0
fi

failed=0
for f in "${files[@]}"; do
  apply_one "$f" || failed=$((failed + 1))
done

if [ "$failed" -ne 0 ]; then
  echo "::error::${failed} ruleset file(s) failed to apply"
  exit 1
fi

echo "ok — ${#files[@]} ruleset(s) processed"
