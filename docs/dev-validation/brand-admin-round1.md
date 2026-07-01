# brand-admin (solsol-brand-admin) 개발 검증 — Round 1 + 보완

> 대상: 쏠쏠 **플랫폼 운영자 백오피스** (solsol-brand-admin) Phase 0 — 뼈대 + 핵심 4도메인(사이트·회원·요금제/구독·결제), 전부 목업 데이터.
> 정본: solsol-brand-admin `docs/DESIGN_SPEC.md` §2(화면목록 SoT) · solsol-api `db/migrations/000_master.sql`(마스터 스키마) · solsol-mng `docs/validation/05_정책설계서.md`.
> 검증일 기준: 2026-07-01(KST). 검증 폴더(`docs/validation/`)는 무수정.

## A. 커버리지 (SoT §2 Phase 0 = 17화면 + 모달 3)

| 상태 | 수 | 비고 |
| --- | --- | --- |
| 있음(매핑) | 17 본화면 + 3 모달 | 100% 구현, 스텁 잔존 0 |
| 누락 | 0 | — |
| 목업에만(추가) | 0 | restricted는 SoT 포함(admin 레이아웃) |

화면ID: S-BA01-0001-001 로그인 · 0002-001 권한없음 · 0100-001 대시보드 · 0201-001/002(+_pu01) 사이트 · 0301-001/002 회원 · 0401-001(+_pu01)/002 요금제 · 0501-001/002(+_pu01) 구독 · 0601-001 청구서 · 0602-001/002 결제.

## B. Round 1 결함표 (게이트 3종) — 판정: **HOLD**

| 화면/파일 | 검증축 | 심각도 | 현상 | SoT근거 | 조치 |
| --- | --- | --- | --- | --- | --- |
| server/utils/session.ts | 보안(세션) | **상** | 세션 쿠키 HMAC 미서명(평문 base64), NUXT_SESSION_SECRET 미사용 → 위조·권한상승 | DESIGN §3 세션쿠키 서명 | ✅ 보완 |
| middleware/02.rbac + [...path] | 보안(RBAC) | **상** | 라우트 가드 미실행(dead code) + BFF 프록시 인가 누락(세션 존재만 확인) | DESIGN §3 RBAC 2중방어 | ✅ 보완 |
| server/api/admin/[...path].ts | 보안(인가) | **상** | 로그인만 하면 support도 전 도메인 API 임의호출(DELETE 포함) | DESIGN §3 | ✅ 보완 |
| S-BA01-0201-002 | 인터랙션 | **상** | uiStore.toast 렌더러 부재 → 운영자 액션 피드백 소실 | 05 C-5 단방향 토스트 | ✅ 보완 |
| S-BA01-0401-*/0201-* | 데이터정합 | **상** | 플랜 가격이 목업 3벌(plan/site/billing)에서 상충 | DESIGN §4 픽스처 1:1 | ✅ 보완 |
| S-BA01-0201-001 | 마스킹 | 중 | 사이트목록 소유셀러 이메일 원문(타 화면은 마스킹) | 표준 §7 / 05 C-6 | ✅ 보완 |
| 청구서↔구독상세 | 카피 | 중 | invoice_state 라벨 상충(open '발행' vs '미납') | DESIGN §4 | ✅ 보완 |
| 로그인↔회원목업 | IA/계약 | 중 | 목 계정 이메일 불일치·단일창구 미경유 | DESIGN §3 | ✅ 보완 |
| S-BA01-0501-001 | 인터랙션 | 중 | 구독목록 딥링크 route.query.plan 미반영 | — | ✅ 보완 |
| plans/subscriptions 목록 | 상태 | 중 | 로딩/빈상태 미처리 | 3축 | ✅ 보완 |
| S-BA01-0602-002 | 데이터정합 | 중 | 빌링키 site_id+100 오프셋 가정 → 다수 미표시 | DESIGN §4 | ✅ 보완 |
| 계정열거/XFF | 보안 | 중 | 로그인 실패코드 구분(계정열거)·XFF 무검증 전달 | — | ✅ 보완 |
| 대시보드·반응형·생테이블 | 상태/8축/4축 | 하 | KPI 하드코딩·테이블 overflow·상세 생테이블 | — | 일부 보완(D-10)/잔여 |

Round1 집계: **상 5 · 중 7 · 하 4** → 게이트 미통과(HOLD).

## C. 보완 라운드 (server ↔ app 병렬)

- **server (api-developer)**: 세션 HMAC-SHA256 서명·검증(Web Crypto, 운영 secret 미설정 시 503 fail-fast) / BFF 프록시 `resolveMenuKey`+`authorizeProxy` 인가(superadmin 통과·그외 permissions.allowed·미해석 deny·403) / 계정열거 단일코드(MISMATCH)·upstream code 보존 / XFF는 cf-connecting-ip만 신뢰.
- **app (admin-developer)**: `02.rbac.global.ts` 승격 / `AppToaster.vue` 신설·admin 레이아웃 마운트·토스트 채널 단일화 / `planMock.ts` 단일 SoT·site/subscription/billing 정합 / `statusLabels.ts` 라벨 통일 / 사이트목록 maskEmail·`mask.ts` maskIp / 목계정 .local 정합 / 딥링크·로딩/빈상태 / 빌링키 정규경로 / 대시보드 mock 파생.

## D. Round 2 재검증 — 판정: **GO** ✅

| 게이트 | 판정 | 근거 |
| --- | --- | --- |
| security | **GO** | 상 3건(세션HMAC·프록시인가·계정열거) 코드로 해소 확인. 잔여 중2(레이트리밋=인프라 TODO·백엔드 실패코드 정책)·하1(method 단위 RBAC). |
| qa (9축) | **GO** | 상 3건(토스트·RBAC·플랜값) 해소, 중/하 6건 반영, 17+3 커버리지 완전, 회귀 없음. 잔여 하2(D-3b 엔터프라이즈 협상가 표기·W-1 중복 재노출 WARN). |
| privacy | **GO** | 금융정보(카드/빌링키/토스키) 마스킹 견고. P1(이메일)·maskIp 보완. password_hash 타입 제외. |

**통합 검증**: `pnpm nuxt typecheck` exit 0 / TS 에러 0 · `pnpm build` 성공(1.26MB).

## E. 종합 판정: **게이트 통과(GO)** — ❌'상'(blocker) 0건

- 잔여 minor(하): D-3b(엔터프라이즈 연납 목업가=협상가 주석 필요), W-1(auto-import 중복 WARN·무해) → Phase 1 정리.
- **운영 배포 전 조건**(deployer 인계): ① `NUXT_SESSION_SECRET` 필수 설정 ② 로그인 엔드포인트 CF Rate Limiting ③ solsol-brand-api 로그인 실패코드 단일화(백엔드) ④ API 실연동(현재 mock 폴백).

## F. 참여자 활동내역

| 담당(역할) | 수행 |
| --- | --- |
| admin-developer | Phase 0a 스캐폴딩(설정·레이아웃·인증·공통컴포넌트·타입·menuMap·목업인프라) + 사이트·회원·요금제/구독 도메인 + app 보완(RBAC·토스트·플랜SoT·마스킹 등) |
| api-developer | 서버 BFF 보안 보완(세션 HMAC·프록시 인가·계정열거·XFF) |
| (결제 도메인 담당) | 청구서·결제 도메인 + 마스킹 |
| qa | 9축 검증 Round1/Round2 |
| security-reviewer | 보안 검토 Round1/Round2 |
| privacy-officer | 개인정보·마스킹 검토 |
