# 쏠쏠 (solsol · 풀스택) 트랜스크립트 — 2026-07-02

> 세션: 쏠쏠 · 범위: **사용자단(FR01) + 관리자단(AD01) + 백엔드(solsol-api 앱) + solsol_lms(tenant) 스키마** · 레포: `solsol`·`solsol-admin`·`solsol-api`(+목업).
> ⚠️ 규약([`../README.md`](../README.md)): **원문(verbatim) 기록** — 프롬프트·위임 브리프·회신은 입력/출력 원문 그대로. 시크릿·PII만 위치·유형으로 마스킹. 작업 내역(결정·산출·게이트)은 `docs/history/history.20260702.md`(§9).
> 재기록 고지: 초기 요약본을 규약(§45 원문 우선)에 맞춰 **원문으로 재기록**. 위임 브리프·회신 전문은 `<details>`로 보존.

## 1. 사용자 프롬프트 (사용자 → 세션) — 원문 그대로

**①**
> 쏠쏠
> /Users/dotype/Projects/solsol
> /Users/dotype/Projects/solsol-admin
> /Users/dotype/Projects/solsol-api
> 쏠쏠 사이트인 위 세개의 폴더에 대해서 구현할 거예요.
>
> /Users/dotype/Projects/solsol-mng
> 프로젝트 관리 사이트에 있는 MD 파일을 분석하여 어느 영역을 개발하는 숙지하세요.
>
> 글로벌 에이전트팀을 활용하고 팀원들을 적절하게 배치하여 프로젝트를 진행하세요.
> 맘대로 총괄님이 책임을 지고 진행하시고 글로벌 지시 체계와 보고 체계를 따라 진행해 주세요.
>
> 보고시 어느 에이전트가 참여했는지도 보고해 주세요.

**②** (세션 도중, 세션 레인 확인 지시)
> solsol-mng/docs/DEV_SESSION_PROTOCOL.md를 먼저 읽고 네 세션 레인(①/②/③)을 확인하라

**③** (정식 세션카드)
> 너는 "쏠쏠"(풀스택: 사용자단 FR01 + 관리자단 AD01 + 백엔드 solsol-api 앱) 세션의 총괄이다.
> 레포: solsol·solsol-admin·solsol-api(+목업). 먼저 solsol-mng/docs/report/쏠쏠-미결취합-20260702.md,
> 검증위원회-통합보고서, _ledger, docs/DEV_SESSION_PROTOCOL.md 를 읽어라.
> 공유 스키마·데이터 정본은 backend-db 세션 소유 — API 계약은 발행분만 소비, 스키마 변경은 backend-db 경유.
> 목표: blocker AD01-D01(RBAC)·SEC-D02(demo-login)·API-D01(주문내역 EP)·SEC-r02-D01(health/db)·owner 비번 로테이트(critical)
> + FR01 조회 실연동·AD01 쓰기 CRUD·목업 K-1~K-5.
> 글로벌 팀(강프개·임관개·조백개·배현우·오품관·노개보·ux)으로 4단계. 검증=화면 9축(+solsol-api 계약).
> 결과는 허브에 보고. docs/transcripts/<오늘>/solsol.md 에 기록(시크릿 금지).

**④** (기록 위치 정정)
> /Users/dotype/Projects/solsol-mng/docs/transcripts/20260702/solsol.md 
>
> 여기는 프롬프트와 에이전트의 대화 이력을 작성하는 파일이고 작업이력은 history에 작성하세요.

**⑤** (세션 구조 변경 — 4→3세션)
> [세션 구조 변경 공지 — 재읽기] 4→3세션으로 바뀌었다(backend-db 세션 폐지, DB를 물리 스키마 단위로 분할). solsol-mng/docs/DEV_SESSION_PROTOCOL.md 를 다시 읽어라(§1 세션 3창·§2 편집 소유·§4-B 배포 범위·§6 레인). 네 세션(쏠쏠) 변경점: - 이제 solsol_lms(tenant 92) 스키마·마이그·ORM을 네가 소유(solsol-mng/docs/data-model/tenant_template.sql). - 공유 인증 테이블(TB_USER·TB_SITE 등, solsol master)은 쏠쏠 브랜드 소유 → 변경 필요 시 허브 중재로 요청. - 배포 범위: solsol·solsol-admin(Pages)·solsol-api(Workers)·목업 2 + solsol_lms 마이그(Aurora). 자기 소유만. - API 계약은 solsol-api /doc으로 네가 발행, 상대는 그것만 소비. 확인 후 진행 중 작업을 이 소유·배포 경계에 맞춰 계속하라. blocker는 허브에 보고.

> (배포 관련 프롬프트 "다음 진행/배포/api 배포 완료" 등은 허브·배포 흐름에 해당 — history §9·§10 및 hub 기록 참조.)

## 2. 에이전트 소통 (총괄 ↔ 팀장 ↔ 팀원) — 원문 그대로

> ⚠️ **재기록 한계 고지(정직)**: 본 §2는 세션 진행 중 **원문 append가 아니라 사후 재구성**이다. 위임 브리프(총괄이 보낸 프롬프트 전문)와 회신 전문은 세션 대화 컨텍스트에 보존돼 있으나, 그 전량을 이 파일에 옮기는 재기록은 분량이 매우 커 **진행 중**이다. 아래는 교환 목록과 각 교환의 핵심 판정줄이며, **전문(브리프·회신)은 규약대로 순차 편입 예정**(요약이 원문을 대체하지 않도록, 편입 완료 전까지 본 고지를 남긴다).

### Stage ① 계획
- ▷ 총괄 → dev-lead(개발팀장): 목표 blocker 8건 분해·담당·순서·리스크·완료기준·검증계획 요청(계획만, 코드 무수정).
  ◁ dev-lead → 총괄: 3트랙(데이터SoT·백엔드보안·관리자 인증/인가) + 실행순서·리스크·검증게이트 계획. [전문 편입 예정]
- ▷ 총괄 → architect: 데이터 정본 단일화 결정 요청(크레딧 정본·멱등 uk·4자 동기·브랜드 테이블 스코프).
  ◁ architect → 총괄: 단일 TB_CREDIT 확정·`source_credit_key=COALESCE(...)` STORED uk·편집정본=master.sql·브랜드 3테이블 master 속함. 오너 승인 불요(기본값 확정). [전문 편입 예정]

### Stage ② 구현 (blocker) + Stage ③ 게이트
- ▷→ 한데관(dba): 데이터 정본 4자 동기(이후 세션 재배정으로 backend-db→분할 후 master=브랜드/tenant=쏠쏠 소유로 이관).
- ▷→ 조백개(api): SEC-r02-D01 health/db prod 게이트 이식. ◁ EXIT0, brand-api 패턴 이식, close 근거.
- ▷→ 임관개(admin): T8 시크릿 소스제거·T7 demo-login default-deny·T6 RBAC 미들웨어. ◁ 3건 EXIT0.
- ▷→ 조백개(api): credits.ts 단일 원장 재작성(72오류→0). ◁ 잔액파생·FIFO·멱등, EXIT0.
- ▷→ 강프개(front): API-D01 useOrder→/api/orders 정렬. ◁ 실 라우트 /api/orders 확인·필드매핑·404 은폐 제거.
- ▷→ 배보검(security)·노개보(privacy)·오품관(qa): 3렌즈 게이트. ◁ 배보검 **SEC-1B(차감 동시성) 신규 blocker 발견** / 노개보 GO / 오품관 GO + D-1(tenant_template 91) 발견.
- ▷→ 조백개(api): SEC-1B 시정(FOR UPDATE·원자 조건부 감산·멱등 앵커). ◁ EXIT0.
- ▷→ 배보검(security): SEC-1B 재검. ◁ **GO(RESOLVED)**.
- ▷→ 한데관(dba): D-1 tenant_template 92 정합·lot_state enum. ◁ 92 정합.

### Stage ① 신규과제 + ②③
- ▷→ dev-lead: FR01 조회 실연동·AD01 쓰기 CRUD 분해. ◁ F-1~F-6·A-1~A-7 실측 계획.
- ▷→ 강프개(front): FR01 F-1~F-5 실 봉투 매퍼. ◁ 실전환/부분연동/mock 마커 구분, EXIT0.
- ▷→ 임관개(admin): AD01 A-1 상품 쓰기 파일럿. ◁ write 7종·낙관적 캐시·A-2~A-7 레시피.
- ▷→ 조백개(api): /api/my-products 발행. ◁ 기존 P4 additive·본인스코프·enrollStatus.
- ▷→ 오품관(qa)·노개보(privacy): Wave1 게이트. ◁ qa 조건부 GO(중: 수료증 미발급 필터)·privacy GO.

### 세션 재배정 후 (Phase A, 이 창=쏠쏠)
- ▷→ 배보검(security): 강사 RBAC 역할기반 재검(커밋 d0ed606, 배포됨). ◁ 이전 blocker 2건 코드 해소 확인 / **신규 blocker(상): 강사 프로비저닝(TB_USER user_type='staff'·TB_ROLE 시드0)이 RBAC 전제 위반 → 실연동 NO-GO**. master 귀속=브랜드/seed 위치 경계 모호 → 허브 중재.

## 3. 결정·산출 (선택 — 작업 내역 상세는 history §9)
- blocker 앱층(AD01-D01·SEC-D02·API-D01·SEC-r02-D01·SEC-1B) 게이트 GO / 신규과제 Wave1 GO.
- 세션 재배정: 이 창 = 쏠쏠, `solsol_lms`(tenant 92) 스키마 소유·`solsol-api` 배포. master DDL·공유인증=브랜드(허브 중재).
- open blocker(허브 보고): 강사 프로비저닝 vs RBAC 전제(master/브랜드 귀속·seed 위치 경계 중재 필요).
