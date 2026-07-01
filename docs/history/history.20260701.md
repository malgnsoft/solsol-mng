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
