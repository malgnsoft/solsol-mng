# 실 API 결선 Phase A(조회·인증) — E2E 재검증 결함표 · Round 2

- 검증자: QA
- 일자: 2026-07-01 (KST)
- 대상: `solsol`(프론트, :3000, `NUXT_PUBLIC_API_BASE=http://localhost:8787`) ↔ `solsol-api`(`wrangler dev --remote`, :8787 → 실 Aurora/Hyperdrive dev 테넌트 slug `dev`, schema `solsol_lms`)
- 방식: 실 API 대상 E2E(curl: SSR HTML + API 직접 + 인증 루프). mock 소셜은 dev 전용 provider로만 사용. **코드 무수정**(레포 변경 0, `.dev.vars` 무수정 — 기존값 `APP_ENV=local` 그대로, 원복 불필요).
- 대상 보완: 프론트 `X-Site-Host`(SSR=useRequestHeaders host / 클라=location) 부착 · slug useState 공유 · 홈 SSR try/catch 방어 · `NUXT_PUBLIC_TENANT_SLUG` 오버라이드 / API 테넌트 해석 `X-Tenant>X-Site-Host(domain|slug)>Host>dev폴백(prod 차단)` · mock 콜백 dev 허용.
- **판정: GO** — Round1 blocker 3건(D-1·D-2·D-3) 전부 해소. 잔여결함 blocker 0, 중 1, 하 2.

---

## 이전 blocker 해소 확인

### D-1(홈 SSR 500) — **해소(PASS)**
- 홈 `GET /` → **HTTP 200**(500 아님). SSR HTML에 에러상태("사이트를 불러오지 못했습니다") 미노출.
- 히어로 `h1`에 **실 테넌트명 "개발 사이트"** SSR 렌더(하드코딩 폴백 "쏠쏠" 아님) → host→테넌트 해석 SSR 성립.
- 근거: 홈 `app/pages/index.vue`가 top-level `await loadTenant()` try/catch, `useApi.getSiteHost()`가 SSR에서 `useRequestHeaders(['host'])` 반환 → `X-Site-Host: localhost:3000` 부착 → API가 `dev` 폴백으로 200.

### D-2(브라우징 SSR 결선 미성립) — **해소(PASS, 단 SSR 렌더는 설계상 클라 페치)**
- `/courses` → HTTP 200, `/courses/106` → HTTP 200 (TENANT_NOT_FOUND/500 없음).
- API 직접(브라우저와 동일 헤더 = `X-Site-Host: localhost:3000`, X-Tenant 없음):
  - `GET /api/products` → 200, 실 시드 8건(id 101~108, 6개 상품유형 전부).
  - `GET /api/products/106` → 200, `title="프론트+백엔드 올인원 패키지", listPrice=129000, salePrice=109650, discountRate=15`.
  - 무헤더(host=localhost:8787) `GET /api/products` → **200 dev 폴백**(Round1의 404 회귀 해소 확인).
  - `GET /tenant` (X-Site-Host: localhost:3000) → 200, `{slug:"dev", name:"개발 사이트", siteConfig 실데이터}`.
- 유의: `/courses`·상세는 상품 데이터를 `onMounted`(**클라이언트 전용**) 페치 → **SSR HTML에는 상품명이 없고 스켈레톤(animate-pulse)만** 존재. 실데이터는 클라 하이드레이션 후 노출. API가 브라우저 헤더 패턴으로 200+실데이터 반환함을 확인했으므로 클라 렌더 성립. → SSR 성립 여부는 "테넌트 해석"까지는 SSR, "상품 목록/상세"는 클라(설계). 카드 렌더 자체의 브라우저 DOM 스냅샷은 미실행(curl 한계).

### D-3(mock 콜백 400) — **해소(PASS)**
- `POST /auth/social/callback` provider=mock → **200**(400 PROVIDER_UNSUPPORTED 아님).
  - 신규 이메일: `{isNew:true, signupTicket}` 발급.
  - `POST /auth/signup`(ticket+nickname+terms/privacy) → **201 `{user, access}`**.
  - 동일 이메일 재콜백(기존 회원, 쓰기 반영 후): **200 `{isNew:false, needsTerms, access, user{id,nickname,email,userType,role}}`**.
- 발급 Bearer로 `GET /me` → **200** 실 프로필: `avatarUrl(null)`, `role("learner")`, `socials:[{provider:"google", isPrimary:false, linkedAt:null}]`, keys=`[avatarKey,avatarUrl,createdAt,email,id,marketingAgreed,name,nickname,phone,role,socials,status]`.
- 프론트 `mapUserProfile` 정합: `ApiUserProfileRow` 필드(avatarUrl·role·socials·nickname·email…)가 런타임 `/me` 응답 키와 1:1 매핑 확인(`avatarUrl ?? undefined`, `socials Array 가드`, `role` 통과). **런타임 정합 확인**(Round1 미검증 → 이번 검증).

---

## 검증 항목별 결과

### ① 홈/브라우징 SSR 200·실데이터 — PASS
- 홈 200 + 실 테넌트명 SSR. `/courses`·상세 200. API 직접 실 시드 노출. 무헤더/`X-Site-Host: localhost:3000` 모두 dev 폴백 200.

### ② mock 콜백 → /me 루프 — PASS
- callback(신규) → signupTicket → signup 201(access) → callback(기존) → access → `/me` 200 실프로필. 전 구간 200/201.

### ③ 필드 매핑 정합 — PASS(현 시드) / 잠재리스크(하)
- 목록 `listPrice/salePrice/discountRate/thumbnailUrl/avgRating` 정상. 시드 salePrice = round(listPrice*(100-discountRate)/100) 일치(106: 129000·15%→109650). `thumbnailUrl` null → 플레이스홀더(깨짐 없음). `avgRating` null → 별점 hide.
- 잠재(하): 프론트가 API `salePrice` 대신 `price*(1-discountRate)` 재계산(D-4) — 현 시드는 일치하나 API가 커스텀 salePrice 주면 화면가≠API가. (확인만, Round1과 동일 잔존.)

### ④ 폴백 비활성 유지 — PASS
- apiBase 설정 → `useApiFallbackEnabled()=false`(`window.__NUXT__.config.public.apiBase="http://localhost:8787"` 확인).
- API 중지 후 클라 동일 헤더 페치 → **연결거부(HTTP 000)**, mock 은폐 없음. `listProducts/getProduct`가 `if(!fallbackEnabled) throw` → 화면 에러상태("다시 시도" 버튼) 노출.

### ⑤ 회귀(X-Tenant·소셜 5종 게이트) — PASS(코드·스모크)
- 테넌트 해석 우선순위 1 = `X-Tenant`(slug) 분기 불변(`src/middleware/tenant.ts:103-107`) — 관리자단/기존 slug 경로 무손상(additive: X-Site-Host·dev폴백만 추가).
- 소셜 5종 게이트 불변: `isValidProvider`=['google','kakao','naver','apple','facebook'](`src/lib/oauth/index.ts:212-214`), `isAllowedProvider`는 mock만 `APP_ENV!=='production'` 조건(`src/routes/auth.ts:66-69`) → prod에서 mock 차단 유지.

---

## 결함표

| ID | 검증축 | 심각도 | 현상 | 재현 | 기대 vs 실제 | 근거(파일:라인) | 담당·제안 |
|----|--------|--------|------|------|--------------|----------------|-----------|
| R2-1 | 상태/데이터일관성 | 중 | 방금 INSERT한 소셜 회원을 즉시 재콜백하면 `isNew:true` 재발급(잠깐). ~수십초 후 정상 `isNew:false+access`. | signup 직후(<~60s) 동일 code로 `/auth/social/callback` 재호출 | 기대: 기존회원 `{access,user}` / 실제: 일시적 `{isNew,signupTicket}`(중복가입 유도 가능) | Hyperdrive SELECT staleness(`src/routes/ops.ts:334` 주석에 동일 특성 명시). callback 존재조회 `src/routes/auth.ts:418-431` | api-developer: 콜백 존재조회를 최신 읽기(트랜잭션/primary read) 또는 signup 시 INSERT 멱등·ON DUP 처리로 staleness 창 제거 검토. (prod Aurora writer 직결 시 완화 가능 — 확인 필요) |
| R2-2 | 데이터정합(마스킹外) | 하 | mock 회원 `/me` socials가 `provider:"google", isPrimary:false`로 표기(실 primaryProvider='mock'). | mock 콜백→signup→`/me` | 기대: mock 백킹 표기 일관 / 실제: 백킹컬럼(googleUid)만 노출, isPrimary=false | `SOCIAL_UID_KEY.mock='googleUid'`(auth.ts:51), deriveSocials isPrimary=`p===primaryProvider`(me.ts) | dev 전용 아티팩트(prod mock 차단). 영향 없음 — 문서화만. |
| R2-3 | 결선범위(SSR) | 하 | `/courses`·상세 상품 데이터가 클라(onMounted) 전용 페치 → SSR HTML엔 상품명 없음(스켈레톤). | curl `/courses` SSR HTML grep 상품명 → 0건 | 기대(브리프): "SSR/클라 렌더에 실 시드 상품명" / 실제: 테넌트명은 SSR, 상품목록/상세는 클라 렌더 | `app/pages/courses/index.vue:127 onMounted→fetchProducts`, `[id].vue:142 onMounted→fetchDetail` | 설계 선택(SEO 무영향 페이지면 허용). SSR 필요 시 useAsyncData 전환은 별도 기획 결정. |

> blocker(상) 0건. 게이트 종료조건(상 0) 충족 → **GO**.

---

## 환경/정리

- 백엔드 `wrangler dev --remote`(:8787, Hyperdrive `a14c69…`, APP_ENV=local) 정상 기동 후 검증 종료 시 종료.
- 프론트 `NUXT_PUBLIC_API_BASE=http://localhost:8787 pnpm dev`(:3000) 정상 기동 후 종료.
- `.dev.vars` 무수정(APP_ENV 기존 `local` — 오버라이드 불필요, 원복 없음).
- 검증 후 프로세스 전부 종료 확인. `solsol`/`solsol-api` 레포에 QA 편집·신규파일 0(untracked `mockup/app/error.vue`는 QA 산출물 아님, 검증 대상 밖 기존 파일). 본 리포트만 `solsol-mng`에 신규 작성.
- 시드 상품 6종/8건: 101~108. 검증 중 mock signup으로 dev 테넌트에 테스트 회원(2003·2004 등) 생성됨 — dev 스키마 한정, prod 무영향.

## 판정

**GO** — Round1 blocker D-1(홈 500)·D-2(브라우징 결선)·D-3(mock 콜백 400) 전부 해소. mock→/me 인증 루프 런타임 정합, 폴백 비활성, 회귀 불변 확인. 잔여 R2-1(중, staleness 재가입 유도 가능성)·R2-2/R2-3(하)는 배포 차단 아님 — R2-1은 후속 라운드 권고.
