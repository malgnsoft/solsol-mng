# FR01 게시판 3종 검증 — 라운드4 (공지 0109 · 자유게시판 0110 · FAQ 0111)

- 대상: `/Users/dotype/Projects/solsol/app/` — 페이지 7 + `useFaq.ts`(신규) + `useBoard.ts`(확장) + `CommentThread.vue`(allowSecret)
- 정본: `docs/validation/01_customer-front.md`(0109·0110·0111) · `04_정책요약.md`(P-25~28) · `00_화면목록.md` · `data-model/ERD.md`
- 검증자: QA · 판정 기준: 종료조건 = 심각도 '상'(blocker) 0건
- 절차: `docs/DEV_VALIDATION_PROCESS.md` (9축 + 05 6건 + 회귀 0 + typecheck)

---

## 1. 커버리지 (화면ID 7건)

| 화면ID | 화면 | 파일 | 상태 | 주석 |
|--------|------|------|------|------|
| S-FR01-0109-001 | 공지 목록 | `pages/community/notice/index.vue` | 있음 | 헤더 주석 ID 표기 O |
| S-FR01-0109-002 | 공지 상세 | `pages/community/notice/[postId].vue` | 있음 | 읽기전용·댓글 없음 명시 |
| S-FR01-0110-001 | 자유 목록 | `pages/community/free/index.vue` | 있음 | 비밀글 자물쇠·토스트 |
| S-FR01-0110-002 | 자유 상세 | `pages/community/free/[postId].vue` | 있음 | 비밀글 진입차단·비밀댓글 |
| S-FR01-0110-003 | 자유 글쓰기 | `pages/community/free/write.vue` | 있음 | 비밀글 토글 |
| S-FR01-0110-005 | 자유 수정 | `pages/community/free/[postId]/edit.vue` | 있음 | 프리필·본인검증. -004는 공번(정본 §800) → 정상 |
| S-FR01-0111-001 | FAQ | `pages/community/faq/index.vue` | 있음 | 아코디언 단일확장·useFaq |

- **누락 0 · 추가 0**. 채번 -004 결번은 정본 §800(N-1 정정)과 일치 — 결함 아님.
- 지원 모듈: `composables/useFaq.ts`(신규·경량) · `useBoard.ts`(BoardType `premium|notice|free` 확장) · `components/board/CommentThread.vue`(`allowSecret` prop) 모두 존재.

---

## 2. 유형별 정합 체크표

### 공지 (0109 · P-25) — 어드민 작성·읽기전용·전체공개
| 항목 | SoT | 구현 | 판정 |
|------|-----|------|------|
| 글쓰기 버튼 없음 | §770 어드민만 | 목록에 글쓰기 버튼 미배치 | ⭕ |
| 댓글/에디터 없음(읽기전용) | §793 | 상세 `<!-- 7 댓글 영역 없음 -->` CommentThread 미포함 | ⭕ |
| 더보기(⋮) 없음(수정/삭제/신고 불가) | §792 | 상세 헤더 메뉴 없음 | ⭕ |
| 전체공개(작성자 유형 배지) | §786 | admin 배지 노출 | ⭕(하 1건, 아래) |
| 고정글 상단 배치 | §787 | `sortedPosts` pinned 선행 정렬 + '공지' 마크 | ⭕ |
| 첨부 개별 다운로드 | §792 | `BoardAttachment mode=view` + `onDownload` | ⭕(mock 계약대기) |
| 빈 상태 카피 | C-7 "아직 등록된 공지사항이 없어요" | EmptyState `variant=notice` 동일 | ⭕ |

### 자유 (0110 · P-26/27 · SUP-05) — 비밀글/비밀댓글·등급권한
| 항목 | SoT | 구현 | 판정 |
|------|-----|------|------|
| 비밀글 목록 자물쇠+제목노출 | §822 | `isSecret` 자물쇠 SVG + 제목 truncate | ⭕ |
| 비밀글 내용 대체문구 | §823 "해당 내용은 작성자와 운영자만 볼 수 있습니다." | 목록 line153 동일 카피 | ⭕ |
| 비밀글 진입차단 토스트 | §820 "해당 게시글은 작성자 또는 운영자만 열람 가능합니다" | 목록 onPostClick·상세 load 동일 카피 | ⭕ |
| 상세 비밀글 표기(제목 상단) | §834 | `v-if=isSecret` 비밀글 뱃지 | ⭕ |
| 비밀댓글 토글/잠금 | §835/836 | CommentThread `allowSecret` 토글+`isLocked` 대체문구 | ⭕ |
| 고정글 없음 | §822 | pinned 정렬 없음·mock isPinned=false | ⭕ |
| 공통컴포넌트 재사용 | §828 | BoardEditor/BoardAttachment/CommentThread 재사용 | ⭕ |
| 등급권한(읽기/쓰기/댓글) | §802 어드민 on/off | mock `isLearner` 게이팅 `[개발-계약대기]` | ⭕(기록) |

### FAQ (0111 · P-28) — 아코디언 단일확장
| 항목 | SoT | 구현 | 판정 |
|------|-----|------|------|
| 아코디언 단일확장 | §869 다른 항목 클릭시 자동 닫힘 | `openId` 단일 ref + `toggle` | ⭕ |
| 질문 전체노출(말줄임 없음) | §868 | `leading-[1.5]` truncate 없음 | ⭕ |
| 검색(제목+내용) | §871 | useFaq q필터 `question+answer` | ⭕ |
| 10개+더보기 10개씩 | §867/870 | PAGE=10 · loadMore +10 | ⭕ |
| 댓글·글쓰기 없음 | §865 | 리스트만 렌더 | ⭕ |
| 카테고리 필터(옵션) | ERD TB_FAQ_CATEGORY | categories 있으면 노출 | ⭕(계약대기) |

---

## 3. 9축 점검 요약

| 축 | 결과 | 비고 |
|----|------|------|
| 존재 | ⭕ | 7화면 + 지원모듈 전부 존재 |
| IA/라우팅 | ⭕ | `/community/notice·free·faq` 경로, free write/edit·상세 navigateTo 정상 |
| 상태(빈/로딩/에러/권한없음) | ⭕ | 3화면 모두 로딩 스켈레톤·에러+재시도·EmptyState. free 비밀글 권한없음=토스트+목록회귀 |
| 공통컴포넌트 재사용 | ⭕ | BoardEditor·BoardAttachment·CommentThread·AppModal·EmptyState 재사용 |
| 마스킹(C-6) | ⭕ | 게시판은 닉네임 노출(마스킹 대상 아님), 비밀글=권한 기반 콘텐츠 은닉 |
| 카피(정본 대조) | ⭕ | 비밀글 차단·대체문구·빈상태·용량초과 카피 정본 일치(하 1건 자유게시판명 하드코딩) |
| 디자인토큰 | ⭕ | `#7954C6` 하드코딩 0건 — 전부 `var(--color-primary)` 계열 사용 (grep 확인) |
| 반응형(1440/390) | ⭕ | 목록 max-w-[1440]/[900]·상세 [760]. 글쓰기/수정 MO ✕(PU) `md:hidden` 처리 |
| 인터랙션 | ⭕ | 아코디언 단일확장·비밀글 토글·더보기(⋮) 메뉴·삭제 컨펌 AppModal |

디자인토큰 grep 결과: 대상 7파일 + CommentThread + useFaq 내 `#7954C6`/`#7954c6` **0건**.

---

## 4. 비밀글 권한 축 (P-27)

| 경로 | 판정 로직 | 결과 |
|------|-----------|------|
| 목록 자물쇠·내용대체 | `canViewSecret = !isSecret \|\| canAccessSecret(isMine)` | ⭕ |
| 목록 진입차단 | `onPostClick` preventDefault + 토스트 | ⭕ |
| 목록 썸네일 은닉 | 비밀글&권한없으면 `thumbnailUrl` 미노출 | ⭕ |
| 상세 진입차단 | `getPost` 후 `canAccessSecret(post.isMine)` 실패시 토스트+`/community/free` 회귀 | ⭕ |
| 비밀댓글 잠금 | `isLocked = allowSecret && isSecret && !canAccessSecret(isMine)` → 대체문구 | ⭕ |
| 운영자 판정 | `canAccessSecret = isMine \|\| role==='admin'` (mock) | ⭕(`[개발-계약대기]` 운영등급 서버판정) |

- mock 결정론: 비밀글 `id%5===0`, 본인글 `id%4===0` → 4000=열람가능/4005·4010=차단. 재현 가능·논리 정합.
- 서버 최종 판정(운영 등급 부여)은 `[개발-계약대기]` → blocker 아님(정당).

---

## 5. 라운드1~3 회귀 (커뮤니티 premium 등)

| 확인 대상 | 결과 |
|-----------|------|
| premium 목록 `[communityId]/index.vue` | `listPosts(id, {q})` — boardType 미전달 → **default premium 동작 보존** ⭕ |
| premium 상세 `[communityId]/[postId].vue` | `getPost(id, postId)` boardType 미전달 · `CommentThread` **allow-secret 미전달**(default false → 비밀UI 없음) ⭕ |
| premium 글쓰기 `write.vue` | `createPost` isSecret 미전달 ⭕ |
| useBoard 확장 하위호환 | `BoardType`·`isSecret`·`boardType`·`isMine?` 모두 **옵셔널**, premium 경로 무영향 ⭕ |
| CommentThread `allowSecret` | `withDefaults(false)` — premium/notice 비밀 UI·잠금 미노출 ⭕ |
| courses/* · subscription/* | 이번 라운드 무수정(git ?? 신규만, premium/course/subscription 기존 파일 변경 없음) ⭕ |

- premium detail 작성정보 = 평문 `authorTypeLabel`(line160) — free detail(line147)과 **동일 렌더**, 일관성 보존.
- **회귀 결함 0건.**

---

## 6. 05 확정 6건 / 공통 6원칙

| 원칙 | 결과 |
|------|------|
| 컨펌 = AppModal | ⭕ 게시글/댓글 삭제 컨펌 모두 `AppModal`(free 상세·CommentThread) |
| 토스트 일원화 | ⭕ 전 화면 `useAppToast`(등록/수정/삭제/차단/오류) |
| 얼럿 미사용 | ⭕ `alert(`/`confirm(` 네이티브 호출 0건 |
| 마스킹 | ⭕ 게시판 비대상. 비밀글=권한 기반 은닉 |
| 05 6건(닉네임/체험/RBAC/유효시간/비번문구/쿠폰) | 해당 화면 비교사항 없음(게시판 스코프 외) — 위반 0 |

---

## 7. typecheck

```
pnpm exec nuxt prepare && vue-tsc@2.2.0 --noEmit -p .nuxt/tsconfig.json
→ 총 21 errors (전부 baseline)
```

| 구분 | 파일 | 건수 |
|------|------|------|
| baseline(범위 밖) | auth/callback·login·signup·signup-terms | 8 |
| baseline(범위 밖) | mypage/profile · MypageSidebar | 13 |
| **라운드1~4 게시판 스코프** | community/* · useBoard · useFaq · CommentThread · BoardEditor · BoardAttachment · boardFormat | **0** |

- baseline 21건은 Nuxt UI v3 `color="red"/"green"` prop 타입·`local` undefined — 게시판 라운드와 무관(선재). 신규 도입 오류 0.

---

## 8. 결함표

| 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|--------|--------|--------|------|---------|------|
| S-FR01-0109-001 | 상태 | 하 | 검색어 1글자(`>=2` 미만) 입력·검색 시 목록 페이지의 EmptyState variant가 `search`가 아닌 `notice`로 표기됨(`isSearchActive`는 2자 이상만 true). 단 composable 필터는 1자에도 동작 → 결과 0건일 때 "공지사항 없음"으로 오안내 가능 | §788 검색=부분일치, C-7 검색 결과 없음 | `isSearchActive` 기준을 `activeQuery.length>0`로 통일하거나 필터 최소길이를 2자로 맞춰 일관화 (0110·0111 동일 패턴) |
| S-FR01-0110-001 | 카피 | 하 | 게시판명 초기값이 `'자유게시판'` 하드코딩(§817 "어드민에서 설정한 자유게시판명"). API 응답 전/mock은 고정 문자열 | §817 자유게시판명=어드민 설정 | 서버 boardName 우선(현재 res.boardName 반영됨) — mock 상수만 명시 주석 유지, blocker 아님 |
| S-FR01-0109-001 | 카피 | 하 | 작성자 유형 배지 색상 분기가 admin/비admin 2색(§786은 관리자/강사/학습자 3색 상이). 공지=어드민 작성이라 실사용 admin 고정이나 강사/학습자 유형 유입 시 회색 단색 | §786 유형별 색상 상이 | 자유게시판(line139)처럼 3색 분기 재사용 권장(일관성). 공지 특성상 우선순위 낮음 |
| S-FR01-0110-003 | 상태 | 하 | 글쓰기 권한(`canWrite=isLoggedIn&&isLearner`)이 SoT "비회원 제외 모든 회원"보다 좁음. 다만 어드민 on/off·강사 정책이 `[개발-계약대기]`로 명시 | §828 비회원 제외 모든 회원(어드민 on 전제) | 서버 권한 계약 확정 시 게이팅 교체(현 주석에 근거 명시됨) — 계약대기, blocker 아님 |

- 심각도 **상(blocker) 0건 · 중 0건 · 하 4건**.
- 하 4건 모두 mock/계약대기 또는 경미한 일관성 항목 — 종료조건 충족.

---

## 9. 종합 판정

### 판정: **GO** ✅

- 커버리지 7/7 · 누락·추가 0 · 유형별 정합(공지 읽기전용 / 자유 비밀글·비밀댓글 / FAQ 단일확장 아코디언) 전부 충족.
- 비밀글 권한 축(목록/상세/댓글) 논리 정합 · 진입차단·대체문구 카피 정본 일치.
- **premium(R1~3) 회귀 0건** — useBoard/CommentThread 옵셔널 확장이 default premium 동작 보존.
- typecheck 게이트: 게시판 스코프 **0 error**(baseline 21건은 auth/mypage 선재·범위 밖).
- 05 6건·컨펌 AppModal·토스트 일원화·얼럿 미사용 준수.
- **blocker 0건** → 종료조건 충족.

### 우선 보완(비차단 · 하)
1. 검색 EmptyState variant 판정(`>=2`)과 필터 최소길이 불일치 통일 — 3화면 공통(0109·0110·0111).
2. 공지 작성자 배지 3색 분기 재사용(일관성).
3. `[개발-계약대기]` 항목(등급권한·FAQ 엔드포인트·첨부 R2·운영등급 서버판정) — API 계약 확정 시 mock→실연동 교체(정당, 판정 무관).

> 정본·핸드오프·구현 파일 무수정. 본 결함표만 신규 작성.
