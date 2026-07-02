# 검증위원회 T7 — 데이터 5축 트랙 결함표 (data-committee-r01)

- 위원: dba (데이터 5축) · 라운드: r01 · 일자: 2026-07-02(KST)
- SoT: `docs/data-model/ERD.md`, `docs/data-model/master.sql`, `docs/data-model/tenant_template.sql`, `DEV_VALIDATION_PROCESS.md §3-B`. (`06_API계약`은 참고, D1 가정=권위 아님.)
- 대상: `solsol-api/src`+`db/migrations`+`db/seed`, `solsol-brand-api/src`+`db/migrations`+`src/db/seed.admin.sql`.
- 방법: 코드·SQL·ERD **정적 대조**(정본·스키마 무수정). **실 DB 직접 조회 미실행(권한 없음 — 자기 env 시크릿 부재)**.
- 스코프 하드캡 준수: 결함표 파일만 기록. `_ledger.md` 미접촉. 파괴적/쓰기 DB작업·마이그레이션 실행·커밋·배포 없음.

---

## 결함표

| 결함ID | 스키마/대상 | 축 | 심각도 | 현상 | 근거(파일:라인/ERD) | 제안 | 상태 |
|---|---|---|---|---|---|---|---|
| DAT-cttee-r01-D01 | solsol-api master 크레딧 | 1 스키마정합 | 상 | ORM·라우트는 **TB_CREDIT_ACCOUNT / TB_CREDIT_CHARGE / TB_CREDIT_LEDGER**(3테이블)를 조회·기록하나, 실제 마이그레이션은 **단일 TB_CREDIT**만 생성. 3테이블은 어떤 마이그레이션에서도 생성되지 않음 → `/api/admin/credits` 전 엔드포인트 런타임 "table doesn't exist" 위험. ERD·`master.sql`·brand-api ORM은 모두 단일 TB_CREDIT(lot/통장식)로 일치, solsol-api ORM만 이탈. | `solsol-api/src/db/schema.master.ts:154,164,181`(3테이블) vs `db/migrations/000_master.sql:230 CREATE TABLE TB_CREDIT`; ERD.md L176-203(TB_CREDIT 단일); `solsol-brand-api/src/db/schema.master.ts:254`(단일 일치) | solsol-api 크레딧 ORM·라우트를 단일 TB_CREDIT(uk `site_id,idempotency_key,source_credit_id`)로 재정렬하거나, 3테이블 모델을 정본으로 승격 시 ERD·master.sql·brand-api·마이그레이션 4자를 동시 개정. **결정 전 배포 금지.** | open |
| DAT-cttee-r01-D02 | docs/data-model/master.sql (SoT) | 1 스키마정합 | 상 | SoT DDL 사본이 자매 정본 ERD.md와 불일치 — master.sql=**13테이블**(TB_CONTACT·TB_CONTACT_REPLY·TB_NEWS 누락), 종료주석은 "14개"로 실제와도 불일치. ERD.md·solsol-api `000_master.sql`은 **16테이블**. "DB변경→정본 동기화" 위반(사본 미갱신). | `docs/data-model/master.sql`(CREATE 13개, 말미 "마스터 14개 테이블") vs ERD.md L14 "16"·L6 개정이력(13→16); `solsol-api/db/migrations/000_master.sql`(16) | master.sql에 TB_CONTACT/CONTACT_REPLY/NEWS 반영 + 카운트 주석 16으로 정정(구현·ERD가 이미 16이므로 사본만 현행화). | open |
| DAT-cttee-r01-D03 | docs/data-model/tenant_template.sql (SoT) | 1 스키마정합 | 중 | SoT DDL 사본이 ERD·구현과 불일치 — tenant_template.sql=**91테이블**(TB_OAUTH_CONFIG 누락), 종료주석 "88개". ERD.md·solsol-api `001_tenant_template.sql`·ORM은 **92**(OAUTH_CONFIG 포함). | `docs/data-model/tenant_template.sql`(CREATE 91, 말미 "88개") vs ERD.md L15 "92"; `solsol-api/db/migrations/001_tenant_template.sql:215 TB_OAUTH_CONFIG` | tenant_template.sql에 TB_OAUTH_CONFIG 추가 + 카운트 주석 92로 정정. | open |
| DAT-cttee-r01-D04 | TB_PRODUCT.type 값 | 1 스키마정합 / 3 시드 | 중 | 문서·주석은 상품 기본형을 `course`로, 구현·시드는 `general`로 사용 — 값 드리프트. ERD·DDL 주석·TB_COURSE FK 주석 = `course/live/...`, 코드 PRODUCT_TYPES·시드 = `general/live/...`. | ERD.md L494·`001_tenant_template.sql:247`(주석 'course/…') / `solsol-api/src/routes/admin/products.ts:56`(`'general'`)·`db/seed/dev_domain_seed.sql`(type='general' ×2) | 실값 `general`로 정본(ERD·DDL 주석·TB_COURSE FK 설명)을 통일하거나 반대로 구현·시드를 `course`로 통일 — 한쪽으로 확정 후 4자 동기화. | open |
| DAT-cttee-r01-D05 | solsol-brand-api master 부트스트랩 | 2 마이그레이션 / 3 시드 | 중 | brand-api ORM은 master 16테이블(TB_SITE·TB_USER·TB_PLAN·TB_CREDIT·TB_SUBSCRIPTION·TB_INVOICE·TB_PAYMENT·TB_BILLING_KEY 등)을 참조하나, brand-api 마이그레이션(`000_brand_ext.sql`)은 **TB_CONTACT·TB_CONTACT_REPLY·TB_NEWS 3개만** 생성. 나머지 master 스키마는 solsol-api `000_master.sql` 선적용 의존 → brand-api 단독 프로비저닝 불가(부트스트랩 갭). | `solsol-brand-api/src/db/schema.master.ts`(16테이블 참조) vs `db/migrations/000_brand_ext.sql`(3 CREATE); `src/routes/ops.ts:66` | brand-api에 공유 master DDL(또는 solsol-api 000_master 참조 절차)을 명시·멱등 적용 경로로 편입해 단독 기동 시에도 master 존재 보장. 소유권(누가 master를 생성) 문서화. | open |
| DAT-cttee-r01-D06 | solsol-api dev_domain_seed.sql | 3 시드정합 | 중 | 부트스트랩 필수 시드 누락 — **RBAC(TB_ROLE·TB_USER_ROLE·TB_ADMIN_PERMISSION)·알림라우팅(TB_NOTIFICATION_ROUTE)·자격증명(TB_USER_CREDENTIAL)·소셜(TB_OAUTH_CONFIG)** 미시드. staff(1001) 행은 있으나 credential 無 → dev 로그인·05#3 데이터스코프(own) 서버강제 검증 불가, 알림 발송 라우팅 부재. | `solsol-api/db/seed/dev_domain_seed.sql`(INSERT 대상 24테이블에 ROLE/USER_ROLE/ADMIN_PERMISSION/NOTIFICATION_ROUTE/USER_CREDENTIAL/OAUTH_CONFIG 없음) | 역할 4종(owner/instructor/sub_instructor/learner)·권한매트릭스·알림라우팅(N-01~/MKT)·staff credential 멱등 시드 추가. | open |
| DAT-cttee-r01-D07 | solsol-brand-api seed.admin.sql | 3 시드정합 | 중 | 운영자(superadmin) 시드가 **미적용 상태**(설계상) — password_hash가 플레이스홀더 `pbkdf2$100000$REPLACE_WITH_ACTUAL_HASH_SALT$REPLACE_WITH_ACTUAL_HASH_VALUE`. 파일 그대로는 로그인 불가, DBA가 자기 env로 해시 재생성·수기 적용 필요. | `solsol-brand-api/src/db/seed.admin.sql`(REPLACE_WITH_… 해시, "실행 금지" 주석) | 운영자 부트스트랩 절차(해시 생성 → DBA 직접 적용) 문서화·체크리스트화. 프로덕션 전 강PW 교체·미커밋 확인. (미적용은 의도된 상태 — 갭으로 기록.) | open |
| DAT-cttee-r01-D08 | 두 API master TB_CONTACT/REPLY/NEWS | 1 스키마정합 | 하 | 동일 master 테이블 3종을 solsol-api(`000_master.sql`)·brand-api(`000_brand_ext.sql`) **양쪽에서 생성** — 이중 소유. migrate 러너가 IF NOT EXISTS로 정규화해 멱등·안전하나, 한쪽만 컬럼 수정 시 정의 드리프트 위험. | `solsol-api/db/migrations/000_master.sql:308~`·`solsol-brand-api/db/migrations/000_brand_ext.sql` | 단일 소유 레포 지정 후 다른 쪽은 참조/공유. 컬럼 정의 동일성 정기 대조. | open |
| DAT-cttee-r01-D09 | data-model SQL 카운트 주석 | 1 스키마정합 | 하 | 말미 테이블 수 주석이 실제 CREATE 수와 불일치(master "14개"↔13, tenant "88개"↔91). D02/D03 정정 시 함께 교정. | `docs/data-model/master.sql`·`tenant_template.sql` 말미 주석 | 실제 CREATE 수와 일치하도록 주석 갱신(16/92). | open |

---

## 5축 요약

1. **스키마 정합** — ❌. 최대 리스크 = **D01(solsol-api 크레딧 3테이블 ↔ 마이그레이션 단일 TB_CREDIT 이탈, 런타임 실패 위험)**. 그 외 SoT DDL 사본(master.sql/tenant_template.sql)이 ERD·구현 대비 각각 3테이블/1테이블 뒤처짐(D02/D03), TB_PRODUCT.type 값 문서-구현 드리프트(D04). 단, solsol-api·brand-api **테넌트 92 / brand master 16 ORM은 ERD·마이그레이션과 테이블 셋 일치**(OAUTH_CONFIG·ROLE·NOTIFICATION_ROUTE 포함).
2. **마이그레이션 안전** — 🔺(대체로 안전). 러너가 `CREATE TABLE IF NOT EXISTS \`schema\`.\`TB_X\`` 로 **멱등 정규화**, CREATE만 실행(ALTER/DROP 없음=additive·비파괴), 시드는 `ON DUPLICATE KEY UPDATE`/`INSERT IGNORE`로 재실행 안전. down/rollback 스크립트는 없음(additive-only라 수용). Aurora `information_schema` 적용 확인은 **미실행(권한)**. brand 단독 부트스트랩 갭 = D05.
3. **시드 정합** — ❌. RBAC·알림라우팅·credential·OAuth 시드 누락(D06), 운영자 시드 플레이스홀더 미적용(D07). 도메인 대표 시드(상품 7유형·게시판·쿠폰·수강)는 멱등 구비.
4. **데이터 정합성** — ⭕(양호). 자연키·멱등키 UNIQUE 광범위: master `uk_site_slug/schema/domain`·`uk_plan_code`·`uk_siteuser`·`uk_payment_toss_key`·`uk_credit_idem(site_id,idempotency_key,source_credit_id)`·`uk_webhook_event(event_id)`; tenant `uk_user_login_id/nickname/email`+소셜 uid 5종·`uk_credential_user`·`uk_cert_no`·`uk_order_no`. status 소프트삭제(1/0/-1) 일관. 약한 FK(제약 없음)는 컨벤션대로.
5. **성능** — ⭕(스팟 기준 양호). 조회 커버 인덱스 확인: `idx_contact_state(contact_state,created_at)`·`idx_news_category(category,published_at)`·`idx_user_type`·복합 uk. 명백한 인덱스 부재 blocker 미발견. 실행계획·대량잠금은 실 DB 필요 = **미실행(권한)**.

## 정적검증 증거
- 실행: `diff`(data-model SQL ↔ solsol-api 마이그레이션), `grep -c CREATE TABLE`, ORM `.table('TB_…')` 열거, UNIQUE/idempotency 스캔. **모두 정적 대조** — 빌드/타입체크 및 실 DB 조회는 본 트랙 범위 밖·권한 없음으로 미실행.

## 트랙 판정 — ❌ 재작업 (blocker 존재)

- **상(blocker) 2건**: D01(크레딧 스키마 이탈·런타임 실패 위험), D02(master.sql SoT 3테이블 드리프트).
- **중 5건**: D03·D04·D05·D06·D07.  **하 2건**: D08·D09.
- 종료조건 "❌'상' 0건" 미충족 → **NO-GO**. D01은 배포 전 필수 해소(결제 인접·master), D02는 정본 동기화로 즉시 교정 가능.
- blocker(D01·D02)는 `_ledger.md` 등재 대상(본 위원 미접촉 — 원장 담당이 등재).
