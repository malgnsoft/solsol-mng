# 쏠쏠 개발 세션 협업 규약 (각 세션 공통 전달용)

> **작성**: 2026-07-02 (KST) · 총괄(chief) · **모든 세션은 착수 전 본 문서를 읽는다.**
> **상위 계획**: [DEV_SESSION_PLAN.md](DEV_SESSION_PLAN.md) (범위·담당·시작 프롬프트) · **검증 정본**: [DEV_VALIDATION_PROCESS.md](DEV_VALIDATION_PROCESS.md) · **블로커 원장**: `docs/dev-validation/_ledger.md`
> **단계**: **Phase A (3세션)** — 데이터 정본 단일화·계약 발행이 끝나(프리즈), 백엔드·DB를 제품에 흡수했다. DB는 **물리 스키마 단위로 소유 분할**(오너 확정 2026-07-02): **`solsol`(master)=쏠쏠 브랜드 · `solsol_lms`(tenant)=쏠쏠 · 허브=조율·검증·ERD 통합**.

---

## 1. 세션 구성 (3창)

| 창 이름 | 영문키 | 역할 | 레포(작업 디렉터리) |
|---|---|---|---|
| 프로젝트 관리 | `hub` | **허브** — 조율·검증 게이트·`_ledger`·WBS·이력 **+ 공유 master 데이터 정본 스튜어드** | `solsol-mng`(+`docs/data-model` 정본) |
| 쏠쏠 | `solsol` | **풀스택**: 사용자단(FR01)+관리자단(AD01)+백엔드(solsol-api 앱)+**테넌트 스키마**+목업 | `solsol` · `solsol-admin` · `solsol-api`(+목업) |
| 쏠쏠 브랜드 | `solsol-brand` | **풀스택**: 사용자단+관리자단+백엔드(brand-api 앱)+목업 | `solsol-brand` · `solsol-brand-admin` · `solsol-brand-api`(+목업) |

> **쏠쏠·쏠쏠 브랜드는 각각 풀스택**(사용자단+관리자단+백엔드+목업). 두 제품이 **공유하는 master 스키마·데이터 정본(`master.sql`/`ERD`/`ORM 미러`)만 허브가 단독 소유**한다(중립 스튜어드). 각 제품의 **테넌트/비공유 스키마·API 앱**은 제품 세션 소유.

> **모든 세션(허브 포함)의 총괄 = 단일 「맘대로 총괄」(맘총괄).** 각 세션이 별도 총괄을 두지 않고, 맘대로 총괄 한 명이 각 창에서 해당 세션 범위를 진행한다(글로벌 chief 에이전트 정본). 각 세션은 **해당 있는 글로벌 에이전트**(`~/.claude/agents/`)만 팀장 경유 4단계로 참여한다.

---

## 2. 편집 소유 경계 (⚠️ 가장 중요 — 충돌 방지)

`solsol-mng`을 허브와 제품 세션이 **공유**(제품 세션은 자기 스키마 파일·결함표·트랜스크립트를 여기 기록)하므로, 내부 편집 소유를 아래로 고정한다. **소유자가 아닌 세션은 해당 경로를 수정하지 않는다.** DB 스키마는 **물리 스키마 단위(`solsol` / `solsol_lms`)로 소유를 나눈다.**

| 경로/자산 | 편집 소유 | 다른 세션 |
|---|---|---|
| **`solsol` 스키마** = `docs/data-model/master.sql` + `brand-api`의 스키마·마이그·ORM 미러 (플랫폼: 셀러·사이트·플랜·구독·결제·크레딧·문의·소식 + 공유 인증) | **쏠쏠 브랜드** | 읽기·런타임 쓰기 O, **DDL 변경 X**(요청) |
| **`solsol_lms` 스키마** = `docs/data-model/tenant_template.sql` + `solsol-api`의 테넌트 스키마·마이그·ORM 미러 (크리에이터 LMS 92테이블) | **쏠쏠** | 읽기 · 변경요청 |
| `docs/data-model/ERD.md`(양 스키마 통합 뷰) | **허브**(각 소유자 변경분 취합) | 자기 스키마 변경 시 허브에 알림 |
| `solsol`·`solsol-admin` + `solsol-api` **앱 계층**(라우트·핸들러·로직) | **쏠쏠 세션** | — |
| `solsol-brand`·`solsol-brand-admin` + `brand-api` **앱 계층** | **쏠쏠 브랜드 세션** | — |
| `docs/validation/`(정본·읽기전용) | **아무도 수정 안 함**(원본 무수정) | 전원 읽기만 |
| `docs/validation_modified/`(개정본) | **허브**(오너 승인 후 완성본 + `_개정이력.md` 전후) | 개정 필요 시 허브에 요청 |
| `DEV_*`·`IMPLEMENTATION_STANDARD`·`WBS`·`docs/history`·`docs/report` | **허브** | — |
| **`docs/dev-validation/_ledger.md`(블로커 원장)** | **허브 단독 기록** | 아래 §3 |
| `docs/transcripts/<YYYYMMDD>/<세션>.md`(`hub`·`solsol`·`solsol-brand`) | **각 세션이 자기 파일만** | 클로버 방지 |

> **DDL 단일 소유가 핵심**: `solsol`(master) DDL은 쏠쏠 브랜드만, `solsol_lms`(tenant) DDL은 쏠쏠만 authoring한다(정본 표류=현 #1 블로커 재발 방지). **런타임 데이터 쓰기는 양쪽 앱이 필요한 테이블에 자유롭게** 한다(스키마 소유 ≠ 데이터 쓰기 제한).
> **공유 인증/사이트 테이블**(`TB_USER`·`TB_SITE`·`TB_SESSION`·`TB_SITE_USER` 등)은 물리적으로 `solsol`(master)에 있어 **DDL 소유=쏠쏠 브랜드**. solsol-api가 이 테이블 스키마 변경을 필요로 하면 **허브 중재로 쏠쏠 브랜드에 요청**(현재 frozen이라 드묾).

---

## 3. 블로커 원장(`_ledger.md`) 규칙 — 허브 단독 기록

세션들은 git 브랜치가 아니라 **같은 파일시스템**에서 동시에 돈다 → 여러 세션이 `_ledger.md`를 직접 편집하면 서로 덮어쓴다.

- **각 작업 세션**: 자기 결함표는 **자기 레포/`solsol-mng/docs/dev-validation/<영역>-r<NN>.md`** 에 기록. blocker를 열거나 닫으면 **허브에 보고**(결함ID·상태·근거).
- **허브**: 보고를 받아 **`_ledger.md`를 단독 갱신**하고 "blocker 0" 검산·WBS 반영.
- 결함ID = `<영역>-r<NN>-D##`(안정 ID). 표준 결함표 템플릿 = `DEV_VALIDATION_PROCESS.md` §6.

---

## 4. 세션 간 인터페이스

1. **API 계약 = 각 백엔드가 발행** — `solsol-api /doc`(쏠쏠)·`solsol-brand-api /doc`(쏠쏠 브랜드) Scalar가 계약(엔드포인트·봉투·에러코드) 정본. 상대 제품이 그 계약을 호출하면 **발행분만 소비**(불일치는 소유 세션에 변경요청). 계약 변경은 `_ledger`/허브에 알림.
2. **공유 인증/사이트 테이블 변경** — `solsol`(master)의 공유 테이블(`TB_USER`·`TB_SITE`·`TB_SESSION`·`TB_SITE_USER`) DDL은 쏠쏠 브랜드 소유. solsol-api가 변경 필요 시 **허브 중재로 쏠쏠 브랜드에 요청**(frozen이라 드묾). ERD.md는 허브가 통합.
3. **브랜드 실전환 의존** — ③의 brand-admin 실전환·크레딧 조정 노출은 ①의 **운영자 시드 + SEC-1(크레딧 멱등·원자성) 해소 이후**. 그 전까지 mock/목업 유지.
4. **검증 게이트 = 허브가 실행 (독립)** — 실앱·계약 검증 게이트는 **허브(맘대로 총괄)가 독립 렌즈(qa·security·privacy·dba·api)를 스폰**해 진행하고 `_ledger` 판정·등재한다(개발↔검증 분리·자기참조 방지·3제품 동일 기준). **제품 세션은 선결 준비물만 제공** → 배포 + 샘플 데이터 Aurora 적용 + `MOCK` 배지 0 → **허브에 "검증 준비 완료" 신호** → 허브가 게이트. (오너 확정 2026-07-02.) 절차 정본 [DEV_VALIDATION_PROCESS.md](DEV_VALIDATION_PROCESS.md), 실앱 검증 프롬프트 [IMPLEMENTATION_STANDARD.md](IMPLEMENTATION_STANDARD.md) §7-D.
5. **결정 사항 기록** — 오너·세션 간 합의는 **허브가 기록**(WBS·history·본 문서 갱신).
6. **일일 트랜스크립트** — 각 세션은 **자기 프롬프트·에이전트 소통을 `docs/transcripts/<YYYYMMDD>/<세션>.md`(자기 파일)** 에 **원문**으로 기록한다(규약 [`transcripts/README.md`](transcripts/README.md)). 파일명: `hub`·`solsol`·`solsol-brand`. **시크릿·PII 값만 마스킹.** 허브는 `INDEX.md` 관리.
7. **배포 범위(§4-B)** — 각 세션은 **자기 소유 레포·DB 스키마만** 배포한다(오너 "배포" 시).

### 4-B. 배포 범위 (세션별 — 명확 정의)

| 세션 | 소유 레포 → 배포 타깃 | DB 마이그레이션 |
|---|---|---|
| **허브** | `solsol-mng` → **Pages `solsol-mng`** + **D1 `solsol-project`**(WBS·이슈·화면) | (스키마 authoring 없음) — ERD 통합·검증·집계 |
| **쏠쏠** | `solsol`→**Pages `solsol`** · `solsol-admin`→**Pages `solsol-admin`** · `solsol-api`→**Workers `solsol-api`** · 목업→**Pages `solsol-mockup`·`solsol-admin-mockup`** | **`solsol_lms`(tenant 92)** → Aurora (DBA env) |
| **쏠쏠 브랜드** | `solsol-brand`→**Pages `solsol-brand`** · `solsol-brand-admin`→**Pages `solsol-brand-admin`** · `solsol-brand-api`→**Workers `solsol-brand-api`** · 목업→**Pages `solsol-brand-mockup`** | **`solsol`(master 17)** → Aurora (DBA env) |

**배포 규칙**
- 각 세션은 **자기 소유 레포·타깃만** 커밋·푸시·배포. 배포는 **오너 "배포" 명시 시** [배포 일괄 절차](../CLAUDE.md) 실행(커밋→푸시→빌드·배포→이력).
- 커밋·푸시는 **각 레포 origin**(`malgnsoft/<repo>`)으로. 배포 타깃 방식: Pages=`build`+`wrangler pages deploy`, Workers=`wrangler deploy`, D1=`db:apply`, Aurora=DBA env(mysql/`/ops`).
- **`solsol-mng` 안의 산출물**(dev-validation 결함표·transcripts·`docs/data-model/*`·`_ledger`)은 제품 세션이 **기록/편집**하되 **커밋·배포는 허브**(단일 커밋 지점, 클로버·이력 일원화).
- **물리 Aurora `solsol` 스키마는 하나지만 테이블 DDL 소유가 분리**됨 — 각 소유 세션은 **자기 스키마만** 마이그레이션(코어 인증 테이블 변경은 §4-2 경유).

---

## 5. 공통 금지 (전 세션)

- `docs/validation/` **무수정**(원본 보존). 개정은 오너/기획-lead 승인 후 **`docs/validation_modified/` 에 동일 파일명 완성본 + `_개정이력.md` 전후 기록**(허브가 처리). 검증·개발은 **개정본 우선 → 없으면 원본**.
- **커밋·푸시·배포는 오너가 명시할 때만**. 기본은 분석·구현·검증까지.
- **시크릿·PII 평문**을 출력·로그·커밋에 남기지 않는다(위치·유형만).
- **비가역**(실결제·실환불·계정삭제·데이터 영구삭제)은 사용자/운영자 확인 전 자동 진행 금지.
- 소유 경계(§2) 밖 파일을 수정하지 않는다.
- **데이터 계층 표준**([IMPLEMENTATION_STANDARD.md](IMPLEMENTATION_STANDARD.md)) — 목업=가짜 데이터 / 실앱=실 API+실 DB(샘플 데이터는 각 스키마 소유 세션이 시드: `solsol`=쏠쏠 브랜드·`solsol_lms`=쏠쏠). 실앱 목 폴백엔 **`MOCK` 배지** 필수·게이트는 **배지 0건**. 목업↔실앱 동일 화면ID 1:1.

---

## 6. 세션별 담당·목표 요약 (레인 카드)

### 허브 (프로젝트 관리)
- **담당**: chief(총괄) + qa-lead·plan-lead(게이트 조율) + dba(ERD 통합).
- **역할**: 검증 게이트·`_ledger` 집계·검산 · WBS·이력·`docs/report` · `docs/data-model/ERD.md` 통합 뷰 · `solsol-mng` 배포 · 공유 인증 테이블 변경 중재.
- **스키마 authoring 없음**(제품이 소유). solsol-mng 산출물의 단일 커밋·배포 지점.

### 쏠쏠 (풀스택 + `solsol_lms` 스키마)
- **담당**: 강프개(frontend·FR01)·임관개(admin·AD01)·조백개(api-developer·solsol-api)·배현우(lms)·오품관(qa)·노개보(privacy)·한데관(dba·tenant 스키마)·ux-designer.
- **소유**: `solsol`·`solsol-admin`·`solsol-api` 앱 + **`solsol_lms`(tenant 92) 스키마·마이그·ORM** + 목업.
- **목표 blocker(+critical)**: `AD01-cttee-r01-D01`(RBAC)·`SEC-cttee-r01-D02`(demo-login)·`API-cttee-r01-D01`(주문내역 EP)·`SEC-cttee-r02-D01`(solsol-api health/db)·**owner 실비번 git 커밋 로테이트**(+deployer).
- **잔여**: FR01 조회 실연동 필드매핑·AD01 쓰기 CRUD 확장·목업 K-1~K-5. **공유 인증 테이블 변경은 §4-2 경유.**

### 쏠쏠 브랜드 (풀스택 + `solsol`(master) 스키마)
- **담당**: 강프개(frontend)·임관개(admin)·조백개(api-developer·brand-api)·배보검(security)·오품관(qa)·노개보(privacy)·한데관(dba·master 스키마)·ux-designer.
- **소유**: `solsol-brand`·`solsol-brand-admin`·`solsol-brand-api` 앱 + **`solsol`(master 17) 스키마·마이그·ORM**(공유 인증 테이블 DDL 포함) + 목업.
- **목표 blocker**: `PRV-cttee-r02-D01`(셀러 PII)·`SEC-1`(크레딧 조정 멱등)·`SEC-VC-01`(이메일코드 오프라인탐색) + brand 인증·쓰기 실연동 · `[TEST-ONLY]` 인증번호 `400039` 원복 · 오너 판정 3건.

---

## 7. 오너 결정 대기 (세션 진행 게이트)
- PG(TOSS) staging-gate 해제(쏠쏠·브랜드 결제 공통)
- K-1~K-5(마스킹·반응형 범위·화면ID SoT·브랜드 색상·인증코드 표준값)
- refresh 쿠키 크로스도메인 전략 · 국외이전 동의(법무)

---

## 8. 스키마 소유 분할 (완료 — Phase A)
- backend-db 세션이 데이터 정본 단일화·계약 발행을 끝내(프리즈), 스키마를 **물리 단위로 분할**해 제품에 흡수했다:
  - **`solsol`(master 17테이블)** = 쏠쏠 브랜드 소유(플랫폼: 셀러·사이트·플랜·구독·결제·크레딧·문의·소식 + 공유 인증).
  - **`solsol_lms`(tenant 92테이블)** = 쏠쏠 소유(크리에이터 LMS).
  - **허브** = ERD 통합 뷰 + 공유 인증 테이블 변경 중재(스키마 authoring 없음).
- 물리 Aurora `solsol` 스키마는 하나지만 **테이블 DDL 소유가 분리** — 각자 자기 테이블만 마이그레이션. 공유 인증 테이블(`TB_USER` 등) DDL 변경만 허브 중재(frozen·드묾).
