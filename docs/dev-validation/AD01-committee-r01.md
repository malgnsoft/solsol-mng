# AD01 검증위원회 T2 — 크리에이터 관리자단 화면 트랙 (round1)

| 항목 | 내용 |
|------|------|
| 위원 | T2 (QA · 화면 트랙) |
| 대상 | `solsol-admin` (실연동 단계) `/Users/dotype/Projects/solsol-admin/app` |
| SoT | `docs/validation/00_화면목록.md`(AD01) · `02_customer-admin.md` · `04_정책요약.md` · `05_정책설계서.md` · `00_검증가이드.md` |
| 방법 | 화면ID 커버리지 전수 + 9축 도메인 표본 + 05 확정 6건 + M-4 + RBAC 노출 |
| 정적검증 | `pnpm build` (nuxt build) **EXIT=0** (2026-07-02, 무해 경고: `[cloudflare] Node.js compatibility is not enabled` = 인프라 설정, 코드결함 아님) |
| 스코프 | 정본·앱 무수정(열람·빌드만). 본 파일만 기록. |

---

## 1. 화면ID 커버리지 (SoT 본화면 → 구현 페이지)

SoT §3.2 AD01 본화면 전수 대조 결과 **누락 0 / 미매핑 0**. 대표 매핑(발췌):

| SoT 화면ID | 구현 페이지 | 상태 |
|-----------|------------|------|
| S-AD01-0100-001 대시보드 | `admin/index.vue` | 있음 |
| S-AD01-0901~0903 통계 3종 | `admin/stats/{learners,sales,contents}.vue` | 있음 |
| S-AD01-0301~0303 로그인/비번/가입 | `auth/{login,forgot-password,reset-password,register}.vue` | 있음 |
| S-AD01-9002-001 알림센터 | `admin/notifications/index.vue` | 있음 |
| S-AD01-9003~9005 내정보/문의/크레딧 | `admin/{profile,inquiries,credits}/…` | 있음 |
| S-AD01-0101~0103 사용자(학습자/강사/관리자) 목록·상세 | `admin/users/{learners,instructors,admins}/{index,[id]}.vue` | 있음 |
| S-AD01-0201~0208 상품 7유형 목록/생성/상세 | `admin/products/{courses,live,video,digital,packages,membership,community}/…` | 있음 |
| S-AD01-0301-001~005 콘텐츠 | `admin/contents/{library,folders,upload,[id],[id]/subtitle}` | 있음 |
| S-AD01-0401~0403 판매(주문/쿠폰/환불) | `admin/sales/{orders,coupons,refunds}/…` | 있음 |
| S-AD01-0501~0502 운영(게시판/팝업) | `admin/operations/{boards,popups}/…` | 있음 |
| S-AD01-0601~0607 마케팅 7메뉴 | `admin/marketing/{campaigns,history,groups,templates,surveys,tools,landing}/…` | 있음 |
| S-AD01-0701~0706 사이트 디자인 | `admin/site/{info,menus,pages,meta,seo,footer}/…` | 있음 |
| S-AD01-1001~1003 정산 | `admin/settlement/{info,history,tax}/…` | 있음 |
| S-AD01-1101~1105 설정 | `admin/settings/{basic,player,certificate,notice,notification}/…` | 있음 |

**관찰(결함 아님)**: 페이지 생성/수정(S-AD01-0703-002 HTML 편집)과 페이지 빌더(S-AD01-0703-003)는 `admin/site/pages/[id]/edit.vue` + 빌더 컴포넌트(`components/admin/site/builder/`)로 통합 라우팅. 라우트 존재하므로 커버리지 충족.

---

## 2. 05 확정 6건 + M-4 대조

| 항목 | 확정값(SoT) | 구현 근거 | 판정 |
|------|------------|----------|------|
| C-1 닉네임 2~15자 | 전 영역 2~15자 | `auth/register.vue:82,110,388`(maxlength 15·2~15 검증) | ⭕ |
| M-1 무료체험 14일 미운영 | 즉시결제 유지·체험 UI 없음 | 가입/결제 flow에 14일 체험 UI 없음(register 즉시가입) | ⭕ |
| M-2 강사/서브강사 RBAC 화이트리스트 | 메뉴 화이트리스트+데이터스코프 | `utils/rbacPreset.ts`(preset owner/instructor/sub) · `stores/auth.ts:hasMenu` · `AdminSidebar.vue:361 visibleMenus` | 🔺 (§3 D01) |
| C-2 유효시간 | 가입 10분/재설정 30분/초대 48h | `register.vue:340 CODE_TTL=600` · `forgot-password.vue:81 유효시간 30분`·`10회 제한` | ⭕ |
| C-3 비번 문구 | 영문·숫자·특수문자 3종 8~16자 | `register.vue:205,233,434` | ⭕ |
| C-4 쿠폰 정액 only | 정액만·정률 숨김/비활성 | `sales/coupons/create.vue:51-62`(정률 disabled)·`222 정액 가드` | ⭕ |
| M-4 알림센터 10종 | N-01~N-10 종류별 카드+필터 | `types/system.ts:31-40 NOTIFICATION_CATALOG(10종)` · `notifications/index.vue:19-34`(카드+필터)·목데이터 10코드 전부 등장 | ⭕ |
| C-5 피드백 토스트 통일 | 단방향 토스트/양방향만 컨펌 | toast 82페이지 사용·`common/AppConfirm.vue`만(단방향 window.alert/MPU 잔존 0) | ⭕ |
| C-6 본인화면 마스킹 예외 | 타회원=마스킹, 계좌/카드=부분마스킹 | `utils/mask.ts` 전체 + 학습자/강사/주문/환불 상세 마스킹 적용, 계좌 `maskAccount`(instructors/[id]:333) | ⭕ |

---

## 3. 결함표

| 결함ID | 화면ID | 검증축 | 심각도 | 현상 | SoT근거 | 제안 |
|--------|--------|--------|:--:|------|---------|------|
| AD01-cttee-r01-D01 | (전 admin 라우트) | RBAC/인가 | **상** | 라우트 미들웨어가 `isAuthenticated`만 검사하고 **메뉴 권한(hasMenu)을 검사하지 않음**. 강사/서브강사가 차단 메뉴(예: `/admin/marketing/campaigns`·`/admin/site/info`·`/admin/users/learners`·`/admin/settlement/history`)를 **직접 URL로 진입하면 페이지 셸이 그대로 렌더**됨. EXC-06(접근 차단) 리다이렉트 없음. LNB는 `hasMenu`로 올바르게 숨김되나(메뉴 노출 결함 아님), 직접 URL 벡터가 열려 있음. `restricted/index.vue`는 결제유예(S-AD01-9001-001) 전용이며 RBAC 차단용 아님. | 05 M-2 결정 규칙5 "권한 없는 진입 차단: 직접 URL 접근 시 EXC-06 적용"(05 L148) — 05 확정 6건 중 M-2 위반 | `middleware/auth.global.ts`에 메뉴 권한 게이트 추가(라우트 prefix→menuKey 매핑, `hasMenu` false 시 `/admin/restricted` 또는 EXC-06 리다이렉트). ※서버 403이 데이터 유출은 차단하나 화면 게이트/EXC-06 부재가 SoT 위반 |
| AD01-cttee-r01-D02 | C-1 LNB (AdminSidebar) | 상태/미연동 | 하 | LNB에 하드코딩 스텁값 노출: 1:1문의 미처리 배지 `inquiryCount=3`(L230), 보유 크레딧 `credit=120000`(L233). 둘 다 `// TODO: API 연동` 주석 상태로 실 데이터 미연동 — 전 화면 상단에 고정 노출되는 값이라 실연동 단계에서 오정보 표기. | 실연동 단계 기준(조회형 실 API 전환 진행) · 화면상 상시 노출 | 세션/집계 API 연동 또는 로딩 스켈레톤 처리. 실연동 완료 전까지 잠정 스텁임을 팀 인지 |
| AD01-cttee-r01-D03 | S-AD01-9002-001 알림센터 | 미연동 | 하 | 알림 목록이 `utils/notificationMock.ts` 정적 12건 기반(실 알림 API 미연동). ※카탈로그 10종(NOTIFICATION_CATALOG)은 정적이 정상(M-4 명세). 목록만 미연동. | M-4는 카탈로그 정적 정상 / 목록 실연동은 stage 잔여 | 알림 목록·읽음처리 실 API 연동(정보 제공 — stage 정합) |

---

## 4. 9축 도메인 표본 점검 요약

- **존재/IA/라우팅**: 11개 1depth·서브메뉴 경로 LNB 정의와 페이지 라우트 일치. active 하이라이트(`isActive`/`isMenuActive`) 정상.
- **상태**: 알림센터 빈 상태(`visibleList.length===0`)·더보기·자동읽음(`onBeforeRouteLeave`) 구현. 목록화면 KPI/필터/일괄 존재.
- **공통 컴포넌트**: `common/{AppConfirm,AppDataTable,AppModal,AppPagination,AppSearchFilter,AppStatusBadge}` 일원 사용.
- **마스킹**: 타회원 조회(학습자·강사·주문·환불 목록/상세)에 `maskName/Email/Phone/Nickname` 적용, 계좌 `maskAccount`(뒤4자리). C-6 정합.
- **카피**: 정책 문구(닉네임 2~15·비번 3종 8~16·유효시간·정액 only) SoT 일치. (PNG 픽셀 정밀 대조는 미수행 — 문구 레벨만.)
- **토큰/반응형/인터랙션**: 인라인 style 토큰 다수, grid 5열 카드 등. (반응형 390/1440 실브라우저 점검은 본 라운드 정적 코드검증 범위 밖 — 미실행.)

---

## 5. 종합 판정

- **심각도별 건수**: 상 1 · 중 0 · 하 2
- **blocker(상) 목록**: `AD01-cttee-r01-D01` (RBAC 직접 URL 접근 미차단 — 05 M-2 규칙5 위반)
- **커버리지**: 본화면 누락 0 · 미매핑 0
- **정적검증**: `pnpm build` EXIT=0
- **트랙 판정**: **NO-GO** (blocker 1건 — D01 해소 후 재검증 필요)

> 미실행 명시: 실브라우저 반응형(390/1440)·PNG 픽셀 카피 정밀대조·역할별 세션 실런타임 RBAC 재현은 본 정적 라운드에서 미실행. D01은 코드(미들웨어·사이드바) 정적 근거로 판정.
