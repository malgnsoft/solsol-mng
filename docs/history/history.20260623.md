# 2026-06-23 — 쏠쏠 브랜드 사이트 화면 목업 제작 + 배포

> **한 줄 요약** — Figma `LMS Customer_디자인시안`의 "03. Brand site **확정본**"(레드 브랜드·Pretendard)을 기준으로 브랜드 사이트(사용자단) **전체 25개 페이지**를 정적 HTML 목업으로 제작해 `solsol-brand/mockup/` 에 담고, Cloudflare Pages(`solsol-brand-mockup`)로 배포.

## 1. 디자인 해석 (Figma MCP)

- 파일 권한(Dev) 부여 후 "03. Brand site" 페이지(node 245:2, ~92963×50015px) 메타데이터에서 **48개 최상위 프레임** 추출 — 구버전 시안 + 최신 대형 프레임 + 디자인 시스템(컬러/타이포/컴포넌트) + 확정본.
- **확정본**(3368:22557) + 컬러/타이포 프레임(3736:37578) 시각 확인 → 디자인 토큰 추출: Primary **레드 #ED1B23**, 니어블랙 섹션(#101010), 폰트 **Pretendard**, 타이포 스케일(H1 44 … B 12~14).
- ⚠️ Figma MCP **Starter 플랜 호출 한도** 도달 — 메인·가격·컬러는 직접 확인, 미열람 화면(마이페이지·구매결제 상세 등)은 확정본 패턴 기반 재구성.

## 2. 목업 구성 (`solsol-brand/mockup/`, 정적 HTML)

- `assets/tokens.css`(토큰) · `assets/base.css`(공용 컴포넌트) · `assets/chrome.js`(공용 헤더/푸터 주입) · `index.html`(전체 페이지 갤러리).
- **전체 25 페이지**: 메인(랜딩)·가격·문의 / 로그인·회원가입·가입완료·이메일인증·비밀번호 재설정(요청/설정/완료) / 구매결제·결제완료/실패·사이트생성·결제유예·구독해지/만료 / 마이페이지 4탭(계정·사이트·결제내역·문의내역) / 서비스정지·사용량경고·약관·404.
- 헤드리스 렌더 검증 — 메인 랜딩이 확정본(다크 히어로 + 레드 헤드라인 + 비교 섹션)과 일치.

## 3. 배포

- `malgnsoft/solsol-brand` main 에 첫 커밋·푸시(`54788ff`).
- Cloudflare Pages 프로젝트 **`solsol-brand-mockup`** 신설 → 배포. 실제 `solsol-brand`(Nuxt) 프로젝트명과 분리.
- 라이브 검증: 전 페이지 200(클린 URL). <https://solsol-brand-mockup.pages.dev>

## 산출물

- 레포 `malgnsoft/solsol-brand` (`mockup/` 25 페이지 + 토큰/공용 CSS).
- 배포 <https://solsol-brand-mockup.pages.dev> (index.html = 전체 갤러리).

## 4. 메인 정밀 재현 (Figma MCP 한도 해제 후)

- Figma 한도 원인 규명: 파일이 속한 **팀의 플랜** 기준으로 한도 적용(Starter=6/월). 파일을 Pro 팀으로 이동(새 파일 `CustomerLMS-디자인시안 _최종`, fileKey `fa8RY8ZvnJYD4pZafKnbMP`)해 **200/일** 해제.
- `get_design_context`로 최종 `메인`(node 3700:24262) 정확 데이터 추출: 컬러(**#ED1B23** 등)·Pretendard·이미지 에셋 **50개**·전체 카피. 에셋은 `mockup/assets/img/`(약 21MB) 다운로드.
- Figma 코드젠(절대좌표) 직접 변환은 헤드리스 렌더가 깨져, **정확한 토큰/카피/실에셋 기반 flow 레이아웃으로 재구성**. 메인 **9개 섹션**(헤더·히어로·이미지그리드·솔루션 6카드·뉴스레터·비교표(쏠쏠 vs 경쟁사 ₩49,000~)·핵심기능 6카드·프로토타입 레드밴드·최종 CTA·푸터).
- 재배포: `malgnsoft/solsol-brand`(`a65052e`) → Pages `solsol-brand-mockup`. 라이브 검증 200·히어로 이미지 정상. <https://solsol-brand-mockup.pages.dev/pages/main>

## 다음 단계 / 알려진 한계

- 메인 외 화면(가격·마이페이지 등)도 동일 방식(MCP 정확 추출 → 재현)으로 정밀화 가능.
- flow 재구성이라 미세 여백은 ±수 px 차이 가능(컬러·카피·이미지·구조는 일치).
- 이후 실제 `solsol-brand`(Nuxt 3 + Nuxt UI v3, 원본 `malgn-noti`)로 토큰·컴포넌트 이식.

## 5. 메인 시안 정밀 보정 (디자인 대조)

전체 시안 이미지와 대조해 차이를 정정(`solsol-brand` `8bae10f`):

- 솔루션: **첫 카드(콘텐츠 제작 부담) 레드 채움**(반전 — 흰 아이콘/스탯/펠) + 카드 **열 순서(컬럼-메이저)** 정정.
- 비교표: **다크 섹션 + 쏠쏠 열 레드 보더(border-2 #ED1B23, rounded-40)** + **초록(✓)·빨강(✕) 원형 아이콘**.
- 최종 CTA: **회전 배지**(14일 무료체험·신용카드 등록없이·모든 기능) + 재생 버튼, 좌측 배치.
- 히어로: **2단 제목 크기**(크리에이터를 위한 44 / 핵심 서비스만 모았습니다 60), 이미지 그리드 **2행 디밍**.
- 재배포 `solsol-brand-mockup` · 라이브 검증 200. <https://solsol-brand-mockup.pages.dev/pages/main>

## 6. 관리 허브에 검증(validation) 섹션 신설 + 개발–검증 절차

검증 패키지(`docs/validation/`, Figma 화면설계서 기반 SoT)를 학습·연동(`solsol-mng` `fd07d7a`):

- **에이전트팀 학습**: `기획-lead`·`운영-lead`가 검증 문서 9종 정독·브리핑(읽기 전용 준수). 전체 제품(쏠쏠 크리에이터 LMS 3영역·194화면·정책 96 + 충돌 확정 6건) 이해.
- **개발–검증 연동 절차** 신설 `docs/DEV_VALIDATION_PROCESS.md` + CLAUDE.md 반영 — 화면ID 단위, 권위 우선순위(05 정책설계서 6건 최우선), 6단계 게이트(구현 9축→셀프→qa·security·privacy→팀장 컨펌→배포).
- **관리 허브 "검증" 섹션**: GNB '검증' 메뉴 + `/validation` 인덱스(문서 9종) + `/docs` 에서 검증문서 분리. @nuxt/content가 `docs/validation/*.md` 렌더.
- 검증 캡처 `_exports`(1.2GB·PNG 1,946)는 `.gitignore` 제외(앱은 .md만 렌더). 검증 폴더 원본 무수정.
- 배포 검증: `/validation` 200 · `/docs/validation/*` 200. <https://solsol-mng.pages.dev/validation>

## 7. 브랜드 사이트 목업 → Nuxt 3 재구축 (디자인 핸드오프)

기존 정적 HTML 목업 삭제 후, 개발자 핸드오프(`ProjectHandoff/design_handoff_solsol_brand`)를 정본으로 **Nuxt 3 + Tailwind + Nuxt UI** 재구현(`solsol-brand` `66a4129`·`139fc37`):

- **검증 라운드1(목업 vs SoT)** 선행: qa가 BR01 36화면 대조 → 커버리지 61%·❌상 9건 결함표 산출(게이트 미통과 확인). 이후 목업 전면 삭제.
- `mockup/` 에 Nuxt 앱 신설 — `pages/index.vue`(Brand Landing, 1920×7132) + `pricing.vue` + `my-sites.vue`, 공통(AppHeader/Footer/SsolLogo) + 랜딩 7섹션 + pricing·my-sites 컴포넌트. Pretendard·에셋 12종.
- **빈 렌더 버그 2건 수정**(자동임포트 prefix `pathPrefix:false`, `h()` 오용→인라인 SVG) — 헤드리스 스크린샷으로 실제 렌더 확인(빌드 성공≠동작).
- `nuxt generate` 정적 산출 → Pages `solsol-brand-mockup` 배포. 라이브 `/`·`/pricing/`·`/my-sites/` 200. <https://solsol-brand-mockup.pages.dev>
- 핸드오프엔 가격/내사이트 변형 등 잔여 페이지 존재 — 동일 방식 확장 가능.

## 8. 크리에이터 사용자단(Customer Front) 목업 + FR01 검증 라운드

`design_handoff_customer_lms` 핸드오프를 에이전트팀으로 구현·검증·배포:

- **빌드**(frontend-developer): `solsol/mockup/` Nuxt 3 + Tailwind + Nuxt UI, Customer Front **46 화면**(인증·강의 6유형·플레이어·결제·마이페이지 13·커뮤니티/게시판·FAQ) + 레이아웃 default/mypage/player + 목업 인덱스(화면ID 표기). `nuxt generate` 정적 배포.
- **검증**(qa, FR01 정본 대조): ❌ **게이트 미통과** — 커버리지 40/42, blocker 5(쿠폰 정률 C-4 위반 4파일 + 프로필 모달 미구현)·major 5·minor 3. 05 6건: ②무료체험 미운영 합격·⑥쿠폰 정액 위반·나머지 N/A. 결과: [docs/dev-validation/FR01-customer-front-round1.md](../dev-validation/FR01-customer-front-round1.md).
- 배포(게이트 미통과 기록 후 시연용): `malgnsoft/solsol`(`6f54a9f`) → Pages `solsol-mockup`. <https://solsol-mockup.pages.dev>
- 보완은 후속 라운드(쿠폰 정률 정액화 → 모달 구현 → 재검증).
