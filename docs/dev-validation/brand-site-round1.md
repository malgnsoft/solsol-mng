# brand-site — 검증 라운드1 (BR01 사용자단 신규 앱)

| 항목 | 내용 |
|------|------|
| 대상 | `/Users/dotype/Projects/solsol-brand/app/` (신규 앱, 37 페이지) |
| 기준(SoT) | `docs/validation/00_화면목록.md §3.3 BR01`(39화면) · `03_brand-site.md` · `05_정책설계서.md` · 1px 기준선 = `solsol-brand/mockup/app/pages/*.vue` |
| 검증자 | QA (검증 전담 — 코드 무수정) |
| 검증일 | 2026-07-01 (KST) |
| 스택 | Nuxt 4.4.8 · @nuxt/ui 4.9.0 · tailwind 4.3 |
| 빌드 | `pnpm build` **PASS** (실행 확인 — dist 생성, ✨ Build complete) |
| 무수정 확인 | `mockup/**` git 변경 0 · solsol-mng `docs/validation/**` git 변경 0 (확인 완료) |

---

## 1. 화면ID 커버리지 매핑 (SoT BR01 39화면 vs 구현 37페이지)

> SoT 39 = 실앱 이관 37 + 카탈로그성 2 제외(프로덕트 미설계·데모보기/주요기능 실사이트 대체).

| SoT 화면ID | 화면명 | 구현 페이지 | 상태 |
|-----------|--------|-------------|------|
| S-BR01-0101-001 | 메인(랜딩) | index.vue | 있음 |
| S-BR01-0102-001 | 플랫폼 소개 | platform-intro.vue | 있음 |
| S-BR01-0103-001 | 프로덕트 | — | **의도적 제외**(미설계·빈 GNB) |
| S-BR01-0104-001 | 데모보기 | — | **의도적 제외**(실사이트 대체) |
| S-BR01-0105-001 | 주요기능 소개 | — | **의도적 제외**(실사이트 대체) |
| S-BR01-0301-001 | 회원가입 Free | signup-free.vue | 있음 |
| S-BR01-0301-002 | 회원가입(동의 통합폼) | signup.vue | 있음 |
| S-BR01-0301-003 | 회원가입 Free 완료 | signup-done.vue | 있음 |
| S-BR01-0302-001 | 로그인 | login.vue | 있음 |
| S-BR01-0302-002 | 비밀번호 재설정(인증메일) | password-reset.vue | 있음 |
| S-BR01-0302-003 | 새 비밀번호 설정 | password-new.vue | 있음 |
| S-BR01-0401-001 | 내 사이트 만들기 | my-site-create.vue | 있음 |
| S-BR01-0401-002 | 내 사이트 관리(목록) | my-sites.vue | 있음 |
| S-BR01-0501-001 | 공지/소식 목록 | news.vue | 있음 |
| S-BR01-0501-002 | 공지/소식 상세 | news-detail.vue | 있음 |
| S-BR01-0601-001 | 가격(요금제 main) | pricing.vue | 있음 |
| S-BR01-0601-002 | 유료플랜 구매/업그레이드 | pricing-purchase.vue | 있음 |
| S-BR01-0601-003 | 결제 완료(최초) | payment-done.vue | 있음 |
| S-BR01-0601-004 | 결제 완료(업그레이드) | payment-done-upgrade.vue | 있음 |
| S-BR01-0601-005 | 결제 실패 | payment-fail.vue | 있음 |
| S-BR01-0701-001 | 문의하기 | contact.vue | 있음 |
| S-BR01-0701-002 | 문의 접수 완료 | contact-done.vue | 있음 |
| S-BR01-0702-001 | 문의 내역 목록 | contact-history.vue | 있음 |
| S-BR01-0702-002 | 문의 내역 상세 | contact-history-detail.vue | 있음 |
| S-BR01-0801-001 | 이용상품 정보 | my-product.vue | 있음 |
| S-BR01-0801-002 | 사용 연장하기 | my-product-extend.vue | 있음 |
| S-BR01-0901-001 | 계정관리(계정정보) | account.vue | 있음 |
| S-BR01-0901-002 | 결제 이메일 변경 | account-email.vue | 있음 |
| S-BR01-1001-001 | 결제 내역 | billing.vue | 있음 |
| S-BR01-1101-001 | 이용약관 | terms.vue | 있음 |
| S-BR01-1101-002 | 무료약정상품 이용약관 | terms-free.vue | 있음 |
| S-BR01-1101-003 | 유료약정상품 이용약관 | terms-paid.vue | 있음 |
| S-BR01-1101-004 | 개인정보처리방침 | privacy.vue | 있음 |
| S-BR01-1101-005 | 마케팅 정보 수신 동의 | marketing-consent.vue | 있음 |
| S-BR01-9001-001 | 시스템 에러 | error-system.vue (+ app/error.vue 실핸들러) | 있음 |
| S-BR01-9001-002 | 404 | not-found.vue (+ app/error.vue 실핸들러) | 있음 |
| S-BR01-9001-003 | 네트워크 연결 오류 | network-error.vue | 있음 |
| S-BR01-9001-004 | 서비스 긴급점검 | emergency-maintenance.vue | 있음 |
| S-BR01-9001-005 | 서비스 정기점검 | maintenance.vue | 있음 |

**커버리지: SoT 대상 37/37 = 100%. 누락 0.**

**추가(SoT 외) 1건**: `pricing-light.vue` — 가격 LP 라이트 변형(목업 `pricing-light.vue` 대응). SoT BR01 미등재. 앱 내 진입 링크 없음(orphan route, 직접 URL만).

### 모달/팝업 6건(§3.3.2 + §3.3.3) 존재 확인

| _pu / 컴포넌트ID | 명 | 부모 | 구현 위치 | 판정 |
|-----|----|------|-----------|------|
| S-BR01-0301-002_pu01 | 인증코드 발송 PU(3분) | signup | signup.vue `v-if="codeSent"` (인라인 확장) | ⚠️ 존재하나 **오버레이 LPU 아님**(인라인 섹션) — DEF-04 |
| S-BR01-0302-003_pu01 | 새 비번 완료 컨펌 | password-new | password-new.vue:81 `v-if="doneOpen"` (fixed inset 모달) | 있음 |
| S-BR01-0401-001_pu01 | 도메인 중복 체크 결과 | my-site-create | my-site-create.vue:162 `v-if="checkOpen"` (fixed inset 모달) | 있음 |
| S-BR01-0801-001_pu01 | 구독 취소 완료 | my-product | my-product.vue:78 `v-if="showCancelConfirm"` (fixed inset 모달) | 있음(취소 컨펌+완료) |
| S-BR01-0901-002_pu01 | 결제 이메일 인증코드 발송 PU(3분) | account-email | account-email.vue `verified` 단계 게이트 (인라인 단계) | ⚠️ 존재하나 **오버레이 LPU 아님**(인라인 단계) — DEF-04 |
| S-BR01-C01 | 약관 상세보기 모달(공유 LPU) | signup·my-site-create | **없음** — 약관 항목 chevron이 `/terms` 등 전체 페이지로 NuxtLink 이동 | DEF-03 |

---

## 2. 1px verbatim 대조 결과 (핵심)

전 37페이지 `<template>` 를 대응 목업과 diff(요소명 스왑·동적바인딩 정규화 후 잔차 분석).

**결론: 좌표/px/hex색상/클래스토큰/SVG path 훼손 0건.** 모든 잔차는 아래 4개 의도적 변경으로 100% 설명됨:
1. `div`/`span`/`button`/`a` → `NuxtLink` (네비게이션 배선) — **class/style 문자열 동일 보존 확인**.
2. 정적 텍스트 → `v-model`/`{{ }}`/`v-if` (mock 데이터 바인딩) — 렌더 산출 동등.
3. 신규 빈/에러/완료 상태 추가(9축 상태) — 예: contact-history-detail 문의 미발견 상태.
4. `contact.vue` 목업의 가짜 `<div>` 입력영역 → 실제 `<textarea>` (기능 폼 승격, placeholder 보존).

- **우선 대상(landing/my-sites/pricing/pricing-light/terms/signup)**: 전부 verbatim 정합(위 4유형 외 차이 0).
- **my-sites `<style>` 복원**: 목업 `<style>` 누락 이슈를 실앱이 정본 `SsolSsol My Sites.dc.html <style>` 블록으로 복원(주석 명시). 템플릿 class 사용과 CSS 자기정합 확인. **정합(통과)** — 단 `.dc.html` 원본은 본 검증 트리에 미존재하여 원본 대조는 불가(핸드오프 소스). 
- **terms/privacy/marketing/terms-free/terms-paid**: 본문 전사 대신 `app/data/legal.json` SoT 렌더(`v-for sections`). 05 M-6 "JSON SoT 렌더·화면 전사 금지" 정합. legal.json 5키(terms/terms-free/terms-paid/privacy/marketing) 존재·섹션 채움 확인(terms-free 3섹션·terms-paid 5섹션).

---

## 3. 9축 점검 요약

| 축 | 결과 | 비고 |
|----|------|------|
| 존재 | PASS | 37/37 페이지 존재·빌드 통과 |
| IA/라우팅 | PASS | 전 NuxtLink 타깃(24종 + 동적 news-detail/contact-history-detail) 실재 페이지로 resolve. 깨진 링크 0 |
| 상태(빈/로딩/에러/성공) | PASS(경미 예외) | 빈상태(my-sites/news/contact-history), 에러(error.vue statusCode 분기), 완료(payment/signup/contact) 구현. |
| 공통컴포넌트 | PASS | BrandCanvas 37/37 사용. GNB/Footer 페이지별 인라인이나 클래스·좌표 일관(공유 컴포넌트 미추출은 목업 구조 답습). |
| 마스킹(PII) | PASS | 카드번호 `신한카드 **** 1234` 마스킹(useBilling). 비밀번호 `••••••••`. |
| 카피(SoT 문구) | PASS | 약관/개인정보/마케팅 = legal.json SoT. 화면 문구 목업 verbatim. |
| 디자인토큰 | PASS | #ED1B23(브랜드 레드)·#7954C6(플랜 배지) 등 목업 hex 보존. |
| 반응형 | 미검증(라운드1 정적) | 목업이 고정 px(1920) 기반 → 반응형은 목업 baseline 자체가 데스크톱 고정. 라운드2 동작검증 대상. |
| 인터랙션 | PASS(mock) | 폼(signup 인증/약관동의)·모달(계정삭제·구독취소·도메인체크)·필터(news 카테고리) mock 동작. |

---

## 4. 05 정책 · PII/동의 흐름 정합

- **계정삭제 이중게이트(P-AUTH-04)**: account.vue — 동의 체크(`deleteAgreed`) **+** 비밀번호 재확인(`deletePassword`) 이중 게이트 확인. **정합**.
- **이메일 변경 인증**: account-email.vue — `idle→codeSent→verified→done` 단계, 변경완료 버튼 `:disabled="!verified"` 게이트. **정합**.
- **마케팅 동의**: marketing-consent.vue — 토글 저장(`saveProfile marketingAgreed`), 본문 legal.json SoT. **정합**.
- 05 확정 6건(M-1 무료체험 미운영·M-2 RBAC·M-3 크레딧·M-4/M-5 알림·M-6 약관 JSON) 중 BR01 직접 관련 = **M-1**(즉시 결제·체험단계 없음 → signup/pricing에 14일 체험 UI 없음, 정합)·**M-6**(약관 JSON 렌더, 정합). 나머지는 Admin/Front 도메인으로 BR01 무관.

---

## 5. 결함표

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|--------|--------|--------|------|---------|------|
| DEF-01 | S-BR01-0601-002 | verbatim/인터랙션 | **중** | `pricing-purchase.vue:105-106` 에 목업에 없는 "결제 실패 시나리오 (검증용)" 보조 버튼이 **화면에 상시 노출**. 1px 기준선(mockup/pricing-purchase.vue) 미포함 요소. | `mockup/app/pages/pricing-purchase.vue`(해당 버튼 없음) · 00_화면목록 §3.3(verbatim 원칙) | 화면 노출 버튼 제거하고 실패 시나리오는 쿼리파라미터(`?fail=1`) 또는 `onPay(true)` 개발용 트리거로 대체(비노출). |
| DEF-02 | S-BR01-0702-002 | IA/라우팅(보안) | **중** | `/contact-history-detail` 이 미들웨어 PROTECTED 미등록(`01.require-auth.global.ts` 는 목록 `/contact-history` 만 보호). 비로그인이 상세 URL 직접 진입 가능. | `03_brand-site.md §1 IA`(마이페이지군=로그인 후 진입) · 미들웨어 주석("새 마이페이지 경로 추가 시 PROTECTED 등록") | PROTECTED 배열에 `/contact-history-detail` prefix 추가(담당: frontend-developer). 목록만 보호는 정보노출 갭. |
| DEF-03 | S-BR01-C01 | 존재/공통컴포넌트 | **중** | 공유 약관 상세보기 모달(C01, LPU)이 미구현. signup·my-site-create의 약관 항목 chevron이 모달 대신 `/terms`·`/privacy`·`/marketing-consent` 전체 페이지로 NuxtLink 이동. (목업도 모달 없음 → 목업 baseline 자체 갭) | `00_화면목록 §3.3.3`(C01 약관 상세보기 모달 LPU) · `03_brand-site.md §회원가입 약관 상세보기(공통)` | 목업이 baseline이므로 즉시 verbatim 위반 아님. **SoT-목업 갭**으로 오너/기획 판정 필요: (a) C01 모달 신설 or (b) SoT를 "페이지 이동"으로 개정(둘 중 택1, 불일치 해소). |
| DEF-04 | S-BR01-0301-002_pu01 / S-BR01-0901-002_pu01 | 존재/UI타입 | **하** | 인증코드 발송 PU가 SoT상 LPU(오버레이 팝업)이나 구현은 인라인 확장 섹션(signup `v-if="codeSent"`)·인라인 단계(account-email `verified`). 목업 구조 답습(목업도 인라인). | `00_화면목록 §3.3.2`(_pu01 UI타입=LPU, p034/p134) | 목업 baseline 정합이므로 verbatim 통과. SoT UI타입(LPU) vs 구현(인라인) 표기 불일치는 기획 확인 후 SoT 주석 정정 or 라운드2에서 LPU화 결정. 기능(3분 유효·발송·검증)은 동작. |
| DEF-05 | pricing-light | 커버리지 | **하** | SoT BR01 미등재 페이지 `pricing-light.vue` 존재(추가). 앱 내 진입 링크 없음(orphan). | `00_화면목록 §3.3`(pricing-light 없음) | 목업 대응물 존재하므로 유지 가능. SoT에 "가격 라이트 변형"으로 등재하거나, 미사용이면 라우트 정리 판정(기획). |
| DEF-06 | S-BR01-0601-002 | 인터랙션 | **하** | my-product/my-sites가 `/pricing?upgrade=1` 로 진입시키나 pricing.vue가 `upgrade` 쿼리를 소비하지 않음(업그레이드 모드 미분기·일할 변형 없음). 목업도 미소비 → verbatim 정합. | `00_화면목록 §3.3`(0601-002 "플랜 업그레이드·일할 변형") | mock 단계 허용. 백엔드 실연동 라운드에서 upgrade 모드/일할 계산 배선(담당: frontend-developer + api). |

**※ 그룹C billing summary 카드 미표시** = 목업에 요약카드 없음 → 구현도 없음. **정합(통과, 결함 아님)**.
**※ 그룹A news-detail** = 리치본문 `v-html` 데이터화·데모버튼/검색창 없음 → 목업에 없음 확인. **정합(통과, 결함 아님)**.

### 심각도별 집계
- **상(blocker): 0건**
- 중(major): 3건 (DEF-01, DEF-02, DEF-03)
- 하(minor): 3건 (DEF-04, DEF-05, DEF-06)

---

## 6. 종합 판정

## GO (조건부)

- **종료조건(❌'상' 0건) 충족** → 게이트 **GO**.
- 1px verbatim 좌표/색상/클래스 훼손 0, 커버리지 100%, 빌드 PASS, PII 이중게이트·인증게이트·마스킹 정합.
- 단, 중(major) 3건은 **배포 전 처리 권고**:
  - **DEF-01(결제 실패 버튼 노출)**: verbatim 위반 — 화면 노출 제거 필수. 최우선.
  - **DEF-02(상세 페이지 미보호)**: PII 정보노출 갭 — security-reviewer 공유 권장. PROTECTED 등록.
  - **DEF-03(C01 모달)**: SoT-목업 갭 — 기획/오너 판정(모달 신설 vs SoT 개정).
- 하(minor) 3건은 라운드2(동작·백엔드 연동) 또는 기획 확인으로 이월 가능.

### 수정 우선순위
1. DEF-01 (frontend-developer) — 결제 실패 버튼 비노출화(`?fail=1` 트리거).
2. DEF-02 (frontend-developer + security-reviewer) — `/contact-history-detail` PROTECTED 등록.
3. DEF-03 (기획/오너 판정 → frontend-developer) — C01 모달 신설 or SoT 개정.
4. DEF-04·05·06 (기획 확인 후 라운드2 반영).

### 검증 범위 주석
- 라운드1 = 정적(정본·1px·9축·정책) 검증 + 빌드 실행. **동작(런타임 플로우)·반응형·접근성 키보드/포커스 심층**은 라운드2(dev 서버 기동) 대상.
- `mockup/**`·`docs/validation/**` 무수정(코드 무수정). 빌드는 `.nuxt`/`dist` 갱신만.
