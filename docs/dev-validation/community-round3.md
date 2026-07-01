# FR01 커뮤니티/멤버십 라운드3 검증 결함표 (QA)

- 대상: 프리미엄 커뮤니티 S-FR01-0107-001~005 + 멤버십 S-FR01-0108-001 + board/subscription 공통 컴포넌트 9종
- 검증 기준(SoT, 읽기전용): `docs/validation/01_customer-front.md`(§0107-001~005·§0108-001), `00_화면목록.md`, `04_정책요약.md`(LRN-15/16·SUP-04·CMP-01~06), `05_정책설계서.md`
- 절차: `docs/DEV_VALIDATION_PROCESS.md` (9축 + 05 6건 + 회귀)
- 파일 무수정 준수(구현·mockup·정본). 본 파일만 신규 작성.
- 종료조건: 심각도 '상'(blocker) 0건 — **판정 GO**

---

## 1. 커버리지 (화면ID 6건)

| 화면ID | SoT | 구현 파일 | 상태 | 주석 |
|--------|-----|-----------|------|------|
| S-FR01-0107-001 | 프리미엄 커뮤니티 소개/구독 | `app/pages/community/premium/index.vue` | ⭕ 있음 | 헤더 화면ID 주석. 단일상품 게시판 랜딩(P-20) 구현 |
| S-FR01-0107-002 | 게시판 리스트 | `.../premium/[communityId]/index.vue` | ⭕ 있음 | 검색·더보기·작성정보·글쓰기권한 분기 |
| S-FR01-0107-003 | 게시글 글쓰기 | `.../[communityId]/write.vue` | ⭕ 있음 | 에디터·첨부·검증토스트 |
| S-FR01-0107-004 | 게시글 상세(댓글/답글/대댓글) | `.../[communityId]/[postId].vue` | ⭕ 있음 | 더보기 분기·삭제컨펌·신고 |
| S-FR01-0107-005 | 게시글 수정 | `.../[communityId]/[postId]/edit.vue` | ⭕ 있음 | 프리필·작성자 본인 게이트 |
| S-FR01-0108-001 | 멤버십 상품 | `app/pages/courses/membership.vue` | ⭕ 있음 | 좌목록/우상세·무제한 카테고리·미리보기 |

- 라우팅: 중첩 동적 `[communityId]/[postId]` 정상. `[postId].vue`(상세) + `[postId]/edit.vue`(수정) 동거 — Nuxt 3 규칙상 유효.
- **누락 0 / 추가(정본 외 신규 화면) 0.**
- 공통 컴포넌트 9종 전부 존재: `board/{BoardEditor,BoardAttachment,CommentThread}`, `subscription/{SubscriptionInfoCard,BenefitList,SubscribeConfirm}`, `composables/{useBoard,useSubscription}`, `utils/boardFormat`.

---

## 2. 결함표

`화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안`

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|--------|--------|--------|------|---------|------|
| D-1 | S-FR01-0107-004 (CommentThread) | 인터랙션/공통컴포넌트 | 중 | 답글·대댓글 **이미지 첨부 UI 부재**. SoT는 답글/대댓글에 이미지 1개(jpg/jpeg/png) 첨부·미리보기·교체·확대를 요구하나, CommentThread는 텍스트 textarea만 있고 `createComment(imageUrl:null)` 고정. 댓글 작성(2-3)도 이미지 선택 없음. | 01 §0107-004 2-3(댓글 이미지)·6-1·7-1(답글 이미지 1개, 교체/삭제/확대) | 답글/댓글 입력창에 이미지 picker + 미리보기 추가. 업로드는 `useBoard.uploadImage` 재사용. (현재 [개발-계약대기] 범위면 스텁+주석 명시) |
| D-2 | S-FR01-0107-004 (CommentThread) | 상태/권한 | 중 | `canReply`가 `isLoggedIn`만으로 근사 — SoT는 **답글/대댓글 = 학습자만**(강사·관리자 어드민 전용). 강사·관리자로 로그인해도 답글창이 노출됨(mock authorType 부재로 판정 불가). | 01 §0107-004 3-2·SUP-04·P-22 | user.authorType 확정 시 `canReply = isLoggedIn && authorType==='learner'` 로 교체. 페이지 주석에 mock 근사 명시되어 있음(추적 가능). |
| D-3 | S-FR01-0107-004 | IA/라우팅 | 하 | 게시글/댓글 **신고 → `/mypage/inquiries/new`** 로 navigate하나 해당 라우트 미존재(`app/pages/mypage`에 `profile.vue`만). 클릭 시 404. | 01 §0107-004 1-b·3-b(신고=자동입력 1:1 문의 이동)·P-22 | 1:1 문의 작성 화면(S-FR01-0301-109)은 타 라운드 — 해당 라운드 구현 시 경로/쿼리(type·refType·refId·refTitle) 계약 정합 확인 필요(현재는 교차의존 데드링크). |
| D-4 | S-FR01-0108-001 | 디자인토큰 | 하 | 무제한 카테고리 칩 색상이 하드코딩 `bg-[#f5f3fb] text-[#5a3fa0]` — 프로젝트 토큰(`--color-primary #7954C6`/`-light #EDE9FF`) 미사용. 다른 곳은 전부 `var(--color-primary*)` 일관. | 스타일가이드(토큰 #7954C6)·9축 디자인토큰 | `bg-[var(--color-primary-light)] text-[var(--color-primary)]` 로 치환(다른 배지와 톤 일치). |
| D-5 | S-FR01-0107-002 | 상태 | 하 | 비구독자 진입 차단 미구현 — SoT '상태/예외'에 "비구독자 진입 차단(소개로 회귀, 추정)". 현재 리스트는 열람 가능(글쓰기 버튼만 숨김). | 01 §0107-002 상태/예외(단 **추정** 표기) | SoT가 `[추정]` 수준이라 blocker 아님. 실 API 권한(403) 확정 시 진입 가드 추가 권장. |
| D-6 | S-FR01-0107-003/004 | 상태 | 하 | 유튜브 링크 → 상세 **썸네일 자동 노출** 미구현(에디터/상세 모두 링크 텍스트만). | 01 §0107-003 2.1·§0107-004 1-3·P-21 | BoardEditor 주석에 [P1] 후속으로 명시됨. 계약 확정 시 임베드 추가. |

> **심각도 '상'(blocker) = 0건.** 위 중 2건(D-1/D-2)은 공통컴포넌트 기능 보강, 하 4건은 토큰/교차의존/추정정책·[P1] 후속.

---

## 3. 권한 분기 체크표 (핵심축)

5상태 × 동작 — 구현 정확성:

| 상태 | 글쓰기 노출 | 수정/삭제 | 답글/대댓글 | 신고 라우팅 | 판정 |
|------|-----------|-----------|-------------|-------------|------|
| 비로그인 | ❌ 숨김(`canWrite=false`) | — | ❌ 댓글창 숨김(`isLoggedIn` false) | — | ⭕ |
| 비구독(로그인) | ❌ 숨김(`isSubscribed` false) | 게시글 isMine 시만 노출 | 답글 노출(⚠️ D-2) | 타인 신고 ⭕ | 🔺 D-2 |
| 구독중(학습자) | ⭕ 노출 | 본인 isMine → 수정/삭제 ⭕ | ⭕ 노출 | 타인 → 신고 ⭕ | ⭕ |
| 작성자 본인 | ⭕ | ⭕ 수정/삭제(더보기 isMine 분기) | ⭕ | 본인엔 신고 미노출 ⭕ | ⭕ |
| 타인 | ⭕(구독시) | ❌ 수정/삭제 미노출 → 신고만 | ⭕ | 신고 → 1:1문의(D-3 경로) | 🔺 D-3 |

- 게시글 수정 페이지(0107-005): `!post.isMine` 시 토스트 후 상세로 회귀 — **작성자 본인 게이트 구현 확인 ⭕** (강사·관리자 프론트 수정 차단 P-23 부합).
- 글쓰기 권한 `canWrite = isLoggedIn && isSubscribed` — 강사·관리자 어드민 전용은 mock authorType 부재로 프론트에서 구분 불가(D-2와 동일 한계, [개발-계약대기]).

---

## 4. 교차 재사용 검증 (board/* · subscription/* 6컴포넌트)

| 컴포넌트 | 0107 사용 | 0108 사용 | 페이지 종속 | 판정 |
|----------|-----------|-----------|-------------|------|
| BoardEditor | write·edit | — | props/emit(contentHtml·usedBytes·pickImage), 도메인 주입 | ⭕ 종속 없음 |
| BoardAttachment | write·edit·상세 | — | files v-model·mode·emit | ⭕ |
| CommentThread | 상세 | — | postId·comments·canReply props, report emit | ⭕ |
| SubscriptionInfoCard | 001 | membership | status prop only | ⭕ 양쪽 |
| BenefitList | 001 | membership | benefits prop only | ⭕ 양쪽 |
| SubscribeConfirm | 001 | membership | open·variant props | ⭕ 양쪽 |
| useSubscription | 001 | membership | community/membership 양쪽 메서드 | ⭕ |
| useBoard | 002/003/004/005 | — | boardId 파라미터화(자유게시판·공지 재사용 가능 주석) | ⭕ |
| boardFormat | 002/004 | 001/membership(월구독료·무제한카테고리) | 순수 함수 | ⭕ |

- subscription 3종 + boardFormat은 0107·0108 **양쪽에서 실제 import**됨(BenefitList/SubscriptionInfoCard/SubscribeConfirm/formatMonthlyFee 확인).
- board 3종은 0107 전용(정본상 0108은 게시판 없음) — 정상.
- **데이터 접근은 composable 단일 지점 격리**(컴포넌트 직접 $fetch 없음) 확인. useSubscription이 useProducts.getProduct 조합(중복조회 방지) — 회귀 안전.

---

## 5. 05 확정 6건 / 공통 패턴

| 항목 | 확인 | 결과 |
|------|------|------|
| 컨펌 = AppModal(C-3/C-4) | SubscribeConfirm·게시글삭제([postId])·댓글삭제(CommentThread) 전부 `AppModal` 래핑, `role=dialog aria-modal` | ⭕ |
| 얼럿(alert/confirm) 미사용 | `window.confirm`/`alert` grep 0(BoardEditor의 `window.prompt`는 링크입력 — 얼럿컨펌 아님) | ⭕ |
| 토스트 일원화(C-5) | 전 화면 `useAppToast`(info/success/error) 단일 경유, 3초·하단중앙 프리셋 | ⭕ |
| 쿠폰 정률 0 | 해당 없음(구독/게시판 화면) | N/A |
| 본인 화면 마스킹(C-6) | 작성정보 닉네임 = 본인/타인 모두 **닉네임 노출**(마스킹 대상 아님, 식별정보 비마스킹 허용 05 §C-6). 카드/계좌/비번 노출 없음 | ⭕ |
| 컨펌 카피 정본 대조 | 2-a "멤버십 변경은 현재 이용 기간 종료 후 적용됩니다"+"멤버십을 변경하시겠어요?" / 2-b "로그인이 필요합니다"+"로그인 하시겠어요?" — SoT §0107-001 601~602·§0108-001 758 **정확 일치** | ⭕ |
| 카피 3-a/4-a/4-b | "파일 용량이 업로드 가능한 최대 용량을 초과했습니다"·"제목 또는 내용을 입력해 주세요"·"게시글이 등록되었습니다" — 정본 일치 | ⭕ |
| 삭제 컨펌 카피 | 게시글 "작성하신 게시글을 삭제하시겠어요?"·댓글 "작성하신 댓글을 삭제하시겠어요?" + 토스트 "게시글이/댓글이 삭제되었습니다" — 정본 일치 | ⭕ |
| 마스킹(CMP-01) | 커뮤니티 화면에 이름/이메일/휴대폰/카드 노출 없음 | ⭕ |

---

## 6. 라운드1~2 회귀

- `courses/*`(index·[id]·digital·live·package·video)·`useProducts`·`CourseReviews`·`productFormat` — **본 라운드 미수정**(CommentThread는 CourseReviews를 원형으로 **별도 파일** 일반화, 헤더에 "CourseReviews 무수정" 명시).
- 신규 `useSubscription`이 `useProducts.getProduct`를 import하나 **읽기 조합만**(기존 시그니처 변경 없음) → 기존 courses 경로 무영향.
- 신규 `boardFormat`이 `productFormat.{formatDate,formatRelativeTime}` 재사용(중복정의 없음) → 회귀 안전.
- typecheck에서 courses/*·useProducts·productFormat 에러 0.
- **회귀 결함 0건.**

---

## 7. Typecheck

```
cd /Users/dotype/Projects/solsol
pnpm exec nuxt prepare  (exit 0)
pnpm dlx vue-tsc@2.2.0 --noEmit -p .nuxt/tsconfig.json
```

- **총 21건 — 전부 baseline(auth/mypage 선재)**: profile.vue 11 · signup-terms.vue 5 · MypageSidebar.vue 2 · auth(login/callback/signup) 3. (Nuxt UI 색상 prop `"red"/"green"` 미허용 + MypageSidebar `local` undefined — 라운드3 범위 밖)
- **라운드1~3 대상 파일(community·courses·board·subscription·useBoard·useSubscription·boardFormat) 에러 0건.**
- 신규 도입 오류 0 / baseline 21 유지(증가 없음).

---

## 8. 종합 판정: **GO**

- **blocker(상) 0건** → 게이트 종료조건 충족. 커버리지 6/6, 컨펌/토스트/카피/토큰 축 정본 정합, 교차 재사용·회귀 클린, typecheck 신규오류 0.
- 특기(정당): R6 대댓글(ERD 1단계 vs 정본 3계층)은 `@멘션+동일 parentId` UI로 구현 — [개발-계약대기] 에스컬레이션(중 이하). 업로드/첨부다운로드/구독시작 mock 스텁도 [개발-계약대기] → blocker 아님.

### 우선 보완(다음 라운드/계약 확정 시)
1. **D-1**(중): 댓글·답글·대댓글 이미지 첨부 UI(jpg/jpeg/png 1개, 미리보기·교체·확대) — SoT 명시 기능.
2. **D-2**(중): `canReply`/글쓰기 권한을 `authorType==='learner'` 로 확정(강사·관리자 프론트 답글 차단).
3. **D-3**(하): 신고 대상 `/mypage/inquiries/new` 라우트(S-FR01-0301-109) 구현 시 쿼리 계약 정합.
4. **D-4**(하): membership 무제한 카테고리 칩 토큰화(#5a3fa0/#f5f3fb → var).
5. **D-5/D-6**(하): 비구독자 진입 가드(API 403 확정 시)·유튜브 썸네일 임베드([P1]).
