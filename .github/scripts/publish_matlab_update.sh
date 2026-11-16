#!/usr/bin/env bash
set -euo pipefail

formula=Formula/matlab-mcp-server.rb
branch="autobump/matlab-mcp-server-$VERSION"
title="matlab-mcp-server $VERSION"
api="repos/$GITHUB_REPOSITORY"

require_current_main() {
  git fetch --quiet origin refs/heads/main
  if [[ "$(git rev-parse FETCH_HEAD)" != "$GITHUB_SHA" ]]; then
    echo "main changed during validation; the next run will recheck it." >&2
    exit 1
  fi
}

require_current_main
python3 .github/scripts/matlab_release.py apply "$VERSION" "$SHA256"
git add -- "$formula"
git diff --cached --check
[[ "$(git diff --cached --name-only)" == "$formula" ]]
expected_tree="$(git write-tree)"

existing="$(gh api -X GET "$api/pulls" -f state=all -f base=main -f head="$GITHUB_REPOSITORY_OWNER:$branch" -f per_page=2)"
[[ "$(jq 'length' <<<"$existing")" -le 1 ]]
if jq -e '.[0].state == "closed"' <<<"$existing" >/dev/null; then
  echo "The update PR for $VERSION was already closed. Leaving it closed."
  exit 0
fi

remote_head="$(git ls-remote origin "refs/heads/$branch" | cut -f1)"
if [[ -z "$remote_head" ]]; then
  git -c user.name='github-actions[bot]' \
    -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
    commit -m "$title"
  head="$(git rev-parse HEAD)"
  git push origin "HEAD:refs/heads/$branch"
else
  git fetch --quiet origin "refs/heads/$branch"
  head="$(git rev-parse FETCH_HEAD)"
  [[ "$head" == "$remote_head" ]]
  [[ "$(git show -s --format=%P "$head")" == "$GITHUB_SHA" ]]
  [[ "$(git show -s --format=%T "$head")" == "$expected_tree" ]]
fi

number="$(jq -r '.[0].number // empty' <<<"$existing")"
if [[ -z "$number" ]]; then
  number="$(gh api "$api/pulls" --method POST -f base=main -f head="$branch" \
    -f title="$title" \
    -f body="Only the version, URL, and SHA-256 have changed. The upstream binary passed SHA-256, MathWorks signature, and version checks. Workflow: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" \
    --jq .number)"
fi
[[ "$number" =~ ^[1-9][0-9]*$ ]]
gh api "$api/pulls/$number" | jq -e \
  --arg repo "$GITHUB_REPOSITORY" --arg head "$head" --arg branch "$branch" \
  '.state == "open" and .draft == false and .user.login == "github-actions[bot]" and
   .head.repo.full_name == $repo and .base.repo.full_name == $repo and
   .base.ref == "main" and .head.ref == $branch and .head.sha == $head' >/dev/null

require_current_main
gh api --method PUT "$api/pulls/$number/merge" -f sha="$head" -f merge_method=squash \
  | jq -e '.merged == true'
echo "Merged $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/pull/$number"
