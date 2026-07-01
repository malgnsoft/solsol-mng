# 실 API 결선 검증 — Phase B(쓰기) + Phase C(결제·구독 승인대기) E2E · Round 1

- 일자: 2026-07-01 (KST)
- 검증자: QA
- 대상: `solsol-api`(Hono/Hyperdrive, `wrangler dev --remote` :8787, `APP_ENV=local`) ↔ `solsol` 프론트 매퍼
- 방식: API 직접 curl(dev 테넌트, 비파괴 write) + 프론트 매퍼 소스 대조(런타임 shape 정합)
- 인증: mock 콜백→signup 발급 access(Bearer). 테스트 사용자 `qa2@solsol.dev` (id 2005), 테넌트 `dev`(schema `solsol_lms`)
- 코드 수정: **없음**(무편집). 백엔드 종료·`.dev.vars`(`APP_ENV=local`) 원복 확인. 프론트(:3000)는 미기동(API-direct 검증).

## 판정: **GO (조건부)**
- 쓰기 영속성·pending 승인대기 분기·PG 미해제·폴백 비활성 — **핵심 게이트 전부 통과**.
- blocker(상) 0건. **major(중) 3건**은 모두 "read 매퍼 필드명 불일치"로 배포 전 정정 권고(작성·저장은 정상, 화면 표시만 깨짐).

---

## Phase B — 쓰기 6항목

| # | 항목 | 결과 | 근거 |
|---|------|------|------|
| B1 | 찜 wishlist | **PASS** | `POST /api/products/101/wishlist` 200 → `GET /api/wishlist` 에 id 101 반영. `DELETE` → `{isWished:false}`, 재조회 `[]`. (최초 재조회 잔존은 Hyperdrive replica lag, 재확인 시 정상) |
| B2 | 문의 inquiries | **BLOCKED(데이터)** | `POST /api/inquiries` (정상 스키마 `{type,title,contentHtml}`) → **HTTP 404 NOT_FOUND**. 원인: `dev` 테넌트에 `board_type='qna'` 게시판 **미시드** → `inquiry.ts:228 if(boardIds.length===0) throw notFound()`. 쓰기 코드 결함 아님, **시드 누락**. 답글(`/:id/replies`)은 문의 생성 불가로 미검증 |
| B3 | 게시판 posts | **PASS** | `POST /api/boards/1/posts {title,contentHtml}` → 201 `{id:525}`, 상세 반영. `POST /api/posts/525/comments` → 201 `{id:1}`, 댓글목록 반영. ※매핑 결함 D-1 참조 |
| B4 | 후기 reviews | **PASS(게이트 미적용)** | `POST /api/products/101/reviews {rating,content}` → 201 `{id:1}`, 상세 `reviews[]` 반영. dev 테넌트는 **수강권 게이트 미적용**(403 아님, 누구나 작성 가능) — 기록. ※매핑 결함 D-2 참조 |
| B5 | 쿠폰 coupons | **PASS** | `POST /api/coupons/601/claim` → 201, 재요청 409 `COUPON_MULTIPLE`(멱등 가드). `GET /api/coupons/mine.available` 에 반영(초기 지연 후 수렴), `/usable` 즉시 반영. `issueId:0` echo는 Hyperdrive insertId 미반환(표시용, 무해) |
| B6 | 진도 progress | **PASS(도달 분기)** | `POST /api/enrollments/999999/progress` → **403 NOT_ENROLLED**(소유·수강권 게이트 정상). 200/`SEQUENTIAL_LOCK` 분기는 실 수강권 필요 → Phase C가 pending-only(주문 미완결)라 **staging에서 도달 불가**(정상 제약) |

## Phase C — 결제·구독 승인대기 4항목

| # | 항목 | 결과 | 근거 |
|---|------|------|------|
| C7 | 주문 orders | **PASS** | `POST /api/orders {product_ids:[101],agreements}` → 201 `{success:false, pending:true, orderNo:"20260701-JRNVL957", amount:79200, ...}`. staging-gate 정확. 프론트 `complete.vue:20` `pending===true && success!==true` → 승인대기 경로 정합. 실 PG 승인·실결제 **미발생** |
| C8 | 카드 cards | **PASS** | `GET /api/billing/cards` → `{items:[]}` shape 정합. `usePayment.ts` 매퍼 `cardCompany/cardLast4/cardBrand/maskedNumber` + `maskCardNumber(last4)` 뒤4자리 마스킹 로직 존재. 카드 없음(등록엔 실 PG 빌링키 필요=PG 미해제 일관) → last4 실데이터 미검증 |
| C9 | 구독 subscriptions | **PASS** | `POST /api/subscriptions {plan:241,product_id:107}` → 201 `{id:0, subState:"pending"}`. `/current`·`/mine.membership` 반영(subState=pending, unitPrice 9900, paidAt 없음). `DELETE /api/subscriptions/1` → `cancelScheduled:true, canceledAt` 설정, `nextBillingAt:null`. 매퍼(`useSubscription.ts:343,399`) 정합 |
| C10 | 내주문 my-orders | **PASS(데이터경미)** | `GET /api/orders` → `{items,summary,total}`. `summary{paidCount:0,paidTotal:0,canceledCount:0}` (실결제 0 확인). `orderState:"pending", paidAt:null`(paid 누수 없음). `useOrder.ts:476-481` summary 매핑 정합. ※경미 결함 D-3 참조 |

---

## 확인 포인트 결과
- **영속성(생성→재조회)**: B1/B3/B4/B5/C7/C9/C10 모두 재조회 반영 확인(단, Hyperdrive `--remote` 는 write→read replica lag ~수초 존재, 재확인 시 수렴).
- **필드 매핑 런타임 정합**: orders·subscriptions·wishlist·cards 정합. **board posts/comments·reviews 불일치(D-1/D-2)**.
- **승인대기(pending) 분기**: orders·subscriptions 모두 `pending:true`/`subState:pending`, 성공 단정 없음. 프론트 `complete.vue` isPending 경로 정합.
- **PG 미해제(실결제 0)**: `orders.ts`/`subscriptions.ts` 에 실 PG 승인 호출(`await toss/approve/confirm`) **0건**. summary.paidCount=0, orderState=pending, paidAt=null.
- **폴백 비활성**: `useApi.ts:65` `fallbackEnabled = (apiBase==='')` — `NUXT_PUBLIC_API_BASE` 설정 시 mock 폴백 OFF, `ok:false`→`ApiError` throw(useApi.ts:155). 정합.
- **마스킹**: `usePayment.ts:212 maskCardNumber` 뒤4자리 유지·앞자리 마스킹 로직 존재(카드 부재로 실데이터 미검증).

---

## 결함표

| ID | 심각도 | 항목 | 현상 | 근거(파일:라인) | 제안 |
|----|--------|------|------|------------------|------|
| D-1 | **중(major)** | B3 게시판 매퍼 | API 게시글/댓글 응답 키와 프론트 매퍼 기대 키 불일치 → 작성자·조회수·상단고정 표시 깨짐. API list/detail: `writer`/`hitCount`/`isNotice`, comment: `writer`. 매퍼 기대: `authorNickname`/`viewCount`/`isPinned`, comment `authorNickname`. 또한 `excerpt·thumbnailUrl·authorType·isEdited·isMine` API 부재 | API `community.ts` 응답 vs `solsol/app/composables/useBoard.ts:476-522`(`mapPostSummary`/`mapPostDetailRow`/`mapCommentRow`) | 매퍼를 API 키(`writer→authorNickname`, `hitCount→viewCount`, `isNotice→isPinned`)로 정정하거나 API 응답 키 정렬. **작성·저장은 정상(201)**, 표시만 문제 |
| D-2 | **중(major)** | B4 후기 매퍼 | 상세 `reviews[]` 및 생성응답이 `nickname`/`userId` 반환, 매퍼는 `authorNickname`/`authorId` 기대 → 모든 후기 작성자가 기본값 **'나'** 로 표시, `authorId=0`. `replies·isEdited·isMine·authorType` API 부재 | API 상세 reviews vs `solsol/app/composables/useProducts.ts:956`(`mapReview`), 생성응답 매핑 `useProducts.ts:1106` | 매퍼 `nickname→authorNickname`, `userId→authorId` 정정 또는 API 키 정렬 |
| D-3 | 경미(minor) | C10 내주문 항목 | my-orders list 행에서 `productTitle:""·itemCount:0·items:[]`(주문생성 응답엔 title 있음) → "내 주문" 카드 상품명 공란 | `GET /api/orders` 항목 응답(`orders.ts:89~` list 핸들러 order_item 미조인) | pending 주문에도 상품명/항목 join 채우기 |
| D-4 | 경미(minor) | B2 시드 | `dev` 테넌트에 `board_type='qna'` 게시판 미시드 → 1:1 문의 생성 404 | `inquiry.ts:228` `qnaBoardIds` 빈배열→notFound | dev 테넌트 시드에 qna 게시판 추가(코드 아닌 데이터) |

## 우선 보완(권고 순)
1. **D-1 / D-2** (중) — 게시판·후기 read 매퍼 필드명 정정(작성자·조회수 표시 정합). 저장은 정상이므로 프론트 매퍼 소폭 수정.
2. **D-4** (경) — dev 테넌트 qna 게시판 시드 추가 후 B2(문의 생성·답글) 재검증.
3. **D-3** (경) — my-orders 항목에 상품명/항목 join.

## 미도달(staging 제약 — 결함 아님)
- B6 진도 200/`SEQUENTIAL_LOCK` 정상흐름: 실 수강권 필요 → Phase C가 pending-only(주문 미완결·enrollment 미생성)라 도달 불가. PG 해제·주문 완결 단계에서 재검증 필요.
- C8 카드 뒤4자리 실데이터 마스킹: 실 PG 빌링키 필요(PG 미해제) → 로직 정합만 확인.

## 담당 위임
- D-1/D-2/D-3: 프론트/API 매퍼·응답 정합 → frontend/api 개발 담당.
- D-4: dev 테넌트 시드 → dba/api 담당(자기 env로 직접).
