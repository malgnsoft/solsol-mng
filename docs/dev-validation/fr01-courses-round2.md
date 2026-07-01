# FR01 강의 4유형(라이브/화상/패키지/디지털) 검증 — 라운드2

| 항목 | 내용 |
|------|------|
| 대상 | S-FR01-0103~0106 목록·상세 8화면 + 공통 컴포넌트 확장 |
| 구현 경로 | `solsol/app/pages/courses/{live,video,package,digital}/` · `components/course/` · `composables/useProducts.ts` · `utils/productFormat.ts` |
| 정본(SoT) | `docs/validation/01_customer-front.md` §0103~0106 · `00_화면목록.md` · `04_정책요약.md`(LRN-11~14) · `05_정책설계서.md`(C-4) |
| 검증자 | QA (FR01) |
| 검증일 | 2026-07-01 |
| 종합 판정 | **GO** (blocker '상' 0건) |

> 규칙: 구현·mockup·정본 무수정. 결함은 담당 개발 역할에 위임 대상.

---

## 1. 화면ID 커버리지 (8/8 존재, 누락 0·유령 0)

| 화면ID | 화면 | 파일 | 주석표기 | 판정 |
|--------|------|------|---------|------|
| S-FR01-0103-001 | 라이브강의 목록 | `courses/live/index.vue` | ⭕ `<!-- S-FR01-0103-001 -->` | 있음 |
| S-FR01-0103-002 | 라이브강의 상세 | `courses/live/[id].vue` | ⭕ | 있음 |
| S-FR01-0104-001 | 화상강의 목록 | `courses/video/index.vue` | ⭕ | 있음 |
| S-FR01-0104-002 | 화상강의 상세 | `courses/video/[id].vue` | ⭕ | 있음 |
| S-FR01-0105-001 | 패키지 목록 | `courses/package/index.vue` | ⭕ | 있음 |
| S-FR01-0105-002 | 패키지 상세 | `courses/package/[id].vue` | ⭕ | 있음 |
| S-FR01-0106-001 | 디지털 목록 | `courses/digital/index.vue` | ⭕ | 있음 |
| S-FR01-0106-002 | 디지털 상세 | `courses/digital/[id].vue` | ⭕ | 있음 |

- 페이지는 얇은 래퍼(props 조립) → 실 로직은 `CourseListView`/`CourseDetailView` 공통 컴포넌트. 라우팅 `/courses/{type}/[id]` IA 정합.
- 신규 컴포넌트 4종(`CourseListView`·`CourseDetailView`·`CoursePackageComposition`·`CourseDigitalFiles`) + 확장 4종(`CourseCard`·`CourseInfoPanel`·`CourseFilterBar`·`CourseFilterSheet`) 모두 존재.

---

## 2. 유형별 차이 정합 체크표

| 유형 | 정본 요구 | 목록 카드 | 상세 패널/탭 | 판정 |
|------|-----------|-----------|--------------|------|
| **라이브 0103** | 수강상태 배지(LIVE/예정/종료)·수강일시 / 탭2(소개·후기, 커리큘럼 없음) | `liveStatusBadgeClass`+텍스트, `수강일시 {일시}` ⭕ | `withComposition=false`→탭2 ⭕, 커리큘럼·수료증 dl 숨김(`isGeneral`만) ⭕ | ⭕ |
| **화상 0104** | +플랫폼(Meet/Zoom) 필터·표시 +모집인원(무제한 없음) / 탭2 | `platformText`·`모집인원 {n}명` ⭕, `withPlatform` 필터 ⭕ | 플랫폼 dl 노출 ⭕, 탭2 ⭕ | 🔺(모집인원 폴백, 결함#2) |
| **패키지 0105** | "{n}개 묶음"·"개별구매 대비 N% 할인"·멤버십배지 미표시 / 탭3 / 구성=타유형 카드 | `{n}개 상품 묶음`·`개별 구매 대비 N% 할인`·`showMembershipBadge=false` ⭕ | 탭3(소개/구성/후기) ⭕, `CoursePackageComposition`(유형라벨+커뮤니티전용카드) ⭕ | ⭕ |
| **디지털 0106** | 다운로드제한(무제한/{n}회) / 탭3 / 파일목록 클릭이벤트 없음 | `무제한 다운로드`/`{n}회 다운로드` ⭕ | 탭3 ⭕, `CourseDigitalFiles`(li에 클릭핸들러 없음·표시전용) ⭕ | ⭕ |

**공통 컴포넌트 재사용**: `CourseCard`/`CourseInfoPanel`은 `type` prop 분기로 유형별 렌더, `isGeneral`은 기존 렌더 유지(회귀 안전). 필터바/시트는 `liveStatus`/`platform` prop `undefined` 여부로 조건부 노출. `showPurchase=!withLiveStatus`로 라이브/화상은 구매상태 필터를 수강상태로 대체(정본 §0103-001 7 부합).

---

## 3. 결함표

`화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안`

### 상(blocker) — 0건
없음. (종료조건 충족)

### 중(major)

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|--------|--------|--------|------|---------|------|
| 1 | S-FR01-0104-002 | 카피/정책 | 중 | 화상강의 상세 모집인원 폴백이 "인원 제한 없음". `CourseInfoPanel.vue:89` `capacityText = product.capacity ? '정원 {n}명' : '인원 제한 없음'` — capacity 미설정 시 화상에서도 "인원 제한 없음"을 노출. LRN-12 "화상강의 모집인원 **필수·무제한 없음**"과 로직상 상충(현 mock은 recruitCapacity 항상 부여라 미발현이나 실 API 데이터 결손 시 위반). | `04_정책요약.md` LRN-12 "플랫폼 구분·**모집인원 필수(무제한 없음)**" | 화상(`video_call`)은 capacity null 시 폴백 문구를 노출하지 말고(항상 정원 표기) 혹은 스켈레톤/미표기로 처리. 담당: frontend-developer. |
| 2 | S-FR01-0104-001/002 | 카피 일관성 | 중 | 모집인원 라벨이 카드=`모집인원 {n}명`(`formatRecruitCapacity`) vs 상세=`정원 {n}명`(`capacityText`)로 불일치. 정본 화상 카드(p089 1-2)는 "모집인원 {n}명"으로 명시, 상세는 라벨 미명시(일반상세 2-7 '정원'을 그대로 차용). | 01 §0104 4 "모집인원 {n}명" / 01 §0102-002 6 '정원 {인원수}명' | 화상 상세 모집인원 라벨을 카드와 통일("모집인원") 또는 기획 확정 요청. 담당: frontend + 기획 확인. |

### 하(minor)

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|--------|--------|--------|------|---------|------|
| 3 | S-FR01-0106-002 | 디자인토큰 | 하 | `CourseDigitalFiles.vue:23` 이미지 확장자 아이콘 색 `#f0a500`/`#b07a00` 하드코딩(디자인 토큰 아님). primary/error는 var() 토큰인데 이미지 계열만 리터럴 hex. | 스타일가이드 토큰 원칙(정합축) | 토큰 추가 또는 error/gold 계열 토큰 재사용. 표시 기능엔 영향 없음. 담당: uiux-lead/frontend. |
| 4 | S-FR01-0103-002 | 상태/정책 | 하 | 라이브 상세 mock `capacity = recruitCapacity ?? (id%2 ? 100 : null)`(useProducts:618) → 라이브도 절반은 "정원 100명" 노출. 정본 §0103 상세 차이점(①수강상태 ②수강일시 ③탭2)에 모집인원 미언급. 일반상세 공통구조 차용이라 명백 위반은 아니나 유형 스펙 초과 표기 소지. | 01 §0103 9 차이점 3항 | 라이브 상세 모집인원 노출 필요 여부 기획 확인(현재는 일반상세 구조 상속). 담당: 기획 확인. |
| 5 | S-FR01-0105-002 | 인터랙션 | 하 | 패키지 구성 mock의 커뮤니티 항목 `productId:700`이 실재 상품과 미연결(구성 카드는 링크 없음이라 기능 영향 없음). 표시 전용이므로 무해하나 실 API 연동 시 링크 정책 확인 필요. | 01 §0105 9.4 커뮤니티 전용카드 | 실 API 연동 시 구성 카드 상세 이동 여부 확정. 담당: api-developer 연동 시. |

---

## 4. 일반강의 회귀(라운드1) 결과 — 이상 없음

| 확인 항목 | 결과 |
|-----------|------|
| `courses/index.vue`(일반 목록) | ⭕ 별도 파일 유지. `CourseFilterBar`/`CourseFilterSheet`에 liveStatus/platform prop 미전달 → `undefined`로 필터 미노출, `showPurchase` 기본 true 유지. 기존 배너·메뉴명(테넌트) 로직 온존. |
| `courses/[id].vue`(일반 상세) | ⭕ 별도 파일 유지. 탭3(소개/**커리큘럼**/후기), `CourseCurriculum` + 맛보기 모달(`PreviewVideoModal`, _pu02) 온존. |
| `CourseCard` 확장 | ⭕ `isGeneral` 분기로 강사/수강기간·커리큘럼 기존 렌더 유지. 유형 분기는 `else-if` 체인 → 일반강의 경로 불변. |
| `CourseInfoPanel` 확장 | ⭕ 일반강의는 커리큘럼·수료증 dl 노출(`isGeneral`), 모집일정·수강기간 노출. 라이브/화상 조건이 일반 경로에 영향 없음. |
| `CourseTabs` | ⭕ 미수정. 배지 hide(0건) 로직 유지, 라운드2 상세도 동일 컴포넌트 재사용. |
| 공유 모달(_pu01) | ⭕ `ShareModal` 라운드2 `CourseDetailView`에서도 재사용, 맛보기(_pu02)는 일반 전용 유지. |

**결론**: 공유 컴포넌트 확장은 일반강의 경로를 깨지 않음. `else-if(type)` 분기·`undefined` prop 가드로 회귀 안전.

---

## 5. 05 확정 6건 대조 (관련 항목)

| 항목 | 결과 |
|------|------|
| **C-4 쿠폰 정액 only(정률 % 표기 숨김)** | ⭕ 위반 0건. `CourseCoupon.vue`는 `discountAmount`(정액 -N원)만 렌더, 정률/% 표기·분기 없음(주석으로 blocker 명시). `ProductCoupon` 타입에 정률 필드 부재. 패키지/디지털 상세도 동일 `CourseCoupon` 재사용 → 정률 표기 0. |
| **얼럿(Alert) 미사용(토스트/컨펌 일원화)** | ⭕ 라운드2 대상 전 파일에서 `alert()`/Alert MPU 미사용. 비회원 로그인은 `AppModal` 컨펌(C-4 패턴), 찜/쿠폰/에러 피드백은 `useAppToast`. |
| 그 외(닉네임·무료체험·RBAC·유효시간·비번문구) | 본 라운드 범위(강의 목록/상세) 밖 — 해당 없음. |

---

## 6. typecheck (라운드2 vs 선재)

명령: `pnpm exec nuxt prepare && pnpm dlx vue-tsc@2.2.0 --noEmit -p .nuxt/tsconfig.json`

| 구분 | 에러 수 | 비고 |
|------|--------|------|
| **라운드1+2 대상 파일**(`courses/`·`components/course/`·`useProducts`·`productFormat`) | **0** | 신규 도입 타입 에러 0건 ✅ |
| 선재(baseline·범위 밖) | 21 | `mypage/profile.vue`(11)·`auth/signup-terms.vue`(5)·`components/mypage/MypageSidebar.vue`(2)·`auth/signup.vue`(1)·`auth/login.vue`(1)·`auth/callback.vue`(1). 대부분 Nuxt UI `color="red"/"green"` 리터럴·`local` undefined — 라운드2와 무관한 선재 결함. |

- 브리프 명시 "auth/mypage 선재 21건"과 **정확히 일치**. 라운드2 신규 오류 0.

---

## 7. 9축 요약

| 축 | 결과 | 근거 |
|----|------|------|
| 존재 | ⭕ | 8화면 + 8컴포넌트 전수 존재 |
| IA/라우팅 | ⭕ | `/courses/{live,video,package,digital}` + `[id]` |
| 상태(빈/로딩/에러/비회원) | ⭕ | `isLoading`(스켈레톤)·`isError`(다시시도)·`EmptyState`(product/search variant)·비회원 로그인 컨펌(C-4) |
| 공통컴포넌트 재사용 | ⭕ | 카드·패널·필터·탭·쿠폰·공유 단일 컴포넌트 유형 분기 |
| 카피 | 🔺 | 정본 카피 대부분 일치(수강일시·묶음·다운로드·빈상태). 모집인원 라벨 불일치(결함#2) |
| 디자인토큰 | 🔺 | primary/error/gold/light/dark 전부 `var()` 토큰. #7954C6 하드코딩 0. 이미지 아이콘색만 리터럴(결함#3) |
| 반응형(1440/390) | ⭕ | 그리드 2/3/4열, MO 필터 바텀시트(body scroll lock·Esc·자동포커스), 상세 sticky |
| 인터랙션 | ⭕ | 탭 스크롤스파이(IntersectionObserver)·필터 실시간·시트 확인적용·찜 낙관갱신·검색 2자미만 토스트 |

---

## 8. 종합 판정 — **GO**

- **blocker('상') 0건** → 종료조건 충족. typecheck 라운드2 신규 에러 0. 05 쿠폰 정액·얼럿 미사용 준수. 일반강의 회귀 안전.
- **우선 보완(배포 무관·후속)**:
  1. [중 #1] 화상 상세 모집인원 폴백 "인원 제한 없음" 제거(LRN-12 무제한 없음) — frontend.
  2. [중 #2] 모집인원 라벨 카드·상세 통일("모집인원") — frontend + 기획 확인.
  3. [하 #3] 디지털 파일 아이콘 리터럴 hex 토큰화 — uiux/frontend.
  4. [하 #4] 라이브 상세 모집인원 노출 스펙 확인 — 기획.
- 선재 typecheck 21건(auth/mypage)은 본 라운드 범위 밖 — 별도 티켓 권고.
