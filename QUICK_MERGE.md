# 빠른 병합 참조 (Quick Merge Reference)

병합(merge)이 처음이신가요? 가장 자주 사용하는 방법들입니다.

## 🚀 가장 쉬운 방법: GitHub 웹에서 PR 병합

1. GitHub에서 저장소로 이동
2. "Pull requests" 탭 클릭
3. 병합할 PR 선택
4. "Merge pull request" 버튼 클릭
5. "Confirm merge" 클릭

✅ 완료!

## 📋 GitHub CLI로 빠르게 병합

```bash
# PR 목록 보기
gh pr list

# PR 병합
gh pr merge <PR번호> --merge --delete-branch
```

## 💻 로컬에서 Git 명령어로 병합

```bash
# main 브랜치로 이동
git checkout main

# 최신 변경사항 가져오기
git pull origin main

# 다른 브랜치 병합
git merge feature-branch

# 원격 저장소에 푸시
git push origin main
```

## 📖 자세한 내용은?

전체 병합 가이드를 확인하세요: **[MERGE_GUIDE.md](MERGE_GUIDE.md)**

---

## RepoPilot 정책 PR 병합

RepoPilot이 생성한 정책 PR을 병합하려면:

```bash
# PR 확인
gh pr view <PR번호>

# 정책 변경 확인 후 병합
gh pr merge <PR번호> --merge
```

정책 명령어 예시:
- `/policy labels-add type:ui` - 라벨 추가
- `/policy labels-rm type:hotfix` - 라벨 제거
- `/policy checks-set build,unit-test` - 필수 검사 설정

자세한 내용: [docs/REPOPILOT_MVP.md](docs/REPOPILOT_MVP.md)
