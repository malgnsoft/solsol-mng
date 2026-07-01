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

## 산출물

- 코드: `server/api/screens/[id].patch.ts`·`index.get.ts`·`server/utils/screenStatus.ts`(§3), `app/utils/wbsData.ts`·`app/pages/wbs.vue`·`app/pages/index.vue`·`server/db/seed.sql`(§4·§5).
- 라이브 D1(`solsol-project`): `screen_status` FR01 7행 복구, `wbs_item` 스텝 재편(4:13·5:5·6:8·7:19·8:18) + 스파이크 5행.
- 커밋 `cf5ecd6`(screens fix)·`8cf245a`(wbs spike 신설)·`a7bad92`(spike 설계–구현 사이 이동·이번주 완료) → `malgnsoft/solsol-mng` → Pages `solsol-mng` 배포.
- 최종 WBS 8단계: 4 목업 → **5 설계 → 6 스파이크(1차 개발·이번주 완료) → 7 구현** → 8 운영·계약.

## 다음 단계

- 회원 모델 변경 반영해 인증 API/프론트 재작성 → mock→실 provider 교체 → 인증 QA 라운드 → 배포.
- 스파이크(Step 5) 항목 진행에 따라 진척률 갱신(현재 스텝5 평균 27%).
