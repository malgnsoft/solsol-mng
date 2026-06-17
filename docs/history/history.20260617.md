# 2026-06-17 — 참여자·이슈 게시판·주간 작업 신설 + 현황판 제거

> **한 줄 요약** — `malgn-noti-mng`(맑은노티 프로젝트 관리) 구조를 참고해 **참여자(회원) 시스템 + 이슈 게시판(댓글·이미지 첨부)** 과 **주간 작업(`/weekly`)** 을 신설하고, **현황판(`/board`)** 을 제거. 단일 비밀번호 게이트를 회원 인증으로 교체하고, 대시보드 '프로젝트 현황'을 WBS 기반 요약 + 최근 이슈로 재구성. 원격 D1 마이그레이션·R2 버킷·세션 시크릿까지 적용해 프로덕션 배포.

## 1. 참여자(회원) 시스템 신설

- malgn-noti-mng 의 회원 구조를 이식: **로그인 / 회원가입(관리자 승인 대기) / 내 정보(`/account`) / 참여자 관리(`/members`, 관리자 전용)**.
- 인증: **HMAC 서명 세션 쿠키**(`mng_session`, Web Crypto) + **PBKDF2** 비밀번호 해시. `server/utils/auth.ts`·`members.ts`, `server/api/auth/*`·`account/*`·`members*`, `app/composables/useAuth.ts`·`app/plugins/auth.ts`.
- 기존 **단일 비밀번호 게이트 제거**: `app/middleware/auth.global.ts`·`server/api/login.post.ts` 삭제 → `app/middleware/01.require-auth.global.ts`(전역 회원 게이트, 프리렌더 중 스킵) 로 교체.
- **기본 관리자** 부트스트랩 — 아이디 `admin` / 비밀번호 `solsol2026`. dev 인메모리·`seed.sql`·원격 D1 동일.
- 맑은오피스 SSO 연동(`server/api/integration/*`·`auth/sso`)도 구조 유지를 위해 함께 이식(시크릿 없으면 비활성).

## 2. 이슈 게시판 신설 (`/issues`)

- **정책·이슈·공지·논의** 분류 + 상태(열림·진행중·해결·보류) + 우선순위, **댓글**, **마크다운 본문**(경량 자체 렌더러, 외부 의존 0), **이미지 첨부**(R2 `FILES`, 미생성 시 인메모리 폴백).
- 작성자 = 로그인 참여자(`authorName` 작성 시점 스냅샷). `server/utils/issues.ts`·`issueComments.ts`·`uploads.ts`, `server/api/issues/*`·`uploads/*`, `app/pages/issues/*`, `AppIssueForm`·`AppMarkdownEditor`, `app/utils/issueMeta.ts`·`markdown.ts`·`extractError.ts`.

## 3. 주간 작업 신설 (`/weekly`)

- WBS(`/api/wbs`) 파생 — **주차별 해야 할 일** + **지연(이월) 항목** + 담당/완료 필터.
- malgn 의 앱-티어 그룹핑은 쏠쏠 데이터에 안 맞아 **WBS 단계(Step 1~7)** 기준으로 적응(담당자 색은 이름 해시 팔레트).

## 4. 현황판(`/board`) 제거

- `app/pages/board.vue`·`server/api/board.get.ts`·`server/utils/boardSeed.ts` 삭제, `schema.ts` 의 `board_meta`·`stage`·`task` 제거(`wbs_item` 유지).
- 대시보드(`index.vue`) **'프로젝트 현황'** 을 `/api/board` → **`/api/wbs` + `wbsStageMeta`** 기반 요약으로 교체하고 **'최근 이슈'** 섹션 추가. `AppWbsOverview` 의 `/board` 링크 → `/wbs`.
- GNB 네비: **주간 작업·이슈·참여자(관리자 전용)** 추가, 로그아웃·계정 메뉴를 회원 인증 기준으로 교체.

## 5. 스키마 · 마이그레이션 · 설정

- `schema.ts`: `member`·`issue`·`issue_comment` 추가(board 제거). `0002_members_issues.sql`(멱등 DROP/CREATE) 신설 — `pnpm db:apply` 가 함께 적용.
- `seed.sql`: board 시드 제거, 기본 관리자 + `wbs_item` 유지. `wrangler.toml` 에 **R2 버킷 `solsol-mng-files`** 바인딩 추가. CLAUDE.md·drizzle.config 현행화.
- 두 프로젝트 스택·`package.json` 동일 → **신규 패키지 0건**.

## 6. 배포 (Cloudflare)

- **원격 D1**(`solsol-project`): `0002` 직접 적용(board 3테이블 DROP, member/issue/issue_comment CREATE) — **`wbs_item` 62행 무손실 유지**. 관리자 1명만 삽입.
- **R2** `solsol-mng-files` 생성. **Pages 시크릿** `NUXT_SESSION_SECRET`·`OFFICE_SHARED_SECRET` 설정.
- `pnpm build` → `wrangler pages deploy`(branch=main). 프로덕션 검증: 로그인·전 페이지 200 · `/board` 404 · 비로그인 302 · 이슈 생성 영속 정상.

## 산출물

- **신규 화면**: `/login`(회원)·`/signup`·`/account`·`/members`·`/issues`(+`new`·`[id]`·`[id]/edit`)·`/weekly`.
- **제거**: `/board`·`/api/board`·`boardSeed`·board 스키마.
- **커밋**: `d4beda4` → **push** `malgnsoft/solsol-mng`(main). 배포 <https://solsol-mng.pages.dev>.
- **DB**: 원격 D1 `member`·`issue`·`issue_comment` 신설 + 기본 관리자, `wbs_item` 유지. R2 `solsol-mng-files`.

## 알려진 한계 / 다음 단계

- origin(`djkim555-cmyk/solsol-mng`)은 현재 계정 **읽기 전용** → push 는 `malgnsoft/solsol-mng` 로. 원본 반영은 별도 권한/PR 필요.
- 회원가입은 **관리자 승인 대기**(pending) — 관리자가 `/members` 에서 활성화/등급 부여해야 로그인 가능.
- 기본 관리자 비밀번호(`solsol2026`)는 운영 전 변경 권장. 맑은오피스 SSO 는 연동 규약 확정 후 활성.
