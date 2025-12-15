# CodeQL Code Scanning 설정 가이드

## 개요

이 저장소는 **CodeQL Advanced 설정**을 사용하여 코드 보안 취약점을 자동으로 검사합니다. Advanced 설정을 사용하면 더 세밀한 제어와 커스터마이징이 가능하며, 캐싱 등의 최적화 기능을 활용할 수 있습니다.

## ⚠️ 중요: 기본 CodeQL 설정 비활성화 필요

GitHub의 **기본 CodeQL 설정(Default Setup)**과 **Advanced 설정**은 동시에 활성화할 수 없습니다. 두 설정이 동시에 활성화되어 있으면 다음과 같은 에러가 발생합니다:

```
CodeQL analyses from advanced configurations cannot be processed when the default setup is enabled
```

### 기본 설정을 비활성화해야 하는 이유

1. **충돌 방지**: 기본 설정과 Advanced 설정은 상호 배타적이며, 동시 사용 시 워크플로우가 실패합니다.
2. **세밀한 제어**: Advanced 설정을 통해 분석 언어, 빌드 모드, 캐싱 전략 등을 직접 제어할 수 있습니다.
3. **최적화**: 캐싱 기능을 사용하여 분석 시간을 단축할 수 있습니다.
4. **커스터마이징**: 특정 쿼리 팩을 사용하거나 분석 스케줄을 조정할 수 있습니다.

## 기본 CodeQL 설정 비활성화 방법

저장소 소유자 또는 관리자 권한이 있는 사용자만 이 작업을 수행할 수 있습니다.

### 단계별 가이드

1. **저장소 설정 페이지로 이동**
   - 저장소 페이지에서 `Settings` 탭을 클릭합니다.

2. **Code security and analysis 섹션으로 이동**
   - 왼쪽 사이드바에서 `Code security and analysis`를 클릭합니다.

3. **Code scanning 설정 찾기**
   - `Code scanning` 섹션을 찾습니다.

4. **Default setup 비활성화**
   - `Set up` 또는 `Configuration` 버튼을 클릭합니다.
   - `Default` 설정이 활성화되어 있다면, `Disable` 버튼을 클릭합니다.
   - 확인 대화상자가 나타나면 비활성화를 확인합니다.

5. **변경사항 저장**
   - 설정이 비활성화되면 자동으로 저장됩니다.

### 스크린샷 참고 위치

설정 경로:
```
Repository → Settings → Security → Code security and analysis → Code scanning
```

## 현재 워크플로우 설정

이 저장소의 CodeQL Advanced 워크플로우(`.github/workflows/codeql.yml`)는 다음과 같이 설정되어 있습니다:

### 분석 언어

- **JavaScript/TypeScript**: 이 저장소의 주요 애플리케이션 코드가 JavaScript로 작성되어 있어 `javascript-typescript` 언어로 분석합니다.

### 빌드 모드

- **none**: JavaScript는 인터프리터 언어이므로 별도의 빌드 과정이 필요하지 않습니다.

### 실행 스케줄

- **Push 이벤트**: `main` 브랜치에 코드가 푸시될 때마다 실행됩니다.
- **Pull Request**: `main` 브랜치로 향하는 PR이 생성되거나 업데이트될 때 실행됩니다.
- **정기 실행**: 매주 월요일 오전 0시 21분(UTC)에 자동으로 실행됩니다.

### 최적화 기능

- **캐싱**: CodeQL 분석 결과를 캐시하여 반복 실행 시 분석 시간을 단축합니다.
- **Fail-fast 비활성화**: 여러 언어를 분석할 때 하나가 실패해도 나머지는 계속 진행됩니다.

## 워크플로우 실행 확인

기본 설정을 비활성화한 후:

1. `Actions` 탭에서 `CodeQL Advanced` 워크플로우를 확인합니다.
2. 최근 실행 결과를 확인하여 성공적으로 완료되었는지 확인합니다.
3. `Security` 탭의 `Code scanning alerts`에서 발견된 취약점을 확인할 수 있습니다.

## 문제 해결

### 워크플로우가 여전히 실패하는 경우

1. **기본 설정이 완전히 비활성화되었는지 확인**
   - Settings → Code security and analysis → Code scanning에서 "Default" 라벨이 없는지 확인합니다.

2. **워크플로우 재실행**
   - Actions 탭에서 실패한 워크플로우를 선택하고 "Re-run all jobs"를 클릭합니다.

3. **권한 확인**
   - 워크플로우 파일의 `permissions` 섹션이 올바르게 설정되어 있는지 확인합니다.
   - 현재 설정: `security-events: write`, `packages: read`, `actions: read`, `contents: read`

### 추가 언어 분석이 필요한 경우

현재는 JavaScript/TypeScript만 분석하도록 설정되어 있습니다. 다른 언어를 추가로 분석하려면:

1. `.github/workflows/codeql.yml` 파일을 엽니다.
2. `matrix.include` 섹션에 새로운 언어를 추가합니다.

예시:
```yaml
matrix:
  include:
  - language: javascript-typescript
    build-mode: none
  - language: python  # 새로운 언어 추가
    build-mode: none
```

## 참고 자료

- [CodeQL Code Scanning 공식 문서](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning-with-codeql)
- [Advanced Setup 커스터마이징 가이드](https://docs.github.com/en/code-security/code-scanning/creating-an-advanced-setup-for-code-scanning/customizing-your-advanced-setup-for-code-scanning)
- [CodeQL 지원 언어 목록](https://codeql.github.com/docs/codeql-overview/supported-languages-and-frameworks/)

## 지원

문제가 계속되거나 추가 도움이 필요한 경우:

1. 이 저장소에 Issue를 생성하여 문제를 설명해주세요.
2. 실패한 워크플로우 실행 링크를 포함해주세요.
3. 에러 메시지의 전체 내용을 첨부해주세요.
