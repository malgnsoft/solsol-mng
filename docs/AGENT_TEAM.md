# 에이전트팀 — 쏠쏠(solsol)

쏠쏠은 **별도의 프로젝트 전용 에이전트팀을 두지 않는다.** 개발·운영은 전적으로
**글로벌 에이전트팀**(`~/.claude/agents/<name>.md`)을 그대로 사용한다.

- **정의 위치**: `~/.claude/agents/`. `Agent` 툴의 `subagent_type` 지정 또는 description 자동 매칭으로 스폰.
- **이름↔역할 정본**: 글로벌 로스터 `~/Projects/malgn-dotype/docs/agent-org-roster.md` §0-A + 앱 D1 `agents.display_name`.
- 이 문서는 글로벌 팀을 **쏠쏠 레포에 어떻게 적용하는지**(레포 담당·작업 흐름)만 기술한다.
  팀 구성·역할·규칙의 **정본은 글로벌**이며, 이 문서와 상충하면 글로벌이 우선한다.

> 레포 토폴로지·아키텍처 매핑은 [CLAUDE.md](../CLAUDE.md)의 "관련 프로젝트" 표,
> 배포 절차는 같은 문서의 "배포 일괄 절차"를 참조.

---

## 글로벌 에이전트팀 (실제 정의 = `~/.claude/agents/`)

- **총괄**: `chief`
- **팀장**: `plan-lead`(기획) · `dev-lead`(개발) · `uiux-lead`(UI/UX) · `ops-lead`(운영) · `qa-lead`(품질·보안)
- **기획**: `planner` · `tech-writer`
- **개발**: `architect` · `frontend-developer` · `admin-developer` · `api-developer` · `dba` · `lms-developer`
- **UI/UX**: `ux-designer`
- **운영**: `deployer` · `cs-operator` · `it-specialist`
- **품질·보안**: `qa` · `security-reviewer` · `privacy-officer`
- **성장(상시 대기)**: `growth-keeper`

> 위 목록은 실제 글로벌 정의와 1:1이다. 글로벌에 없는 역할(예: 참모·퍼블리셔·서비스기획·법무)은
> 두지 않으며, 필요 시 **글로벌에 에이전트를 추가**해 다음 세션부터 사용한다(프로젝트 로컬 정의 금지).

---

## 레포 담당 (글로벌 에이전트 배정)

| 레포 | 구분 | 주담당 에이전트 | 아키텍처 원본 |
| --- | --- | --- | --- |
| `solsol-mng` | 프로젝트 관리 허브 | `frontend-developer` | `malgn-noti-mng` |
| `solsol-brand` | 사용자단(브랜드 사이트) | `frontend-developer` | `malgn-noti` |
| `solsol-brand-admin` | 관리자단(백오피스 콘솔) | `admin-developer` | `malgn-noti-admin` |
| `solsol-brand-api` | 백엔드 API(Hono·Workers) | `api-developer` | `malgn-noti-api` |
| `solsol`·`solsol-admin`·`solsol-api` | 크리에이터 LMS 본체 | `lms-developer`·`frontend-developer`·`admin-developer`·`api-developer` | — |
| D1 `solsol-project` / Aurora | 스키마·마이그레이션 | `dba` | — |

- 화면 동작·상태·연동 **그리고** 마크업·디자인 시스템 준수·반응형·접근성까지 각 프론트 개발자
  (`frontend-developer`/`admin-developer`)가 한 사람이 책임진다(Vue SFC 특성상 퍼블리셔 분리 안 함).
  `ux-designer`는 디자인 시스템·시안·접근성 표준 수립 단계에서 `uiux-lead` 하에 협업.
- 외부 API 호출·시크릿은 **API 레포에만**. 프론트는 직접 호출 금지(`api-developer` 경유).
- 스키마는 개발자가 직접 DDL을 돌리지 않고 **`dba`** 가 마이그레이션 작성·적용.

---

## 표준 작업 흐름

1. **plan-lead / planner** — 요구사항·정책·사용자 플로우·KPI 정의, 작업 분해(WBS).
2. **dev-lead / architect** — 구조·경계·기술 선택을 정하고 작업을 개발자에게 분배.
3. **개발자** — `frontend-developer`(사용자단·관리 허브)·`admin-developer`(관리자단)·`api-developer`(백엔드)·
   `lms-developer`(LMS 도메인)가 구현, 스키마 변경은 **`dba`** 에 위임.
4. **qa-lead** — `qa`(동작·회귀)·`security-reviewer`(위협·권한·시크릿)·`privacy-officer`(PII)가
   서로 다른 렌즈로 검증하고 결함을 재현 절차·심각도와 함께 담당자에게 회신(직접 수정 안 함).
5. **ops-lead / deployer** — 사용자 명시 요청 시 빌드→배포→검증→커밋·이력까지 처리
   (CLAUDE.md "배포 일괄 절차"). 인프라·CI/CD 포함.
6. **tech-writer** — 기능·API·운영 가이드·릴리스 노트 작성·현행화.

> 팀장 경유 4단계(총괄→팀장 계획→총괄 오케스트레이션→팀장 통합·GO/NO-GO→총괄 교차결정·보고)는
> 글로벌 지침(`~/.claude/CLAUDE.md`)을 따른다.

---

## 팀 공통 규칙

- 커밋·푸시·배포는 **사용자가 명시 요청할 때만**. 기본은 분석·구현·검증까지.
- TypeScript `any` 금지. 자체 컴포넌트 `App*`, Nuxt UI `U*` 사용. 디자인 토큰 하드코딩 지양.
- 시크릿(세션·오피스·외부 연동 키, PII)은 출력·로그·커밋 금지.
- 날짜·기준일은 **KST(UTC+9)** 로 계산.
- 검증 렌즈(`qa`/`security-reviewer`/`privacy-officer`)와 개발은 분리 — 검토자는 직접 수정하지 않고 회신.

---

## 스폰 방법

- **자동 위임**: 요청이 에이전트 description과 맞으면 자동 위임(예: "관리자 화면 구현" → `admin-developer`,
  "API 엔드포인트 추가" → `api-developer`, "배포" → `deployer`, "스키마 변경" → `dba`).
- **명시 호출**: `Agent` 툴에서 `subagent_type: "<name>"` 지정.
- **팀 단위**: 여러 팀장/전문가를 동시에 띄울 땐 한 메시지에서 병렬 스폰.
- ⚠️ 에이전트 정의는 **세션 시작 시 로드**된다. 글로벌에 새 에이전트를 추가하면 새 세션부터 노출.
