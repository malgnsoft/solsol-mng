# AD01 신규 앱 — Phase 1c 상품>일반강의 검증 라운드

> 검증 정본(`docs/validation/`) 읽기 전용. 이전: [phase0](AD01-app-phase0-round1.md)·[1a 학습자](AD01-app-phase1a-learners.md)·[1b 강사·관리자](AD01-app-phase1b-staff.md).

- **일시**: 2026-07-01 (KST)
- **대상**: `solsol-admin/` 신규 앱 — 상품>일반강의(상품 7유형 **기준형**). 목업 디자인 기준선(무수정).
- **범위(화면ID)**: S-AD01-0201-001(목록)·0202-001(카테고리)·0201-002~005(생성 4스텝)·0201-006(상세 6탭)·`_pu` 11종.
- **수행**: 총괄 오케스트레이션 — 구현 admin-developer, 게이트 qa·privacy.

## 종합 판정: ⭕ 게이트 통과 (보완 후) — 최초 privacy blocker 2건 → 해소 확인

## A. 커버리지 (누락 0 / 유령 0)
목록·카테고리·생성 4스텝(단일 위저드)·상세 6탭 + `_pu` 11종(카테고리선택·복사·이동·상품정렬·썸네일·카테고리라디오·대표/서브강사·콘텐츠선택·수료증미리보기·학습기간) 전부 구현·화면ID 주석.

## B. 정책 반영 (qa 전건 정합)
LRN-02(신규 기본 비공개·공개3/판매2) · LRN-03(카테고리 2단계·1상품1카테고리 라디오) · LRN-04(콘텐츠 선행등록) · LRN-05(섹션+차시·번호자동) · LRN-08(자유/순차) · LRN-09(진도율 10~100·기본80) · LRN-22(가격변경 신규부터) · LRN-23(학습기간 ≤365·수료사유 10자↑) · LRN-20(후기답글 어드민만).

## C. 재사용 상품 컴포넌트 (이후 6유형 재사용 확립)
`app/components/admin/products/{ProductStatusBadge,CategoryTree,ContentSelectModal,ThumbnailCropModal,InstructorPickModal,ProductStepIndicator}.vue` + `app/types/product.ts` + `app/utils/productMock.ts`.

## D. 게이트 결과 & 보완
### privacy — 최초 blocker(상) 2건 → 게이트 미통과 → 해소
| 심각도 | 결함 | 조치 |
|:--:|---|---|
| **상** | 상세 학습자 탭 **닉네임 원본 노출** (06 §0: 타인조회 시 닉네임도 마스킹) | `maskNickname` 유틸 신설 + 적용 |
| **상** | 후기 작성자(닉네임)에 `maskName` 오적용 | `maskNickname`으로 교정 |
- **소급 감사**: 사용자 도메인(학습자·강사·관리자) 목록/상세의 닉네임 표시 6파일에도 `maskNickname` 적용(Phase 1a/1b가 놓친 일관성 갭 마감). **grep 검증: 운영자 화면 비마스킹 닉네임 잔존 0**(register.vue의 닉네임은 가입 본인 입력=마스킹 비대상, 정상).

### qa — blocker 0 (중2·하3 보완)
| 심각도 | 결함 | 조치 |
|:--:|---|---|
| 중 | 목록 강사·모집일정 컬럼 누락 | 컬럼 2개 추가(+ recruitSchedule 목값) |
| 중 | 카테고리 순서변경 **죽은 UI**(orderDirty 미배선) | ↑↓ 이동 버튼 + orderDirty→저장바 실동작 배선 |
| 하 | 상세 "등록시 비공개" 안내 무조건 노출 | 비공개 상품일 때만 노출 |
| 하 | 학습기간 종료일 과거 지정 가능 | date `min`=오늘(KST) 방어 |

→ 보완 후 `pnpm build` 재성공(에러 0).

## E. 잔여(하, 이관)
커리큘럼 섹션/차시 드래그 재정렬(목 스텁, 주석 명시) · 실제 DnD·리치에디터·부록 첨부는 API/라이브러리 연동 시.
