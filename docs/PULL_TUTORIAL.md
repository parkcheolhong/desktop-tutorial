# 🔄 로컬 환경 업그레이드 가이드 (Pull Tutorial)

원격 저장소에서 최신 변경사항을 가져오는 방법을 안내합니다.

## 📌 개요

로컬 저장소를 작업하다 보면 원격 저장소(Remote Repository)에 새로운 커밋이 추가되어 로컬 환경과 동기화가 필요한 경우가 있습니다. 이 가이드에서는 GitHub Desktop과 Git 명령어를 사용하여 변경사항을 가져오는 방법을 설명합니다.

## 🎯 언제 Pull이 필요한가요?

다음과 같은 상황에서 Pull 작업이 필요합니다:

- ✅ 팀원이 원격 저장소에 새로운 커밋을 푸시했을 때
- ✅ 다른 컴퓨터에서 작업한 내용을 동기화할 때
- ✅ GitHub 웹에서 직접 파일을 수정했을 때
- ✅ Pull Request가 병합되어 메인 브랜치가 업데이트되었을 때

## 🖥️ GitHub Desktop 사용하기

### 1단계: 원격 변경사항 확인

1. GitHub Desktop을 실행합니다
2. 상단 메뉴에서 현재 브랜치를 확인합니다
3. "Fetch origin" 버튼을 클릭하여 원격 저장소의 변경사항을 확인합니다

### 2단계: Pull 실행

원격에 새로운 커밋이 있으면 "Pull origin" 버튼이 활성화됩니다:

1. "Pull origin" 버튼을 클릭합니다
2. 자동으로 원격의 변경사항이 로컬로 병합됩니다
3. History 탭에서 새로 가져온 커밋을 확인할 수 있습니다

### 3단계: 충돌 해결 (필요한 경우)

로컬과 원격에서 같은 파일을 수정했다면 병합 충돌이 발생할 수 있습니다:

1. GitHub Desktop이 충돌이 발생한 파일 목록을 표시합니다
2. 충돌 파일을 텍스트 에디터로 엽니다
3. `<<<<<<<`, `=======`, `>>>>>>>` 마커를 찾아 충돌을 해결합니다
4. 해결된 파일을 저장하고 커밋합니다

## 💻 Git 명령어 사용하기

### 기본 Pull 명령어

```bash
# 현재 브랜치의 원격 변경사항 가져오기
git pull

# 특정 원격과 브랜치에서 가져오기
git pull origin main

# Rebase를 사용하여 가져오기 (깔끔한 히스토리 유지)
git pull --rebase origin main
```

### 안전하게 Pull하기

```bash
# 1. 먼저 원격 정보 업데이트
git fetch origin

# 2. 로컬과 원격의 차이 확인
git diff HEAD origin/main

# 3. 확인 후 병합
git merge origin/main
```

### Pull 전 로컬 변경사항 처리

작업 중인 파일이 있다면 먼저 처리해야 합니다:

#### 옵션 1: 커밋하기
```bash
git add .
git commit -m "작업 중인 변경사항 커밋"
git pull
```

#### 옵션 2: Stash 사용하기
```bash
# 변경사항 임시 저장
git stash

# Pull 수행
git pull

# 임시 저장한 변경사항 복원
git stash pop
```

## ⚠️ 주의사항

### Pull 전 체크리스트

- [ ] 현재 브랜치가 올바른지 확인
- [ ] 로컬 변경사항을 커밋하거나 stash로 저장
- [ ] 원격 저장소 URL이 올바른지 확인 (`git remote -v`)
- [ ] 인터넷 연결 상태 확인

### 충돌 발생 시

충돌이 발생하면 당황하지 마세요! 다음 단계를 따르세요:

1. **충돌 파일 확인**: `git status` 명령어로 확인
2. **충돌 마커 찾기**: 
   ```
   <<<<<<< HEAD
   로컬의 변경사항
   =======
   원격의 변경사항
   >>>>>>> origin/main
   ```
3. **올바른 내용 선택**: 필요한 변경사항을 선택하고 마커 제거
4. **충돌 해결 완료**: 
   ```bash
   git add <해결된_파일>
   git commit -m "병합 충돌 해결"
   ```

## 🔍 Pull 후 확인사항

Pull 작업 후 다음을 확인하세요:

```bash
# 현재 커밋 히스토리 확인
git log --oneline -10

# 파일 변경사항 확인
git status

# 특정 파일의 변경 내용 확인
git diff HEAD~1 HEAD -- <파일명>
```

## 📚 추가 리소스

- [Git Pull 공식 문서](https://git-scm.com/docs/git-pull)
- [GitHub Desktop 문서](https://docs.github.com/ko/desktop)
- [병합 충돌 해결 가이드](https://docs.github.com/ko/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts)

## 💡 베스트 프랙티스

1. **자주 Pull하기**: 하루에 한 번 이상 원격 변경사항을 확인하세요
2. **작은 단위로 커밋**: 충돌 가능성을 줄이고 해결을 쉽게 만듭니다
3. **Pull 전 커밋**: 항상 로컬 변경사항을 먼저 커밋하세요
4. **브랜치 전략 사용**: Feature 브랜치를 사용하여 main 브랜치의 충돌을 최소화하세요
5. **팀과 소통**: 같은 파일을 동시에 작업하지 않도록 조율하세요

## 🚀 실습 예제

### 시나리오: 팀원의 커밋 가져오기

1. 팀원이 `feature-login` 브랜치에 새로운 기능을 푸시했습니다
2. 당신의 로컬에서 해당 변경사항을 가져오고 싶습니다

```bash
# 1. 원격 정보 업데이트
git fetch origin

# 2. feature-login 브랜치로 전환
git checkout feature-login

# 3. 원격 변경사항 Pull
git pull origin feature-login

# 4. 변경사항 확인
git log --oneline -5
```

### 시나리오: 메인 브랜치 최신 상태 유지

```bash
# 1. 메인 브랜치로 이동
git checkout main

# 2. 최신 변경사항 가져오기
git pull origin main

# 3. 작업 브랜치로 돌아가기
git checkout feature-branch

# 4. 메인 브랜치의 변경사항 병합
git merge main
```

## ❓ 자주 묻는 질문 (FAQ)

### Q: "Your branch is behind" 메시지가 나타납니다
**A**: 원격 브랜치가 로컬보다 앞서 있다는 의미입니다. `git pull`을 실행하세요.

### Q: Pull할 때마다 충돌이 발생합니다
**A**: 같은 파일을 동시에 수정하고 있을 가능성이 높습니다. 팀원과 작업 영역을 분담하거나, 더 자주 Pull하여 변경사항을 동기화하세요.

### Q: Pull을 취소할 수 있나요?
**A**: Pull 직후라면 `git reset --hard ORIG_HEAD` 명령어로 취소할 수 있습니다. 단, 이미 추가 작업을 했다면 복구가 어려울 수 있습니다.

### Q: Fetch와 Pull의 차이는?
**A**: 
- `git fetch`: 원격 변경사항을 다운로드만 하고 병합하지 않음
- `git pull`: 원격 변경사항을 다운로드하고 자동으로 병합 (`fetch` + `merge`)

---

이 가이드를 통해 원격 저장소의 변경사항을 안전하게 가져오고 로컬 환경을 최신 상태로 유지할 수 있습니다. 궁금한 점이 있다면 팀에 문의하세요!
