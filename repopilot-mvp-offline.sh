#!/usr/bin/env bash
set -euo pipefail

# RepoPilot (Actions-only) MVP 오프라인 설치 스크립트
# - 리포 루트에서 실행하면 워크플로/정책/스크립트 파일을 생성하고
#   chore/repopilot-mvp 브랜치로 커밋/푸시합니다.
# - gh(깃허브 CLI)가 있으면 PR까지 자동 생성, 없으면 웹에서 PR 생성하시면 됩니다.

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "ERROR: git repo 안에서 실행해주세요."
  exit 1
fi

BR="chore/repopilot-mvp"
mkdir -p .github/workflows scripts docs

# 정책 파일들
cat > policy.labels.json <<'JSON'
{
  "required_prefixes": ["type:", "area:", "impact:"],
  "allowed": {
    "type:": ["ui","ux","feature","bug","docs","chore","refactor","perf","security","build","ci","deps","design","infra","release","i18n","l10n","test","hotfix"],
    "area:": ["ux","api","api/v1","api/v2","api/v3","rules","rules/layering","dem","drawings","infra","vworld"],
    "impact:": ["breaking","normal","security","performance","documentation","none"]
  },
  "case_insensitive": true
}
JSON

cat > policy.changelog.json <<'JSON'
{
  "date_format": "YYYY.MM.DD",
  "categories": ["Breaking","UI","UX","Added","Changed","Fixed","Performance","Security","Docs","Chore"],
  "section_order": ["Breaking","UI","UX","Added","Changed","Fixed","Performance","Security","Docs","Chore"],
  "labels_to_categories": {
    "impact:breaking": "Breaking",
    "type:ui": "UI",
    "type:ux": "UX",
    "area:ux": "UX",
    "bug": "Fixed",
    "enhancement": "Added",
    "docs": "Docs",
    "chore": "Chore"
  },
  "notes_heading": "Notes",
  "contributors": {
    "heading": "Contributors",
    "format": "table",
    "show_emails": false,
    "link_handles": true,
    "min_commits": 1
  }
}
JSON

cat > policy.required-checks.json <<'JSON'
{ "required_checks": ["build","unit-test","e2e-chrome","e2e-firefox","e2e-webkit","label-policy","release-guard"] }
JSON

# /policy 명령 적용 스크립트(간단 버전)
cat > scripts/repopilot-apply.sh <<'SH2'
#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-}"; ARG="${2:-}"
changed=0; summary=""

write_json(){ printf "%s" "$1" > "$2"; changed=1; }

case "$CMD" in
  labels-add)
    key="${ARG%%:*}"; val="${ARG#*:}"
    file=policy.labels.json
    js=$(python - <<'PY' "$file" "$key" "$val"
import json,sys
f,key,val=sys.argv[1],sys.argv[2],sys.argv[3]
with open(f,encoding='utf-8') as fh: J=json.load(fh)
pref=f"{key}:"
J["allowed"].setdefault(pref,[])
if val not in J["allowed"][pref]: J["allowed"][pref].append(val)
print(json.dumps(J,ensure_ascii=False,indent=2))
PY
)
    write_json "$js" "$file"
    summary="$summary\n- labels: add ${key}:${val}"
  ;;
  labels-rm)
    key="${ARG%%:*}"; val="${ARG#*:}"
    file=policy.labels.json
    js=$(python - <<'PY' "$file" "$key" "$val"
import json,sys
f,key,val=sys.argv[1],sys.argv[2],sys.argv[3]
with open(f,encoding='utf-8') as fh: J=json.load(fh)
pref=f"{key}:"
J["allowed"][pref]=[x for x in J["allowed"].get(pref,[]) if x!=val]
print(json.dumps(J,ensure_ascii=False,indent=2))
PY
)
    write_json "$js" "$file"
    summary="$summary\n- labels: remove ${key}:${val}"
  ;;
  checks-set)
    file=policy.required-checks.json
    js=$(python - <<'PY' "$file" "$ARG"
import json,sys
f,arg=sys.argv[1],sys.argv[2]
arr=[x.strip() for x in arg.split(',') if x.strip()]
J={"required_checks":arr}
print(json.dumps(J,ensure_ascii=False,indent=2))
PY
)
    write_json "$js" "$file"
    summary="$summary\n- checks: set to [$ARG]"
  ;;
  release-set)
    file=policy.changelog.json
    k="${ARG%%=*}"; v="${ARG#*=}"
    js=$(python - <<'PY' "$file" "$k" "$v"
import json,sys
f,k,v=sys.argv[1],sys.argv[2],sys.argv[3]
with open(f,encoding='utf-8') as fh: J=json.load(fh)
J[k]=v
print(json.dumps(J,ensure_ascii=False,indent=2))
PY
)
    write_json "$js" "$file"
    summary="$summary\n- release template: set ${k}=${v}"
  ;;
  *) echo "사용법: /policy {labels-add|labels-rm|checks-set|release-set} <arg>"; exit 2;;
esac

printf "%b\n" "$summary" > .repopilot-summary.txt
[ $changed -eq 0 ] && exit 3 || exit 0
SH2
chmod +x scripts/repopilot-apply.sh

# /policy 코멘트 워크플로
cat > .github/workflows/repopilot.yml <<'YML'
name: RepoPilot (Actions-only) MVP
on:
  issue_comment: { types: [created] }
  pull_request_review_comment: { types: [created] }
permissions: { contents: write, pull-requests: write }
jobs:
  repopilot:
    if: >
      (github.event_name == 'issue_comment' && startsWith(github.event.comment.body, '/policy '))
      || (github.event_name == 'pull_request_review_comment' && startsWith(github.event.comment.body, '/policy '))
    runs-on: ubuntu-latest
    steps:
      - name: Guard (OWNER/MEMBER만 허용)
        if: >
          !contains(fromJson('["OWNER","MEMBER"]'), github.event.comment.author_association)
        run: echo "skip outsider" && exit 0

      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.repository.default_branch }}

      - name: Parse command
        id: parse
        run: |
          BODY="${{ github.event.comment.body }}"
          CMD=$(echo "$BODY" | sed -n 's#^/policy[[:space:]]\+\([^[:space:]]\+\).*#\1#p')
          ARG=$(echo "$BODY" | sed -n 's#^/policy[[:space:]]\+[^[:space:]]\+[[:space:]]\+\(.*\)$#\1#p')
          echo "cmd=$CMD" >> $GITHUB_OUTPUT
          echo "arg=$ARG" >> $GITHUB_OUTPUT

      - name: Apply change
        id: apply
        run: |
          chmod +x scripts/repopilot-apply.sh || true
          scripts/repopilot-apply.sh "${{ steps.parse.outputs.cmd }}" "${{ steps.parse.outputs.arg }}" || true
          echo "summary<<EOF" >> $GITHUB_OUTPUT
          cat .repopilot-summary.txt >> $GITHUB_OUTPUT || true
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create PR
        uses: peter-evans/create-pull-request@v6
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: "chore(repopilot): policy update via /policy"
          branch: "repopilot/${{ github.run_id }}"
          title: "chore(repopilot): policy update"
          body: |
            Command:
            ```
            ${{ github.event.comment.body }}
            ```
            ${{ steps.apply.outputs.summary }}
          labels: repopilot
YML

# 안내 문서
cat > docs/REPOPILOT_MVP.md <<'MD'
# RepoPilot (Actions-only) MVP
코멘트로 정책을 바꾸고 PR로 제안합니다.

## 명령 예시
- `/policy labels-add type:ui`
- `/policy labels-rm type:ui`
- `/policy checks-set build,unit-test,e2e-chrome`
- `/policy release-set notes_heading=Notes`
MD

# 브랜치/커밋/푸시
git checkout -b "$BR"
git add .
git commit -m "chore(repopilot): actions-only MVP bootstrap" -m "JIRA: PF-000" || true
git push -u origin "$BR" || true

# gh가 있으면 PR 자동 생성(없어도 무시)
if command -v gh >/dev/null 2>&1; then
  DEF="$(gh api /repos/"${GITHUB_REPOSITORY:-$(git remote get-url origin | sed -n 's#.*github.com[:/]\([^/]*\)/\([^/.]*\).*#\1/\2#p')}" --jq .default_branch 2>/dev/null || echo main)"
  gh pr create --base "$DEF" --head "$BR" --title "chore: add RepoPilot (Actions-only) MVP" --body "Adds comment-driven policy PR workflow."
else
  echo "NOTE: gh 미설치. 웹에서 PR을 생성하시면 됩니다."
fi

echo "완료: PR이 열리면, 이슈/PR 코멘트에 '/policy ...'를 달아서 정책을 바꿔보세요."
