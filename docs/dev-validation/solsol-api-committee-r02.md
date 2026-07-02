# solsol-api 계약·데이터 라운드 결함표 — committee-r02

> 라운드: **committee-r02** (백엔드 계약·데이터 트랙 심화) · 기준일: 2026-07-02 (KST)
> 대상: `solsol-api` (Hono·Workers·Aurora, 테넌트+마스터) · 트랙: 계약 라운드(데이터 5축 + 보안 상시 + 마스킹 3레이어 + 계약정합)
> 정본: `db/migrations/*.sql`·`docs/data-model/ERD.md` (06은 참고) · 절차: `../DEV_VALIDATION_PROCESS.md`
> 위원: dba(한데관)·security-reviewer(배보검)·privacy-officer(노개보)·qa(오품관) · 통합: qa-lead(위원장)·총괄
> 성격: **읽기 전용 검증(코드·정본 무수정)**. 실 Aurora 미접근 → 마이그레이션 실적용·`information_schema` 검증은 미실행(담당자 자기 env).

## 정적검증 증거
```
solsol-api : npx tsc --noEmit → EXIT 0 (신규 0 / baseline 0)   [dba·qa 각각 재현]
실 DB(Aurora) 적용·information_schema 멱등 : 미실행(직결 불가)
```

## 결함표 (§6 표준)

| 결함ID | 추적키(EP/테이블) | 검증축 | 심각도 | 현상 | 기대 vs 실제 | 근거(파일:라인) | 제안 | 담당 | 상태 |
|---|---|---|---|---|---|---|---|---|---|
| SEC-cttee-r02-D01 | `GET /health/db`·`/health/db/grants` | 보안-정보노출/인증 | **상(blocker)** | 두 라우트 게이트 미부착 → 프로덕션 무인증 공개. DB버전·**전체 테넌트 스키마명(solsol_t\*)**·`SHOW GRANTS`(계정 권한) 노출 | prod OPS_SECRET 게이트 필요 vs 완전 공개. brand-api는 동일 라우트 게이트됨(대조) | `src/index.ts:95,109,152` | brand-api `index.ts` 게이트 이식(prod `X-Ops-Secret===OPS_SECRET`, grants prod 무조건 차단) | api-developer | open |
| DAT-cttee-r01-D01 | `/api/admin/credits*`·TB_CREDIT | 데이터1 스키마정합 | **상(blocker·이월재확인)** | admin/credits가 미존재 3테이블(TB_CREDIT_ACCOUNT/CHARGE/LEDGER) 조회·삽입 → Aurora 런타임 파손. DDL 정본=단일 TB_CREDIT. 원인=`schema.master.ts` 구버전 | 단일 TB_CREDIT vs 미존재 3테이블 | `src/routes/admin/credits.ts:81-167` · `src/db/schema.master.ts:154-197` vs `db/migrations/000_master.sql:230-266` | schema.master.ts 단일 TB_CREDIT 재미러 + credits.ts 재작성 | api-developer+dba | open(committee-r01 등재분 재확인) |
| SEC-cttee-r02-D02 | `GET /api/admin/vat-reports`·`/:id` | 인가/own스코프(05#3) | 중 | settlements는 scope==='own' 강제하나 vat-reports는 강사 스코프 필터 전무 → 서브강사가 플랫폼 전체 부가세·거래(orderId) 열람 | own 강사=본인분 vs 전체 노출 | `src/routes/admin/settlement.ts:351-456` (cf. :91,:154) | vat-reports scope==='own' 필터 또는 owner 전용 roleGuard | api-developer | open |
| DAT-cttee-r02-D01 | schema.master.ts (TB_SITE·TB_PAYMENT 등) | 데이터1 스키마정합 | 중 | 미러 컬럼/범위 불일치: `owner_seller_id`(DDL=owner_user_id)·`credit_charge_id`(DDL=credit_id)·마스터 9테이블만 정의(TB_USER·PLAN·SITE_USER·USER_AGREEMENT·LOGIN_LOG·SITE_PROVISION_LOG·CONTACT·CONTACT_REPLY·NEWS 누락) | sql↔drizzle↔ERD 4자 동기화 vs 3자 분기 | `src/db/schema.master.ts:60,136,4-5` vs `000_master.sql:24,200` | 000_master.sql 기준 미러 전면 재생성, SoT 주석 migration 통일 | dba | open |
| DAT-cttee-r01-D02 | docs/data-model/master.sql·tenant_template.sql | 데이터1 스키마정합 | 중(이월재확인) | data-model 사본 stale: master 13(CONTACT/REPLY/NEWS 누락·"14개" 오기)·tenant 91(OAUTH_CONFIG 누락). ERD/migration은 16/92 | data-model=migration·ERD 동기화 vs 누락 | `docs/data-model/master.sql:303`·tenant diff vs `ERD.md:6` | data-model/*.sql 현행화 or "파생 사본" 명시 | dba | open(committee-r01 등재분 재확인) |
| DAT-cttee-r02-D02 | TB_ROLE·ADMIN_PERMISSION·USER_ROLE·NOTIFICATION_ROUTE | 데이터3 시드정합 | 중 | 테넌트 부트스트랩 RBAC 매트릭스 시드 미발견(001 INSERT 0·dev_domain_seed는 도메인만·ops는 DDL만) → 신규 테넌트 TB_ROLE 비어있음. 05#3 데이터 의존 시 미동작 위험 | 프로비저닝 시 역할·권한·알림 시드 vs 미발견 | `001_tenant_template.sql`(INSERT 0)·`db/seed/dev_domain_seed.sql` | 프로비저닝 훅에 RBAC·알림 부트스트랩 시드(멱등) 추가. 코드기반이면 근거 명시 | api-developer+dba | open |
| SEC-cttee-r02-D03 | `POST /auth/login` | 보안-남용 | 중 | 계정열거 — 미가입 UNREGISTERED/불일치 MISMATCH/정지 SUSPENDED 구분 반환 | 통일 코드 vs 상태 구분 | `src/routes/auth.ts:960,965,986` | 실패 코드 단일화(정책·privacy 협의) | api-developer/privacy | open |
| SEC-cttee-r02-D04 | `/auth/*` 전역 | 보안-남용/브루트포스 | 중 | 로그인·리프레시·이메일코드 발급 레이트리밋 전무(코드 verify는 5회 상한 있음) | `/auth/*` 레이트리밋 vs 없음 | 전역·`wrangler.toml` | CF Rate Limiting Rules 또는 앱 슬라이딩 윈도우 | deployer/api-developer | open |
| PRV-cttee-r02-D01 | `DELETE /me`(탈퇴) | 마스킹/보관·파기 | 중 | social UID·세션은 파기/revoke하나 name/email/phone 등 핵심 PII는 status=-1 잔존, 파기 스케줄·법정보관 항목/기간 미정의 | 목적달성 후 파기 or 보관기간 명시 | `src/routes/me.ts:482-495` | 파기 배치 or 보관항목·기간 정책 | api-developer/dba | open |
| DAT-cttee-r02-D03 | 000_master.sql·001_tenant_template.sql | 데이터2 마이그레이션안전 | 하 | raw DDL IF NOT EXISTS 0건·롤백 없음(비멱등). 런너(migrate.ts)는 CREATE+IFNE 보정하나 base 스키마는 직접 mysql 적용 | 멱등+롤백 vs 비멱등 raw DDL | `000_master.sql`·`src/lib/migrate.ts:47-72` | base DDL IFNE 부여 or 러너 통일, 롤백 문서화 | dba | open |
| DAT-cttee-r02-D04 | dev_domain_seed.sql | 데이터3 시드정합 | 하 | `solsol_lms` 하드코딩 + 평문 INSERT(IGNORE/upsert 아님) → 재실행 중복/PK충돌(dev 전용) | 재실행 안전 vs 비멱등 | `db/seed/dev_domain_seed.sql` | INSERT IGNORE/ON DUPLICATE + 스키마 파라미터화 | dba | open |
| SEC-cttee-r02-D05 | TB_OAUTH_CONFIG 저장/복호 | 보안-시크릿 | 하 | `SECRET_ENC_KEY` 미설정 시 OAuth client_secret·Apple privateKey 평문 패스스루 | prod at-rest 암호화 vs 키 미주입 시 평문 | `src/lib/crypto.ts:17-19` | prod SECRET_ENC_KEY(32B) 주입 확인 + `v1:` 암호문 유지 | deployer/dba | open |
| PRV-cttee-r02-D02 | community·inquiry 목록/상세 | 마스킹 L1 | 하 | 작성자 `nickname ?? writer`, writer(실명 가능)가 닉네임 부재 시 타인 노출 가능(admin/support는 maskName 적용 → 불일치) | 타인노출 마스킹/닉네임강제 vs 원문 폴백 | `community.ts:280,389,558`·`inquiry.ts:195` | writer 실명 저장 여부 확인 후 마스킹/닉네임 필수 | api-developer | open [확인필요] |
| PRV-cttee-r02-D03 | lib/masking maskEmail | 마스킹 L1 | 하 | 이메일 앞 1자 노출(`a****@`), SoT §3-D "앞 2자"와 불일치(더 보수적이라 누출 아님) | 단일 정본 알고리즘 일치 | `src/lib/masking.ts:24` | 문서·코드 중 정본 확정 후 정합 | api-developer | open |
| QA-cttee-r02-D01 | /auth/signup·nickname/check | 05#1 닉네임 | 하 | 허용문자 정규식에 리터럴 백슬래시(`\\-`) 포함 → `\` 통과 | `[가-힣a-zA-Z0-9_.-]`만 vs `\` 허용 | `src/lib/nickname.ts:33` | 문자셋 정정 | api-developer | open |
| QA-cttee-r02-D02 | 비번 규칙(05#5) | 05#5 | 하 | `hasSpecial=/[^A-Za-z0-9]/` → 공백·한글도 특수문자 인정 | 특수문자 집합 명시 vs 비-영숫 전체 | `src/routes/auth.ts:287` | 특수문자 집합 명시 | api-developer | open |
| QA-cttee-r02-D03 | 계약 커버리지 | 계약정합 | 하 | endpoints 문서 등록(~165) < 실 핸들러(453) + SoT 인벤토리 부재로 EP 1:1 전수 매핑 미실시 | SoT↔구현 누락0 검증 vs 미실시 | `src/docs/endpoints.ts` | 인벤토리 확보 후 전수 매핑 재라운드 | plan-lead | open |

## 축별 판정
| 축 | 판정 | 근거 |
|---|:--:|---|
| 계약정합(qa) | ⭕ GO | 봉투·페이지네이션·게이트 일관, 05 6건 강제(해당분), typecheck 0. (전수는 인벤토리 대기) |
| 05 확정 6건(qa) | ⭕ | 6/6 강제(①닉네임·②무료체험미운영·③RBAC own·④유효시간·⑤비번3종·⑥쿠폰정액) |
| 데이터 5축(dba) | ❌ NO-GO | D01(blocker)·스키마정합 이탈 |
| 보안 상시(security) | ❌ NO-GO | S01(blocker) health/db 무인증 |
| 마스킹 3레이어(privacy) | 🔺 조건부 | blocker 0, 중=탈퇴 파기 |

## 종합 판정: **❌ NO-GO** (open blocker 2건)
- **SEC-cttee-r02-D01** (신규, 상) · **DAT-cttee-r01-D01** (이월 재확인, 상)
- 계약 라운드 종료조건(❌'상' 0건) 미충족. 두 blocker 해소 후 committee-r03 재검 필요.
- 상 2 · 중 6 · 하 8.
