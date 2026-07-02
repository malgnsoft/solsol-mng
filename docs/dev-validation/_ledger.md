# Blocker 이월 원장 (dev-validation ledger)

모든 **상(blocker)** 결함을 라운드 간 추적하는 단일 원장. 게이트 종료조건 "blocker 0"은 여기서 검산한다.
절차 정본: [../DEV_VALIDATION_PROCESS.md](../DEV_VALIDATION_PROCESS.md) §7.

- **등재 규칙**: 라운드에서 `상` 결함이 나오면 즉시 등재(상태 open). 해소되면 `closed` + closed라운드 기록.
- **"게이트 미통과 배포"·"오너 won't-fix"·"blocker 강등"** 은 이 원장에 **사유 + 승인자**를 반드시 기재한다.
- 결함ID는 발견 라운드의 안정 ID(`<영역>-r<NN>-D##`)를 그대로 쓴다.

| 결함ID | 발견라운드 | 추적키(화면ID/EP) | 심각도 | 요약 | 상태 | closed라운드 | 승인자·사유 |
|---|---|---|---|---|---|---|---|
| FR01-r01-B* | FR01-customer-front-round1 | FR01 다수 | 상 | 목업 blocker 5건 상태로 시연 배포(쿠폰 정률 표기 등) | closed | committee-r01 | 위원장 재판정 — 실앱 FR01 committee-r01 GO(상0)·정률표기 실렌더 0·C-4 정액only 준수. 목업트리는 오너 "분석만 유지" 종결(별개) |
| AD01-mock-r02-B* | AD01-mockup-round2 | AD01 모달 다수 | 상 | 10 게이트 NO-GO(비가역 원클릭 등 다수) | 이관 | committee-r01 | 목업→실앱 전환. 실앱 T2에서 C-5 컨펌통일 확인으로 승계 종결 → 신규 AD01-cttee-r01-D01(RBAC)로 이관 |
| BR01-v5-r01-B* | BR01-brand-site-v5-round1 | BR01 | 상 | 정책 충돌 2건 | won't-fix | — | 오너 "A형 정본 유지" 결정(불변). committee-r01 정책충돌 재발 0 |
| AD01-cttee-r01-D01 | committee-r01 | AD01 전 admin 라우트 | 상 | RBAC 직접 URL 미차단(hasMenu 미검사·EXC-06 부재, 05 M-2 규칙5 위반) | open | — | 해제조건: auth.global.ts 메뉴권한 게이트+역할별 재검(admin-developer) |
| SEC-cttee-r01-D02 | committee-r01 | solsol-admin /api/auth/demo-login | 상 | demo-login fail-open(default-open 인증우회, seed superadmin 전권) | open | — | 해제조건: default-deny 반전+APP_ENV 이중가드+prod previewDemo=false 검증(admin-developer) |
| DAT-cttee-r01-D01 | committee-r01 | solsol-api master 크레딧 | 상 | 크레딧 3테이블 ORM↔마이그레이션 단일 TB_CREDIT 이탈(런타임 실패 위험) | open | — | 해제조건: 단일 TB_CREDIT 재정렬 or 3테이블 정본승격+4자 동시개정. 결정 전 배포금지(dba) |
| DAT-cttee-r01-D02 | committee-r01 | docs/data-model/master.sql | 상 | SoT DDL 사본 드리프트(TB_CONTACT/REPLY/NEWS 누락, 13↔16) | open | — | 해제조건: master.sql 16테이블 현행화+카운트 주석 정정(dba) |
| API-cttee-r01-D01 | committee-r01 | GET /api/my-orders (FR01 주문내역) | 상 | 프론트 호출 EP 라우트 부재→404→mock 은폐(주문내역 실데이터 차단) | open | — | 해제조건: 프론트 /api/orders 정렬 or API 별칭 추가+재검(frontend/api-developer) |
| SEC-cttee-r02-D01 | committee-r02 | solsol-api `GET /health/db`·`/health/db/grants` | 상 | 프로덕션 무인증 공개 — 전체 테넌트 스키마명·`SHOW GRANTS`(DB 계정 권한)·버전 노출(정찰 근거) | open | — | 해제조건: brand-api 게이트 이식(prod `X-Ops-Secret===OPS_SECRET`, grants prod 무조건 차단)+재검(api-developer) |
| PRV-cttee-r02-D01 | committee-r02 | solsol-brand-api `GET /admin/users`·`/:id` | 상 | 플랫폼 관리자(타인)에게 셀러 loginId·email·name·phone 전부 무마스킹 노출(mask 함수 dead code) — C-6 타인조회 마스킹 위반 | open | — | 해제조건: maskName/Email/Phone 적용 후 재검, 또는 관리자 열람목적 오너 정책확정 시 사유·승인자 기재(강등)(admin/api-developer) |
| data-model-r03-D02 | data-model-vs-validation-round3 | master.TB_CREDIT `uk_credit_idem` | 상 | 크레딧 멱등 uk=(site_id,idempotency_key,source_credit_id). 증가행(charge/bonus) source_credit_id=NULL → MySQL NULL-distinct로 멱등 무효 → **동일 키 중복 충전** 가능(원장 불변식 실패) | open | — | 해제조건: 증가행 멱등 DB강제(`COALESCE(source_credit_id,0)` 생성컬럼 uk 등)+앱 선검증. mng master.sql+api 000_master 동시개정(dba) |

> **blocker 0 검산 (@committee-r01, 2026-07-02)**: 기존 3건 = FR01-r01-B* **closed** / AD01-mock-r02-B* **이관** / BR01-v5-r01-B* **won't-fix(검산 제외)**. 신규 open **5건**. → **현재 open blocker 총수 = 5 → 게이트 종료조건 "blocker 0" 미충족(NO-GO).** 위원회 종합보고(통합 정본): [../report/검증위원회-통합보고서-20260702.md](../report/검증위원회-통합보고서-20260702.md) · 원본(committee-r01): [../report/_archive/검증위원회-20260702-종합-committee-r01.md](../report/_archive/검증위원회-20260702-종합-committee-r01.md).
>
> **blocker 0 재검산 (@committee-r02, 2026-07-02 — 백엔드 계약·데이터 트랙 심화)**: committee-r01 open 5건 중 백엔드 2건(**DAT-cttee-r01-D01** 크레딧·**DAT-cttee-r01-D02** data-model 드리프트) **여전히 open 재확인**. 신규 open **2건**(**SEC-cttee-r02-D01** solsol-api health/db 무인증 · **PRV-cttee-r02-D01** brand-api admin 셀러 PII 무마스킹). → **현재 open blocker 총수 = 7** (r01 5 + r02 신규 2). 게이트 종료조건 "blocker 0" 미충족(**NO-GO**). 레포별: solsol-api NO-GO(상 2: SEC-r02-D01·DAT-r01-D01) · solsol-brand-api NO-GO(상 1: PRV-r02-D01). committee-r02 종합보고: [../report/_archive/검증위원회-20260702-종합-committee-r02-백엔드.md](../report/_archive/검증위원회-20260702-종합-committee-r02-백엔드.md). 결함표: [solsol-api-committee-r02.md](solsol-api-committee-r02.md)·[brand-api-committee-r02.md](brand-api-committee-r02.md).
>
> **blocker 0 재검산 (@data-model-vs-validation-round3, 2026-07-01 — 데이터모델 위원회 4축)**: mng `docs/data-model`(master 13/tenant 91) 정본 대상 재검증. 기존 백엔드 blocker **DAT-cttee-r01-D01**(ORM 단일 TB_CREDIT 이탈)·**DAT-cttee-r01-D02**(master.sql 13↔16 드리프트) **여전히 open 재확인**(dba D01=D01·D03/Q01=D02와 동일 이슈). **신규 open 1건: `data-model-r03-D02`**(크레딧 멱등 uk NULL-distinct → 중복충전). security·privacy·qa 축은 상 0(중 15·하 13, 대부분 정본 4자 표류). → **데이터모델 라운드 NO-GO**(관련 open blocker 3: DAT-r01-D01·DAT-r01-D02·data-model-r03-D02). 종합보고: [../report/_archive/검증위원회-20260701-종합-committee-r03-데이터모델.md](../report/_archive/검증위원회-20260701-종합-committee-r03-데이터모델.md). 결함표: [data-model-vs-validation-round3.md](data-model-vs-validation-round3.md).
>
> **소급 등재 = 최소 필수.** 초기 3건은 검토(오품관) 지적으로 우선 등재했다(정확한 결함ID·건수는 각 라운드 파일에서 backfill). 이후 라운드는 발생 즉시 등재한다. `B*`는 원본 라운드 결함ID 확정 후 치환.
