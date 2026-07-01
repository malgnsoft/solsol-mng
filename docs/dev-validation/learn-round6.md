# FR01 학습 4화면 검증 — learn-round6

- 대상: **강의실(0301-201)·대시보드(202)·라이브강의실(203)·수료증(103)** + _pu(201-P01·202-P01·103-P01)
- 검증 정본: `docs/validation/01_customer-front.md`(L1114~1311), `04_정책요약`(LRN-08/09/10/11/17/18/19/20, EXC-01), `05_정책설계서`
- 절차: `docs/DEV_VALIDATION_PROCESS.md` (9축 + 05 6건 + typecheck)
- 검증자: QA / 일시: 2026-07-01 (KST)
- **어떤 대상 파일도 수정하지 않음.** 본 파일만 신규 작성.

---

## 1. 커버리지 (SoT 화면ID ↔ 구현)

| 화면ID | SoT | 구현 파일 | 상태 |
|---|---|---|---|
| S-FR01-0301-201 강의실 | L1114 | `pages/mypage/classroom/[id].vue` (+`layouts/classroom.vue`) | ⭕ 있음 |
| └ 201-P01 영상 전체보기 | L1177 | `components/learn/FullscreenPlayerModal.vue` | ⭕ 있음 |
| S-FR01-0301-202 대시보드 | L1187 | `pages/mypage/classroom/[id]/dashboard.vue` | ⭕ 있음 |
| └ 202-P01 후기작성 모달 | L1216 | `components/learn/ReviewWriteModal.vue` | ⭕ 있음 |
| S-FR01-0301-203 라이브 강의실 | L1226 | `pages/mypage/live/[id].vue` | ⭕ 있음 |
| S-FR01-0301-103 수료증 | L1267 | `pages/mypage/certificate.vue` | ⭕ 있음 |
| └ 103-P01 수료증 모달 | L1303 | `components/learn/CertificateModal.vue` | ⭕ 있음 |

- **누락 0 / 추가 0.** 지원 컴포넌트(WecandeoPlayer·LearnCurriculum·AiTutorPanel·ResourceList·YoutubeLivePlayer·LiveChatPanel·CertificateCard) + composable(useLearning·useCertificate) 모두 존재.
- 화면ID 표기: 각 파일 상단 주석·템플릿 첫 노드에 화면ID 명시 — 추적키 1:1 매핑 확인.

---

## 2. 결함표 (심각도 상=blocker / 중=major / 하=minor)

| # | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|---|---|---|---|---|---|---|
| D1 | 0301-103 | 카피(빈상태) | **중** | 수료증 0건 빈 상태가 `EmptyState variant="product"` → 렌더 문구 "아직 비어있어요 / 조금만 기다려 주세요. 알찬 상품으로 채워질 예정이에요." 노출. SoT 확정 문구와 불일치. | 01 L1300 (p268): "아직 발급 가능한 수료증이 없어요 / 첫 수료증을 만들어 보세요." | `EmptyState`에 `certificate` variant 추가 후 해당 문구 매핑(`common/EmptyState.vue:11,20` — 정본 SoT는 검증폴더 밖 수정). **담당: frontend-developer(한데관님)** |
| D2 | 0301-202 | 카피(빈상태) | 하 | 후기 0건 빈 상태 `EmptyState variant="review"` → 타이틀 "아직 작성된 후기가 없어요". SoT 후기 빈 문구는 "아직 후기가 등록되지 않은 상품입니다."(타이틀 뉘앙스 상이, desc는 일치). | 01 L1212 (202-7) | 문구 정합 검토 — `review` variant는 course 후기 등 공유 사용 중이라 영향 범위 확인 후 조정 판단. 낮은 우선순위. |
| D3 | 0301-103 | 인터랙션(필터 BS) | 하 | MO 필터/정렬은 SoT상 **BS(바텀시트) + [확인]**(L1297) 이나, 구현은 PC/MO 공통 inline `<select>`(자동 재조회). 기능 동치이나 MO 전용 BS 패턴 미구현. | 01 L1297 (6 MO), TYPE "+필터 BS·+정렬 BS" | 기능상 필터/정렬 동작은 충족(동치). MO BS는 디자인 정합 항목 — 후속 라운드 반영 권고. blocker 아님. |
| D4 | 0301-103 | 상태(정렬 안정성) | 하 | 발급일 동일 값 다수일 때 `localeCompare(completedAt)`만으로 2차 정렬키 없음 → 동일 발급일 항목 순서 비결정적 가능. mock은 값 분산이라 미노출. | 01 L1290 (2 정렬) | 2차 정렬키(id 등) 추가 권고. 실데이터 영향 낮음. |

> **상(blocker) 0건.**

---

## 3. 핵심 정합 판정

### 3-1. 순차잠금 (LRN-08 · 201 4.1.b) — ⭕
- `LearnCurriculum.onLectureClick`: `lecture.locked` 시 `toast.info(LOCK_MESSAGE)`로 **차단**(emit select 안 함). **얼럿 미사용**. `classroom/[id].vue:87~98`.
- 토스트 문구 = "이전 강의를 완료해야 다음 강의를 수강할 수 있습니다" — **정본 5-a(p243) 일치**(`LearnCurriculum.vue:34`).
- `hasNext`: 다음 강의가 `locked`면 `false` → [다음] 버튼 비활성(`classroom/[id].vue:47~51`). 첫 강의 [이전] 비활성(`hasPrev`). **버튼 비활성 + 클릭차단 이중 방어** 정합.
- `recomputeLocks`: 완료 반영 시 `restrictSkip && !prevAllCompleted && status∉{completed,in_progress}`로 재계산 — 완료 시 **다음 강의 잠금 해제** 동작 검증(로직 추적 OK). `mockClassroomSections`의 초기 잠금(prevAllCompleted 전파)도 정합.

### 3-2. 진도율 실시간 반영 — ⭕
- 커리큘럼 상단 4-1 `{완료}/{전체}` + 4-2 `%`+프로그래스 바(`LearnCurriculum.vue:70~81`, `role=progressbar`+`aria-valuenow`).
- `onProgress(completed)` → 로컬 status='completed' + `recomputeLocks()`에서 `progress` 재계산 → 실시간 반영(`classroom/[id].vue:94~114`).
- 대시보드 4-2 상세: 전체/시청완료/시청미완료(`notCompleted = total-completed`) 3행 정합(202 L1206).

### 3-3. 조건부 노출 (LRN-18 · 5.1/5.2) — ⭕
- AI튜터 탭: `showAiTab = data.aiTutorEnabled`. false면 **탭·MO탭바·콘텐츠 전부 숨김**(`classroom/[id].vue:54,194,222,231`).
- 자료실 탭: `showResourceTab = resources.length > 0`. 0건이면 탭 숨김(빈 탭 없음, L1171 정합).
- 라이브(203) 자료실도 동일 조건부(`live/[id].vue:25`).

### 3-4. 수료 3상태 (202 6 / LRN-19) — ⭕
- `certificate.state`: `none`(6-3 미제공 문구) / `unissued`(6-1 [수료증 보기] disabled) / `issued`(6-2 활성 + `formatDateTime` 수료완료 표기 + 모달). `dashboard.vue:129~155`.
- issued 분기에서만 `CertificateModal`에 `certificateId` 전달 — 정합.

### 3-5. 후기 최초 1회 (LRN-20 · 202-9) — ⭕
- `hasWrittenReview` true면 버튼 disabled + 라벨 "후기 작성 완료", `openReviewModal` 가드(`dashboard.vue:62~65,167~174`).
- 등록 후 `onReviewSubmitted`에서 `hasWrittenReview=true` 세팅 → 재작성 차단. `ReviewWriteModal`은 `useProducts.createReview` **재사용**(중복 로직 없음), 토스트 "상품 후기가 등록되었습니다"(정본 9-a 일치).

### 3-6. 라이브 채팅 폴링 + cleanup (203 4.1) — ⭕ (핵심 점검 통과)
- `LiveChatPanel`: `onMounted`에서 `setInterval(refresh, 10000)`(pollTimer) + `setInterval(tick,1000)`(카운터) 2개 등록.
- **`onUnmounted`에서 두 타이머 모두 `clearInterval` + null 처리**(`LiveChatPanel.vue:78~83`). **메모리 누수/중복 폴링 없음.**
- 최신 하단 배치·`scrollToBottom`·오전/오후 HH:MM 표기(`chatTime`)·내(우)/상대(좌) 말풍선·placeholder "궁금한 점을 실시간으로 질문해 보세요!" 전부 정본 정합.
- 참고: `WecandeoPlayer`(플레이어 tick)·`FullscreenPlayerModal`(body overflow)도 `onUnmounted` cleanup 확인 — 리소스 누수 0.

### 3-7. 수료증(103) — ⭕
- 카드 = **강의 단위**, mock은 수료완료분(그리드 3×3). `visibleCount` 9씩 [더보기](L1296 정합).
- 필터(상품유형/발급상태) + 정렬(발급일 최신순 디폴트) + 검색(2자 이상 가드, `toast.info`) + 초기화 — L1290~1295 정합.
- 모달 103-P01: 이름/상품명/수료번호/교육시간/시작일/수료일/로고 7필드(L1306) + 8-1 [PDF 다운로드](mock 토스트) + AppModal Esc/✕/외부클릭(C-3).
- 개인정보: 이름 실명 노출(수료 증빙 목적, 본인 발급분 — L1310 정합). **마스킹 예외 정당.**

---

## 4. 9축 요약

| 축 | 판정 | 근거 |
|---|---|---|
| 존재 | ⭕ | 4화면 + 3 _pu + 지원 컴포넌트/composable 전부 존재 |
| IA/라우팅 | ⭕ | `products.vue` `goClassroom→/mypage/classroom/:id`(121) · `joinLive→/mypage/live/:id`(124) 도달. 대시보드↔강의실 상호 링크. 화상강의는 외부 토스트(EXC 정합). 파일 라우팅 `[id].vue`·`[id]/dashboard.vue` 정상 |
| 상태(빈/로딩/에러/잠금) | 🔺 | 로딩("불러오는 중…")·잠금(토스트)·후기/수료증 빈상태 모두 구현. **단 수료증 빈상태 카피 불일치(D1)** |
| 공통컴포넌트 | ⭕ | AppModal(모달/BS)·EmptyState·useAppToast 재사용. ResourceList는 201/203 공용. 자체 얼럿 미사용 |
| 카피 | 🔺 | 순차잠금 5-a·후기 9-a 문구 일치. **수료증 빈상태(D1 중)·후기 빈상태 타이틀(D2 하)** 불일치 |
| 디자인토큰 | ⭕ | `#7954C6` 등 하드코딩 **0건**. 전부 `var(--color-primary*)` 토큰 사용. 상태색(#22B573 완료·#FFB800 별점)은 의미색으로 허용 범위 |
| 반응형 | 🔺 | PC 2단(좌 플레이어+우 380px 탭)·MO 하단 sticky 탭바+BS 구현. **MO 필터 BS 미구현(D3 하)** — 기능 동치 |
| 인터랙션 | ⭕ | 탭 전환·도넛(stroke-dashoffset transition)·채팅 폴링/전송·전체보기 모달·별점·플레이어 컨트롤(↺10/▶/10↻) 정합 |

---

## 5. 회귀 (라운드1~5) — ⭕ 회귀 0

- **git status: round6 산출물 전부 untracked(신규)** — `products.vue`·`mypage.vue`·`useProducts.ts`는 변경 목록에 **없음**(직전 커밋 fdab4ed 소속, 무수정 확인).
- `classroom.vue` 레이아웃 신설은 **독립 레이아웃**(사이드바 없는 학습 전용). `mypage.vue` 미오염 — 주석에 "mypage.vue 무수정" 명시, 실제 미변경.
- `ReviewWriteModal`·`dashboard.vue`는 기존 `useProducts.createReview`/타입을 **import 재사용**(중복정의 금지 준수), 원본 무수정.
- 기존 경로(`/mypage/products` 등) 정상 — 신규 라우트는 하위 경로 추가만.

---

## 6. 05 확정 6건 — 해당 항목 위반 0

- 학습 4화면은 6건(닉네임 2~15·무료체험 미운영·RBAC·유효시간·비번문구·쿠폰 정액) 중 **직접 해당 규칙 없음**. 위반 트리거 없음(닉네임 입력·결제·체험 UI 미등장). ⭕
- 후기 프로필 닉네임은 `useAuth().user.nickname` 표시만(입력 검증 아님).

## 7. typecheck — ⭕ 0건

```
cd /Users/dotype/Projects/solsol && pnpm exec nuxt prepare; pnpm typecheck
→ exit=0, error TS 건수: 0, learn 관련 에러: 0
```
- 잔존 WARN 2건(`BoardAuthorType` duplicated import — `useBoard`/`boardFormat`)은 **round6 무관 기존(baseline)** 경고. 신규 도입 오류 없음.
- 타입 계약 정합: `ProductDetail.hasCertificate/liveStatus/reviews`, `LiveStatus='live'|'upcoming'|'ended'`(YoutubeLivePlayer union 일치), `createReview(id,{rating,content})` 시그니처 일치.

## 8. [개발-계약대기] mock (정당 — blocker 아님, 기록)

- 위캔디오 VOD 플레이어(placeholder+tick 시뮬)·YouTube Live iframe(mock VIDEO_ID)·AI튜터 응답·라이브 채팅 폴링(mock seed)·PDF 다운로드·자료실 ZIP/개별 다운로드 = 전부 `[개발-계약대기]` mock 폴백. 06_API계약 연동 시 useLearning/useCertificate 단일 지점 전환 구조. **결함 아님.**

---

## 판정: **GO (조건부)**

- 종료조건 **상(blocker) 0건 충족** → GO.
- typecheck 0 · 회귀 0 · 순차잠금/진도/조건부/채팅cleanup/수료증 3상태/후기 최초1회 핵심 정합 전부 통과.

### 우선 보완 (배포 전 권고)
1. **D1(중)** — 수료증 빈 상태 카피 정본 문구("아직 발급 가능한 수료증이 없어요 / 첫 수료증을 만들어 보세요.")로 교정. `EmptyState`에 `certificate` variant 추가. **담당: 한데관님(frontend-developer).**
2. D2/D3/D4(하) — 후기 빈상태 타이틀·MO 필터 BS·정렬 2차키. 후속 라운드 반영 가능.

> 결함 D1~D4는 검증자 직접 수정하지 않음 — frontend-developer에 재현정보와 함께 위임.
