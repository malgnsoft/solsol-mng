# brand-site — 검증 라운드2 (세션③ 브랜드 프론트 · A-2/C01/B-1)

| 항목 | 내용 |
|------|------|
| 대상 | `/Users/dotype/Projects/solsol-brand/app/` (사용자단) |
| 기준(SoT) | `docs/validation/00_화면목록.md §3.3 BR01` · `03_brand-site.md`(366, 104-105) · 1px 기준선 = `solsol-brand/mockup/**` |
| 변경 범위 | `signup.vue` · `useAccount.ts` · `my-site-create.vue` · **신규** `components/BrandLegalModal.vue` (4파일) |
| 담당 | 강프개(frontend, 구현) · 배보검(security, 서명) · 오품관(qa, 검증) · ux-designer(오너 브리프) |
| 검증일 | 2026-07-02 (KST) |
| 빌드 | `pnpm build` **PASS** (dist 생성) / typecheck: 변경 4파일 **클린**, baseline 기존오류 7건(BrandCanvas·my-product-extend, 세션 밖) |
| 무수정 확인 | `mockup/**` 변경 0 · `docs/validation/**` 변경 0 · `solsol-brand-api` 변경 0(mtime 교차확인) · 커밋/배포 없음 |

---

## 1. 변경·검증 항목

| ID | 항목 | 심각도 | 결과 | 근거 |
|----|------|--------|------|------|
| A-2 | 인증완화 프로덕션 유출 하드닝 | — | **GO** | `CODE_RE=/^\d{6}$/` 선검증 + `import.meta.dev` 가드. 구 "무조건 통과" 제거. dist grep에 `import.meta.dev`/`TEST-ONLY` **0건**, 컴파일 `verifyCode` prod 항상 `{ok:false}`. 배보검 5항 PASS·blocker0. |
| C01 (DEF-03) | 약관 상세 모달 LPU 신설 | 상→**해소** | **종결** | `BrandLegalModal.vue` — chevron→모달, [동의하기]→체크 on, [취소]/ESC/배경=불변, 포커스트랩·복귀, role=dialog. SoT `03:366` 정합. 풀페이지 약관 존치. |
| — | 사용자단 회귀(라우팅·렌더) | — | PASS | `/`·`/login`·`/signup`·약관 4페이지 200, `/my-site-create` 미인증 302(정상) |

## 2. blocker(상) 검산

- **세션 변경분 상(blocker) = 0건.** DEF-03(round1 등재 상)은 C01 모달로 **해소·종결**.

## 3. 잔여 (gated · 정상 대기 — 결함 아님)

- **A-2 완전 원복 gated** — 서버 `verify-code` 실배선은 **레인① 계약 발행** 후. 현재는 프로덕션 유출 차단까지(TODO seam 표식). 인계: ①이 배선 시 **서버측 레이트리밋/시도횟수 제한**(6자리=100만 조합 브루트포스 방어) 필수 소유.
- 인증·쓰기 실연동(login/signup/account/sites/billing/inquiries) = ① 계약+시드 gated → mock 유지.
- **B-1 필드매핑 분석** 완료 → ① 변경요청 큐 12건([[brand-front-to-spine]] 참조, 총괄 전달).

## 4. 관찰(하 · 기록만)

- `[하]` `BrandLegalModal` 배경 레이어에 `aria-hidden`/`inert` 미부여(포커스트랩은 JS-only) — 향후 강화 여지.
- `[하/baseline]` solsol-brand typecheck 기존오류 7건(BrandCanvas.vue TS2578, my-product-extend.vue undefined ×6) — 세션 미유입, 별도 티켓.

## 5. 오너 판정 큐 (ux 브리프 3건 상신)

- **color-contrast**: 권고 B안(면=원색/텍스트=AA 파생토큰). 성공그린 #22c55e **2.28:1** 최우선. → SoT(디자인토큰) 개정 승인 필요.
- **모바일 반응형**: 권고 C안(데스크톱 zoom 유지 + 폼/결제만 모바일). "모바일 목표수준" 오너 확정 선행. → 반응형 spec 신설(SoT 개정).
- **C01 약관모달**: 권고 A안 = **이미 구현·SoT 무수정으로 종결**.
