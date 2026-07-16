#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <owner/repository> <reviewed-revision> <candidate-revision> [output.md]\n' "$0" >&2
  exit 2
}

[[ $# -ge 3 && $# -le 4 ]] || usage

repository=$1
reviewed=$2
candidate=$3
output=${4:-/dev/stdout}

for command in gh git jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command" >&2
    exit 1
  fi
done

repo_json=$(gh api "repos/$repository")
default_branch=$(jq -r '.default_branch' <<<"$repo_json")
current_head=$(gh api "repos/$repository/commits/$default_branch" --jq '.sha')

reviewed_json=$(gh api "repos/$repository/commits/$reviewed")
candidate_json=$(gh api "repos/$repository/commits/$candidate")
reviewed_sha=$(jq -r '.sha' <<<"$reviewed_json")
candidate_sha=$(jq -r '.sha' <<<"$candidate_json")
reviewed_date=$(jq -r '.commit.committer.date' <<<"$reviewed_json")
candidate_date=$(jq -r '.commit.committer.date' <<<"$candidate_json")
reviewed_subject=$(jq -r '.commit.message | split("\n")[0]' <<<"$reviewed_json")
candidate_subject=$(jq -r '.commit.message | split("\n")[0]' <<<"$candidate_json")
reviewed_parents=$(jq -r '.parents | length' <<<"$reviewed_json")
candidate_parents=$(jq -r '.parents | length' <<<"$candidate_json")

upstream_url="https://github.com/$repository.git"
git fetch --no-tags --quiet "$upstream_url" "$reviewed_sha" "$candidate_sha"

if merge_base=$(git merge-base "$reviewed_sha" "$candidate_sha" 2>/dev/null); then
  relationship=linear-or-diverged
else
  merge_base=none
  relationship=no-common-ancestor
fi

reviewed_files=$(git ls-tree -r --name-only "$reviewed_sha" | wc -l | tr -d ' ')
candidate_files=$(git ls-tree -r --name-only "$candidate_sha" | wc -l | tr -d ' ')
changed_files=$(git diff --name-only "$reviewed_sha" "$candidate_sha" | wc -l | tr -d ' ')
shortstat=$(git diff --shortstat "$reviewed_sha" "$candidate_sha")
patch_id=$(git diff "$reviewed_sha" "$candidate_sha" | git patch-id --stable | cut -d' ' -f1)

{
  printf '# Upstream comparison\n\n'
  printf '| Field | Value |\n'
  printf '|---|---|\n'
  printf "| Repository | \`%s\` |\n" "$repository"
  printf "| Default branch | \`%s\` |\n" "$default_branch"
  printf "| Current default head | \`%s\` |\n" "$current_head"
  printf "| Reviewed revision | \`%s\` |\n" "$reviewed_sha"
  printf "| Candidate revision | \`%s\` |\n" "$candidate_sha"
  printf "| Relationship | \`%s\` |\n" "$relationship"
  printf "| Merge base | \`%s\` |\n" "$merge_base"
  printf '| Reviewed file count | **%s** |\n' "$reviewed_files"
  printf '| Candidate file count | **%s** |\n' "$candidate_files"
  printf '| Changed paths | **%s** |\n' "$changed_files"
  printf "| Stable patch ID | \`%s\` |\n" "$patch_id"
  printf '\n## Revisions\n\n'
  printf -- "- Reviewed: \`%s\` — %s — %s — **%s** parent(s)\n" "$reviewed_sha" "$reviewed_date" "$reviewed_subject" "$reviewed_parents"
  printf -- "- Candidate: \`%s\` — %s — %s — **%s** parent(s)\n" "$candidate_sha" "$candidate_date" "$candidate_subject" "$candidate_parents"
  printf '\n## Diff summary\n\n'
  printf '%s\n\n' "${shortstat:-No tree changes.}"
  printf '```text\n'
  git diff --stat "$reviewed_sha" "$candidate_sha"
  printf '```\n\n'
  printf '## Changed paths\n\n'
  printf '```text\n'
  git diff --name-status "$reviewed_sha" "$candidate_sha"
  printf '```\n'
} >"$output"
