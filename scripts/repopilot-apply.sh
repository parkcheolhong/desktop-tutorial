#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-}"; ARG="${2:-}"
changed=0; summary=""

write_json(){ printf "%s" "$1" > "$2"; changed=1; }

case "$CMD" in
  labels-add)
    key="${ARG%%:*}"; val="${ARG#*:}"
    if [[ -z "$key" || -z "$val" || "$key" == "$ARG" ]]; then
      echo "오류: labels-add는 'key:value' 형식이어야 합니다 (예: type:feature)" >&2
      exit 2
    fi
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
    if [[ -z "$key" || -z "$val" || "$key" == "$ARG" ]]; then
      echo "오류: labels-rm은 'key:value' 형식이어야 합니다 (예: type:feature)" >&2
      exit 2
    fi
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
    if [[ -z "$ARG" ]]; then
      echo "오류: checks-set은 최소 하나 이상의 체크를 지정해야 합니다 (예: build,unit-test)" >&2
      exit 2
    fi
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
    k="${ARG%%=*}"; v="${ARG#*=}"
    if [[ -z "$k" || -z "$v" || "$k" == "$ARG" ]]; then
      echo "오류: release-set은 'key=value' 형식이어야 합니다 (예: date_format=YYYY-MM-DD)" >&2
      exit 2
    fi
    file=policy.changelog.json
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
