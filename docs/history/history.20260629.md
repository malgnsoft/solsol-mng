# 2026-06-29 — 브랜드 사이트 v5 목업 정본 verbatim 재구축 + 검증 + 배포

> **한 줄 요약** — 브랜드 목업이 디자인 시안과 어긋나던 문제를, 핸드오프 v5 정본 `.dc.html` **마크업을 그대로(verbatim) 이식** + `BrandCanvas`(document.body.zoom fit + 배경 동기화)로 **정본과 일치**시켜 재구축. BR01 39화면, `/`=화면 카탈로그, 검증 후 `solsol-brand-mockup` 배포.

## 1. 원인 — 정본 재해석

- v2~v4 목업이 정본 `.dc.html`(1920px 캔버스 + **인라인 절대좌표** + Tailwind)을 **flex flow로 재해석**해 시안과 어긋남. 사용자 피드백 "모든 페이지가 다르다".

## 2. v5 정본 verbatim 이식 (강프개)

- 기존 목업 폐기 후 `solsol-brand/mockup` 신규 스캐폴드(Nuxt 3 + @nuxt/ui).
- 각 `.dc.html`의 `<div class="w-[1920px] ...">` 본문을 **그대로 이식** — 인라인 좌표·Tailwind·텍스트·SVG·filter 무변경. 허용 변경 3가지(래퍼 제거 / `src=/assets/` / 캔버스 fit 래퍼).
- **`BrandCanvas`**: 정본 `<helmet>` 스크립트와 동일하게 `document.body.style.zoom = min(1, vw/1920)` + 짧은 페이지 배경(body) 캔버스색 동기화(흰 여백 제거). → 전 39페이지 공용 적용.
- **소스 대조 검증**: 로그인·가격·메인 랜딩을 정본 `.dc.html` 렌더와 직접 대조 → 일치 확인.
- `/` = 화면 카탈로그(BR01 39 + 링크, ID 표준화), 메인 = `/landing`. `npx nuxi generate` 82라우트.

## 3. 검증 (오품관) — A형(정본 그대로)

- 화면목록: BR01 39 중 36 구현 + 3 SoT 인정 미구현(0103 미설계·0104/0105 실사이트 대체), **누락 0**.
- 게이트: 정책 기준 ❌(M-1 무료체험·C-2 인증코드 "3분")이나 **이는 v5 정본 디자인에 내재** → 사용자 **A형(정본 그대로 유지)** 선택. 모달 6건 미구현(정본 메인에 모달 프레임 없음).
- 리포트: [docs/dev-validation/BR01-brand-site-v5-round1.md](../dev-validation/BR01-brand-site-v5-round1.md).

## 4. 배포

- `malgnsoft/solsol-brand`(`f0dc5a5`) → Pages `solsol-brand-mockup`. 스모크 전 라우트 200, `/`=카탈로그 확인. <https://solsol-brand-mockup.pages.dev>
- FR01 크리에이터 목업(`solsol/mockup`)은 미접근·보존.

## 다음 단계

- (선택) 모달 6건(`_pu` 5 + 약관 C01) LPU 구현 → 재검증.
- 정책 반영(B형) 필요 시 무료체험·인증코드 정정.
