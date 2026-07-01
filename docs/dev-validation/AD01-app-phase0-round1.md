# AD01 관리자단 신규 앱 — Phase 0 골격 검증 라운드 1

> 검증 정본(`docs/validation/`)은 읽기 전용 — 본 결과는 그 **밖**(dev-validation)에 기록(절차: [DEV_VALIDATION_PROCESS.md](../DEV_VALIDATION_PROCESS.md)).
> ※ 기준선 목업 검증은 [AD01-customer-admin-round1.md](AD01-customer-admin-round1.md) 참조. 본 문서는 **레포 루트 신규 앱**(`solsol-admin/`) Phase 0 골격 대상.

- **일시**: 2026-07-01 (KST)
- **검증 대상**: `/Users/dotype/Projects/solsol-admin/`(레포 루트 신규 앱) — Nuxt 3(compat v4)·Nuxt UI v3·Pinia. 목업(`solsol-admin/mockup/`)은 디자인·IA 기준선(무수정).
- **Phase 0 범위**: 스캐폴드 · 디자인시스템 이식(토큰·레이아웃·LNB/GNB) · RBAC 구조(menuKey별 `hasMenu` hide) · auth 스토어·전역 미들웨어·`useApi` 래퍼 · **인증 4화면**(S-AD01-0301-001/0302-001/0302-002/0303-001) · **대시보드**(S-AD01-0100-001) · catch-all 플레이스홀더.
- **정본(SoT)**: `docs/validation/{00_화면목록,02_customer-admin,04_정책요약,05_정책설계서,06_API계약}.md`.
- **수행**: 총괄(chief) 오케스트레이션 — 구현 admin-developer, 게이트 qa·security-reviewer·privacy-officer. SoT·목업·검증문서 무수정.

## 종합 판정: ⭕ **게이트 통과** (3렌즈 전원 blocker '상' 0건)

빌드 `pnpm build` 성공(에러 0), 라우팅 스모크(`/`→`/admin`→비인증 게이트→`/auth/login` 200) 통과.

---

## A. 게이트 결과 요약

| 렌즈 | 판정 | blocker | 핵심 지적 |
| --- | --- | :---: | --- |
| qa | 통과 | 0 | register 역할라디오·닉네임 미존재(중, 기준선 승계) · auth 반응형 오버플로(하) · 목→Phase1 실동작 다수(하) |
| security-reviewer | 통과 | 0 | localStorage 세션(중)·RBAC hide만·직접URL 인가 없음(중)·devLogin public 노출(하) — 전부 Phase 1 서버연동 시 필수 이관 |
| privacy-officer | 통과 | 0 | 대시보드 "최근 1:1문의" 작성자 실명 비마스킹(중) — 구조 고정 권고 |

## B. Phase 0 프론트 보완 라운드 (품질 마감 — 완료)

프론트만으로 마감 가능한 6건을 즉시 보완하고 `pnpm build` 재성공 확인.

| # | 항목 | 검증축 | 결과 |
| --- | --- | --- | --- |
| 1 | register 역할 라디오(강사/관리자·default 강사) | 존재/카피 | ⭕ |
| 2 | register 닉네임 필드 + 2~15자 검증([n/15]·중복확인 목) | 존재(C-1) | ⭕ |
| 3 | register 비밀번호 강도 바(reset 로직 재사용) | 인터랙션 | ⭕ |
| 4 | auth 4화면 반응형(`w-full max-w-*`·390px 오버플로 해소) | 반응형 | ⭕ |
| 5 | 대시보드 작성자 `maskName()` 마스킹(CMP-01) + `app/utils/mask.ts` 신설(maskName/maskEmail/maskPhone) | 마스킹 | ⭕ |
| 6 | `auth.global.ts` `/auth` 경계 슬래시(`/authxyz` 우회 차단) | 미들웨어 | ⭕ |

## C. 05 확정 6건 — 인증화면 적용분

| # | 항목 | 결과 |
| --- | --- | --- |
| ① 닉네임 2~15 | ⭕ register 닉네임 필드·검증 반영(보완 라운드) |
| ④ 유효시간(가입코드 10분/재설정 30분) | ⭕ 가입 10:00 카운트다운·만료 처리 / 재설정 30분 문구 |
| ⑤ 비밀번호 3종 8~16자 | ⭕ register·reset 검증함수(상한 16 포함)·문구 통일 |
| 라운드1 결함(비번 상한·가입코드 04:59·"로그인 하기" 카피) | ⭕ 전부 수정 |
| ②무료체험 ③RBAC ⑥쿠폰 | 해당 화면 Phase 1(도메인) 범위 |

## D. Phase 1 승계 항목 (배포 전 필수 — 백엔드 의존)

> 실 API·실 시크릿·실 PII가 붙는 Phase 1 배포는 1~3 미해결 시 **운영 배포 반대**(security-reviewer). 미해결 시 해당 항목 '상' 승격.

1. **[중]** 세션 httpOnly+Secure+SameSite 쿠키 + 서버 검증, localStorage 플래그 폐기.
2. **[중]** RBAC 라우트 가드(`roleGuard`) + **API 서버측 403 강제**(EXC-06 직접URL 차단) — hide는 인가 아님.
3. **[하→상]** `runtimeConfig.public.devLogin*` + login.vue 목 분기 **동시 제거**(실서비스 백도어 방지).
4. **[하]** 로그인 서버 인증: 레이트리밋·브루트포스 방어·실패메시지 단일화(계정 열거 차단)·비번 해시(bcrypt/argon2).
5. **[중]** register 역할 라디오·닉네임 중복확인·10회 발송제한·SUSPENDED 분기의 **실 API 실동작** 연결.
6. **[하]** 디자인 토큰 점진 적용(신규 화면부터), 이름 성/이름 분리 실검증.

## E. 다음 단계

- **Phase 1 도메인 이식**(breadth-first): 사용자 → 상품(7유형) → 콘텐츠 → 판매 → 마케팅 → 운영 → 사이트디자인 → 통계 → 정산 → 설정. 각 화면ID 단위로 목업 이식·프로덕션화 + 상태(빈/로딩/에러)·모달 + RBAC hide, 목 데이터. 라운드마다 qa·security·privacy 게이트.
- **백엔드 연동 트랙**: `solsol-api`(Hono·MySQL) 인증/RBAC 계약 확정 후 `useApi` 실연동 + D 항목 해소.
