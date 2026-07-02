# 2026-07-01 — 인증 슬라이스 프론트 커밋(보류 해제) + 배포 상태 점검

> **한 줄 요약** — 06-30 인증 슬라이스의 **프론트 신규 앱(`solsol/`)을 커밋·푸시**(보존, 배포는 실연동 후로 보류). 관리 허브(solsol-mng)·브랜드/관리자 목업 레포는 모두 커밋·푸시·배포 완료 상태 확인.

## 1. 배포 상태 점검

- **solsol-mng**(관리 허브): 미커밋 0·미푸시 0 — 전 작업(화면 디자인검수·다중코멘트·WBS 필터·현행화 등) 반영 완료.
- **solsol-brand**(v5)·**solsol-admin**(AD01): 완료.
- **solsol**: 인증 프론트 신규 앱 미커밋 8건 확인.

## 2. 인증 프론트 커밋 (WIP, 커밋·푸시만 — 배포 보류)

- `malgnsoft/solsol`(`d19d911`) — Nuxt 3 신규 앱(레포 루트, `mockup/` 동결과 별개): 로그인·이메일 가입·약관 게이트·OAuth 콜백·프로필/탈퇴 + `useAuth`/`useApi`/미들웨어. 빌드 GREEN. 30파일.
- **배포 보류(사용자 선택 1번)**: mock 전용 → 소셜 OAuth 키·프론트↔API 실연동·인증 QA 후 배포. §6 회원 모델 변경(소셜 비정규화·login_id 분리)으로 **인증 코드 재작성 필요**.

## 3. /screens 사용자단(FR01) 목업 링크 복구 + 근본 수정 (배포)

- **증상**: `/screens`에서 사용자단(FR01) "목업" 링크가 사라짐. 목업 사이트(`solsol-mockup.pages.dev`)는 정상 — `/screens` 표시 문제.
- **원인**: 디자인 검수(`review`) 등 한 필드 토글 시 D1 `screen_status` 신규 행이 **하드코딩 기본값**(publish=false·mockupUrl='')으로 생성돼, GET 머지에서 정적 목록의 publish=true·목업 URL을 덮음(FR01 7행 영향).
- **수정**(`cf5ecd6`): `[id].patch.ts`가 정적 화면목록 값을 base(defaults)로 시드 + `index.get.ts` 머지에 URL 정적 폴백. 라이브 D1 FR01 7행을 정적값(publish=1·mockup_url)으로 복구(`publish=0` 잔여 0). → Pages 배포.

## 4. WBS 스파이크(1차 개발) 단계 신설 — 8단계 재편 (배포)

- 목업(Step 4) **다음에 Step 5 「스파이크(1차 개발)」 신설**, 기존 설계·구현·운영을 **6·7·8**로 재번호. 전체 진척 제외 스텝은 Step 8(운영·계약).
- Step 5 항목 5건: 데이터모델·멀티테넌트 스파이크(90%) / 인증·회원 슬라이스(35%) / 핵심 도메인 API 골격(10%) / 결제·정산 PoC(0%) / 강의 플레이어·진도 PoC(0%). 가중치 스파이크 7.
- `wbsData.ts`·`seed.sql`·라이브 D1(`sort+10` 후 step 재번호·스파이크 5행 INSERT) 동기화. `wbs.vue`·`index.vue` 스텝 참조(STEP_OPTIONS 8·STEP_EMOJI ⚡·전체진척 제외 8·"8단계") 갱신. 커밋 `8cf245a` → Pages 배포.

## 5. WBS 스파이크를 설계–구현 사이로 이동 + 이번주 완료 일정 (배포)

- 스파이크(1차 개발)를 **Step 5 → Step 6**(설계와 구현 사이)로 이동, 설계를 Step 5로. 가중치(설계 9·스파이크 7)·이모지(5=📐·6=⚡) 동반 교체.
- 스파이크 5항목 **종료일을 이번주(KST 2026-06-29~07-05) 안으로 압축** — 전부 `end ≤ 2026-07-05`(데이터모델 07-04, 나머지 07-05).
- `wbsData.ts`·`seed.sql`·라이브 D1(step 5↔6 교체·sort 213–220↔221–225 재배치·스파이크 날짜 UPDATE) 동기화. 커밋 `a7bad92` → Pages 배포.

## 6. 에이전트팀 글로벌 일원화 (배포)

- 쏠쏠 **프로젝트 전용 에이전트팀 폐지 → 글로벌 에이전트팀(`~/.claude/agents/`)만 사용**. 로컬 정의는 원래 없었고(문서만 존재), 조직도에 글로벌에 없는 가상 역할(`chief-of-staff`·`service-planner`·`publisher`·`devops-engineer`·`instructional-designer`·`legal-reviewer`)이 섞여 있던 것을 실제 글로벌 정의(22개)와 1:1 정렬.
- `docs/AGENT_TEAM.md` 재작성(글로벌 팀 사용·레포 적용만 기술·로컬 정의 금지), `CLAUDE.md`(에이전트팀 안내 2곳·참모 제거), `docs/DEV_VALIDATION_PROCESS.md`(조율 역할을 `plan/dev/qa/ops-lead` 글로벌 슬러그로) 정리. `docs/validation/*`(읽기전용 정본)의 작성자 메타데이터는 무수정.
- 커밋 `f4167b7` → Pages 배포(`docs/`는 `/docs` 콘텐츠 소스라 반영).

## 7. /screens 스파이크 단계 열 추가 + 체크박스 열 간격 축소 (배포)

- `/screens` 상태 단계에 **「스파이크」(1차 개발/PoC)를 디자인 검수와 개발 사이**에 추가 — `screen_status.spike` 열 신설(schema + `0006_screen_spike.sql` ADD COLUMN, 라이브 D1 적용·기존 9행 spike=0), `StatusRow/Patch`·PATCH 불리언 키·GET 머지·`screenList` 인터페이스·인메모리 폴백 반영. 최종 6단계: 디자인·퍼블리싱·디자인 검수·**스파이크**·개발·테스트.
- 상태(체크박스) 열 **너비 78→46px·좌우 패딩 축소**로 간격 압축, 헤더 제목 **2줄 허용**(`word-break: keep-all`). 커밋 `ab0e511` → Pages 배포.

## 8. 크리에이터 관리자단(AD01) 신규 앱 전 도메인 구축 + 공개 미리보기 배포

- **`solsol-admin` 레포 루트에 관리자단 실제 앱 신규 구축**(mockup은 기준선 무수정) — Nuxt 3(compat v4)·Nuxt UI v3·Pinia·pretendard. **프론트 우선(목 데이터)**, 실 API(solsol-api) 연동은 후속 트랙.
- **AD01 화면목록 107 본화면 전 도메인 구현**: 골격(디자인시스템 이식·RBAC·인증 미들웨어·useApi·공용 App* 6종·마스킹 유틸 5종) · 인증4·대시보드 · 사용자(학습자·강사·관리자, **C-16 권한설정 RBAC·M-2 프리셋**) · 상품 7유형 · 콘텐츠(업로드 상태머신·AI·자막) · 판매(주문·쿠폰·환불) · 마케팅(캠페인·발송·그룹·템플릿·설문·툴·랜딩 13) · 운영(게시판·팝업) · 사이트디자인(빌더 섹션9유형·SEO·푸터) · 통계·정산·설정.
- **품질 게이트**: 도메인마다 **qa +(민감)privacy·security** 게이트 → ❌'상' 0건 확인 → 결함 보완. 발견 blocker(환불금액 정합 PAY-11·닉네임 마스킹·마케팅 5건·광고 야간발송 차단 등) 전건 해소. 라운드 기록 = `docs/dev-validation/AD01-app-{phase0,1a,1b,1c,1d,phase2-*}.md`.
- **05 확정 6건 반영**: 닉네임 2~15·무료체험 미운영·RBAC·유효시간(가입10분/재설정30분)·비번 3종 8~16·쿠폰 정액only.
- **커밋·푸시**: `malgnsoft/solsol-admin` `2e0fdde`(앱 전체 218파일) + `c0d35fd`(cloudflare-pages 프리셋).
- **공개 미리보기 배포**(사용자 승인 — 목·무인증 노출 인지): Cloudflare Pages 프로젝트 `solsol-admin` 신규 생성 → `dist/` 배포 → **https://solsol-admin.pages.dev** (스모크: `/`→`/auth/login` 302·로그인 200). ⚠️ 실인증 없음(localStorage owner·devLogin public) — **Phase 1 서버 인증(roleGuard·httpOnly 세션·응답 마스킹·환불/정산 서버 재계산) 전까지 프로덕션 아님**.
- **에스컬레이션(SoT 소유자 확정 대기)**: ①06 §2.8 vs 05 M-2 강사 `operation` 권한 불일치(코드는 05 따름) ②자막 편집 화면 유효성(위캔디오 위임) ③폴더 삭제 정책.

## 산출물

- 코드: `server/api/screens/[id].patch.ts`·`index.get.ts`·`server/utils/screenStatus.ts`(§3·§7), `app/utils/wbsData.ts`·`app/pages/wbs.vue`·`app/pages/index.vue`·`server/db/seed.sql`(§4·§5), `docs/AGENT_TEAM.md`·`CLAUDE.md`·`docs/DEV_VALIDATION_PROCESS.md`(§6), `server/db/schema.ts`·`server/db/migrations/0006_screen_spike.sql`·`app/utils/screenList.ts`·`app/pages/screens.vue`(§7).
- 라이브 D1(`solsol-project`): `screen_status` FR01 7행 복구, `wbs_item` 스텝 재편(4:13·5:5·6:8·7:19·8:18) + 스파이크 5행.
- 커밋 `cf5ecd6`(screens fix)·`8cf245a`(wbs spike 신설)·`a7bad92`(spike 설계–구현 사이 이동·이번주 완료) → `malgnsoft/solsol-mng` → Pages `solsol-mng` 배포.
- 최종 WBS 8단계: 4 목업 → **5 설계 → 6 스파이크(1차 개발·이번주 완료) → 7 구현** → 8 운영·계약.
- 에이전트팀: **글로벌 팀만 사용**(프로젝트 전용 팀 폐지) — 커밋 `f4167b7`, Pages 배포.

## 다음 단계

- 회원 모델 변경 반영해 인증 API/프론트 재작성 → mock→실 provider 교체 → 인증 QA 라운드 → 배포.
- 스파이크(Step 5) 항목 진행에 따라 진척률 갱신(현재 스텝5 평균 27%).
- **solsol-admin(§8)**: 백엔드(solsol-api) 실연동 트랙 — 목→request 교체 + **Phase 1 서버 이관 보안**(roleGuard·httpOnly 세션·devLogin 제거·환불/정산 서버 재계산·응답 단계 마스킹). 에스컬레이션 3건 SoT 소유자 확정. 잔여(하): 페이지빌더 실 DnD·이미지 업로드/크롭·toss 카드등록·카카오 연결 C-14 다단계화.

---

## 9. 크리에이터 사용자단(FR01) 신규 앱 전 화면 구축(7라운드) + 프로덕션 배포

- **`solsol` 레포 루트 `app/`에 사용자단 실제 앱 신규 구축**(mockup 기준선 무수정) — Nuxt 3(compat v4)·Nuxt UI v3·Cloudflare Pages·디자인토큰 primary `#7954C6`. **프론트 우선**, 데이터는 composable **mock 폴백 단일지점**(실 API 미연동).
- **FR01 48페이지 전 화면 구현(7라운드)**: ①~③ 상품 브라우징 7유형(강의 일반/라이브/화상/패키지/디지털 + 프리미엄커뮤니티 + 멤버십) 목록·상세 ④ 게시판 3종(공지·자유[비밀글/등급권한]·FAQ) ⑤ 마이페이지 코어 11(구독관리·내상품·찜·쿠폰·결제내역·결제정보·내게시글·1:1문의 3종·프로필[탈퇴 이중컨펌 비가역]) ⑥ 학습 4(강의실[위캔디오 플레이어·순차잠금·진도율·AI튜터/자료실 조건부]·대시보드·라이브실[YouTube Live·채팅]·수료증 PDF) ⑦ 결제 3(주문·완료·실패)+알림센터+유예 인트로.
- **운영 방식**: 라운드마다 **팀장 경유 4단계**(dev-lead 계획 → frontend-developer 구현 → qa +(재무/PII)privacy-officer 게이트[❌'상' 0] → 총괄 교차판정 → 체크포인트 커밋). 매 라운드 화면ID 단위 검증·결함 전건 보완. 정본(`docs/validation/`)·목업 무수정, `app/`만 변경, **05 확정 6건 준수**(쿠폰 정액·토스트 일원화·컨펌 AppModal·본인 마스킹·비가역 이중컨펌). 라운드7 카드 마스킹 형태 위반(뒤4자리 배치)을 **privacy-officer가 blocker로 잡고 총괄 교차판정으로 수정**. 전체 `pnpm typecheck` **0**.
- **공통 자산**: 레이아웃 3(default·mypage·classroom) + 공통/course/board/subscription/mypage/learn 컴포넌트 ~50종 + composable 14종(useProducts·useBoard·useSubscription·useOrder·usePayment·useInquiry·useWishlist·useCoupon·useNotification·useLearning·useCertificate 등, 전부 mock 폴백 → 실 API 전환 시 이 지점만 교체).
- **커밋·푸시**: `malgnsoft/solsol`(=origin) main — `0f0276c`(브라우징+게시판+typecheck 정리) → `fdab4ed`(마이페이지 코어 11) → `cf31dad`(학습+결제/알림/유예, **FR01 화면 완성점**). baseline 21건(구버전 토스트 color) 정리 + `vue-tsc` 도입 + mockup 컴파일 제외(nuxt.config).
- **프로덕션 배포**(사용자 "배포" 지시 — mock 폴백 데모 인지): Cloudflare Pages 프로젝트 `solsol` 신규 생성(계정 `info@malgnsoft.com`) → `pnpm build`(nitro cloudflare-pages·`dist/`) → 배포 → **https://solsol.pages.dev**. 스모크: `/`200 · `/courses`200(mock 목록 SSR) · `/mypage/subscription`302→로그인(보호 라우트 가드) · `/notifications`200. ⚠️ `NUXT_PUBLIC_API_BASE` 미설정 = **mock 폴백**(실 데이터 없음) → **실 API 결선·시크릿 주입 전까지 비프로덕션 데모**.
- **계약대기(실 API 전환 시)**: 위캔디오/YouTube/NICE/toss/약관JSON·후기·찜·쿠폰·문의·주문·알림 CRUD·R6 댓글 3계층 모델·약관 동의이력 필드.

### §9 산출물
- 코드: `solsol/app/`(페이지 48·레이아웃 3·컴포넌트 ~50·composable 14), `nuxt.config.ts`(mockup 제외·vue-tsc), `package.json`(vue-tsc).
- 검증 기록: `docs/dev-validation/`(fr01-courses-round1/2·community-round3·boards-round4·mypage-5a/5b/5c-round1·learn-round6·payment-round7).
- 배포: Cloudflare Pages `solsol` → **https://solsol.pages.dev**(mock 데모).
- 커밋: `malgnsoft/solsol` `0f0276c`·`fdab4ed`·`cf31dad`.

### §9 다음 단계
- **실 API 결선**: dba(TB_ 스키마 마이그레이션) + api-developer(도메인별 라우터) 병행 → composable mock→실 API 단일지점 전환. R6 댓글 3계층·동의이력 정합.
- 폴리시 백로그(하): 알림 미읽음 카운트·쿠폰 0장 hide·고객센터 연락처·휴대폰 마스킹 정책(강테크 컨펌).
- 실연동 후 `NUXT_PUBLIC_API_BASE`·세션 시크릿 주입 → 프로덕션 승격.

---

## 10. 데이터 모델 정밀화 — 테넌트 마무리 + 마스터 스키마 전면 개편 (문서/DB, 배포 없음)

사용자와 대화형으로 스키마를 다듬은 세션. 매 변경마다 **정본 4종(`master.sql`·`tenant_template.sql`·`README`·`ERD.md`) + dev DB(Hyperdrive→Aurora `solsol`/`solsol_lms`) 동기화 후 커밋**. Figma는 사용자 요청 시 일괄.

### 테넌트(LMS) 마무리
- **디지털 다운로드 이력** `TB_DIGITAL_DOWNLOAD_LOG` 신설 → 이후 `course_user_id` 제거·`order_id`/`order_item_id`로 정정(디지털은 수강 무관).
- **`TB_COURSE_USER`** malgn 레거시 26컬럼 제거(성적체계·반/담당강사·등급·학점·마감·정지 등) → 진도율·수료·수강기간·구매연결 18컬럼.
- **수료조건을 `TB_COURSE` 컬럼으로 흡수**(min_progress_rate·watch_mode·certificate_template_id) + `TB_COMPLETION_RULE` 삭제. 라이브 수료증용 `TB_PRODUCT_LIVE.certificate_template_id` 추가.
- **금액 컬럼 `_price` 통일**(정가 list_price·할인 discount_price·거래액 pay_price 등, tenant 35·master 5건).
- **설문 보기**: JSON→정규화 후 다시 **인라인**(`TB_SURVEY_QUESTION.option1~10`, `TB_SURVEY_OPTION` 삭제, 답변 `option_no`).
- **영상=위캔디오(Wecandeo)** VOD(`TB_CONTENT.source_type=wecandeo`·`wecandeo_video_key`), **자막은 위캔디오 보관** → `TB_SUBTITLE`/`TB_SUBTITLE_LINE` 삭제.
- **일시 = `TIMESTAMP`(내부 UTC)** 전환(DATETIME→TIMESTAMP tenant 239·master 49). 사유: dev Aurora tz=Asia/Seoul + **Hyperdrive가 세션 SET time_zone 미유지** → DATETIME은 KST 저장. (테넌트 최종 91)

### 마스터 스키마 전면 개편 (14→13)
- **`TB_TENANT`→`TB_SITE`**(+`tenant_id`→`site_id`, `TB_TENANT_PROVISION_LOG`→`TB_SITE_PROVISION_LOG`).
- **`TB_SELLER`+`TB_PLATFORM_ADMIN`→`TB_USER`**(user_type=seller/admin) + **`login_id`·비밀번호 인라인**(`TB_USER_CREDENTIAL` 흡수).
- **크레딧 재설계(에이전트팀 DBA 위임)** → 최종 **단일 `TB_CREDIT`**(통장식 원장): 증가lot(`remaining_cr`·`expires_at`·`is_expiring`)+차감, 각 행 `balance_after_cr`, 유효기간 FIFO, 소진 lot은 `source_credit_id`(분할 차감). `TB_CREDIT_ACCOUNT`/`TB_CREDIT_CHARGE`/`TB_CREDIT_ALLOCATION` 모두 제거(잔액=원장 파생). **크레딧 컬럼 `_cr` 접미**(통화 `_price`와 구분, 둘 다 DECIMAL(18,6)).
- **감사 기록 신설**: `TB_USER_AGREEMENT`(약관 동의 이력)·`TB_LOGIN_LOG`(로그인/로그아웃/실패).
- **사이트 권한 `TB_SITE_USER`(N:M)** — 크리에이터=owner 자동배정(다중 사이트)·담당자=manager 배정, 권한체크=배정 존재로 통일. `owner_user_id`=생성자 앵커 유지.

### 정본·규정·산출물
- **`ERD.md` 현행화**: 세션 중 tenant_template·DB만 갱신하고 ERD.md를 누락했던 것을 사용자가 지적 → 정본 기준 재생성(옛 구조 0). 이후 매 변경 동기화.
- **글로벌 규정 등재**: `~/.claude/knowledge/conventions.md`에 "**DB 변경=정본 문서까지 동기화가 1작업**" 추가(+메모리 `db-change-sync-sot`).
- **Figma**: 마스터 보드(`UR6M…`) 재생성(13테이블), 테넌트 보드(`tds3…`) 최신 확인. URL 유지.
- dev DB 최종: **master 13 · tenant 91**, 0오류. `solsol-api`(`schema.master`·`ops` 시드/verify) 동기. ⚠️ `wrangler.toml` APP_ENV=production이라 dev ops는 `--var APP_ENV:local` 오버라이드로 적용.
- 커밋 다수(malgn main): `2ca8e11`…`761452b` 및 후속(데이터모델·이력).

---

## 11. 크리에이터 백엔드(solsol-api) 전 도메인 엔드포인트 구축 + OAuth 테넌트화 + 프로덕션 배포

- **범위**: `solsol-api`(Hono + Drizzle + Aurora MySQL, schema-per-tenant)에 사용자단(FR01) + 관리자단(AD01) **전 도메인 엔드포인트** 구축. 기존 인증(스프린트1 `/auth`·`/me`·`/tenant`) 위에 신규 **23개 라우터 마운트** — 사용자단 `/api/*`: products·learning·certificates·orders·billing·subscriptions·coupons·community·inquiry·faq·notifications·wishlist·reviews / 관리자단 `/api/admin/*`: settings·site·contents·products·commerce·settlement·credits·members(RBAC)·marketing·stats·support·dashboard.
- **작업 방식**: 팀장 경유 4단계 — 정본 6소스 병렬 분석(조백개님·임관개님·도아컨님) → 팀개발(dev-lead) 도메인 배치 GO 계획 → **최대 9트랙 병렬 구현**(조백개님·배엘개님·임관개님) → 중앙 통합 → 3중 게이트.
- **Batch 0 파운데이션**: Drizzle 미러 도메인 분할(`schema.tenant/` 7슬라이스 + index, 전 테넌트 테이블), `middleware/roleGuard.ts`(TB_ADMIN_PERMISSION menu + data_scope), `lib/pagination`·`lib/idempotency`, errors 확장.
- **B1 정정(오너 지침)**: 소셜 연동은 **TB_USER 비정규화 컬럼**(`google_uid`…`primary_provider`)이 정본, **TB_USER_SOCIAL 미사용** — 초기 정규화 방향을 롤백하고 `auth`·`me` 라우트를 비정규화로 재작성.
- **3중 게이트**: qa GO(계약 사용자단 40/40·관리자 15도메인 전량, typecheck 그린) / security·privacy 초기 **NO-GO(blocker 3)** — `/ops/*` 무인증·파괴적, `/ops/sessions` refreshTokenHash 노출, community 비밀글 무단열람 → **보완**(ops 운영게이트 `APP_ENV`+`OPS_SECRET`·reset prod 차단, refreshTokenHash 응답 제거, 비밀글 작성자/staff 통제, 업로드 타입·크기 검증, REFRESH_PEPPER 폴백 제거, 인증코드 시도상한) → **재검토 전원 GO**.
- **비가역 staging 게이트**: 결제·환불·정산·구독·크레딧충전·캠페인발송은 **골격 + `// TODO(staging-gate)`로 실행 차단**(실 PG/토스 호출 0).
- **OAuth 테넌트화(오너 아키텍처 정정)**: OAuth 자격증명은 테넌트마다 다르므로 전역 시크릿이 아닌 **테넌트 테이블 `TB_OAUTH_CONFIG`**(provider별 1행, `client_secret` AES-GCM 암호문)로 이전. `resolveProvider`(테넌트 조회)·`lib/crypto.ts`(AES-GCM) 신설. 테넌트 91→**92**. **정본 동기화**(db-change-sync-sot): 마이그레이션 SQL·Drizzle 미러·`docs/data-model/ERD.md` 갱신.
- **배포(Cloudflare Workers)**: Worker `solsol-api` 신규 생성 → 전역 시크릿 3종(`JWT_SECRET`·`REFRESH_PEPPER`·`SECRET_ENC_KEY`) **난수 생성·주입(값 무노출)** → 최신 코드 재배포 **버전 `7e056d9d`** → 스모크 전량 통과: `/health` 200, **`/health/db` Aurora MySQL 8.0.42 실연결(`solsol`·`solsol_lms`) = 실 DB 실연동 검증**, `/api/products` 200(공개), `/api/orders` 401(보호+인증게이트), `/tenant` 200(실 테넌트 row). URL **https://solsol-api.malgnsoft.workers.dev**. (참고: `solsol-api`는 로컬 git 레포 아님 → 커밋 대상 없음.)
- **관리 허브 부가**: `solsol-mng`에 **`/apis` API 상세 내역 페이지** 추가(157 엔드포인트·필터·상세 드로어, 네비 "API" 링크).

### §11 산출물
- 코드(`solsol-api`, 로컬 git 레포 아님): 신규 23개 라우터(사용자단 `/api/*` 13 + 관리자단 `/api/admin/*` 10 도메인), `schema.tenant/` 7슬라이스 + index, `middleware/roleGuard.ts`, `lib/pagination`·`lib/idempotency`·`lib/crypto.ts`(AES-GCM)·`resolveProvider`, `TB_OAUTH_CONFIG` 마이그레이션 SQL + Drizzle 미러.
- 정본 동기화: `docs/data-model/ERD.md`(`TB_OAUTH_CONFIG` 반영, 테넌트 92).
- 배포: Cloudflare Workers `solsol-api` **버전 `7e056d9d`** → **https://solsol-api.malgnsoft.workers.dev**(실 Aurora 실연동 검증). 시크릿 3종 난수 주입(값 무노출).
- 관리 허브(`solsol-mng`): `/apis` API 상세 내역 페이지(157 엔드포인트) + 네비 "API" 링크.

### §11 다음 단계 / 알려진 한계
- **(a)** `/health/db` verdict 문구가 마스터 스키마명을 `solsol_master`로 기대하나 실제는 `solsol` → **문구 정정 권고**(연동 자체는 정상).
- **(b)** 테넌트별 `TB_OAUTH_CONFIG` **행 시드 필요**(소셜 로그인 활성화 전제).
- **(c)** 결제·크레딧 **실 토스 연동은 staging 게이트 해제 시 오너 확인**(현재 실행 차단).
- **(d)** Figma 테넌트 ERD 보드(`tds3…`)에 `TB_OAUTH_CONFIG` **제자리 갱신**.
- **(e)** 마스킹헬퍼(`maskAccount`·`maskBizNo`) lib 승격 · 동의이력 `TB_USER_AGREEMENT` 이관 후속.

---

## 12. API 문서 위치 이관 — 관리 허브 `/apis` 제거 → 백엔드(solsol-api) `/doc` 신설(Scalar UI + OpenAPI 3.1) + 루트 리다이렉트

- **배경/결정(오너 지시)**: API 상세 문서를 관리 허브(`solsol-mng`)의 `/apis` 페이지가 아니라 **백엔드(`solsol-api`) 자체의 `/doc`** 에서 제공하도록 이관. 루트(`/`) 접속 시 문서로 유도한다. 문서 UI·경로 모두 **아키텍처 원본 `malgn-noti-api/doc`과 동일한 방식**(Scalar UI + OpenAPI 3.1, 경로 `/doc` 단수)으로 맞춘다.
- **solsol-mng — `/apis` 제거**: `app/pages/apis.vue`·`app/data/apiEndpoints.ts` 삭제 + `app/layouts/default.vue` 네비의 "API" 링크 제거. 커밋 `d237f59`(malgn main) → Pages 재배포(**https://b6868703.solsol-mng.pages.dev**). `/screens` 등 기존 기능 무손상.
- **solsol-api — `/doc` 신설(Scalar + OpenAPI 3.1)**: 초기 자체 완결 HTML(중간 단계, 버전 `72c249d7`)로 배포했으나 오너 요청으로 **아키텍처 원본 `malgn-noti-api` 방식**(`@scalar/hono-api-reference@0.10.19`)으로 재구축.
  - `src/openapi.ts`(OpenAPI 3.1 스펙) — 카탈로그 `src/docs/endpoints.ts`의 `ENDPOINTS`를 빌더로 변환해 **151 paths / 223 operations / 26 태그(도메인)** 생성. `info.description` 마크다운(소개·인증[Bearer + X-Tenant]·**응답 형식**[`{ok,data,meta?}` / `{ok:false,error}`]·에러 코드·페이지네이션·멀티테넌트·멱등성)으로 참고 페이지의 `#description/응답-형식` 앵커에 대응. securitySchemes = `bearerAuth` + `tenantHeader`(X-Tenant).
  - 라우트: `GET /doc`(Scalar UI) + `GET /doc/openapi.json`(raw 3.1 스펙) — `tenantResolver`·`requireAuth` **밖 공개 라우트**. 루트 `GET /` → **302 `/doc`** 유지. 기존 수제 HTML 라우트(`src/routes/docs.ts`) 삭제.
  - Workers 재배포 흐름: 초기 수제 HTML `72c249d7` → Scalar 재구축 `d4136a0d` → **경로 `/docs`→`/doc`(단수) 변경 재배포 최종 버전 `bb42ee1b`**(`malgn-noti-api`와 경로 일치).
- **스모크**: `/`→302→`/doc`(Scalar 셸 200) · `/doc/openapi.json` 200(3.1.0·151 paths/223 ops) · `/health` 200. URL **https://solsol-api.malgnsoft.workers.dev/doc**. (`solsol-api`는 로컬 git 레포 아님 → 커밋 대상 없음.)
- **유지보수 메모**: 라우트 추가/변경 시 `solsol-api/src/docs/endpoints.ts`의 `ENDPOINTS` 배열만 갱신하면 OpenAPI 스펙·Scalar 문서에 자동 반영된다.

### §12 산출물
- solsol-mng: `app/pages/apis.vue`·`app/data/apiEndpoints.ts` 삭제 + `app/layouts/default.vue`("API" 네비 제거). 커밋 `d237f59`(malgn main) → Pages 재배포 **https://b6868703.solsol-mng.pages.dev**.
- solsol-api(로컬 git 아님): `src/openapi.ts`(OpenAPI 3.1 — 151 paths/223 ops/26 태그·securitySchemes bearerAuth+X-Tenant·`info.description` 규약 마크다운) + `GET /doc`(Scalar UI, 원본 `malgn-noti-api` 방식)·`GET /doc/openapi.json`(raw 3.1) 라우트 + 루트 `GET /` → 302 `/doc`. 기존 수제 HTML 라우트(`src/routes/docs.ts`) 삭제. Workers 재배포 **최종 버전 `bb42ee1b`**(수제HTML `72c249d7` → Scalar `d4136a0d` → `/doc` 경로 `bb42ee1b`) → **https://solsol-api.malgnsoft.workers.dev/doc**.

### §12 다음 단계
- 문서 카탈로그는 **코드 변경 시 `solsol-api/src/docs/endpoints.ts` 동기화**(라우트 추가/변경 → `ENDPOINTS` 배열 갱신 → OpenAPI/Scalar 자동 반영).

## 13. 브랜드 사용자단(solsol-brand) 신규 앱 전 화면 구축(2라운드+a11y) + 프로덕션 배포

- **배경/결정(오너 지시)**: 브랜드 사이트 **사용자단**을 핸드오프 v5 목업(`solsol-brand/mockup`, 동결 기준선) 대비 **1px 그대로** 재현하고 각 페이지에 **mock 데이터 기능**을 탑재해 레포 루트에 신규 구축. API 미생성 → 전 데이터 mock 폴백. 글로벌 에이전트팀(총괄 대행) 4단계 SoP로 진행.
- **스택 결정(1px 우선)**: 목업과 동일 핀 — Nuxt 4.4.8 / **@nuxt/ui v4**(4.9.0) / Tailwind v4 / Pretendard. `nuxt.config` `ignore:['mockup/**']`·`tsConfig.exclude:['../mockup']`·`nitro cloudflare-pages`. 1px 생명선 `BrandCanvas`(1920 고정폭 + `body.style.zoom` fit) verbatim. GNB/Footer는 페이지 인라인 verbatim(추출 안 함).
- **구축(4트랙 병렬)**: 파운데이션(리드) → 페이지 그룹 A/B/C/D 병렬. **37페이지**(목업 39 − 카탈로그성 index/page-list/design-guide 제외), `landing→index.vue`. mock composable 9종(useAuth/Sites/News/Inquiries/Plans/MyProduct/Billing/Account/LegalDocs) + data json. mock 인증코드 `400039`.
- **검증 R1**: 화면ID 커버리지 37/37(누락0), 1px verbatim diff 훼손 0, `pnpm build` PASS. QA GO / privacy·security CONDITIONAL(**상 0**). 결함표 `docs/dev-validation/brand-site-round1.md`. 보완: route-protection(`/contact-history-detail`·`/pricing-purchase`)·오픈리다이렉트 화이트리스트·개정일버그·verbatim위반(결제실패버튼→`?fail=1`) 수정.
- **검증 R2(런타임·브라우저 심화)**: dev 서버 전 37라우트 스모크(공개 27→200·보호 10→302 `/login?redirect=`), SSR 렌더·로그 에러 0. Playwright로 로그인 플로우(세션·리다이렉트 화이트리스트)·뉴스 필터·폼검증·반응형(가로 오버플로 0)·시각 렌더 확인. 콘솔·페이지 에러 0.
- **a11y 1px-safe 스윕**: 4그룹 병렬로 비가시 속성만 추가(약 147개 `alt`/`aria-label`/label 연결/`select-name`). axe 재측정 결과 **image-alt·label·link-name·button-name·select-name 위반 0**, `color-contrast`만 잔존(=핸드오프 색상, 디자인/오너 판정 영역).
- **배포**: 커밋 `ff377b4`(origin=malgnsoft/solsol-brand main 푸시). 신규 Pages 프로젝트 `solsol-brand` 생성 + `dist` 배포. 프로덕션 **https://solsol-brand.pages.dev**.
- **스모크(프로덕션)**: `/`·`/pricing`·`/login`·`/terms`·`/signup` 200, `/billing` 302(보호), `/news`·`/news-detail` 200(초기 522는 콜드스타트 후 정상). 랜딩 콘텐츠(쏠쏠·크리에이터·무료로 시작) 정상.

### §13 산출물
- solsol-brand(origin=malgnsoft): 레포 루트 실앱 신규(app/pages 37 + composables 9 + data json + BrandCanvas/AppLogo + middleware + config). 커밋 `ff377b4` → Pages 신규 프로젝트 `solsol-brand` 배포 **https://solsol-brand.pages.dev**. `mockup/**` 무수정(동결).
- solsol-mng: 결함표 `docs/dev-validation/brand-site-round1.md`(R1).

### §13 다음 단계
- **오너 판정 대기**: `color-contrast` 디자인 조정 · 모바일 리플로우 반응형 별도 설계 여부(현재 고정캔버스 zoom 축소) · 공유 약관상세 모달(C01) 신설 vs SoT 개정.
- **실 API 연동 시 선결(보안·개인정보)**: 서버측 인증/세션·IDOR 차단·인증코드 서버검증·레이트리밋·v-html sanitize·카드 PAN 서버마스킹·정보통신망법 마케팅 고지. mock 세션 영속화(새로고침 유지)는 데모 개선 옵션.

---

## 14. 관리자단 **목업**(`solsol-admin/mockup`) 검증 라운드2 + 「수정 지시서」 AD01 즉시착수 3건 수정·배포

- **배경/결정(오너)**: 종전 '동결 기준선'이던 `solsol-admin/mockup`을 오너가 **동결 해제 → 수정 대상**으로 전환(사용자단 `solsol/mockup`은 동결 유지). 수정 착수 **전** 읽기전용 검증 라운드2 수행 후, solsol PO 공식 「수정 지시서」(2026-07-01, DJ 지시)의 **AD01 해당·무게이트 항목만** 반영.
- **검증 라운드2(무수정 분석)**: 관리자단 목업 99 Vue 전수를 SoT(`docs/validation/{00,02,04,05,06}` + 참조 PNG) 기준으로 **10 게이트 병렬**(도메인 qa 8 + security + privacy). 화면 파일 커버리지 ~100%(물리 누락 ≈0)이나 화면 내부 정책 충실도 낮은 **초기 축약본** → 10/10 NO-GO. 근본원인 **8계열**(마스킹 유틸 부재·RBAC 미반영·비가역 게이트 부재·인증 정책 위반·정책 정합 불일치·핵심요소 미구현·정통망법 컴플라이언스·공통 상태/반응형). 05 확정 6건 중 #2 무료체험·#6 쿠폰 정액only ⭕ / #1·#3·#5 ❌ / #4 🔺. 디자인 baseline 색 `#027CFA`(참조 PNG도 파랑)=비결함. 결함표 정본 = `docs/dev-validation/AD01-mockup-round2.md`.
- **「수정 지시서」 AD01 분류**: 즉시착수(무게이트) = **AD-1·AD-2·AD-3**. 보류(DJ 선행 컨펌 게이트) = AD-4(마스킹·K-1)·AD-5/COM-3(브랜드색·K-4)·COM-1(반응형·K-2)·COM-2(화면ID SoT·K-3, 대상은 실앱 `screenList.ts`).
- **수정(admin-developer, `solsol-admin/mockup` 3파일)**:
  - **AD-1(상)** `auth/register.vue` — 회원가입 주 CTA 라벨 "로그인 하기" → **"회원가입"**(하단 로그인 링크·동작 로직 무변경).
  - **AD-3(중)** `auth/register.vue`·`auth/reset-password.vue` — 비밀번호 placeholder → **"영문·숫자·특수문자 3종 조합 8~16자"**(05 C-3 통일). 검증 로직·확인 필드 무변경.
  - **AD-2(중)** `admin/index.vue` — 대시보드 "chart.js/vue-chartjs 연동 필요" placeholder 제거 → **인라인 SVG 정적 막대차트**(신규 의존성 0, 색 `#027CFA`).
  - grep 교차검증: 잔존 placeholder 0건, 검증 로직·타 영역 무변경.
- **배포(deployer)**: 워킹트리에 섞인 **무관 루트앱 WIP**(`app/composables/useApi.ts`·`app/pages/auth/login.vue`·`nuxt.config.ts`·`server/`)는 **미접촉**, 내 3파일만 명시 스테이징. 커밋 **`5144310`**(`git show --stat`로 3파일만 확인) → `git push origin main`(`malgnsoft/solsol-admin`, `2fad462..5144310`). `npm run generate`(205 라우트 프리렌더 → `.output/public`) → `wrangler pages deploy` → Pages 프로젝트 **`solsol-admin-mockup`**. 배포 URL **https://4aa6a247.solsol-admin-mockup.pages.dev**(alias **https://solsol-admin-mockup.pages.dev**). 스모크: `/admin`·`/auth/register`·`/auth/reset-password` 308→200, AD-1/2/3 반영 라이브 확인.

### §14 산출물
- `solsol-admin/mockup`(별도 레포 `malgnsoft/solsol-admin`): `mockup/app/pages/{admin/index,auth/register,auth/reset-password}.vue` 3파일 — 커밋 `5144310`(origin main) → **Pages `solsol-admin-mockup` 배포**(https://solsol-admin-mockup.pages.dev).
- `solsol-mng`: `docs/dev-validation/AD01-mockup-round2.md`(검증 라운드2 통합 결함표·8계열·우선순위) 신규.

### §14 다음 단계
- **DJ 선행 컨펌(K-1~K-4)** 결정 시 AD-4(마스킹)·AD-5/COM-3(브랜드색)·COM-1(반응형) 순차 반영(K-1 마스킹·K-4 브랜드색 우선 권고).
- 라운드2 **P0 공통 인프라**(마스킹 유틸·비가역 컨펌 모달·RBAC 골격·공통 상태 컴포넌트) 착수 시 다수 blocker 동시 해소 → 보완 라운드 재검증(종료조건 blocker 0).

---

## 15. 브랜드 백엔드(solsol-brand-api) 신규 구축 + master 스키마 확장 + 프로덕션 배포

- **범위/스택**: 빈 레포 `solsol-brand-api`를 신규 구축. Hono + Drizzle + Cloudflare Workers(아키텍처 원본 `malgn-noti-api`, 기반 `solsol-api`). 브랜드 백엔드는 **master 스키마 단독**(tenant 불필요) — 동일 Aurora·Hyperdrive(`a14c69…`) 재사용. 인증은 master `TB_USER`(seller) **이메일 + PW**(PBKDF2), 소셜/tenantResolver 없음(크리에이터 LMS `solsol-api`와 구분되는 지점).
- **엔드포인트**: **12 도메인 라우트 / 43 엔드포인트**(`/api/*`) — auth · account · agreement · plans(공개) · sites(프로비저닝 게이트) · billing · subscriptions · invoices · payments · contact · news(공개) · webhooks(`/webhooks/toss` 공개·서명검증).
- **작업 방식**: 팀장 경유 — 도아컨님(스캐폴드·master 맵·상태머신 분석)·최기획님(목업→43EP 인벤토리) → 한데관님(SoT/미러) + 조백개님(스캐폴드) → 5트랙 병렬 도메인 라우트 → 통합 → 3중 게이트.
- **master 스키마 확장(비파괴)**: 브랜드 문의/소식용 **`TB_CONTACT`·`TB_CONTACT_REPLY`·`TB_NEWS` 3테이블 추가**(`solsol-api` `000_master.sql` 13→16) + **`docs/data-model/ERD.md` 동기화**(db-change-sync-sot 규정 준수).
- **문서(Scalar UI `/doc`)**: OpenAPI 3.1(`src/openapi.ts` + `src/docs/endpoints.ts` 카탈로그 — 43 operations · 12 태그 · 인증/응답형식/에러/게이트 규약) + 루트 `/` → **302 `/doc`**(`solsol-api`·`malgn-noti-api`와 동일 방식).
- **3중 게이트**: qa GO(계약 43기능 커버·typecheck 그린) / privacy GO(마스킹·시크릿 미노출·동의 스냅샷) / security **초기 NO-GO**(blocker: `/health/db`·`/health/db/grants` 무인증 DB 토폴로지 노출) → 보완(OPS_SECRET 게이트·CORS 화이트리스트·billing 상태검증·`getMasterSchema` 분열버그 수정) → **재검토 전원 GO**.
- **staging 게이트**: 결제·구독·카드등록·프로비저닝·웹훅은 골격 + TODO(실 토스 호출·자동전이·실 테넌트 스키마 생성 0).
- **핵심 발견(스키마명)**: live master 스키마명 = **`solsol`**(설계상 `solsol_master`가 아니라 `solsol-api`와 동일) → `MASTER_SCHEMA_NAME=solsol`(`wrangler.toml [vars]`) 필수. contact/news 3테이블은 게이트된 `POST /ops/migrate`(CREATE IF NOT EXISTS)로 live `solsol`에 적용.
- **배포(Cloudflare Workers)**: **https://solsol-brand-api.malgnsoft.workers.dev**. 시크릿 4종(`JWT_SECRET`·`REFRESH_PEPPER`·`SECRET_ENC_KEY`·`OPS_SECRET`) 난수 주입(값 무노출). 버전 흐름 `755ca23e`(생성)→`0e26f335`(시크릿)→`023c584f`(`MASTER_SCHEMA_NAME=solsol` 정합)→**`973fee86`**(마이그레이션 라우트·최종). git origin `malgnsoft/solsol-brand-api`(`591bcd5`).
- **스모크**: `/`→302→`/doc` · `/doc` 200(Scalar) · `/doc/openapi.json` 200(43ops) · `/api/plans` 200 · `/api/news` 200(마이그레이션 후) · `/api/account` 401 · `/health/db` 게이트 403. **12도메인 라이브 완성.**

### §15 산출물
- `solsol-brand-api`(origin=`malgnsoft/solsol-brand-api`, `591bcd5`): Hono + Drizzle + Workers 신규 앱 — 12 도메인 라우트/43 엔드포인트(`/api/*` + `/webhooks/toss`), master 스키마 단독, `src/openapi.ts` + `src/docs/endpoints.ts`(43ops·12태그) + Scalar `/doc` + 루트 302, `MASTER_SCHEMA_NAME=solsol`(`wrangler.toml [vars]`), 시크릿 4종 난수 주입.
- master SoT: `solsol-api` `000_master.sql` **13→16**(`TB_CONTACT`·`TB_CONTACT_REPLY`·`TB_NEWS` 추가) + `docs/data-model/ERD.md` 동기화. live `solsol`에 3테이블 적용(게이트된 `POST /ops/migrate`).
- 배포: Cloudflare Workers **버전 `973fee86`**(생성 `755ca23e`→시크릿 `0e26f335`→스키마정합 `023c584f`→마이그레이션 라우트 `973fee86`) → **https://solsol-brand-api.malgnsoft.workers.dev**. 3중 게이트 전원 GO(security 초기 NO-GO→보완).

### §15 다음 단계
- **프론트 연결·결제 실연동 시**: `ALLOWED_ORIGINS`·토스키 미주입 상태 → 주입.
- **결제 실연동 라운드 GO 조건**: refresh 세션 원장(`TB_SESSION`) · 웹훅 토스 서명검증 완성.
- **후속**: 사이트 사용량 소스 · 프로비저닝 방식 · 약관버전 CMS · 레이트리밋(WAF).

## 16. 브랜드 관리자단(solsol-brand-admin) 신규 구축 Phase 0+1 + 운영자 API 30EP + 관리자단 CF Pages 배포(목업 모드)

- **한 줄**: 빈 레포 `solsol-brand-admin`(플랫폼 운영자 콘솔)을 Phase 0+1 27화면으로 신규 구축하고, 백엔드 `solsol-brand-api`에 운영자(admin) API 계층 30EP를 신규 배선. **관리자단 프론트만 목업 모드로 CF Pages 배포**(https://solsol-brand-admin.pages.dev), **brand-api Workers 실배포·운영자 시드는 시크릿 확인 게이트로 코드 푸시까지만**.
- **범위(총괄 방침)**: brand-admin 프론트 = 목업 모드 CF Pages 배포(실 API 미연동 — `NUXT_API_BASE` 미설정, BFF mock 폴백). brand-api Workers 실배포·`seed.admin.sql` 실행 = 프로덕션 Aurora·백엔드 시크릿(`JWT_SECRET`·`REFRESH_PEPPER`·`SECRET_ENC_KEY`(ENCRYPTION)·`TOSS_SECRET_KEY`) 확인 필요한 파괴적·비용 작업 → **게이트(코드 푸시 A-2까지만)**.
- **brand-admin(신규 앱)**: Nuxt4(compat) · Nuxt UI · `nitro cloudflare-pages`. 27화면(사이트/회원/플랜/구독/결제(청구서·결제)/크레딧/CS/공지/통계/설정(운영자·약관·OAuth)) + admin/auth 레이아웃 · 전역 미들웨어(`01.auth.global`·`02.rbac.global`) · 공통 컴포넌트(테이블·필터·페이지네이션·상태배지·토스터) · 스토어(auth·ui) · `useApi` 컴포저블(brand-api 운영자 BFF 실연동 배선 + 목업 폴백). **BFF 세션**: 로그인 시 access/refresh 토큰을 HMAC 서명 세션 쿠키(`sbrand_admin_sess`)에 흡수 — 브라우저엔 user(permissions[])만 반환(토큰 비노출), role→permissions BFF 매핑, login 엔드포인트 인메모리 레이트리밋(운영은 CF WAF 병행 필요 주석).
- **brand-api(운영자 계층 추가)**: 운영자 라우트 11도메인 30EP(`/admin/*`: auth·sites·users·plans·subscriptions·invoices·payments·credits·contact·news·stats) + `requireAdmin`·`requireRole` RBAC 미들웨어 + admin JWT(`typ:'admin'` 클레임으로 seller 토큰과 구분)·전용 refresh 쿠키(`solsol_brand_admin_refresh`) + openapi 운영자 태그. `wrangler.toml`에 운영자 시크릿 이름 주석(값 미기입 — `JWT_SECRET`·`REFRESH_PEPPER` seller와 공유). **`seed.admin.sql`**: 운영자 초기계정(superadmin@solsol.local / dev PW solsol2026 / PBKDF2 해시) — **문서·미실행**(prod PW 교체 경고 명시).
- **3중 게이트(사전 라운드)**: brand-admin `docs/dev-validation/brand-admin-round1.md`·`round2.md` 기록(라운드 검증 GO). 배포 사전 점검: brand-admin **typecheck 그린(exit 0, 중복 import WARN만)** → `pnpm build` PASS(dist 산출·`_worker.js` BFF 라우트 베이크).
- **배포(관리자단 프론트만 · 목업 모드)**: CF Pages `solsol-brand-admin` 프로젝트 생성(최초 create 8000000 transient → 재시도 성공) → **`NUXT_SESSION_SECRET` 32B 난수 비대화식 주입 성공**(production env·값 무노출) → **`NUXT_API_BASE` 미설정(목업 모드 유지)** → `wrangler pages deploy dist`(계정 info@malgnsoft.com·`CLOUDFLARE_ACCOUNT_ID` env 전달) → **https://solsol-brand-admin.pages.dev**(deploy alias `3dfd95f4.`). commit-message ASCII "brand-admin Phase0+1 mock preview".
- **스모크(관리자단 배포)**: `/`→**302→/auth/login**(비인증 게이트) · `/auth/login`→**200** · `/admin`(비인증)→**302→/auth/login**(보호 라우트 가드) · **로그인 POST `/api/admin/auth/login`(mock superadmin)→200**(user+permissions[] 반환·서명 세션쿠키 set·토큰 비노출) · **세션 API `/api/admin/auth/session`(쿠키 동반)→200**(서버측 세션 검증=실 인가). SSR에서 `/admin`+쿠키가 302인 것은 클라이언트 게이트 특성(브라우저에서 store restore 후 렌더 — 인가는 서버 BFF 세션 API로 강제, blocker 아님).
- **brand-api 게이트(실배포 금지)**: `wrangler deploy`(Workers)·`seed.admin.sql` **미실행**. 코드 푸시(A-2)까지만.

### §16 산출물
- `solsol-brand-admin`(origin=`malgnsoft/solsol-brand-admin`, 신규 브랜치 `main` `507c533`): Nuxt4 운영자 콘솔 신규 앱 27화면·BFF 세션·RBAC 미들웨어·공통 컴포넌트·`useApi` 실연동 배선(목업 폴백). CF Pages **배포 https://solsol-brand-admin.pages.dev**(deploy `3dfd95f4.`·목업 모드·`NUXT_SESSION_SECRET` 주입·`NUXT_API_BASE` 미설정).
- `solsol-brand-api`(origin=`malgnsoft/solsol-brand-api`, `0443afd`): 운영자 API 계층 30EP(11도메인)·`requireAdmin`/`requireRole`·admin JWT·전용 refresh 쿠키·openapi 운영자 태그·`wrangler.toml` 시크릿 이름 주석(값 미기입)·`src/db/seed.admin.sql`(문서·미실행). **Workers 실배포·시드 미실행(게이트)**.
- `solsol-mng`: `docs/dev-validation/brand-admin-round1.md`·`round2.md`(검증 라운드) + 본 이력.

### §16 다음 단계 (brand-api 게이트 잔여 절차 — 사용자 확인 후 담당자가 자기 env로 직접 실행)
- **① 백엔드 시크릿 주입**(값 무노출·담당자 자기 env): `wrangler secret put JWT_SECRET`·`REFRESH_PEPPER`(seller와 공유 가능)·`SECRET_ENC_KEY`(ENCRYPTION)·`TOSS_SECRET_KEY` — 이미 등록 시 공유. CORS `ALLOWED_ORIGINS`에 운영자단 도메인(`https://solsol-brand-admin.pages.dev`) 추가.
- **② 운영자 시드 적용(코드 배포와 분리·선적용)**: `seed.admin.sql`을 담당자가 Aurora MySQL에 직접 `SOURCE`/`<` 실행 — **prod PW는 dev값(solsol2026) 교체·해시 재생성(`src/lib/password.ts`) 필수**. 스키마 = master `solsol`.
- **③ brand-api Workers 실배포**: 시크릿·시드 검증 후 `wrangler deploy` → 스모크(`/admin/*` 401 무인증·admin 로그인 200).
- **④ brand-admin 실연동 전환**: 위 ①~③ 완료·security(WAF 레이트리밋)·qa 게이트 통과 후 `wrangler pages secret put NUXT_API_BASE`(brand-api Workers URL) 주입 → 재배포로 목업→실 API 전환.

## 17. brand-api Workers 실배포 + 시크릿 주입 (사용자 승인 후 실행)

- **한 줄**: 사용자 승인으로 `solsol-brand-api`(Hono/Workers)를 **프로덕션 실배포**하고 `ALLOWED_ORIGINS` 시크릿을 주입, 스모크(헬스 200·admin 게이트 401)까지 GREEN. **운영자 시드는 이 환경에서 Aurora 직접 쓰기 경로 없음 → 준비된 실해시 SQL 핸드오프(미적용)**. 시드 미완이므로 **brand-admin `NUXT_API_BASE` 전환은 페일세이프로 보류**(목업 배포 무손상).
- **사전 점검**: `pnpm typecheck` GREEN(exit 0). 작업트리 clean(`0443afd`).
- **시크릿(값 무노출)**: `JWT_SECRET`·`OPS_SECRET`·`REFRESH_PEPPER`·`SECRET_ENC_KEY`(AES-256 base64 32B) — **기존 등록분 재사용(로테이트 안 함)**. `ALLOWED_ORIGINS` **신규 주입 성공**(운영자단 `https://solsol-brand-admin.pages.dev` + 브랜드 프론트 포함). `MASTER_SCHEMA_NAME=solsol`(wrangler.toml var). `TOSS_SECRET_KEY`/`TOSS_WEBHOOK_SECRET` **미주입**(결제 staging-gate, 관리자 콘솔 동작 불요).
- **배포**: `wrangler deploy` → **https://solsol-brand-api.malgnsoft.workers.dev** (Version `c8739ecf`). 바인딩: HYPERDRIVE(Aurora)·APP_ENV=production·MASTER_SCHEMA_NAME=solsol.
- **스모크(GREEN)**: `GET /health`→200(env=production) · `GET /admin/sites`(무토큰)→**401 UNAUTHENTICATED**(requireAdmin 정상, 가드 누락 아님) · `GET /api/plans`(공개)→200 `[]` · `GET /api/news`→200 `[]`(**TB_NEWS 존재 = 이전 세션 migrate 적용됨, 재실행 불요**). 빈 배열=Aurora 실연결(에러 시 500).
- **운영자 시드(미적용·핸드오프)**: `POST /admin/auth/login`(superadmin@solsol.local/solsol2026)→**401 INVALID_CREDENTIALS**(=admin 계정 미시드). brand-api엔 seed 엔드포인트 없음(`/ops/migrate`만) + 이 환경에서 Aurora 직접 MySQL 쓰기 경로 없음 → **시드 미실행**. `solsol2026`의 **실 PBKDF2 해시를 레포 알고리즘(`src/lib/password.ts`)으로 생성·self-verify** 후 최종 SQL을 **파일로만** 준비(해시 무노출). DBA가 자기 env로 Aurora master `solsol`.TB_USER에 `mysql ... < seed.admin.FINAL.sql` 적용 필요.
- **brand-admin 실전환(보류)**: 시드 미완 → `NUXT_API_BASE` **미설정 유지**. 목업 배포 https://solsol-brand-admin.pages.dev 무손상.

### §17 산출물
- `solsol-brand-api` **Workers 실배포**: https://solsol-brand-api.malgnsoft.workers.dev (Version `c8739ecf`, `0443afd`). `ALLOWED_ORIGINS` 시크릿 주입. 스모크 GREEN.

### §17 다음 단계 (잔여 TODO)
- **① 운영자 시드 적용**(DBA·자기 env): 준비된 실해시 SQL을 Aurora master `solsol`.TB_USER에 적용 → 재검증 `POST /admin/auth/login`→200.
- **② brand-admin 실전환**(시드 성공 후에만): `wrangler pages secret put NUXT_API_BASE`=brand-api Workers URL → 재빌드·재배포 → pages.dev 실 로그인 스모크.
- **③ TOSS 실키**: 결제 활성화 시 `TOSS_SECRET_KEY`/`TOSS_WEBHOOK_SECRET` 주입.
- **④ CF WAF**: 운영자 로그인 엔드포인트 레이트리밋(security 게이트).

## 18. 크리에이터 관리자단(solsol-admin) 실 백엔드(solsol-api) 연동 + 프로덕션 배포

- **한 줄**: 목데이터로 완성됐던 관리자단(AD01 107화면)을 **실 `solsol-api`에 연결** — BFF(Nitro server/)·httpOnly 세션·실 로그인·실 데이터(대시보드·사용자). 백엔드 블로커 3종 해소·재배포, 프론트 실연동·게이트·배포까지 GREEN. **총괄 검토 → BFF 골격 → 백엔드 블로커 해소 → 프론트 실연동**의 다단계.
- **총괄 검토(2렌즈)**: solsol-api가 그새 전 도메인 구축·배포됨 확인(사용자단 15+관리자단 12 라우터·3중게이트) → 검토 결과 관리자 실연동 blocker 3(로그인 role버그·관리자 시드 부재·CORS 반사 F-1) 도출·기록(`docs/dev-validation/solsol-api-review-round1.md`).
- **BFF 골격(Phase B1)**: solsol-admin에 Nitro `server/`(apiClient·auth/{login,logout,session}·proxy). security 초기 NO-GO(프록시 SSRF: 화이트리스트·`..`·메서드 부재)→보완(화이트리스트 `admin/*`·`new URL` 검증·GET/HEAD·Origin 검증)→직접 프로브로 해소 확인.
- **백엔드 블로커 해소(solsol-api 수정·재배포)**: 로그인 role 파생(`userHasRole`/TB_ROLE)·CORS allowlist·`/ops/seed-admin`(INSERT·멱등)로 `solsol_lms`에 staff `admin@solsol.dev`(userId 2002·owner·11메뉴 권한 all) 시드·`GET /api/admin/me` 신설. 재배포 Version `50ca3ad1`→`3016f42d`. 라이브 검증: 로그인 200·role=owner·`/api/admin/me` 200(권한11)·무토큰 401·CORS 허용/차단. INSERT만·무삭제.
- **프론트 실연동(Phase B2)**: 실 세션 부트스트랩(setSession·서버응답만 신뢰·setMockOwner 제거)·대시보드/사용자 3종 `/api/proxy/admin/*` 실 request(useMembersApi 어댑터)·나머지 도메인 목 폴백(회귀 0). qa blocker 0(중: 새로고침 세션 지속 해소).
- **보안 critical 해소**: 시드가 실 계정이 되며 `devLoginCode`(=실 비번 `Solsol!2026`)가 public 번들 노출될 뻔 → **데모 원클릭을 서버측 실 로그인(`/api/auth/demo-login`)으로 전환**(서버 보관 자격증명·클라 미노출), public 실비번 제거. 클라 번들 실비번 **0건**(빌드·라이브 3중 확인, 서버 청크만).
- **배포**(사용자 "공개 원클릭 데모 유지" 승인): solsol-admin `ce11a5d`(origin) → Pages 재배포 → **https://solsol-admin.pages.dev**. 라이브 스모크: demo-login 200(owner 세션)·session 200(권한11)·`/api/proxy/admin/admins` **200 실봉투**(시드 계정 2건·비번/해시 없음 = 프로덕션 Pages Function이 solsol-api 실도달)·무쿠키 401·클라 실비번 0. 데모 계정 `admin@solsol.dev`/`Solsol!2026`(dev·`NUXT_PREVIEW_DEMO=false`로 원클릭 404화 가능).

### §18 산출물
- solsol-admin: BFF `server/*`(apiClient·auth 4·proxy)·`useMembersApi`·실세션(auth store·login.vue·middleware)·대시보드/사용자 실 request. 커밋 `malgnsoft/solsol-admin` `ce11a5d` → **https://solsol-admin.pages.dev**(실연동).
- solsol-api(무버전 레포, 다른 워크스트림): 로그인 role 파생·CORS allowlist·`/ops/seed-admin`·`GET /api/admin/me`. 재배포 `3016f42d`. 관리자 시드 1계정(Aurora `solsol_lms`).
- 검증 기록: `docs/dev-validation/{solsol-api-review-round1,AD01-app-phaseB1-bff-integration,AD01-app-phaseB2-real-integration}.md`.

### §18 다음 단계
- 조회형 나머지 9도메인 `/api/proxy/admin/*` 순차 전환 + 목록 필터/정렬/페이지 서버 위임.
- 쓰기형(CRUD mutation): CSRF 방어 갖춘 전용 BFF 핸들러 후 배선.
- 백엔드 잔여(라운드1): 경로 `/api/auth/login` 정렬·F-2 계정열거·F-3 레이트리밋·F-5 공개경로·`/health/db` verdict·`SEED_ADMIN_PASSWORD` Pages secret화·로테이션.

## 19. 브랜드 사용자단(solsol-brand) mock 세션 영속화 + 실 API 연동 1단계(공개 읽기+폴백) + 배포

- **배경/결정(오너 지시)**: §13 브랜드 사용자단 배포 후 오너 지시로 ① 브라우저 심화검증 → a11y 1px-safe 보완(별도 반영) ② mock 세션 영속화 ③ **실 API 연동 페이즈 착수**. 실 연동은 오너 선택 "**연동 기반 + 읽기(폴백) 지금**"으로 범위 확정.
- **mock 세션 영속화**: `useAuth`를 `useState`(인메모리) → **`useCookie('brand_mock_session')`(SSR-safe) 기반**으로 전환. 새로고침·직접 URL 진입 시 로그인 유지(보호 페이지 미튕김), 미인증 게이트는 그대로. 런타임 실측: 하드 새로고침 후 `/billing` 200 유지 / 쿠키 없는 세션 `/account`→`/login` 리다이렉트(게이트 정상). 계약·시각 무변경.
- **실 API 연동 사전조사(실측)**: 브랜드 백엔드 **배포 확인** `https://solsol-brand-api.malgnsoft.workers.dev`(health/doc 200, §17 실배포). OpenAPI 3.1 계약 = **35 paths**, 사용자단 엔드포인트가 프론트 9 composable과 **1:1 매핑**(auth/account/agreements/plans/sites/billing/subscriptions/invoices/payments/contact/news). 엔벨로프 `{ok,data,meta}`/`{ok:false,error{code,message}}`, **X-Tenant 불필요**(master 단독). **현 DB 비어있음**(`/api/news`·`/api/plans`→빈), 계정 시드 미실행 → 인증·데이터 미충족.
- **구현(프론트 4파일, 무쓰기)**: `nuxt.config` `runtimeConfig.public.apiBase`(기본 workers.dev·`NUXT_PUBLIC_API_BASE`) + `app/composables/useApi.ts`(신규 `$fetch` 래퍼: 엔벨로프·Bearer·8s·실패 throw) + `useNews`/`usePlans`를 **실API 우선 + 빈/실패 시 mock 폴백**으로 전환(계약·페이지 무수정; `computed` 동기호출 제약은 `useAsyncData`→`useState` 백그라운드 로드로 해결; 스키마 미확정 대비 camel/snake 방어 매핑). **인증·쓰기는 mock 유지**(범위 밖·401 폴백). DB 시드되면 프론트 수정 없이 실데이터 자동 노출.
- **검증**: `pnpm build` PASS·eslint 0·1px 무영향. 라이브 API GET 실연동(현 빈 응답→조용히 mock 폴백)·런타임 `/news`·`/pricing` mock 정상·SSR 에러 0.
- **배포**: 커밋 `291f007`(origin=malgnsoft/solsol-brand main) → Pages `solsol-brand` 재배포. 프로덕션 **https://solsol-brand.pages.dev** 스모크: `/`·`/pricing`·`/news`·`/login` 200·`/billing` 302(보호)·mock 폴백 콘텐츠 정상.

### §19 산출물
- solsol-brand(origin=malgnsoft): `app/composables/useAuth.ts`(쿠키 세션)·`useApi.ts`(신규)·`useNews.ts`·`usePlans.ts`·`nuxt.config.ts`. 커밋 `291f007` → Pages `solsol-brand` **https://solsol-brand.pages.dev**. (a11y 1px-safe 스윕 ~147속성은 §13 커밋 `ff377b4`에 포함.)

### §19 다음 단계
- **인증·쓰기 실연동**(login/signup/account/sites/subscriptions/payments) — 전제: 브랜드 API **DB 시드 + 계정 시드 실행 + 계약 프리즈**(백엔드 세션 소관), 보안 게이트(서버 인증/세션·IDOR·인증코드 서버검증·레이트리밋·PAN 마스킹·정보통신망법) 확인.
- **백엔드 조율**: news/plans 등 실데이터 시드 시 프론트 자동 노출. 실 스키마 필드명 확정 시 `mapNews`/`mapPlan`만 조정.

## 20. 브랜드 관리자단(solsol-brand-admin) 목업 모드 원클릭 로그인 버튼 추가 + 재배포

- **변경**: `app/pages/auth/login.vue` — 목업 모드(`isMock`, `NUXT_API_BASE` 미설정) 조건에서만 '슈퍼관리자/지원팀 원클릭 로그인' 버튼 노출. typecheck GREEN·빌드 PASS.
- **배포**: 커밋 `addddf8`(origin=malgnsoft/solsol-brand-admin main) → `pnpm build` → Pages `solsol-brand-admin` 재배포(alias `https://1127c9a5.solsol-brand-admin.pages.dev`). NUXT_API_BASE 미설정 유지(목업 모드), NUXT_SESSION_SECRET 유지.
- **스모크**: `/auth/login` 200 + '원클릭'·'슈퍼관리자로 로그인' 문자열 노출 / `POST /api/admin/auth/login`(superadmin@solsol.local) 200 + 세션쿠키(`sbrand_admin_sess` HttpOnly·Secure·SameSite=Lax)·`{"ok":true}` 확인. 프로덕션 **https://solsol-brand-admin.pages.dev**.

## 21. 브랜드 사용자단(solsol-brand) [TEST-ONLY] 인증번호 완화 + 배포

- **오너 지시(테스트 편의)**: 테스트 기간 동안 회원가입·결제이메일 변경의 **인증번호를 아무 값이나 허용**(비어있지 않으면 통과).
- **변경(2파일)**: `app/pages/signup.vue`(인증코드 확인) + `app/composables/useAccount.ts`(`verifyCode`·`changeBillingEmail`) — `400039` 고정 검증 → `trim().length > 0` 통과로 완화. 전부 `[TEST-ONLY]` 주석(실 API 연동 시 서버 검증 대체·완화 제거 필수, security gate). 빈 입력은 여전히 "입력해 주세요" 유지.
- **검증**: `400039` 잔여 참조 0, `pnpm build` PASS, eslint 0 errors.
- **배포**: 커밋 `ed77464`(origin=malgnsoft/solsol-brand) → Pages `solsol-brand` 재배포 **https://solsol-brand.pages.dev**. 스모크 `/`·`/signup`·`/login` 200·`/account-email` 302(보호).
- **주의**: 테스트 전용 완화 — 실 API 연동/운영 전 반드시 서버측 인증코드 검증으로 원복.

## 22. 브랜드 운영자단(solsol-brand-admin) 목업 → 실 API(brand-api) 전환 + 운영자 시드 + 배포

- **오너 지시**: brand-api에 추가된 일회용 운영자 시드 엔드포인트를 배포하고, **배포 → 시드 → brand-admin 실 API 연결 → 검증**을 페일세이프(시드·로그인 검증 성공 전 `NUXT_API_BASE` 미설정)로 실행.
- **brand-api 배포**: `src/routes/ops.ts`(`POST /ops/seed-admin` 멱등 시드)·`src/env.d.ts`(`SEED_ADMIN_PASSWORD?`) 커밋 `1c2967b`(origin=malgnsoft/solsol-brand-api main) → `wrangler deploy` **https://solsol-brand-api.malgnsoft.workers.dev**. 시크릿 `SEED_ADMIN_PASSWORD` 주입(값 무노출)·`OPS_SECRET` 세션용 재설정(기존값 미보관 → /ops 게이트용 신규 발급). typecheck GREEN.
- **운영자 시드**: `POST /ops/seed-admin`(X-Ops-Secret 게이트) → `superadmin@solsol.local`·`support@solsol.local` **seeded:true**(신규). 재호출 시 **exists:true**(멱등 확인).
- **페일세이프 게이트**: `POST /admin/auth/login`(superadmin) → **200 + admin JWT**(typ:admin·role:superadmin) 확인 후에만 다음 단계 진행.
- **근본 결함 발견·수정(brand-admin)**: Cloudflare Pages/Workers는 env 바인딩을 `process.env`로 노출하지 않아, `useRuntimeConfig()`(event 미전달)로는 Pages secret이 runtimeConfig에 반영되지 않음 → `apiBase` 빈 값 → BFF가 mock 폴백(로그인 user.id=`mock-*`, `/api/admin/sites`→503). server 5파일(`[...path].ts`·`auth/login|logout|session`·`utils/session.ts`)을 **`useRuntimeConfig(event)`**(원본 malgn-noti-admin과 동일 패턴)로 수정. 부수 효과로 세션 서명이 DEV_FALLBACK_KEY가 아닌 실 `NUXT_SESSION_SECRET`으로 전환됨. typecheck GREEN.
- **실 API 연결**: Pages secret `NUXT_API_BASE`·`NUXT_PUBLIC_API_BASE` = `https://solsol-brand-api.malgnsoft.workers.dev` 주입 → `pnpm build` → Pages 재배포.
- **실연동 스모크(프로덕션 https://solsol-brand-admin.pages.dev)**: `/auth/login` 200 + **원클릭 목업 버튼 비노출**(isMock=false, SSR payload에 실 apiBase 반영) / `POST /api/admin/auth/login`(superadmin@solsol.local) → 200 + 세션쿠키·**user.id=`"2"`**(실 DB 시드 계정) / `GET /api/admin/sites`(세션) → **200**(이전 503 해소), 어댑터 정규화(snake_case) 정상 — dev 사이트 1건 실 Aurora 응답(500 아님).
- **정리**: `SEED_ADMIN_PASSWORD`(brand-api) **삭제**(시드 완료 후 안전 — 계정 존재 시 멱등 스킵).

### §22 산출물
- solsol-brand-api(origin=malgnsoft): `src/routes/ops.ts`·`src/env.d.ts` 커밋 `1c2967b` → Worker 재배포 **https://solsol-brand-api.malgnsoft.workers.dev**.
- solsol-brand-admin(origin=malgnsoft): `server/api/admin/[...path].ts`·`auth/login.post.ts`·`auth/logout.post.ts`·`auth/session.get.ts`·`utils/session.ts` — `useRuntimeConfig(event)` 전환. Pages 재배포 **https://solsol-brand-admin.pages.dev**.

### §22 다음 단계(잔여)
- **초기 비밀번호 변경**: 시드 계정(`superadmin`/`support`) 초기 비번(`SEED_ADMIN_PASSWORD`로 주입) 최초 로그인 후 즉시 변경 필수.
- **brand-admin 코드 커밋·푸시**: `useRuntimeConfig(event)` 수정분(현 working tree 배포·미커밋) → origin=malgnsoft/solsol-brand-admin main 커밋 필요.
- **CF WAF Rate Limiting**: `/admin/auth/login`(brand-api·brand-admin BFF)에 엣지 레이트리밋 적용(인메모리는 Isolate 간 미공유).
- **TOSS·Phase1 어댑터**: 결제(TOSS) 시크릿·Phase1 미매핑 도메인 어댑터는 별도(docs/DEPLOY.md TODO).
- **OPS_SECRET**: 세션용 신규 발급값 유지 — 다음 /ops 사용 주체가 재설정 후 사용(기존값 미보관).

## 23. 크리에이터 관리자단(solsol-admin) 조회형 전 도메인 실 API 전환 (2차 배치)

- **한 줄**: §18 실연동 1차(대시보드·사용자)에 이어 **나머지 조회형 도메인 전체**(상품 7유형·콘텐츠·판매·마케팅·운영·사이트디자인·정산·설정·통계)를 BFF 프록시 `/api/proxy/admin/*` 실 request로 전환. 병렬 3그룹(P/S/O)·qa 게이트(blocker 0)·표시 정정 후 재배포.
- **전환 패턴**: 도메인 어댑터 컴포저블 **9종**(`use{Products,Contents,Sales,Marketing,Ops,Site,Settlement,Settings,Stats}Api`) — 프록시 GET(httpOnly 세션)→응답 shape 매핑→실패/빈응답 시 **기존 목 폴백**(회귀 0).
- **라이브 실증**(demo-login owner 세션): 실데이터 = 쿠폰 2·게시판 3·상품 7유형·콘텐츠·주문 1·정산 프로필·통계 KPI·site basic/footer·settings basic/player. 빈폴백(정상) = 환불·팝업·캠페인·설문·정산내역·수료증·공지·템플릿·툴·메뉴/페이지 등. **목유지(날조 0·정직 보고)** = 멤버십(등급 tier)·settings/notification(매트릭스 불일치)·site/meta(키 불일치)·통계 비-KPI·상세/쓰기.
- **qa(blocker 0)** + 표시 정정: 쿠폰 code 파생 오인→`-`, 주문 유형 축약→미확정, 이중마스킹 정리(무해·안전방향). SSRF 가드(화이트리스트 `admin/*`·`..`방어·GET/HEAD) 무손상. 마스킹 유출 0(백엔드 마스킹 신뢰).
- **배포**: solsol-admin 커밋 **`f89e790`**(`ce11a5d..f89e790`, origin=malgnsoft) → Pages 재배포 **https://a152a3ca.solsol-admin.pages.dev** → 프로덕션 **https://solsol-admin.pages.dev**. 라이브 스모크: demo-login 200 · `/api/proxy/admin/coupons` 200(2건, 응답에 code 필드 없음=파생코드 날조 실증) · `/boards` 200(3건) · 무쿠키 401 · 페이지 200. 백엔드 마스킹(`M*****r`·`q****@…`) 실봉투 확인.

### §23 산출물
- solsol-admin: 어댑터 9종 + 도메인 목록/조회 페이지 실 전환(대부분 목록). 커밋 `malgnsoft/solsol-admin` `f89e790` → 재배포 https://solsol-admin.pages.dev.
- 검증 기록: `docs/dev-validation/AD01-app-phaseB2b-read-domains.md`.

### §23 다음 단계
- **상세(detail) 실 전환**(유형별 부속·주문/쿠폰 상세 조인) → **쓰기형 CRUD**(프록시 GET 전용 → CSRF 방어 전용 BFF 쓰기 핸들러 후 생성/수정/삭제/상태변경) → 목록 필터·정렬·페이지 서버 위임. site/meta 키 컨벤션·notification 매트릭스 API·멤버십 등급 조회 후속.

## 24. 크리에이터 사용자단(solsol) ↔ 실 API(solsol-api) 전체 결선(A조회·인증/B쓰기/C결제 승인대기) + 안전 go-live 배포

- **한 줄**: FR01 사용자단(§9, mock 폴백)을 실 API(solsol-api)에 **전 도메인 결선** — 연결가능성 검토 → dev 테넌트 도메인 시드 → Phase A/B/C 구현·실 API E2E(전 Phase GO·blocker 0) → **안전 결선 go-live**(사용자단 프론트·백엔드 재배포). 결제(PG)·업로드(R2)·쿠키 크로스도메인은 오너 확인 잔여.
- **연결가능성 검토**(api-dev+frontend 양측 계약 대조): 경로(`/api/*`+`/auth`/`/me`/`/tenant`)·엔벨로프(`{ok,data,error}`+meta)·인증(Bearer·소셜콜백·refresh)·CORS 구조 정합 확인. 핵심 갭 = 테넌트 식별(schema-per-tenant)·`?site_id` mock 잔재·필드명·결제 staging-gate.
- **Phase 0 선행(시드)**: dba `db/seed/dev_domain_seed.sql`(24테이블/68행, `solsol_lms` 멱등) — 카테고리5·상품 7유형+부속·강의/차시·게시판(공지/자유/FAQ/**qna**)·쿠폰·사이트config. api-dev `/ops/domain-seed`(dev 가드) + 응답 필드 병기(`thumbnailUrl/avatarUrl/role`). 실 Aurora dev 테넌트 적용(errors 0).
- **Phase A(조회·인증)**: 프론트 `apiBase` env + **폴백정책 플래그**(apiBase 설정 시 mock 은폐 금지) + `site_id` 제거(12 composable) + 필드 매핑 어댑터 + **SSR-safe 테넌트(`X-Site-Host` 헤더·`useState` slug 공유·홈 SSR 방어·`NUXT_PUBLIC_TENANT_SLUG` 오버라이드)**. 백엔드 테넌트 해석 `X-Tenant>X-Site-Host(domain)>Host>dev폴백(localhost·*.workers.dev·빈값, prod 차단)` + mock 콜백 dev 허용. **E2E round2 GO**(홈 SSR 200·브라우징 실데이터·mock콜백→/me 루프).
- **Phase B(쓰기)**: 후기·찜·쿠폰·문의·게시글/댓글·진도 6도메인 mock→실 apiFetch 전환+매핑. **E2E GO**(생성→재조회 영속). 업로드(R2)·미확정 조회는 계약공백 유지.
- **Phase C(결제·구독)**: billing shape 통일(`{items}`)·orders/summary 매핑·**승인대기(pending) UX**(`{success:false,pending:true}` 분기·완료 단정 금지)·구독 pending. **E2E GO**(PG 미해제·실결제 0).
- **품질 게이트**: 각 Phase qa 실 API E2E + Phase A security-reviewer(CORS·쿠키·인증·마스킹). 전체 `pnpm typecheck` 0·mock 회귀 0. blocker 해소(SSR 테넌트·mock 콜백·카드마스킹 형태·게시판/후기 매퍼 필드명 D-1/D-2·내주문 조인 D-3·qna 시드 D-4·가입 멱등 R2-1).
- **안전 go-live 배포**(사용자 승인 — 결제·R2 제외):
  - 백엔드 `solsol-api`: git 초기화·커밋 **`92ad1bd`**→malgn 푸시(빈 레포) + **워커 재배포 version `ec5c247f`** → https://solsol-api.malgnsoft.workers.dev. CORS allowlist에 `solsol.pages.dev`(+프리뷰) 추가 → **라이브 검증: solsol.pages.dev Origin 허용·attacker.test 거부**(구버전 임의오리진 취약점 해소). 시드 재적용(qna 포함 errors 0). 라이브 `/ops` 403(prod 차단 정상).
  - 프론트 `solsol`: 결선분(app/·nuxt.config)만 커밋 **`f56a8b1`**(mockup 외부변경 제외)→origin(malgnsoft/solsol) 푸시 + `NUXT_PUBLIC_API_BASE`+`NUXT_PUBLIC_TENANT_SLUG=dev` 빌드·배포 + CF Pages env 설정 → **https://solsol.pages.dev**. 스모크: 홈 SSR 200(테넌트 dev 해석)·`/courses` 실 시드 상품 8건(클라 페치·CORS 허용)·보호 라우트 302/401 가드.
- **잔여(오너 확인)**: ①**PG staging-gate 해제**(실결제·실환불 비가역 CMP-06 — 미해제=승인대기 유지) ②**R2 버킷**(첨부·이미지·아바타 업로드 스텁) ③**refresh 쿠키 크로스도메인**(`.pages.dev↔.workers.dev` 서드파티 쿠키 — 동일도메인 정렬/프록시 전략) ④localStorage access(XSS·중) ⑤R2-1 UNIQUE 제약 검토·D-3 스냅샷 컬럼 후속.

### §24 산출물
- 프론트 `solsol`: 14 composable 실 API 전환(폴백플래그·X-Site-Host·필드매핑·승인대기), `nuxt.config`(tenantSlug). 커밋 `malgnsoft/solsol` `f56a8b1` → 배포 https://solsol.pages.dev(실 API 연결).
- 백엔드 `solsol-api`: 테넌트(X-Site-Host)·mock콜백·`/ops/domain-seed`·필드병기·CORS·orders조인·가입멱등. git 초기화 커밋 `92ad1bd`(malgn) → 워커 `ec5c247f`.
- 시드: `dev_domain_seed.sql`(24테이블, qna 포함) 실 Aurora dev 테넌트 적용.
- 검증 기록: `docs/dev-validation/wiring-phase{A-round1,A-round2,BC-round1}.md`.

### §24 다음 단계
- 오너 확인 후: PG staging-gate 단계 해제(toss 웹훅·staging 선검증) → 결제 승인대기→실결제. R2 버킷·업로드 배선. refresh 쿠키 동일도메인 전략(커스텀 도메인 정렬 or Pages 프록시).
- 실 테넌트 프로비저닝(현재 `dev` 데모 테넌트) — 커스터머별 사이트·domain 매핑 시 host 기반 테넌트 해석 자동. 업로드/강의실·수료증 스키마 확정 후 잔여 조회 결선.

## 25. 브랜드 운영자단(solsol-brand-admin) Phase1 실 API 어댑터 실배포 + brand-api seed-admin 하드닝

- **한 줄(§23 계열)**: §22(목업→실 API 전환)에 이어 **Phase1 조회 도메인**(credits·cs·news·stats)을 BFF 어댑터로 실 API 전환. app 표기 경로(`cs`·`notices`·`stats/dashboard`·`credits/:id`)를 brand-api 실 마운트(`contact`·`news`·`stats/overview`·`credits?siteId=`)로 **경로 정규화**(신규 엔드포인트 없이 기존 라우트 재사용) + 응답 camelCase→snake_case 매핑 + 요청 body 역매핑(notices `published_at`→`publishedAt`). 백엔드 갭 도메인은 **허구 데이터 생성 없이** 빈배열/0/null 로 정직 반환(500 없음).
- **brand-admin 배포**: `server/utils/adapt.ts`·`server/api/admin/[...path].ts` 커밋 **`4886d3f`**(origin=malgnsoft/solsol-brand-admin main) → typecheck GREEN → `pnpm build` → Pages 재배포 alias **https://88ecfdf9.solsol-brand-admin.pages.dev** → 프로덕션 **https://solsol-brand-admin.pages.dev**. NUXT_API_BASE 등 기존 시크릿 유지(실 API 모드).
- **brand-api 하드닝**: `src/routes/ops.ts` seed-admin 프로덕션 방어 커밋 **`266b6b1`**(origin=malgnsoft/solsol-brand-api main) → `wrangler deploy` Version **`2392abe3`** → https://solsol-brand-api.malgnsoft.workers.dev. prod(`APP_ENV=production`)에서 `SEED_ADMIN_PASSWORD` 미설정 시 **403(존재·사유 비노출)** — OPS_SECRET 통과자에게도 세부 미제공. 비프로덕션은 400+안내 유지. 부트스트랩 종료 후 라우트 제거/OPS_SECRET 로테이션 폐기 주석 추가.
- **실연동 스모크(https://solsol-brand-admin.pages.dev, superadmin 세션)**: 로그인 200(실 DB user.id=`"2"`). Phase1 4경로 세션 200 — `/api/admin/credits` 200(빈배열·집계 API 미구현 우아처리)·`/api/admin/cs` 200(빈배열)·`/api/admin/notices` 200(빈배열)·`/api/admin/stats/dashboard` 200(실 스냅샷 active_sites=1·new_signups=1·delta=null·mrr_series/signup_series=[] 정직). **500·404 0건**. Phase0 회귀 `/api/admin/sites` 200(dev 사이트 1건). 미인증 가드: 5경로 전부 **401**(가드 정상). 시크릿 값 무노출.

### §25 산출물
- solsol-brand-admin(origin=malgnsoft): `server/utils/adapt.ts`·`server/api/admin/[...path].ts` 커밋 `4886d3f` → Pages 재배포 https://solsol-brand-admin.pages.dev(실 API 모드).
- solsol-brand-api(origin=malgnsoft): `src/routes/ops.ts` 커밋 `266b6b1` → Worker Version `2392abe3` → https://solsol-brand-api.malgnsoft.workers.dev.

### §25 다음 단계 (백엔드 갭 — 별도 티켓)
- 신규 백엔드 엔드포인트 필요분: 크레딧 사이트별 잔액 목록 집계·수동 조정(멱등키), 문의 상태 전환(PATCH /cs/:id/state), 공지 단건 상세(본문 포함), 통계 시계열(mrr/signup)·전기간 delta·churn. 확보 시 어댑터 빈값→실값 승격.
- seed-admin: 실 운영자 계정 유입 확인 즉시 라우트 제거 또는 OPS_SECRET 로테이션+마운트 해제로 완전 비활성.
