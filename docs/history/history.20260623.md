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
