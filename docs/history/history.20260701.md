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
