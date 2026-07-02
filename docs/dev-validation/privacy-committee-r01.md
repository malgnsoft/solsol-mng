# 개인정보(PII) 트랙 T6 — 검증위원회 라운드1 결함표

| 항목 | 내용 |
|------|------|
| 트랙 | T6 개인정보(PII) 횡단 — 마스킹 3레이어(3-D) + 동의 + 비가역 |
| 위원 | privacy-officer (T6) |
| 근거 SoT | 05_정책설계서 C-6 · DEV_VALIDATION_PROCESS §3-D/§2 stage7·8 · 01_검증체크리스트(마스킹 축) |
| 대상 | solsol/app · solsol-admin/app · solsol-brand/app · solsol-api/src · solsol-brand-api/src |
| 방법 | 코드 무수정(정적 점검) · 실제 PII 값 미노출(위치·유형만) |
| 단계 | 대부분 mock/staging 게이트 단계 → 실발송·실PG·실AI는 "실연동 전 필수"로 분리 |

> 심각도: 상=평문 PII 유출·비가역 무확인·카드 원번호 노출 / 중=마스킹 L1 누락·정통망법 고지 부재 / 하=권고.

## 결함표

| 결함ID | 대상앱 | 레이어/축 | 심각도 | 현상(위치) | 정책근거 | 권고 | 상태 |
|--------|--------|-----------|:---:|------------|----------|------|------|
| PRV-cttee-r01-D01 | solsol-brand-api | L2 로그·웹훅 | 중 | 토스 웹훅 `raw_payload`를 마스킹 없이 원문 저장(최대 60000자). 코드 주석은 "카드원문 없음"만 근거로 두나, 토스 웹훅 payload에 구매자 이름·이메일·휴대폰(customerName/Email/MobilePhone)이 포함될 수 있음. (routes/webhooks.ts:169-182, `rawPayload: rawBody.slice(0,60000)`) | 3-D L2 웹훅 raw_payload 마스킹 | 저장 전 payload에서 이름·이메일·휴대폰 키 마스킹 후 저장하거나 필요 필드만 화이트리스트 저장. 담당=api-developer | open |
| PRV-cttee-r01-D02 | solsol-api | 동의·L3 정통망법 | 중 | 마케팅 캠페인 발송(CP6 `/campaigns/:id/send`)에 야간발송 차단(21:00~08:00)·광고성 표기(`(광고)`)·수신동의 대상 필터가 미구현. 현재 실발송은 staging 게이트(mock)로 차단됨. (routes/admin/marketing.ts:743-786) | 05 R-1 컴플라이언스(정통망법) · 3-D | 실채널 발송 활성화 전 야간차단·광고표기·수신거부/수신동의 필터를 발송 파이프라인에 강제. 실연동 전 필수. 담당=api-developer | open |
| PRV-cttee-r01-D03 | solsol-api / solsol-brand-api | L3 외부전송 | 중 | PG(toss)·AI 튜터/번역/자막(`POST /admin/contents/:id/ai`) 외부전송의 국외이전 고지·동의 근거 미확인. 현재 AI 실호출·실결제는 게이트(mock). (docs/endpoints.ts:1043, routes/webhooks.ts) | 3-D L3 · 개인정보보호법 §28의8(국외이전) | 실연동 전 국외이전 고지·동의(또는 국내 리전) 확보 여부 법무 자문 별건 처리. AI 입력에서 학습자 PII 최소화. 실연동 전 필수. 담당=biz-legal/api-developer | open |
| PRV-cttee-r01-D04 | solsol-api / solsol-brand-api | L1 마스킹 알고리즘 | 하 | `maskEmail`이 로컬파트 앞 1자만 노출(`a****@domain`). 3-D 정본 예시는 "앞 2자 후 ***@domain". 방향은 더 보수적(노출 축소)이라 유출 위험 없음이나 단일 정본 알고리즘과 표기 불일치. (lib/masking.ts:19-26) | 3-D "마스킹 단일 정본" | 정본 알고리즘(앞 N자) 값을 확정·통일. 유출 아님 → 하. 담당=api-developer | open |
| PRV-cttee-r01-D05 | solsol-api / solsol-brand-api | L1 마스킹 커버리지 | 하 | `maskPhone`이 국내 3-3(4)-4 하이픈/무하이픈 패턴만 매칭. 국제번호·비정형 형식은 미매칭 시 원문 노출 가능(정규식 non-match 시 원본 반환). (lib/masking.ts:40-42) | 3-D L1 | non-match 시 폴백 마스킹(중간 전부 마스킹) 추가. 담당=api-developer | open |

## 앱별 요약

- **solsol-api**: 마스킹 라이브러리(lib/masking.ts) + 계좌 부분마스킹(settlement.ts maskAccount 앞3·뒤3) + 카드 뒤4(orders/commerce) 구비. 관리자 목록/문의/마케팅/커머스가 타인 조회 시 이름·이메일·휴대폰 마스킹 적용(members·support·marketing·commerce). 인증코드·재설정토큰은 SHA-256 해시 저장·응답 미포함(auth.ts `void code`). 로그는 오류 메시지만(4건)·PII 없음. 탈퇴(M7)는 status=-1 + 소셜 UID/primary_provider NULL 파기 + 세션 revoke. **L1 양호, blocker 0.**
- **solsol-brand-api**: 마스킹 라이브러리 동일 구비, 카드 뒤4(billing/payments). 이메일변경=verifyToken 게이트, 비번변경=현재PW, 탈퇴=현재PW 확인(account.ts AC3/AC4/AC5). 코드·토큰·password_hash 응답 미포함 명시. 웹훅 서명검증(상수시간 비교)·멱등 골격. **raw_payload 마스킹만 미흡(D01).**
- **solsol (사용자단)**: 프로필 본인 이메일 비마스킹(C-6 정합), 계정탈퇴 3단계 이중컨펌(AUTH-10/CMP-06/P-47), 마케팅 수신동의 화면(signup-terms) 구비. 결제/카드 마스킹 표기 존재. **비가역 게이트 양호.**
- **solsol-brand (브랜드 사용자단)**: 약관·개인정보처리방침·마케팅 동의 화면 분리 구비(terms/privacy/signup/account). 결제·카드 화면 마스킹 참조. mock 폴백 단계.
- **solsol-admin**: 프론트 목데이터 단계 — PII 실노출 위험은 실연동 시 백엔드 마스킹 응답에 의존(위 solsol-api L1로 커버).

## 트랙 판정

**🔺 조건부 통과 (blocker 0 / 상 0건)**

- 마스킹 L1(응답)·비가역 이중게이트·인증코드/비번 응답 배제는 현 단계 정책(C-6) 정합 — **상(blocker) 없음.**
- 미해소는 **중 3건(D01 웹훅 raw_payload / D02 정통망법 발송규제 / D03 국외이전)** 으로, 전부 **실발송·실PG·실AI 활성화 시점의 필수 조건**. 현재는 staging/mock 게이트로 실전송이 차단되어 있어 현 단계 GO 저해는 아님.
- DEV_VALIDATION_PROCESS §2: **stage8 실연동 라운드는 security·privacy 서명 없이는 GO 불가** — 아래 "실연동 전 필수"를 서명 조건으로 건다.

## 실연동 전 필수 (stage8 서명 조건)

1. **D01** — 토스 웹훅 raw_payload 이름·이메일·휴대폰 마스킹(또는 화이트리스트 저장) 후 재점검.
2. **D02** — 마케팅 실발송 파이프라인에 야간차단(21~08)·광고표기·수신동의/수신거부 필터 강제.
3. **D03** — PG·AI 외부전송 국외이전 고지·동의 근거(법무 자문) 확보 + AI 입력 PII 최소화.
4. **D04/D05** — 마스킹 알고리즘 단일 정본 확정(이메일 앞N자·전화 폴백).

> _ledger.md 미접촉(본 라운드 상=0건). 코드·정본 무수정. 실제 PII 값 미기재(유형·위치만).
