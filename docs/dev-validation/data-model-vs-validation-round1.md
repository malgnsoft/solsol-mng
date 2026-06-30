# 데이터 모델 ↔ 검증 정본 적합성 검증 — Round 1

- **대상**: `docs/data-model/master.sql`(14) + `tenant_template.sql`(90) = 104 테이블
- **정본(SoT)**: `docs/validation/` 00~06 (확정정책 16건 · 06 API계약 · 화면목록)
- **검증축 4**: QA(정책·API·화면 커버리지) · 보안 · 개인정보 · DBA(스키마 건전성)
- **일시**: 2026-06-29 (KST) · 정본·모델 파일 **무수정**

---

## 종합 판정: ⚠️ 부분적합 — 게이트 미통과 (blocker 존재)

아키텍처(schema-per-tenant)·네이밍/타입 **컨벤션 일관성**·핵심 **멱등(크레딧·웹훅·결제)**·**RBAC/알림 단일라우팅** 구조는 **견고**하고, 확정정책 16건 중 14건·06 API계약 핵심 필드 ~90%를 충족한다.
그러나 **모델 레벨 blocker 다수**가 확인되어 현 상태로는 개발/배포 게이트(❌ '상' 0건)를 통과하지 못한다.

| 축 | 상 | 중 | 하 |
|---|---|---|---|
| QA(정책/API/화면) | 2 | 5 | 2 |
| 보안 | 2 | 6 | 3 |
| 개인정보 | 4 | 8 | 2 |
| DBA(스키마) | 3 | 4 | (다수) |

> blocker는 축 간 중복이 있어, 아래 **통합 blocker 7건**으로 정리(중복 제거).

---

## 통합 Blocker (상) — 7건 · 해소 전 게이트 통과 불가

| # | 결함 | 축 | 현상 | SoT근거 | 제안 |
|---|------|----|------|---------|------|
| **B-1** | 평문 토큰/코드 저장 | 보안·개인정보 | `TB_AUTH_CODE.code`·`TB_PASSWORD_RESET_TOKEN.token`·`TB_INVITE_TOKEN.token`을 **평문** 저장. 동일 위험의 `TB_SESSION.refresh_token_hash`는 이미 해시 → 일관성 결여. DB 유출 시 가입/재설정/초대 takeover | C-2(토큰 탈취 takeover) · AUTH_SPRINT1 §4.2 | 세 토큰/코드 **해시 저장**으로 통일 + 코드 검증 시도횟수 컬럼 |
| **B-2** | `TB_SETTLEMENT_PROFILE` 소유자 컬럼 부재 | DBA | 정산 프로필에 `instructor_user_id`(소유 강사) 컬럼 **자체가 없음** → 강사↔프로필 연결·조회·승인게이트 구현 불가. **구조 결함** | 06 §1.9 · PAY-20 | `instructor_user_id` 추가 + `UNIQUE(instructor_user_id)` |
| **B-3** | 상품 후기·별점 테이블 부재 | QA | 리뷰 전용 테이블 없음(`TB_BOARD.type`에 review 없음, rating 컬럼 없음) → FR01 후기 화면 3건 + `TB_PRODUCT.avg_rating` 집계 불가 | 00화면목록 S-FR01-0102-002/0301-202/0301-108 | `TB_REVIEW`(user_id·product_id·enrollment_id·rating·content) 신설 |
| **B-4** | 정산·결제 민감정보 평문 + 암호화 미규정 | 개인정보 | `account_no`·`biz_no`·`birth_date`·통장/사업자등록증 R2키·`transfer_note`·`toss_billing_key`가 평문/주석만. 저장 암호화·접근제어·마스킹 요건 미명시 | C-6/CMP-01 · 개인정보보호법 §23 | 계좌·빌링키 **저장 암호화(AES-256/KMS)** 요건 명문화, R2 원본 접근제어, `biz_no`·`birth_date` 수집근거 |
| **B-5** | `TB_PRODUCT.discount_rate` C-4 경계 모호 | QA | 상품 정률 할인율 컬럼 존재 → 결제 계산에 적용되면 **C-4(정액 only) 위반** 전환 가능. 용도 미명시 | 05 C-4 | COMMENT에 "UI 표시 전용·결제 미사용" 또는 "오픈 비활성" 명시, 06 §1.4 반영 |
| **B-6** | `TB_SESSION.refresh_token_hash` UNIQUE 부재 | DBA·보안 | 유니크 없음 → 리프레시 토큰 재사용·충돌 탐지 불가(`PASSWORD_RESET_TOKEN`·`INVITE_TOKEN`은 UNIQUE 보유 — 불일치) | 보안 컨벤션(1회용 토큰 UNIQUE) | `UNIQUE(refresh_token_hash)` (해시 prefix 191 주의) |
| **B-7** | 신규 테넌트 `CREATE DATABASE` 권한 미해소 | DBA·운영 | 앱 `solsol` 유저는 DB 생성 불가 → 크리에이터 자동 온보딩 불가, 수동 DDL 병목 | README dev 매핑 OQ | 프로비저닝 전용 DB 계정(CREATE 권한) 분리 + 온보딩 API/CLI + `TB_TENANT_PROVISION_LOG` |

> B-1·B-2·B-3·B-5·B-6은 **모델 차원 교정 필수**(컬럼/테이블/유니크 변경). B-4는 모델 주석 + 앱계층/문서. B-7은 인프라.
> **현재 DB에 운영 데이터가 없으므로**(초기 부트스트랩) 컬럼·유니크·테이블 추가는 **비파괴 온라인 DDL**로 영향 0.

---

## 주요 중(中) — 개발 착수 전 보완 권고

- **D-02 `TB_INVOICE` 누락 4컬럼**: `vat`·`unpaid_carryover`·`issued_at`·`paid_at` (PAY-08 재시도/유예·정산 집계 직결)
- **D-04 캠페인 채널 불일치**: 모델 단일 `channel` vs 06 §5.1 `channels[]` 배열 → SoT/모델 정렬 필요
- **D-05 시험 테이블 부재**: `min_exam_score`는 있으나 `TB_EXAM*` 없음 → 시험 오픈범위면 신설, 아니면 컬럼 비활성 명시
- **D-07 테넌트 `TB_SUBSCRIPTION`의 SELLER_PLAN 중복**: 마스터 구독과 충돌 → enum 2/3만 허용
- **D-08 `TB_TOSS_WEBHOOK_EVENT` 역할 구분**: master(SaaS/크레딧) vs tenant(상품결제) COMMENT 동일 → 구분 명시
- **유니크 누락**: `TB_COUPON_ISSUE(coupon_id,user_id)`·`TB_SETTLEMENT(instructor_user_id,period_month)`·`TB_USER_AGREEMENT(user_id,agreement_key)`
- **보관/파기 정책 부재**: 인증코드·토큰·세션(ip)·탈퇴 PII는 `status=-1` 소프트삭제만 → 물리파기/익명화 배치 정책(개인정보보호법 §21)
- **마케팅 동의 동기화(F-09)** · **GA/Meta 국외이전 동의(F-11)** · **RBAC `own` IDOR 매트릭스** · **R2 다운로드 권한 가드** · **약한 FK 앱계층 무결성 가드** · **비번 해시 알고리즘(bcrypt/argon2id) 명문화** · 인덱스 누락(campaign group·payment credit_charge·noti ref·authcode)

## 하(下)
`TB_INQUIRY.title` 50→100자, `TB_PLAYER_SETTING` 구조(전역/상품별 미정), `provider_email` 중복, COMMENT 보강(watched_sec·avg_rating CHECK·마스터 invoice retry_count), `TB_SESSION.last_used_at` 등.

---

## 충족(양호) 요약

- **컨벤션**: 104테이블 `id BIGINT AI PK`·`status INT(1/0/-1)`·`created/updated DATETIME`·`DECIMAL(18,6)`·utf8mb4·약한FK 네이밍 **일관**.
- **확정정책 14/16 충족**: C-1닉네임·C-2 TTL·C-3비번·C-4쿠폰정액(정률컬럼 부재)·C-6 card_last4·M-1 무료체험없음·M-2 RBAC·M-3 크레딧멱등·M-4/5/R-1 알림단일라우팅·M-6약관·M-7랜딩4·M-8빌링키/웹훅멱등·M-10마이페이지.
- **비즈니스 유니크/멱등**: `order_no`·`cert_no`·`(tenant_id,idempotency_key)`·`(user_id,product_id)`·`(provider,provider_uid)`·`event_id` 등 견고.
- **CTI 상품 7종**·**알림 3계층**·**정산 13컬럼**·**수료증 스냅샷**·**사이트빌더**·**게시판/문의** 데이터 백킹 충족.

---

## 다음 단계 (권고)

1. **모델 교정(비파괴 DDL)**: B-1·B-2·B-3·B-5·B-6 + 중 유니크/Invoice 컬럼 → `master.sql`/`tenant_template.sql` 개정 후 재적용(데이터 없음, 영향 0).
2. **문서 명문화**: B-4(암호화·접근제어), 보관/파기 정책, 캠페인 채널 SoT 정렬(D-04), 해시 알고리즘.
3. **인프라**: B-7 프로비저닝 전용 계정 설계(prod 전 필수).
4. **재검증(Round 2)**: 교정 후 동일 4축 재점검 → ❌'상' 0건 확인.
5. `biz_no`·`birth_date` 수집근거·국외이전 고지는 biz-legal 협의.
