# BR01 (브랜드 사용자단) — 검증위원회 T3 화면 트랙 (committee-r01)

| 항목 | 내용 |
|------|------|
| 대상 | `/Users/dotype/Projects/solsol-brand/app` (공개읽기 실연동 + mock 폴백, 인증/결제=구현 라운드) |
| 기준(SoT, 읽기전용) | `docs/validation/00_화면목록.md §3.3 BR01`(39) · `03_brand-site.md` · `04_정책요약.md` · `05_정책설계서.md`(확정 16건) · `_exports/png/brand-site/` |
| 방법 정본 | `00_검증가이드.md`(권위 분리·[추정] 규칙) · `01_검증체크리스트.md` |
| 기존 결함표(R1) | `docs/dev-validation/brand-site-round1.md` — 재판정·중복 회피 |
| 검증자 | QA (검증위원 T3 — 정본·앱·기존 결함표 무수정) |
| 검증일 | 2026-07-02 (KST) |
| 빌드 | `pnpm build` **PASS (EXIT 0, ✨ Build complete)** — 실행 확인 |
| 무수정 확인 | 정본(`docs/validation/**`)·앱·R1 결함표 열람만. 신규 파일(본 파일)만 생성. |

> 심각도: 상(blocker)/중(major)/하(minor). 권위 분리(가이드 §2): 존재·IA=화면설계서 / 문구=PNG / 동작·정책=04·05(05 최우선) / 토큰=스타일가이드. `[추정]`은 권위 아님.

---

## 1. 화면ID 커버리지 (BR01 39 − 제외 3)

- SoT 39 − 검증제외 3(가이드 §5: `S-BR01-0103-001` 프로덕트=미설계 / `0104-001` 데모보기 / `0105-001` 주요기능=실사이트 대체, ➖) = **검증대상 36**.
- 구현 매핑: 36/36 존재(R1 매핑 유지, 재확인). **누락 0.** 커버리지 100%.
- 모달/팝업 6건(§3.3.2 5 + §3.3.3 C01) 존재 재확인: `_pu` 4건 구현(완료 컨펌·도메인체크·구독취소완료·인증코드 인라인), C01(약관 공유 LPU) 미구현(D02).
- 추가(SoT 외) 1건: `pricing-light.vue` — 진입 링크 없음(orphan). grep 확인: 실참조는 `usePlans.ts` 주석뿐(D04).
- 참고: 태스크 언급 "index 카탈로그·page-list·design-guide"는 실앱 라우트에 부재(목업 잔재) — 실앱 index.vue = `S-BR01-0101-001` 메인 랜딩. 카탈로그성 페이지 없음.

---

## 2. R1 결함 재판정 (승계·해소)

| R1 ID | 요지 | 재판정 | 근거(파일:라인) |
|-------|------|--------|-----------------|
| DEF-01 | pricing-purchase 결제실패 버튼 상시 노출(verbatim 위반) | **해소(FIXED)** | `pricing-purchase.vue:39` — `simulateFail = route.query.fail === '1'` 쿼리 트리거로 대체, 화면 노출 버튼 없음(라인 62~127 전수 확인) |
| DEF-02 | `/contact-history-detail` 미들웨어 미보호(PII 노출 갭) | **해소(FIXED)** | `01.require-auth.global.ts:21` — PROTECTED 배열에 `/contact-history-detail` 등록됨 |
| DEF-03 | C01 약관 상세보기 공유 모달 미구현 | **잔존 → D02** | signup/my-site-create chevron이 전체페이지 NuxtLink |
| DEF-04 | 인증코드 발송 PU UI타입(LPU vs 인라인) 불일치 | **잔존 → D03** | signup `v-if="codeSent"` 인라인 / account-email 인라인 단계 |
| DEF-05 | pricing-light orphan(SoT 미등재·진입링크 없음) | **잔존 → D04** | 앱 내 라우트 참조 0 |
| DEF-06 | upgrade 쿼리 흐름 미소비 | **변형 잔존 → D05** | pricing-purchase는 소비하나 pricing.vue가 미전달 |

---

## 3. 결함표 (신규·승계)

| 결함ID | 화면ID | 검증축 | 심각도 | 재현/현상 → 기대 vs 실제 | SoT근거 | 제안·담당 |
|--------|--------|--------|--------|---------------------------|---------|-----------|
| BR01-cttee-r01-D01 | S-BR01-0301-002 / S-BR01-0302-003 | 정책(05 C-3) | **중** | **재현**: 회원가입/새비번에 `abcd123!`(영문소문자+숫자+특수=3종, 대문자 없음) 입력. **기대**(C-3): "영문·숫자·특수문자 3종 조합, 8~16자" → 3종이므로 **허용**(05 측정: 8자 3종=허용). **실제**: 정규식 `(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])`가 대문자를 필수로 요구 → **차단**(4조건). 안내 문구도 "영문 대소문자·숫자·특수문자 조합"으로 통일 문구와 불일치. | `05_정책설계서.md:28,218,222`(C-3 확정=영문·숫자·특수 3종, 문구 통일) · 가이드 §4-1 C-3 | 정규식을 3종(영문 대소구분 없음+숫자+특수) 8~16자로 완화, 안내 문구를 `"영문·숫자·특수문자 3종 조합, 8~16자"`로 통일. `signup.vue:9,90,157` · `password-new.vue:13,18,59`. 담당: frontend-developer. |
| BR01-cttee-r01-D02 | S-BR01-C01 | 존재/공통컴포넌트 | **중** | 공유 약관 상세보기 모달(C01, LPU) 미구현. signup·my-site-create의 약관 chevron이 모달 대신 `/terms`·`/privacy`·`/marketing-consent`·`/terms-paid` 전체페이지 NuxtLink로 이동. (목업 baseline도 모달 없음 → SoT-목업 갭) | `00_화면목록 §3.3.3`(C01 약관 상세보기 LPU) · `03_brand-site.md §회원가입 약관 상세보기(공통)` | verbatim 위반 아님. **오너/기획 판정 이월**: (a) C01 모달 신설 or (b) SoT를 "페이지 이동"으로 개정(택1, 불일치 해소). `signup.vue:171,172,174` · `my-site-create.vue:148,149`. |
| BR01-cttee-r01-D03 | S-BR01-0301-002_pu01 / S-BR01-0901-002_pu01 | 존재/UI타입 | **하** | 인증코드 발송 PU가 SoT상 LPU(오버레이)이나 구현은 인라인 확장(`signup.vue v-if="codeSent"`)·인라인 단계(account-email). 목업 baseline 답습. 기능(3분 표시·발송·검증)은 동작. | `00_화면목록 §3.3.2`(_pu01 UI타입=LPU, p034/p134) | 목업 정합이므로 verbatim 통과. SoT UI타입(LPU) vs 구현(인라인) 표기 불일치는 기획 확인 후 SoT 주석 정정 또는 후속 LPU화. |
| BR01-cttee-r01-D04 | pricing-light | 커버리지 | **하** | SoT BR01 미등재 페이지 `pricing-light.vue` 존재(orphan, 진입 링크 0 — `usePlans.ts:4` 주석 참조만). | `00_화면목록 §3.3`(pricing-light 없음) | 목업 대응물 존재 시 유지 가능. SoT 등재하거나 미사용이면 라우트 정리 판정(기획). |
| BR01-cttee-r01-D05 | S-BR01-0601-001 → 0601-002 | 인터랙션 | **하** | **재현**: pricing.vue에서 임의 플랜 "구매하기" 클릭. **기대**: 선택 플랜/주기(+업그레이드 시 upgrade)로 pricing-purchase 진입. **실제**: 3개 "구매하기" NuxtLink 모두 쿼리 없는 `/pricing-purchase`(`pricing.vue:111,141,171`) → pricing-purchase가 항상 `basic·monthly·신규` 기본값 진입(`pricing-purchase.vue:10~12`), 플랜/주기/업그레이드 선택 유실. pricing-purchase 소비부(upgrade/plan/cycle/credit)는 구현됨. | `00_화면목록 §3.3`(0601-002 "플랜 업그레이드·일할 변형") | 목업 verbatim 정합이나 기능 갭. pricing.vue "구매하기"에 `:to="{path:'/pricing-purchase',query:{plan,cycle,upgrade}}"` 배선. mock 단계 허용 → 백엔드 실연동 라운드 이월. 담당: frontend-developer. |

### 통과(결함 아님) 재확인
- **M-10(마이페이지 인가경계)**: `01.require-auth.global.ts:14~25` PROTECTED에 my-sites/my-site-create/my-product/my-product-extend/billing/contact-history/contact-history-detail/pricing-purchase/account/account-email **전수 등록**. 비로그인 → `/login?redirect=`. **PASS**.
- **C-5(단방향 Alert→토스트/컨펌)**: `window.alert`/`confirm()` 잔존 0(grep 확인). 컨펌은 양방향 in-component 모달만(구독취소·계정삭제·도메인체크). **PASS**.
- **C-6(본인화면 마스킹)**: 카드번호 `신한카드 **** 1234`(`pricing-purchase.vue:92`, useBilling) 부분마스킹·비번 `••••` 마스킹. 이름/이메일 과마스킹 없음. **PASS**.
- **M-1(무료체험 미운영)**: signup/pricing에 14일 체험 UI 없음(R1 확인 유지). **PASS**.
- **M-6(약관 JSON SoT)**: terms/privacy/marketing 등 `app/data/legal.json` 렌더. **PASS**.
- **빌드**: `pnpm build` EXIT 0. **PASS**.

---

## 4. 이월(carry-over) — 결함 아님(상태 명시 필요)

| 항목 | 성격 | 근거 | 조치 |
|------|------|------|------|
| **[TEST-ONLY] 인증번호 완화(§21)** | **테스트 의도 상태**(결함 아님) | `signup.vue:6,68`(코드 비어있지 않으면 통과) · git `ed77464` · 동일 패턴 account-email | **운영 전 원복 필수** — 실 API 서버 검증으로 교체. security-reviewer 공유 대상. |
| color-contrast(접근성) | 오너/디자인 판정 이월 | 회색 텍스트 `#aaa`(≈2.3:1)·`#bbb` on white 다수(pricing-purchase 안내문·breadcrumb 등) — WCAG AA 4.5:1 미달 소지 | 색=스타일가이드/PNG 권위·목업 verbatim이라 결함 단정 안 함. 오너/디자인 판정. |
| 모바일 반응형 | 오너 판정 이월 | 목업 1920px 고정(`w-[1920px]`) → 반응형 미지원(R1도 미검증) | 데스크톱 고정 baseline. 반응형 필요 여부 오너 판정. |
| C01 약관 모달(D02) | 오너/기획 판정 이월 | §3.3.3 vs 목업 갭 | 모달 신설 vs SoT 개정 택1. |

---

## 5. 종합 판정

### 트랙 판정: **GO (조건부)** — blocker(상) 0건, 종료조건 충족

- 커버리지 36/36(100%), 빌드 PASS, M-10·C-5·C-6·M-1·M-6 정합, R1 DEF-01·DEF-02 해소 확인.
- **중(major) 2건은 배포 전 처리 권고**:
  - **D01(C-3 비밀번호 정책 위반)**: 05 최우선 권위 위반 — 정책상 허용되는 비밀번호가 차단됨. 최우선 수정.
  - **D02(C01 약관 모달)**: SoT-목업 갭 — 오너/기획 판정.
- 하(minor) 3건(D03·D04·D05)은 기획 확인 또는 백엔드 실연동 라운드 이월.

### 심각도별 집계
- **상(blocker): 0건**
- 중(major): 2건 (D01, D02)
- 하(minor): 3건 (D03, D04, D05)
- 해소 확인: 2건 (R1 DEF-01, DEF-02)

### 이월 항목 명시
- **[TEST-ONLY] 인증번호 완화(§21)** — 테스트 의도 상태, **운영 전 원복 필수**(security-reviewer 공유).
- **오너 판정 이월**: color-contrast(#aaa/#bbb 저대비) · 모바일 반응형(1920 고정) · C01 모달(D02).

### 검증 범위 주석
- 정적(정본·9축·정책·M-10·폴백경계) + 빌드 실행. 런타임 클릭 플로우·픽셀 정밀 토큰·스크린리더 심층은 후속(dev 서버) 대상.
- 정본·앱·R1 결함표 무수정. `_ledger.md` 미접촉. 본 파일만 신규 생성.
