# BR01 목업 라운드 결함표 (MK-1 · r01)

| 항목 | 값 |
|------|-----|
| 대상 | `solsol-brand/mockup` (동결 별도 Nuxt · S-BR01 브랜드 사이트 목업) |
| 검증 범위 | 화면ID 1:1 인덱스 + 목업 9축·05 확정 6건 라운드 (빌드가능 36 설계화면) |
| 기준 SoT | `docs/validation/00_화면목록.md` §3.3 BR01(39화면, :345-383) · `03_brand-site.md` · `05_정책설계서.md`(확정 6건 C-1·M-1·M-2·C-2·C-3·C-4) |
| 검증자 | 오품관(qa) |
| 검증일 | 2026-07-02 (KST) |
| 빌드 | **미실행(동결 프로젝트 아티팩트 생성 회피)** → 정적 검증으로 대체. 근거: 기존 빌드 산출물 `mockup/.output/public` 존재(2026-06-29 20:42, `index.html` 40 route 프리렌더 완료) = 40 route 빌드 성공 실증. `node_modules` 존재. |
| 무수정 확인 | **목업·validation·data-model 무수정(읽기 전용)** — 산출물은 본 파일 1개 신규 생성만. `_ledger.md` 미편집. |
| 데이터 전제 | 목업 계층 = **가짜 데이터·정적 verbatim**(핸드오프 v5 `.dc.html` 1:1 이식). 인터랙션·상태전이·밸리데이션은 실앱 몫. |

---

## 1. 화면ID 1:1 인덱스 (3자 매핑: 정본 ↔ 목업 route ↔ 실앱 route)

정본 BR01 = **39화면**(00_화면목록 :345-383). 이 중 **의도적 미설계/실사이트 대체 3건 N/A**, **설계 대상 36화면**.

| 화면ID | 화면명 | 목업 route | 실앱 route | 판정 |
|--------|--------|-----------|-----------|------|
| S-BR01-0101-001 | 메인(main 랜딩) | `landing.vue` | `index.vue` | ✅ 일치 |
| S-BR01-0102-001 | 플랫폼 소개 | `platform-intro.vue` | `platform-intro.vue` | ✅ |
| S-BR01-0103-001 | 프로덕트 | — | — | N/A(미설계·빈 GNB) |
| S-BR01-0104-001 | 데모보기 | — | — | N/A(실사이트 대체) |
| S-BR01-0105-001 | 주요기능 소개 | — | — | N/A(실사이트 대체) |
| S-BR01-0301-001 | 회원가입 - Free | `signup-free.vue` | `signup-free.vue` | ✅ |
| S-BR01-0301-002 | 회원가입(동의 통합 폼) | `signup.vue` | `signup.vue` | ✅ |
| S-BR01-0301-003 | 회원가입 - Free 완료 | `signup-done.vue` | `signup-done.vue` | ✅ |
| S-BR01-0302-001 | 로그인 | `login.vue` | `login.vue` | ✅ |
| S-BR01-0302-002 | 비밀번호 재설정(인증메일) | `password-reset.vue` | `password-reset.vue` | ✅ |
| S-BR01-0302-003 | 새 비밀번호 설정 | `password-new.vue` | `password-new.vue` | ✅ |
| S-BR01-0401-001 | 내 사이트 만들기 | `my-site-create.vue` | `my-site-create.vue` | ✅ |
| S-BR01-0401-002 | 내 사이트 관리(목록) | `my-sites.vue` | `my-sites.vue` | ✅ |
| S-BR01-0501-001 | 공지/소식(목록) | `news.vue` | `news.vue` | ✅ |
| S-BR01-0501-002 | 공지/소식 상세 | `news-detail.vue` | `news-detail.vue` | ✅ |
| S-BR01-0601-001 | 가격(요금제 main) | `pricing.vue` | `pricing.vue` | ✅ |
| S-BR01-0601-002 | 유료플랜 구매/업그레이드 | `pricing-purchase.vue` | `pricing-purchase.vue` | ✅ |
| S-BR01-0601-003 | 결제 완료(최초) | `payment-done.vue` | `payment-done.vue` | ✅ |
| S-BR01-0601-004 | 결제 완료(업그레이드) | `payment-done-upgrade.vue` | `payment-done-upgrade.vue` | ✅ |
| S-BR01-0601-005 | 결제 실패 | `payment-fail.vue` | `payment-fail.vue` | ✅ |
| S-BR01-0701-001 | 문의하기 | `contact.vue` | `contact.vue` | ✅ |
| S-BR01-0701-002 | 문의하기 - 접수 완료 | `contact-done.vue` | `contact-done.vue` | ✅ |
| S-BR01-0702-001 | 문의 내역(목록) | `contact-history.vue` | `contact-history.vue` | ✅ |
| S-BR01-0702-002 | 문의 내역 상세 | `contact-history-detail.vue` | `contact-history-detail.vue` | ✅ |
| S-BR01-0801-001 | 이용상품 정보(상태별) | `my-product.vue` | `my-product.vue` | ✅ |
| S-BR01-0801-002 | 사용 연장하기 | `my-product-extend.vue` | `my-product-extend.vue` | ✅ |
| S-BR01-0901-001 | 계정관리(계정정보) | `account.vue` | `account.vue` | ✅ |
| S-BR01-0901-002 | 결제 이메일 변경 | `account-email.vue` | `account-email.vue` | ✅ |
| S-BR01-1001-001 | 결제 내역 | `billing.vue` | `billing.vue` | ✅ |
| S-BR01-1101-001 | 이용약관 | `terms.vue` | `terms.vue` | ✅ |
| S-BR01-1101-002 | 무료약정상품 이용약관 | `terms-free.vue` | `terms-free.vue` | ✅ |
| S-BR01-1101-003 | 유료약정상품 이용약관 | `terms-paid.vue` | `terms-paid.vue` | ✅ |
| S-BR01-1101-004 | 개인정보처리방침 | `privacy.vue` | `privacy.vue` | ✅ |
| S-BR01-1101-005 | 마케팅 정보 수신 동의 | `marketing-consent.vue` | `marketing-consent.vue` | ✅ |
| S-BR01-9001-001 | 시스템 일부 에러 | `error-system.vue` | `error-system.vue` | ✅ |
| S-BR01-9001-002 | 404 페이지 | `not-found.vue` | `not-found.vue` | ✅ |
| S-BR01-9001-003 | 네트워크 연결 오류 | `network-error.vue` | `network-error.vue` | ✅ |
| S-BR01-9001-004 | 서비스 긴급점검 | `emergency-maintenance.vue` | `emergency-maintenance.vue` | ✅ |
| S-BR01-9001-005 | 서비스 정기점검 | `maintenance.vue` | `maintenance.vue` | ✅ |

### 1.1 카운트 정합

| 구분 | 목업 | 실앱 | 비고 |
|------|------|------|------|
| route 파일 총계 | 40 | 37 | — |
| 설계 대상 화면(정본 36) | 36 ✅ | 36 ✅ | **누락 0** |
| N/A(미설계·실사이트 3건) | 0(정상 부재) | 0(정상 부재) | 0103·0104·0105 |
| 비화면 tooling | 3 | 0 | 목업: `index.vue`(카탈로그)·`page-list.vue`(화면목록)·`design-guide.vue`(디자인가이드) — 실앱은 정상 제거 |
| 유령(정본 39 외) | 1 | 1 | `pricing-light.vue` (양쪽 공통) |

- **누락**(정본에 있으나 목업/실앱 부재): **0건**.
- **유령**(정본 39에 없음): `pricing-light.vue` — Figma BSub "가격(라이트 시안)" 디자인 변형. 목업·실앱 **양쪽 잔존**. 정본 화면ID 미부여(승인된 디자인 시안 참조본). → **관리대상 유령 1건**(아래 D-3).
- **tooling 3건**(index/page-list/design-guide)은 목업 카탈로그 도구 → 검증대상 36에서 **정당 제외(오존재 아님)**. `page-list.vue`가 정본 화면ID 카드 인덱스를 자체 보유(교차확인용).
- **검증제외 오존재 0 확인**: 실앱은 tooling 3건 미포함(정상), 유령은 pricing-light 1건뿐.

---

## 2. 목업 9축 결과 (36 설계화면 · 가짜데이터 전제)

| 축 | 결과 | 근거/비고 |
|----|------|-----------|
| ① 존재 | ✅ PASS | 36/36 존재. 기존 빌드 `.output/public` 40 route 프리렌더 실증. |
| ② IA/라우팅 | ✅ PASS(하 1) | route 네이밍 일관·GNB(C-1) inline verbatim. **하**: `page-list.vue` 요약 통계 카운트 부정합(D-4). |
| ③ 상태(빈/로딩/에러) | △ N/A-note | 빈상태는 정본 반영(my-sites·contact-history·billing 빈상태 문구 존재). **로딩/에러 상태전이는 목업 static 미표현 → 실앱 책임(목업 layer N/A)**. |
| ④ 공통컴포넌트 | ✅ PASS(갭 1) | `BrandCanvas`·`AppLogo`·`TemplateMenu`. GNB/Footer inline verbatim. **모달(C-3 LPU)은 목업 inline static** → 실앱 `BrandLegalModal` 컴포넌트화(D-6 목업↔실앱 갭, C01). |
| ⑤ 마스킹 | ✅ PASS(하 1) | 가짜데이터(`@example.com`·`djtech.new@gmail.com`), 카드 last-4(`신한카드 1234`)만·full PAN/CVV 없음. **하**: 카드번호 마스킹 dot(`····1234`) 미표기(D-5). |
| ⑥ 카피(PNG verbatim) | △ 정책 stale 2 | 각 페이지 정본 `.dc.html` 경로 주석·verbatim 이식. **정책 문구 stale**: M-1 "14일 무료체험"(D-1), C-2 "3분"(D-2). |
| ⑦ 디자인토큰 | ✅ PASS | 브랜드 컬러 `#ED1B23`·`#7954C6`·`#1b8bec`, Pretendard. 정본 토큰 일치. |
| ⑧ 반응형(1440/390) | △ N/A-note | `BrandCanvas` = 1920 고정 캔버스 `body.zoom=min(1,vw/1920)` 스케일-핏. **리플로우 없음 → 390 반응형 미지원(design verbatim)**. 실앱 390 반응형 책임(목업↔실앱 갭). |
| ⑨ 인터랙션 | △ N/A-note | 목업 static(예: `login.vue` 39줄 vs 실앱 73줄). 클릭/밸리데이션 미구현 = 목업 layer 정상. |

### 2.1 05 확정 6건 라운드 (BR01 관점)

| 정책 | 확정값 | 목업 상태 | 판정 |
|------|--------|-----------|------|
| C-1 닉네임 길이 | (LMS 영역) | 브랜드 가입에 닉네임 필드 없음 | **N/A**(BR01 무관) |
| M-1 무료체험 14일 | **미운영 확정** | `pricing.vue:37` "모든 플랜은 14일 무료 체험…" **잔존** | **위반(상)** → D-1, 단 실앱 해소확인 |
| M-2 RBAC LNB | (AD01 전용) | 브랜드 무관 | **N/A** |
| C-2 인증코드 TTL | 가입/이메일변경 **10분**, 재설정 **30분** | 목업 가입·이메일변경 **"3분"** 잔존 | **위반(중)** → D-2, **실앱 account-email 미해소(D-2b)** |
| C-3 비밀번호 문구 | "영문·숫자·특수문자 3종, 8~16자" | `password-new.vue:20` "8~16자·3종 조합" **정합**, login placeholder 빈값(stale 없음) | **PASS** |
| C-4 쿠폰 할인 오픈 | (오픈 범위) | 목업 판단 대상 아님 | **N/A** |

---

## 3. 결함표

> 심각도 **상/중/하** 단일 척도. 목업은 **동결 verbatim**이므로 목업 자체 수정 불가 → 정책 stale은 "목업↔실앱 갭"으로 기록, **실행 수정 책임은 실앱(front-developer)**. 담당 위임은 총괄 경유.

| ID | 심각도 | 화면/축 | 재현 절차 | 기대값 | 실제값 | 근거(파일:라인) | 처리 |
|----|--------|---------|-----------|--------|--------|-----------------|------|
| **D-1** | 상 | S-BR01-0601-001 / ⑥·M-1 | pricing 목업 진입 → 요금제 안내 문구 | M-1 미운영 확정 → "무료체험" 문구 없음 | "모든 플랜은 14일 무료 체험이 포함…" | `mockup/app/pages/pricing.vue:37` | **목업↔실앱 갭**. 실앱 `app/pages/pricing.vue` 해당 문구 **부재 확인(해소됨)** → 실앱 clean. 목업 동결로 비수정. blocker 아님. |
| **D-2** | 중 | S-BR01-0301-002·0901-002 / ⑥·C-2 | signup/account-email 인증코드 안내 | 가입/이메일변경 코드 **10분** | "유효 시간: 3분" | `mockup/app/pages/signup.vue`(3분)·`account-email.vue:75`(3분) | 목업↔실앱 갭. 실앱 `signup.vue:17` **10분 반영 확인**. |
| **D-2b** | 중 | S-BR01-0901-002 / C-2 | **실앱** account-email 진입 → 인증코드 발송 안내 | 이메일변경 코드 **10분**(C-2) | **"3분" 잔존** | `solsol-brand/app/pages/account-email.vue:22,165` | **실앱 결함(C-2 부분미반영)**. signup은 10분 고쳤으나 account-email 누락. → **front-developer 위임**. |
| **D-3** | 하 | 유령 / 화면ID | route `pricing-light` 존재 | 정본 39 외 화면ID 미부여 | 목업·실앱 양쪽 잔존(Figma BSub 시안) | `mockup/.../pricing-light.vue`·`app/pages/pricing-light.vue` | 승인 디자인 시안이면 유령 아님으로 명문화, 아니면 실앱 제거 검토. 기획-lead 확인 대상. |
| **D-4** | 하 | tooling / IA | page-list 요약 통계 확인 | 카드 렌더 실수와 정본 39 정합 | "전체 37/완료 35" 라벨이 실제 렌더 36완료·정본 39와 부정합(35+1+2=38≠37) | `mockup/app/pages/page-list.vue:15,149-154` | 목업 카탈로그 라벨 부정확(동결로 비수정, 참고). |
| **D-5** | 하 | S-BR01-1001-001 / ⑤ 마스킹 | billing 결제내역 카드 컬럼 | 카드번호 마스킹(`····1234`) | "신한카드 1234"(dot 없음, last-4만) | `mockup/app/pages/billing.vue:19-22` | 실앱 마스킹 표기(`····1234`) 권장. 가짜데이터·full PAN 없음이라 경미. |
| **D-6** | 하 | 공통컴포넌트 C-3 모달 / ④ | 약관·법무 모달 렌더 방식 | 공통 모달 컴포넌트(LPU) | 목업 inline static | `mockup`(inline) vs `app/components/BrandLegalModal.vue` | 목업↔실앱 갭(C01). 실앱 이미 컴포넌트화 완료 → 참고. |

---

## 4. blocker 검산

- **목업 라운드 "상" 결함 = 1건**: D-1(M-1 14일 무료체험, `pricing.vue:37`).
  - 그러나 ① 목업은 **동결 verbatim**(수정 대상 아님) ② **실앱 pricing에서 해당 문구 부재 확인(해소됨)** → 실제 사용자 노출 경로 clean.
  - ∴ **활성 blocker 아님**. 목업↔실앱 갭(baseline stale)으로만 기록. 허브 원장 등재 불요(실앱 clean 근거). 등재·강등 판단은 팀장/총괄 몫.
- **실앱 잔여 결함**: D-2b(account-email C-2 "3분" 미반영, **중**) — blocker 아님(중). **front-developer 위임 필요**.
- **결론: 목업 라운드 blocker 0.** 화면ID 1:1 누락 0·검증제외 오존재 0. 위임 1건(D-2b, 중, 실앱), 확인요청 1건(D-3, 하, 유령 성격).

---

## 5. 총괄 취합용 요약

- **화면ID 1:1**: 정본 39 = 설계 36(전건 목업·실앱 존재, **누락 0**) + N/A 3(0103·0104·0105). **유령 1**(pricing-light, 양쪽), tooling 3(목업 전용, 정당 제외).
- **빌드**: 미실행(동결 아티팩트 회피). 기존 `.output` 40 route 프리렌더 실증으로 빌드가능 판단.
- **9축**: PASS 4 / N/A-note 3(상태·반응형·인터랙션=목업 layer 특성) / 정책 stale·갭 다수.
- **결함 7건**: 상 1(D-1, 실앱 해소·비활성) · 중 2(D-2·**D-2b 실앱 활성**) · 하 4(D-3~D-6).
- **blocker 0**. 실앱 위임 1건(D-2b account-email C-2 10분 수정 → front-developer), 기획 확인 1건(D-3 pricing-light 유령 성격).
