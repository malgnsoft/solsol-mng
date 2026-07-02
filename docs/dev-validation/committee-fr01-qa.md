# FR01 위원회 검증 — QA 위원 종합 검수 (solsol 사용자단)

| 항목 | 내용 |
|------|------|
| 라운드 | 위원회 검증(구현 FR01 전체 · 실 API 결선/배포 상태) |
| 검증 대상 | `/Users/dotype/Projects/solsol/app/` (pages 48 · components 7군 · composables 18 · layouts 3 · middleware 2) |
| 정본(SoT) | `docs/validation/` 00 화면목록·01 customer-front·04 정책요약·05 정책설계서(확정 6건) |
| 검증자 | QA 위원 |
| 검증일 | 2026-07-02 (KST) |
| 방식 | 정적 검수(파일 대조) + typecheck 실행. **런타임 플로우(dev서버/브라우저) 미실행** — 상태축 일부는 코드 패턴 근거 |
| 무수정 | 정본·구현 파일 무수정(읽기 전용) 준수 |

---

## 1. 화면ID 커버리지 (SoT ↔ 구현)

### 1-A. 본화면 42 (S-FR01-*)

| SoT 화면ID | 구현 파일 | 판정 |
|---|---|:--:|
| S-FR01-9001-001 유예 인트로 | pages/payment-restricted.vue | 있음 |
| S-FR01-0301-001 가입-소셜시작 | pages/auth/signup.vue | 있음 |
| S-FR01-0301-002 가입-약관동의 | pages/auth/signup-terms.vue | 있음 |
| S-FR01-0302-001 로그인 | pages/auth/login.vue | 있음 |
| S-FR01-9002-001 알림센터 | pages/notifications.vue | 있음 |
| S-FR01-0102-001/002 일반강의 목록/상세 | pages/courses/index.vue · [id].vue | 있음 |
| S-FR01-0103-001/002 라이브 목록/상세 | pages/courses/live/index.vue · [id].vue | 있음 |
| S-FR01-0104-001/002 화상 목록/상세 | pages/courses/video/index.vue · [id].vue | 있음 |
| S-FR01-0105-001/002 패키지 목록/상세 | pages/courses/package/index.vue · [id].vue | 있음 |
| S-FR01-0106-001/002 디지털 목록/상세 | pages/courses/digital/index.vue · [id].vue | 있음 |
| S-FR01-0107-001 프리미엄 소개/구독 | pages/community/premium/index.vue | 있음 |
| S-FR01-0107-002 커뮤니티 리스트 | pages/community/premium/[communityId]/index.vue | 있음 |
| S-FR01-0107-003 글쓰기 | .../[communityId]/write.vue | 있음 |
| S-FR01-0107-004 게시글 상세 | .../[communityId]/[postId].vue | 있음 |
| S-FR01-0107-005 게시글 수정 | .../[postId]/edit.vue | 있음 |
| S-FR01-0108-001 멤버십 | pages/courses/membership.vue | 있음 |
| S-FR01-0109-001/002 공지 목록/상세 | pages/community/notice/index.vue · [postId].vue | 있음 |
| S-FR01-0110-001~005 자유게시판 | pages/community/free/index·[postId]·write·[postId]/edit | 있음 |
| S-FR01-0111-001 FAQ | pages/community/faq/index.vue | 있음 |
| S-FR01-0201-001/002/003 결제/완료/실패 | pages/payment/checkout·complete·fail.vue | 있음 |
| S-FR01-0301-101 구독관리 | pages/mypage/subscription.vue | 있음 |
| S-FR01-0301-102 내 상품 | pages/mypage/products.vue | 있음 |
| S-FR01-0301-201 강의실 | pages/mypage/classroom/[id].vue | 있음 |
| S-FR01-0301-202 강의실 대시보드 | pages/mypage/classroom/[id]/dashboard.vue | 있음 |
| S-FR01-0301-203 라이브 강의실 | pages/mypage/live/[id].vue | 있음 |
| S-FR01-0301-103 수료증 | pages/mypage/certificate.vue | 있음 |
| S-FR01-0301-104 찜하기 | pages/mypage/wishlist.vue | 있음 |
| S-FR01-0301-105 쿠폰 | pages/mypage/coupon.vue | 있음 |
| S-FR01-0301-106 결제내역 | pages/mypage/payments.vue | 있음 |
| S-FR01-0301-107 결제정보 | pages/mypage/payment-info.vue | 있음 |
| S-FR01-0301-108 내 게시글 | pages/mypage/posts.vue | 있음 |
| S-FR01-0301-109 1:1 문의하기 | pages/mypage/inquiry/write.vue | 있음 |
| S-FR01-0301-110 문의내역 | pages/mypage/inquiry/index.vue | 있음 |
| S-FR01-0301-111 문의 상세 | pages/mypage/inquiry/[id].vue | 있음 |
| S-FR01-0301-112 프로필 | pages/mypage/profile.vue | 있음 |

**본화면 42/42 = 100% 있음. 누락 0.**

### 1-B. 모달/팝업 14 (`_pu`)

| SoT _pu화면ID | 구현 | 판정 |
|---|---|:--:|
| 0301-002_pu01 약관 보기 | components/auth/TermsAgreement.vue | 있음 |
| 0102-002_pu01 공유 | components/course/ShareModal.vue | 있음 |
| 0102-002_pu02 맛보기 영상 | components/course/PreviewVideoModal.vue | 있음 |
| 0201-001_pu01 쿠폰 선택 | checkout.vue `_pu02 쿠폰 선택` | 있음 |
| 0201-001_pu02 결제 약관 | checkout.vue `_pu03 결제 약관`(M-6 SoT 렌더) | 있음 |
| 0301-101_pu01 구독 취소 | components/mypage/SubscriptionCancelModal.vue | 있음 |
| 0301-102_pu01 패키지 리스트 | components/mypage/PackageListModal.vue | 있음 |
| 0301-102_pu02 디지털 리스트 | components/mypage/DigitalListModal.vue | 있음 |
| 0301-201_pu01 영상 전체보기 | components/learn/FullscreenPlayerModal.vue | 있음 |
| 0301-202_pu01 후기 작성 | components/learn/ReviewWriteModal.vue | 있음 |
| 0301-103_pu01 수료증 | components/learn/CertificateModal.vue | 있음 |
| 0301-112_pu01 프로필 설정 | components/mypage/ProfileImageModal.vue | 있음 |
| 0301-112_pu02 닉네임 변경 | profile.vue AppModal + NicknameField | 있음 |
| 0301-112_pu03 계정 탈퇴 | profile.vue 탈퇴 모달(3단계 이중컨펌) | 있음 |

**모달 14/14 = 100% 있음. 누락 0.**

### 1-C. 추가(유령 아님 · 정당 지원 화면)
- `pages/index.vue` — GNB 홈. SoT 42목록 밖이나 정당한 랜딩. (유령 아님)
- `pages/auth/callback.vue` — 소셜 IdP 콜백. SoT "외부 IdP 화면 자체 설계 대상 아님"의 필수 처리 브리지. (유령 아님)

> 커버리지 요약: **있음 56/56(본화면 42 + 모달 14) · 누락 0 · 유령 0 · 정당 추가 2.**

---

## 2. 9축 축별 판정

| 축 | 판정 | 근거 |
|---|:--:|---|
| ① 존재 | ⭕ | 56/56 화면·모달 구현 (§1) |
| ② IA/라우팅 | ⭕ | pages 트리가 메뉴경로와 정합. auth.global.ts 보호라우트 게이트 + terms-gate.ts 약관 게이트 |
| ③ 상태(빈/로딩/에러/비회원) | 🔺 | EmptyState 19개 페이지·로딩/에러 패턴 27개 페이지 확인. **런타임 미실행**으로 화면별 4상태 전수는 코드패턴 근거(일부 detail 페이지 상태 분기 미전수) |
| ④ 공통컴포넌트 | ⭕ | AppModal·AppHeader/Footer·EmptyState·NicknameField·MypageSidebar·useAppToast(C-5) 재사용 일관 |
| ⑤ 마스킹 | ⭕ | 카드 뒤4자리(maskCardNumber `**** **** **** 1234`)·사이드바 이메일(P-32)·휴대폰 가운데·본인 비마스킹 C-6·수료증 실명(본인발급) |
| ⑥ 카피 | ⭕ | 유예(9001) 정본 카피 그대로·닉네임 "2~15자"·쿠폰 정액. (비번문구 C-3 = FR01 소셜전용 N/A) |
| ⑦ 디자인토큰 | ⭕ | `--color-primary: #7954C6` (main.css·app.config.ts) 정의·전역 사용 |
| ⑧ 반응형 | ⭕ | PC/MO `md:` 분기·모바일 BS(CourseFilterSheet 등) 구현 (390/1440 정적 확인) |
| ⑨ 인터랙션 | ⭕ | 모달/토스트/자동읽음(onBeforeRouteLeave)·순차수강 잠금·이중컨펌 탈퇴 |

---

## 3. 05 확정 6건 대조 (FR01 적용분)

| # | 확정 규칙 | FR01 적용 | 판정 | 근거 |
|---|---|---|:--:|---|
| ① | 닉네임 2~15자 단일 | 적용 | ⭕ | NicknameField.vue validate 2~15·maxlength 15·카운터 `/15자`. profile _pu02·signup-terms 재사용 |
| ② | 무료체험 미운영(즉시결제) | 적용 | ⭕ | 14일/trial UI 0건(grep). 가입=소셜 즉시, 유료=즉시결제. 체험 배지·D-day 없음 = 정상 |
| ③ | 강사/서브강사 RBAC | N/A | — | AD01(관리자단) 영역. FR01 무관 |
| ④ | 유효시간(가입10/재설정30/초대48) | N/A | — | FR01 소셜 전용(가입코드·비번재설정 없음) |
| ⑤ | 비밀번호 문구 3종 8~16자 | N/A | — | FR01 소셜 전용(비밀번호 입력 없음) |
| ⑥ | 쿠폰 정액 only(정률% 0) | 적용 | ⭕ | useCoupon/CourseCoupon/useOrder 전부 `discountAmount`(정액)만·정률 필드 없음·`-{n}원`만 렌더. 주석 명시 C-4 blocker 방어 |

> 보조: **C-5 토스트 일원화** — useAppToast(3초·ⓘ/✓/✕) 단방향 프리셋. `alert(`/`confirm(` 직접호출 0건(얼럿 폐지 준수). **C-6 마스킹** — 본인 비마스킹 + 카드/계좌/비번 부분마스킹 유지 정합.
> FR01 적용 3건(①②⑥) **전건 ⭕ · 위반 0.**

---

## 4. 결함표

| 결함ID | 추적키 | 검증축 | 심각도 | 현상(재현) | 기대 vs 실제 | 근거 | 제안 | 담당 |
|---|---|---|:--:|---|---|---|---|---|
| FR01-cmt-D01 | S-FR01-0301-001/002·0302-001 | ⑨ 인터랙션/C-5 | 하 | auth 4화면(login·signup·signup-terms·callback)이 `useToast().add()`를 직접 호출 — C-5 프리셋(useAppToast: 3초·ⓘ아이콘) 우회 | 기대: 전 토스트 useAppToast 프리셋 일관 vs 실제: 아이콘/지속시간 스펙 미적용(토스트 자체는 사용, 얼럿 아님) | auth/login.vue:28·signup.vue:20·signup-terms.vue:98~115·callback.vue:83 | useAppToast로 통일(색만 매핑) | frontend |
| FR01-cmt-D02 | S-FR01-0201-001·0301-201/203 | ④/⑨ 실연동 | 하 | 본인확인(NICE)·카드등록(toss)·결제약관(JSON SoT)·강의실/라이브(useLearning) mock 스텁 잔존 | 기대: 실연동(stage8) vs 실제: `[개발-계약대기]` 정직 표기 mock | checkout.vue:6/8/9·useLearning.ts | 실연동 라운드(security·privacy 서명) 대상으로 이관 | api/frontend |
| FR01-cmt-D03 | 전역 | 정적검증 | 하 | typecheck 경고 2건: `BoardAuthorType` 중복 import(useBoard.ts↔boardFormat.ts) | 기대: 경고 0 vs 실제: WARN 2(타입오류 아님·EXIT 0) | pnpm typecheck 로그 | import 일원화 | frontend |

**집계: 상(blocker) 0 · 중(major) 0 · 하(minor) 3.**

> D02는 결함이라기보다 **stage7 화면 라운드 범위 밖 실연동 status**의 정직 표기다(정본상 OQ-PAY/CMP·실연동 라운드 이관 대상). 화면 9축 판정에는 blocker로 잡지 않는다.

---

## 5. 정적검증 증거

```
명령어: cd /Users/dotype/Projects/solsol && pnpm typecheck (nuxt typecheck / vue-tsc)
EXIT: 0
결과: 타입 오류 0. 경고 2건(BoardAuthorType 중복 import — baseline성, 타입 안전성 무관)
```
- 신규 도입 오류: 0 / baseline 경고: 2(중복 import).

---

## 6. QA 위원 판정

**GO (게이트 통과 — ❌'상'(blocker) 0건 충족)**

- 커버리지 100%(56/56)·누락0·유령0. 05 확정 FR01 적용 3건(닉네임·무료체험·쿠폰정액) 전건 ⭕. typecheck EXIT 0.
- 잔여는 하(minor) 3건뿐 — 게이트 저해 없음.

### 우선 보완(비차단)
1. **D01** auth 4화면 토스트 useAppToast 일원화(C-5 프리셋 정합).
2. **D02** 실연동 스텁(NICE·toss·강의실)은 **실연동 라운드(security·privacy 서명 필수)** 로 별도 게이트 — 화면 라운드 GO와 분리 관리.
3. **D03** BoardAuthorType 중복 import 정리(경고 제거).

### 한계 고지
- **런타임 플로우(dev서버·브라우저) 미실행** — ③상태축(빈/로딩/에러/비회원)은 코드 패턴 근거의 🔺. 실 API 결선분 동작 검증은 실연동 스모크(별도)에서 확인 권고.
