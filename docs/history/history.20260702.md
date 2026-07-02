# 2026-07-02 — 검증 절차 단일정본 개정 + 리포트 취합·아카이브

> **한 줄 요약** — 검증 절차를 **단일 정본(`DEV_VALIDATION_PROCESS.md`)으로 전면 개정**(대상 매트릭스·단계 프로파일·데이터 5축·심각도 상/중/하·이월원장)하고, `docs/report/`의 미결 8종·검증위원회 8종을 **취합 3파일**로 정리 + 원본 16종을 `_archive/`로 형식통일 이관.

## 1. 검증 절차 단일정본 개정 (오너 확정 4결정 반영)
- `docs/DEV_VALIDATION_PROCESS.md` 전면 개정 — §1 적용대상 매트릭스(화면/계약 트랙·`solsol-mng` 비적용), §2 단계별 프로파일(목업/설계/스파이크/구현/실연동, WBS 8단계 정합), §3 화면 9축 + **데이터 5축** + 보안 상시 + 마스킹 3레이어, §4 심각도 **상/중/하** 성문화, §5 게이트(실연동 서명필수·blocker 0 강제), §6 결함표 표준 템플릿·네이밍, §7 이월 원장, 부록 A/B.
- `CLAUDE.md` 검증 절 축약(→PROCESS.md 링크), `docs/validation/06_API계약.md` 상단 **정본 격하 고지**(D1→Aurora, 오너 승인). 검토(오품관·최기획 조건부 GO) 지적 전건 반영.

## 2. 리포트 취합 · 아카이브
- **미결·막힌 사항**: 원본 8종 → `쏠쏠-미결취합-20260702.md` · `브랜드-미결취합-20260702.md`(6영역 분류).
- **검증위원회**: 원본 8종(R-VC1→r01→r02→r03 + 앱별 심화) → `검증위원회-통합보고서-20260702.md`(**open blocker 8건 NO-GO**).
- 원본 16종 → `docs/report/_archive/` 이동 + 파일명 통일(`미결보고-…` / `검증위원회-…`), `_archive/README.md` 인덱스. `_ledger.md` 링크 갱신.

## 3. 검증위원회 결함표 반영 (dev-validation)
- `dev-validation/`에 committee-r01/r02 결함표(FR01·AD01·BR01·security·privacy·data·api-contract·solsol-api·brand-api)·`_ledger.md`(open blocker 8) 반영.

## 산출물
- 문서: `docs/DEV_VALIDATION_PROCESS.md`·`CLAUDE.md`·`docs/validation/06_API계약.md`·`docs/report/*`(취합 3 + `_archive/` 16)·`docs/dev-validation/*committee*`·`_ledger.md`.
- 커밋 `39a5a1e` → `malgnsoft/solsol-mng` → Pages `solsol-mng` 배포.

## 4. WBS 구현(Step 7) 일정 스파이크 이후로 재조정
- 스파이크(Step 6, ~07-05) 이후 시작하도록 **구현(Step 7) 항목 중 07-06 이전 시작 13건을 07-06 시작으로 이동**(기간 보존 → 종료일 동일 delta 이동). 이미 07-06 이후(07-15·08-03) 시작분은 유지.
- `wbsData.ts`·`seed.sql`·라이브 D1(`step=7 AND start<'2026-07-06'` → 07-06 + julianday delta) 동기화. 커밋 `<이 커밋>` → Pages 배포.

## 5. 개발 세션 분할 계획 + 협업 규약 + 검증 정본 개정 메커니즘
- **세션 분할(오너 확정 B→A 단계적)**: `docs/DEV_SESSION_PLAN.md`(Phase B 3세션=공통 백엔드·데이터 spine + 쏠쏠 프론트 + 브랜드 프론트, 담당·책임 blocker·시작 프롬프트; 안정화 후 Phase A 2세션 축소) + `docs/DEV_SESSION_PROTOCOL.md`(전 세션 전달용: 편집 소유 경계·`_ledger` 허브 단독 기록·API 계약 프리즈·레인 카드·공통 금지). 기존 8분할 폐지.
- **검증 정본 개정 메커니즘**: `docs/validation_modified/` 신설 — 원본(`docs/validation/`) 무수정 보존, 개정은 **동일 파일명 완성본** + `_개정이력.md` **전후 기록**, **개정본 우선 권위**. `CLAUDE.md`·`DEV_VALIDATION_PROCESS.md`·`DEV_SESSION_PROTOCOL.md` 반영.
- (동봉) spine 세션의 `docs/data-model/*`(master.sql·ERD·README) 편집분 함께 커밋. 커밋 `b456066` → Pages 배포.

## 6. 구현 표준(3계층·데이터 정책) + 개발 지시 프롬프트 + 세션 네이밍 정정
- **구현 표준** `docs/IMPLEMENTATION_STANDARD.md` 신설(오너 확정) — **목업=가짜(하드코딩) 데이터로 디자인·기능 확인 / 실앱(사용자단·관리자단)=실 API+실 Aurora+샘플 데이터로 실 연동 확인**. 실앱 목 폴백엔 **`MOCK` 배지** 필수·게이트 종료조건 **배지 0건**(무음 폴백·미연동 은폐 금지). 유기적 연결=동일 화면ID·목업=디자인 SoT. §7 **개발 지시 프롬프트**(목업/실앱/샘플시드) 포함.
- **세션 네이밍 정정**: 쏠쏠·쏠쏠 브랜드=**풀스택**(사용자단+관리자단+백엔드), `backend-db`=공유 데이터 정본 단독 소유. `DEV_SESSION_PLAN`·`PROTOCOL`·`transcripts` 전면 정합(spine/프론트/①②③ 폐기).
- **`docs/transcripts/`** 일일 기록 체계(세션별 파일·시크릿 금지)·`validation_modified/` 개정 메커니즘은 §5 참조. `PROCESS`·`PROTOCOL`에 표준 링크 반영.
- (동봉) 병렬 세션 산출물: `data-model/*`(master.sql·ERD·tenant_template) + dev-validation 신규(backend-db-r01·brand-admin-round3·brand-site-round2 등). 커밋 `cc62013` → Pages 배포.

## 7. 쏠쏠 브랜드 세션 구현·검증 (목업·사용자단·관리자단 병렬 — 커밋·배포 없음)

> 총괄(chief) 대행·글로벌 팀 4단계·2 웨이브 병렬. IMPLEMENTATION_STANDARD 3계층·MOCK 배지·게이트 정합. 공유 master 정본·계약 무수정(backend-db 소유). 대화 기록=`docs/transcripts/20260702/solsol-brand.md`.

- **사용자단(`solsol-brand`)** — [TEST-ONLY] 인증번호 서버검증(A6) 원복(완화 하드코딩 0)·인증/쓰기 실연동 배선 + **MOCK 배지 6화면**(login·signup·my-sites·my-site-create·account·account-email), 공용 `useApiPost`/`useMockState`/`BrandMockBadge` 신설. BR01 목업 정리: **typecheck 7→EXIT0**(BrandCanvas·my-product-extend), 화면ID 태그(index=S-BR01-0101-001·my-sites=S-BR01-0401-002)·pricing-light 변형태그(기획 SoT 확정 필요). 실전환(폴백 제거)·결제류 미수행(gated).
- **관리자단(`solsol-brand-admin`)** — 중결함 3건 시정(QA-D1 원장 pageSize override·QA-D3 공지 published count·QA-D2 CS 이메일 날조 가드) + `AppModeBadge`(NUXT_API_BASE 미설정 시 상시 MOCK). 크레딧 조정 UI 실노출 미활성 유지. vue-tsc **EXIT0**.
- **백엔드(`solsol-brand-api` 앱층)** — CS(contact) 뮤테이션 2건 requireRole 게이트·가입 인증코드 TTL 600s·웹훅 rawPayload 마스킹(`maskWebhookPayload`)·공지 count SQL 정합 + **maskPhone mask-by-default**·**adjust idempotencyKey 필수화**(재전송 멱등 보존). tsc **EXIT0**. master 스키마·마이그레이션·`users.ts`·`credits.ts` 트랜잭션 로직 무수정.
- **검증 게이트(3렌즈)** — **PRV-cttee-r02-D01**(셀러 PII 마스킹) **GO/closed 권고**(공동서명·열람예외 미채택으로 강등 불요) · **SEC-1**(크레딧 조정) **조건부 GO**(`TB_SITE FOR UPDATE` 직렬화로 이중조정/차감 0 성립, uk 무관 / **실연동 배포는 backend-db 회신 2건 후**: uk 실 Aurora 실재·Hyperdrive 트랜잭션·FOR UPDATE origin 실측) · 목업 라운드 **BA01 GO / BR01 상 0**. 신규 medium(시정): adjust false-dedup·maskPhone passthrough.
- **오너 판정 3건(B-5) — 구현 완료**(총괄 권고 기본값 채택, 오너 번복 가능) — ① **color-contrast**: 회색 2단 토큰(`ink-muted`#595959 7:1·`ink-subtle`#8a8a8a)+`brand-link`#C8151C·primary `green`→`brand`(#ED1B23), 334+146곳 의미기반 치환·AA 충족(build·typecheck EXIT0). ② **모바일 반응형(권고 c)**: BrandCanvas 래퍼 zoom 리팩터 + `BrandPcRecommendBanner`·`BrandMobileNav` 신설, 우선 6화면군(로그인·회원가입·구매·에러5종=방식A / 가격·내사이트=GNB 트윈+오버라이드), 데스크톱 회귀0·모바일390 스모크(가로스크롤0·터치44). ③ **C01 약관모달=이미 구현완료(FIXED)**. hue는 K-4 확정 시 토큰값만 갱신.
- **잔여(오너/기획/backend-db)** — SEC-VC-01(verify-code, backend-db 코드원장)·PRV-B01 탈퇴 PII 파기정책(개인정보보호법)·운영자 시드·PG staging-gate·pricing-light SoT·C-2 문서충돌(00_화면목록 3분↔05 10분)·adjust 멱등키 brand-admin 형상일치(실전환 시).

### 산출물 (작업트리·미커밋·미배포)
- `solsol-brand`: `app/pages/{signup,account-email,pricing-light,index,my-sites,my-product-extend}.vue`·`app/components/{BrandCanvas,BrandMockBadge}.vue`·`app/composables/{useApiPost,useMockState,useAccount,...}` + (B-5) `app/app.config.ts`·`app/assets/css/main.css`·`app/components/{BrandPcRecommendBanner,BrandMobileNav}.vue`·`app/pages/{login,pricing,pricing-purchase,error-system,not-found,network-error,emergency-maintenance,maintenance,platform-intro}.vue`·`app/error.vue`.
- `solsol-brand-admin`: `server/api/admin/[...path].ts`·`app/pages/admin/{notices/index,cs/[id]}.vue`·`app/components/{common/AppModeBadge,admin/AdminHeader}.vue`.
- `solsol-brand-api`: `src/routes/admin/{contact,news,credits}.ts`·`src/routes/{auth,webhooks}.ts`·`src/lib/masking.ts`·`src/docs/endpoints.ts`.
- 기록: `docs/transcripts/20260702/solsol-brand.md`(프롬프트·대화). **커밋·푸시·배포 없음**(오너 "배포" 시 실행).

## 8. backend-db 세션 — 데이터 정본·6 blocker·스키마·샘플시드·계약·강사 RBAC (커밋·배포·실 DB 없음)

> 총괄 대행·글로벌 팀 4단계. 대화기록=`docs/transcripts/20260702/backend-db.md`. 결함표=`dev-validation/backend-db-{r01,r02,plan-r01,decisions-r01}.md`. **커밋·푸시·배포·실 DB 적용 없음.**

- **정본 단일화 + 6 blocker close (r01)** — 크레딧 **단일 TB_CREDIT 정본 확정**(architect)·**4자 동기**(master.sql=ERD=README=ORM, 기준선 `000_master.sql` 16테이블)·DAT-D01/D02/data-model-r03-D02·**SEC-1**(크레딧 조정 단일 tx+FOR UPDATE+INSERT-first 멱등)·**SEC-r02-D01**(/health/db prod 게이트)·**PRV-r02-D01**(셀러 PII 마스킹) 코드 close. 마이그 `002_credit_idem_null_free`. security⭕·privacy⭕·qa GO. W6 후속(파생잔액 직렬화·maskEmail 2자) + security 재서명⭕.
- **스키마 확장 (r02)** — **TB_SESSION 신설**(master 16→17·refresh 세션원장 SEC-3)+tenant 보강·`is_secret`(F-7·B13)·`creditLedgerId`→`credit_id` 정합. 마이그 `003_master_session`·`004_tenant_gaps`(GRANT·멱등·롤백). 데드락 락순서 교정(BDB-r01-D01)·brand `/doc` admin 34EP 보강(BDB-r01-D04). qa 데이터5축 GO.
- **샘플 데이터 시드** — `dev_master_seed`(389행)·`dev_domain_seed`(820행), 도메인×엣지 5종(빈목록·긴텍스트·마스킹대상·페이지네이션 초과 101>100·29>20·상태다양성 incl is_secret), 크레딧 원장 SUM=**293,300** 검산·멱등·실 PII 0. 실 DB 미적용(DBA env 미접속) — 적용은 `/ops`·mysql 경유 절차 문서화.
- **API 계약 발행** — solsol-api **223EP**·brand-api **77EP** `/doc`(Scalar) 프리즈 노트(②③ 인계·임의변경 금지). `totalPages` 보정.
- **DB 미결 실행계획**(`plan-r01`, 5웨이브)·**오너 결정 12건 상신**(`decisions-r01`).
- **강사 RBAC own-스코프 (r02 시도→r03 해소)** — 오너확정(강사=정산·주문·수강생 3종 own·마스킹 유지·조회전용) 구현. r02 1차(typ 기반)는 security NO-GO였으나 **근거가 스테일 주석 오독**(`auth.ts:325`)이었음이 확정 — **실제 토큰 typ=user_type**(강사=instructor, `auth.ts:1022`). **architect 정본 인증모델 확정**(user_type 3값 + TB_ROLE 파생) → **역할기반 재작성**(`lib/role.ts resolveEffectiveRole`·roleGuard scope 코드강제·서브강사 request-time 배제·me 게이트·AC-2 교차강사 누출 교정) → **security GO·privacy GO**(r03). D-01/D-03/D-04 close. 잔존 하/후속: operator scope fail-open(RBAC-OBS-1)·서브강사 members-read menu_key 분리(RBAC-MENU-1)·프론트 role 도메인 확장(②조율).

### 산출물 (작업트리·미커밋·미배포)
- `solsol-api`: `db/migrations/{002,003,004}`·`db/seed/{dev_master,dev_domain}_seed.sql`·`src/db/schema.master.ts`·`src/db/schema.tenant/*`·`src/index.ts`·`src/routes/admin/{credits,settlement,commerce,members}.ts`·`src/routes/auth.ts`·`src/docs/endpoints.ts`·`src/openapi.ts`.
- `solsol-brand-api`: `src/db/schema.master.ts`·`src/routes/admin/{users,credits}.ts`·`src/lib/masking.ts`·`src/docs/endpoints.ts`·`src/openapi.ts`.
- `solsol-mng`: `docs/data-model/{master.sql,tenant_template.sql,ERD.md,README.md}`·`dev-validation/{backend-db-r01,r02,plan-r01,decisions-r01}.md`·`transcripts/20260702/backend-db.md`.
- ⚠️ **강사 RBAC 변경**(settlement/commerce/members·typ 기반)= **NO-GO·재작성 대기**(적용 금지).

## 9. 쏠쏠 크리에이터 세션 — 앱층 blocker + FR01 조회 실연동 + AD01 쓰기 파일럿 (커밋·배포 없음)

> 총괄 대행·글로벌 팀 4단계. 대화기록=`docs/transcripts/20260702/solsol.md`. **데이터 정본·스키마·solsol-api 백엔드 blocker는 backend-db 세션(§8)이 승계·통합** — 본 절은 크리에이터 프론트/앱층 산출 중심. 커밋·푸시·배포 없음.

- **앱층 blocker + Critical (3렌즈 게이트 GO)** — AD01-cttee-r01-D01(RBAC 직접URL: `solsol-admin/app/middleware/auth.global.ts` 메뉴권한 게이트 prefix→menuKey·hasMenu·셸 렌더 전 차단)·SEC-cttee-r01-D02(demo-login default-deny 반전+APP_ENV 이중가드)·**API-cttee-r01-D01**(`solsol/app/composables/useOrder.ts`→`/api/orders` 정렬·404 mock 은폐 제거)·Critical owner 비번(`solsol-admin/nuxt.config.ts` 소스 하드코딩 제거→env-only, 실 로테이트=오너/deployer 잔여). (health/db 게이트·credits 단일원장·SEC-1B 멱등앵커는 solsol-api 앱층 — backend-db §8과 통합.) qa·security·privacy GO.
- **FR01 조회 실연동 (Wave1)** — `solsol/app/composables/{useFaq,useCertificate,useLearning}.ts` 실 봉투 매퍼(FAQ·수료증·라이브·강의실·대시보드). 백엔드 소스 없는 필드는 `[계약대기]` 마커(부분연동 화이트리스트). typecheck EXIT0. 잔여 중: 수료증 '미발급' 필터(프론트+기획).
- **AD01 쓰기 파일럿 (Wave1)** — `solsol-admin/app/composables/useProductsApi.ts` write 7종+`useProductCache` 낙관적 브리지+상품 페이지 배선. **A-2~A-7 확산 표준 레시피 확정**. vue-tsc 편집파일 EXIT0.
- **`GET /api/my-products`** — 기존 P4 additive 확장(본인스코프·enrollStatus 파생·조인 팬아웃0). qa·privacy GO. enrollStatus lms(배현우) 검토 대상.
- **잔여** — F-6 프론트 매퍼·A-2~A-7 도메인 확산·수료증 '미발급' 필터(중) / K-1~K-5 목업·PG staging-gate·R2·실 테넌트 프로비저닝=오너/backend-db 대기.

### 산출물 (작업트리·미커밋·미배포)
- `solsol`: `app/composables/{useOrder,useFaq,useCertificate,useLearning}.ts`.
- `solsol-admin`: `app/composables/useProductsApi.ts`·`app/pages/admin/products/courses/{create,index,[id]}.vue`·`app/middleware/auth.global.ts`·`server/api/auth/demo-login.post.ts`·`nuxt.config.ts`.
- `solsol-api`(앱층): `src/routes/products.ts`(/my-products)·`src/routes/admin/credits.ts`·`src/index.ts`(health 게이트). ※데이터정본(master.sql·ERD·schema.master.ts·000_master·tenant_template)은 backend-db(§8) 소유.
- 기록: `docs/transcripts/20260702/solsol.md`(프롬프트·대화).

## 10. 배포 (deployer) — 크리에이터 프론트·목업 4개 배포 / solsol-api 홀드

> 오너 배포 승인. 대상 4개 레포만 배포, **solsol-api는 배포 금지(홀드)**. 시크릿은 deployer env로 직접 사용(평문 릴레이·출력 없음). 모두 mock 폴백 데모 성격 유지(실 API 결선·실인증 전까지 비프로덕션).

### 사전 점검 (build GREEN)
- `solsol`(front): `pnpm build`(nitro cloudflare-pages → `dist/`) **EXIT 0**, `dist/_worker.js` 마커 OK.
- `solsol-admin`(front): `pnpm build` → `dist/` **EXIT 0**, `dist/_worker.js` OK.
- `solsol/mockup`: `pnpm generate` → `.output/public` **EXIT 0**(48 라우트).
- `solsol-admin/mockup`: `pnpm generate` → `.output/public` **EXIT 0**(102 라우트).

### 커밋 · 푸시 (origin=malgnsoft)
- `solsol` 커밋 **`73bf718`** — 사용자단 composables(useCertificate/useFaq/useLearning/useOrder) mock 폴백 어댑터 보강 + 목업 화면(강좌 상세·학습·멤버십·마이페이지·인증) 갱신·error.vue. `git push origin main`(`f56a8b1..73bf718`).
- `solsol-admin` 커밋 **`ea90cd2`** — 상품/강좌 관리 화면(목록·생성·상세) + useProductsApi write 어댑터 + auth.global·demo-login·nuxt.config. `git push origin main`(`8440bad..ea90cd2`).

### 배포 (CF Pages · 계정 info@malgnsoft.com · `CLOUDFLARE_ACCOUNT_ID` env 전달 · commit-message ASCII)
| 프로젝트 | 산출물 | 배포 URL(alias) | 커밋 |
| --- | --- | --- | --- |
| `solsol` | `dist` | https://solsol.pages.dev (deploy https://184815cd.solsol.pages.dev) | 73bf718 |
| `solsol-admin` | `dist` | https://solsol-admin.pages.dev (deploy https://57460de4.solsol-admin.pages.dev) | ea90cd2 |
| `solsol-mockup` | `.output/public` | https://solsol-mockup.pages.dev (deploy https://5eda2485.solsol-mockup.pages.dev) | 73bf718 |
| `solsol-admin-mockup` | `.output/public` | https://solsol-admin-mockup.pages.dev (deploy https://f4c9f5a7.solsol-admin-mockup.pages.dev) | ea90cd2 |

### 스모크 (프로덕션 alias)
- `solsol`: `/`200 · `/courses`200 · `/notifications`200 · 보호 `/mypage/subscription` **302→/auth/login?redirect=**(라우트 가드 활성).
- `solsol-admin`: `/` **302→/auth/login**(가드 활성) · `/auth/login`200 · 변경 `/admin/products/courses`200.
- `solsol-mockup`: `/`200 · 변경 `/courses/detail`200.
- `solsol-admin-mockup`: `/`200 · `/admin`200.
- 주: 미인증 게이트는 클라이언트/세션 리다이렉트(302)로 동작 — 서버 401 아님(mock 데모·실인증 미도입, Phase 1 전까지 비프로덕션).

### ⛔ solsol-api 홀드 (배포 금지)
- backend-db 세션이 작업트리에 "적용 금지"로 표시한 **강사 RBAC NO-GO 코드** + **미적용 마이그레이션(002/003/004)** 존재 → 배포 시 취약코드·런타임 파손 위험. **커밋·푸시·배포 모두 미수행.** backend-db 세션의 NO-GO 해소·마이그 적용 후 별도 배포. 브랜드 레포·solsol-mng Pages도 이번 스코프 아님.

## 11. 배포 (deployer) — backend-db: solsol-api·brand-api 커밋·푸시 완료 / Workers 배포 홀드

> 오너 배포 승인(범위=**solsol-api·brand-api만**, solsol-mng 앱 제외). 시크릿=deployer env(평문 릴레이·출력 없음). 파괴 방지 가드레일로 Workers 배포·마이그는 중단. §8(강사 RBAC)은 r03에서 GO로 해소된 상태로 커밋됨(§10의 NO-GO 홀드 사유는 해소).

- **커밋·푸시(완료)** — solsol-api `d0ed606` → `malgn/main`(`92ad1bd..d0ed606`, 24파일 +2496/-416) · solsol-brand-api `39828ce` → `origin/main`(`266b6b1..39828ce`, 12파일 +1036/-111). `Co-Authored-By` 트레일러 부착. brand-api 커밋엔 브랜드 프론트 세션 백엔드 작업(contact/news/webhooks/auth 마스킹)도 포함.
- **빌드검증(통과)** — 양 레포 `tsc --noEmit` EXIT 0 · `wrangler deploy --dry-run` 번들 성공(api 3067KiB·brand 2425KiB). `wrangler whoami`=info@malgnsoft.com(deploy 권한 있음).
- **⛔ Workers 배포·마이그 중단(가드레일)** — 배포 코드가 신규 컬럼(`is_secret`·`TB_SESSION`·`source_credit_key`) ORM 의존인데 마이그 002/003/004 안전 적용 경로 없음: ① `/ops/migrate` 러너(`src/lib/migrate.ts`)가 **CREATE TABLE 문만 실행** → ALTER corrective(002/003/004) 미적용, 000/001은 `CREATE IF NOT EXISTS`라 기존 테이블 컬럼추가 불가 ② deployer env에 `OPS_SECRET`·mysql 자격 없음 → 배포 후 `/ops/migrate` 호출·직접 적용 불가. → 마이그 없이 배포 시 해당 테이블 조회 500. **"반쯤 깨진 배포보다 미배포"** 규칙으로 중단.
- **배포 완료 조건(오너/DBA)** — (a) 프로덕션 `solsol`/`solsol_lms` DB 상태 확인(fresh=테이블 미존재 vs 기존): 기존이면 **DBA가 자기 mysql 자격으로 002/003/004 직접 적용**(파일 내 information_schema 멱등·롤백·프리체크 동봉), fresh면 000/001로 신규 컬럼 포함 생성 → (b) `OPS_SECRET`을 deployer env 주입(값 릴레이 금지) → `wrangler deploy` → `/ops/migrate` 재확인 → 4역할 스모크.
- **후속 코드결함(별도 작업)** — `/ops/migrate`가 corrective(ALTER) 마이그를 적용하도록 러너/라우트 보강 필요(현재 CREATE-only). 또는 마이그를 mysql 직접 적용 표준으로 확정.

## 12. 세션 구조 Phase A 확정 — 3세션 + 스키마 2분할 + 배포 범위 (허브 배포)
- **3세션**(오너 확정): 허브 + **쏠쏠**(풀스택+`solsol_lms` tenant 92) + **쏠쏠 브랜드**(풀스택+`solsol` master 17). backend-db 세션 폐지→제품/허브 흡수(정본 단일화·계약 발행 완료 후).
- **DB 소유=물리 스키마 단위**: `solsol`(master)=쏠쏠 브랜드(플랫폼+공유 인증) / `solsol_lms`(tenant)=쏠쏠 / 허브=ERD 통합·중재(스키마 authoring 없음). 공유 인증 테이블 DDL 변경만 허브 중재.
- **세션별 배포 범위 명시**(PROTOCOL §4-B): 허브=`solsol-mng`(Pages+D1) / 쏠쏠=solsol·admin·api+solsol_lms 마이그 / 쏠쏠 브랜드=brand 3레포+solsol 마이그. 각 세션 자기 소유만·solsol-mng 산출물은 허브 단일 커밋.
- `DEV_SESSION_PLAN`·`PROTOCOL`·`transcripts`·`IMPLEMENTATION_STANDARD` 전면 정합(backend-db/spine/①②③ 폐기). 커밋 `c348da8` → Pages 배포.

## 다음 단계
- 검증위원회 open blocker 시정(DAT-D02 즉시·DAT-D01 결정선행·SEC-r02-D01 등) + 신규 `SEC-VC-01`(브랜드 이메일코드 오프라인탐색) backend-db 코드 원장 도입.
- **강사 RBAC 재작성**: 인증모델 확정(관리자단=`user_type='staff'`+TB_ROLE 파생) → 강사 판별 role 기반·배제 owner-only·roleGuard data_scope 검증·강사 code 강제 own → security 재서명.
- **DBA self-env 적용**: 스키마 003/004 + 샘플시드 dev Aurora(`/ops`·mysql, master→`solsol`·tenant→`solsol_lms`) → 실앱 실데이터 확인.
- **오너 결정 12건**(decisions-r01) 회신 시 해당 그룹 착수.
- Phase B 3세션 병행 — backend-db 데이터 정본 단일화·샘플 시드·계약 발행 → 제품 세션 실앱 연동(MOCK 배지 0 목표).
- **브랜드**: backend-db 회신(크레딧 uk 실적용·Hyperdrive 실측)·운영자 시드 후 SEC-1 실연동·brand-admin 실전환 / 오너 결정(PRV-B01 파기정책·반응형(c)·pricing-light SoT).
