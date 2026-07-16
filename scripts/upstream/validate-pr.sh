#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  printf 'Usage: %s <base-sha> <head-sha> <head-ref>\n' "$0" >&2
  exit 2
fi

base_sha=$1
head_sha=$2
head_ref=$3

if [[ "$head_ref" != sync/* ]]; then
  printf 'Upstream synchronization branches must use sync/<source>-<revision>.\n' >&2
  exit 1
fi

mapfile -t changed < <(git diff --name-only "$base_sha...$head_sha")
printf 'Changed files:\n'
printf '  %s\n' "${changed[@]}"

mapfile -t records < <(
  printf '%s\n' "${changed[@]}" |
    grep -E '^docs/upstream/[^/]+/[0-9]{4}-[0-9]{2}-[0-9]{2}-[^/]+\.md$' || true
)
if [[ "${#records[@]}" -ne 1 ]]; then
  printf 'Upstream synchronization must change exactly one dated docs/upstream/<source>/ record.\n' >&2
  exit 1
fi

for file in "${changed[@]}"; do
  case "$file" in
    CHANGELOG.md|docs/upstream/*|.cargo/*|bin/*|crates/*|prod/*|proto/*|third_party/*|Cargo.toml|Cargo.lock|rust-toolchain.toml|clippy.toml|LICENSE|THIRD-PARTY-NOTICES)
      ;;
    *)
      printf 'Unrelated or fork-owned path in isolated synchronization: %s\n' "$file" >&2
      exit 1
      ;;
  esac
done

record=${records[0]}
if grep -Fqx '| User-visible change | yes |' "$record"; then
  if ! printf '%s\n' "${changed[@]}" | grep -qx 'CHANGELOG.md'; then
    printf 'User-visible upstream synchronization must update CHANGELOG.md.\n' >&2
    exit 1
  fi
elif ! grep -Fqx '| User-visible change | no |' "$record"; then
  printf 'Missing user-visible classification in %s; use yes or no.\n' "$record" >&2
  exit 1
fi

for heading in '## Provenance' '## Integration decision' '## Verification'; do
  if ! grep -Fqx "$heading" "$record"; then
    printf 'Missing required heading %s in %s.\n' "$heading" "$record" >&2
    exit 1
  fi
done
