# AD01 신규 앱 — Phase B1 백엔드 실연동 기반(BFF) 라운드

> solsol-admin ↔ solsol-api 실연동 **1단계(연동 배관)**. 블로커(관리자 시드·로그인 role버그·CORS)는 백엔드 오너 해소 대기 — "되는 것(파이프)부터" 구축.

- **일시**: 2026-07-01 (KST)
- **대상**: `solsol-admin/` — Nitro `server/` BFF. 백엔드 `solsol-api`(라이브 `https://solsol-api.malgnsoft.workers.dev`, 무수정).
- **게이트**: security-reviewer(초기 NO-GO → 보완 → 해소 확인).

## 종합 판정: ⭕ 통과(보완 후) — 연동 파이프 실증 + 프록시 SSRF blocker 해소

## A. 구축 (BFF)
- `server/utils/apiClient.ts` — solsol-api 호출 헬퍼: `apiBase`(서버전용)·`X-Tenant: dev` 주입·쿠키 토큰 Authorization 부착·`{ok,data|error}` 봉투·Set-Cookie 수집·토큰 무로그.
- `server/api/auth/{login.post,logout.post,session.get}.ts` — 로그인→**httpOnly 쿠키**(`admin_at`)+refresh 전파/미러(`admin_rt`)·세션 검증(`/api/admin/me`)·로그아웃.
- `server/api/proxy/[...path].ts` — **조회형 프록시**(하드닝 후: `admin/*`만·GET/HEAD만).
- `app/composables/useApi.ts` — 실요청 BFF 경유(`/api/proxy`·`/api/auth`), `isMock` 목 폴백 유지(회귀 0).
- `nuxt.config.ts` — 서버전용 `apiBase`·`tenantSlug='dev'`. **클라 번들에 solsol-api URL·토큰 미노출**.
- 데모 원클릭 입장·프리필 **유지**(블로커 해소 전 미리보기 사용성).

## B. 파이프 실증 (BFF → 실 solsol-api 도달)
- `GET /api/proxy/products` → 실 봉투 `{ok:true,data:{items:[],total:0}}` **200**(연결·테넌트 동작).
- `GET /api/proxy/admin/users`(무토큰) → 실 `UNAUTHENTICATED` **401**(Bearer 게이트 도달).
- `POST /api/auth/login`(임의계정, 정상 이메일) → 실 `UNREGISTERED` **401**(인증 파이프 실서버 도달 — 시드 부재로 실패가 정상).

## C. security 게이트 — 초기 NO-GO(프록시 SSRF) → 보완·해소
| 심각도 | 결함 | 조치 | 실증 |
|:--:|---|---|---|
| **상** | 프록시 `[...path]` 화이트리스트·`..` 방어·메서드 제한 부재(SSRF/authz 우회) | `admin/*`만 화이트리스트(그외 404)·`..`/인코딩 슬래시/제어문자 거부·`new URL` origin+prefix 검증·**GET/HEAD만**(405) | `products`→404·`auth/refresh`→404·`admin/../ops`→404·인코딩→404·`POST`→405·`admin/users`무토큰→401 |
| 중 | 상태변경 CSRF(SameSite만 의존) | login/logout **Origin/Referer 동일오리진 검증**(403) | 교차오리진 login→403 |
| 중 | refresh 미러 `admin_rt` Path=`/` 노출면 넓음 | Path `/api/proxy`로 축소 | 반영 |
- 통과 확인: 토큰 클라 비노출(응답 본문/public/번들)·server `console.*` 0·httpOnly+Secure+SameSite.

## D. Phase 1 이관(블로커/프로덕션 해소 시)
- 데모 버튼·프리필·`devLoginCode`(public) **프로덕션 전 제거**(현재 미리보기 유지).
- 클라 게이트를 `localStorage` 플래그 → `/api/auth/session` 기반으로.
- 쓰기형(mutation) 프록시는 도메인별 CSRF 방어 갖춘 전용 핸들러로 추가.

## E. 다음(백엔드 블로커 해소 후 = Phase B2)
1. 관리자 시드+role 파생(solsol-api Blocker A·B) 해소 → 실 로그인 성공 시 `/api/auth/session`으로 실 user/permissions 부트스트랩(`setMockOwner` 대체).
2. **조회형 12도메인** `useApi`→`/api/proxy/admin/*` 도메인별 점진 전환(목 폴백 단위 제거). 실행형은 staging-gate 유지.
3. solsol-api CORS(F-1)는 BFF 경유라 무관(브라우저 직결 시에만 재검토).

## 관측(백엔드 오너 참고)
- refresh 쿠키 실명 `solsol_refresh`(Path=/auth·SameSite=None). 세션 검증 = `/api/admin/me`(`/auth/me` 없음). 프로덕션 호스트는 `X-Tenant: dev` 필수.
