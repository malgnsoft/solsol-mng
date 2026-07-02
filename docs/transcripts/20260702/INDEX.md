# 트랜스크립트 인덱스 — 2026-07-02 (KST)

> 규약: [`../README.md`](../README.md). 세션 분할: [`../../DEV_SESSION_PLAN.md`](../../DEV_SESSION_PLAN.md).
> **Phase B 착수일** — 4창(허브 + 백엔드·DB + 쏠쏠 풀스택 + 쏠쏠 브랜드 풀스택).

| 세션(창) | 파일 | 범위 | 상태 |
|---|---|---|---|
| 허브 (프로젝트 관리) | [`hub.md`](hub.md) | solsol-mng — 조율·정본·집계 | ✅ 기록 |
| 쏠쏠 사이트 백엔드 및 DB | [`backend-db.md`](backend-db.md) | 공유 DB·마스터/테넌트 스키마·데이터 정본 | ⏳ 세션 자체 |
| **쏠쏠** | [`solsol.md`](solsol.md) | **사용자단(FR01)+관리자단(AD01)+백엔드(solsol-api 앱)** | ⏳ 세션 자체 |
| **쏠쏠 브랜드** | [`solsol-brand.md`](solsol-brand.md) | **사용자단+관리자단+백엔드(brand-api 앱)** | ⏳ 세션 자체 |

> ⏳ = 해당 세션이 자기 파일에 직접 기록. 허브는 개시 프롬프트만 seed.
> **핵심**: 쏠쏠·쏠쏠 브랜드는 각각 **풀스택(사용자단+관리자단+백엔드)**. 공유 DB·데이터 정본만 `backend-db` 세션이 단독 소유.
