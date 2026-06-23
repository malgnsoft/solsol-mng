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

## 다음 단계 / 알려진 한계

- Figma 호출 한도 해제(또는 업그레이드) 후 **미열람 화면 프레임별 픽셀 대조**로 정밀화.
- 이후 실제 `solsol-brand`(Nuxt 3 + Nuxt UI v3, 원본 `malgn-noti`)로 토큰·컴포넌트 이식.
