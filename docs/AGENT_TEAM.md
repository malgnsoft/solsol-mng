# 에이전트팀 — 쏠쏠(solsol)

쏠쏠 프로젝트군을 함께 개발·운영하는 **Claude Code 서브에이전트팀** 정의 정본입니다.
에이전트 정의는 **글로벌**(`~/.claude/agents/<name>.md`)에 있으며, `Agent` 툴의
`subagent_type` 지정 또는 description 자동 매칭으로 스폰됩니다.

> 레포 토폴로지·아키텍처 매핑은 [CLAUDE.md](../CLAUDE.md)의 "관련 프로젝트" 표,
> 배포 절차는 같은 문서의 "배포 일괄 절차"를 참조.

---

## 조직 (총괄 → 참모 → 5팀장 → 전문가)

```
                          chief (총괄)
                              │
                        chief-of-staff (참모)
                              │
   ┌──────────────┬───────────┼───────────┬──────────────────┐
기획-lead       개발-lead    uiux-lead    운영-lead        품질·보안-lead
   │              │            │            │                  │
 planner       architect    ux-designer  devops-engineer    qa
 service-planner frontend-dev publisher   cs-operator        security-reviewer
 tech-writer   api-dev                    it-specialist      privacy-officer
               admin-dev                  deployer
               dba
```

> **그로스/도메인 전문가**(상시 대기, 필요 시 호출): `growth-keeper`(에이전트 조직 성장),
> `lms-developer`·`instructional-designer`(크리에이터 LMS 도메인), `legal-reviewer`(법규·약관·라이선스).

---

## 레포 담당 (4 + DB)

| 레포 | 구분 | 주담당 에이전트 | 아키텍처 원본 |
| --- | --- | --- | --- |
| `solsol-mng` | 프로젝트 관리 허브 | `frontend-developer` | `malgn-noti-mng` |
| `solsol-brand` | 사용자단(브랜드 사이트) | `frontend-developer` | `malgn-noti` |
| `solsol-brand-admin` | 관리자단(백오피스 콘솔) | `admin-developer` | `malgn-noti-admin` |
| `solsol-brand-api` | 백엔드 API(Hono·Workers) | `api-developer` | `malgn-noti-api` |
| D1 `solsol-project` | 스키마·마이그레이션 | `dba` | — |

- 화면 동작·상태·연동 **그리고** 마크업·디자인 시스템 준수·반응형·접근성까지 각 프론트 개발자
  (`frontend-developer`/`admin-developer`)가 한 사람이 책임진다(Vue SFC 특성상 퍼블리셔 분리 안 함).
  `publisher`·`ux-designer`는 디자인 시스템·시안·접근성 표준 수립 단계에서 `uiux-lead` 하에 협업.
- 외부 API 호출·시크릿은 **`solsol-brand-api`에만**. 프론트는 직접 호출 금지(`api-developer` 경유).
- 스키마는 개발자가 직접 DDL을 돌리지 않고 **`dba`** 가 마이그레이션 작성·적용(D1, `server/db/`).

---

## 표준 작업 흐름

1. **기획-lead / planner·service-planner** — 요구사항·정책·사용자 플로우·KPI 정의, 작업 분해(WBS).
2. **개발-lead / architect** — 구조·경계·기술 선택을 정하고 작업을 개발자에게 분배.
3. **개발자** — `frontend`(사용자단·관리 허브)·`admin`(관리자단)·`api`(백엔드)가 구현,
   스키마 변경은 **`dba`** 에 위임.
4. **품질·보안-lead** — `qa`(동작·회귀)·`security-reviewer`(위협·권한·시크릿)·`privacy-officer`(PII)가
   서로 다른 렌즈로 검증하고 결함을 재현 절차·심각도와 함께 담당자에게 회신(직접 수정 안 함).
5. **운영-lead / deployer** — 사용자 명시 요청 시 빌드→배포→검증→커밋·이력까지 처리
   (CLAUDE.md "배포 일괄 절차"). `devops-engineer`가 CI/CD·인프라·모니터링.
6. **tech-writer** — 기능·API·운영 가이드·릴리스 노트 작성·현행화.

---

## 팀 공통 규칙

- 커밋·푸시·배포는 **사용자가 명시 요청할 때만**. 기본은 분석·구현·검증까지.
- TypeScript `any` 금지. 자체 컴포넌트 `App*`, Nuxt UI `U*` 사용. 디자인 토큰 하드코딩 지양.
- 시크릿(세션·오피스·외부 연동 키, PII)은 출력·로그·커밋 금지.
- 날짜·기준일은 **KST(UTC+9)** 로 계산.
- 검증 두 렌즈(`qa`/`security-reviewer`)와 개발은 분리 — 검토자는 직접 수정하지 않고 회신.

---

## 스폰 방법

- **자동 위임**: 요청이 에이전트 description과 맞으면 자동 위임(예: "관리자 화면 구현" → `admin-developer`,
  "API 엔드포인트 추가" → `api-developer`, "배포" → `deployer`, "스키마 변경" → `dba`).
- **명시 호출**: `Agent` 툴에서 `subagent_type: "<name>"` 지정.
- **팀 단위**: 여러 팀장/전문가를 동시에 띄울 땐 한 메시지에서 병렬 스폰.
- ⚠️ 에이전트 정의는 **세션 시작 시 로드**된다. 글로벌에 새 에이전트를 추가하면 새 세션부터 노출.
