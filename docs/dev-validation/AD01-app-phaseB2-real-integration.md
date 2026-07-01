# AD01 신규 앱 — Phase B2 실 백엔드(solsol-api) 연동 라운드

> solsol-admin ↔ solsol-api **실연동 완료**. 블로커 해소 → 실 로그인·실 데이터·배포. 이전: [B1 BFF](AD01-app-phaseB1-bff-integration.md)·[API 검토](solsol-api-review-round1.md).

- **일시**: 2026-07-01 (KST)
- **대상**: `solsol-admin/`(프론트·BFF) + `solsol-api`(백엔드, 라이브 `https://solsol-api.malgnsoft.workers.dev`).
- **결과**: 라이브 `https://solsol-admin.pages.dev` 에서 **실 관리자 로그인 + 실 데이터**(대시보드·사용자) 동작. 커밋 solsol-admin `ce11a5d`(origin).

## 종합 판정: ⭕ 실연동 완료 (게이트 통과·보안 critical 해소·라이브 검증)

## A. 백엔드 블로커 해소 (solsol-api 수정·재배포)
| 블로커 | 조치 | 재배포 |
|---|---|---|
| 로그인 role 매핑 버그(A) | owner/instructor를 `TB_ROLE`/`TB_USER_ROLE`에서 파생(`userHasRole`)·응답 role 정정 | Version 50ca3ad1 |
| 관리자 계정 시드 부재(B) | `/ops/seed-admin`(INSERT·멱등)로 `solsol_lms`에 staff `admin@solsol.dev`(userId 2002) + PBKDF2 자격 + TB_ROLE(owner) + 11메뉴 TB_ADMIN_PERMISSION(all) | 〃 |
| CORS 임의 Origin 반사(F-1) | allowlist(`solsol-admin.pages.dev`+localhost)·미허용 ACAO 미반환 | 〃 |
| 세션 복원 엔드포인트 부재 | `GET /api/admin/me`(staff self·role·permissions) 신규 | Version 3016f42d |
- 라이브 검증: 로그인 200·role=owner·토큰 / `/api/admin/me` 200(권한 11)·무토큰 401 / role 불일치 401 / CORS 허용·차단 정상. **INSERT만·기존데이터 무삭제**.

## B. 프론트(BFF) 실연동
- **BFF(Nitro server/)**: `apiClient`(X-Tenant·httpOnly 토큰)·`auth/{login,logout,session,demo-login}`·`proxy/[...path]`(화이트리스트 `admin/*`·GET/HEAD).
- **실 세션**: 로그인/데모→httpOnly 쿠키(`admin_at`)→`setSession`(서버 응답만 신뢰)·`/api/auth/session`(=`/api/admin/me`) 복원. `setMockOwner`/localStorage owner 위조 경로 **제거**.
- **실 데이터 전환(1차 배치)**: 대시보드·관리자/강사/학습자 목록 → `/api/proxy/admin/*`. 나머지 도메인은 목 폴백 유지(회귀 0). `useMembersApi` 어댑터(응답 shape·joinType·role 매핑).

## C. 게이트 & 보완
- **security**: B1 프록시 SSRF blocker(화이트리스트·`..`·메서드) → 보완·해소. B2 **critical(실 비번 `Solsol!2026` public 노출)** → **데모를 서버측 실 로그인(demo-login)으로 전환·public 실비번 제거**. 클라 번들 실비번 **0건**(3중 확인, 서버 청크만). 세션 신뢰경계·토큰 비노출·PII 마스킹 PASS.
- **qa**: blocker 0. [중] 새로고침 세션 지속(로그인 튕김) → onMounted 복원·미들웨어 ready로 해소. [하] joinType/sub_instructor 매핑·이중마스킹(무해).

## D. 라이브 배포 검증 (프로덕션)
- `POST /api/auth/demo-login` → 200·owner 세션(서버측 실 로그인, 클라 비번 무). `/api/auth/session` → 200 authenticated(권한 11). `/api/proxy/admin/admins`(쿠키) → **200 실 봉투**(시드 계정 2건·비번/해시 없음) = 프로덕션 Pages Function이 solsol-api 실제 도달. 무쿠키 → 401. 클라 자산 실비번 0.
- **데모 계정**: `admin@solsol.dev` / `Solsol!2026`(dev). 데모 종료 시 Pages env `NUXT_PREVIEW_DEMO=false`로 원클릭 404화(재배포 불요).

## E. 다음 배치 / 잔여
- 조회형 나머지 도메인(상품·콘텐츠·판매·마케팅·운영·사이트·정산·설정·통계) 동일 패턴(`/api/proxy/admin/*`) 순차 전환. 목록 필터/정렬/페이지네이션 서버 위임.
- 쓰기형(상태변경·초대·탈퇴·생성/수정/삭제): 프록시 GET 전용 → **CSRF 방어 갖춘 전용 BFF 핸들러** 추가 후 배선.
- 백엔드 잔여(라운드1): 경로 `/api/auth/login` 정렬·F-2 계정열거·F-3 레이트리밋·F-5 공개경로 401·`/health/db` verdict·seed 비번 Pages secret 이전·정률쿠폰 등.
- 운영 위생: `SEED_ADMIN_PASSWORD` 로테이션·Pages env화, 데모 공개 노출 범위(현재 원클릭 owner=dev 데이터) 정책.
