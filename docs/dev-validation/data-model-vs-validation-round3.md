# 데이터 모델 vs 검증정본 — Round 3 (검증 위원회)

> 일시: 2026-07-01(KST) · 트랙: **데이터 라운드**(스키마·data-model) · 절차 정본: [../DEV_VALIDATION_PROCESS.md](../DEV_VALIDATION_PROCESS.md)
> 위원회(데이터 게이트 4주체): **dba · security-reviewer · privacy-officer · qa** (총괄 통합)
> 대상(현재 정본): `docs/data-model/{master.sql(13), tenant_template.sql(91), ERD.md, README.md}` + 참고 ORM `solsol-api/src/db/`
> SoT(읽기전용): `docs/validation/05_정책설계서.md`(최우선)→화면 00~03→04→06(참고). 물리 정본 = DDL·ERD.md.

## 종합 판정: ❌ NO-GO — 상(blocker) **2건**

Round2(게이트 통과) 이후 마스터 전면 개편·크레딧 재설계·course_user 등 대규모 변경 반영분에 대한 재검증. **데이터 라운드 종료조건(❌'상' 0)을 미충족**(상 2건 = D01·D02). 이월원장 등재. 나머지 28건(중 15·하 13)은 대부분 **정본 표류(4자 비동기)**로 수렴 — 게이트 비차단이나 실연동 라운드 전 해소 권고.

### 축별 판정
| 축 | 판정 | 상 | 요약 |
|---|:--:|:--:|---|
| dba ① 스키마 정합 | ❌ | 1 | ORM 구버전 크레딧 잔존 + DDL↔ERD↔ORM 3~4갈래 표류 |
| dba ② 마이그레이션 | 🔺 | 0 | 파괴적 없음, `IF NOT EXISTS` 미사용·라이브 문법 미검증 |
| dba ③ 시드 | 🔺 | 0 | 부트스트랩 필수 시드 SQL 부재(산문만) |
| dba ④ 데이터 정합성 | ❌ | 1 | 크레딧 멱등 uk가 증가행(NULL)에 무효 → 중복 충전 |
| dba ⑤ 성능 | ⭕ | 0 | FIFO·통장·대시보드 인덱스 커버 양호 |
| security | 🔺 | 0 | OAuth 자격증명 DDL 부재·raw_payload 마스킹·테넌트 감사로그·4자 비동기 |
| privacy | 🔺 | 0 | 마스킹 3레이어 요건화 ❌·tenant 동의이력 append 불가 |
| qa | 🔺 | 0 | 05 6건·커버리지 ⭕, ERD/README 문서 드리프트 |

## 결함표 (§6 표준)

| 결함ID | 추적키 | 검증축 | 심각도 | 현상 | 근거(파일:라인/SoT) | 제안 |
|---|---|---|:--:|---|---|---|
| **D01** | ORM masterTables()/TB_CREDIT | 스키마정합 | **상** | ORM `schema.master.ts`가 폐기된 3분할(`TB_CREDIT_ACCOUNT/CHARGE/LEDGER`) 정의 유지 → 크레딧 경로 런타임 실패(행복경로 차단) | schema.master.ts:154·164·181 vs master.sql:230 | ORM을 단일 `TB_CREDIT`로 재작성 |
| **D02** | TB_CREDIT `uk_credit_idem` | 데이터정합성 | **상** | uk=(site_id, idempotency_key, source_credit_id). 증가행 `source_credit_id`=NULL → MySQL NULL-distinct → 동일 키 **중복 충전** 가능(원장 불변식 실패) | master.sql:258·247 (+api 000_master.sql 동일) | 증가행용 `COALESCE(source_credit_id,0)` 생성컬럼 uk 또는 부분/함수 유니크 + 앱 선검증 |
| D03 | master.sql 전체 | 스키마정합 | 중 | mng master.sql=13 vs ERD/api 마이그레이션=16(브랜드 TB_CONTACT/CONTACT_REPLY/NEWS) — 물리 정본 뒤처짐 | master.sql(13) vs ERD.md:6 vs api 000_master.sql(16) | 정본 단일화 결정 후 DDL 현행화 |
| D04 / S01 | tenant.TB_OAUTH_CONFIG | 스키마정합/보안 | 중 | OAuth 자격증명(client_secret·Apple privateKey) 테이블이 ERD·ORM·api DDL엔 있으나 **mng tenant_template.sql(91)엔 부재** | tenant_template.sql(91) vs ERD.md:450 vs api 001:215 | mng 템플릿에 `TB_OAUTH_CONFIG` 이식 + README 암호화 요건 등재 |
| D05 | master.TB_SITE (ORM) | 스키마정합 | 중 | ORM `owner_seller_id`·`plan_id` 누락·길이 상이(DDL은 `owner_user_id`) | schema.master.ts:60·64 vs master.sql:24·25 | ORM을 DDL 기준 정정 |
| D06 | master.TB_PAYMENT (ORM) | 스키마정합 | 중 | ORM `credit_charge_id`(구명) vs DDL `credit_id` | schema.master.ts:136 vs master.sql:200 | ORM `credit_id`로 정정 |
| D09 | 부트스트랩 시드 | 시드정합 | 중 | 신규 테넌트 필수 시드(역할·권한·기본게시판·알림라우팅) SQL 부재(산문만) | README:36 | `tenant_bootstrap_seed.sql`(멱등) 신설 |
| D07 | master ORM 일시 | 스키마정합 | 하 | ORM `datetime()` vs DDL `TIMESTAMP`(UTC, OQ-TZ) | schema.master.ts:17-27 vs README:57 | drizzle `timestamp()` 정렬 |
| D08/Q02/Q03 | 파일 푸터 주석 | 스키마정합 | 하 | 푸터 테이블수 표류(master "14"·tenant "88") vs 실제 13/91 | master.sql:303·tenant:1593 | 주석 13·91 현행화 |
| D10 | 전 CREATE TABLE | 마이그레이션 | 하 | `IF NOT EXISTS` 미사용 → 재적용 비멱등 | master.sql:18 외 | 러너 멱등 보장 또는 IF NOT EXISTS |
| D11/Q04 | README §4 크레딧 | 스키마정합 | 중 | README가 구네이밍(`balance_after`·`source_ledger_id`·`credit_charge_id`) 사용 vs DDL `*_cr`/`credit_id`/`source_credit_id` | README:62·74 vs master.sql:200·237·247 | README 현행화 |
| S02/P01 | TB_TOSS_WEBHOOK_EVENT.raw_payload | 시크릿/마스킹L2 | 중 | 웹훅 원문 평문 TEXT 저장·마스킹 요건 미기재 | master.sql:277·tenant:1019 / DEV §3-D L2 | README 요건에 raw_payload 저장 전 마스킹·보관/파기 추가 |
| S03 | tenant TB_LOGIN_LOG 부재 | 남용/감사 | 중 | 테넌트 staff/강사 로그인 실패·계정열거 감사 테이블 없음(TB_LOGIN_LOG는 master 전용) | tenant(LOGIN_LOG 0건) / DEV §3-C | 테넌트 인증 감사 테이블 or 중앙 감사 결정 |
| S06 | 정본 4자 동기화 | 약한FK/스키마정합 | 중 | DDL↔ERD↔README↔ORM 테이블수·컬럼 3~4자 상이 | master.sql·ERD.md·README·ORM | DDL을 정본으로 4자 재동기 |
| P02 | 전 PII 조회 EP | 마스킹L1 | 중 | 05 C-6 응답 마스킹(본인/타인×식별·카드·계좌·비번·인증코드) 모델/README 미반영 | README §84-96 / SoT 05:687-689 | C-6 L1 규칙 요건화 |
| P03 | tenant.TB_USER_AGREEMENT | 동의기록 | 중 | `UNIQUE(user_id,agreement_key)`로 1행만 → 동의/철회/재동의 **이력 append 불가**, master(KEY·이력형)와 불일치 | tenant:135 vs master.sql:73 | 이력형 전환·master/tenant 통일(dba) |
| S04 | TB_ADMIN_PERMISSION own | 인가 | 하 | own 스코프 필터 컬럼 테이블별 상이(owner_user_id/instructor_user_id), README 단일 예시만 | README:93 / tenant:229·721·936 | own 스코프 필터 컬럼 매핑표 명문화 |
| S05 | TB_BOARD auth_*/is_secret | 인가 | 하 | 게시판 문자열권한·비밀글 가시성 서버강제 요건 미명시 | tenant:1288-1293·1343 | 앱계층 강제 계약 추가 |
| P04 | TB_AI_JOB / 외부전송 | 마스킹L3 | 하(법무) | AI 번역/튜터·PG·GA·Meta 국외이전 고지·동의 근거 미문서화(§28의8) | tenant:626-638 / DEV §3-D L3 | 법무 자문(별도 안건) |
| P05 | 로그 3종 보관 | 보관파기 | 하 | 로그별 보존기간·파기주기 미명시 | README:91 | 로그·PII 보존기간표·파기배치 |
| P06 | 신규 로그 ip/ua | 보관파기 | 하 | ip 전문·UA(500) 최소화(절삭/해시) 주석 부재 | tenant:311-312·549-550·master:83-84 | ip 절삭/해시·보존 검토 |
| P07 | TB_SETTLEMENT_PROFILE | PII최소화 | 하 | birth_date·서류 R2키 수집목적·보유기간 주석 부재 | tenant:902-931 | 목적·보유기간 주석, birth_date 필요성 재검토 |
| P08 | TB_CAMPAIGN_RECIPIENT | PII최소화/보관 | 하 | contact/recipient_name 평문 스냅샷 파기주기 미정 | tenant:1095-1096 | 보존기간·파기 정의 |
| Q01 | ERD 유령 테이블 4종 | 스키마정합 | 중 | ERD가 master16/tenant92 선언 + TB_CONTACT/CONTACT_REPLY/NEWS/OAUTH_CONFIG 포함하나 mng DDL엔 0건 | ERD.md:3·6 vs DDL(grep 0) | ERD를 DDL과 동기 or DDL 반영·헤더 카운트 수정 |
| Q05 | README §8 TB_COURSE_USER | 커버리지/회귀 | 중 | README가 성적(시험/과제/토론)·정지·tutor_user_id "추가"로 기술하나 DDL엔 부재(시험 미사용 정책과도 모순) | README:26·80 vs tenant:480-508 | README를 DDL 실제(진도 기반·TB_COURSE_TUTOR)로 정정 |

> ①스키마정합/②커버리지/③회귀 등에서 SQL DDL 본체는 **정책 6건 지지·회귀 잔존 0·커버리지 누락 0**(qa ⭕). 결함의 대부분은 **DDL↔ERD↔README↔ORM 4자 동기화 실패(정본 표류)** 로 수렴.

## 근본원인 & 통과 조건
- **근본원인**: 데이터 정본이 세션 간 **3~4갈래로 표류**. ① mng `docs/data-model`(13/91) ② `solsol-api/db/migrations`+ERD.md(16/92, 브랜드·OAuth 포함) ③ ORM `schema.master.ts`(구 크레딧 3분할). "어느 것이 정본인가"의 **단일화 결정(오너/architect)** 이 선행돼야 다수 중결함이 일괄 해소됨.
- **재통과 조건(다음 라운드)**: (1) 블로커 2건 해소 — D01(ORM 단일 TB_CREDIT), D02(증가행 멱등 강제). (2) 정본 단일화 후 DDL=ERD=README=ORM 4자 동기(D03·D04·S06·Q01 등). (3) 통과 스냅샷(테이블수+커밋해시) 재기록.

## 이관/별도 트랙
- **법무**: P04 국외이전(AI/PG/GA·Meta) 고지·동의 근거.
- **앱계층 구현 게이트**: 마스킹 L1/L2 실측(P01·P02·S02), own 스코프 필터(S04), 게시판 서버강제(S05).
- **인프라**: 라이브 SQL 문법검증(로컬 MySQL 미기동으로 본 라운드 미실행).
