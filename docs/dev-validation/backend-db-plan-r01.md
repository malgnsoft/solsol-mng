# backend-db 실행계획·절차 (DB 미결 취합) — 세션 ① · 대기중(미실행)

> **작성**: 2026-07-02 (KST) · 총괄(chief) 종합 · 팀: 한데관(dba·절차)·조남기(dev-lead·시퀀싱)
> **출처(DB 항목만 추출)**: `docs/report/검증위원회-통합보고서-20260702.md` · `쏠쏠-미결취합-20260702.md`(§3·공통) · `브랜드-미결취합-20260702.md`(§6·공통)
> **성격**: **계획·절차 수립만. 미실행(오너 지시 대기).** 커밋·배포·실 DB 적용 없음. 시크릿·PII 값 미기재.
> **선결 확보**: 데이터 정본 4자 동기·프리즈 + API 계약 발행 = `backend-db-r01.md`에서 달성.

---

## 0. 이미 해소(세션① close — 재작업 대상 아님)
DAT-D01(크레딧 단일모델)·DAT-D02(master.sql 16)·r03-D02(멱등 uk NULL-free)·SEC-1(크레딧 조정 원자성)·SEC-r02-D01(health 정보노출)·PRV-r02-D01(PII 마스킹). **정본·코드 정합까지** 완료 — 단, "실 DB 반영"은 아래 시드·마이그 적용에 종속(코드=green, 물리적용=대기).

## 1. 공통 실행 전제 (모든 실 DB 액션의 하드 전제)
- **Aurora 직결 불가** — Tunnel 뒤(3306 닫힘)·`.dev.vars`에 DB 자격증명 없음. **모든 라이브 DDL/DML = Worker `/ops/*` 경유**(`wrangler dev --remote`). mysql 직결 불가.
  - solsol-api: `/ops/migrate`·`/ops/seed`·`/ops/domain-seed`·`/ops/seed-admin`·`/ops/verify`·`/ops/reset`(파괴적·prod 차단).
  - brand-api: `/ops/migrate`(확장 3테이블)·`/ops/seed-admin`.
- **게이트**: `/ops/*` = `APP_ENV` + `X-Ops-Secret===OPS_SECRET` 이중가드. dev는 `--var APP_ENV:local`. **시크릿은 담당자 자기 env로만**(평문 릴레이·커밋 금지). `OPS_SECRET`은 배포 중 재설정→값 미보관→호출 전 담당자 재설정.
- **GRANT 선행** — 유저 `solsol`은 신규 **테이블**에 GRANT 없으면 SELECT denied. **신규 테이블 DDL 직후 GRANT 동반**(기존 테이블 컬럼 추가는 불필요).
- **정본 동기(db-change-sync)** — 스키마 변경 시 마이그 ↔ `master.sql`/`tenant_template.sql`/`ERD.md`/`README`/ORM **동시 갱신**. `*.sql`·`ERD.md`·`schema.ts` 변경 = **데이터 라운드 N+1 필수**(테이블수+해시 기록).
- **⚠️ 파일 확정 선행**: 리포트의 브랜드 운영자 시드 `seed.admin.FINAL.sql`는 **실존하지 않음** — 실제 파일 `solsol-brand-api/src/db/seed.admin.sql` 하나. 적용 전 **실 PBKDF2 반영본 확정** 필요.

## 2. 웨이브 · 순서 (의존성)

| 웨이브 | 그룹 | 항목 | 선결 | 게이트 |
|---|---|---|---|---|
| **W1 (즉시)** | 시드·계정 | ①브랜드 운영자 시드→brand-admin 실전환+사용자단 실데이터 ②solsol-admin 관리자 시드(Blocker B: staff TB_USER/ROLE/ADMIN_PERMISSION) ③OAuth config 행 시드 ④dev 샘플 시드(dev_master/dev_domain) | 없음(스키마 frozen) | dba(시드정합)+**security 서명**(계정·RBAC·초기비번) |
| **W2** | 신규 테이블 | TB_SESSION(refresh 세션원장·재사용탐지) · 라이브 채팅 테이블 · (멱등/스냅샷 테이블=여부결정) | **GRANT 선행** + refresh 쿠키 도메인 정렬(오너) | dba+**security**(세션원장) / +privacy(채팅 PII) · 데이터 라운드 N+1 |
| **W3** | 스키마 갭(additive) | isSecret 컬럼(F-7) · TB_BOARD 권한/비밀 컬럼(B13) · orders `product_name` 스냅샷 · 가입 멱등 UNIQUE · 동의이력 `agreed_terms`→TB_USER_AGREEMENT 이관 | 데이터 라운드 N+1 / UNIQUE·이관은 dedup·백필 선행 | dba+security+qa / 이관·백필은 **privacy+사용자확인(비가역)** |
| **W4 (블록)** | 데이터모델 정책 | 강사 operation 권한(06↔05)·자막테이블·폴더삭제·프로비저닝 동기/비동기·코드표·unit_price·사용량소스·구독 비례정산 | **오너/기획 결정 선행** | 결정 후 W3류 흡수 |
| **W5 (후속/조건)** | 인프라·권한·백필 | GRANT 경계 정리 · 테넌트 자동 프로비저닝(CREATE DATABASE 전용계정) · time_zone(TIMESTAMP UTC 수용) · 기존 크레딧 백필(TB_CREDIT_CHARGE→TB_CREDIT) | 프로비저닝=오너/인프라 · 백필=운영데이터 발생 트리거 | dba+security/privacy |

**직렬 사슬**: 브랜드 운영자 시드 → brand-admin 실전환 → `NUXT_API_BASE` / GRANT → 신규테이블 / 정책결정 → 스키마. **단일 DBA env → W1 논리병렬이나 실행은 직렬**.

## 3. 절차 (HOW — 핵심)

### 3-A. 시드 적용 (W1)
1. **스키마 확정**: solsol-api `/ops/migrate`(000_master→`solsol`·001_tenant→`solsol_lms`, +002 크레딧 멱등 uk) → `/ops/verify`로 master 16테이블·`information_schema`에서 uk(`source_credit_key`) 확인. **⚠️ 002 미적용 시 SEC-1 백스톱 무력화→이중지급**.
2. **브랜드 운영자 시드**: 파일 확정 → brand-api `/ops/migrate`(확장) → `/ops/seed-admin`(멱등 INSERT-only) → superadmin/support 로그인 200 → **즉시 초기 비번 변경·`SEED_ADMIN_PASSWORD` 시크릿화** → brand-admin `NUXT_API_BASE` 설정 실전환. 검증: `SELECT login_id,LEFT(password,7)…` PBKDF2 접두·평문 아님·중복 0.
3. **solsol-admin 관리자 시드**: staff 매트릭스 `/ops/seed-admin` 멱등 → owner 로그인 200(로그인 관문은 쏠쏠세션 **Blocker A** role매핑 app fix 병행). 검증: role 파생·권한 매트릭스 행수.
4. **OAuth config 행 시드**: 행만 UPSERT. 실동작은 오너 키(OQ-OAUTH)+`SECRET_ENC_KEY`(F-6) 대기.
5. **dev 샘플 시드**: `/ops/seed`·`/ops/domain-seed`(**dev 전용, 프로덕션 금지**).
> 전 시드 INSERT-only 멱등(자연키 uk), 재실행 중복 0.

### 3-B. 스키마 변경 (W2·W3) 공통 안전
GRANT 선행 → 멱등(`IF NOT EXISTS`·`information_schema` 조건부) → before/after `information_schema` 기록 → 온라인 DDL(Aurora 8.0 INPLACE, 5.6 혼재 시 잠금 고지, 큰 텍스트=MEDIUMTEXT) → 신규 시간컬럼 TIMESTAMP UTC → 롤백(additive=DROP, uk/백필 후=데이터 롤백 불가 고지) → **4자 정본 동기** → 데이터 5축 검증(스키마정합·마이그안전·시드정합·데이터정합성 uk중복0/고아0·성능 EXPLAIN).
- **특이**: isSecret+B13=tenant 2컬럼 묶음 / product_name=추가 후 조인백필(비차단) / 가입 uk=dedup 프리체크 선행 / 동의이력 이관=신규테이블+ETL 백필, 원천 제거는 파괴적(별도 승인·병행기간) / TB_SESSION=master(brand)+solsol-api, SameSite=None 도메인 정렬 병행 / 채팅=tenant append 인덱스.

### 3-C. 백필 (W5)
구 TB_CREDIT_CHARGE→TB_CREDIT는 **운영 데이터 발생 시점에만**(현재 미발생=불필요). 발생 시 FIFO lot 매핑·`SUM` 검산(총 크레딧 불변)·멱등키 충돌0·영향건수/잠금/백업 명시·사용자확인.

## 4. 오너/기획 결정 선행 (결정 없이는 진행 불가)
1. 크레딧 단가 `unit_price` 값(과금 직결) 2. 강사 operation 권한 06↔05 정렬 3. 자막테이블·폴더삭제 정책 4. 사이트 프로비저닝 동기/비동기 + 테넌트 자동 프로비저닝(전용 CREATE DATABASE 계정) 5. 구독 정책(비례정산·연장할인·카드삭제 재바인딩·**탈퇴 파기 vs 법정보존** biz-legal) 6. subjectType·payment.method 코드표 7. 브랜드 멱등 테이블(uk) 신설 여부 8. my-sites 사용량 소스 택1 9. refresh 쿠키 크로스도메인 정렬(TB_SESSION 전제) 10. 국외이전·고유식별정보 근거(법무) 11. TOSS staging-gate 해제(비가역 CMP-06) 12. 파괴적 변경 개별 승인(dedup 삭제·agreed_terms 원천 제거·CREDIT_CHARGE 폐기).

## 5. 저위험 즉시착수 후보 Top 6 (오너 불필요·선결 없음 · 담당자 env·dev 범위)
1. **브랜드 운영자 시드 적용**(파일 확정 후) — 실전환+실데이터 동시 해소. security 서명(비번 로테이트 동반).
2. **solsol-admin 관리자 시드**(Blocker B) — 스키마 frozen·독립.
3. **dev 샘플 시드**(master→solsol·tenant→solsol_lms, 프로덕션 금지).
4. **orders `product_name` 스냅샷 컬럼**(nullable additive·조인백필).
5. **isSecret 컬럼**(F-7, nullable default).
6. **4자 동기 검산 재확인**(16테이블·해시).
> 제외(저위험 미충족): 가입 UNIQUE(dedup)·동의이력 이관·TB_SESSION(GRANT+security)·크레딧 백필(비가역).

## 6. 리스크 요약
비가역·파괴적(백필·이관·dedup·프로비저닝)=멱등·롤백·dedup 프리체크·사용자확인 / GRANT 누락=런타임 SELECT denied(상) / 크로스레포 드리프트=backend-db 단독소유·즉시 4자동기 / 배포·실DB=오너 "배포" 시만·dev 한정 / 검증증거=`/ops`·`--remote` 경유만(미실행 시 미실행 표기).

---
**총괄 판정**: W1(시드) = 오너 불필요·선결 없음 → **즉시 GO 후보**(게이트=dba+security). W2·W3 = 데이터 라운드 N+1·GRANT·4자동기 전제. **W4 = 오너 결정 없이는 NO-GO** → §4 결정 리스트 오너 상신 필요. **본 문서는 계획뿐 — 오너 지시 시 착수.**
