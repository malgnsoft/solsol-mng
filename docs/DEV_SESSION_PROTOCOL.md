# 쏠쏠 개발 세션 협업 규약 (각 세션 공통 전달용)

> **작성**: 2026-07-02 (KST) · 총괄(chief) · **모든 세션은 착수 전 본 문서를 읽는다.**
> **상위 계획**: [DEV_SESSION_PLAN.md](DEV_SESSION_PLAN.md) (범위·담당·시작 프롬프트) · **검증 정본**: [DEV_VALIDATION_PROCESS.md](DEV_VALIDATION_PROCESS.md) · **블로커 원장**: `docs/dev-validation/_ledger.md`
> **단계**: 현재 **Phase B**(3 작업 세션 + 허브). 데이터 정본 프리즈 + 백엔드 blocker 0 달성 후 **Phase A**(2세션)로 축소.

---

## 1. 세션 구성 (4창)

| 창 이름(예) | 역할 | 레포(작업 디렉터리) |
|---|---|---|
| 프로젝트 관리 | **허브** (조율·정본·집계) | `solsol-mng` |
| 쏠쏠 사이트 백엔드 및 DB 관리 | **① 공통 백엔드·데이터 spine** | `solsol-api` · `solsol-brand-api` · `solsol-mng/docs/data-model` |
| 쏠쏠 (구현) | **② 쏠쏠 프론트** | `solsol` · `solsol-admin` (+ 목업) |
| 쏠쏠 브랜드 | **③ 브랜드 프론트** | `solsol-brand` · `solsol-brand-admin` (+ 목업) |

> 각 세션은 **해당 있는 글로벌 에이전트**(`~/.claude/agents/`)만 팀장 경유 4단계로 참여한다.

---

## 2. 편집 소유 경계 (⚠️ 가장 중요 — 충돌 방지)

`solsol-mng`을 **허브와 spine이 공유**하므로, 내부 편집 소유를 아래로 고정한다. **소유자가 아닌 세션은 해당 경로를 수정하지 않는다.**

| 경로/자산 | 편집 소유 | 다른 세션 |
|---|---|---|
| `solsol-mng/docs/data-model/`(`master.sql`·`tenant_template.sql`·`ERD.md`) | **① spine** | 읽기만 · 변경요청 |
| 백엔드 ORM `schema.master.ts`·마이그레이션·API 계약 | **① spine** | 읽기만 |
| `solsol-mng/docs/validation/`(정본·읽기전용) | **아무도 수정 안 함**(원본 무수정) | 전원 읽기만 |
| `solsol-mng/docs/validation_modified/`(개정본) | **허브**(오너 승인 후 개정 완성본 + `_개정이력.md` 전후 기록) | 전원 읽기만 · 개정 필요 시 허브에 요청 |
| `DEV_VALIDATION_PROCESS`·`WBS`·`docs/history`·`docs/report` | **허브** | — |
| **`docs/dev-validation/_ledger.md`(블로커 원장)** | **허브 단독 기록** | 아래 §3 |
| `solsol`·`solsol-admin` 앱 | **② 쏠쏠 프론트** | — |
| `solsol-brand`·`solsol-brand-admin` 앱 | **③ 브랜드 프론트** | — |

> **데이터 정본(master.sql/ERD/ORM)은 오직 spine만 수정한다.** 이것이 현재 #1 블로커(정본 표류)의 재발을 막는 핵심 규칙이다.

---

## 3. 블로커 원장(`_ledger.md`) 규칙 — 허브 단독 기록

세션들은 git 브랜치가 아니라 **같은 파일시스템**에서 동시에 돈다 → 여러 세션이 `_ledger.md`를 직접 편집하면 서로 덮어쓴다.

- **각 작업 세션**: 자기 결함표는 **자기 레포/`solsol-mng/docs/dev-validation/<영역>-r<NN>.md`** 에 기록. blocker를 열거나 닫으면 **허브에 보고**(결함ID·상태·근거).
- **허브**: 보고를 받아 **`_ledger.md`를 단독 갱신**하고 "blocker 0" 검산·WBS 반영.
- 결함ID = `<영역>-r<NN>-D##`(안정 ID). 표준 결함표 템플릿 = `DEV_VALIDATION_PROCESS.md` §6.

---

## 4. 세션 간 인터페이스

1. **API 계약 프리즈** — ① spine이 계약(엔드포인트·요청/응답 봉투·에러코드)을 확정·**발행**한다: `solsol-api /doc`·`solsol-brand-api /doc`(Scalar). **②③은 발행된 계약만 소비**하고 임의로 스키마·계약을 바꾸지 않는다(불일치는 spine에 변경요청).
2. **데이터 정본 단일화 결정** — "어느 사본이 정본인가 + 브랜드 테이블(TB_CONTACT/REPLY/NEWS)이 크리에이터 master 스코프인가"는 ① spine이 **오너/architect 확인 후** 확정 → `master.sql=ERD=README=ORM` 4자 동기.
3. **브랜드 실전환 의존** — ③의 brand-admin 실전환·크레딧 조정 노출은 ①의 **운영자 시드 + SEC-1(크레딧 멱등·원자성) 해소 이후**. 그 전까지 mock/목업 유지.
4. **결정 사항 기록** — 오너·세션 간 합의는 **허브가 기록**(WBS·history·본 문서 갱신).

---

## 5. 공통 금지 (전 세션)

- `docs/validation/` **무수정**(원본 보존). 개정은 오너/기획-lead 승인 후 **`docs/validation_modified/` 에 동일 파일명 완성본 + `_개정이력.md` 전후 기록**(허브가 처리). 검증·개발은 **개정본 우선 → 없으면 원본**.
- **커밋·푸시·배포는 오너가 명시할 때만**. 기본은 분석·구현·검증까지.
- **시크릿·PII 평문**을 출력·로그·커밋에 남기지 않는다(위치·유형만).
- **비가역**(실결제·실환불·계정삭제·데이터 영구삭제)은 사용자/운영자 확인 전 자동 진행 금지.
- 소유 경계(§2) 밖 파일을 수정하지 않는다.

---

## 6. 세션별 담당·목표 요약 (레인 카드)

### ① 공통 백엔드·데이터 spine
- **담당**: 한데관(dba)·조백개(api-developer)·배보검(security-reviewer)·노개보(privacy-officer) + architect(정본 결정).
- **목표 blocker(6)**: `DAT-cttee-r01-D01`(크레딧 스키마)·`DAT-cttee-r01-D02`(master.sql 드리프트)·`data-model-r03-D02`(크레딧 멱등 uk)·`SEC-cttee-r02-D01`(health/db 무인증)·`PRV-cttee-r02-D01`(brand 셀러 PII 무마스킹)·`SEC-1`(브랜드 크레딧 조정 멱등·원자성).
- **산출**: 데이터 정본 4자 동기 + API 계약 발행(/doc) + 결제 staging-gate·refresh 원장·시드 정리.

### ② 쏠쏠 프론트 (크리에이터)
- **담당**: 강프개(frontend·FR01)·임관개(admin·AD01)·배현우(lms)·오품관(qa)·노개보(privacy)·ux-designer.
- **목표 blocker(2+critical)**: `AD01-cttee-r01-D01`(RBAC 직접 URL 미들웨어)·`SEC-cttee-r01-D02`(demo-login fail-open)·**owner 실비번 git 커밋 로테이트**(+deployer).
- **잔여**: `API-cttee-r01-D01`(useOrder→/api/orders 정렬·① 계약 조율)·FR01 조회 실연동 필드매핑·AD01 쓰기 CRUD 도메인 확장·목업 K-1~K-5.

### ③ 브랜드 프론트
- **담당**: 강프개(frontend)·임관개(admin)·오품관(qa)·배보검(security)·ux-designer.
- **목표**: brand 인증·쓰기 실연동(① 계약·시드 이후) · `[TEST-ONLY]` 인증번호 `400039` 원복 · 오너 판정 3건(color-contrast·모바일 반응형·C01 약관 상세 모달).
- **제약**: master SoT 무수정 — 브랜드 3레포 **애플리케이션 계층만** 전진.

---

## 7. 오너 결정 대기 (세션 진행 게이트)
- 데이터 정본 단일화 + 브랜드 테이블 master 스코프(→ ① 선결)
- PG(TOSS) staging-gate 해제(쏠쏠·브랜드 결제 공통)
- K-1~K-5(마스킹·반응형 범위·화면ID SoT·브랜드 색상·인증코드 표준값)
- refresh 쿠키 크로스도메인 전략 · 국외이전 동의(법무)

---

## 8. Phase A 전환 (목표 2세션)
- 전환 기준: 데이터 정본 프리즈(DAT-D01·D02·r03-D02 close) + 백엔드 blocker 0 + API 계약 프리즈 발행.
- 전환 시: ① spine을 **쏠쏠 세션에 흡수**(쏠쏠 = 사용자·관리·백엔드·목업 + 데이터정본 단독 소유), 브랜드 = 프론트 + brand-api 앱층(스키마 변경은 쏠쏠 경유). 본 문서 §1·§6을 2세션으로 개정.
