# 검증위원회 T5 — 보안 트랙(횡단) 결함표 · Round 01

| 항목 | 내용 |
|------|------|
| 라운드 | security-committee-r01 |
| 위원 | T5 보안 트랙(security-reviewer) |
| 대상 | solsol · solsol-admin · solsol-brand (프론트) / solsol-api · solsol-brand-api (백엔드) |
| 검증축(3-C) | 인증·세션 / 인가·RBAC / 시크릿 / 남용 |
| 방법 | 정적 grep·코드검토(무수정). 파괴적 API 호출 없음 |
| SoT | DEV_VALIDATION_PROCESS §3-C · 05 정책설계서 #3(RBAC) · 00 검증가이드 |
| 작성일 | 2026-07-02 (KST) |

> 코드 무수정 · 결함표 기록만. 시크릿 값 평문 미기재(위치·유형만). `_ledger.md` 미접촉(위원장 집계).

---

## 결함표

| 결함ID | 대상앱 | 축 | 심각도 | 현상(위치) | 근거 | 권고 | 상태 |
|---|---|---|---|---|---|---|---|
| SEC-cttee-r01-D01 | solsol-api | 시크릿/정보노출 | 중 | `/health/db` + `/health/db/grants` 무인증 공개 — DB 스키마명·MySQL 버전·`SHOW GRANTS`(DB 계정 권한) 반환 (src/index.ts:109-158) | brand-api는 동일 라우트에 OPS_SECRET 게이트+grants dev전용 적용(src/index.ts:92-107)했으나 solsol-api는 게이트 전무 → 공개 Worker에서 DB 토폴로지·계정권한 정찰 노출 | brand-api와 동일 게이트 이식(prod X-Ops-Secret, grants는 dev 전용) | open |
| SEC-cttee-r01-D02 | solsol-admin | 인증/우회 | 상 | demo-login 게이트 fail-open — `String(config.previewDemo)==='false'` 일 때만 404 (server/api/auth/demo-login.post.ts:29) | previewDemo 미설정/undefined 시 엔드포인트 활성. seed superadmin 자격증명으로 원클릭 관리자 로그인 → 인증 우회(전권). 게이트가 명시적 off에만 닫히는 default-open 구조 | default-deny 로 반전(명시 enable + APP_ENV!=='production' 이중가드), 프로덕션 배포 전 previewDemo=false 검증 | open |
| SEC-cttee-r01-D03 | solsol-brand-api | 인가/세션 | 중 | 비밀번호 재설정 토큰 재사용 방어 미구현 — 주석은 "iat 이전 발급 거부"라 명시하나 실제 코드는 passwordUpdatedAt 를 SELECT 만 하고 비교하지 않음 (src/routes/auth.ts A8 ~L655-671) | stateless reset 티켓은 서버 원장 없음 + 실제 1회성/iat 검사 부재 → 30분 TTL 내 동일 토큰 반복 사용(리플레이)해 비번 재설정 가능 | iat vs passwordUpdatedAt 비교 실제 구현 또는 1회성 토큰 저장소(nonce 소진) 도입 | open |
| SEC-cttee-r01-D04 | solsol-brand-api | 세션 | 중 | stateless refresh 서버측 revoke 원장 부재 — logout 은 쿠키만 클리어(src/routes/auth.ts A3), refresh JWT 는 14일 TTL 까지 유효 | 자기문서화된 한계(파일 헤더 L22-24). 토큰 탈취 시 진짜 로그아웃·전세션 무효화 불가 | TB_SESSION/블랙리스트 저장소 도입(실연동 전). solsol-api 의 세션 회전+재사용감지 모델 참고 | open |
| SEC-cttee-r01-D05 | solsol-api · solsol-brand-api | 남용 | 중 | `/auth/*` 레이트리밋 전무(grep 0건) — login/email-code·issue/password·reset-request 무제한 호출 가능 | login 브루트포스(PBKDF2로 지연 완화되나 계정잠금 없음), email-code/issue·reset-request 무제한 → 이메일 폭탄·발송비용 남용 | CF Rate Limiting/Turnstile 또는 앱레벨 IP·계정 카운터 + 발송 스로틀 | open |
| SEC-cttee-r01-D06 | solsol(사용자단) | 세션 | 중 | access token 을 localStorage 저장 (app/composables/useApi.ts:77, useAuth.ts:99 키 'ss_access') | XSS 발생 시 토큰 탈취 가능. refresh 는 HttpOnly 쿠키(양호)·access 15분 TTL 로 부분완화. solsol-admin 은 httpOnly 쿠키 사용(대조군) | access 는 메모리(변수) 보관 권고, 지속저장 지양 | open |
| SEC-cttee-r01-D07 | solsol-brand-api | 시크릿 | 하 | seed 기본 superadmin 비번 'solsol2026' 문서화 (src/db/seed.admin.sql:54) | 해시는 placeholder(REPLACE_WITH_*)라 현재 미작동 + "프로덕션 반드시 교체" 주석 존재 → 현재 위험 낮음(TEST-ONLY 표기 충족) | 실연동 시 실제 해시가 이 기본 비번으로 생성되지 않도록(교체 비번) 확인 | open |
| SEC-cttee-r01-D08 | solsol-api · solsol-brand-api | 인증 | 하(권고) | 비밀번호 해시 PBKDF2-SHA256 100k iter (auth.ts:202 / lib/password.ts:15) | salt+constant-time 비교로 구현 양호하나 OWASP 2023 권고(PBKDF2-SHA256 600k) 미만. Workers CPU 제약 트레이드오프 | 여력 내 iter 상향 또는 향후 argon2id/scrypt 검토 | open |
| SEC-cttee-r01-D09 | solsol-brand-api | 인증/무결성 | 하(현재)/실연동 상 | 토스 웹훅 서명검증 골격만(TODO staging-gate) (src/routes/webhooks.ts:47) | 현재는 서명 미검증 이벤트의 상태전이를 금지(dispatchEventStub L228 게이트)해 현재 위험 낮음. 실 결제 연동 시 위조 웹훅으로 결제/구독 상태 조작 가능 | 실 PG 연동 전 서명검증(헤더·인코딩 확정)+타임스탬프 window 구현 = 실연동 blocker | open |

---

## 확인된 양호 통제(positive controls)

- **교차테넌트 방어**: requireAuth 가 토큰 tid/sch 를 tenantResolver 결과와 대조(solsol-api middleware/auth.ts:59-63).
- **테넌트 스키마 SQLi 이중방어**: schema_name 은 DB값만 사용 + TENANT_SCHEMA_PATTERN 검증(middleware/tenant.ts:177).
- **IDOR/own 스코프**: me/orders 전 엔드포인트 소유권 검증(`order.userId!==sub→notFound`, billingKey 동일 — routes/me.ts:591,720,756). admin 라우트 roleGuard+data_scope 주입(middleware/roleGuard.ts).
- **계정열거 방지 통일**: login·reset-request 미존재/정지/불일치 동일 응답(solsol-api auth.ts:960-991,1201; brand-api auth.ts:419-429,619).
- **refresh 재사용 감지+전세션 무효화**(solsol-api auth.ts:794-811) · 이메일코드 시도 5회 상한(auth.ts:320,1151).
- **시크릿 위생**: 커밋된 .env/.pem/.key 없음(.dev.vars.example 만) · 코드 하드코딩 시크릿 grep 0건 · 코드/토큰/비번 응답·로그 미포함(`void code`, onError 내부정보 미노출).
- **CORS 화이트리스트**(임의 Origin 반사 금지, credentials) — 양 API 동일.
- **admin BFF**: access 토큰 httpOnly+Secure 쿠키(localStorage 아님) + 상태변경 same-origin CSRF 검사(solsol-admin login.post.ts).
- **ops/reset·domain-seed·seed-admin**: 프로덕션 무조건 차단, 시크릿 env 주입(solsol-api routes/ops.ts).

---

## 앱별 요약 · 판정

| 대상앱 | 상 | 중 | 하 | 판정 | 실연동 전 필수 조치 |
|---|---|---|---|---|---|
| solsol-api | 0 | D01,D05 | D08 | **CONDITIONAL** | D01(헬스 게이트)·D05(레이트리밋) |
| solsol-brand-api | 0 | D03,D04,D05 | D07,D09 | **CONDITIONAL** | D03(리셋토큰)·D04(세션revoke)·D05 / **D09는 실결제 go-live 시 blocker** |
| solsol-admin | **D02** | — | — | **NO-GO(prod)** | D02(demo-login default-deny) 수정+검증 전 프로덕션 배포 불가 |
| solsol(사용자단) | 0 | D06 | — | **CONDITIONAL** | D06(access 토큰 저장) |
| solsol-brand(사용자단) | 0 | 0 | 0 | **GO(mock)** | 아직 실토큰 미실장(mock) — 실연동 시 재검증 |

---

## 트랙 판정: **CONDITIONAL (blocker 1건: D02)**

- **현재 위험**: 대부분 mock/스캐폴드 단계 또는 게이트로 완화. 실동작 blocker 는 **D02(solsol-admin demo-login fail-open)** 1건 — config 의존이나 default-open 구조라 프로덕션 노출 시 관리자 전권 우회.
- **실연동 리스크(배포 전 해소 필요)**: D01(정보노출)·D03/D04(brand 세션·리셋)·D05(레이트리밋 공통)·D06(access 저장). D09 는 실 PG 연동 시점에 blocker 승격.
- **security 서명 조건**: D02 수정·검증 완료 시 solsol-admin 프로덕션 게이트 통과 가능. 그 외 앱은 위 '실연동 전 필수 조치' 반영 후 실연동 라운드 재검. 정적검증(빌드/타입체크)은 본 라운드 미실행(정적 코드리뷰 전용).

> 담당 위임(코드 수정): D01/D05/D08 → api-developer, D02/D06 → admin-developer·frontend-developer, D03/D04/D09 → brand-api 담당(api-developer), D07 → dba. 위원장이 _ledger.md 에 D02(상) 등재.
