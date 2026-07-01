# FR01 마이페이지 서브라운드 5b — 검증 라운드1 결함표

- 대상: **S-FR01-0301-106**(결제 내역) · **S-FR01-0301-107**(결제 정보)
- 검증 대상 파일: `app/pages/mypage/{payments,payment-info}.vue` · `app/composables/{useOrder,usePayment}.ts`
- 정본(읽기전용): `01_customer-front.md`(P-42/P-43, L1379~1459) · `04_정책요약.md`(PAY-11/12/14/15, CMP-01/06, C-6) · ERD TB_ORDER/PAYMENT/REFUND/BILLING_KEY
- 절차: `docs/DEV_VALIDATION_PROCESS.md`
- 라운드: **round1** / 판정: **아래 종합 판정 참조**
- 원칙: 정본·구현 파일 **무수정**. 본 파일만 신규 작성.

---

## 1. 커버리지 (화면ID 2건 + 서브요소)

| 화면ID / 요소 | SoT 근거 | 구현 | 판정 |
|---|---|---|---|
| S-FR01-0301-106 결제 내역(페이지) | P-42 / L1379 | `pages/mypage/payments.vue` (화면ID 주석 O) | 있음 |
| — 요약(총액/완료/취소 3카드) | 1-1~1-3 / L1397 | `summary` 3그리드 | 있음 |
| — 필터(상품 AND 결제상태)+정렬 4종 | 2-1~2-3 / L1399~1401 | typeFilter/statusFilter/sort, AND 필터 | 있음 |
| — 리스트(주문번호/상품/상태/일시/금액/영수증/⋮) | 3-1~3-6 / L1404~1409 | v-for 카드 리스트 | 있음 |
| — 10개+더보기 | 3 / L1403 | PAGE_SIZE=10, loadMore | 있음 |
| — 빈/로딩/에러 상태 | 상태·예외 / L1415 | isLoading/isError/빈상태 | 있음 |
| — 영수증 모달(P01, toss 외부) | L1419 | `openReceipt` window.open 스텁 | 있음(스텁) |
| — 결제취소 컨펌(MPU) | 3-c / L1410 | `cancelOpen` AppModal | 있음 |
| S-FR01-0301-107 결제 정보(페이지) | P-43 / L1429 | `pages/mypage/payment-info.vue` (화면ID 주석 O) | 있음 |
| — 등록 카드 리스트(이미지/브랜드/마스킹/등록일/대표배지) | 1-1~1-3 / L1447~1450 | 카드 리스트 | 있음 |
| — 빈상태 + [카드 등록하기] | 상태·예외 / L1456 | 빈상태 블록 | 있음 |
| — 삭제 컨펌(MPU) + 정기구독 차단 토스트 | 1-4/1-a/1-c / L1451 | deleteOpen + requestDelete 차단 | 있음 |
| — 대표설정 컨펌(MPU) | 1-5/1-d / L1452 | primaryOpen | 있음 |
| — 카드 등록(외부 toss 스텁) | 2 / L1453 | `openAddCard` 스텁 | 있음 |
| composable useOrder / usePayment | — | 신규 2건 | 있음 |
| (추가) 없음 | — | 정본 외 임의기능 없음 | — |

> **누락 0 / 추가(임의기능) 0.** 커버리지 완전.
> 참고: 106 검색(상품명, 2-4)은 정본에 **[추정]** 표기(L1402) → 권위 아님, 미구현 정상. 106 P01 영수증·107 카드등록은 외부 toss(§0-5, 자체설계 대상 아님) → 스텁 정상.

---

## 2. 결함표

`화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안`

| 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|---|---|---|---|---|
| 0301-106 | IA/라우팅 | **중** | ⋮ 분기 b [1:1 문의하기] 클릭 시 `goInquiry`가 `/mypage/inquiry/write`로 navigate → **해당 라우트 미존재(404)**. `app/pages/mypage/` 하위에 inquiry 디렉터리·파일 없음(payments.vue 외 참조 0). | P-42 3-b(L1411) "해당 상품 자동 입력된 **1:1 문의 페이지 이동**" · SUP-02(L175) · 대상화면 S-FR01-0301-109 | 5b 스코프 밖(0301-109 미구축) 이므로 **경계 결함**. 0301-109 구현 시 라우트 정합 확인. 임시로 링크 비활성/안내 토스트 고려. `payments.vue:172` |
| 0301-106 | 카피 | 하 | ⋮ 메뉴 라벨 "결제 취소"/"1:1 문의하기" — 정본 DESCRIPTION은 "[취소하기]"/"[문의하기]"(L1410-1411), P-42 요약도 "[취소하기]/[문의하기]"(L1722). 의미 동일하나 문구 상이. | P-42 3-a/3-b · L1722 | PNG(p286/p290) 대조 후 문구 통일(권장: 정본 우선). 컨펌·토스트 카피는 정본 정합(아래 참조). |
| 0301-106 | 상태(카피) | 하 | 결제일시 표기 `formatDateTime`=`YYYY.MM.DD 오전/오후 HH:MM`. 정본 3-4는 `YYYY.MM.DD HH:MM`(L1407). 앱 공통 util 포맷과 일관되나 정본 형식과 오전/오후 유무 차이. | 3-4(L1407) | PNG 대조 후 결정. 공통 util 통일이면 정본과 함께 확정(경미). |
| 0301-107 | 상태 | 하 | 마지막 카드 삭제 시 처리 정본 `[미확정 — 캡처 미표기]`(L1457). 구현은 삭제 후 남은 카드 0이면 빈상태 전환(대표 승격 로직은 length>0 가드). 정본 미확정 항목이라 결함 아님(관찰). | L1457 | 정책 확정 시 재검. 현재 구현 안전(가드 O). |

> **심각도 상(blocker) = 0건.** (아래 항목들은 통과 근거)

---

## 3. PAY 분기 정합 (핵심)

### PAY-12 (셀프취소 vs 1:1문의) — **통과**
- ⋮ 더보기는 **결제완료 건만** 노출(`v-if="order.status === 'paid'"`, payments.vue:310).
- 분기 a: `order.selfCancellable`(7일 이내+미사용) true → **[결제 취소]** → `openCancel` → AppModal 컨펌 → `confirmCancel` → `cancelOrder`(셀프 전액환불 mock) → 낙관 갱신+요약 재집계+토스트. 컨펌 게이트 존재. ✅
- 분기 b: `selfCancellable=false` → **[1:1 문의하기]** → `goInquiry`(query: type/ref/product 자동입력). 라우팅 대상 404는 §2 중결함. 자동입력 파라미터는 정합. 🔺(라우트)
- `selfCancellable` 판정은 composable/mock에서 산출(호출부는 서버/mock 값 신뢰) → **부분환불 일할·위약금 계산 Front 미구현**. useOrder 주석·구조상 PAY-11 billing 이관 준수. ✅ (부분환불 계산 Front 有 = 오히려 결함인데 **없음** → 정상)

### PAY-14 (영수증) — **통과**
- 영수증 버튼 조건: `order.status === 'paid' && !order.isFullRefunded`(payments.vue:301) → **전액환불 건 숨김** ✅.
- `openReceipt`=toss 외부 `window.open` 스텁 + `[개발-계약대기]` 토스트 ✅ (§0-5 외부 대상, 자체설계 아님).
- mock 취소건 `isFullRefunded: true`(useOrder:160) → 취소 상태는 애초 영수증 미노출(리스트 영수증은 paid만).

### PAY-15 (카드 삭제/대표) — **통과**
- 정기구독 사용 카드(`inUseForSubscription`) → `requestDelete`에서 **컨펌 진입 전 즉시 차단 토스트**(payment-info.vue:71) ✅. composable `deleteCard`도 이중 방어(blocked 반환).
- 그 외 카드 → AppModal 컨펌 → `confirmDelete` → 낙관 제거(대표 삭제 시 첫 카드 대표 승격) + 토스트 ✅.
- 대표설정 → AppModal 컨펌 → `confirmPrimary` → 대상만 대표·나머지 일반전환 + 상단 정렬 + 토스트 ✅. 최초 등록=대표 정렬은 `sortByPrimary`로 리스트 상단 유지.

---

## 4. ⚠️ 카드 마스킹 (C-6 / CMP-01) — **통과 (blocker 0)**

| 점검 | 결과 |
|---|---|
| 원본 카드번호 미보유 | ✅ `PaymentCard.last4`(뒤 4자리)만 보유, 전체 번호 필드 없음(usePayment:36) |
| 표기 항상 뒤 4자리 마스킹 | ✅ `maskCardNumber(last4)` → `**** **** **** 1234`(usePayment:150). 리스트(payment-info.vue:203) 사용 |
| 본인 화면도 부분마스킹 유지(C-6) | ✅ 비마스킹 분기 없음. mock last4는 표기용, 앞자리 데이터 자체 부재 |
| 컨펌 카피에도 마스킹만 노출 | ✅ 삭제 컨펌(payment-info.vue:242)·대표설정 컨펌(271) 모두 `maskCardNumber` 사용. 원본 노출 없음 |
| 방어(빈/비정상 last4) | ✅ `maskCardNumber`가 `\D` 제거·`slice(-4)`·`padStart('•')` 방어 |
| 식별정보(이름/이메일) 노출 | 해당 없음 — 두 화면 모두 카드/주문 정보만 표기, 본인 식별정보(이름/이메일) 미노출 |

> **카드 마스킹 위반 = 0건.** blocker 없음.

---

## 5. 비가역 게이트 (CMP-06) — **통과**

| 행위 | 게이트 | 판정 |
|---|---|---|
| 결제취소(전액환불) | AppModal 컨펌 + 전액환불/3~7일 경고 + "되돌릴 수 없어요" 카피(payments.vue:373-406) | ✅ |
| 카드 삭제 | AppModal 컨펌 + "복구할 수 없어요" 경고(payment-info.vue:239-266) | ✅ |
| 대표카드 설정 | AppModal 컨펌(payment-info.vue:269-292) | ✅ |
| 자동진행/얼럿 사용 | 없음 — 전부 명시적 컨펌 버튼 클릭 필요, `alert()`/`confirm()` 미사용 | ✅ |

> AppModal(`components/common/AppModal.vue`)은 `role=dialog`·`aria-modal`·ESC/오버레이 닫기·포커스 처리 구비 → 접근성 게이트 충족.

---

## 6. 9축 요약

| 축 | 결과 | 비고 |
|---|---|---|
| 존재 | ✅ | 2화면 + 모달 4종(영수증/취소/삭제/대표) 전부 존재 |
| IA/라우팅 | 🔺 | goInquiry 대상 라우트 404(§2 중, 경계) |
| 상태(빈/로딩/에러) | ✅ | 106·107 모두 loading skeleton·error+재시도·empty 3상태 |
| 공통컴포넌트 | ✅ | AppModal 계약(open/title/maxWidth/footer/close) 정합 |
| 마스킹 | ✅ | §4 통과, blocker 0 |
| 카피 | 🔺 | 컨펌/빈상태 정본 정합. ⋮라벨·일시포맷 경미 상이(하) |
| 디자인토큰 | ✅ | `#7954C6` 하드코딩 0. 전부 `var(--color-primary/-dark/-light/-error)` |
| 반응형 | ✅ | 요약 grid-3, 필터 flex-wrap, md: 분기. 코드상 1440/390 붕괴 요소 없음(런타임 미측정) |
| 인터랙션 | ✅ | ⋮ 토글·바깥클릭 닫기·낙관갱신·disabled 로딩상태 |

---

## 7. 회귀 (라운드1~5a 무손상) — **통과**
- `useOrder`/`usePayment`는 신규, 소비처는 두 신규 페이지뿐(다른 페이지 참조 0) → 기존 composable 오염 없음.
- MypageSidebar 결제내역·결제정보 링크 기존대로 `/mypage/payments`·`/mypage/payment-info` 유지(경로 정합).
- 기존 composable(useProducts 등) import만 재사용, 시그니처 변경 없음.

## 8. 05 확정 6건 — **해당 위반 0**
- 5b 대상(결제 내역/정보)은 6건(닉네임/무료체험/RBAC/유효시간/비번문구/쿠폰정률)과 직접 교차 없음. 위반 없음.

## 9. typecheck — **전체 0**
```
cd /Users/dotype/Projects/solsol && pnpm exec nuxt prepare >/dev/null 2>&1; pnpm typecheck
→ exit 0, 에러 0
```
- 잔여 WARN: `Duplicated imports "BoardAuthorType"`(useBoard vs boardFormat) = **baseline(기존)** 경고, 5b 파일과 무관.

---

## 종합 판정: **GO (조건부)**

- **종료조건 = 심각도 '상'(blocker) 0건 → 충족.**
- 카드 마스킹·비가역 게이트·PAY-12/14/15 분기·회귀·typecheck 전부 통과.
- 잔여 결함: 중 1건(경계 라우트 404), 하 3건(카피·포맷·미확정정책). 모두 blocker 아님.

### 우선 보완 (다음 라운드/스코프)
1. **[중]** `goInquiry` 대상 `/mypage/inquiry/write`(0301-109) 구축 시 라우트 정합 — 현재 클릭 시 404. 0301-109 개발 라운드에서 필수 검증.
2. **[하]** ⋮ 메뉴 라벨("결제 취소"/"1:1 문의하기") PNG(p286/p290) 대조 후 정본 문구 통일.
3. **[하]** 결제일시 포맷(오전/오후 vs 정본 `HH:MM`) PNG 대조 후 확정.
