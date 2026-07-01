# AD01 신규 앱 — Phase 1a 사용자>학습자 검증 라운드

> 검증 정본(`docs/validation/`) 읽기 전용. 본 결과는 밖(dev-validation)에 기록. Phase 0: [AD01-app-phase0-round1.md](AD01-app-phase0-round1.md).

- **일시**: 2026-07-01 (KST)
- **대상**: `solsol-admin/` 신규 앱 — 사용자>학습자 도메인. 목업(`solsol-admin/mockup/`) 디자인 기준선(무수정).
- **범위(화면ID)**: S-AD01-0101-001(목록)·0101-002(상세 6탭)·`_pu01~04` 모달 4종.
- **수행**: 총괄 오케스트레이션 — 구현 admin-developer, 게이트 qa·privacy. SoT·목업·검증문서 무수정.

## 종합 판정: ⭕ 게이트 통과 (qa·privacy 전원 blocker 0) → 결함 보완 완료

## A. 커버리지 (누락 0)
| 화면ID | 구현 | 화면ID주석 |
|---|---|:--:|
| S-AD01-0101-001 목록 | `learners/index.vue` | ⭕ |
| S-AD01-0101-002 상세(기본/학습/구매/활동/발송/쿠폰 6탭) | `learners/[id].vue` | ⭕ |
| _pu01 수강강좌 / _pu02 구독관리 / _pu03 수료변경 / _pu04 다운로드 | `Learner{Courses,Subscriptions,Completion,Downloads}Modal.vue` | ⭕ |

## B. 정책 반영 (전건 충족)
- **AUTH-14 상태머신**: 활성↔중지↔탈퇴 · 단방향 바인딩으로 스테일 select 없음.
- **탈퇴차단(P-AD-18/CMP-06)**: 만료강좌 보유 차단 · 일괄탈퇴 1명씩 · 비가역 최종 컨펌(danger+경고).
- **LRN-23(P-AD-20)**: 수료 사유 10자↑ 필수 · '수료' 후 잠금(isLocked).
- **CMP-01 마스킹**: 목록·상세·모달 이름/이메일/휴대폰 `mask.ts` 적용(타 회원 조회=상시 마스킹). privacy 비마스킹 노출 지점 **0**.

## C. 신설 공용 컴포넌트 (이후 도메인 재사용)
`app/components/common/App{DataTable,StatusBadge,SearchFilter,Pagination,Modal,Confirm}.vue` + `app/utils/mask.ts`(maskName/maskEmail/maskPhone) + `app/types/user.ts`.

## D. 결함 보완 (게이트 후 마감)
| 심각도 | 결함 | 조치 |
|:--:|---|---|
| 중 | AppModal 동적 Tailwind 클래스 → 모달 폭 prop 무효 | 인라인 `:style` 폭 바인딩으로 전환(공용 컴포넌트, 전파 차단). 빌드 산출물서 폭 반영 확인 |
| 하 | KPI '이번 달 신규' 월 하드코딩 | KST 현재 연월 동적 산출 |
| 하 | 정렬 드롭다운 미구현(02 §4) | 구매/진도율/멤버십/가입일 정렬 추가 |
| 하 | 접근성 aria 누락 | 상태변경·select·체크박스 aria-label 부여 |

→ 보완 후 `pnpm build` 재성공(에러 0).

## E. Phase 1 이관(하, 백엔드 연동 시)
카드/계좌 **번호** 노출 시 부분마스킹(현재 이 도메인엔 번호 필드 없음) · 서버검색 전환 시 쿼리 로깅 PII 점검 · maskPhone 10자리 지역번호 분기 정밀화 · 목→`useApi` 실연동.
