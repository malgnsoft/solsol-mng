# brand-admin (solsol-brand-admin) 개발 검증 — Round 2 (Phase 1 + 실 API 연동 + 배포조건)

> 대상: Phase 1 신규 5도메인(크레딧·공지/뉴스·문의CS·통계·설정) + solsol-brand-api **운영자 API 신규(30EP)** + BFF **실 연동 배선** + **배포 전 조건**.
> 정본: solsol-brand-admin `docs/DESIGN_SPEC.md`·`docs/DEPLOY.md` · solsol-brand-api `src/routes/admin/*` · 마스터 스키마.
> 검증일 기준: 2026-07-01(KST). 검증 폴더(`docs/validation/`) 무수정.

## A. 범위/커버리지

- **Phase 1 화면 10건**: S-BA01-0701-001/002 크레딧 · 0801-001/002 공지 · 0901-001/002 문의 · 1001-001 통계 · 1101-001/002/003 설정. 구현 100%, 스텁 잔존 0.
- **brand-api 운영자 API 30EP**: `/admin/auth/*`(로그인·refresh·me·logout) + sites·users·plans·subscriptions·invoices·payments·credits·contact·news·stats. requireAdmin(typ=admin) + requireRole(mutation). admin JWT·refresh 쿠키 분리. 시드 파일 제공(실행 보류).
- **BFF 실연동**: `NUXT_API_BASE` 설정 시 실연동/미설정 시 mock 폴백. role→permissions 매트릭스, camelCase→snake_case 어댑터(Phase 0 핵심 6도메인 매핑, Phase 1 4도메인 스텁 통과=TODO).
- **배포조건**: NUXT_SESSION_SECRET fail-fast, 로그인 레이트리밋(인메모리+CF WAF 권고), wrangler.toml, docs/DEPLOY.md 체크리스트.

## B. Round 2-1 결함 (3게이트) — 판정 HOLD

| 출처 | 결함 | 심각도 | 조치 |
| --- | --- | --- | --- |
| SEC B-1 | brand-api `PATCH /admin/sites\|users/:id`에 requireRole 누락 → support 변경·삭제 가능 | **상** | ✅ requireRole('superadmin','admin') 추가 |
| SEC A-1 | BFF refresh 쿠키 relay 이름/경로 불일치 → refresh 재발급 구조적 실패·토큰 취급 오류 | **상** | ✅ relay 폐기, refresh를 HMAC 세션(서버측) 흡수·서버→서버 회전 |
| SEC A-7 | BFF 프록시 RBAC 메서드 무구분 → support가 mutation 통과 | **상** | ✅ authorizeProxy(method) — support mutation 403 |
| PRIV #1 | 문의(CS) 본문·첨부 원문 렌더 → 계좌·사업자번호·제3자 이메일 노출 | **상** | ✅ maskPiiInText() + 본문/첨부 마스킹 + 목업 원문 교체 |
| QA | 크레딧 원장 balance_total ≠ open-lot 합계(SITE1/4/6/10) | 중 | ✅ buildEntries 2-pass·lot_state 정정 |
| PRIV #2 | 답변 스레드 본문 마스킹 누락(제3자 이메일 1건) | 중 | ✅ 총괄 1줄 보완(reply 본문 maskPiiInText + 목업 교체) |
| QA | 설정 기본 랜딩 admin 차단 · notices 무의미 삼항 | 하 | ✅ settings.to→terms · 삼항 정리 |

## C. Round 2-2 재검증 — 판정 **GO** ✅

| 게이트 | 판정 | 근거 |
| --- | --- | --- |
| security | **GO** | B-1(sites/users PATCH requireRole)·A-1(refresh 세션 흡수·회전)·A-7(method-aware RBAC) 코드 해소 확인. 이중 게이트(BFF+API)·세션 HMAC·accessToken 미노출·계정열거·마스킹·매트릭스 parity 유지. 신규 상/중 0. |
| qa | **GO** | Phase1 10화면 커버리지 100%·9축 PASS·회귀 없음. 크레딧 정합 정정. typecheck 0. |
| privacy | **GO** | #1(본문/첨부 maskPiiInText)·#2(답변 본문) 해소. OAuth secret 미노출·password_hash 부재·카드 마스킹·adapt 민감필드 미복원 유지. |

**통합 검증**: brand-admin `pnpm nuxt typecheck` 0 / `pnpm build` 성공 · brand-api `pnpm typecheck` 0 / `wrangler build` 성공.

## D. 종합 판정: **게이트 통과(GO)** — ❌'상' 0건

### 잔여(중/하 — 배포 비차단, 후속 트래킹)
- **인프라 TODO(중)**: 운영 배포 전 **CF WAF Rate Limiting**(로그인) 적용 필요. refresh 원장 부재(탈취 즉시 무효화 불가)·refresh 쿠키 SameSite=None(BFF 서버간 구조상)는 후속 개선.
- **실연동 어댑터(하)**: Phase 1 4도메인(credits·contact·news·stats) camelCase→snake_case 어댑터 미구현(현재 mock 기본이라 무해). 실연동 착수 시 구현.
- **운영자 시드**: brand-api `db/seed.admin.sql` 실행은 원격 Aurora 쓰기 → 사용자 확인/배포 시 DBA가 직접 적용.

### 운영 배포 전 조건 (docs/DEPLOY.md)
① NUXT_SESSION_SECRET 설정 ② NUXT_API_BASE=brand-api URL ③ CF WAF Rate Limiting ④ 운영자 시드 적용 ⑤ Phase1 어댑터 구현.

## E. 참여자 활동내역 (Round 2)

| 담당(역할) | 수행 |
| --- | --- |
| admin-developer | Phase 1 스캐폴딩(menuMap·타입·스텁) + 크레딧·통계·공지·문의·설정 5도메인 + app 보완(CS PII 마스킹·크레딧 정합·minor) |
| api-developer | brand-api 운영자 API 30EP 신규 + BFF 실연동 배선(role→permissions·어댑터) + 배포조건(레이트리밋·wrangler·DEPLOY.md) + 보안 보완(B-1·A-1·A-7) |
| qa | Phase1+통합 9축 검증(GO) |
| security-reviewer | BFF+운영자API 보안 검토 2라운드(HOLD→GO) |
| privacy-officer | Phase1 마스킹 검토 2라운드(HOLD→GO) |
| chief(총괄) | 범위·아키텍처 결정·오케스트레이션·통합 검증·#2 마무리·기록 |
