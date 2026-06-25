# 2026-06-25 — 브랜드 사이트(BR01) 전체 목업 + 크리에이터 사용자단(FR01) 목업/검증 + 화면 페이지 D1화

> **한 줄 요약** — 에이전트팀으로 ① 크리에이터 사용자단(FR01) 46화면 목업 + FR01 검증(게이트 미통과 기록 후 배포), ② 관리 허브 `/screens`(화면) D1 편집형 전환 + 화면 목록 SoT 재생성 + FR01 목업 링크 연결, ③ **브랜드 사이트(BR01) 39화면 + 모달 6 전체 목업**(핸드오프 v2) + BR01 검증(**게이트 통과**) + Pages 배포, ④ CLAUDE.md에 목업 검증 절차(라운드) 추가.

## 1. 크리에이터 사용자단(FR01) 목업 + 검증

- **빌드**(frontend-developer): `solsol/mockup/` Nuxt 3 + Tailwind + Nuxt UI, Customer Front **46 화면** + 레이아웃 default/mypage/player + 화면ID 인덱스. `malgnsoft/solsol` 첫 푸시 → Pages `solsol-mockup` 배포(<https://solsol-mockup.pages.dev>).
- **검증**(qa, FR01 정본): ❌ 게이트 미통과 — 커버리지 40/42, blocker 5(쿠폰 정률 C-4 4파일 + 프로필 모달)·major 5·minor 3. 결과 [docs/dev-validation/FR01-customer-front-round1.md](../dev-validation/FR01-customer-front-round1.md).

## 2. 관리 허브 `/screens`(화면) — D1 편집형 + SoT 재생성

- **D1 전환**: `screen_status` 테이블(화면ID별 design·publish·dev·test + mockup/dev URL) + 0003 마이그레이션 + `server/utils/screenStatus`(D1+인메모리) + `GET /api/screens`·`PATCH /api/screens/[id]`. `/screens` 클릭 토글·URL 입력으로 D1 영속. 페이지명 "페이지"→"화면".
- **화면 목록 SoT 재생성**(`00_화면목록.md` v1.2): 본화면 + 실제 모달 `_pu`(§3.x.2) + 공유 모달 C##(§3.x.3). 집계 일치 — FR01 42행·14모달 / AD01 103행·58모달 / BR01 39행·6모달.
- **FR01 목업 링크 연결**: 42화면+6모달에 solsol-mockup 라우트 mockupUrl + publish=true.

## 3. 브랜드 사이트(BR01) 전체 목업 + 검증 + 배포

- **빌드**(frontend-developer): `solsol-brand/mockup/`(기존 Nuxt 앱 확장)에 핸드오프 `design_handoff_solsol_brand_v2` 기준 **BR01 39화면 + 모달 6**(인증/회원가입·내사이트·공지·가격/결제·문의·마이페이지·약관5·시스템5 + AppModal 공용 6). red #ED1B23·Pretendard·1920px. 화면ID 카탈로그 인덱스. `nuxt generate` 98라우트.
- **검증**(qa, BR01 정본): ⭕ **게이트 통과** — 커버리지 36 있음·3 N/A(미설계/실사이트 대체)·누락 0, 모달 6/6. ❌상 0 · 🔺major 4(무료체험 14일 문구 M-1·인증코드 3→10분 C-2·성/이름 2단·서브타이틀 카피)·minor 6. 결과 [docs/dev-validation/BR01-brand-site-round1.md](../dev-validation/BR01-brand-site-round1.md).
- **배포**: `malgnsoft/solsol-brand`(`349ba9e`) → Pages `solsol-brand-mockup`. 스모크 전 라우트 200. <https://solsol-brand-mockup.pages.dev>

## 4. 검증 절차 문서화

- CLAUDE.md `개발–검증 연동`에 **목업/구현 검증 절차(라운드)** 신설 — 구현→qa 라운드(커버리지·9축·05 6건·결함표)→게이트(❌상 0)→`docs/dev-validation/` 기록, 화면ID 1:1 추적키.

## 산출물

- `malgnsoft/solsol`(`mockup/` FR01 46화면) · <https://solsol-mockup.pages.dev>
- `malgnsoft/solsol-brand`(`mockup/` BR01 39화면+모달6) · <https://solsol-brand-mockup.pages.dev>
- 검증 리포트 2종(`docs/dev-validation/FR01-…`·`BR01-…`) · 관리 허브 `/screens` D1화 + SoT 화면목록.

## 다음 단계

- FR01 blocker 5 / BR01 major 4(무료체험·유효시간 우선) 보완 라운드 → 재검증.
- AD01 관리자단 목업·브랜드 관리자단 화면목록 확정 시 동일 방식 확장.

## 5. 크리에이터 관리자단(AD01) 전체 목업 + 검증 + 배포

- **빌드**(admin-developer): 핸드오프 `design_handoff_customer_admin`(Nuxt SFC 스캐폴드 — 96 .vue + 레이아웃/컴포넌트/토큰, 런타임 파일 부재)를 **동작하는 Nuxt 3 + @nuxt/ui 앱으로 통합**(`solsol-admin/mockup/`). primary `#027CFA`, LNB/GNB, 화면ID 카탈로그(`/catalog`). `nuxt generate` 205라우트, 깨진 페이지 0.
- **검증**(qa, AD01 정본 §3.2): **본화면 107 전수 생성(파일 누락 0)** — 통합 7건·ID미표기 1건. ❌ 게이트 미통과 — **모달 미구현 blocker 2**(학습자상세 `0101-002_pu01~04`·빌더 `0703-003_pu01~05`)·major 6(비밀번호 8~16자·가입코드 10분·강사목록 권한모달·C-10/C-15·가입버튼 오기)·minor 3. 05 6건: ②⑥ ⭕ / ③ 부분 / ④⑤ ❌. 결과 [docs/dev-validation/AD01-customer-admin-round1.md](../dev-validation/AD01-customer-admin-round1.md).
- **배포**(게이트 미통과 기록 후 시연용): `malgnsoft/solsol-admin`(`5e44ea8`) → Pages `solsol-admin-mockup`. 스모크 전 라우트 200. <https://solsol-admin-mockup.pages.dev>
- 보완은 후속 라운드(학습자/빌더 모달 → 정책 문구 → 재검증).

## 6. 관리 허브 `/screens` 목업 링크 현행화 (3영역 전체)

세 영역 목업 배포분에 맞춰 `/screens`(화면)의 mockupUrl·publish 현행화:

- **AD01**: 목업 페이지의 화면ID 주석에서 ID→라우트 자동 추출(정적 산출 라우트 검증) + 통합 단계화면 6건 보강 → **103/103 실페이지** 링크(`solsol-admin-mockup`).
- **BR01**: 빌드 보고 매핑으로 **39/39** 링크(`solsol-brand-mockup`).
- **FR01**: 기존 상대경로(§화면목록 SoT 재생성 때 base 누락으로 깨졌던 링크)에 **base 보정** → **42/42** 링크(`solsol-mockup`) 정상화.
- 모달은 부모 화면 목업으로 연결. 공유 모달 컴포넌트(AD01 C## 7·BR01 C01 1)는 단일 부모가 없어 제외.
- 재배포: `solsol-mng` Pages. `/screens` 각 화면의 '목업' 링크 → 해당 영역 목업으로 이동.
