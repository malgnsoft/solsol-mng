# 실 API 결선 Phase A(조회·인증) — E2E 검증 결함표 · Round 1

- 검증자: QA
- 일자: 2026-07-01 (KST)
- 대상: `solsol`(프론트, :3000, `NUXT_PUBLIC_API_BASE=http://localhost:8787`) ↔ `solsol-api`(`wrangler dev --remote`, :8787 → 실 Aurora dev 테넌트 slug `dev`)
- 방식: 실 API 대상 E2E(curl SSR HTML + API 직접). mock 아님. **코드 무수정**(레포 변경 0, `.dev.vars` 무수정 — 기존값 `APP_ENV=local` 그대로).
- 판정: **NO-GO** (blocker 2건)

> 비고: 브리프는 "`.dev.vars`에 `APP_ENV` 없으면 prod 403 → 임시 `APP_ENV=dev` 추가"를 가정했으나,
> 실제 `.dev.vars`는 이미 `APP_ENV=local`(로 세팅됨). `local`은 dev 라우트·mock 게이팅 모두 만족하고
> `getMasterSchema`가 `solsol`(dev 기본) 반환 → dev 검증에 정상 동작. 따라서 `.dev.vars`를 건드리지 않음(원복 불필요).

---

## 검증 항목별 결과

### ① API 직접(X-Tenant: dev) — PASS
- `GET /tenant` 200 — `{id:1, name:"개발 사이트", slug:"dev", siteConfig/bizInfo 실데이터}`
- `GET /api/categories` 200 — 5건(개발/프로그래밍, 웹 프론트엔드, 백엔드/DB, 디자인, 마케팅/비즈니스)
- `GET /api/products` 200 — 8건(id 101~108, 6개 상품유형 전부: general·live·video_call·digital·package·membership·community)
- 결론: 실 시드 데이터 정상. 헤더 `-H "X-Tenant: dev"` 필수 확인.

### ② 프론트 SSR 결선 + 테넌트 이슈 — **FAIL (blocker)**
- 홈 `/`: **HTTP 500**. SSR HTML 내 `"statusCode":500, "message":"존재하지 않는 사이트입니다.", "stack":["...","at apiFetch (...)"]`.
- `/courses`, `/courses/101`: HTTP 200 (SSR 셸만) — **실 시드 상품명 SSR HTML에 미노출**(제목 0건), mock 상품명도 0건.
- **테넌트 이슈 판정: 실제 발생(확정).**
  - 원인: `useApi.getTenantSlug()`가 `if (!import.meta.client) return null` → SSR 요청에 `X-Tenant` 미부착.
    API 미들웨어(`src/middleware/tenant.ts`)는 X-Tenant 미지정+host=localhost일 때 소스상 `dev` 폴백 로직이 있으나,
    **실행 중인 `--remote` 워커에서 이 폴백이 동작하지 않음**(무헤더 `/tenant` → 404 TENANT_NOT_FOUND, `?tenant=dev`/`X-Tenant:dev`만 200).
  - 홈 `/`는 top-level `await loadTenant()`(SSR 실행) → 404 → `fallbackEnabled=false` → 재throw → SSR 500(D-1).
  - `/courses`·상세는 `onMounted`(클라이언트 전용) 페치라 SSR 500은 회피되나, **SSR 결선 자체가 미성립**(HTML에 실데이터 없음) + 첫 클라이언트 방문 시 동일 무헤더 문제 재현(D-2).

### ③ 인증 콜백·/me — **FAIL(mock E2E 불가) / 부분 PASS(계약·게이팅)**
- `GET /me` 무Bearer/무효Bearer → 401 UNAUTHENTICATED (게이팅 정상).
- `GET /auth/social/authorize?provider=mock` → 200 (authorizeUrl 발급 정상).
- `POST /auth/social/callback` provider=mock → **400 PROVIDER_UNSUPPORTED**.
  - 원인: `env=local`이라 `resolveProvider`는 mock provider 반환(비-null)하나, 콜백 핸들러가 이후
    `isSocialProvider('mock')`(SOCIAL_UID_KEY=google/kakao/naver/apple/facebook만) = false → `providerUnsupported` throw(D-3).
  - 결과: **mock 기반 `{access,user}` 발급 불가 → Bearer로 `/me` 실데이터 조회 E2E 미수행**(런타임 검증 불가).
- 필드 정합(정적): `/me` 응답에 `avatarUrl`(buildMediaUrl), `role`(toFrontRole), `socials[]` 포함 →
  프론트 `mapUserProfile`(avatarUrl·role 매핑) 기대와 **계약상 정합**. 단 런타임 미검증.

### ④ 폴백 비활성 확인 — PASS
- apiBase 설정 시 `useApiFallbackEnabled()=false` → 조회 실패가 mock으로 은폐되지 않음.
- API 중지 상태 홈 `/` SSR → HTTP 500(`[GET] ... fetch failed`), **mock 테넌트/상품명 미노출**(제미나이·ChatGPT·쏠쏠 h1 모두 0건).
- 결론: 은폐 방지 정책 동작 확인. (products 화이트리스트도 `listProducts`에서 `if(!fallbackEnabled) throw` — 동일 보장.)

### ⑤ 필드 매핑 정합 — PASS(현 시드) / 잠재리스크(하)
- 실 응답 필드 `listPrice/salePrice/discountRate/thumbnailUrl/avgRating` ↔ `mapProductCard` 정상.
- 8개 시드 전부 `salePrice == round(listPrice*(100-discountRate)/100)` → 가격 표기 일치(예 101: 99000·20%·79200 / 106: 129000·15%·109650).
- `thumbnailUrl` 전부 null → 카드 플레이스홀더(깨짐 없음). `avgRating` null → toNum→0 → 별점 hide(정상).
- 잠재: 프론트 `formatPrice/finalPrice`는 API `salePrice`가 아니라 `price*(1-discountRate)`를 **재계산**함.
  현 시드는 일치하나, API가 공식과 다른 커스텀 salePrice를 주면 화면가≠API가 발생(하, 미노출 리스크).

---

## 결함표

| ID | 검증축 | 심각도 | 현상 | 재현 | 기대 vs 실제 | 근거(파일:라인) | 담당·제안 |
|----|--------|--------|------|------|--------------|----------------|-----------|
| D-1 | SSR 결선/에러경로 | **상(blocker)** | 홈 `/` SSR HTTP 500 (TENANT_NOT_FOUND) | `curl http://localhost:3000/` (apiBase 설정) | 기대: 200+테넌트명 렌더 / 실제: 500 "존재하지 않는 사이트입니다." | `solsol/app/pages/index.vue:7`(top-level `await loadTenant()`) → `useTenant.ts:61,70-72`(rethrow) ← `useApi.ts:86-89`(SSR X-Tenant null) | api-developer/frontend: SSR에서 host 기반 테넌트 해석(서버 X-Tenant 주입) 또는 서버 프록시. 프론트 loadTenant SSR 에러를 치명적으로 전파하지 않도록 방어 |
| D-2 | 테넌트 해석 | **상(blocker)** | 무 X-Tenant + host=localhost 요청이 `dev`로 폴백되지 않고 404 | `curl http://localhost:8787/tenant`(무헤더) → 404 / `?tenant=dev` → 200 | 기대: localhost 무헤더 시 slug `dev` 폴백(소스 tenant.ts:89-93) / 실제: TENANT_NOT_FOUND 404 | `solsol-api/src/middleware/tenant.ts:77-97` (실행 워커에서 폴백 미동작) | api-developer: `--remote` 워커의 localhost→dev 폴백 미동작 원인 규명(빌드/배포 스큐 or 로직). SSR/첫방문 결선의 근본 원인 |
| D-3 | 인증 콜백 | **상(blocker)** | mock provider 콜백이 PROVIDER_UNSUPPORTED로 실패 | `POST /auth/social/callback {provider:"mock",code:...}` (X-Tenant:dev) | 기대: `{access,user}` 또는 `{isNew,signupTicket}` / 실제: 400 PROVIDER_UNSUPPORTED | `solsol-api/src/routes/auth.ts:397-399`(`isSocialProvider('mock')`=false) vs `oauth/index.ts:111-115`(mock 허용) | api-developer: 콜백에서 mock provider 처리 경로 추가(mock UID 컬럼 매핑 or mock 전용 분기). 없으면 mock 기반 인증 E2E 불가 |
| D-4 | 필드매핑 | 하 | 화면 판매가가 API `salePrice`가 아닌 재계산값 사용 | 코드 정적 분석 | 기대: API salePrice 우선 표기 / 실제: `price*(1-discountRate)` 재계산(현 시드는 일치) | `solsol/app/utils/productFormat.ts:14-18`(finalPrice), `useProducts.ts:378-382`(mapProductCard는 salePrice 파싱하나 Product에 미보존) | frontend: 커스텀 salePrice 대비 salePrice를 Product에 보존·우선 사용 검토(현 시드 무영향) |

---

## 종합 판정: **NO-GO**

blocker 3건(D-1/D-2/D-3). Phase A 조회의 SSR 결선이 성립하지 않고(홈 500, 목록 SSR 무데이터),
인증 mock E2E가 콜백 단계에서 차단되어 `{access}→/me` 실데이터 루프를 런타임 검증할 수 없음.

### 우선 보완(순서)
1. **D-2**(근본): `--remote` 워커에서 localhost 무헤더→`dev` 폴백 미동작 규명·복구. 이게 D-1의 상위 원인.
2. **D-1**: SSR 테넌트 해석 전략 확정(host 기반 서버측 X-Tenant 주입 or 서버 프록시) + 프론트 SSR loadTenant 에러 방어(치명적 500 방지).
3. **D-3**: 콜백 mock provider 처리 경로 추가 → mock 인증 E2E 재검증(`{access}→/me` avatarUrl·role 실데이터 확인).
4. (재검증 시) ③ /me 필드 런타임 정합, ⑤ D-4 커스텀 salePrice 케이스 확인.

### PASS(현 상태 유지 항목)
- ① API 직접 실데이터(200·시드 8상품/5카테고리/테넌트)
- ④ 폴백 비활성(실패→에러, mock 미은폐)
- ⑤ 필드매핑(현 시드 한정 일치)
