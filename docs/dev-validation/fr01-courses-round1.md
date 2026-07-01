# FR01 일반강의 목록·상세 + 공통기반 — 검증 라운드1 결함표

| 항목 | 내용 |
|------|------|
| 검증 대상 | S-FR01-0102-001(목록) · S-FR01-0102-002(상세) · _pu01(공유) · _pu02(맛보기) + 공통기반(C-1/C-2/C-7/C-8·useProducts·useToast·productFormat·app.vue) |
| 구현 경로 | `/Users/dotype/Projects/solsol/app/` |
| 정본(SoT) | `docs/validation/01_customer-front.md`(FR01)·`05_정책설계서.md`(확정6건)·`00_화면목록.md` |
| 절차 | `docs/DEV_VALIDATION_PROCESS.md` (커버리지 → 9축 → 05 6건 → typecheck) |
| 검증자 | QA |
| 검증일 | 2026-07-01 |
| 종료조건 | ❌'상'(blocker) 0건 |

---

## 1. 커버리지 (SoT 화면ID vs 구현)

| 화면ID | SoT | 구현 | 파일 | 판정 |
|--------|:--:|:--:|------|:--:|
| S-FR01-0102-001 일반강의 목록 | ✅ | ✅ | `pages/courses/index.vue` | 있음 |
| S-FR01-0102-002 일반강의 상세 | ✅ | ✅ | `pages/courses/[id].vue` | 있음 |
| S-FR01-0102-002_pu01 공유하기 모달 | ✅ | ✅ | `components/course/ShareModal.vue` | 있음 |
| S-FR01-0102-002_pu02 맛보기 영상 모달 | ✅ | ✅ | `components/course/PreviewVideoModal.vue` | 있음 |

### 공통 컴포넌트 커버리지

| C-ID | 정본(§2.0) | 구현 | 재사용 | 판정 |
|------|-----------|------|:--:|:--:|
| C-1 GNB/Header | ✅ | `common/AppHeader.vue` | 레이아웃 | 있음 |
| C-2 Footer | ✅ | `common/AppFooter.vue` | 레이아웃 | 있음 |
| C-3 모달(LPU) | ✅ | `common/AppModal.vue`(ShareModal·컨펌 재사용) | ShareModal·InfoPanel·Reviews·Footer·Header | 있음 |
| C-5 토스트 | ✅ | `composables/useToast.ts`(useAppToast) + `app.vue` UApp | 전 페이지 | 있음 |
| C-7 빈 상태 | ✅ | `common/EmptyState.vue`(variant 5종) | 목록·후기 | 있음 |
| C-8 상품 카드 | ✅ | `components/course/CourseCard.vue` | 목록 그리드 | 있음 |

- **누락 0 / 추가 0** (SoT 대비 화면ID 1:1 매핑, 유령·누락 없음).
- 추가 구현 course 컴포넌트(CourseFilterBar/Sheet/SearchInput/ProductBanner/CourseInfoPanel/CourseCoupon/CourseTabs/CourseCurriculum/CourseReviews)는 -001/-002 본문 DESCRIPTION 요소를 분해한 하위 컴포넌트로, SoT 범위 내(추가 화면ID 아님).

---

## 2. 9축 점검 요약

| 축 | 판정 | 근거 |
|----|:--:|------|
| 존재 | ⭕ | 4개 화면ID + 6개 공통 컴포넌트 전부 구현 |
| IA/라우팅 | ⭕ | `/courses` → `/courses/[id]` NuxtLink, 브레드크럼(홈>일반강의>상품명), GNB 링크 정합 |
| 상태(빈/로딩/에러/비회원) | 🔺 | 로딩(스켈레톤)·에러(재시도)·빈(C-7 product/search 분기)·비회원 컨펌 전부 구현. 검색 빈입력 토스트 경계는 하 결함 참조 |
| 공통 컴포넌트 재사용 | ⭕ | 모달은 AppModal(C-3) 단일 패턴 재사용, 토스트는 useAppToast 단일화 |
| 마스킹 | N/A | 목록·상세에 PII 마스킹 대상 없음(해당 없음) |
| 카피 | ⭕ | C-7 4종 카피·검색 토스트·후기/삭제/공유 토스트 정본 일치 |
| 디자인토큰 | ⭕ | `--color-primary: #7954C6` 정의, round1 파일 내 하드코딩 퍼플 hex 0건 |
| 반응형(1440/390) | ⭕ | PC 4열(`lg:grid-cols-4`)·MO 2열, MO 필터 바텀시트(B3), MO 상세 Fixed 요소·order 재배치 |
| 인터랙션 | 🔺 | sticky(탭·패널)·스크롤스파이(IntersectionObserver)·바텀시트·모달 scroll-lock·외부클릭 구현. Esc 포커스 의존은 중 결함 참조 |

---

## 3. 결함표

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|--------|--------|:--:|------|---------|------|
| D-1 | _pu01(ShareModal via AppModal) / _pu02(PreviewVideoModal) / B3(FilterSheet) | 인터랙션·접근성 | **중** | Esc 키 닫힘 핸들러가 오버레이 `<div>`의 `@keydown`에 걸려 있으나, 모달/시트 열림 시 해당 div로 **자동 포커스가 이동하지 않음**. 키보드 포커스가 여전히 트리거 버튼(뒤 페이지)에 남아 있어 Esc가 오버레이 div에서 발화하지 않음 → 실제로 Esc 닫힘이 동작하지 않을 가능성. (AppModal.vue:57 `@keydown`, PreviewVideoModal.vue:55, CourseFilterSheet.vue:86) | 01 §0102-002-P01 2 "Esc·✕·외부클릭 닫힘(C-3)" / §P02 4 / C-3 "Esc·✕·외부클릭 닫힘" | 열림 시 컨테이너 `tabindex="-1"` + autofocus, 또는 `window`/`document` 레벨 keydown 리스너로 Esc 처리(AppHeader처럼 document 리스너 패턴 사용). ✕·외부클릭은 정상. |
| D-2 | _pu01 ShareModal | 카피·접근성 | **하** | 카카오 공유가 `toast.info('카카오톡 공유는 준비 중입니다.')` 스텁([개발-계약대기]). SoT는 카카오 공유 팝업(23-a 외부) 호출. 계약 대기 상태로 기능 미완(설계상 외부 SDK). | 01 §0102-002-P01 1 "카카오톡으로 링크 공유하기(23-1)" | SDK 연동 시 실제 공유 호출로 교체. 현재 스텁 표기는 허용(범위 외 외부연동). |
| D-3 | S-FR01-0102-001 검색 | 상태·카피 | **하** | `CourseSearchInput.runSearch()`가 **정확히 1자**일 때만 토스트, 빈 입력은 검색 초기화로 허용. SoT "2자 미만 입력 후 실행 시 토스트"의 문자적 해석과 미세 불일치(0자 실행 시 토스트 없이 전체 재조회). | 01 §0102-001 4 "2자 미만 입력 후 실행 시 토스트" | 의도적 UX(빈 입력=초기화)로 합리적. 단 정본 문자 그대로면 0자 실행도 안내 대상 — 기획 확인 권고(현행 유지 무방). |
| D-4 | S-FR01-0102-002 커리큘럼(C5) | 인터랙션 | **하** | SoT는 최초 진입 시 "**1뎁스 하위 강의 펼침**" + 전체 접기/펼치기 2뎁스. 구현은 모든 섹션 초기 펼침(`new Set(all)`)으로 정본 취지에 부합하나, '모두 펼치기/모두 접기' 토글 라벨이 정본 6-2(모두 펼치기/모두 접기)와 일치. 기능 정상, 경계만 확인. | 01 §0102-002 14/14.2 | 결함 아님(참고). 현행 유지. |
| D-5 | S-FR01-0102-002 상세 상단 정보 | 존재 | **하** | 상세 상단 상품정보의 sticky 대상이 우측 InfoPanel(패널 자체 sticky)로 구현. SoT 2번 "상품 기본정보 영역 sticky"는 충족. 단 SoT 2-2 노출상태 '비공개' 강조는 구현됨(InfoPanel.vue:121). 정합. | 01 §0102-002 2/2.2 | 결함 아님(참고). |

> **상(blocker) 0건 / 중 1건(D-1) / 하 3건(D-2·D-3, D-4·D-5는 참고).**

---

## 4. 05 확정 6건 체크

| # | 확정 항목 | 적용 여부(round1 범위) | 결과 | 근거 |
|---|----------|----------------------|:--:|------|
| C-1 | 닉네임 2~15자 단일 | 헤더 표시명(입력 검증은 프로필 모달 범위 밖) | ⭕(표시 only, 위반 없음) | AppHeader.vue 159/202 `user?.nickname` 표시만. round1에 닉네임 입력 검증 화면 없음 |
| M-1 | 무료체험 미운영 | 즉시 결제/무료 즉시부여 | ⭕ | 상세 구매버튼 P-12 5상태에 14일 체험/D-day UI 없음. 무료=즉시 '무료' 표기(CourseInfoPanel 132) |
| M-2 | 강사/서브강사 RBAC | Front 범위 밖(Admin 정책) | N/A | FR01 사용자단 대상 아님 |
| C-2 | 유효시간(가입10/재설정30/초대48) | Front 인증 범위 밖 | N/A | round1(강의 목록·상세)에 해당 없음 |
| C-3 | 비밀번호 문구 통일 | Front 인증 범위 밖 | N/A | round1에 해당 없음 |
| **C-4** | **쿠폰 정액 only(정률% 숨김)** | 쿠폰 영역 정밀 확인 | ⭕ **위반 0건** | `ProductCoupon` 타입에 `discountAmount`(정액)만 존재, `discountRate`/`RATE`/`discountType` 없음(useProducts.ts:116-120). CourseCoupon.vue는 `-{{ formatWon(discountAmount) }}`만 렌더, `%` 표기·분기 0(코드 내 `%`는 주석뿐). 상품 자체 할인율 %(CourseCard 할인율)는 정본 C-8 1-8 허용 대상으로 별개 — 정상 |
| C-5 | 토스트 단방향 일원화·얼럿 미사용 | 전 컴포넌트 | ⭕ | useAppToast 단일 진입점(info/success/error), `app.vue`가 UApp bottom-center. 코드 전역 `alert(`·`window.confirm` 미사용, 컨펌은 AppModal(C-4)로 처리 |

- **C-4 blocker 최우선 확인 결과: 정률(%) 표기·필드·분기 0건 — 통과.**

---

## 5. 정적 검증 (typecheck)

명령: `pnpm dlx vue-tsc@2.2.0 --noEmit -p .nuxt/tsconfig.json` (실제 실행, EXIT 정상 종료)

| 구분 | 에러 수 | 파일 |
|------|:--:|------|
| **라운드1 신규/수정 파일** | **0** | courses/·course/·common/·useProducts·useToast·productFormat·AppHeader·AppFooter·app.vue — 전부 clean |
| 선재(baseline, 범위 밖) | 21 | auth/(callback·login·signup·signup-terms) · mypage/(profile·MypageSidebar) |

선재 21건 유형: ① Nuxt UI `color` prop에 구버전 값(`"red"`/`"green"`) 전달 → v3에서 `"error"`/`"success"`로 교체 필요(auth·mypage, 19건) ② `MypageSidebar.vue` `local` possibly undefined(2건). **모두 라운드1 밖**이며 담당(auth/mypage 개발)에 회신 대상. 라운드1 산출물은 typecheck 무결.

---

## 6. 종합 판정

**판정: GO (조건부)**

- **종료조건 = ❌'상'(blocker) 0건 → 충족.** C-4(쿠폰 정률 숨김)·C-5(토스트 일원화·얼럿 미사용)·M-1(무료체험 미운영) 전부 통과. 커버리지 누락 0. round1 typecheck 에러 0.
- 잔여 결함: 중 1건(D-1 Esc 포커스), 하 2건(D-2 카카오 스텁, D-3 검색 경계). 배포 차단 사유 아님.

### 우선 보완 순서
1. **D-1(중)** — 모달/시트 열림 시 컨테이너 자동 포커스 또는 document 레벨 Esc 리스너 적용(접근성·정본 "Esc 닫힘" 계약 충족). `frontend-developer` 회신.
2. **D-3(하)** — 검색 0자 실행 시 안내 여부 기획 확인(현행 유지 무방).
3. **D-2(하)** — 카카오 SDK 계약 확정 후 스텁 교체(외부연동, 범위 외).
4. (범위 밖) auth/mypage typecheck 21건 — 해당 개발 역할에 별도 회신(`"red"→"error"` 등).
