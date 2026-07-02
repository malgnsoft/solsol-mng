# FR01 (크리에이터 사용자단) 화면 트랙 — 검증위원회 R01

- **대상**: `/Users/dotype/Projects/solsol/app` (실 API 결선 단계, git HEAD `f56a8b1`)
- **기준일**: 2026-07-02 (KST)
- **정본(SoT, 읽기전용)**: `docs/validation/00_화면목록.md`(FR01 §3.1·§3.1.2) · `01_customer-front.md` · `04_정책요약.md` · `05_정책설계서.md`(확정 16건) · `00_검증가이드.md` · `01_검증체크리스트.md` · `_exports/png/customer-front/`
- **방식**: 화면ID 커버리지(전수) + 대표·핵심 화면 9축 표본 점검 + 05 확정 6건(라운드1) 대조 + 정적 빌드 1회
- **모드**: 읽기 전용 — 정본·앱 **무수정**, 커밋·배포 없음
- **정적 빌드**: `pnpm build` **EXIT 0** (2026-07-02 실행, 로그 확인) — 신규/기존 오류 0

> 본 트랙은 **실앱(`solsol/app`)** 대상. 기존 `mockup-fr01-round1.md`(97건)은 별개의 저밀도 `solsol/mockup` 트리 대상이며 본 실앱과 무관(오너 "분석만 유지" 종결). 실앱은 라운드1~7에서 GO 이력.

---

## 1. 화면ID 커버리지 매핑 (SoT vs 구현 — 전수)

### 1.1 FR01 본화면 (SoT 화면목록 §3.1)

| 화면ID | 화면명 | 구현 파일 | 커버리지 |
|--------|--------|-----------|:--:|
| S-FR01-9001-001 | 결제 유예 이용 제한 인트로 | `app/pages/payment-restricted.vue` | 있음 |
| S-FR01-0301-001 | 회원가입 - 소셜 시작 | `app/pages/auth/signup.vue` | 있음 |
| S-FR01-0301-002 | 회원가입 - 약관 동의 | `app/pages/auth/signup-terms.vue` | 있음 |
| S-FR01-0302-001 | 로그인 (소셜) | `app/pages/auth/login.vue` (+`auth/callback.vue`) | 있음 |
| S-FR01-9002-001 | 알림센터 | `app/pages/notifications.vue` | 있음 |
| S-FR01-0102-001 | 일반강의 목록 | `app/pages/courses/index.vue` | 있음 |
| S-FR01-0102-002 | 일반강의 상세 | `app/pages/courses/[id].vue` | 있음 |
| S-FR01-0103-001 | 라이브강의 목록 | `app/pages/courses/live/index.vue` | 있음 |
| S-FR01-0103-002 | 라이브강의 상세 | `app/pages/courses/live/[id].vue` | 있음 |
| S-FR01-0104-001 | 화상강의 목록 | `app/pages/courses/video/index.vue` | 있음 |
| S-FR01-0104-002 | 화상강의 상세 | `app/pages/courses/video/[id].vue` | 있음 |
| S-FR01-0105-001 | 패키지상품 목록 | `app/pages/courses/package/index.vue` | 있음 |
| S-FR01-0105-002 | 패키지상품 상세 | `app/pages/courses/package/[id].vue` | 있음 |
| S-FR01-0106-001 | 디지털 상품 목록 | `app/pages/courses/digital/index.vue` | 있음 |
| S-FR01-0106-002 | 디지털 상품 상세 | `app/pages/courses/digital/[id].vue` | 있음 |
| S-FR01-0107-001 | 프리미엄 커뮤니티(소개/구독) | `app/pages/community/premium/index.vue` | 있음 |
| S-FR01-0107-002 | 커뮤니티 게시판 리스트 | `app/pages/community/premium/[communityId]/index.vue` | 있음 |
| S-FR01-0107-003 | 커뮤니티 글쓰기 | `app/pages/community/premium/[communityId]/write.vue` | 있음 |
| S-FR01-0107-004 | 커뮤니티 게시글 상세 | `app/pages/community/premium/[communityId]/[postId].vue` | 있음 |
| S-FR01-0107-005 | 커뮤니티 게시글 수정 | `app/pages/community/premium/[communityId]/[postId]/edit.vue` | 있음 |
| S-FR01-0108-001 | 멤버십 상품(구독) | `app/pages/courses/membership.vue` | 있음 |
| S-FR01-0109-001/002 | 공지사항 목록·상세 | `community/notice/index.vue` + `[postId].vue` | 있음 |
| S-FR01-0110-001~005 | 자유게시판 (목록/상세/글쓰기/수정) | `community/free/{index,[postId],write,[postId]/edit}.vue` | 있음 |
| S-FR01-0111-001 | FAQ | `app/pages/community/faq/index.vue` | 있음 |
| S-FR01-0201-001 | 결제 (주문/결제) | `app/pages/payment/checkout.vue` | 있음 |
| S-FR01-0201-002 | 결제 완료 | `app/pages/payment/complete.vue` | 있음 |
| S-FR01-0201-003 | 결제 실패 | `app/pages/payment/fail.vue` | 있음 |
| S-FR01-0301-101 | 마이페이지 - 구독 관리 | `app/pages/mypage/subscription.vue` | 있음 |
| S-FR01-0301-102 | 마이페이지 - 내 상품 | `app/pages/mypage/products.vue` | 있음 |
| S-FR01-0301-201 | 강의실 | `app/pages/mypage/classroom/[id].vue` | 있음 |
| S-FR01-0301-202 | 강의실 - 대시보드 | `app/pages/mypage/classroom/[id]/dashboard.vue` | 있음 |
| S-FR01-0301-203 | 라이브 강의실 | `app/pages/mypage/live/[id].vue` | 있음 |
| S-FR01-0301-103 | 마이페이지 - 수료증 | `app/pages/mypage/certificate.vue` | 있음 |
| S-FR01-0301-104 | 마이페이지 - 찜하기 | `app/pages/mypage/wishlist.vue` | 있음 |
| S-FR01-0301-105 | 마이페이지 - 쿠폰 | `app/pages/mypage/coupon.vue` | 있음 |
| S-FR01-0301-106 | 마이페이지 - 결제 내역 | `app/pages/mypage/payments.vue` | 있음 |
| S-FR01-0301-107 | 마이페이지 - 결제 정보 | `app/pages/mypage/payment-info.vue` | 있음 |
| S-FR01-0301-108 | 마이페이지 - 내 게시글 | `app/pages/mypage/posts.vue` | 있음 |
| S-FR01-0301-109 | 1:1 문의하기 (작성) | `app/pages/mypage/inquiry/write.vue` | 있음 |
| S-FR01-0301-110 | 1:1 문의내역 (목록) | `app/pages/mypage/inquiry/index.vue` | 있음 |
| S-FR01-0301-111 | 1:1 문의 상세 | `app/pages/mypage/inquiry/[id].vue` | 있음 |
| S-FR01-0301-112 | 마이페이지 - 프로필 (설정) | `app/pages/mypage/profile.vue` | 있음 |

**본화면 42 SoT행 / 42 구현 = 100% 커버(누락 0).**

### 1.2 FR01 모달/팝업 (§3.1.2, 14건) — 부모 화면 내 인라인 구현

| _pu 화면ID | 구현 위치 | 커버리지 |
|-----------|-----------|:--:|
| S-FR01-0301-002_pu01 약관 보기 | signup-terms.vue | 있음 |
| S-FR01-0102-002_pu01 공유하기 / _pu02 맛보기 영상 | courses/[id].vue | 있음 |
| S-FR01-0201-001_pu01 본인확인 / _pu02 쿠폰 선택 / (약관·카드) | payment/checkout.vue (_pu01~04 주석 명시) | 있음 |
| S-FR01-0301-101_pu01 구독 취소 | mypage/subscription.vue | 있음 |
| S-FR01-0301-102_pu01/02 패키지·디지털 리스트 | mypage/products.vue | 있음 |
| S-FR01-0301-201_pu01 영상 전체보기 | mypage/classroom/[id].vue | 있음 |
| S-FR01-0301-202_pu01 상품후기 작성 | classroom/[id]/dashboard.vue | 있음 |
| S-FR01-0301-103_pu01 수료증 | mypage/certificate.vue | 있음 |
| S-FR01-0301-112_pu01 프로필설정 / _pu02 닉네임 변경 / _pu03 계정탈퇴 | mypage/profile.vue (주석·핸들러 확인) | 있음 |

> 모달은 별도 라우트가 아니라 부모 화면 상태(`ref` + AppModal)로 구현 — SoT 기대와 일치. 결제 4모달(_pu01~04)은 checkout.vue 주석·핸들러(`startNiceVerify`/쿠폰/약관/카드)로 전수 확인.

### 1.3 추가(SoT 외) — 허용

| 파일 | 판정 |
|------|------|
| `app/pages/index.vue` (홈) | 추가(허용) — FR01 화면ID 비대상이나 사용자단 홈으로 합리적 |
| `app/pages/auth/callback.vue` | 추가(허용) — 소셜 IdP 콜백 처리(외부 인증 공통 블록, 검증가이드 §5 설계 비대상) |

---

## 2. 결함표

| 결함ID | 화면ID | 검증축 | 심각도 | 현상 | 기대 vs 실제 | 근거 | 제안 | 상태 |
|--------|--------|--------|:--:|------|--------------|------|------|:--:|
| FR01-cttee-r01-D01 | S-FR01-0301-112 | 마스킹(05 C-6) | 중 | 본인 프로필 화면에서 **휴대폰번호가 마스킹**되어 노출(`010-****-1234`) | 기대: 본인 화면 휴대폰 **비마스킹 전체표기**(05 C-6 확정: 프로필의 이름·이메일·휴대폰·닉네임 비마스킹 정상) / 실제: `maskedPhone()`로 가운데 4자리 마스킹 | `app/pages/mypage/profile.vue:50-53`(함수), `:282`(렌더). 코드 주석이 "C-6 정본은 비마스킹이나 보수적으로 마스킹"이라 **의도적 이탈** 명시 | 개인정보 보수화 방향이라 privacy-officer·기획 컨펌 후 존치/해제 결정. 해제 시 `maskedPhone` 제거하고 원문 표기 | 신규 |
| FR01-cttee-r01-D02 | (트랙 공통) | 카피(C-2/C-3) | 하 | 05 C-2(인증코드 유효시간)·C-3(비밀번호 문구)를 FR01 프론트에서 **판정 불가** | FR01 가입/로그인은 **소셜 전용**(비밀번호·인증코드 입력 화면 없음) → C-2/C-3 적용대상 아님. 결함 아님, 판정 제외 근거 기록 | `app/pages/auth/{login,signup,signup-terms}.vue` — 소셜 5종만, password/코드 입력 부재 | AD01·BR01 트랙에서 판정(비밀번호·코드 화면 존재 영역) | 기록 |

> **05 확정 6건(라운드1) 대조**: C-1 닉네임 2~15 **준수**(`NicknameField.vue:36` `length<2||>15` 검증) · M-1 무료체험 미운영 **준수**(14일/무료체험 UI 부재) · M-2 RBAC **N/A**(프론트=학습자 단일주체) · C-2 유효시간 **N/A**(소셜전용, D02) · C-3 비번문구 **N/A**(소셜전용, D02) · C-4 쿠폰 정액 only **준수**(`useCoupon.ts`/`CourseCoupon.vue` 정액 전용, 템플릿 % 실렌더 0건, 정률 필드 부재). **6건 위반 0.**

---

## 3. 9축 점검 요약

| 축 | 판정 | 근거 |
|----|:--:|------|
| 존재 | ⭕ | 본화면 42/42·모달 14 전수 구현(§1) |
| IA/라우팅(active) | ⭕ | 라우트 트리가 화면ID depth와 정합, 동적 라우팅([id]/[communityId]/[postId]) 구성 |
| 상태(빈/로딩/에러/예외) | ⭕ | `CourseListView.vue:55-91`(loading/isError/empty variant), payments·wishlist·coupon·notifications·premium 목록 상태키워드 다수 확인. live/video 목록은 `CourseListView` 위임(상태 공통 처리) |
| 공통컴포넌트 일관성 | ⭕ | 목록=`CourseListView`, 쿠폰=`CourseCoupon`, 닉네임=`NicknameField`, 결제모달=단일 AppModal 재사용 |
| 마스킹 | 🔺 | 카드번호 뒤4자리 마스킹 본인화면도 유지(C-6 준수, `usePayment.ts:212`) / **휴대폰 과마스킹(D01, 중)** |
| 카피 | ⭕(부분 N/A) | 정률 표기 0·payment-restricted 카피 SoT 정합. C-2/C-3은 소셜전용으로 N/A(D02) |
| 디자인토큰 | ⭕ | `var(--color-primary)` 등 토큰 사용(표본) |
| 반응형 | ⭕ | sticky(MO)·모바일 분기 주석/클래스 확인(checkout `[결제] sticky(MO)`) |
| 인터랙션 | ⭕ | 모달 open ref·닉네임 valid-change 게이트·결제버튼 활성조건(본인인증+카드+필수약관) 확인 |

### 실 API 결선(신규 관점) 점검
- `useApi.ts:60-65` **폴백 정책 명시** — 실 API 오리진 설정 시 `fallbackEnabled=false`로 조회실패를 mock으로 은폐하지 않고 에러 노출(양호). 쓰기/결제 계약공백 화이트리스트만 폴백 잔존(호출부 주석).
- `X-Site-Host` 테넌트 헤더(`useApi.ts:144`) SSR/클라 공통 적용.
- 프로필 닉네임 변경이 실 API `PATCH /me` + `NICKNAME_DUP` 에러코드 분기(`profile.vue:116-125`)로 결선 — 양호.

### 발산형 구조 제언 (1건)
- **결제 안전장치**: checkout.vue의 결제버튼 활성조건이 "본인인증+카드+필수약관"으로 클라이언트 게이트만 존재. 실 API 결선 단계에선 서버측 재검증(멱등키·상태 재확인)이 병행돼야 이중결제/우회를 막음 — security-reviewer 트랙에서 서버 계약(멱등성) 확인 권고. (결함 아님, 구조 제언)

---

## 4. 트랙 판정

**GO** (blocker '상' 0건)

- 심각도: **상 0 · 중 1(D01 휴대폰 과마스킹) · 하 1(D02 판정제외 기록)**
- 화면ID 커버리지 100%(누락 0), 05 확정 6건 위반 0, 정적 빌드 EXIT 0.
- D01은 개인정보 보수화 방향(안전측 이탈)이라 배포 차단 사유 아님 — privacy-officer·기획 컨펌으로 존치/해제 결정 권고.
