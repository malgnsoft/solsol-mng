# 개발 세션 운영 계획 (Claude Code 세션 분할)

> **작성**: 2026-07-02 (KST) · 총괄(chief) · **오너 확정: B → A 단계적**
> **근거**: `docs/report/검증위원회-통합보고서-20260702.md`(open blocker 8) · `쏠쏠/브랜드-미결취합-20260702.md`
> **원칙**: 기존 8분할(DB·백엔드·관리자단·사용자단·브랜드 관리·브랜드 사용·관리목업·사용목업) 폐지.

## 0. 왜 이 구조인가 (핵심 1줄)
open blocker 8건 중 **5건이 백엔드·데이터**이고 근본원인이 **정본 표류(master.sql↔ERD↔ORM 4자 비동기)**. `solsol-api`·`solsol-brand-api`가 **같은 Aurora master 스키마 `solsol`을 공유**하므로, 백엔드/데이터는 **한 세션이 단독 소유**해야 드리프트가 재발하지 않는다.

## 1. 단계 (Phase A — 현재)

**3세션** — 허브 + 풀스택 2제품. 백엔드·DB를 제품에 흡수하고, **DB는 물리 스키마 단위로 소유 분할**(오너 확정 2026-07-02):
- **`solsol`(master 17테이블)** → 쏠쏠 브랜드 소유(플랫폼: 셀러·사이트·플랜·구독·결제·크레딧·문의·소식 + 공유 인증).
- **`solsol_lms`(tenant 92테이블)** → 쏠쏠 소유(크리에이터 LMS).
- **허브** → 조율·검증·`_ledger`·WBS·`ERD.md` 통합(스키마 authoring 없음).

> 배경: backend-db 세션이 데이터 정본 단일화·API 계약 발행을 끝내(프리즈) 드리프트 위험을 제거 → 스키마를 물리 단위로 나눠 제품에 흡수. 공유 인증 테이블(`TB_USER` 등)만 허브 중재(frozen·드묾).

---

## 2. 세션 정의 (3세션)

### 허브 — 프로젝트 관리 (`solsol-mng`)
- **역할**: 검증 게이트·`_ledger` 집계·검산 · WBS·이력·`docs/report` · `docs/data-model/ERD.md` 통합 뷰 · `solsol-mng` 배포 · **공유 인증 테이블 변경 중재**.
- **담당**: chief + qa-lead·plan-lead + dba(ERD 통합). **스키마 authoring 없음**.

### 쏠쏠 — 풀스택 + `solsol_lms`(tenant) 스키마
- **레포·소유**: `solsol`(FR01)·`solsol-admin`(AD01)·`solsol-api`(앱) + **`solsol_lms`(tenant 92) 스키마·마이그·ORM** + 목업.
- **담당**: 강프개(frontend·FR01)·임관개(admin·AD01)·조백개(api-developer·solsol-api)·배현우(lms)·한데관(dba·tenant)·오품관(qa)·노개보(privacy)·ux.
- **책임 blocker(+critical)**: AD01-cttee-r01-D01(RBAC)·SEC-cttee-r01-D02(demo-login)·API-cttee-r01-D01(주문내역 EP)·SEC-cttee-r02-D01(solsol-api health/db)·**owner 실비번 로테이트**(+deployer).
- **잔여**: FR01 조회 실연동 필드매핑·AD01 쓰기 CRUD 확장·목업 K-1~K-5. 공유 인증 테이블 변경은 허브 중재.

### 쏠쏠 브랜드 — 풀스택 + `solsol`(master) 스키마
- **레포·소유**: `solsol-brand`·`solsol-brand-admin`(BA01)·`solsol-brand-api`(앱) + **`solsol`(master 17) 스키마·마이그·ORM**(공유 인증 테이블 DDL 포함) + 목업.
- **담당**: 강프개(frontend)·임관개(admin)·조백개(api-developer·brand-api)·한데관(dba·master)·배보검(security)·오품관(qa)·노개보(privacy)·ux.
- **책임 blocker**: PRV-cttee-r02-D01(셀러 PII)·SEC-1(크레딧 조정 멱등)·SEC-VC-01(이메일코드 오프라인탐색).
- **잔여**: 인증·쓰기 실연동 · [TEST-ONLY] 인증번호 `400039` 원복 · 오너 판정 3건(color-contrast·모바일 반응형·C01 약관모달).

> 배포 범위·편집 소유 경계·인터페이스는 [DEV_SESSION_PROTOCOL.md](DEV_SESSION_PROTOCOL.md) §1·§2·§4-B 참조.

---

## 3. 세션 간 조율 장치 (필수)
1. **스키마 DDL 단일 소유** — `solsol`(master) DDL=쏠쏠 브랜드 · `solsol_lms`(tenant) DDL=쏠쏠. 상대는 읽기·변경요청. 공유 인증 테이블은 허브 중재.
2. **API 계약** — 각 백엔드가 `/doc`(Scalar)로 발행. 상대 제품은 발행분만 소비, 임의 변경 금지.
3. **공유 블로커 원장** — `docs/dev-validation/_ledger.md`(허브)를 세션 공통 추적기로. 각 세션이 담당 blocker를 open/close(허브 집계).
4. **검증 게이트** — `docs/DEV_VALIDATION_PROCESS.md`·`IMPLEMENTATION_STANDARD.md` 정본. 화면 9축 + 실연동(계약·데이터 5축) + security·privacy 서명 + MOCK 배지 0.
5. **배포 범위** — 각 세션 자기 소유 레포·스키마만([DEV_SESSION_PROTOCOL.md](DEV_SESSION_PROTOCOL.md) §4-B).
6. **금지(공통)** — `docs/validation/` 무수정 · 커밋/푸시/배포는 오너 명시 시만 · 시크릿·PII 평문 금지 · 비가역 사용자 확인.

---

## 4. 오너 결정 대기 (세션 진행 게이트)
- **PG(TOSS) staging-gate 해제** 여부(쏠쏠·브랜드 결제 공통).
- **K-1~K-5**(마스킹·반응형 범위·화면ID SoT·브랜드 색상·인증코드 표준값).
- **refresh 쿠키 크로스도메인** 전략(동일도메인 정렬/프록시).
- **국외이전 동의**(GA/Meta·AI) 법무 자문.

---

## 5. 세션 시작 프롬프트 (복붙용)

### 쏠쏠 (풀스택 + solsol_lms 스키마)
```
너는 "쏠쏠"(풀스택: 사용자단 FR01 + 관리자단 AD01 + 백엔드 solsol-api + 테넌트 스키마 solsol_lms) 세션의 총괄이다.
소유: solsol·solsol-admin·solsol-api 앱 + solsol_lms(tenant) 스키마·마이그·ORM(solsol-mng/docs/data-model/tenant_template.sql).
먼저 solsol-mng/docs/report/쏠쏠-미결취합-20260702.md, 검증위원회-통합보고서, _ledger,
docs/DEV_SESSION_PROTOCOL.md, docs/IMPLEMENTATION_STANDARD.md 를 읽어라.
공유 인증 테이블(TB_USER·TB_SITE 등, solsol master)은 쏠쏠 브랜드 소유 — 변경 필요 시 허브 중재로 요청.
목표: blocker AD01-D01(RBAC)·SEC-D02(demo-login)·API-D01(주문내역 EP)·SEC-r02-D01(health/db)·owner 비번 로테이트(critical)
+ FR01 조회 실연동·AD01 쓰기 CRUD·목업 K-1~K-5.
글로벌 팀(강프개·임관개·조백개·배현우·한데관·오품관·노개보·ux) 4단계. 검증=화면 9축+데이터5축(tenant)+계약. MOCK 배지 0.
결과·blocker는 허브에 보고. docs/transcripts/<오늘>/solsol.md 기록(시크릿 금지). 커밋/배포는 오너 명시 시만.
```

### 쏠쏠 브랜드 (풀스택 + solsol master 스키마)
```
너는 "쏠쏠 브랜드"(풀스택: 사용자단 + 관리자단 + 백엔드 brand-api + master 스키마 solsol) 세션의 총괄이다.
소유: solsol-brand·solsol-brand-admin·solsol-brand-api 앱 + solsol(master) 스키마·마이그·ORM(공유 인증 테이블 DDL 포함,
solsol-mng/docs/data-model/master.sql). 먼저 solsol-mng/docs/report/브랜드-미결취합-20260702.md, 검증위원회-통합보고서,
_ledger, docs/DEV_SESSION_PROTOCOL.md, docs/IMPLEMENTATION_STANDARD.md 를 읽어라.
공유 인증 테이블 DDL 변경은 허브 중재(solsol-api 영향). 테넌트 스키마는 쏠쏠 소유.
목표: blocker PRV-r02-D01(셀러 PII)·SEC-1(크레딧 조정 멱등)·SEC-VC-01(이메일코드 오프라인탐색)
+ 인증·쓰기 실연동 · [TEST-ONLY] 인증번호 원복 · 오너 판정 3건.
글로벌 팀(강프개·임관개·조백개·한데관·배보검·오품관·ux) 4단계. 검증=화면 9축+데이터5축(master)+계약. MOCK 배지 0.
결과·blocker는 허브에 보고. docs/transcripts/<오늘>/solsol-brand.md 기록(시크릿 금지). 커밋/배포는 오너 명시 시만.
```

> 허브(이 창)는 이미 실행 중이라 별도 개시 프롬프트 불필요. 작업 지시 프롬프트(목업/실앱/시드/검증)는 [IMPLEMENTATION_STANDARD.md](IMPLEMENTATION_STANDARD.md) §7.

---

## 6. 스키마 소유 분할 근거 (참고)
- `solsol`(master)는 대부분 브랜드/플랫폼 테이블(17 중 11)이라 쏠쏠 브랜드가 소유하는 게 자연스럽다. 공유 인증 6테이블(`TB_USER`·`TB_SITE`·`TB_SESSION`·`TB_SITE_USER`·`TB_USER_AGREEMENT`·`TB_LOGIN_LOG`)은 물리적으로 master에 있어 DDL 소유=쏠쏠 브랜드, solsol-api는 런타임 사용 + 스키마 변경 시 허브 중재.
- `solsol_lms`(tenant 92)는 크리에이터 LMS 전용 → 쏠쏠 단독.
- 물리 스키마는 각 1개(`solsol`·`solsol_lms`)지만 소유가 깔끔히 분리돼 드리프트 위험이 낮다.
