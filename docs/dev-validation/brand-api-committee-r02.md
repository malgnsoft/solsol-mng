# solsol-brand-api 계약·데이터 라운드 결함표 — committee-r02

> 라운드: **committee-r02** (백엔드 계약·데이터 트랙 심화) · 기준일: 2026-07-02 (KST)
> 대상: `solsol-brand-api` (Hono·Workers·Aurora master 단독) · 트랙: 계약 라운드(데이터 5축 + 보안 상시 + 마스킹 3레이어 + 계약정합)
> 정본: `db/migrations/*.sql`·`docs/data-model/ERD.md`(master) · 절차: `../DEV_VALIDATION_PROCESS.md`
> 위원: dba(한데관)·security-reviewer(배보검)·privacy-officer(노개보)·qa(오품관) · 통합: qa-lead·총괄
> 성격: 읽기 전용(무수정). 실 Aurora 미접근 → 마이그레이션 실적용 검증 미실행.

## 정적검증 증거
```
solsol-brand-api : npx tsc --noEmit → EXIT 0 (신규 0 / baseline 0)
```

## 결함표 (§6 표준)

| 결함ID | 추적키(EP) | 검증축 | 심각도 | 현상 | 기대 vs 실제 | 근거(파일:라인) | 제안 | 담당 | 상태 |
|---|---|---|---|---|---|---|---|---|---|
| PRV-cttee-r02-D01 | `GET /admin/users`·`/:id` (AU1/AU2) | 마스킹 L1 (C-6) | **상(blocker)** | 플랫폼 관리자(타인)에게 셀러 loginId·email·name·phone을 목록·상세 **전부 무마스킹** 노출. `maskName/Email/Phone` 정의됐으나 미사용(dead code, maskCard만 사용). solsol-api admin/members는 마스킹 → C-6 정면 불일치 | 타인조회 마스킹 vs 원문 노출 | `src/routes/admin/users.ts:101-103,198-200` (dead: `lib/masking.ts:17-35`) | maskName/Email/Phone 적용. 관리자 열람 목적 예외면 오너 정책확정+원장 승인자 기재(강등) | admin-developer/api-developer | open |
| SEC-cttee-r02-B01 | `/api/auth/*`·`/admin/auth/*`·`/webhooks/toss` | 보안-남용 | 중 | 로그인·리프레시·웹훅 레이트리밋 전무 | 남용 방어 vs 없음 | 전역·`wrangler.toml` | CF Rate Limiting Rules(로그인·웹훅)+실패 카운터 | deployer | open |
| SEC-cttee-r02-B02 | `/api/auth/refresh`·`/logout`·`/admin/auth/*` | 보안-세션 | 중 | stateless refresh, 서버 원장 없음 → logout·회전 후에도 이전 refresh 14일 TTL 내 유효, 재사용 탐지·즉시 revoke 불가 | 회전+재사용탐지+revoke vs TTL 의존 | `src/routes/auth.ts:456-518`·`admin/auth.ts:259-323` | TB_SESSION(refresh_hash) 저장소 도입(solsol-api 수준) | dba/api-developer | open |
| QA-cttee-r02-B01 | `POST /api/auth/email-code/issue` | 05#4 유효시간 | 중 | 가입 인증코드 TTL 3분(180s) | 가입코드 10분(600s) vs 180s | `src/routes/auth.ts:52` | 600s로 통일 또는 브랜드 05 적용성 plan-lead 확정 | api-developer/plan-lead | open |
| PRV-cttee-r02-B01 | `DELETE /api/account`(AC5 탈퇴) | 마스킹/보관·파기 | 중 | status=-1만, PII 파기·사이트/구독 연계 후속배치 위임(TODO). name/email/phone/loginId 잔존, 파기 스케줄·보관항목/기간 미정의 | 목적달성 후 파기 or 보관기간 명시 | `src/routes/account.ts:314-321` | 파기 배치 or 보관항목·법정보관 기간 정책 | api-developer/dba | open |
| SEC-cttee-r02-B03 | `POST /webhooks/toss` | 보안-무결성 | 하(gated) | 토스 서명검증 골격(스텁)·헤더명·인코딩 미확정. **현재 미악용**(미검증 시 상태전이 없음+실전이 staging-gate) | HMAC 상수시간+타임스탬프 vs 스텁 | `src/routes/webhooks.ts:47-75,142-151` | **실결제 go-live 전 상(blocker) 승격 필수** | api-developer | open(gated) |
| QA-cttee-r02-B02 | `POST /api/auth/password/reset` | 회귀-리플레이 | 하 | reset 티켓 완전 1회성 아님(nonce 원장 없음, TTL·passwordUpdatedAt만) | 1회 소진 vs TTL 내 재사용 가능 | `src/routes/auth.ts:655` | 토큰 저장·소진 원장 | api-developer | open |
| SEC-cttee-r02-B04 | `src/db/seed.admin.sql` | 보안-시크릿(위생) | 하 | 개발용 기본 PW(`solsol2026`) 평문 문서 기재(해시는 placeholder). 실 시드는 `/ops/seed-admin`+`SEED_ADMIN_PASSWORD` 경로 | 저장소 크리덴셜 비기재 vs 문서 상수 | `src/db/seed.admin.sql:17,54` | 파일 내 평문 PW 제거(커밋 위생) | api-developer | open |
| PRV-cttee-r02-B02 | `POST /webhooks/toss` rawPayload | 마스킹 L2 | 하 | 웹훅 rawBody 원문 저장, 민감필드 마스킹 미적용(주석: 토스 payload 카드원문 없음). PII 포함 여부 미검증 | raw_payload PII 마스킹 vs 원문저장 | `src/routes/webhooks.ts:176` | 토스 실스키마 확인 후 PII 마스킹/제외 | api-developer | open [확인필요] |
| DAT-cttee-r02-B01 | TB_USER seed | 데이터3 시드정합 | 하 | `seed.admin.sql` password_hash 플레이스홀더(`...REPLACE_WITH_ACTUAL_HASH`) → 그대로 적용 시 superadmin 인증 불가(INSERT IGNORE라 멱등은 정상) | 유효 해시 or 적용차단 vs 플레이스홀더 | `src/db/seed.admin.sql:56` | 적용 전 실 해시 생성(자기 env) | dba/운영 | open |
| DAT-cttee-r02-B02 | TB_CONTACT/REPLY/NEWS 소유권 | 데이터1 스키마정합 | 하 | 마스터 문의·소식 3테이블을 solsol-api(000_master.sql)·brand-api(000_brand_ext.sql) 양쪽 정의. additive·IFNE·동일컬럼이라 충돌 없음이나 소유 레포 모호 | 마스터 테이블 소유 단일화 vs 이중 정의 | `db/migrations/000_brand_ext.sql:5-9` | 소유 레포·적용순서 1줄 명시 | dba | open |

## 축별 판정
| 축 | 판정 | 근거 |
|---|:--:|---|
| 계약정합(qa) | 🔺 조건부 GO | 봉투·게이트·비번 정상, blocker 0. 중=가입코드 05#4 편차 |
| 05 확정 6건(qa) | ⭕ | 해당분 준수(닉네임·쿠폰·강사RBAC는 브랜드 N/A) |
| 데이터 5축(dba) | ⭕ GO(조건부) | DDL 1:1 미러·멱등·prod게이트·인덱스 커버. 시드 해시는 운영주의 |
| 보안 상시(security) | ⭕ GO(현스코프) | blocker 0. 실결제 전 웹훅서명·refresh원장 상 승격 조건 |
| 마스킹 3레이어(privacy) | ❌ NO-GO | B01(blocker) admin/users 셀러 PII 무마스킹 |

## 종합 판정: **❌ NO-GO** (open blocker 1건)
- **PRV-cttee-r02-D01** (신규, 상) — admin/users 셀러 PII 무마스킹.
- 그 외 축은 GO/조건부. blocker 해소(마스킹 적용) 또는 오너 정책확정(원장 강등) 후 GO 전환 가능.
- 상 1 · 중 4 · 하 6.
- **실결제 go-live 승계 조건**: SEC-B03(웹훅 서명검증)·SEC-B02(refresh 원장)을 상으로 승격해 stage8 재게이트.
