# backend-db-r02 — DB 미결 실행 + 샘플시드 강화 + 계약 발행 (허브 집계용)

> **라운드**: backend-db-r02 · **일자**: 2026-07-02 (KST) · **세션**: ① 공통 백엔드·데이터
> **프로파일**: 데이터 라운드(데이터 5축) + 계약정합. 게이트 = qa(오품관) **GO**.
> **⚠️ `_ledger.md` 갱신은 허브 단독**(PROTOCOL §3). 본 파일은 결함표+보고이며 허브가 원장 반영.
> **실행 근거**: 오너 "계획대로 다수 에이전트 진행" + "[샘플 데이터 시드 + 계약 발행]". 계획 = `backend-db-plan-r01.md`.

## 1. 산출물 (아티팩트 — 실 DB 미적용·미커밋·미배포)

### A. 스키마 확장 스윕 (Wave A · 한데관, additive·비파괴)
| 항목 | 처리 | 4자 동기 |
|---|---|---|
| TB_SESSION 신설(refresh 세션원장·재사용탐지 SEC-3) | master 16→**17** + tenant TB_SESSION `session_id(uk)`·`reused_at` 보강 | 000_master.sql·001_tenant·data-model(master.sql/tenant_template/ERD/README)·solsol-api ORM·brand-api ORM ✅ |
| is_secret(F-7 비밀댓글·B13 게시판 비밀정책) | TB_COMMENT·TB_BOARD(·TB_POST 기존) is_secret 컬럼 | ✅ |
| creditLedgerId 명명 정합(BDB-r01-D02) | ORM `learning.ts`/`contents.ts` → `credit_id`(DDL/ERD는 기존 정합) | ✅ (잔재 grep 0) |
| product_name 스냅샷(W3-3) | **이미 충족(no-op)** — 000_master/001·ORM 기존재 | — |
| 마이그레이션 | `003_master_session.sql`(멱등·GRANT·롤백)·`004_tenant_gaps.sql`(멱등·롤백) | 실 DB 미적용 |

### B. 후속 교정 (Wave A · 조백개)
| 결함ID | 조치 | 상태 |
|---|---|---|
| BDB-r01-D01 (데드락 락순서, 하) | solsol-api credits.ts `lockedBalance` ORDER BY를 debit와 통일 → 1213 창 제거 | **closed@r02** (security 재서명 불요=계약 불변) |
| BDB-r01-D04 (brand /doc admin 미수록, 하) | brand-api endpoints.ts에 admin 34EP 추가(총 77EP)·openapi 스테일 주석 정정 | **closed@r02** |
| Blocker A (로그인 role 매핑) | 현행 코드 이미 TB_ROLE 파생으로 해소 확인(무편집) | 확인·closed |

### C. 샘플 데이터 시드 강화 (Wave B · 한데관, IMPLEMENTATION_STANDARD §2/§4)
- `dev_master_seed.sql`(198→389)·`dev_domain_seed.sql`(603→820), backend-db 단독 소유·멱등.
- **도메인×엣지 매트릭스(각 ≥1건)**: 빈목록(site2 credit0·board505 post0) · 긴텍스트(contact#4·post#530) · 마스킹대상(card 뒤4·정산계좌 부분가림) · 페이지네이션 초과(credit **101**>100·orders **29**>20) · 상태다양성(lot open/expired/refund_restore·order refunded/canceled/failed/pending·is_secret 글/댓글).
- **값 안전**: 홍길동·`@dev.solsol.test`·010-xxxx·카드 뒤4·가짜 계좌형식. 실 PII·시크릿·16자리 PAN 0.

### D. 계약 프리즈 발행 (Wave B · 조백개)
- solsol-api **223 EP**(FR01 81·AD01 142) · solsol-brand-api **77 EP**(셀러 43·admin 34). `/doc` Scalar + `/doc/openapi.json`.
- 봉투 `{ok,data,meta?}`/`{ok:false,error{code,message,field?}}`, 페이지네이션 `{page,pageSize,total,totalPages}`, 인증 Bearer(+solsol X-Tenant). solsol-api openapi.ts `totalPages` 보정.
- **②③ 인계**: 이 계약만 소비·임의 변경 금지, 변경은 backend-db 경유.

## 2. 게이트 (qa 오품관 · 데이터 5축)
- 파서정합 ⭕ · 스키마정합 ⭕(generated 미삽입·uk 위반 0) · **크레딧 원장 SUM=293,300=최신 balance ⭕** · 멱등 ⭕(ON DUP 전건) · 엣지 5종 ⭕ · 4자 동기 ⭕(creditLedger 잔재 0) · 계약 223/77 일치 ⭕.
- 정적검증: solsol-api·brand-api `npx tsc --noEmit` **EXIT=0**(신규 0).
- **종합 GO** (blocker/major 0).
- advisory 1: 시드 `홍길동` 8회 — 의도된 안전 마스킹 테스트값(실 PII 아님), 오너 확인 후 수용/치환 택1.
- **미실행 명시**: 실 DB 적용·`wrangler deploy --dry-run`·`/doc` 런타임 부팅 = 범위 밖.

## 3. 허브/오너 라우팅
- **[데이터모델 결정 필요]** 강사(`user_type='instructor'`)가 관리자단 `requireUserType('staff')` 게이트에서 403 — (a) 강사 `staff`+TB_ROLE(instructor) 통일 vs (b) 게이트 `('staff','instructor')` 확장. 시드·계약 정합에 영향 → 오너/기획 결정 후 반영.
- **[적용 대기]** 스키마 003/004·시드 = DBA self-env로 `/ops`·mysql 경유 적용(master→`solsol`, tenant→`solsol_lms`). 실 DB 반영 시 데이터 라운드 재확인.
- **[TB_SESSION]** 스키마만 추가 — 재사용탐지·revoke **앱 배선** 시 security 서명 필요(별도).

## 4. blocker 상태 (허브 반영 요청)
- 신규 close: BDB-r01-D01·BDB-r01-D04 (하). 
- open 유지(비-blocker 후속): BDB-r01-D03(loginLogs ipAddr 마스킹)·데이터모델 결정 12건(계획 §4·[decisions-r01](backend-db-decisions-r01.md)).

## 5. 강사 RBAC 정합 (05#3 준수) — 부분 완료 + 신규 blocker D-2
- **완료**: solsol-api `middleware`/`admin/products.ts` 게이트를 `requireUserType('staff','instructor')`로 완화 — **products만**(own 스코프 서버강제 완결: list=ownerUserId 필터·create=ownerUserId:sub·상세/수정/삭제=assertOwnScope, IDOR 차단 논증). 관리자(staff·scope=all) 회귀 0. tsc EXIT=0.
- **user_type 값 정정**: 실제 `learner`/`instructor`/`staff` 3종. 서브강사=`instructor`+`TB_ROLE.code='sub_instructor'`+축소 권한(별도 user_type 아님). 게이트 완화값=`('staff','instructor')`.

| 결함ID | 추적키 | 심각도 | 요약 | 상태 |
|---|---|---|---|---|
| BDB-r02-D01 | solsol-admin 8 admin 라우트 own-scope | **상(blocker)** | contents/commerce/stats/marketing/support/credits/members/settlement(vat)이 roleGuard(menuKey)는 있으나 **data_scope='own' 서버강제 미구현**(scope 미소비). 강사 활성화 시 타강사/테넌트 전역 IDOR → **완화 보류 중**(현 상태는 staff-only라 무누출) | open — own 사양 확정 후 구현 |
| BDB-r02-D02 | products 공유 카테고리 CRUD | 중 | 강사가 공유 taxonomy(ownerUserId 없음) 생성/수정/삭제 가능 — 기획 확인 | open |

> **현 안전성**: D-01 대상 라우트는 게이트를 완화하지 않아(staff-only 유지) **현재 IDOR 노출 없음**.

### 5-1. 강사 own-스코프 구현 시도 → **security NO-GO (재작성 대기)**
오너 확정(정산·주문·수강생 3종·마스킹 유지·조회전용) 대로 구현했으나 **security 서명 NO-GO(blocker 2)**. 근본원인 = **코드베이스 인증모델 불일치**.

| 결함ID | 심각도 | 요약 | 상태 |
|---|---|---|---|
| BDB-r02-D03 | 상(blocker) | own 강제 트리거가 `typ==='instructor'` 전제인데 관리자단 로그인은 `user_type='staff'` 고정(강사=TB_ROLE 파생, auth.ts:994·me.ts:40) → 트리거 사문화, data_scope 오구성 시 전체 데이터 IDOR | open — 역할기반 재작성 |
| BDB-r02-D04 | 상(blocker) | 배제 게이트 `requireUserType('staff')`가 강사에게 no-op(강사도 staff) → 5종·쓰기·비가역·AM-12(자기권한 상승) 도달 | open — owner-only/role 가드로 교체 |

- **privacy GO**: 마스킹은 scope/typ 무관 무조건 적용(비마스킹 잔존 0) — 재작성 후에도 유지.
- **재작성 방향**(security 권고): 강사 판별 = TB_ROLE code(owner 아님) / 배제 = owner-only(role) 가드 / roleGuard가 data_scope 검증(‘none’ 차단) / 강사는 코드에서 own 강제(scope 값 불신) / AM-12 owner-only / AC-2 상세 강사=본인 item·비례금액만.
- **선결**: 인증모델 확정(관리자단 사용자=`user_type='staff'`+TB_ROLE 파생) — architect/data-model.
- ⚠️ **정정(→ r03에서 해소)**: 본 NO-GO 근거(강사 typ='staff')는 **스테일 주석 오독**이었음(실제 typ=user_type, 강사=instructor). architect 정본모델 확정 후 **역할기반 재작성 → security·privacy 재서명 GO**. D-01·D-03·D-04 **closed@r03**. → [backend-db-r03.md](backend-db-r03.md).
