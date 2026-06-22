# solsol-mng — 프로젝트 관리 허브

`solsol`(고객상담 AI 챗봇) 프로젝트를 운영·조망하는 **단일 관리 허브** 앱.
설계 원본은 [doc/PROJECT_MANAGEMENT_BLUEPRINT.md](docs/PROJECT_MANAGEMENT_BLUEPRINT.md).

## 관련 프로젝트 (로컬 경로)

쏠쏠 브랜드 4개 앱은 **맑은노티(malgn-noti) 생태계와 동일한 아키텍처**를 사용한다.
각 프로젝트는 같은 접미사의 맑은노티 레포를 아키텍처 원본으로 참고한다.
(`solsol-brand*` 3개는 현재 비어 있음 — 아래 원본 구조를 따라 구축 예정.)

| 경로 (`/Users/dotype/Projects/…`) | 구분 | 아키텍처 원본(맑은노티) | 스택 |
| --------------------- | ---------------- | ------------------------------- | --------------------------------------------------- |
| `solsol-mng`          | 프로젝트 관리 허브 | `malgn-noti-mng`                | Nuxt 3 (compat v4) · Nuxt UI v3 · @nuxt/content · Drizzle D1 · Pages |
| `solsol-brand`        | 사용자단 (브랜드 사이트) | `malgn-noti` (사용자단)          | Nuxt 3 · Vue 3 · Nuxt UI v3 · nitro `cloudflare-pages` (프론트) |
| `solsol-brand-admin`  | 관리자단 (백오피스 콘솔) | `malgn-noti-admin` (관리자단/BackOffice) | Nuxt 3 풀스택(`server/` 포함) · Nuxt UI v3 · `cloudflare-pages` |
| `solsol-brand-api`    | 백엔드 API        | `malgn-noti-api` (API 서버)      | Hono · Drizzle ORM · Cloudflare **Workers** (`wrangler`) |

> **아키텍처 참고**: 구조·패턴·스택을 맞출 때 위 "아키텍처 원본" 레포(`../malgn-noti*`)를 참조한다.
> 본 관리 허브(`solsol-mng`)의 참여자·이슈 게시판·주간 작업 구조 원본은 `malgn-noti-mng`.
>
> **에이전트팀**: 개발·운영 서브에이전트팀 구성·역할·작업 흐름은 [docs/AGENT_TEAM.md](docs/AGENT_TEAM.md).
> 에이전트 정의는 글로벌(`~/.claude/agents/`)에 있다.

## 화면

| 영역      | 경로       | 렌더링   | 내용                                                    |
| --------- | ---------- | -------- | ------------------------------------------------------- |
| 대시보드  | `/`        | SSR      | 목표 · WBS 진척 요약 · 최근 이슈 · 바로가기 · 문서/이력  |
| WBS(간트) | `/wbs`     | SSR      | 일 단위 간트 + 작업 CRUD                                |
| 주간 작업 | `/weekly`  | SSR      | WBS 파생 — 주차별 해야 할 일(단계별 그룹) + 지연 항목    |
| 이슈      | `/issues`  | SSR      | 정책·이슈·공지·논의 게시판 + 댓글 (작성자 = 참여자)      |
| 참여자    | `/members` | SSR      | 회원 관리(관리자 전용) — 승인/등급/삭제                 |
| 문서      | `/docs`    | 프리렌더 | `doc/` 마크다운 트리 뷰어                               |
| 작업 이력 | `/history` | 프리렌더 | 일자별 타임라인 (`doc/history/`)                        |

> 인증: 전역 회원 게이트(`app/middleware/01.require-auth.global.ts`). 비로그인은 `/login`.
> `/signup`(가입은 관리자 승인 대기) · `/account`(내 정보) · 세션은 HMAC 서명 쿠키(`mng_session`).
> 로컬 dev 기본 관리자 — 아이디 `admin` / 비밀번호 `solsol2026` (인메모리·`seed.sql` 동일).

## 데이터 정본 (2)

- **구조화 데이터**(참여자·간트·이슈/댓글): Cloudflare **D1** (`solsol-project`).
  로컬/미생성 시 `app/utils/wbsData.ts`(간트) + 각 `server/utils/*`의 **인메모리 폴백**.
  이슈 첨부 이미지는 **R2**(`FILES`, 버킷 `solsol-mng-files`) — 미생성 시 인메모리 폴백.
- **문서/이력**: `doc/` 마크다운 (@nuxt/content, 빌드 타임 프리렌더).

> `doc/` 트리는 `solsol/doc/`의 정본을 반영한다. 원본이 바뀌면 이 레포 `doc/`도 현행화한다.

## 스택

Nuxt 3 (compat v4) · Nuxt UI v3 (Tailwind v4) · @nuxt/content v3 · Drizzle ORM(D1) · Cloudflare Pages. 패키지 매니저 pnpm.

## 로컬 개발

```bash
pnpm install
pnpm dev                      # http://localhost:3000 (D1 없음 → 시드 폴백)
pnpm build && npx wrangler pages dev dist   # 빌드 산출물로 프리뷰
```

## 배포 (Cloudflare Pages + D1)

D1을 아직 만들지 않았다면 시드 폴백으로도 동작하지만, 편집(CRUD) 영속화를 위해 D1을 권장한다.

```bash
# 1) D1 생성 → 출력된 database_id 를 wrangler.toml 의 REPLACE_WITH_D1_DATABASE_ID 에 기입
wrangler d1 create solsol-project
# 2) 스키마 적용 + 시드
pnpm db:apply                 # migrations_dir 의 0000~0002 전체 적용(참여자·이슈 포함)
pnpm db:seed                  # server/db/seed.sql 적용(기본 관리자 + 간트)
wrangler r2 bucket create solsol-mng-files   # 이슈 첨부 이미지 저장소(최초 1회)
# 3) 빌드 + 배포
pnpm build
wrangler pages project create solsol-mng --production-branch=main   # 최초 1회
wrangler pages deploy dist --project-name=solsol-mng --branch=main --commit-dirty=true --commit-message "init"
```

- 프로덕션은 세션·오피스 시크릿 필요: `NUXT_SESSION_SECRET`(필수), `OFFICE_SHARED_SECRET`(오피스 연동 시).
- 스키마 정본은 `server/db/schema.ts`. 데이터·문구를 바꿀 때는 `server/db/seed.sql` + `app/utils/wbsData.ts`(간트)를 함께 갱신.

## 배포 일괄 절차 (IMPORTANT — "배포" 요청 시 이 전체를 한 번에 수행)

사용자가 **"배포"**(또는 커밋·푸시·배포·이력 중 일부)를 요청하면, 아래 순서를 **일괄로** 실행한다.

1. **커밋** — 변경 스테이징 후 한국어 메시지로 커밋. 마지막 줄에 트레일러:
   `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`
2. **푸시** — `git push malgn main`.
   ⚠️ `origin`(`djkim555-cmyk/solsol-mng`)은 이 계정 **읽기 전용** → 푸시는 **`malgn` 리모트(`malgnsoft/solsol-mng`)** 로. 없으면
   `git remote add malgn https://github.com/malgnsoft/solsol-mng.git`.
3. **빌드 + 배포** —
   `pnpm build && wrangler pages deploy dist --project-name=solsol-mng --branch=main --commit-dirty=true --commit-message "<요약>"`.
4. **이력 기록** — `docs/history/history.<오늘(KST,yyyyMMdd)>.md` 작성(한 줄 요약 + 작업 섹션 + 산출물 + 다음 단계) + `docs/history/README.md` 인덱스 표 **맨 위 행** 추가. 같은 날 파일이 있으면 섹션을 이어 붙인다.
5. **이력 커밋·푸시** — 4의 문서를 커밋 후 다시 `git push malgn main`.
6. **검증** — 배포 후 프로덕션 스모크(로그인 + 주요 페이지 200, 변경점 반영) 확인 후 결과 보고.

- **문서만** 바뀐 변경(예: CLAUDE.md·docs)은 3(배포)을 생략해도 되지만, **앱 코드/콘텐츠 변경의 배포에는 이력(4·5)을 항상 포함**한다.
- 기준일·날짜는 **KST(UTC+9)** 로 계산한다.
