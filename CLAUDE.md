# solsol-mng — 프로젝트 관리 허브

`solsol`(고객상담 AI 챗봇) 프로젝트를 운영·조망하는 **단일 관리 허브** 앱.
설계 원본은 [doc/PROJECT_MANAGEMENT_BLUEPRINT.md](doc/PROJECT_MANAGEMENT_BLUEPRINT.md).

## 화면 (5)

| 영역      | 경로       | 렌더링   | 내용                                                    |
| --------- | ---------- | -------- | ------------------------------------------------------- |
| 대시보드  | `/`        | SSR      | 목표(Phase 1/2) · 진척 요약 · 바로가기 · 문서/최근 이력 |
| 현황판    | `/board`   | SSR      | Phase 1 · SI 6단계 진척(가중평균) + 단계별 작업 표      |
| WBS(간트) | `/wbs`     | SSR      | 일 단위 간트 + 작업 CRUD                                |
| 문서      | `/docs`    | 프리렌더 | `doc/` 마크다운 트리 뷰어                               |
| 작업 이력 | `/history` | 프리렌더 | 일자별 타임라인 (`doc/history/`)                        |

## 데이터 정본 (2)

- **구조화 데이터**(진척·작업·단계·간트): Cloudflare **D1** (`solsol-project`).
  로컬/미생성 시 `server/utils/boardSeed.ts` + `app/utils/wbsData.ts` **시드로 자동 폴백**.
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
pnpm db:apply                 # wrangler d1 migrations apply solsol-project --remote
pnpm db:seed                  # server/db/seed.sql 적용
# 3) 빌드 + 배포
pnpm build
wrangler pages project create solsol-mng --production-branch=main   # 최초 1회
wrangler pages deploy dist --project-name=solsol-mng --branch=main --commit-dirty=true --commit-message "init"
```

- `server/db/seed.sql` 과 `server/utils/boardSeed.ts` 는 **동일 내용**을 유지한다(전자=D1 정본, 후자=폴백).
- 데이터·문구를 바꿀 때는 두 파일 + `app/utils/wbsData.ts`(간트)를 함께 갱신.
