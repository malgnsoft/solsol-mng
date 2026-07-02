# T8 — API 계약 정합 트랙 결함표 (r01)

- 위원회 트랙: **T8 API 계약 정합** (계약 vs 실 API 라우트 · 프론트 사용처 매칭)
- 검증일: 2026-07-02 (KST)
- 방식: **코드 무수정 · 읽기전용**. 파괴적/쓰기 API 호출 없음.
- SoT: `docs/data-model/ERD.md` + 실 라우트(`solsol-api`/`solsol-brand-api` `src/routes`, `src/docs/endpoints.ts` 카탈로그, `openapi`).
  `docs/validation/06_API계약.md` 는 **참고(D1 가정 격하, 권위 아님)** — 맥락만.
- 대상:
  - `solsol-api` (사용자단 FR01 `/api/*`·`/auth`·`/me`·`/tenant` + 관리자단 AD01 `/api/admin/*`)
  - `solsol-brand-api` (seller `/api/*` + 운영자 `/admin/*` + `/webhooks`)
  - 프론트 사용처: `solsol/app/composables/*`(15), `solsol-brand/app/composables/*`(11)

---

## 매핑 요약 (라우트 ↔ 카탈로그 ↔ 프론트)

### solsol-api ↔ solsol 프론트 (FR01)
- 프론트 composable 15종이 실제 호출하는 EP를 정규화 추출 → 실 라우트/카탈로그와 대조.
- **일치 확인(행복경로 정합)**: products/categories/my-products, classrooms/dashboard, enrollments/:id/progress,
  live-rooms(+chat), me/certificates(+:id+/pdf), billing/cards(+primary+삭제), orders(POST)/orders/checkout/orders/:id/cancel,
  subscription-products(+:id), subscriptions/current·/mine·POST·/:id/plan·DELETE /:id, coupons/mine·/usable·/:id/claim,
  wishlist·products/:id/wishlist, boards/:id/posts(+:postId)·posts/:id(+comments)·comments/:id·uploads/attachment·image,
  inquiries(+:id+/replies), faqs, me/notifications(+/read-all)·notification-settings, auth/login·signup·nickname/check·refresh·logout·social/authorize·social/callback, me, tenant.
  → **위 전부 실 라우트에 존재하며 경로·메서드 일치.**
- **불일치 1건**: `GET /api/my-orders` (아래 D01).

### solsol-api 카탈로그(endpoints.ts) ↔ 실 라우트
- 카탈로그 ~130 EP가 실 라우트 마운트와 정합. 관리자단 12개 라우트(settings/site/contents/products/commerce/settlement/credits/members/marketing/stats/support/dashboard) 모두 대응.
- **카탈로그 누락 1건**: `/api/admin/me`(staff 세션 부트스트랩, index.ts:241 마운트)가 endpoints.ts `ENDPOINTS` 배열에 없음 (D03).

### solsol-brand-api ↔ solsol-brand 프론트
- brand-api: 라우트 43 path(카탈로그 43 entries) — seller(auth·account·agreements·plans·sites·billing·subscriptions·invoices·payments·contact·news) + 운영자(`/admin/*`) + `/webhooks/toss`.
- brand 프론트 11 composable 중 **실 EP 호출은 2건뿐**: `useNews→GET /api/news`, `usePlans→GET /api/plans` (둘 다 존재·일치).
  나머지(account/billing/inquiries=contact/myProduct/sites/auth/legalDocs)는 **mock 폴백 전용** — 대응 brand-api EP는 존재(부재 아님) (D05).

### 엔벨로프 / 게이트 (공통 축)
- 성공 `{ ok:true, data, meta? }` / 실패 `{ ok:false, error:{ code, message, field? } }` — 두 API `lib/response.ts` 동일 정의. onError·notFound 핸들러도 동일 봉투.
- 예외: `/health*` 인프라 EP는 raw `{ ok, env, time }`(비봉투) — 문서상 인프라 레벨 명시 (D04).
- staging-gate: 금전/비가역 EP(orders·subscriptions·admin/credits, brand billing/payments/subscriptions)는 `pending`/`gated:true` shape + `TODO(staging-gate)`로 실 PG 호출 차단 — **양 API 일관**. 웹훅(`/webhooks/toss`)은 HMAC 서명검증 골격 + event_id 멱등 — 일관.

---

## 결함표

| 결함ID | 엔드포인트(+영향 화면ID) | 축 | 심각도 | 현상 | 근거 | 제안 | 상태 |
|---|---|---|---|---|---|---|---|
| API-cttee-r01-D01 | `GET /api/my-orders` (내 주문/결제내역, FR01 마이페이지 주문내역) | 4 프론트↔EP | **상** | solsol 프론트 `useOrder.ts:503-505` 가 `GET /api/my-orders` 를 실호출하나 solsol-api 에 해당 라우트 **부재**(grep 결과 0건). API는 동일 용도를 `GET /api/orders`("내 주문/결제내역", 카탈로그 line542)로 구현. → 실 응답 항상 404 → `catch` mock 폴백. 주문내역 **실데이터 행복경로 영구 차단**(개발중엔 mock라 무증상). | routes/orders.ts GET `/`(mount `/api/orders`); endpoints.ts:542; `solsol/app/composables/useOrder.ts:504` | 프론트를 `GET /api/orders` 로 정렬(권장 — 라우트/카탈로그가 SoT). 불가 시 API에 `/api/my-orders` 별칭 추가. | 미해결 |
| API-cttee-r01-D02 | solsol 프론트 다수 composable JSDoc | 3 표기정합 | 하 | `useOrder`/`useProducts`/`useSubscription`/`useCoupon` 등의 주석이 폐기된 06계약을 인용해 "§x.x GET … **미정** → mock 폴백"으로 표기하나, 해당 EP(`/api/my-products`,`/api/subscriptions/mine`,`/api/coupons/mine`, notifications)는 **실제 존재·호출됨**. 코드는 정상이나 주석이 오도(개발자 mock 잔존 유발). | endpoints.ts:357,655,702,929-985; useProducts.ts:1063, useSubscription.ts:392/413, useCoupon.ts | 스테일 주석을 실 계약 상태로 갱신(별도 문서정리 작업). 계약 EP 확정 반영. | 미해결 |
| API-cttee-r01-D03 | `GET /api/admin/me` (staff 세션 부트스트랩, AD01) | 1 존재/카탈로그 | 하 | 라우트는 index.ts:241 에 마운트·동작하나 `docs/endpoints.ts` `ENDPOINTS` 배열(문서 렌더 정본)에 **미등재** → `/doc` 카탈로그·openapi 에서 누락. | index.ts:241 `adminMe`; endpoints.ts ENDPOINTS(1170-1197)에 adminMe 없음 | endpoints.ts 에 adminMe EP 레코드 추가(문서 현행화). | 미해결 |
| API-cttee-r01-D04 | `/health`,`/health/db`,`/health/db/grants` (양 API) | 2 엔벨로프 | 하 | 인프라 헬스 EP가 공통 `{ok:true,data}` 봉투가 아닌 raw `{ok,env,time}` 등 반환. 문서상 "인프라 레벨(스코핑 밖)"로 명시된 의도적 예외이나 봉투 규약과 형식 상이. | solsol-api index.ts:95-158; brand-api index.ts:80-157; endpoints.ts:50-95 | 현행 유지 가능(설계 의도). 소비자에 "헬스는 비봉투" 명시 유지. | 수용(설계) |
| API-cttee-r01-D05 | solsol-brand 프론트 7 composable | 4 프론트↔EP | 하 | account/billing/inquiries/myProduct/sites/auth/legalDocs 가 mock 폴백 전용(실 brand-api EP 미배선). 대응 EP(`/api/account`,`/api/billing/cards`,`/api/contact`,`/api/sites`,`/api/subscriptions`,`/api/agreements`,`/api/auth`)는 **존재**(부재 아님) → 계약 불일치 아닌 **배선 커버리지 갭**. | brand-api routes(account/billing/contact/sites/subscriptions/agreement/auth); brand front composables (news·plans만 실호출) | brand 프론트 실연동 단계에서 순차 배선(보안 게이트 후). 계약 자체는 정합. | 미해결(계약 정합) |
| API-cttee-r01-D06 | `/api/orders/:id/cancel`, `/api/subscriptions/:id` (프론트 표기) | 3 표기정합 | 하 | 프론트가 path param을 `:id`로, 카탈로그/라우트는 `:orderId`로 명명. 해석되는 실 URL은 동일(형태 일치) — 순수 표기 드리프트. | useOrder.ts:536-538 vs endpoints.ts:575 `/api/orders/:orderId/cancel` | 무영향(cosmetic). 필요 시 명명 통일. | 수용 |

---

## 트랙 판정

- **심각도별**: 상 **1** · 중 0 · 하 5 (그중 D04·D06 수용, D05 계약 정합).
- **Blocker(상)**: **1건 — D01 `/api/my-orders`**. 프론트 주문내역 실데이터 행복경로가 실 라우트 부재로 차단(현재 mock 폴백으로 은폐).
- **판정: NO-GO(조건부)** — FR01 주문/결제내역 실연동 게이트는 **D01 해소 전 통과 불가**. 그 외 FR01 사용자단↔solsol-api 계약 정합, 양 API 엔벨로프·에러봉투·staging-gate·웹훅 서명 규약은 **일관(양호)**. brand 측은 계약 자체 정합, 프론트 실배선만 진행 필요(D05).
- **권고 순서**: ① D01 프론트→`/api/orders` 정렬(또는 API 별칭) → 재검증 → ② D03 카탈로그 adminMe 등재 → ③ D02 스테일 주석 정리.

> 스코프 준수: 정본·코드·`_ledger.md` 무수정. 본 결함표 파일만 신규 기록. 배포·커밋 없음.
