# 2026-07-02 — 검증 절차 단일정본 개정 + 리포트 취합·아카이브

> **한 줄 요약** — 검증 절차를 **단일 정본(`DEV_VALIDATION_PROCESS.md`)으로 전면 개정**(대상 매트릭스·단계 프로파일·데이터 5축·심각도 상/중/하·이월원장)하고, `docs/report/`의 미결 8종·검증위원회 8종을 **취합 3파일**로 정리 + 원본 16종을 `_archive/`로 형식통일 이관.

## 1. 검증 절차 단일정본 개정 (오너 확정 4결정 반영)
- `docs/DEV_VALIDATION_PROCESS.md` 전면 개정 — §1 적용대상 매트릭스(화면/계약 트랙·`solsol-mng` 비적용), §2 단계별 프로파일(목업/설계/스파이크/구현/실연동, WBS 8단계 정합), §3 화면 9축 + **데이터 5축** + 보안 상시 + 마스킹 3레이어, §4 심각도 **상/중/하** 성문화, §5 게이트(실연동 서명필수·blocker 0 강제), §6 결함표 표준 템플릿·네이밍, §7 이월 원장, 부록 A/B.
- `CLAUDE.md` 검증 절 축약(→PROCESS.md 링크), `docs/validation/06_API계약.md` 상단 **정본 격하 고지**(D1→Aurora, 오너 승인). 검토(오품관·최기획 조건부 GO) 지적 전건 반영.

## 2. 리포트 취합 · 아카이브
- **미결·막힌 사항**: 원본 8종 → `쏠쏠-미결취합-20260702.md` · `브랜드-미결취합-20260702.md`(6영역 분류).
- **검증위원회**: 원본 8종(R-VC1→r01→r02→r03 + 앱별 심화) → `검증위원회-통합보고서-20260702.md`(**open blocker 8건 NO-GO**).
- 원본 16종 → `docs/report/_archive/` 이동 + 파일명 통일(`미결보고-…` / `검증위원회-…`), `_archive/README.md` 인덱스. `_ledger.md` 링크 갱신.

## 3. 검증위원회 결함표 반영 (dev-validation)
- `dev-validation/`에 committee-r01/r02 결함표(FR01·AD01·BR01·security·privacy·data·api-contract·solsol-api·brand-api)·`_ledger.md`(open blocker 8) 반영.

## 산출물
- 문서: `docs/DEV_VALIDATION_PROCESS.md`·`CLAUDE.md`·`docs/validation/06_API계약.md`·`docs/report/*`(취합 3 + `_archive/` 16)·`docs/dev-validation/*committee*`·`_ledger.md`.
- 커밋 `39a5a1e` → `malgnsoft/solsol-mng` → Pages `solsol-mng` 배포.

## 4. WBS 구현(Step 7) 일정 스파이크 이후로 재조정
- 스파이크(Step 6, ~07-05) 이후 시작하도록 **구현(Step 7) 항목 중 07-06 이전 시작 13건을 07-06 시작으로 이동**(기간 보존 → 종료일 동일 delta 이동). 이미 07-06 이후(07-15·08-03) 시작분은 유지.
- `wbsData.ts`·`seed.sql`·라이브 D1(`step=7 AND start<'2026-07-06'` → 07-06 + julianday delta) 동기화. 커밋 `<이 커밋>` → Pages 배포.

## 5. 개발 세션 분할 계획 + 협업 규약 + 검증 정본 개정 메커니즘
- **세션 분할(오너 확정 B→A 단계적)**: `docs/DEV_SESSION_PLAN.md`(Phase B 3세션=공통 백엔드·데이터 spine + 쏠쏠 프론트 + 브랜드 프론트, 담당·책임 blocker·시작 프롬프트; 안정화 후 Phase A 2세션 축소) + `docs/DEV_SESSION_PROTOCOL.md`(전 세션 전달용: 편집 소유 경계·`_ledger` 허브 단독 기록·API 계약 프리즈·레인 카드·공통 금지). 기존 8분할 폐지.
- **검증 정본 개정 메커니즘**: `docs/validation_modified/` 신설 — 원본(`docs/validation/`) 무수정 보존, 개정은 **동일 파일명 완성본** + `_개정이력.md` **전후 기록**, **개정본 우선 권위**. `CLAUDE.md`·`DEV_VALIDATION_PROCESS.md`·`DEV_SESSION_PROTOCOL.md` 반영.
- (동봉) spine 세션의 `docs/data-model/*`(master.sql·ERD·README) 편집분 함께 커밋. 커밋 `b456066` → Pages 배포.

## 다음 단계
- 검증위원회 open blocker 8건 시정(DAT-D02 즉시·DAT-D01 결정선행·SEC-r02-D01·PRV-r02-D01 등).
- Phase B 3세션 병행 착수 — spine 데이터 정본 단일화·계약 프리즈 → 프론트 세션 소비.
