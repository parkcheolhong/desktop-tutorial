# RepoPilot (Actions-only) MVP
코멘트로 정책을 바꾸고 PR로 제안합니다.

## 명령 예시
- `/policy labels-add type:ui`
- `/policy labels-rm type:ui`
- `/policy checks-set build,unit-test,e2e-chrome`
- `/policy release-set notes_heading=Notes`

## 정책 PR 병합 방법

RepoPilot이 정책 변경 PR을 생성하면:

### 1. GitHub 웹에서 병합
1. PR 페이지로 이동
2. 변경사항 검토 (Files changed 탭)
3. "Merge pull request" 클릭
4. "Confirm merge" 클릭

### 2. GitHub CLI로 병합
```bash
# PR 확인
gh pr view <PR번호>

# PR 병합
gh pr merge <PR번호> --merge
```

더 자세한 병합 방법은 [MERGE_GUIDE.md](../MERGE_GUIDE.md)를 참고하세요.

