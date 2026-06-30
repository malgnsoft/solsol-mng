# 데이터 모델 ↔ 검증 정본 적합성 — Round 2 (교정 후 재검증)

- **대상**: 교정본 `docs/data-model/master.sql`(14) + `tenant_template.sql`(91) = **105 테이블** (+ dev DB 클린 리빌드 적용 완료)
- **기준**: [Round 1 결함표](data-model-vs-validation-round1.md)
- **검증축 4**: QA · 보안 · 개인정보 · DBA (각 축 재검증)
- **일시**: 2026-06-30 (KST) · 정본·모델 무수정

---

## 종합 판정: ✅ 게이트 통과 — 상(blocker) 잔여 0건

Round1 blocker 7건 중 **B-1~B-6 전량 해소**, B-7(테넌트 자동 프로비저닝 권한)은 **인프라 이슈로 스키마 게이트에서 제외**. 4개 축 모두 ❌'상' 0건.

| 축 | 상 잔여 | 비고 |
|---|---|---|
| QA | 0 | 7/9 완전해소, D-06 부분(명칭), 신규 중 2(N-01·N-02) |
| 보안 | 0 | 6/6 해소, 신규 하 3(앱계층 권고) — **PASS** |
| 개인정보 | 0 | 해소 3·부분해소 5(앱계층 이행)·미해소 3(중) |
| DBA | 0 | B-1~B-6 해소, 신규 하 3, 스키마 건전성 양호 |

---

## 해소 확인 (Blocker)

| Round1 | 해소 | 근거 |
|---|---|---|
| B-1 평문 토큰/코드 | ✅ | `code_hash`·`token_hash`(+`verify_count`), 세 토큰 해시 일관 |
| B-2 정산프로필 소유자 | ✅ | `TB_SETTLEMENT_PROFILE.instructor_user_id` + `uk_settleprofile_instructor` |
| B-3 후기·별점 | ✅ | `TB_REVIEW`(rating·UNIQUE(user_id,product_id)) 신설 |
| B-4 정산·결제 암호화 | ✅ | 빌링키 AES-256-GCM·계좌 암호화/마스킹 주석 + README 요건 |
| B-5 discount_rate 경계 | ✅ | COMMENT "UI 표시 전용·결제 미사용(C-4)" |
| B-6 세션 토큰 UNIQUE | ✅ | `uk_session_refresh` |
| B-7 테넌트 자동생성 권한 | ⏸ 인프라 | 모델 외 — prod 전 전용 계정 설계(별도 트랙) |

중결함(유니크 3·인덱스 4·Invoice 4컬럼·구독/웹훅 구분·문의 제목 등)도 적용 확인.

---

## 잔여 과제 (중/하 — 게이트 비차단)

**모델·문서 보완(권장, 저비용)**
- **N-01** `TB_PRODUCT.avg_rating` 집계 경로 미명시 → 갱신 방식(배치/트리거/앱) 주석화
- **N-02** `instructor_user_id` vs 06계약 `instructor_admin_id` 명칭 통일(주석 매핑은 완료)
- **N-03** 테넌트 `TB_SUBSCRIPTION.subject_type DEFAULT 1` → DEFAULT 2 또는 CHECK(2,3)
- **개인정보 문서 보완**: 웹훅 `raw_payload` 보관·마스킹(F-01), 캠페인 수신자 PII 파기(F-10), GA/Meta **국외이전** 고지·동의(F-11) — README 미반영
- 하: master `TB_INVOICE.retry_count` COMMENT, `TB_REVIEW.enrollment_id` 인덱스, `TB_COUPON_ISSUE` 중복 인덱스 정리

**앱계층 구현 게이트로 이월**(모델 요건화 완료, 구현 시 재검증)
- 토큰/코드 해시·빌링키/계좌 암호화 실장, RBAC `own` IDOR 필터, R2 presigned 권한가드, 보관·파기 배치, 마케팅 동의 동기화, verify_count 락아웃

**별도 트랙**
- B-7 프로비저닝 전용 DB 계정(인프라, prod 전 필수)
- biz-legal: `biz_no`·`birth_date` 수집근거, GA/Meta 국외이전(개인정보보호법 §28의8)
- D-04 캠페인 채널(단일 유지 vs 06 §5.1 배열) SoT 정렬

---

## 결론
데이터 모델은 검증 정본(정책 16·API계약·화면) 적합성 측면에서 **게이트 통과**(상 0). 잔여는 모두 중/하로, 앱계층 구현·문서·인프라·법무 트랙으로 분리 관리한다. dev DB(`solsol`/`solsol_lms`)에 교정본 클린 리빌드 적용 완료(master 14 / tenant 91).
