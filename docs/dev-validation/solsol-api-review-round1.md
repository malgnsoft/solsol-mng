# solsol-api 검토 라운드 1 — 백엔드팀 이관용 결함표

> 총괄(chief) 오케스트레이션 검토(구현 미수정). 렌즈: `api-developer`(완성도·계약·DB·연동준비도) + `security-reviewer`(라이브 보안). 사용자 결정 = **검토 보고만·조치 보류**(수정 주체·시점은 백엔드 오너 결정).

- **일시**: 2026-07-01 (KST)
- **대상**: `solsol-api` (Hono+Drizzle+Aurora MySQL, schema-per-tenant) · 라이브 **https://solsol-api.malgnsoft.workers.dev** (`/health` OK · Aurora 8.0.42 실연결) · git 미초기화(버전관리 없음)
- **정본**: `docs/validation/06_API계약.md`, `docs/data-model/ERD.md`

## 종합 판정
- **구현 완성도 높음** — 사용자단 15 + 관리자단 12 라우터(관리자 ~256 메서드), 대부분 실 Drizzle 쿼리. 스텁=아바타 501 1건. 관리자단 **3중 게이트**(`requireAuth→requireUserType('staff')→roleGuard(menuKey)`) 일관.
- **관리자단 실연동은 현재 불가** — 로그인 blocker(A·B) 미해소. 로그인만 뚫리면 **조회형 12도메인 즉시 연동 가능**, 실행형은 staging-gate.
- **라이브 보안 조건부 NO-GO** — 신규 상급 F-1(CORS) 노출 중. 단 이전 3 blocker(/ops 무인증·refresh 노출·비밀글 열람)는 **실제 해소 확인**.

## A. 실연동 Blocker (상)
| # | 결함 | 위치 | 조치 |
|---|---|---|---|
| A | **로그인 role 매핑 버그** — `role='owner/instructor'`를 `user_type`(항상 `'staff'`)와 직접 대조 → 계약대로 role 전송 시 항상 ROLE_MISMATCH. owner/instructor는 `TB_ROLE`/`TB_USER_ROLE`에서 파생해야(members.ts 모델). 응답 `user.role`도 `'staff'` 오설정 | `src/routes/auth.ts:895~902` | role 검증·응답을 TB_ROLE 파생으로. `requireUserType('staff')` 게이트는 유지 |
| B | **관리자 계정 시드 부재** — `solsol_lms`에 staff `TB_USER`·`TB_USER_CREDENTIAL`·`TB_ROLE(owner/instructor)`·`TB_USER_ROLE`·`TB_ADMIN_PERMISSION`(메뉴 매트릭스) 시드 없음 → 로그인=UNREGISTERED, roleGuard=403 | `src/routes/ops.ts` seed 범위 | **dba 시드 마이그레이션**(owner=11메뉴 allowed/scope=all). 직접 DDL 금지 규칙 준수 |
| F-1 | **CORS 임의 Origin 반사 + `credentials:true`** — 라이브에서 `Origin: evil` 그대로 반사. refresh 쿠키 사용하므로 CSRF/자격증명 표면. §10 "해소" 주장과 달리 미해소 | `src/index.ts:59-65` | origin allowlist(운영 프론트·admin 도메인), 미허용 Origin ACAO 미반환. **즉시 핫픽스 권장(라이브)** |

## B. 중급 격차
| # | 결함 | 위치 |
|---|---|---|
| 경로 | 계약 `/api/auth/login` ↔ 실제 `/auth/login` 불일치 | `src/index.ts:158` |
| me/perm | 관리자 로그인 직후 자기 메뉴 권한 세트 받을 전용 엔드포인트 부재(타인 `users/:id/permissions`만) | admin/members |
| F-5 | `learning.use('*',requireAuth)`가 `/api`에 걸려 **공개 FAQ/게시판 401**(기능 회귀) | `src/index.ts` 마운트 · `learning.ts:38` |
| F-2 | 로그인 계정열거(UNREGISTERED vs MISMATCH 구분 코드) | `src/routes/auth.ts:860~892` |
| F-3 | 레이트리밋/브루트포스 방어 전무(`/auth/*`) — WAF/Rate Limiting 권고 | 전역 |
| F-4 | `/health/db`·`/health/db/grants` 무인증 정보노출(DB버전·스키마·GRANT) | `src/index.ts:86-135` |
| verdict | `/health/db` "solsol_master 없음" = **오탐**(옛 네이밍 기준). 실제 `solsol`+`solsol_lms` 적용·쿼리 실동작 | `src/index.ts:100~120` |

## C. 하급/기록
- F-6 `SECRET_ENC_KEY` 미설정 시 `TB_OAUTH_CONFIG` client_secret 평문 패스스루 → **프로덕션 키 주입 확인 필요**(dba/deployer).
- F-7 비밀댓글 `isSecret` 컬럼 부재로 no-op(현재 UI 미사용이면 영향 제한).
- staging-gate(의도된 실행 차단): commerce 환불·credits 충전·marketing 실발송·orders/subscriptions 실 PG → pending 응답.
- 초대/비번재설정/인증코드 **메일 발송 TODO**(토큰·코드 생성까지만).

## D. 양호 (근거 기반)
관리자 roleGuard 3단(서버 `TB_ADMIN_PERMISSION` 조회로 allowed/data_scope 강제) · PII 마스킹(members/commerce/settlement, 카드 last4·계좌 부분) · 비번 PBKDF2(salt·constant-time) · refresh 회전+재사용탐지·HttpOnly 쿠키 · 테넌트 격리(schema 이중검증·JWT tid/sch 교차) · IDOR 차단 · Drizzle 파라미터화(SQLi 안전) · 시크릿 미커밋·fail-closed · mock OAuth 프로덕션 비활성.

## E. DB 상태 판정
스키마 **적용됨**(`solsol` 마스터 + `solsol_lms` 테넌트, 쿼리 실동작·빈 배열 응답). "빈 DB"가 아니라 **구조 적용·관리자/콘텐츠 데이터 미시드** 상태. 프로덕션 호스트엔 매핑 테넌트 없어 모든 요청에 `X-Tenant: dev`(또는 `?tenant=`) 필수.

## F. 권장 조치 순서 (백엔드 오너 결정 대기)
1. dba: 관리자 시드 마이그레이션(staff 계정+credential+role/user_role+admin_permission 매트릭스).
2. api: 로그인 role 로직(TB_ROLE 파생)·응답 role 정정(Blocker A).
3. api: `/api/auth/login` 경로 정렬 + `/health/db` verdict 현행화 + F-5 공개경로 분리.
4. api: **CORS allowlist(F-1)**·계정열거 통일(F-2)·health/db 게이트(F-4), deployer: WAF 레이트리밋(F-3).
5. api: 관리자 `me/permissions` 접점 추가(프론트 부트스트랩용).
6. 이후 solsol-admin은 조회형 12도메인부터 실연동, 실행형은 staging-gate 유지.
