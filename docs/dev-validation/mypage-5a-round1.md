# 마이페이지 코어 서브라운드 5a — QA 검증 결함표 (Round 1)

- 대상 영역: 마이페이지 코어 5a — 구독관리(0301-101)·내상품(0301-102)·찜(0301-104)·쿠폰(0301-105) + C-9 사이드바
- 검증 대상 앱: `/Users/dotype/Projects/solsol`
- 정본(SoT, 읽기전용): `docs/validation/01_customer-front.md`, `04_정책요약.md`, `05_정책설계서.md`, `00_화면목록.md`
- 검증일: 2026-07-01 · 검증자: FR01 QA
- **판정: GO (조건부)** — blocker(상) 0건. major(중) 1건·minor(하) 6건은 후속 보완 권고.

---

## 1. 화면ID 커버리지 (SoT vs 구현)

| 화면ID | SoT | 구현 | 상태 | 파일 |
|--------|-----|------|------|------|
| S-FR01-0301-101 구독 관리 | 있음 | 있음 | ⭕ | `app/pages/mypage/subscription.vue` |
| S-FR01-0301-101_pu01 구독 취소 모달 | 있음 | 있음 | ⭕ | `app/components/mypage/SubscriptionCancelModal.vue` |
| S-FR01-0301-102 내 상품 | 있음 | 있음 | ⭕ | `app/pages/mypage/products.vue` · `MyProductCard.vue` |
| S-FR01-0301-102_pu01 패키지 리스트 모달 | 있음 | 있음 | ⭕ | `app/components/mypage/PackageListModal.vue` |
| S-FR01-0301-102_pu02 디지털 리스트 모달(잔여차감) | 있음 | 있음(부분) | 🔺 | `app/components/mypage/DigitalListModal.vue` — 선택다운로드/전체선택 미구현(DEF-01) |
| S-FR01-0301-104 찜하기 | 있음 | 있음 | ⭕ | `app/pages/mypage/wishlist.vue` |
| S-FR01-0301-105 쿠폰 | 있음 | 있음 | ⭕ | `app/pages/mypage/coupon.vue` · `useCoupon.ts` |
| C-9 마이페이지 사이드 네비(P-32) | 있음 | 있음 | ⭕ | `app/components/mypage/MypageSidebar.vue` |

- 커버리지: SoT 4화면 + 3모달(_pu01/_pu02/_P01) + C-9 = **전건 존재**. 누락 0 · 추가(유령) 0.
- 추적키 1:1 매핑 정상. 각 파일 상단 화면ID 주석 표기 확인.

---

## 2. 결함표

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|--------|--------|:---:|------|---------|------|
| DEF-01 | S-FR01-0301-102_pu02 | 존재/인터랙션 | **중** | 디지털 리스트 모달에 **[선택 다운로드] 및 [전체 선택] 체크박스가 없음**. 개별 [다운로드]만 구현. SoT §0301-102-P02 2-2(선택 다운로드=체크파일 ZIP+각 1회 차감)·2-3(전체선택/개별해제 연동/잔여0 비활성/무제한 표시) 미충족. 개별 잔여차감·소진 비활성(2-4/2-5)은 구현됨. | 01 §0301-102-P02 2-2·2-3, P-35 | 체크박스 컬럼 + 전체선택 헤더 + [선택 다운로드](활성파일만·각 1회 차감) 추가 |
| DEF-02 | C-9 | 반응형 | 하 | `app/layouts/mypage.vue` 가 `flex gap-8` 고정 + 사이드바 `w-[300px]` 고정. **MO(390px) 전용 전체화면 메뉴 PU(C-9 7-1~7-3) 변형 미구현** — 좁은 폭에서 사이드바+본문이 나란히 압축됨. | 01 §C-9 "MO=별도 전체화면 메뉴(PU)", §0301-101~105 DESCRIPTION "MO=…" | MO 브레이크포인트에서 사이드바를 GNB 진입 전체화면 메뉴 PU로 분리(반응형 스택) |
| DEF-03 | C-9 | 디자인토큰 | 하 | 프리미엄 커뮤니티 뱃지 색을 `bg/border/text-[#E8941A]` **하드코딩**. 동일 값이 `main.css --color-orange: #E8941A` 토큰으로 존재하나 var() 미참조. (주 브랜드색 #7954C6 하드코딩은 5a 파일에서 발견 0 — 전부 `var(--color-primary*)` 사용.) | DEV_VALIDATION §2 디자인축(토큰값 스타일가이드) | `#E8941A` → `var(--color-orange)` 치환(토큰 일원화) |
| DEF-04 | S-FR01-0301-105 | 카피 | 하 | 쿠폰 사용기간 표기가 `~{날짜} 까지`(선행 `~` 붙음). SoT 형식은 `YYYY.MM.DD 오후 HH:MM 까지`(선행 `~` 없음). | 01 §0301-105 1-1, P-41 | 선행 `~` 제거 또는 PNG 대조 후 통일 |
| DEF-05 | S-FR01-0301-102 | 카피/상태 | 하 | 구매·수료상태 필터 `미수료` 옵션이 composable `enrollStatus='not_started'`(수강 전)에 매핑. "미수료"=수료 안 됨(수강중 포함) 의미와 라벨-값 어긋날 소지. 옵션 5종 개수·순서는 SoT 일치. | 01 §0301-102 6.2 | 라벨을 "수강 전"으로 하거나 값 매핑 재정의(PNG 원문 대조) |
| DEF-06 | S-FR01-0301-102 | 인터랙션 | 하 | 화상강의 [화상강의 참여하기] 클릭 시 SoT는 **외부 플랫폼(Zoom/Meet) 새창**. 구현은 `toast.info('화상강의 참여 링크로 이동합니다.')` 안내만(계약대기 스텁). 기능 미완(개발-계약대기 표기 있음). | 01 §0301-102 3-3 | join_url 연동 시 `window.open` 새창 처리(현재는 계약대기로 허용) |
| DEF-07 | S-FR01-0301-102 | 상태 | 하 | 일반강의 상태버튼 `not_started` 라벨이 `"아직 수강기간 전이 아닙니다"` — 이중부정으로 의미 모호(정본 원문은 "아직 수강기간 전입니다"류로 추정). PNG 대조 필요. | 01 §0301-102 1-6 | PNG 원문 카피 확정 후 문구 정정 |

> blocker(상): **0건**. major(중): 1건(DEF-01). minor(하): 6건.

---

## 3. 핵심 정합 검증

### 3-1. 구독 취소 (0301-101 · PAY-10 · P-33 · CMP-06) — ⭕
- `useSubscription.cancelSubscription` mock: 반환 `{ nextBillingAt:null, expiresAt=기존 결제예정일, isActive:true, isCancelled:true }` → **자동결제만 중지 + 잔여기간(만료일까지) 혜택 유지**. 즉시 박탈 아님. PAY-10/P-33 정합.
- 페이지 낙관적 반영: 취소 후 버튼이 "자동 결제 중지됨 (기간 만료 후 종료)"으로 전환. 커뮤니티 [바로가기]는 `isActive` 유지 조건이라 잔여기간 중 계속 활성(만료 후에만 비활성) — SoT "만료일 지난 경우 비활성" 정합.
- 멤버십(단일 카드) / 커뮤니티(복수 카드 v-for) 2형 분리 정확.
- **CMP-06 비가역 게이트**: `SubscriptionCancelModal`이 AppModal(C-4 컨펌 패턴) 래핑 + 경고 카피 정본 정확("구독 취소 시 자동 결제가 중지되며, 남은 이용 기간 동안 혜택을 계속 이용하실 수 있습니다. / 구독을 취소하시겠습니까?") + [계속 이용하기]/[구독 취소] 2버튼. 자동 진행 없음(사용자 확인 필수). ⭕

### 3-2. 내 상품 (0301-102) — ⭕ (DEF-01 제외)
- 카드 5종(일반=진도율+프로그래스바+강의실 / 라이브·화상=수강일시+참여 / 패키지·디지털=리스트 보기) 모두 구현. 상태별 버튼 분기(강의실/마감/수강전, 준비중/종료 등) 라벨 텍스트 병기(색 단독의존 아님).
- 필터 **AND**(type AND completion) + 정렬 3종 + 검색 2자↑(공백무시·대소문자무시, 2자미만 토스트) — `listMyProducts` mock 로컬처리 정합.
- 9개 초과 [더보기] 9개씩 확장 정합.
- 빈 상태: 상품 0건="아직 구매한 상품이 없어요 / 나를 성장시켜줄…"(정본 확정 카피 일치) · 검색 결과 없음=EmptyState variant="search".
- _pu01 패키지 리스트 모달: 묶음 상품 리스트 정상. _pu02 디지털: 개별 잔여차감(`{used}/{limit}`)·소진 비활성·무제한 표시 정상(단 선택다운로드/전체선택 미구현 = DEF-01).

### 3-3. 찜하기 (0301-104 · P-40) — ⭕
- **정렬/필터/검색 없음**(SoT 명시) 정합 — 페이지에 필터/정렬 UI 없음.
- 기본 최근 찜하기순 · 3×3 그리드 · 9개 초과 더보기.
- 해제 플로우: 하트 클릭 → 컨펌(AppModal "찜하기를 해제하시겠어요?") → [확인] → `removeWishlist` → 토스트("찜하기가 해제되었습니다") → 리스트 즉시 제거(filter) + 재정렬 유지. 컨펌→토스트→즉시제거 순서 정합.
- 빈 상태 카피 "찜한 목록이 비어있어요 / 나를 성장시켜줄…" 정본 일치.
- CourseCard(C-8) 공통 재사용(`@toggle-wish` 계약 준수).

### 3-4. 쿠폰 (0301-105 · MKT-15 · C-4) — ⭕
- 2섹션(받을수있는 / 사용가능) 세로 배치. 받기 → `claimCoupon` → 토스트("쿠폰 발급이 완료되었습니다") → claimable에서 제거 + available 상단 추가.
- **C-4 정액 only 준수(blocker 없음)**: `MyCoupon` 타입에 `discountAmount`(정액)만 존재, **정률(%) 필드·표기 전무**. 카드 렌더 `-{{ formatWon(discountAmount) }}` 정액만. 정률 표기 0건. useCoupon 주석에 C-4 blocker 명시.
- 사용가능 섹션 **클릭 이벤트 없음**(표시 전용) 정합. 정렬 최신 등록/발급순 mock 반영.
- 섹션별 빈 상태 카피 "받을수 있는 쿠폰이 비어있어요"/"사용 가능한 쿠폰이 비어있어요" 정본 일치.

---

## 4. 마스킹 (P-32 사이드바 vs C-6 본문)

- **C-9 사이드바 이메일**: `maskEmail()` = 계정 첫 절반 노출 후 `***@domain` 마스킹 적용 → P-32("이메일 마스킹, 계정 첫 2자 이후") 정합. ⭕
- **본문(프로필 화면 등) 비마스킹**: C-6 결정(본인화면 식별정보 비마스킹 허용)과 사이드바 마스킹(P-32)은 **의도된 이원화**. 사이드바 파일 상단 주석에 근거 명시("사이드바 이메일은 C-9(P-32) 명세대로 마스킹 유지"). 5a 범위 내 카드/계좌/비번 노출 화면 없음(C-6 부분마스킹 유지 대상 무). ⭕
- 참고: `maskEmail`은 "첫 절반 노출"이라 SoT 문언 "첫 2자 이후"와 알고리즘이 다르나(계정 길이에 비례), 마스킹 목적·CMP-01 부합. 엄밀히 "첫 2자 고정"을 원하면 조정 여지(하, 비결함 수준 참고).

---

## 5. 회귀 (라운드1~4 무손상) — ⭕ PASS

- `toggleWishlist` 이관: `useWishlist().toggleWishlist` 구현체 + `useProducts` 는 함수 본문 내 lazy 위임으로 **재export(@deprecated)**. 기존 사용처 `CourseDetailView.vue`·`CourseListView.vue`·`courses/index.vue`·`courses/[id].vue` 전부 `useProducts().toggleWishlist` 그대로 동작(참조 무손상).
- `claimCoupon` 이관: `useCoupon().claimCoupon` + `useProducts` 재export. `CourseDetailView.vue`·`courses/[id].vue` 무손상. `CourseCoupon.vue` 는 `ProductCoupon` 타입만 import(영향 없음).
- **순환 import 회피 확인**: `useWishlist`/`useCoupon` 는 top-level 에서 `useProducts` import, `useProducts` 는 top-level 에 `useApi` 만 import하고 `useWishlist()/useCoupon()` 는 **함수 본문 내부에서만** 호출 → top-level 순환 없음. 안전.
- `useProducts`·`useSubscription` 확장(MyProduct/MySubscription 타입·listMyProducts/listMySubscriptions 추가)은 기존 export(listProducts/getProduct/listCategories/getStatus/startSubscription 등) 시그니처 불변 → 기존 사용처 무영향.
- CourseCard(C-8) `@toggle-wish` emit 계약 유지, wishlist 페이지가 동일 계약으로 소비.

---

## 6. 05 확정 6건 관련 (해당분)

- **C-4 쿠폰 정액 only**: ⭕ 준수(정률 필드·표기 0건). §3-4 참조.
- **C-5 토스트 일원화 / 얼럿 폐지**: ⭕ 전 플로우 `useAppToast`(토스트) 사용. 얼럿(alert/window.alert) 미사용. 양방향만 컨펌(구독취소·찜해제·로그아웃 = AppModal C-4). `grep` 상 얼럿 호출 0.
- **C-6 본인화면 마스킹**: ⭕ 사이드바(P-32 마스킹)/본문(비마스킹) 이원화 의도 반영. 카드/계좌/비번 노출 화면 5a 범위 무.
- (닉네임 2~15자·무료체험 미운영·RBAC·유효시간·비번문구는 5a 화면 비해당.)

---

## 7. 정적 검증 (typecheck) — ⭕ 전체 0

```
cd /Users/dotype/Projects/solsol
pnpm exec nuxt prepare  → rc=0
pnpm typecheck          → rc=0, "error TS" 매칭 0건
```

- 결과: **전체 프로젝트 타입 에러 0** (회귀 0). WARN 2건은 기존(baseline) `BoardAuthorType` 중복 import 경고로 5a 무관·비차단.

---

## 8. 종합 판정

**GO (조건부)** — 종료조건 blocker(상) 0건 충족.

우선 보완(배포 전 권고, 순위순):
1. **DEF-01(중)** 디지털 리스트 모달 [선택 다운로드]/[전체 선택] 구현 — _pu02 핵심 기능(P-35) 부분 누락. → `frontend-developer` 위임.
2. DEF-02(하) C-9 MO(390px) 전체화면 메뉴 PU 반응형 — 모바일 UX.
3. DEF-04/05/07(하) 카피 PNG 원문 대조 후 정정.
4. DEF-03(하) `#E8941A` → `var(--color-orange)` 토큰화.
5. DEF-06(하) 화상강의 새창 — join_url 계약 확정 후(현재 계약대기 허용).

- 회귀 0 · typecheck 0 · C-4 정액 only · CMP-06 컨펌게이트 · 마스킹 이원화 모두 정합.
- 정본·핸드오프·목업 무수정, 결함표는 `docs/dev-validation/` (validation 폴더 밖)에만 기록.
