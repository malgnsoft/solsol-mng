# brand-admin — 검증 라운드3 (세션③ · 목업 회귀 + 중/하 시정)

| 항목 | 내용 |
|------|------|
| 대상 | `/Users/dotype/Projects/solsol-brand-admin/app/**` · `server/utils/mock` (목업 모드) |
| 기준(SoT) | `docs/validation` BA01 · brand-admin-round1·2 |
| 담당 | 임관개(admin, 회귀+시정) · 오품관(qa, 검증) · 배보검(보안 렌즈) |
| 검증일 | 2026-07-02 (KST) |
| 빌드 | `pnpm typecheck` **EXIT 0** · `pnpm build` **PASS** |
| 무수정 확인 | brand-api 변경 0(mtime 교차확인) · `docs/validation`·`_ledger.md` 변경 0 · 실전환(NUXT_API_BASE) 미설정(목업 유지) · 커밋/배포 없음 |
| 제약 | 크레딧 조정=금전 원장 → 실전환은 **레인① 운영자 시드 + SEC-1** 후. 이번 세션은 목업 안전지대만. |

---

## 1. 목업 회귀 (A-4) — 전체 PASS · blocker(상) 0

| 항목 | 결과 |
|------|------|
| 페이지 라우팅(24) · 비인증 302 fail-closed | PASS |
| RBAC 게이트 — support 이하 mutation BFF 메서드 선차단 · 계정열거 방지 | PASS |
| 목업 폴백 무손상(apiBase 미설정 시 도메인 503 + 목업 렌더) | PASS |
| Phase1 5EP 화면 UI 상태·입력검증 | PASS |

## 2. 발견 결함 → 시정 결과 (웨이브3)

| ID | 심각도 | 요약 | 상태 | 근거 |
|----|--------|------|------|------|
| CRED-UI-1 | 중 | 크레딧 debit 잔액초과 시 음수 미리보기 무경고 | **해소** | `credits/[siteId].vue` `isOverDebit` → 버튼 비활성 + 경고 + `validateAdjust` 이중차단. 백엔드 원자성(SEC-1) gated 불변, UI 방어만. |
| AUTH-SSR-1 | 중 | SSR 세션 미복원 → 새로고침/딥링크 시 로그인 튕김 | **해소** | `auth.ts` `restore()` `$fetch`→`useRequestFetch()`. dev 실측: 쿠키 有 SSR 200 유지 / 무쿠키 302 fail-closed 유지. |
| IMPORT-DUP-1 | 하 | 자동임포트 중복 export 충돌(billingMock↔statusLabels 등 14건) | **해소** | statusLabels 정본 단일화(+subscriptionMock 동종결함). 소비 4페이지 import 경로 이동. 경고 전량 소거·런타임 불변. |
| MOCK-PERM-1 | 하 | mock `ALL_MENU_KEYS` `notices` 누락(10키↔real 11키) | **해소** | `mock/index.ts` notices 추가, real permissions 패리티 회복. |

## 3. blocker(상) 검산

- **세션 변경분 상(blocker) = 0건.** QA round2 8/8 PASS.

## 4. 잔여 (보류·gated)

- **NOTICE-XSS-1** `[하→재판정 대상]` — `notices/edit.vue` 공지 미리보기 `v-html`(운영자 신뢰 컨텍스트). 이 콘텐츠가 **brand-front 사용자단에 노출될 경우 저장형 XSS 표면**. → brand-front 렌더/sanitize 정책과 **함께 결정 필요, 실연동 전 심각도 재판정 필수**(상 승격 가능). 이번 세션 보류(수정 안 함).
- **실전환 요망 6지점**(NUXT_API_BASE·시드 의존): 크레딧 조정 · CS 상태변경/답변 · 공지 CRUD 업스트림 매핑 · 통계 분포차트(real도 mock 상수) · BFF 재인가 실경로 재확인 · `NUXT_SESSION_SECRET` 필수. → **레인① 운영자 시드 + SEC-1** 후 실배선.

## 5. 소유경계 관측 (분리 필수)

- `server/api/admin/[...path].ts` · `server/utils/adapt.ts` = **prior "useRuntimeConfig 전환 미커밋"**(이번 세션 미변경). brand-front 세션 커밋에 혼입 금지 — prior/① 트랙에서 별도 처리.
