# FR01 결제·알림·유예 검증 — 라운드7 (payment)

- **대상**: 결제(S-FR01-0201-001) + 결제완료(0201-002) + 결제실패(0201-003) + 알림센터(9002-001) + 유예 인트로(9001-001) — 5화면 + 결제 4모달
- **검증 대상 파일**: `solsol/app/pages/payment/{checkout,complete,fail}.vue` · `pages/notifications.vue` · `pages/payment-restricted.vue` · `composables/useNotification.ts`(신규) · `composables/useOrder.ts`(확장) · `components/common/AppHeader.vue`(알림 링크)
- **정본(SoT)**: `docs/validation/01_customer-front.md` (169~187, 263~288, 879~1012) · `04_정책요약.md`(PAY-02/09/18·MKT-15 C-4·CMP-01/05·M-6·SUP-07·EXC-06·C-6)
- **판정**: **GO** (심각도 '상' 0건)

---

## 1. 화면ID 커버리지

| 화면ID | 정본 | 구현 | 상태 | 주석 |
|---|---|---|---|---|
| S-FR01-0201-001 | ✓ | `payment/checkout.vue` | 있음 | 상품/구매자/쿠폰/카드/금액/약관/결제버튼 전 영역 구현 |
| S-FR01-0201-001-P01 본인확인 | ✓ | checkout `_pu01` AppModal | 있음 | NICE mock 스텁 [개발-계약대기] |
| S-FR01-0201-001-P02 쿠폰선택 | ✓ | checkout `_pu02` AppModal | 있음 | 정액·1개·선택안함 기본·빈상태 |
| S-FR01-0201-001-P03 약관 | ✓ | checkout `_pu03` AppModal | 있음 | JSON SoT 목차/동의만 (M-6/CMP-05) |
| S-FR01-0201-001-P04 카드등록 | ✓ | checkout `_pu04` AppModal | 있음 | toss window.open mock [개발-계약대기] |
| S-FR01-0201-002 | ✓ | `payment/complete.vue` | 있음 | 주문번호/상품/일시/금액/수단 마스킹 |
| S-FR01-0201-003 | ✓ | `payment/fail.vue` | 있음 | 실패사유 강조·다시결제·고객센터 |
| S-FR01-9002-001 | ✓ | `notifications.vue` | 있음 | 월그룹·자동읽음·더보기·상대표기 |
| S-FR01-9001-001 | ✓ | `payment-restricted.vue` | 있음 | 진입차단 인트로·정본 카피 |

커버리지: 5화면 + 4모달 = **9/9 있음, 누락 0, 부당한 추가 0.**

---

## 2. 핵심 정합 판정

| 항목 | 정본 | 구현 | 판정 |
|---|---|---|---|
| **PAY-18 실시간 금액** | 총결제=정가합−상점할인−쿠폰할인+VAT, 선택 변경 시 실시간 | `amount = computed(calcCheckoutAmount(products, appliedCoupon))` — computed 실시간·순수함수 경유 | ⭕ |
| **쿠폰 1개·정액 -{n}원** | 1개만·정률(%) 금지(C-4) | `CheckoutCoupon`에 `discountAmount`(정액)만·정률 필드 없음, 라디오 단일선택, 표기 `-{formatWon}` | ⭕ |
| **쿠폰 최소주문/실시간** | 사용가능만 노출·실시간 계산 | `usableCoupons` 필터·`calcCheckoutAmount`서 미달 시 0 적용 | ⭕ |
| **약관 JSON SoT·본문 전사 없음** | M-6/CMP-05 목차·동의만 | `TERMS_SOT` 목차(sections)만 렌더, 안내문 "상세 약관 본문은 확정 후 연동" — 전문 전사 없음 | ⭕ |
| **NICE/toss mock** | 외부 [개발-계약대기] | `onVerifyConfirm`/`onCardAddConfirm` mock 스텁 — 정당 | ⭕ |
| **카드 마스킹(checkout)** | 뒤4자리(CMP-01/C-6) | `**** **** **** {{last4}}`, `BillingCard.last4`만 보관 | ⭕ |
| **완료(002) 마스킹** | `현대 3333 **** **** ****` | `paymentMethodLabel = "${company} ${last4} **** **** ****, 일시불"` | ⭕ |
| **실패(003) 마스킹·사유** | 카드 마스킹·toss 실패사유 강조 | 동일 label·`failReason` error색 강조·재결제 컨텍스트 유지 | ⭕ |
| **알림 자동읽음** | 진입 후 이탈 시 전체읽음 | `onBeforeRouteLeave → markAllRead`(didMarkRead 1회 가드) | ⭕ |
| **알림 월그룹·최신순·더보기·상대표기** | YYYY.MM·내림차순·10건+더보기 | `groups`(월), `sort desc`, PAGE_SIZE 10, `formatRelativeTime` | ⭕ |
| **9001 정본 카피** | "현재 사이트는 쏠쏠 운영 정책에 따라 이용이 제한된 상태입니다. 자세한 사항은 {사이트명}로 문의…" + 보조문 | 정본과 **문자 일치**(줄바꿈만 반응형 `<br class="hidden md:block">`) | ⭕ |

---

## 3. 결함표

| 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|---|---|---|---|---|
| S-FR01-9002-001 / AppHeader | 마스킹/상태 | 하 | GNB 알림 아이콘 배지·aria-label이 **항상** "읽지 않은 알림 있음"으로 하드코딩(빨간 dot 상시 노출). 실제 미읽음 0건이어도 배지·라벨 미변경 | 01 §263 3.2 미읽음 시각구분 / SUP-07 | 미읽음 카운트 바인딩 시 배지·aria-label 조건부 렌더(있을 때만). 현 라운드 AppHeader 변경범위=링크라 하로 유지 |
| S-FR01-0201-001 | 상태 | 하 | 쿠폰 영역: 정본 "사용 가능 쿠폰 0장 시 영역 hide(추정)"인데 구현은 0장이어도 영역 노출 + `쿠폰 선택` 버튼 → 열면 빈상태 모달("쿠폰이 없습니다"). 정본이 `(추정)`이라 blocker 아님 | 01 §937 "쿠폰 영역 hide 추정" | 추정 사항이므로 현행 유지 가능. 확정 시 0장 hide 여부 결정 |
| S-FR01-0201-001 | 인터랙션 | 하 | 결제버튼 활성 조건이 **본인인증+카드선택**만. 정본 8-2 약관 "[필수]"인데 약관 동의 여부는 버튼 활성 게이트에 미반영(약관 모달 [동의하기]가 상태를 저장하지 않음) | 01 §928 "[필수] 주문 내용 확인 동의" | 필수 약관 동의 체크상태를 canPay 게이트에 포함(정본 활성조건은 인증+카드만 명시라 상 아님, 개선 권고) |
| S-FR01-0201-003 | 카피 | 하 | 고객센터 이메일 `support@ssolssol.com`·운영시간 하드코딩 | 01 §1012 "실제 문구/연락처 추후 확정 `[미확정]`" | 정본이 미확정이므로 정당(주석 `[미확정]` 명시됨). 확정 시 교체 |

- **상(blocker) 0건 · 중 0건 · 하 4건.**
- 카드 마스킹 위반: **없음**(전 화면 뒤4자리·전체번호 미보관). 쿠폰 정률 노출: **없음**(정액 필드만).

---

## 4. 05 확정 6건 (관련 항목)

| 항목 | 판정 | 근거 |
|---|---|---|
| 쿠폰 정액 only(정률 숨김) | ⭕ | `CheckoutCoupon.discountAmount`(정액)만, 정률 필드/표기 부재 |
| 마스킹(카드 뒤4자리) | ⭕ | checkout/complete/fail 전부 뒤4자리, `last4`만 보관 |
| 컨펌=AppModal | ⭕ | 4모달 모두 단일 `AppModal`(footer 슬롯) 사용 |
| 토스트 일원화(피드백=useAppToast) | ⭕ | 본인인증/쿠폰/카드/결제오류 전부 `toast.*` |
| 얼럿 미사용(EXC-01) | ⭕ | `alert(`·`window.alert` 미검출 |

> 나머지 05 항목(닉네임/무료체험/RBAC/유효시간/비번문구)은 본 라운드 화면 무관.

---

## 5. 회귀 (라운드1~6)

| 점검 | 결과 |
|---|---|
| useOrder 기존 API(`listMyOrders`/`cancelOrder`) 무손상 | ⭕ 시그니처·mock·요약집계 그대로. 신규(getCheckoutProducts/listCheckoutCoupons/listBillingCards/createOrder/calcCheckoutAmount)는 **추가만**, return에 병존 |
| AppHeader 알림 링크 변경 부작용 | ⭕ `to="/notifications"`(PC+MO drawer) 단순 링크. 프로필 드롭다운·기타 GNB 무영향 |
| courses `[id]` 구매버튼 → checkout 정합 | ⭕ `onBuy` → `navigateTo('/payment/checkout?product=${productId}')`. checkout `productIds` 쿼리 파서 정상 매칭. 비회원 게이트(CourseInfoPanel 로그인 컨펌 + onBuy `isLoggedIn` 이중가드) 유지 |
| CheckoutCoupon/BillingCard 타입 신규가 MyOrder 등 기존 타입 충돌 | ⭕ 독립 인터페이스, 충돌 없음 |

**회귀 결함 0건.**

---

## 6. typecheck

```
cd /Users/dotype/Projects/solsol && pnpm exec nuxt prepare; pnpm typecheck
```
- **에러 0건**(EXIT 정상). 
- baseline WARN 1건: `Duplicated imports "BoardAuthorType"`(useBoard vs boardFormat) — **기존(라운드 무관) 경고**, 신규 도입 아님.

---

## 7. 종합 판정

**GO** — 상(blocker) 0건, 중 0건, 하 4건(전부 정본 `추정`/`미확정` 또는 라운드 범위 밖 개선 권고). 종료조건(❌'상' 0) 충족.

### 우선 보완 (배포 후 백로그, 게이트 무관)
1. (하) AppHeader 알림 배지/aria-label을 실제 미읽음 카운트에 바인딩(상시 "읽지 않음" 하드코딩 제거) — 알림 실API 연동 시 동반.
2. (하) 필수 약관 동의 상태를 결제버튼 canPay 게이트에 반영(현재 인증+카드만).
3. (하) 쿠폰 0장 시 영역 hide 여부 확정(정본 `추정`).
4. (하) 고객센터 연락처/운영시간 정본 확정 시 하드코딩 교체(현 `[미확정]` 정당).
