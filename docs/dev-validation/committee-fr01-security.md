# FR01 검증 위원회 — 보안 위원 점검 결과 (round1)

| 항목 | 내용 |
|------|------|
| 검토 대상 | solsol 사용자단(FR01) `app/` + solsol-api 라이브(`https://solsol-api.malgnsoft.workers.dev`, APP_ENV=production 확인) |
| 검토 기준 | 05 정책설계서 M-2(RBAC)·C-6(마스킹) / 04 정책요약 AUTH·CMP-06 / 06 API계약 §0 |
| 검토 범위 | CORS·인증/세션·인가(EXC-06)·시크릿 노출·마스킹 연계 |
| 검토 방식 | 코드 리딩(수정 없음) + 라이브 프로브(preflight·인증·노출 라우트) |
| 판정 | **조건부 GO** (아래 운영 전 필수 보완 2건 이행 시 GO) |

> 코드 무수정 원칙 준수. 발견 시크릿/PII 값은 본문에 옮기지 않음(위치·유형만 기재).

---

## 1. 점검표

| # | 항목 | 판정 | 근거(라이브/코드) | 권고·심각도 |
|---|------|:--:|------|------|
| CORS-1 | allowlist 반사(solsol.pages.dev 허용) | ⭕ | preflight → `ACAO: https://solsol.pages.dev` + `Vary: Origin` | 유지 |
| CORS-2 | 미허용 Origin 거부(attacker.test) | ⭕ | preflight 204이나 **ACAO 미반환** → 브라우저 차단. `index.ts` origin() null 반환 | 유지 |
| CORS-3 | 와일드카드(`*`)+credentials 동시 사용 | ⭕ | ACAO를 요청 Origin 반사(정확 매칭·정규식 화이트리스트), `*` 미사용. credentials=true 안전 | **상 리스크 없음** |
| CORS-4 | allow-headers(authorization·x-tenant·x-site-host) | ⭕ | preflight 응답에 3종 반영 | 유지 |
| AUTH-1 | Bearer(ss_access) 필수·JWT 서명(HS256) | ⭕ | `middleware/auth.ts` verifyAccess, `lib/jwt.ts` SubtleCrypto HMAC-SHA256 | 유지 |
| AUTH-2 | exp 검증 | ⭕ | `verifyAccess` `claims.exp < now` → null | 유지 |
| AUTH-3 | 교차테넌트(tid/sch) 검증 | ⭕ | `auth.ts` `claims.tid!==tenant.id \|\| claims.sch!==tenant.schema` → 401 | 유지 |
| AUTH-4 | 스키마명 사용자입력 차단·SQLi 이중방어 | ⭕ | `tenant.ts` schema는 DB값만, `TENANT_SCHEMA_PATTERN` 검증. Drizzle 파라미터화 | 유지 |
| AUTH-5 | refresh 회전·재사용 탐지 | ⭕ | `/auth/refresh` 회전+revoke, 재사용 시 전 세션 무효화(`refreshReused`) | 유지 |
| AUTH-6 | refresh 해시저장(평문 미저장) | ⭕ | `hashRefresh`=SHA-256(raw+REFRESH_PEPPER), pepper 필수화(미설정 500) | 유지 |
| AUTH-7 | PW 해시 강도 | 🔺 | PBKDF2-HMAC-SHA256 100k iter+16B salt+constant-time(SHA-256 무salt 아님, 양호). bcrypt/argon2 대비 GPU 내성은 낮음 | **하** — 후속 argon2id 검토 |
| SESSION-1 | refresh 쿠키 HttpOnly·Secure·SameSite | 🔺 | `Set-Cookie ... HttpOnly; Secure; SameSite=None; Path=/auth` | **상(구조)** — 아래 SEC-A |
| SESSION-2 | 크로스도메인(.pages.dev↔.workers.dev) | 🔺 | 프론트/API가 **다른 등록가능도메인** → refresh 쿠키=서드파티. SameSite=None 필수이나 Safari ITP/Chrome 서드파티 쿠키 차단 시 refresh 단절 | **상(구조)** — 아래 SEC-A |
| SESSION-3 | CSRF(refresh) | 🔺 | refresh는 쿠키 단독 트리거 가능(CSRF 토큰 없음). 단 CORS로 응답 읽기 차단·행위=토큰 회전(피해 경미) | **중** — 아래 SEC-B |
| AUTHZ-1 | 보호 라우트 Bearer 없을 때 401 | ⭕ | 라이브 `/api/me/certificates` no-auth → 401, `/me` → 401 | 유지 |
| AUTHZ-2 | RBAC 서버 강제(M-2) | ⭕ | `roleGuard(menuKey)` TB_ADMIN_PERMISSION allowed/status 검증+data_scope 주입(관리자단). 사용자단은 learner 단일 | 유지 |
| AUTHZ-3 | IDOR(소유권) | ⭕ | `/me`는 JWT `sub`로만 조회(경로 id 미사용). 마스킹 `isSelfRequest(sub,ownerId)` | 유지 |
| SEC-1 | 응답/에러 시크릿·내부정보 노출 | 🔺 | onError 예상외 에러 은폐(⭕). **그러나** `/health/db`·`/health/db/grants` 공개 노출 | **중** — 아래 SEC-C |
| SEC-2 | refreshTokenHash 응답 노출 | ⭕ | `/ops/sessions`도 존재여부 bool만. 어느 응답에도 해시/원문 미포함 | 유지 |
| SEC-3 | 프론트 access 토큰 저장(XSS) | 🔺 | `useApi.ts` access를 localStorage(`ss_access`) 저장 → XSS 시 15분 토큰 탈취 가능(refresh는 HttpOnly라 보호) | **중** — 아래 SEC-D |
| SEC-4 | /ops 운영도구 프로덕션 게이트 | ⭕ | 라이브 `/ops/verify`·`/ops/sessions`·`POST /ops/migrate` 모두 403. reset/seed류 prod 무조건 차단 | 유지 |
| SEC-5 | 시드/mock 프로덕션 차단 | ⭕ | mock provider APP_ENV=production 거부, seed-admin PW=env 주입(하드코딩 없음) | 유지 |
| MASK-1 | 카드/비번/인증코드 응답 미포함 | ⭕ | `/me` 응답에 passwordHash·refresh·카드 없음. email-code/issue는 `expiresIn`만(코드 원문 미반환). reset-request 항상 동일 200(계정열거 차단) | 유지 |
| MASK-2 | C-6 본인 비마스킹/카드 부분마스킹 | ⭕ | `masking.ts` isSelf 분기, `maskCard` 뒤4자리 | 유지 |
| RATE-1 | 로그인 브루트포스 방어 | 🔺 | 라이브 3회 오류 모두 401·락아웃/지연 없음(PBKDF2 100k가 유일 코스트). IP 레이트리밋 부재 | **중** — 아래 SEC-E |
| RATE-2 | 재설정메일 발송제한(AUTH-07 10회/10분) | 🔺 | 라이브 reset-request 3연속 200, send-count 스로틀 미구현 | **중** — 아래 SEC-E |
| RATE-3 | 이메일코드 검증 시도상한 | ⭕ | `EMAIL_CODE_MAX_VERIFY=5` 초과 시 코드 무효화 | 유지 |

범례: ⭕ 충족 / 🔺 부분·리스크 / ❌ 미충족

---

## 2. 주요 발견(위협→영향→근거→권고→심각도)

### SEC-A. refresh 쿠키 크로스도메인(서드파티) — 상(구조 리스크)
- 위협/영향: 프론트(`*.pages.dev`)와 API(`*.workers.dev`)가 서로 다른 등록가능도메인 → refresh 쿠키가 **서드파티 쿠키**. Safari ITP·Chrome 서드파티 쿠키 제한 환경에서 쿠키 미전송 → **세션 갱신(자동 로그인 유지) 단절**. 보안 침해라기보다 신뢰성·세션 지속성 리스크.
- 근거: `routes/auth.ts setRefreshCookie` `SameSite=None; Secure; Path=/auth`; 라이브 API 오리진 = workers.dev.
- 권고(→ api-developer / 오너 결정): ① 운영 시 **API를 프론트와 동일 상위도메인 서브도메인**(예: `api.<서비스도메인>`)으로 배치 → SameSite=Lax/Strict 가능·서드파티 회피. ② 또는 커스텀 도메인 매핑 전제로 go-live. 현재 `pages.dev↔workers.dev` 조합은 **운영 정식 도메인 미확정**일 때의 임시 구성임을 오너 확인 필요.

### SEC-B. refresh CSRF 토큰 부재 — 중
- 위협/영향: SameSite=None이라 타 사이트가 `POST /auth/refresh`를 쿠키와 함께 유발 가능. 다만 CORS가 응답 본문 읽기를 차단하고 행위는 토큰 회전에 그쳐 실질 피해 경미(로그인 세션 강제 회전 정도).
- 권고(→ api-developer): SEC-A에서 동일도메인+SameSite=Lax로 전환되면 자연 해소. 크로스도메인 유지 시 refresh에 double-submit CSRF 토큰 또는 Origin 화이트리스트 재확인 추가 검토.

### SEC-C. 진단 라우트 공개 노출(/health/db, /health/db/grants) — 중
- 위협/영향: **인증·테넌트 게이트 없이 공개**. 라이브에서 DB 스키마명(solsol/solsol_lms)·MySQL 버전(8.0.42)·**DB 계정명 및 GRANT 전문(ALL PRIVILEGES … WITH GRANT OPTION)** 노출 → 정찰 정보 제공. 시크릿 값 자체는 아니나 공격 표면 파악을 돕는 내부 메타데이터.
- 부수 발견(→ dba): GRANT 결과상 앱 DB 계정이 `ALL PRIVILEGES WITH GRANT OPTION` 보유 → 최소권한 원칙 위배(앱 계정은 DROP/GRANT 불필요). 별도 하드닝 권고.
- 근거: 라이브 `GET /health/db/grants` 200 응답에 GRANT 3행 노출.
- 권고(→ api-developer): `/health/db`·`/health/db/grants`를 **APP_ENV=production에서 차단(또는 OPS_SECRET 게이트)**. `/health`(살아있음 확인)만 공개 유지.

### SEC-D. 프론트 access 토큰 localStorage 저장(XSS) — 중
- 위협/영향: XSS 발생 시 `localStorage.ss_access`(15분 access) 탈취 가능. refresh는 HttpOnly라 보호되어 피폭 반경은 access 만료(15분)로 제한.
- 근거: `useApi.ts getAccessToken/setAccessToken` localStorage.
- 권고(→ frontend-developer): 현행 유지 시 access TTL 15분·CSP 강화로 완화. 장기적으로 access를 메모리(in-memory) 보관 + 새로고침 시 refresh 재발급 패턴 검토. (blocker 아님)

### SEC-E. 공개 인증 엔드포인트 레이트리밋 부재 — 중
- 위협/영향: `POST /auth/login`·`/auth/password/reset-request`에 IP/계정 단위 레이트리밋·락아웃 없음. 로그인 온라인 브루트포스·재설정메일 스팸 가능(PBKDF2 100k가 부분 완화). AUTH-07의 "재설정 10회/10분 제한"이 코드 미구현.
- 근거: 라이브 login 3연속 401(지연·락아웃 무), reset-request 3연속 200.
- 권고(→ api-developer): Cloudflare Rate Limiting(WAF) 또는 앱단 IP/이메일 카운터로 login·reset-request·email-code/issue에 레이트리밋. AUTH-07 발송제한 구현.

### 양호 확인(강점)
- CORS: 정규식+정확매칭 화이트리스트, 미허용 Origin에 ACAO 미반환. **와일드카드+credentials 위험 없음.**
- 교차테넌트 방어(tid/sch), refresh 회전+재사용 탐지+PW변경 시 전세션 무효화, pepper·JWT_SECRET 필수화.
- 시크릿 하드코딩 없음(env/wrangler secret), onError 내부에러 은폐, /ops 프로덕션 게이트 정상 동작, mock provider 프로덕션 차단.
- 마스킹(C-6)·계정열거 방지(reset 동일응답)·이메일코드 시도상한 구현.

---

## 3. 보안 위원 판정: **조건부 GO**

인증·세션·인가·마스킹의 **핵심 통제는 견고**하며 상급(critical) 취약점(인가 우회·CORS 와일드카드+credentials·시크릿 값 노출)은 **발견되지 않음**.

### 운영 전 필수 보완(GO 조건) — 블로커 취급
1. **SEC-C**: `/health/db`·`/health/db/grants`를 프로덕션에서 차단/게이트 (공개 DB 메타·GRANT 노출 제거). → api-developer
2. **SEC-A**: refresh 쿠키 크로스도메인 구성 결정 — 운영 정식 도메인(API를 프론트 동일 상위도메인 서브도메인)으로 배치하거나, 서드파티 쿠키 차단 환경의 세션 단절을 감수할지 오너 결정. → api-developer + 오너

### 권고 보완(후속, 블로커 아님)
- SEC-E 레이트리밋(login·reset·email-code) + AUTH-07 발송제한 구현
- SEC-B refresh CSRF(크로스도메인 유지 시)
- SEC-D access 토큰 메모리 보관 검토
- AUTH-7 PW 해시 argon2id 전환 검토
- dba: 앱 DB 계정 최소권한화(ALL PRIVILEGES/WITH GRANT OPTION 회수)

### 오너 확인 항목
- 운영 도메인 토폴로지(SEC-A): `pages.dev↔workers.dev` 임시 구성 vs 커스텀 동일도메인 확정 여부.
- 서드파티 쿠키 차단 환경(Safari 등)에서 자동 세션 유지 미보장 수용 여부.

> 검토 근거는 라이브 프로브(2026-07-02 KST) + 코드 리딩. 코드 무수정. 결함은 담당(api-developer·frontend-developer·dba)에 위임, 보완 후 재검토.
