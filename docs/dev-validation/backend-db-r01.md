# backend-db-r01 — 세션 ① 공통 백엔드·데이터 결함표·close 보고 (허브 집계용)

> **라운드**: backend-db-r01 · **일자**: 2026-07-02 (KST) · **세션**: ① 공통 백엔드·데이터 spine
> **프로파일**(DEV_VALIDATION_PROCESS §2): 계약 라운드(데이터 5축+계약정합) + 실연동(security·privacy 서명)
> **게이트 서명**: security(배보검) ⭕ · privacy(노개보) ⭕ · qa(오품관) GO · dba(한데관) 데이터 5축 셀프
> **⚠️ `_ledger.md` 갱신은 허브 단독**(PROTOCOL §3). 본 파일은 ① 세션의 결함표 + close 근거이며, 허브가 이를 받아 원장 open→closed 반영한다.

## 1. blocker close 보고 (6건 → 허브 원장 반영 요청)

| 결함ID | 추적키 | 검증축 | 심각도 | 조치 근거(파일:라인) | 서명 | 상태 |
|---|---|---|---|---|---|---|
| DAT-cttee-r01-D01 | solsol-api master 크레딧 | 스키마정합·계약정합 | 상 | ORM `schema.master.ts` 단일 TB_CREDIT 재작성(3분할 제거)+16테이블 정합, 라우트 `admin/credits.ts` 단일모델 정합(3분재 grep 0)·멱등키 `.max(60)` | security⭕·qa GO | **closed@backend-db-r01** |
| DAT-cttee-r01-D02 | docs/data-model/master.sql | 스키마정합 | 상 | master.sql 13→16(TB_CONTACT/REPLY/NEWS 역이식)+푸터 카운트 정정, README 16·크레딧 네이밍 현행화, ERD 정합 | qa GO | **closed@backend-db-r01** |
| data-model-r03-D02 | master.TB_CREDIT uk_credit_idem | 마이그안전·데이터정합성 | 상 | `source_credit_key = COALESCE(source_credit_id,0) STORED` 생성컬럼 + `uk(site_id,idempotency_key,source_credit_key)` 재정의(6파일 동기) + 마이그 `002_credit_idem_null_free.sql`(멱등·롤백·dedup 프리체크) | security⭕·qa GO | **closed@backend-db-r01** |
| SEC-cttee-r02-D01 | solsol-api /health/db·/grants | 보안 상시 | 상 | `index.ts:107-122` prod `X-Ops-Secret===OPS_SECRET`·미설정 시 전차단, `/grants` prod 무조건 차단(가드 핸들러 선행) | security⭕ | **closed@backend-db-r01** |
| PRV-cttee-r02-D01 | brand-api /admin/users·:id | 마스킹 L1 | 상 | `users.ts:100-107·204-207` self 분기 후 loginId/email/name/phone 마스킹(masking.ts dead code 활성화), maskEmail 앞2자 정본 정합 | privacy⭕ | **closed@backend-db-r01** |
| SEC-1 (≈r03-D02 계열) | brand-api 크레딧 조정 EP | 계약·금전원장 | 상 | `credits.ts:375-651` 단일 `db.transaction` + `TB_SITE`/lot `FOR UPDATE` 직렬화 + INSERT-first uk-catch 멱등 | security⭕ | **closed@backend-db-r01** |

**정적검증 증거**: solsol-api `npx tsc --noEmit` EXIT=0 · `wrangler deploy --dry-run` EXIT=0 / solsol-brand-api `npx tsc --noEmit` EXIT=0 (baseline/신규 오류 각 0).

**4자 동기 검산**(데이터 5축 #1): 기준선 `solsol-api/db/migrations/000_master.sql`(16·단일 TB_CREDIT·NULL-free uk) = mng master.sql = ERD.md = README(16) = solsol-api ORM = brand-api ORM. 3분할 잔재 0, master 테이블수 16 일치.

## 2. 잔여 결함표 (비-blocker · 후속)

| 결함ID | 추적키 | 축 | 심각도 | 현상 | 제안 | 담당 | 상태 |
|---|---|---|---|---|---|---|---|
| BDB-r01-D01 | solsol-api credits.ts lockedBalance | 마이그안전(가용성) | 하 | charge/refund·debit의 open-lot FOR UPDATE 락 순서 불일치 → 고동시성 시 InnoDB 데드락(1213) 창(금전 손실 없음·원자 롤백) | lockedBalance SELECT에 debit와 동일 ORDER BY(isExpiring desc,expiresAt asc,id asc) 또는 1213 재시도 | api-developer | open |
| BDB-r01-D02 | tenant TB_AI_JOB.credit_ledger_id | 스키마정합 | 하 | 단일모델 후 `creditLedgerId` 명명 잔재(nullable·항상 null·조인없음·무해) | 명명 일관화(후속) | dba | open |
| BDB-r01-D03 | brand-api /admin/users loginLogs[].ipAddr | 마스킹(범위밖) | 하(관찰) | 타인 관리자에게 로그인 IP 원문 노출(D01=name/email/phone/loginId 4항목 범위밖) | 별도 마스킹 정책 판정 | privacy/api | open |
| BDB-r01-D04 | brand-api /doc 카탈로그 | 계약 완결성 | 하 | admin/* 11서브라우트가 `docs/endpoints.ts`에 미수록 → 콘솔 계약 `/doc` 미노출(라우트는 마운트됨) | endpoints 카탈로그에 admin 추가 | api-developer | open |

## 3. 배포 전 필수(게이트 체크 — 오너 "배포" 시)
1. brand-api 실배포 전 `solsol_master`에 `000_master.sql`+`002_credit_idem_null_free.sql` 적용 확인(미적용 시 SEC-1 uk 백스톱 무력화 → 이중지급 가능).
2. 결제/크레딧 조정 EP는 staging-gate·실 PG 미주입 유지(SEC-D09 승격 전 운영 노출 보류).
3. 샘플 시드 dev 적용: master→`solsol`, tenant→`solsol_lms`(담당자 자기 env 시크릿, 프로덕션 금지).

## 4. Phase B→A 전환 기준 대비(DEV_SESSION_PLAN §1)
- ① 데이터 정본 단일화·프리즈: **달성**(4자 동기, DAT-D01·D02·r03-D02 close).
- ② 백엔드 open blocker 0: **달성**(6건 close, 잔여 전부 하).
- ③ API 계약 프리즈 발행: **달성**(양 API `/doc` Scalar·프리즈 노트, 단 brand admin 카탈로그 갭 BDB-r01-D04).
