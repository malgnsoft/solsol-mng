# 검증 위원회 종합 보고서 — 데이터 모델 Round 3

- **일시**: 2026-07-01 (KST)
- **소집**: 총괄(chief) — 오너 지시
- **트랙**: 데이터 라운드(스키마·data-model) · 절차 정본 `docs/DEV_VALIDATION_PROCESS.md`
- **위원회(데이터 게이트 4주체)**: dba · security-reviewer · privacy-officer · qa
- **대상**: `docs/data-model/{master.sql(13), tenant_template.sql(91), ERD.md, README.md}` + 참고 ORM `solsol-api/src/db/`
- **정본(SoT)**: `docs/validation/`(읽기전용) — 05 정책설계서 최우선. 물리 정본 = DDL·ERD.md.
- **결함표**: `docs/dev-validation/data-model-vs-validation-round3.md` · **이월원장**: `docs/dev-validation/_ledger.md`

---

## 1. 종합 판정: ❌ **NO-GO** (상 blocker 미해소)

Round2(게이트 통과) 이후 **마스터 전면 개편·크레딧 재설계·course_user·TIMESTAMP** 등 대규모 변경분 재검증. 결과 **상(blocker) 관련 open 3건** → 데이터 라운드 종료조건("❌'상' 0건")을 **미충족**.

| 위원 | 상 | 중 | 하 | 축 판정 |
|---|:--:|:--:|:--:|---|
| dba (데이터 5축) | **2** | 5 | 4 | 스키마정합 ❌ · 데이터정합성 ❌ · 마이그/시드 🔺 · 성능 ⭕ |
| security | 0 | 4 | 2 | 🔺 (실연동 전 해소 권고) |
| privacy | 0 | 3 | 5 | 🔺 (마스킹 요건화 ❌) |
| qa | 0 | 3 | 2 | ⭕(05 6건·커버리지) / 🔺(문서 드리프트) |
| **합계** | **2** | **15** | **13** | **30건** |

> 이월원장 검산: 데이터모델 관련 **open blocker 3건** = `DAT-cttee-r01-D01`(기존)·`DAT-cttee-r01-D02`(기존, 재확인) + **`data-model-r03-D02`(신규)**.

## 2. Blocker (상) — 재작업 대상

| ID | 내용 | 성격 | 조치 |
|---|---|---|---|
| **data-model-r03-D02** (신규) | 크레딧 멱등 `uk(site_id,idempotency_key,source_credit_id)` — 증가행(charge) `source_credit_id`=NULL → MySQL **NULL-distinct**로 멱등 무효 → **중복 충전** 가능 | 돈 원장 불변식 실패 | `COALESCE(source_credit_id,0)` 생성컬럼 uk 또는 증가행 부분 유니크 + 앱 선검증. **mng master.sql + api 000_master 동시 개정** |
| **DAT-cttee-r01-D01** (기존·재확인) | ORM `schema.master.ts`가 폐기된 크레딧 3분할(ACCOUNT/CHARGE/LEDGER) 잔존 → 크레딧 경로 런타임 붕괴 | 앱계층(ORM) stale | ORM을 단일 `TB_CREDIT`로 재작성 |
| **DAT-cttee-r01-D02** (기존·재확인) | 데이터 정본 사본 드리프트(mng master.sql 13 ↔ ERD/api 16, 브랜드·OAuth 누락) | 정본 표류 | 정본 단일화 후 DDL 현행화 |

## 3. 근본원인 — **정본 표류(4자 비동기)**

데이터 정본이 세션 간 **3~4갈래로 분기**했다. 다수 중결함(중 15건 상당)이 여기로 수렴한다.

| 사본 | 테이블 수 | 크레딧 | 비고 |
|---|---|---|---|
| mng `docs/data-model` (본 라운드 대상) | 13 / 91 | 단일 `TB_CREDIT`·`_cr` | 브랜드·`TB_OAUTH_CONFIG` **없음** |
| `solsol-api/db/migrations` + `ERD.md` | 16 / 92 | 단일 TB_CREDIT | 브랜드 `TB_CONTACT/CONTACT_REPLY/NEWS` + `TB_OAUTH_CONFIG` 포함 |
| ORM `schema.master.ts` | — | **구 3분할** | `owner_seller_id`·`credit_charge_id` 등 구컬럼 |

→ **선결정(오너/architect)**: "어느 사본이 정본인가" + "브랜드 테이블이 크리에이터 LMS master 스코프인가" 단일화. 이후 DDL=ERD=README=ORM 4자 동기하면 D03·D04·S01·S06·Q01·D05·D06·D11 등 대부분 일괄 해소.

## 4. 축별 하이라이트 (중결함)

- **security**: OAuth 자격증명 테이블(`client_secret`/privateKey) mng DDL 부재(S01) · 웹훅 `raw_payload` 평문·마스킹 요건 부재(S02) · 테넌트 로그인 감사로그 부재(S03) · 4자 비동기(S06).
- **privacy**: 05 **C-6 응답 마스킹 규칙** 모델/README 미요건화(P02) · 웹훅 raw_payload L2(P01) · **tenant `TB_USER_AGREEMENT` UNIQUE로 동의/철회 이력 append 불가**(P03, master와 불일치).
- **qa**: 05 확정 6건·화면 데이터 커버리지·회귀(SQL 본체) **정상(⭕)**. 결함은 전부 ERD/README ↔ DDL **문서 드리프트**(Q01·Q04·Q05·Q02·Q03).

## 5. 이관/별도 트랙 (게이트 비차단)

- **법무**: 국외이전(AI 번역/튜터·PG·GA/Meta) 고지·동의 근거(P04, §28의8).
- **앱계층 구현 게이트**: 마스킹 L1/L2 실측(P01·P02·S02), own 스코프 필터 매핑(S04), 게시판 서버강제(S05).
- **인프라**: 라이브 SQL 문법검증(로컬 MySQL 미기동으로 본 라운드 미실행 — dba env 별도).

## 6. 권고 (총괄)

1. **즉시(재통과 선결)**: ① `data-model-r03-D02` 멱등 uk 수정(내가 이번 세션에 유입한 결함) ② ORM 단일 `TB_CREDIT` 재작성(DAT-r01-D01) ③ **정본 단일화 결정** 후 4자 동기(DAT-r01-D02 외).
2. **문서 드리프트 일괄 정정**: ERD/README 카운트·구네이밍·유령 테이블(Q01·Q04·Q05·D08).
3. **요건화**: README "보안·개인정보 구현 요건"에 C-6 L1·raw_payload L2·동의이력·보존기간표 추가.
4. 재검증 시 **통과 스냅샷**(테이블수 + 커밋해시) 재기록.

> 본 라운드는 **검증·보고**만 수행했고 파일(스키마) 수정은 하지 않았다. 위 1번(블로커 remediation)은 오너 승인/정본 단일화 결정 후 착수한다.
