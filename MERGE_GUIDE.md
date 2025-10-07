# 병합(Merge) 가이드

이 문서는 병합(merge)을 수행하는 다양한 방법을 설명합니다.

## 목차
1. [GitHub에서 PR 병합하기](#github에서-pr-병합하기)
2. [Git 명령어로 병합하기](#git-명령어로-병합하기)
3. [RepoPilot 정책 PR 병합하기](#repopilot-정책-pr-병합하기)
4. [번들 병합 스크립트 사용하기](#번들-병합-스크립트-사용하기)
5. [병합 충돌 해결하기](#병합-충돌-해결하기)

---

## GitHub에서 PR 병합하기

GitHub 웹 인터페이스를 통해 Pull Request를 병합하는 가장 간단한 방법입니다.

### 단계별 방법

1. **PR 페이지로 이동**
   - GitHub 저장소의 "Pull requests" 탭을 클릭합니다
   - 병합하려는 PR을 선택합니다

2. **PR 검토**
   - 변경사항을 확인합니다 ("Files changed" 탭)
   - CI/CD 검사가 통과했는지 확인합니다
   - 리뷰어의 승인을 확인합니다

3. **병합 실행**
   - PR 페이지 하단의 "Merge pull request" 버튼을 클릭합니다
   - 병합 방법을 선택합니다:
     - **Merge commit**: 모든 커밋 히스토리를 유지 (기본값)
     - **Squash and merge**: 모든 커밋을 하나로 합침
     - **Rebase and merge**: 커밋을 재배치하여 선형 히스토리 생성
   - "Confirm merge" 버튼을 클릭합니다

4. **브랜치 삭제 (선택사항)**
   - 병합 후 "Delete branch" 버튼을 클릭하여 불필요한 브랜치를 정리합니다

---

## Git 명령어로 병합하기

터미널에서 Git 명령어를 사용하여 병합하는 방법입니다.

### 로컬에서 브랜치 병합하기

```bash
# 1. main 브랜치로 이동
git checkout main

# 2. 최신 변경사항 가져오기
git pull origin main

# 3. 병합할 브랜치로 전환
git checkout feature-branch

# 4. 최신 변경사항 가져오기
git pull origin feature-branch

# 5. main 브랜치로 다시 전환
git checkout main

# 6. feature-branch를 main으로 병합
git merge feature-branch

# 7. 원격 저장소에 푸시
git push origin main
```

### GitHub CLI를 사용한 PR 병합

```bash
# PR 목록 보기
gh pr list

# 특정 PR 병합
gh pr merge <PR번호>

# 병합 방법을 지정하여 병합
gh pr merge <PR번호> --merge      # Merge commit
gh pr merge <PR번호> --squash     # Squash and merge
gh pr merge <PR번호> --rebase     # Rebase and merge

# 자동으로 브랜치 삭제
gh pr merge <PR번호> --merge --delete-branch
```

---

## RepoPilot 정책 PR 병합하기

RepoPilot이 생성한 정책 변경 PR을 병합하는 방법입니다.

### 정책 PR 검토 및 병합

1. **정책 변경 확인**
   ```bash
   # PR 확인
   gh pr view <PR번호>
   
   # 변경된 파일 확인
   gh pr diff <PR번호>
   ```

2. **정책 파일 검증**
   - `policy.labels.json`: 라벨 정책
   - `policy.required-checks.json`: 필수 검사
   - `policy.changelog.json`: 릴리스 노트 설정

3. **병합 실행**
   ```bash
   # 정책 PR 병합
   gh pr merge <PR번호> --merge
   ```

### RepoPilot 명령어로 정책 변경하기

```bash
# 라벨 추가
/policy labels-add type:ui

# 라벨 제거
/policy labels-rm type:hotfix

# 필수 검사 설정
/policy checks-set build,unit-test,e2e-chrome

# 릴리스 템플릿 설정
/policy release-set notes_heading=Notes
```

이 명령어들은 이슈나 PR 코멘트에 작성하면 자동으로 새로운 정책 PR이 생성됩니다.

---

## 번들 병합 스크립트 사용하기

`merge_bundle_and_apply_ruleset_v36.sh` 스크립트를 사용하여 v3.6 번들을 병합하는 방법입니다.

### 사전 요구사항

- `gh` (GitHub CLI)
- `git`
- `unzip`
- 대상 저장소에 대한 관리자 권한

### 사용법

```bash
# 기본 사용법
./merge_bundle_and_apply_ruleset_v36.sh <owner> <repo>

# 브랜치 이름 지정
./merge_bundle_and_apply_ruleset_v36.sh <owner> <repo> custom-branch-name

# 번들 파일 경로 지정
./merge_bundle_and_apply_ruleset_v36.sh <owner> <repo> branch-name /path/to/bundle.zip

# 환경 변수로 설정 지정
CHECKS="build,unit-test,e2e-chrome" \
COMPANY_DOMAINS="@mycompany.com" \
INCLUDE_BOTS="false" \
CONTRIB_MODE="all" \
./merge_bundle_and_apply_ruleset_v36.sh <owner> <repo>
```

### 스크립트가 수행하는 작업

1. 저장소를 임시 디렉토리에 클론
2. v3.6 번들의 압축을 풀고 파일을 병합
3. 새 브랜치를 생성하고 변경사항을 커밋
4. PR을 생성하고 원격 저장소에 푸시
5. 브랜치 보호 규칙과 필수 검사를 적용
6. 저장소 변수 설정 (선택사항)

### 병합 후 작업

```bash
# PR 확인
gh pr list --state open

# PR을 검토하고 준비되면 병합
gh pr merge <PR번호> --merge
```

---

## 병합 충돌 해결하기

병합 중 충돌이 발생하면 수동으로 해결해야 합니다.

### 충돌 해결 단계

1. **충돌 발생 확인**
   ```bash
   git merge feature-branch
   # CONFLICT (content): Merge conflict in <파일명>
   ```

2. **충돌 파일 확인**
   ```bash
   git status
   # 충돌이 발생한 파일들이 "Unmerged paths"에 표시됩니다
   ```

3. **충돌 마커 찾기**
   충돌이 발생한 파일을 열면 다음과 같은 마커를 볼 수 있습니다:
   ```
   <<<<<<< HEAD
   현재 브랜치의 코드
   =======
   병합하려는 브랜치의 코드
   >>>>>>> feature-branch
   ```

4. **충돌 해결**
   - 충돌 마커를 제거하고 원하는 코드를 선택합니다
   - 또는 두 버전을 모두 통합하여 새로운 버전을 작성합니다

5. **해결된 파일 추가**
   ```bash
   git add <충돌-해결된-파일>
   ```

6. **병합 완료**
   ```bash
   git commit
   # 기본 병합 메시지가 자동으로 생성됩니다
   ```

7. **원격 저장소에 푸시**
   ```bash
   git push origin main
   ```

### 병합 중단하기

충돌 해결이 어려운 경우 병합을 중단할 수 있습니다:

```bash
git merge --abort
```

---

## 추가 리소스

- [GitHub 공식 문서 - About Pull Request Merges](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges)
- [Git 공식 문서 - Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
- [GitHub CLI 문서](https://cli.github.com/manual/)

---

## 도움이 필요하신가요?

- 이슈를 생성하여 질문해주세요
- RepoPilot 관련 질문은 `docs/REPOPILOT_MVP.md`를 참고하세요
