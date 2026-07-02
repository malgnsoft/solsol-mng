# 06. API 계약서 (v0.2 — 라운드2 결정 반영)

> ⚠️ **정본 격하 고지 (2026-07-01, 오너 승인)** — 본 문서 **§0 스택 전제·§1 "D1 테이블 관점" 엔티티·OQ-D1·KV 세션**은
> **무효**다. 실백엔드는 **Aurora MySQL 8.0 schema-per-tenant + Hyperdrive**이며(테넌트 스키마엔 `site_id` 컬럼 없음),
> 세션은 `TB_SESSION`(DB), 영상은 Wecandeo VOD(`wecandeo_video_key`)다.
> **데이터(물리) 정본 = 구현 DDL(`master.sql`·`tenant_template.sql`) → `ERD.md`(파생 뷰).** 06은 이제
> **엔드포인트 계약(경로·요청/응답 봉투·에러코드·정책ID 추적) 참고 문서**로만 쓴다 — 스키마·타입·제약·격리 판정에 06을 권위로 삼지 않는다.
> 근거: [../DEV_VALIDATION_PROCESS.md](../DEV_VALIDATION_PROCESS.md) §0, [메모리: solsol-backend-aurora-not-d1].


| 항목 | 내용 |
|------|------|
| 문서 ID | 06_API계약 |
| 작성자 | 강테크 (테크리드, proj-techlead) |
| 지시자 | CL총괄 (전담 PO, proj-solsol-po) |
| 작성일 | 2026-06-25 |
| 버전 | v0.2 (라운드2 결정 반영) |
| 입력 문서 | `04_정책요약.md`(96정책·정책ID AUTH/PAY/LRN/MKT/CMP/EXC/SUP) · `05_정책설계서.md`(C-1·M-1·M-2·C-2·C-3·C-4 확정) · `billing.md`(2026-06-25 개정본: §1.2 즉시결제) · `_운영/03_정책결정제안_라운드2.md`(2026-06-25 DJ 컨펌: M-3 종량제·M-4~M-10·C-5·C-6·R-1) |
| 후속 작업자 | 오백개 (백엔드, proj-backend) — DAO/라우터 구현, D1 상세 스키마 |
| 상태 | 착수본 — 핵심 도메인(AUTH/PAY/LRN/MKT/SUP) 대표 엔드포인트 정의. 미정의·미결은 §9 Open Questions로 분리 / **v0.2: 라운드2 결정 반영(M-3 종량제·R-1 알림 단일도메인·C-6 마스킹·M-8 PG 골격)** |

> 본 문서는 [DOCS-산출물표준.md §06]·[STACK-기술표준.md]를 따른다. **무엇·왜는 04/05가 확정**했고, 본 문서는 "어떻게(엔티티·엔드포인트·계약)"를 고정한다.
> ⚠️ **v0.1 착수본**: 전수 엔드포인트가 아니다. 핵심 도메인을 대표 위주로 정의하고, 미정의 영역(전체 엔드포인트·D1 상세 스키마·크레딧 단가·웹훅 등)은 **§9 Open Questions / 후속(v0.2+)**에 정직하게 분리했다. 추정 단가·가짜 완성은 넣지 않는다.

---

## 0. 스택 전제 (STACK-기술표준 §2)

- **런타임**: Hono on Cloudflare Workers (또는 Pages Functions `functions/api/*`).
- **데이터**: **D1**(SQLite, 관계형 본체=SoT) + **R2**(동영상·디지털파일·증빙 등 용량 큰 산출물, egress 무료) + **KV**(세션·디바이스토큰·집계 캐시·설정). 파일 실체는 R2, D1에는 R2 키만 저장.
- **인증**: JWT, 요청 시 `Authorization: Bearer <token>`. 보호 엔드포인트는 `authMiddleware` 통과 후 `roleGuard`(M-2 RBAC) 적용.
- **멀티테넌트**: Front 회원은 커스터머(판매자) **사이트별 개별 계정**(AUTH-03). 모든 Front 도메인 쿼리는 `site_id` 스코프 강제. JWT 클레임에 `site_id` 포함.
- **응답 헬퍼**(utils/response.js): `ok` / `created` / `notFound`(404) / `badRequest`(400) / `unauthorized`(401) / `forbidden`(403) / `conflict`(409) / `serverError`(500).
- **공통 응답 봉투**:
  ```
  성공: { "ok": true, "data": <payload>, "meta": { ... } }
  실패: { "ok": false, "error": { "code": "STRING_CODE", "message": "사용자 문구", "field": "선택" } }
  ```
- **금액**: 모두 정수 KRW(원). 응답은 원 단위 정수, 화면 표기(천단위 콤마·VAT)는 프론트 책임.

### 응답 마스킹 규칙 (C-6 확정 · 2026-06-25 컨펌 · CMP-01/02 정합)
> 표준 §7은 "항상 마스킹"이 원칙이나, **본인이 자기 정보를 조회하는 화면**은 보호 대상이 본인이므로 본인 식별정보를 비마스킹한다(C-6 보수안). 단 금융정보·인증정보는 본인 화면에서도 보호한다.

| 응답 컨텍스트 | 이름·이메일·휴대폰·닉네임 | 카드번호·계좌번호 | 비밀번호·인증코드 |
|---------------|:---:|:---:|:---:|
| **본인 자기조회** (`GET /api/me`, 본인 문의/수료증/계정관리 등) | **비마스킹**(전체 표기) | **부분마스킹 유지** | **응답 미포함**(예외 없음) |
| **타인·제3자 노출** (운영자가 타 회원 조회 등) | 마스킹(표준 §7) | 부분마스킹 | 응답 미포함 |

- 카드번호: 본인 화면에서도 뒤 4자리만 `**** **** **** 1234`(CMP-01). 계좌번호: 부분마스킹 유지(표준 §7).
- 비밀번호·인증코드(이메일코드/OTP 등)는 **어떤 응답에도 절대 포함하지 않는다**(본인 화면 포함, 예외 없음).
- 적용 분기 기준: JWT 주체(`member_id`/`admin_user_id`)가 **조회 대상 리소스 소유자와 일치**하면 본인 자기조회로 판정 → 식별정보 비마스킹. 불일치 시 타인 조회 규칙 적용.

### 정책ID 추적키
각 도메인 헤더와 주요 엔드포인트에 관련 정책ID(`AUTH/PAY/LRN/MKT/CMP/EXC/SUP`)를 표기해 04/05와 1:1 추적한다(누락 추적 가능).

---

## 1. 엔티티 데이터 모델 요약 (D1 테이블 관점 — 필드 나열 수준)

> v0.1은 필드 나열 수준(타입·제약 상세·인덱스·FK는 **오백개가 D1 마이그레이션에서 확정** → §9 OQ-D1). `*`=필수, `?`=nullable/optional.

### 1.1 Member (회원 — Front 수강생) · AUTH-01/03/15, C-1
`id*` · `site_id*`(멀티테넌트 분리) · `provider*`(google/kakao/naver/apple/facebook) · `provider_uid*` · `email?` · `nickname*`(min2 max15·중복체크·금칙어 C-1) · `name?`(NICE 본인인증 시) · `phone?`(NICE) · `is_primary_account`(최초 연동 SNS=대표) · `status*`(active/suspended/withdrawn AUTH-14) · `marketing_agreed`(CMP-03) · `created_at` · `withdrawn_at?`
- 유니크: `(site_id, provider, provider_uid)`, `(site_id, nickname)`.

### 1.2 AdminUser (강사/관리자 — Brand·Admin) · AUTH-01/11/12, M-2
`id*` · `site_id*` · `email*`(=로그인 ID, 변경불가 AUTH-09) · `password_hash*`(8~16자 3종 C-3) · `name*` · `role*`(owner/instructor/sub_instructor) · `status*`(active/suspended) · `two_factor_email`(AUTH-09 토글) · `invited_by?` · `created_at`
- **권한**: 별도 `AdminPermission`로 분리(메뉴 화이트리스트 + 데이터스코프 M-2).

### 1.3 AdminPermission (RBAC) · M-2, AUTH-12
`id*` · `admin_user_id*` · `menu_key*`(LNB 1depth 11종 화이트리스트: dashboard/users/products/contents/sales/operation/marketing/site_design/stats/settlement/settings) · `allowed*`(bool) · `data_scope*`(all / own = 본인 담당 상품·강좌·수강생·정산)
- P-AD-19 [설정 완료] = 해당 admin_user의 행 일괄 교체(기존 무시).

### 1.4 Product (상품) · LRN-01/02, PAY-18
`id*` · `site_id*` · `owner_admin_id*`(담당 강사·데이터스코프 기준) · `type*`(general/live/video_call/digital/package/membership/community — 7종) · `title*` · `category_id?`(최대2단계, 1상품1카테고리) · `price*`(원) · `visibility*`(public/partial/private·기본 private) · `sale_status*`(on_sale/sale_closed) · `created_at`
- 유형별 부속 테이블(라이브 일시·디지털 다운로드 제한·패키지 구성·멤버십 등급·커뮤니티)은 §9 OQ-LRN(v0.2).

### 1.5 Content (콘텐츠 라이브러리) · LRN-04/07
`id*` · `site_id*` · `source_type*`(upload/youtube) · `r2_key?`(업로드 실체=R2) · `youtube_url?` · `upload_status*`(pending/processing/done/failed) · `duration_sec?` · `size_bytes?`(용량한도 집계) · `created_at`

### 1.6 Order (주문) · PAY-07/13/18
`id*` · `site_id*` · `member_id*` · `status*`(상태머신 PAY-07: pending/paying/paid/failed/grace/unpaid) · `product_ids*`(복수 동시결제) · `subtotal*` · `shop_discount?` · `coupon_id?`(1개 only PAY-18) · `coupon_discount?` · `vat*` · `total*` · `paid_at?` · `created_at`

### 1.7 Subscription (플랜 구독 — Brand 판매자) · PAY-01/05/07/08/17
`id*` · `site_id*` · `plan*`(free/basic/growth/advanced/enterprise) · `billing_cycle*`(monthly/yearly·연30%할인 PAY-04) · `status*`(active/grace/expired·이용상품 PAY-17) · `billing_key?`(토스 빌링키) · `current_period_start*` · `current_period_end*` · `next_billing_at?` · `cancel_scheduled`(기간종료후 해지 PAY-10) · `created_at`
- **무료체험(trial) 상태 없음** — billing.md §1.2 개정(M-1) 반영: 가입 시 즉시 결제.

### 1.8 Invoice (청구서) · PAY-07/08, billing.md §4
`id*` · `subscription_id*` · `status*`(pending/paid/failed/grace) · `amount*` · `unpaid_carryover?`(미납 합산 billing §4.2) · `vat*` · `retry_count?`(0~6 billing §9.1) · `period_start*` · `period_end*` · `issued_at*` · `paid_at?`

### 1.9 Settlement (정산) · PAY-20/21
13컬럼: `id*` · `site_id*` · `instructor_admin_id?`(본인 스코프 M-2) · `period_month*`(YYYY-MM·말일 집계) · `pay_date*`(익월10일) · `gross_amount*`(결제금액) · `vat*`(부가세10%) · `sales_fee*`(판매수수료11%) · `pg_fee*`(PG4%) · `canceled_amount?`(결제후 취소액 차감) · `net_amount*`(정산금액=gross−vat−sales_fee−pg_fee−canceled) · `status*`(pending/approved/paid) · `approved_at?`
- 정산정보 제출·승인 게이트(PAY-20): `SettlementProfile`(유형 개인사업자/법인/개인·계좌실명·통장사본 R2키) — 상세 §9 OQ-PAY.

### 1.10 Coupon (쿠폰) · MKT-14, C-4
`id*` · `site_id*` · `discount_type*`(**AMOUNT only** C-4 — `RATE`는 enum에 자리 확보하되 v0.1 발행·적용 차단) · `discount_amount*`(원) · `min_order_amount?` · `status*`(active/paused/revoked MKT-14) · `target*`(all/recipient_group) · `issued_qty*`(등록인원보다 적게 불가) · `created_at`

### 1.11 Credit (크레딧) · PAY-19, MKT-06, M-3
잔액: `site_id*` · `balance*`(원 환산 아닌 크레딧 단위) · 충전이력 `CreditCharge`(충전 10,000원 단위·VAT별도·보너스·`expires_at`=충전+1년 자동소멸 PAY-19) · 차감이력 = **크레딧 차감 원장(ledger)** `CreditLedger`
- **CreditLedger** 필드: `id*` · `site_id*` · `direction*`(debit 차감 / refund 환불) · `reason*`(campaign_send/ai_tutor/ai_translate/ai_caption) · `unit_count*`(발송 건수·분량 등 과금 단위 수) · `unit_price?`(과금 단위당 크레딧 — config 참조, **값은 Open**) · `amount*`(차감/환불 크레딧 총량 = unit_count × unit_price) · `idempotency_key*`(**중복 차감 방지 유니크**) · `status*`(pending=가차감 / settled=최종차감 / refunded=익일환불 MKT-06) · `ref_type?`(campaign/ai_job) · `ref_id?` · `created_at`
- 유니크: `(site_id, idempotency_key)` — 동일 키 재요청은 기존 결과 반환(멱등).
- **과금 모델 = 종량제(건당 차감) 확정(M-3, 2026-06-25 컨펌)**. 단 **채널별/AI기능별 실제 단가(크레딧)·크레딧↔원 환산율은 여전히 Open**(입력데이터 5종 수집 후 확정) → `unit_price`는 **config(Open)** 참조로만 표기, 본 문서에 숫자 미기재. → §8·§9 OQ-MKT.

### 1.12 DeviceToken (푸시 — KV) · STACK §3
KV 저장(D1 아님): `key = device:{member_id}:{device_id}` · `value = { token, platform(ios/android), updated_at }`. 등록 `POST /api/devices`.

---

## 2. 인증 / 회원 (AUTH)

> 관련 정책: AUTH-01~15, C-1(닉네임 2~15), C-2(TTL), C-3(비번 8~16 3종), M-2(RBAC). **영역별 인증 모델 상이**: Front=소셜 only, Admin/Brand=이메일+PW.

### 2.1 소셜 로그인 콜백 (Front) · AUTH-01/02/08
`POST /api/auth/social/callback`
```
Req:  { provider, code, site_id, redirect_uri }
Res:  { ok, data: { token, member: {id,nickname,...}, isNew: bool } }
      isNew=true → 가입 플로우(약관동의 게이트 AUTH-04)로 분기
```
- 401: provider 인증 실패. 멤버십 연동 회원은 google 강제(AUTH-02, 프론트 안내).

### 2.2 이메일+PW 로그인 (Admin/Brand) · AUTH-08
`POST /api/auth/login`
```
Req:  { email, password, role(instructor|owner), site_id }   // Admin 라디오 default=instructor
Res:  { ok, data: { token, user:{id,role,...} } }
에러: 401 unauthorized — code 4종: UNREGISTERED / MISMATCH / ROLE_MISMATCH / SUSPENDED (AUTH-08)
```

### 2.3 회원가입 검증 (닉네임·비번) · AUTH-04, C-1, C-3
`POST /api/auth/signup`
```
Req(Front):  { site_id, provider, provider_uid, nickname, agreements:[{key,agreed}] }
Req(Admin):  { site_id, email, password, name, agreements:[...] }
검증: nickname min2 max15·금칙어·중복(C-1) / password 영문+숫자+특수 3종 8~16(C-3) / 필수약관 미동의→차단(AUTH-04)
Res:  201 { ok, data:{ member|user, token } }
에러: 400 badRequest — field별 code(NICKNAME_LENGTH / NICKNAME_DUP / NICKNAME_FORBIDDEN / PASSWORD_RULE / TERMS_REQUIRED)
```

### 2.4 이메일 인증코드 발급/검증 · AUTH-05, C-2
`POST /api/auth/email-code/issue` → `{ purpose: signup|email_change|reset, email }` · 코드 KV 저장 + TTL
`POST /api/auth/email-code/verify` → `{ email, code }`
- **TTL 상수(C-2)**: 가입/이메일변경 코드 **600s(10분)** · 비밀번호 재설정 **1800s(30분)** · 초대 토큰 **172800s(48시간)**.
- 재설정 메일 연속 10회 발송 시 "10분 후 재시도" 제한(AUTH-07) → 429 또는 400(RATE_LIMIT).

### 2.5 비밀번호 재설정 · AUTH-07, C-2
`POST /api/auth/password/reset-request` → 메일 링크/코드(TTL 1800s) · `POST /api/auth/password/reset` → `{ token, newPassword }`(C-3 규칙 재검증).

### 2.6 프로필 조회/수정 · AUTH-15, C-1
`GET /api/me` · `PATCH /api/me` → `{ nickname? }`(중복체크·min2max15) / 휴대폰 본인인증 NICE 연동(§7). 닉네임 변경 시 409 conflict(NICKNAME_DUP).

### 2.7 RBAC 권한 설정 (관리자→강사/서브강사) · M-2, AUTH-12
`GET /api/admin/users/:id/permissions` · `PUT /api/admin/users/:id/permissions`
```
Req:  { permissions: [ { menu_key, allowed, data_scope } ] }  // P-AD-19 일괄 교체(기존 무시)
```
- **roleGuard 규칙(M-2)**: 아래 §2.8.

### 2.8 RBAC 인가 규칙 (roleGuard) · M-2, EXC-06
`authMiddleware`(JWT 검증) → `roleGuard(menu_key)`(메뉴 화이트리스트 + 데이터스코프) 2단.
| 역할 | 허용(default) | 차단(403) |
|------|---------------|-----------|
| owner(관리자) | 전 메뉴·전사 데이터 | — |
| instructor(강사) | dashboard/products/contents/stats/settlement/sales **본인 스코프(own)** | marketing · site_design · users(타) · settlement(전사) → **403 forbidden** |
| sub_instructor(서브강사) | contents/products(본인) | 강사 차단분 + operation·settlement·users → 403 |
- **메뉴권한(보이는가)** 과 **데이터스코프(무엇이 보이는가)** 분리. 강사가 권한 가진 메뉴라도 데이터는 `own`으로 필터.
- **직접 URL 접근 차단(EXC-06)**: 권한 없는 menu_key 호출 시 403(미들웨어 레벨, 라우트 진입 전).

---

## 3. 콘텐츠 / 학습 (LRN)

> 관련 정책: LRN-01~23. v0.1은 목록/상세·수강/진도·라이브 입장·수료 대표만. 유형별 상세(디지털 다운로드 차감·패키지·멤버십 등급)는 §9 OQ-LRN.

### 3.1 상품 목록/상세 · LRN-01/21
`GET /api/products?site_id&category&type&q&sort` (q는 2자↑ 부분일치 LRN-21·2자미만 400) · `GET /api/products/:id`

### 3.2 수강 / 진도 · LRN-08/09
`GET /api/me/enrollments` · `POST /api/enrollments/:productId/progress` → `{ chapterId, position_sec, completed }`
- 순차 수강(LRN-08): 이전 차시 미완료 차시 진행 요청 → 403(SEQUENTIAL_LOCK). 수료 진도율 기본 80%(LRN-09).

### 3.3 라이브 입장 · LRN-10/11
`GET /api/live/:productId/enter`
- 입장버튼 활성 시각: 시작 10~60분 전(기본 10분, LRN-11). 활성 전 요청 → 403(LIVE_NOT_OPEN). 입장 즉시 자동 수료(LRN-10).

### 3.4 수료 / 수료증 · LRN-19
`GET /api/me/certificates` · `GET /api/me/certificates/:id`(이름/상품명/수료번호/교육시간/시작·수료일/로고 + PDF). 미수료분 발급 불가 → 404.

---

## 4. 결제 / 구독 (PAY)

> 관련 정책: PAY-01~21. **billing.md(2026-06-25 개정본)·05와 1:1 정합**. 무료체험 없음(M-1), 재시도 3일6회, 유예27일, 환불 7일전액/일할0.7. 외부 PG=토스(§7).

### 4.1 카드 등록 (빌링키) · PAY-02, billing §5.1
`POST /api/billing/card` → 토스 빌링키 발급창 연동 결과 저장 `{ billingKey, last4, cardType }`. 신용/체크만(계좌이체 미지원·PAY-02). 결제일 당일 변경 불가(billing §5.3) → 409.

### 4.2 구독 시작 / 플랜 결제 (즉시결제) · PAY-01/04, M-1
`POST /api/subscriptions` → `{ plan, billing_cycle }`
- **무료체험 단계 없음** — 카드 등록 후 **즉시 정액 결제**(billing §1.2 개정본). 연간=30% 할인 일괄(PAY-04).
- Res 201 `{ subscription, invoice }`.

### 4.3 LMS 상품 주문/결제 (Front) · PAY-18, MKT-15
`POST /api/orders` → `{ product_ids:[...], coupon_id? }`
- 총결제 = 정가합 − 상점할인 − 쿠폰할인(AMOUNT 1개 only PAY-18/C-4) + VAT. 쿠폰 2개 이상 → 400(COUPON_MULTIPLE). RATE 쿠폰 → 400(COUPON_TYPE_UNSUPPORTED, C-4).
- 결제는 토스 본인확인 NICE 최초 1회(PAY-02·§7).

### 4.4 구독 조회 / 해지 · PAY-10
`GET /api/subscriptions/current` · `POST /api/subscriptions/:id/cancel`
```
Req:  { mode: "end_of_period" | "immediate_refund" }
- end_of_period: 기간 만료까지 이용·이후 카드 자동삭제(PAY-10)
- immediate_refund: 1:1 문의로 수동 접수 라우팅(SUP) — 자동 환불 금지(CMP-06 비가역 게이트). Res에 inquiry 생성 안내.
```

### 4.5 결제 실패 재시도 / 유예 / 즉시결제 · PAY-08, billing §9
- 재시도(서버 배치/큐): 3일간 하루2회 총6회(billing §9.1). 재시도 중 상태 `사용중`·청구서 `결제실패`.
- 6회 실패 → `결제유예`(상태 중지·Admin 이용중지/Front 이용가능). 유예 27일.
- `POST /api/invoices/:id/pay-now` → 유예 중 즉시결제(billing §5.4). 결제 시 구독기간 재시작.
- 유예 27일 미결제 → `만료`/`미결제`(billing §9.3).
- ⚠️ **빌링키·환불 골격은 확정(M-8, 2026-06-25 컨펌)**. 단 아래 4종은 **OQ-PAY로 잔존(해소 아님)** → §9:
  ① 토스 **결제결과 웹훅 수신**(`POST /api/billing/webhook/toss`) ② 웹훅 **서명검증**(시크릿=`wrangler secret`, 코드/로그 노출 금지 STACK §4) ③ 정기결제 **재시도 배치**(3일 6회 billing §9) 자동화 = Cloudflare Cron/Queues ④ **멱등 처리**(웹훅 중복 수신 대비) + 결제 상태머신(PAY-07) 동기화 · 정산 자동집계.
  > 실결제·실환불 자동화는 **비가역** → staging 선검증 + 운영자 확인 전제(STACK §4·PROCESS 자동진행 주의). 환불 자동화 불가(CMP-06 게이트, §4.6과 정합).

### 4.6 환불 · PAY-11, billing §11
`POST /api/orders/:id/refund-request`(셀프) / 1:1문의 접수(PAY-12)
- 7일 이내+사용이력 없음 → 전액환불(셀프 허용). 그 외 → 부분환불 `[결제금액 − (월제공금액÷30×사용일수)] × 0.7`(위약금30% PAY-11). 연간은 할인 전(정상금액) 기준 일할.
- **자동 환불 불가** — 부분환불·즉시취소는 관리자 확인 후 진행(CMP-06). 디지털 상품 환불 불가(PAY-12) → 400.

### 4.7 플랜 변경 · PAY-05/06, billing §8
`PATCH /api/subscriptions/:id/plan` → `{ plan?, billing_cycle? }`
- 즉시 적용·미사용 일할 차액 제외(PAY-05). 월→연 즉시, 연→월 즉시 변경 불가(기간 종료 후, PAY-06) → 409(CYCLE_CHANGE_BLOCKED).

### 4.8 정산 조회 (강사 본인) · PAY-21, M-2
`GET /api/settlements?period_month` (instructor=본인 스코프 강제 M-2 — 타 강사 조회 시 403). 집계: 말일/익월10일, 부가세10%·판매수수료11%·PG4% 차감(§1.9).

---

## 5. 마케팅 / 메시지 / 크레딧 (MKT)

> 관련 정책: MKT-01~16. 캠페인 발송(크레딧 차감)·수신자그룹·쿠폰. **차감 단가 미결 → §9 OQ-MKT**.

### 5.1 캠페인 발송 · MKT-01/02/06
`POST /api/campaigns` → `{ name, channels:[email|sms|alimtalk], recipient_group_id, schedule:{type:reserve|condition, at?, condition?} }`
- 예약 최소 10분 후(MKT-02). 발송 시 예상비용 **가차감(pending)** → 성공건만 **최종차감(settled)**·실패건 **익일환불(refunded)**(MKT-06). 크레딧 부족 → 402/400(CREDIT_INSUFFICIENT).
- **과금 모델 = 종량제(건당 차감) 확정(M-3)**. 채널별 차감 **단가(크레딧)는 여전히 Open** → §8·§9 OQ-MKT. 차감은 §5.4 크레딧 원장 엔드포인트로 일원화(단가 상수 = config 참조, 값 Open).

### 5.4 크레딧 차감 원장 (debit / refund) · PAY-19, MKT-06, M-3
> 종량제(M-3 확정) 과금의 단일 차감 경로. 캠페인 발송·AI 기능 호출 등 **과금 이벤트당 1회 debit**. 멱등키로 중복 차감을 막고, 잔액 부족 시 차감을 거부한다. **단가 상수는 config(Open) 참조** — 본 계약에 숫자 미기재.

`POST /api/credits/debit` (authMiddleware + roleGuard)
```
Req:  { reason: "campaign_send|ai_tutor|ai_translate|ai_caption",
        unit_count,                 // 발송 건수·분량 등 과금 단위 수
        idempotency_key,            // 중복 차감 방지(필수)
        ref_type?, ref_id? }        // campaign/ai_job 추적
처리:  amount = unit_count × config.unit_price[reason]   // unit_price = Open(미기재)
       1) 멱등키 기존 존재 → 기존 ledger 결과 반환(재차감 없음)
       2) 잔액(balance) < amount → 402/400 CREDIT_INSUFFICIENT (차감 안 함)
       3) 가차감(status=pending) 기록 후 amount 만큼 balance 차감
Res:  201 { ok, data: { ledger_id, status:"pending", amount, balance_after } }
에러:  402/400 CREDIT_INSUFFICIENT(잔액 부족) · 400 BAD_REQUEST(unit_count<=0 / reason 미허용)
```
`POST /api/credits/ledger/:id/settle` → 성공 확정분 `pending → settled`(최종차감, balance 변동 없음).
`POST /api/credits/ledger/:id/refund` → 실패건 `pending|settled → refunded`(MKT-06 **익일 환불 배치**가 호출, amount 만큼 balance 복원, 멱등).
- **단가 상수(config)는 Open**: `config.unit_price[reason]` 값은 입력데이터 5종(채널 도매원가·AI 원가·경쟁사 시세·환산율·마진정책) 수집 후 운영자·오백개가 확정 → §9 OQ-MKT. **본 문서는 숫자를 채우지 않는다.**

### 5.2 수신자 그룹 · MKT-07
`GET/POST /api/recipient-groups` → 조건(동적)/명단(수동). 캠페인 사용 중 그룹 삭제 불가 → 409.

### 5.3 쿠폰 발행 · MKT-14, C-4
`POST /api/coupons` → `{ discount_type:"AMOUNT", discount_amount, min_order_amount?, target, issued_qty }`
- **discount_type=AMOUNT only(C-4)**. RATE 요청 → 400(COUPON_TYPE_UNSUPPORTED). 발행수량 < 등록인원 → 400. (RATE는 enum 자리 확보·v0.1 차단 — 정률 P1.)

---

## 5b. 알림 / 통지 (NOTI) — 단일 알림 도메인 · R-1, M-4, M-5

> R-1(2026-06-25 선합의 채택): 영역별로 흩어진 알림(Admin 알림센터·Front 자동메일·학습자 채널·푸시)을 **단일 알림 도메인 = 하나의 라우팅 테이블**로 본다. M-4 운영자 알림(N-01~N-10)·M-5 자동메일은 이 테이블의 **행(row)** 으로 편입된다. 정보통신망법(야간발송·광고표기·수신거부 MKT-10/CMP-03) 정합.

### 알림 라우팅 모델
```
이벤트(event) → 대상(audience: 역할 + 데이터스코프 M-2) → 채널(email|push|inapp|sms|alimtalk) → 수신설정
  · 필수(transactional): 결제·만료·중지·라이브 리마인드·강의 변동·중요 공지 → 사용자 OFF 불가(CMP-03)
  · 선택(marketing): 광고성 → 수신 동의 필수 + 광고표기 + 야간(21~08시) 차단 + 수신거부 링크(MKT-10)
```
- 알림 1건은 **라우팅 룰의 매칭 결과**다: 이벤트 발화 → 대상 산출(M-2 데이터스코프 필터) → 채널 결정 → 수신설정 검사 → 발송/적재.

### 5b.1 알림 트리거 발화 (내부 이벤트 훅) · M-4, M-2
> 외부 공개 엔드포인트가 아닌 **서버 내부 이벤트 훅**(결제·정산·문의·업로드 등 도메인 이벤트 → 알림 생성). 데이터스코프(M-2) 적용 — 강사 수신분은 본인 담당 상품/강좌 범위로 한정.
```
내부: emitNotification({ event, ref_type, ref_id, site_id })
  → 라우팅 테이블 조회 → audience 산출(roleGuard/data_scope) → 채널별 발송 + inapp 수신함 적재
```
- M-4 운영자 알림 카탈로그(이 테이블의 행, default 10종):

| 코드 | 이벤트(트리거) | 수신 대상(역할·스코프) | 기본 채널 | 분류 | 출처 |
|------|----------------|------------------------|-----------|------|------|
| N-01 | 학습자 가입 완료 | 관리자(+담당 강사 own) | inapp | 필수 | MKT-02 |
| N-02 | 주문/구독 결제 성공 | 관리자(+담당 강사 own) | inapp | 필수 | PAY-07 |
| N-03 | 정기결제 6회 실패→유예 | 관리자 | inapp | 필수 | PAY-08 |
| N-04 | 구독 만료 임박(잔여 7일) | 관리자 | inapp | 필수 | MKT-02 |
| N-05 | 환불/즉시취소 접수 | 관리자 | inapp | 필수 | PAY-12 |
| N-06 | 1:1 문의/신고 등록 | 관리자(+대상 강사 own) | inapp | 필수 | SUP-01/02 |
| N-07 | 정산 집계 완료·승인 대기 | 관리자 | inapp | 필수 | PAY-20/21 |
| N-08 | 크레딧 잔액 임계·발송 실패 | 관리자 | inapp | 필수 | MKT-06, PAY-19 |
| N-09 | 콘텐츠 인코딩/업로드 실패 | 관리자(+담당 강사 own) | inapp | 필수 | LRN-07 |
| N-10 | 용량·회원 한도 임박(80/90%) | 관리자 | inapp | 필수 | PAY-16 |

- M-5 Front 자동메일(필수 트랜잭션 메일, 사용자 OFF 불가)도 같은 테이블의 행:

| 코드 | 이벤트(트리거) | 대상 | 기본 채널 | 분류 | 출처 |
|------|----------------|------|-----------|------|------|
| N-F1 | 라이브/화상 시작 1시간 전 리마인드 | 해당 수강생 | email | 필수(트랜잭션) | LRN-11, M-5 |
| N-F2 | 강의 변동(일정 변경·취소) | 해당 수강생 | email | 필수(트랜잭션) | M-5 |

> N-F1/N-F2는 **거래/이용 필수 고지 → 정보통신망법상 수신거부 대상 아님**(CMP-03). 마케팅 수신설정과 무관하게 발송. 설정 UI 부활 없음.

### 5b.2 수신설정 조회 · CMP-03
`GET /api/me/notification-settings` (authMiddleware)
```
Res: { settings: [ { category, channel, required: bool, enabled: bool } ] }
     required=true(필수 트랜잭션)는 항상 enabled=true(토글 불가)
```

### 5b.3 수신설정 변경 · CMP-03, MKT-10
`PATCH /api/me/notification-settings` → `{ updates: [ { category, channel, enabled } ] }`
- **필수 트랜잭션(required=true) 변경 시도 → 400(NOTIFICATION_REQUIRED, 변경 불가)**. 선택(마케팅)만 enabled 토글 가능. 마케팅 OFF는 즉시 발송 제외(수신거부 처리 MKT-10).

### 5b.4 알림센터 (인앱 수신함) 조회 · SUP-07
`GET /api/me/notifications?unread&cursor` (Front/Admin **역할 필터로 공유**하는 단일 패턴) · `POST /api/me/notifications/:id/read`(읽음 처리) · `POST /api/me/notifications/read-all`
- Admin 알림센터(P-AD-11)·Front 알림센터(SUP-07)가 **동일 엔드포인트 + 역할 스코프**로 동작(R-1 단일 패턴 공유).

---

## 6. 문의 / 게시판 (SUP)

> 관련 정책: SUP-01~09.

### 6.1 1:1 문의 · SUP-01/02
`POST /api/inquiries` → `{ type:product|payment|report|etc, content, ref? }`(신고는 콘텐츠 정보 자동입력). 상태머신 답변대기→답변중→답변완료→문의종료. 문의 수정 불가(삭제만).
- 환불 즉시취소·구독 즉시환불은 여기로 라우팅(PAY-10/12).

### 6.2 게시판 / 댓글 · SUP-03/04/05
`GET /api/boards/:boardId/posts` · `POST /api/boards/:boardId/posts` · `POST /api/posts/:id/comments`
- 작성 권한: 구독중/접근권한 보유자만(SUP-04). 비밀글 권한 없으면 상세 진입 403(SUP-05). 본인만 수정/삭제.

---

## 7. 외부 연동 (External Integrations)

> 04/05의 외부연동(§8.2 M-8)과 정합. 외부 API 마크는 화면설계서 프로세스의 외부 인터페이스와 1:1.

| 연동 | 용도 | 비고 |
|------|------|------|
| **토스페이먼츠** (PG) | 카드 등록(빌링키)·정기/즉시 결제·매출전표 영수증 | 신용/체크만(계좌이체 미지원 PAY-02). 빌링 결제창·매출전표 출력 연동. **빌링키·환불 골격 확정(M-8)**. **웹훅 4종(수신·서명검증·재시도 배치·멱등/정산자동화)은 OQ-PAY 잔존(§9·§4.5)** |
| **NICE** (본인확인) | 휴대폰 본인인증(이름 노출)·Front 상품결제 최초 1회 | AUTH-15·PAY-02 |
| **맑은메시지 계열** | 캠페인 발송: SMS/MMS·알림톡·이메일 | 알림톡=카카오 검수 승인 템플릿코드만(MKT-04). 정보통신망법(수신거부·광고표기 MKT-10/CMP-03) |
| **카카오 비즈니스 채널** | 알림톡 채널ID·템플릿코드(Read-only) | 연결 해제 시 승인템플릿 발송 즉시 중단(MKT-04) |
| **FCM(Android)/APNs(iOS)** | 푸시 | 디바이스토큰 KV → 서버이벤트 → **Cloudflare Queues** 비동기(at-least-once+재시도+DLQ STACK §3) |
| 소셜 OAuth ×5 | Front 로그인(google/kakao/naver/apple/facebook) | AUTH-01 |

---

## 8. 크레딧 차감 단가 정책 (과금모델 = 종량제 확정 · 단가는 Open)

> PAY-19·MKT-06·LRN-17·M-3. 크레딧은 **캠페인 발송·AI 튜터·AI 번역·AI 자막** 시 차감(충전 10,000원 단위·유효기간 1년).
> **과금 모델 = 종량제(건당 차감) 확정(M-3, 2026-06-25 컨펌)**. 단 **채널별/AI기능별 실제 단가(크레딧)·크레딧↔원 환산율은 여전히 Open** — 입력데이터 5종(채널 도매원가·AI 호출원가·경쟁사 시세·환산율·마진정책) 수집 후 운영자·오백개가 확정한다. **아래 표의 단가 칸은 전부 Open 유지. 임의 단가 금지(수치 날조 금지).**

| 차감 사유(reason) | 단위 기준 | 단가(크레딧) | 상태 |
|----------|----------|:---:|:---:|
| SMS 발송 (90자↓) `campaign_send` | 건당 | — | **Open(M-3 종량제 확정·단가 입력데이터 5종 후)** |
| MMS 발송 (90자↑) `campaign_send` | 건당 | — | **Open(단가)** |
| 알림톡 발송 `campaign_send` | 건당 | — | **Open(단가)** |
| AI 튜터 생성 `ai_tutor` | 영상 분량 기준 | — | **Open(단가·AI 스펙 OQ-AI)** |
| AI 번역 `ai_translate` | 영상 분량·언어 기준 | — | **Open(단가)** |
| AI 자막 `ai_caption` | 영상 분량 기준 | — | **Open(단가)** |

> 차감 로직 골격(가차감 pending → 성공건 최종차감 settled → 실패건 익일환불 refunded, MKT-06)은 §5.4 크레딧 원장 엔드포인트·§1.11 CreditLedger에 **확정 정의**. **단가 상수(`config.unit_price[reason]`)만 미확정** — 운영자/오백개 후속 결정 필요(§9 OQ-MKT).

---

## 9. Open Questions / 후속 (v0.2+)

> v0.1에서 의도적으로 미정의한 영역. 정직하게 분리한다(가짜 완성 금지).

| # | 영역 | 미정의 내용 | 결정 주체 | 연계 |
|---|------|------------|----------|------|
| OQ-MKT | 크레딧 단가 | **과금모델=종량제 확정(M-3)**. 잔존: 채널별(SMS/MMS/알림톡)·AI기능별 차감 단가(크레딧)·크레딧↔원 환산율 — 입력데이터 5종 수집 후 확정. **단가 수치만 Open**(§5.4·§8 종량제 골격은 확정) | 운영자·오백개 | 05 M-3, §5.4, §8 |
| OQ-AI | AI 기능 스펙 | AI 튜터/자막/번역의 입력·출력·재생성 정책 상세 API | 임기획·오백개 | 05 M-3, LRN-17 |
| OQ-EP | 엔드포인트 전수화 | 7도메인 전체 CRUD 전수 정의(v0.1은 대표만) | 강테크·오백개 | 04 96정책 |
| OQ-D1 | D1 상세 스키마 | 타입·제약·인덱스·FK·마이그레이션 SQL | 오백개 | §1, STACK §4(비가역 게이트) |
| OQ-PAY | 토스 웹훅·정산 자동화 | **잔존(M-8 골격 확정, 웹훅 4종 구체화)**: ①웹훅 수신 `POST /api/billing/webhook/toss` ②서명검증(`wrangler secret`) ③재시도 배치(Cloudflare Cron/Queues, 3일6회) ④멱등+상태머신 동기화·정산 자동집계. 실결제/실환불 자동화=비가역(staging 선검증·운영자 확인) | 오백개·배인프 | billing §9, PAY-21, §4.5, §7 |
| OQ-SET | 정산 프로필 | SettlementProfile(유형·계좌실명·통장사본 R2) 제출/승인 API | 오백개 | PAY-20 |
| OQ-LRN | 상품 유형별 상세 | 디지털 다운로드 차감·패키지 구성·멤버십 등급·커뮤니티 결제 엔드포인트 | 강테크·오백개 | LRN-13~16 |
| ~~OQ-CMP~~ | ~~본인화면 마스킹 예외~~ | **해소(v0.2 §0 응답 마스킹 규칙)** — 본인 식별정보 비마스킹 / 카드·계좌 부분마스킹 유지 / 비번·인증코드 응답 미포함(C-6 확정) | 강테크·임기획 | CMP-02, §0, 05 C-6 |
| ~~OQ-NOTI~~ | ~~알림 트리거~~ | **해소(v0.2 §5b 알림 단일 도메인)** — 라우팅 테이블 1개에 M-4 운영자 알림(N-01~N-10)·M-5 자동메일(N-F1/N-F2) 편입, 수신설정(필수/선택) 분기(R-1) | 임기획·오백개 | SUP-07, §5b, 05 M-4/5 |

---

## 부록. v0.2 커버리지

| 도메인 | 정의 엔드포인트(대표) | 정책ID 추적 |
|--------|:---:|---|
| AUTH | 8 (소셜콜백·로그인·가입·인증코드·재설정·프로필·권한설정·roleGuard) | AUTH-01~15, C-1/2/3, M-2 |
| LRN | 4 (목록상세·진도·라이브입장·수료증) | LRN-01/08/09/10/11/19/21 |
| PAY | 8 (카드·구독·주문·해지·재시도/유예·환불·플랜변경·정산조회) | PAY-01~21, M-1, C-4 |
| MKT | 4 (캠페인·수신자그룹·쿠폰발행·**크레딧 차감 원장 debit/settle/refund**) | MKT-01/02/06/07/14, C-4, **M-3** |
| **NOTI** | **4 (알림 트리거 훅·수신설정 조회/변경·알림센터)** | **R-1, M-4(N-01~10), M-5(N-F1/2), CMP-03** |
| SUP | 2 (1:1문의·게시판) | SUP-01~05 |
| **합계** | **약 30 대표 엔드포인트 + 12 엔티티(CreditLedger 보강)** | NOTI 도메인 추가 — 8도메인 추적키 매핑 |

> billing/05 정합: 무료체험 없음(M-1)·재시도3일6회·유예27일·환불7일전액/일할0.7·쿠폰AMOUNT only(C-4)·닉네임2~15(C-1)·비번8~16 3종(C-3)·TTL 600/1800/172800s(C-2)·RBAC(M-2) **전부 반영**.
> **v0.2 추가 반영**: **M-3 종량제(과금모델 확정·단가 Open)**·**R-1 알림 단일도메인(라우팅 테이블 1개)**·**C-6 응답 마스킹 규칙(본인 비마스킹/카드·계좌 부분마스킹/비번·인증코드 미포함)**·**M-8 PG 골격 확정(웹훅 4종은 OQ-PAY 잔존)**. Open Questions는 §9에 정직 분리(해소 2건: OQ-CMP·OQ-NOTI / 잔존: OQ-MKT 단가·OQ-PAY·OQ-AI·OQ-EP·OQ-D1·OQ-SET·OQ-LRN).

---

## 변경이력

- **v0.2 (2026-06-25)**: 라운드2 결정 반영 — OQ-MKT(종량제 확정·단가 Open)·OQ-NOTI(알림 단일 도메인 라우팅 테이블)·OQ-CMP(본인화면 마스킹 규칙) 해소/진전, M-8 PG 골격 확정·OQ-PAY 잔존.
- **v0.1 (2026-06-25)**: 착수본 — 핵심 도메인(AUTH/PAY/LRN/MKT/SUP) 대표 엔드포인트·12 엔티티 정의. 미정의·미결은 §9 Open Questions로 분리.
