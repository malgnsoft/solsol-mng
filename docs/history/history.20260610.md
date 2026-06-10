# 2026-06-10 — 솔솔(SolSol) 리브랜딩 + Cloudflare 연결 + 현황판·WBS 전면 재작성

> **한 줄 요약** — 관리 허브를 `malgn-noti`/`malgn-helper`에서 **솔솔(크리에이터 LMS)** 로 전면 리브랜딩하고, 전용 Cloudflare 리소스(D1 `solsol-project` + Pages `solsol-mng`)를 신설·연결. 기획 스프레드시트(이미지 7장)를 분석해 **현황판(7단계·78작업)** 과 **WBS 간트(5트랙·32항목)** 를 새로 작성하고, 진척률을 dev `/progress` 실측치(종합 베타 44%)에 맞춘 뒤 WBS 마감을 8월말까지 연장.

## 1. 리브랜딩 — solsol / 솔솔

- **CLAUDE.md**: `malgn-helper` → `solsol` 전체 치환(제목·DB명·Pages 프로젝트명·doc 경로).
- **코드·데이터 일괄 치환**(`app/`·`server/` 12개 파일): `malgn-noti*`·`malgn-notifications` → `solsol*`/`solsol-notifications`, 브랜딩 `맑은노티`·`맑은 메시징` → `솔솔`.
  - 화면 제목·GNB 로고 워드마크·주석·`projectName` 폴백·바로가기 URL.
  - `wrangler.toml`·`package.json`·`drizzle.config.ts` → `solsol-mng` / `solsol-project`.
- **docs 마크다운**(`PROJECT_MANAGEMENT_BLUEPRINT.md`·`history/README.md`): `malgn-noti`·`malgn-helper`·`맑은노티`·`맑은 메시징` → `solsol`/`솔솔`.
- **유지**: 회사명 `맑은소프트`, GitHub 조직 `malgnsoft`/`*.malgnsoft.workers.dev`, 과거 이력 메모(`맑은메시지 TF` 등).
- **로고**: GNB 워드마크에서 `message` 제거 → **솔솔 프로젝트 관리** 만 노출(미사용 `.brand-message` CSS·주석 정리).

## 2. Cloudflare 연결 (신규 리소스)

- 계정 `info@malgnsoft.com`. 기존 `malgn-noti`/`malgn-helper` 리소스는 미변경, **solsol 신규 생성** 선택.
- **D1** `solsol-project` 생성(`e682bf78-753f-4087-b5fa-58bdccd75fb3`, APAC) → 마이그레이션 2건 적용 + 시드.
- **Pages** `solsol-mng` 생성 → 프로덕션 <https://solsol-mng.pages.dev>.
- `wrangler.toml` 의 `database_id`·`database_name`·`name` 을 solsol 로 갱신.

## 3. 현황판(`/board`) 전면 재작성 — 크리에이터 LMS

- 기획 스프레드시트(이미지 7장) 분석: **솔솔 = 멀티 테넌트 크리에이터 LMS SaaS**. 4개 앱 — Brand site(`solsol.so`) · Customer Admin(강사, `ceo.solsol.so/@slug`) · Customer Front(수강생, `{slug}.solsol.so`) · BackOffice(운영, `so.solsol.so`). 결제 토스 · 정산 펌뱅킹 · 본인인증 NICE · 알림 NHN · 동영상 위캔디오 · GitHub `malgnsoft/creatorlms`.
- **7단계 · 78작업**: 기획·정책 / 화면설계 / 디자인 / 퍼블리싱 / 개발 설계 / 서비스 개발 / 운영·계약. 담당자·일자·정책을 스프레드시트에서 이식.
- 대시보드(`index.vue`) 목표·기능 칩·기획 방향·바로가기, `board.vue` 부제·링크를 LMS 기준으로 교체.

## 4. WBS 간트(`/wbs`) 전면 재작성

- **누락 발견**: `seed.sql` 에 `wbs_item` INSERT 가 0건 → D1 간트가 비어 있던 문제. 시드에 포함하도록 수정.
- 개발 간트(이미지 7) 전사: **5트랙 32항목** — 서버·공통 / Customer Admin / Customer Front / Brand site / BackOffice·인프라. 주차(W01~)를 날짜로 환산, 우선순위[상/중/하]·담당·비고 반영.
- `wbsData.ts`(`wbsSteps`·`wbsStageMeta`·`wbsGantt`), `wbs.vue`(담당자·색·기준일 6/10·STEP 1~5·부제) 갱신.

## 5. 진척률 실측 반영

- 출처: <https://backoffice.solsol-dev.workers.dev/progress> (CreatorLMS 개발 진행률, 2026-06-07) — **종합 베타 44%**.
  - 앱 전체%: Customer-Admin 45% · BackOffice 66% · Customer-Front 17% · Brand 2%.
  - 메뉴 실측: CA 사용자 95 · 운영 92 · 콘텐츠 85 · 상품 78 · 판매 55 · 설정 35 · 정산 10 / CF 일반강의 55 · 공지 90.
- 현황판 단계 진척·Step 6 작업 상태(CA 인증+사용자 **완료**, CF 상품목록 **진행중**, Brand 인증+가입 **대기** 등)와 WBS 간트 항목 진척·트랙 메타를 실측에 정렬.
- 결과: 현황판 가중평균 **56.5%**(기획·설계 완료 + 개발 44%), WBS 간트 KPI **43.9%**(≈ 종합 베타 44%).

## 6. WBS 마감 8월말 연장

- 완료 항목은 기존 일정 유지, 미완료 작업을 7~8월로 재분배. 롱폴(Customer Front 커뮤니티·멤버십, Brand 마이페이지·서비스 소개)이 **2026-08-31** 마감.
- 간트 타임라인: **2026-04-13 ~ 2026-08-31**. 진척률·트랙 가중치는 실측치 유지.

## 산출물

- **신규 리소스**: D1 `solsol-project`(`e682bf78…`), Pages `solsol-mng` — <https://solsol-mng.pages.dev>.
- **데이터 정합**(단일 생성 스크립트로 동기화): `server/db/seed.sql`(board + `wbs_item`) · `server/utils/boardSeed.ts` · `app/utils/wbsData.ts`.
- **수정 파일**: `wrangler.toml`·`package.json`·`drizzle.config.ts`·`CLAUDE.md`, `app/pages/{index,board,wbs}.vue`·`app/layouts/default.vue`·`app/composables/useWbs.ts`·`app/pages/docs/index.vue`, `server/api/board.get.ts`·`server/db/schema.ts`·`server/utils/db.ts`, `docs/PROJECT_MANAGEMENT_BLUEPRINT.md`.
- **주요 커밋**(`main`): `Rebrand to solsol and wire up Cloudflare` → `Rewrite board and WBS for SolSol Creator LMS` → `Adjust progress to real dev /progress data` → `Remove 'message' from logo wordmark` → `Extend WBS gantt deadlines to end of August`(`6c02938`).

## 다음 단계 / 알려진 한계

- 기획·디자인·설계(Step 1~5) 진척은 `/progress` 미수록 영역이라 이미지·일정 기반 **추정치**. 실제 수치 확보 시 정렬 필요.
- `/board`·`/wbs` 편집(CRUD)은 D1 정본을 직접 갱신 — 데이터 변경 시 `seed.sql`·`boardSeed.ts`·`wbsData.ts` 3종 동기화 유지(생성 스크립트 권장).
- WBS 일정은 실측 진척 + 8월말 목표 기준의 재분배안 — 팀 확정 일정으로 보정 필요.
