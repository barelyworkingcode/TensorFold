#!/usr/bin/env bash
# Prepare a fresh branch, retaining the local patch series without touching this checkout.
set -euo pipefail
release_tag=${1:?Usage: refresh-local-int8.sh vX.Y.Z}
[[ "$release_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.-]+)?$ ]] || { echo 'Invalid release tag' >&2; exit 2; }
repo_dir=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
[[ -z $(git -C "$repo_dir" status --porcelain) ]] || { echo 'Commit local changes first' >&2; exit 2; }
git -C "$repo_dir" fetch origin --tags
git -C "$repo_dir" rev-parse --verify "refs/tags/$release_tag"
destination="$(dirname "$repo_dir")/TensorFold-int8-$release_tag"
branch="local/qwen-int8-$release_tag"
base_tag=$(cat "$repo_dir/LOCAL_BASE")
mapfile -t patch_commits < <(git -C "$repo_dir" rev-list --reverse "$base_tag..HEAD")
git -C "$repo_dir" worktree add -b "$branch" "$destination" "$release_tag"
git -C "$destination" cherry-pick "${patch_commits[@]}"
printf '%s\n' "$release_tag" > "$destination/LOCAL_BASE"
git -C "$destination" add LOCAL_BASE
git -C "$destination" commit -m "chore: track local patch base at $release_tag"
echo "Prepared $destination. Resolve any conflicts, validate, then install explicitly."
