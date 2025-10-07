#!/usr/bin/env bash
set -euo pipefail

# merge_bundle_and_apply_ruleset_v36.sh
# - Clones <owner>/<repo>
# - Merges the v3.6 bundle into the repo
# - Pushes a branch and opens a PR
# - Applies Ruleset (branch protection + required checks incl. e2e-{chrome,firefox,webkit}, label-policy, release-guard)
#
# Usage:
#   ./merge_bundle_and_apply_ruleset_v36.sh <owner> <repo> [branch-name] [bundle-zip]
#   # Optional env:
#   #   CHECKS="build,unit-test,e2e-chrome,e2e-firefox,e2e-webkit,label-policy,release-guard"
#   #   COMPANY_DOMAINS="@myco.com,@sub.myco.com"  INCLUDE_BOTS="false"  CONTRIB_MODE="all"
#
# Prereqs: gh (GitHub CLI), git, unzip. Admin perms on the target repo.

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <owner> <repo> [branch-name] [bundle-zip]"
  exit 1
fi

OWNER="$1"
REPO="$2"
BR="${3:-chore/org-rules-v3.6}"
BUNDLE="${4:-}"

# Default checks for v3.6
export CHECKS="${CHECKS:-build,unit-test,e2e-chrome,e2e-firefox,e2e-webkit,label-policy,release-guard}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing dependency '$1'"; exit 1; }; }
need gh; need git; need unzip

# Try to locate bundle if not provided
if [[ -z "$BUNDLE" ]]; then
  if [[ -f "./parcel-feasibility-nextjs-v5-org-policy-ultra-v3.6.zip" ]]; then
    BUNDLE="./parcel-feasibility-nextjs-v5-org-policy-ultra-v3.6.zip"
  elif [[ -f "$HOME/Downloads/parcel-feasibility-nextjs-v5-org-policy-ultra-v3.6.zip" ]]; then
    BUNDLE="$HOME/Downloads/parcel-feasibility-nextjs-v5-org-policy-ultra-v3.6.zip"
  else
    echo "ERROR: v3.6 bundle zip not found. Pass the path as the 4th argument."
    exit 1
  fi
fi

echo "== Params =="
echo "Owner/Repo : $OWNER/$REPO"
echo "Branch     : $BR"
echo "Bundle     : $BUNDLE"
echo "Checks     : $CHECKS"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo ">> Cloning $OWNER/$REPO under $TMPDIR ..."
gh repo clone "$OWNER/$REPO" "$TMPDIR/repo" -- -q
cd "$TMPDIR/repo"

DEFAULT_BRANCH="$(gh api /repos/"$OWNER"/"$REPO" --jq '.default_branch')"
echo ">> Default branch: $DEFAULT_BRANCH"

echo ">> Creating branch $BR"
git checkout -b "$BR"

echo ">> Unzipping bundle into repo root ..."
unzip -oq "$BUNDLE" -d .

echo ">> Staging & committing changes ..."
git add -A
if git diff --cached --quiet; then
  echo "No changes after unzip. Nothing to commit."
else
  git commit -m "chore(ruleset): apply org policy bundle v3.6" -m "JIRA: PF-000"
  git push -u origin "$BR"
fi

echo ">> Applying Ruleset to repository (requires admin on $OWNER/$REPO) ..."
chmod +x scripts/gh-create-ruleset.sh scripts/apply-project-scopes.sh || true
scripts/apply-project-scopes.sh "$OWNER" "$REPO"

echo ">> Creating PR ..."
PR_URL="$(gh pr create --base "$DEFAULT_BRANCH" --head "$BR" \
  --title "chore: apply org policy bundle v3.6" \
  --body "$(cat <<'MD'
This PR applies the **Org Policy ULTRA v3.6** bundle:

- Commit rules (Conventional Commits, footer-only issue keys, type↔scope, BREAKING scopes)
- Release automation (CHANGELOG generator, format checks, tag sync, notes/contributors template)
- Ruleset application helper (branch protection, required checks incl. `e2e-chrome`, `e2e-firefox`, `e2e-webkit`, `label-policy`, `release-guard`)
- PR label policy enforcement (`type:*`, `area:*`, `impact:*`) with expanded allowed sets
- Contributors report workflow (bots/domain filters, modes), co-author aggregation

After merge, required checks will include: `build`, `unit-test`, `e2e-chrome`, `e2e-firefox`, `e2e-webkit`, `label-policy`, `release-guard`.
MD
)" 2>/dev/null || true)"

if [[ -n "$PR_URL" ]]; then
  echo "PR created: $PR_URL"
else
  echo "PR may already exist or creation failed; open PRs:"
  gh pr list --state open --search "$BR" || true
fi

# Optional: set repository variables for contributors report (if provided as env)
if [[ -n "${COMPANY_DOMAINS:-}" ]]; then
  gh variable set COMPANY_DOMAINS --repo "$OWNER/$REPO" --body "$COMPANY_DOMAINS" || true
fi
if [[ -n "${INCLUDE_BOTS:-}" ]]; then
  gh variable set INCLUDE_BOTS --repo "$OWNER/$REPO" --body "$INCLUDE_BOTS" || true
fi
if [[ -n "${CONTRIB_MODE:-}" ]]; then
  gh variable set CONTRIB_MODE --repo "$OWNER/$REPO" --body "$CONTRIB_MODE" || true
fi

echo ">> Done. Review the PR and merge when ready."
