# 개발 세션 운영 계획 (Claude Code 세션 분할)

> **작성**: 2026-07-02 (KST) · 총괄(chief) · **오너 확정: B → A 단계적**
> **근거**: `docs/report/검증위원회-통합보고서-20260702.md`(open blocker 8) · `쏠쏠/브랜드-미결취합-20260702.md`
> **원칙**: 기존 8분할(DB·백엔드·관리자단·사용자단·브랜드 관리·브랜드 사용·관리목업·사용목업) 폐지.

## 0. 왜 이 구조인가 (핵심 1줄)
open blocker 8건 중 **5건이 백엔드·데이터**이고 근본원인이 **정본 표류(master.sql↔ERD↔ORM 4자 비동기)**. `solsol-api`·`solsol-brand-api`가 **같은 Aurora master 스키마 `solsol`을 공유**하므로, 백엔드/데이터는 **한 세션이 단독 소유**해야 드리프트가 재발하지 않는다.

## 1. 단계 (Phase)

- **Phase B (현재 — 블로커 해소기)**: **3 작업 세션 + 허브** 병행 — `backend-db`(공유 DB·데이터 정본) + `solsol`(풀스택) + `solsol-brand`(풀스택). 공유 데이터 정본을 backend-db가 **단독 소유**해 드리프트 차단 + 데이터 정본 프리즈.
- **Phase A (안정화 후 — 목표)**: **backend-db를 쏠쏠 세션에 흡수** → **2 작업 세션**(쏠쏠 / 쏠쏠 브랜드) + 허브. 쏠쏠이 데이터 정본까지 단독 소유.
- **전환 기준(B→A)**: ① 데이터모델 SoT 단일화·프리즈(DAT-D01·D02·r03-D02 close) ② 백엔드 open blocker 0 ③ API 계약 프리즈 발행 완료.

> **쏠쏠·쏠쏠 브랜드는 각각 풀스택**(사용자단+관리자단+백엔드). 두 제품이 공유하는 **DB·마스터 스키마·데이터 정본만** backend-db 세션이 단독 소유한다.

---

## 2. 세션 정의 (Phase B)

### backend-db — 쏠쏠 사이트 백엔드 및 DB (공유 데이터 정본 단독 소유)
- **레포**: `solsol-mng/docs/data-model`(정본) + `solsol-api`·`solsol-brand-api`의 **스키마·마이그레이션·ORM 정의**.
- **범위**: Aurora(master/tenant) 스키마·마이그레이션·시드 정합 · 크레딧 모델 · 데이터측 보안(health/PII 스키마) · **API 계약 발행(/doc)**.
- **소유(정본)**: `master.sql`·`tenant_template.sql`·`ERD.md`·ORM `schema.master.ts` — **이 세션만 수정**. (제품 세션은 API 앱 라우트/로직만; 스키마 변경은 여기 경유.)
- **담당**: 한데관(dba)·조백개(api-developer)·배보검(security-reviewer)·노개보(privacy-officer) + 정본 단일화 결정에 architect.
- **책임 blocker**: DAT-cttee-r01-D01(크레딧 스키마)·DAT-cttee-r01-D02(master.sql 드리프트)·data-model-r03-D02(크레딧 멱등 uk).
- **선결 결정(오너/architect)**: "어느 사본이 정본인가 + 브랜드 테이블(TB_CONTACT/REPLY/NEWS)이 크리에이터 master 스코프인가" 단일화 → 4자 동기.

### 쏠쏠 — 풀스택 (사용자단 + 관리자단 + 백엔드)
- **레포**: `solsol`(FR01 사용자단) · `solsol-admin`(AD01 관리자단) · `solsol-api`(앱 계층) · 목업.
- **범위**: 화면·상태·인터랙션·마스킹 표시·쓰기 CRUD + **solsol-api 라우트·비즈니스 로직**. **스키마·데이터 정본은 backend-db 경유**(계약 소비).
- **담당**: 강프개(frontend·FR01)·임관개(admin·AD01)·조백개(api-developer·solsol-api 앱)·배현우(lms)·오품관(qa)·노개보(privacy)·ux-designer.
- **책임 blocker(+critical)**: AD01-cttee-r01-D01(RBAC 직접 URL)·SEC-cttee-r01-D02(demo-login fail-open)·API-cttee-r01-D01(주문내역 EP)·SEC-cttee-r02-D01(solsol-api health/db 무인증)·**Critical** owner 실비번 git 커밋 로테이트(+deployer).
- **잔여**: FR01 조회 실연동 필드매핑 · AD01 쓰기 CRUD 도메인 확장 · 목업 K-1~K-5 반영.

### 쏠쏠 브랜드 — 풀스택 (사용자단 + 관리자단 + 백엔드)
- **레포**: `solsol-brand`(사용자단) · `solsol-brand-admin`(관리자단·BA01) · `solsol-brand-api`(앱 계층) · 목업.
- **범위**: 화면·인증/쓰기 실연동 + **brand-api 라우트·비즈니스 로직**. 스키마·데이터 정본은 backend-db 경유.
- **담당**: 강프개(frontend)·임관개(admin)·조백개(api-developer·brand-api 앱)·배보검(security)·오품관(qa)·노개보(privacy)·ux-designer.
- **책임 blocker**: PRV-cttee-r02-D01(셀러 PII 무마스킹)·SEC-1(크레딧 조정 멱등·원자성).
- **의존**: brand-admin 실전환·크레딧 조정 노출은 **운영자 시드 + SEC-1 해소 후**(그 전까지 목업/mock 유지).
- **잔여**: 인증·쓰기 실연동 · [TEST-ONLY] 인증번호 `400039` 원복 · 오너 판정 3건(color-contrast·모바일 반응형·C01 약관모달).

> **관리 허브 `solsol-mng`은 세션에 포함하지 않는다**(검증 대상 비적용) — 모든 세션의 **공통 정본·조율 지점**으로만 쓴다.

---

## 3. 세션 간 조율 장치 (필수)
1. **데이터정본 단일 소유** — master.sql·ERD·ORM은 세션 ①만 수정. ②③은 읽기·변경요청만.
2. **API 계약 프리즈** — ①이 계약(엔드포인트·요청/응답 봉투·에러코드)을 확정·발행(`solsol-api /doc`·`brand-api /doc` Scalar). ②③은 그것만 소비, 임의 변경 금지.
3. **공유 블로커 원장** — `docs/dev-validation/_ledger.md`(허브)를 세션 공통 추적기로. 각 세션이 담당 blocker를 open/close.
4. **검증 게이트** — `docs/DEV_VALIDATION_PROCESS.md` 단일 정본. 화면=②③(9축), 계약·데이터=①(데이터 5축), 실연동=security·privacy 서명 필수.
5. **금지(모든 세션 공통)** — `docs/validation/` 무수정 · 커밋/푸시/배포는 오너 명시 시만 · 시크릿·PII 평문 노출 금지 · 비가역(실결제·계정삭제) 사용자 확인.

---

## 4. 오너 결정 대기 (세션 착수 전/중 필요)
- **데이터 정본 단일화** + 브랜드 테이블 master 스코프 여부(→ backend-db 착수 선결).
- **PG(TOSS) staging-gate 해제** 여부(쏠쏠·브랜드 결제 공통).
- **K-1~K-5**(마스킹·반응형 범위·화면ID SoT·브랜드 색상·인증코드 표준값).
- **refresh 쿠키 크로스도메인** 전략(동일도메인 정렬/프록시).
- **국외이전 동의**(GA/Meta·AI) 법무 자문.

---

## 5. 세션 시작 프롬프트 (복붙용)

### backend-db (쏠쏠 사이트 백엔드 및 DB)
```
너는 쏠쏠 "백엔드·DB(공유 데이터 정본)" 세션의 총괄이다. 소유: solsol-mng/docs/data-model 정본 +
solsol-api·solsol-brand-api의 스키마·마이그레이션·ORM. 먼저 solsol-mng/docs/report/검증위원회-통합보고서-20260702.md,
docs/DEV_VALIDATION_PROCESS.md, docs/dev-validation/_ledger.md, docs/DEV_SESSION_PROTOCOL.md 를 읽어라.
이 세션은 공유 master/tenant 스키마·마이그레이션·데이터 정본·API 계약을 단독 소유한다(제품 세션은 API 앱만).
목표: 데이터 정본 단일화(4자 동기: master.sql=ERD=README=ORM) + blocker DAT-D01·DAT-D02·r03-D02 해소 + API 계약 발행(/doc).
글로벌 팀(한데관·조백개·배보검·노개보 + architect)으로 팀장 경유 4단계. 검증=데이터 5축.
결과는 허브에 보고(허브가 _ledger 집계). 정본 무수정·커밋/배포는 오너 명시 시만.
docs/transcripts/<오늘>/backend-db.md 에 프롬프트·에이전트 소통 기록(시크릿 금지).
```

### 쏠쏠 (풀스택)
```
너는 "쏠쏠"(풀스택: 사용자단 FR01 + 관리자단 AD01 + 백엔드 solsol-api 앱) 세션의 총괄이다.
레포: solsol·solsol-admin·solsol-api(+목업). 먼저 solsol-mng/docs/report/쏠쏠-미결취합-20260702.md,
검증위원회-통합보고서, _ledger, docs/DEV_SESSION_PROTOCOL.md 를 읽어라.
공유 스키마·데이터 정본은 backend-db 세션 소유 — API 계약은 발행분만 소비, 스키마 변경은 backend-db 경유.
목표: blocker AD01-D01(RBAC)·SEC-D02(demo-login)·API-D01(주문내역 EP)·SEC-r02-D01(health/db)·owner 비번 로테이트(critical)
+ FR01 조회 실연동·AD01 쓰기 CRUD·목업 K-1~K-5.
글로벌 팀(강프개·임관개·조백개·배현우·오품관·노개보·ux)으로 4단계. 검증=화면 9축(+solsol-api 계약).
결과는 허브에 보고. docs/transcripts/<오늘>/solsol.md 에 기록(시크릿 금지).
```

### 쏠쏠 브랜드 (풀스택)
```
너는 "쏠쏠 브랜드"(풀스택: 사용자단 + 관리자단 + 백엔드 brand-api 앱) 세션의 총괄이다.
레포: solsol-brand·solsol-brand-admin·solsol-brand-api(+목업). 먼저 solsol-mng/docs/report/브랜드-미결취합-20260702.md,
검증위원회-통합보고서, _ledger, docs/DEV_SESSION_PROTOCOL.md 를 읽어라.
공유 master 스키마·데이터 정본은 backend-db 세션 소유(무수정). API 계약은 발행분만 소비.
brand-admin 실전환·크레딧 조정은 운영자 시드 + SEC-1 해소 후.
목표: blocker PRV-r02-D01(셀러 PII)·SEC-1(크레딧 조정 멱등) + 인증·쓰기 실연동 · [TEST-ONLY] 인증번호 원복 · 오너 판정 3건.
글로벌 팀(강프개·임관개·조백개·배보검·오품관·ux)으로 4단계. 검증=화면 9축(+brand-api 계약).
결과는 허브에 보고. docs/transcripts/<오늘>/solsol-brand.md 에 기록(시크릿 금지).
```

---

## 6. Phase A 전환 (목표 2세션)
- **쏠쏠** = 현 쏠쏠 세션 + **backend-db(공유 데이터 정본) 흡수** → 사용자·관리·백엔드·목업 + 데이터 정본 단독 소유.
- **쏠쏠 브랜드** = 현 브랜드 세션 유지(brand-api 앱층 포함, 스키마 변경은 쏠쏠 경유).
- 전환 시점: §1 전환 기준 3건 충족 후. 그때 본 문서 §2를 2세션으로 개정.
