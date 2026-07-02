# 브랜드 프론트(세션③) → 레인①(spine) 변경요청 큐

> 작성: 2026-07-02 (KST) · 세션③ 강프개(B-1 필드매핑 분석) · 총괄 전달.
> 성격: brand 인증·쓰기 **실연동 배선 전** 계약(brand-api `/doc`) 정합 요구. 프론트 임의 변경 불가 항목 = ① 계약 확정 필요. §4.1(임의 계약 소비 금지) 준수 — 코드 미배선.

## A. ① 계약변경 필요 (엔드포인트/필드/값셋)

| # | 대상 | 요구 | 사유 |
|---|------|------|------|
| ①-1 | `PATCH /api/account/email`(또는 신규) | `billingEmail`을 로그인ID와 **분리** 저장·엔드포인트 정의(+PW 재확인 정책) | 프론트 billingEmail ≠ API email(login_id). TB_USER billing_email 컬럼·개념 부재 → 배선 불가 |
| ①-2 | `GET /api/sites/check-slug?slug=` (신규) | 도메인 중복 사전체크(available/message) | mock `checkDomain` 대응 EP 전무. my-site-create 실시간 체크 |
| ①-3 | `GET /api/payments` dto | `planName/planCode/billingCycle` + `siteName` 조인 추가 | 결제내역 화면 필수표기. 현 dto는 siteId·refType까지 |
| ①-4 | payment 상태 매핑 | `success/canceled/failed` ↔ `ready/paid/failed/…` 공식 매핑 + `canceledAt` | 뱃지·필터 정확성. canceled 원천 불명 |
| ①-5 | contact 상태 매핑 | `waiting/answering/answered` ↔ `open/answered/closed` 정합(‘answering’·‘closed’ 확정) | 문의 상태 카운트·뱃지 3:3 비대칭 |
| ①-6 | `GET /api/contact/:id` reply | `authorName`(표시명)·`mentionOf`(멘션) 제공 여부 | 댓글 스레드 표시. 현재 writerUserId만 |
| ①-7 | account/auth 응답 | `twoFactorEnabled`·`marketingAgreed` 노출 + PATCH 갱신 경로 | 계정 토글 배선 경로 부재 |
| ①-8 | `name` ↔ `firstName/lastName/displayName` | 성/이름 분리 저장 여부·displayName 파생규칙 확정 | signup/account/login 전반 |
| ①-9 | `email-code` 3-스텝 | `issueToken` 프론트 보관·재전달 흐름을 sendCode/verifyCode 시그니처에 반영 | 현 시그니처가 issueToken·email·verifyToken 미수용 |
| ①-10 | 목록 data 래핑 | `GET /api/contact`도 명명 래핑 통일(또는 전체 배열직접 통일) | 소비 shape 일관성(현재 contact만 배열직접) |
| ①-11 | `usage.*Used` | 테넌트 현재 사용량(members/storage) 집계 소스·EP 정의 | 현 used=0 mock. my-sites/my-product 게이지 |
| ①-12 | `Site.price/billingCycle/createdAt/expiresAt` | 응답 제공 여부(구독·플랜 조인 파생) | my-sites 카드·상세 표기 |

## B. 프론트 임의 처리(① 불필요 — 계약 프리즈 후 adapter)

- 표시 파생(typeLabel·카드 포맷) / 명칭 리네이밍(brand←issuer·isPrimary←isDefault·subtype←subType·content←body·slug←subdomain) / 클라 게이트(deleteAccount.agreed·createSite.agreedFreeTerms) / summary·statusCounts 클라 집계(①-4/①-5 확정 후).

## C. 배선 준비도

| composable | 분류 |
|------------|------|
| useAuth | 계약변경 선행(AuthUser 필드셋 ①-7/①-8, access토큰 보관 seam) |
| useAccount | 혼합 — cards CRUD·deleteAccount·password 즉시 가능 / email·2FA·marketing·code 3-스텝 선행(①-1/①-7/①-9) |
| useSites | 혼합 — list/create 필드매핑 후 가능 / checkDomain(①-2)·usage(①-11) 선행 |
| useBilling | 계약변경 선행(①-3/①-4). summary 클라집계 우선 가능 |
| useInquiries | 혼합 — CRUD 리네이밍 후 가능 / 상태값셋(①-5)·authorName/mentionOf(①-6) 선행 |

> 소스 미확정(별도 트랙): my-sites 사용량(①-11) · billingEmail 저장소(①-1) · 결제 플랜/사이트 조인(①-3).
