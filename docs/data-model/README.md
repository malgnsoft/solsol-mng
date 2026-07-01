# 쏠쏠 크리에이터 LMS — 데이터 모델 (Aurora MySQL · schema-per-tenant)

`solsol`(사용자단) · `solsol-admin`(관리자단) · `solsol-api`(백엔드)의 **백엔드 통합 스키마**.
정본(SoT)은 [docs/validation](../validation) 검증 패키지(00~06) + `solsol/mockup` + `solsol-admin/mockup`.

## 아키텍처: 크리에이터(테넌트)별 별도 스키마

크리에이터 1명 = **DB(스키마) 1개**. 데이터는 테넌트 스키마로 물리 분리되고, 플랫폼 공통 데이터만
중앙 마스터 스키마에 둔다. (MySQL에서 "스키마" = "데이터베이스")

| 파일 | 스키마(기본) | 적용 단위 | 테이블 |
| --- | --- | --- | --- |
| [master.sql](master.sql) | `solsol_master`(prod) | 1개(전역) | **12** |
| [tenant_template.sql](tenant_template.sql) | `solsol_t{테넌트ID 6자리}`(prod) 예: `solsol_t000123` | 테넌트마다 1개 | **91** |

> **개발(dev) 스키마 매핑 — 확정(2026-06-29)**: malgn-dev-db의 `solsol` 유저가 신규 DB 생성 권한이 없어,
> 이미 전권을 가진 기존 DB 2개를 사용한다. **마스터 = `solsol`**(Hyperdrive `malgn-dev-solsol-prv` 기본 DB와 일치),
> **개발 중 단일 테넌트 = `solsol_lms`**. 이후 추가 테넌트는 **`solsol_lms_<site_id>`**(예: `solsol_lms_1`).
> DDL은 스키마명을 하드코딩하지 않으므로(파일은 CREATE TABLE만), master.sql→`solsol`, tenant_template.sql→`solsol_lms`로 적용한다.
> 라우팅 정본은 `solsol.TB_SITE.schema_name`(테넌트1=`solsol_lms`). prod에서는 위 `solsol_master`/`solsol_t*`로 전환.
> ⚠️ 추가 테넌트의 `CREATE DATABASE`는 관리자 권한 필요(앱 `solsol` 유저 불가) — 자동 온보딩 경로는 prod OQ.
> Round1 교정 반영(2026-06-30): B-1~B-6 blocker 해소 + 중결함 유니크/인덱스/INVOICE 컬럼 적용.
> 소셜 통합(2026-06-30): `TB_USER_SOCIAL` 폐지 → `TB_USER`에 5종 SNS 컬럼(`google_uid`~`facebook_uid`, 각 UNIQUE) + `primary_provider` **비정규화**. 어떤 SNS로 로그인해도 1회원.
> 게시판 엔진화(2026-06-30): 게시판류=범용 엔진(`TB_BOARD`/`TB_POST`/`TB_COMMENT`/`TB_FILE`/`TB_BOARD_CATEGORY`, module 기반)으로 재구성, 우리 컨벤션 변환, schema-per-tenant라 `site_id` 없음. `TB_FAQ`·`TB_FAQ_CATEGORY`·`TB_INQUIRY`·`TB_INQUIRY_REPLY`·`TB_POST_LIKE`·`TB_ATTACHMENT` 6종은 엔진으로 흡수. 프리미엄 커뮤니티는 별도(`TB_COMMUNITY_POST`/`TB_COMMUNITY_COMMENT`). (총 89+14=103 테이블)
> 강좌 도메인 재정의(2026-06-30): `TB_PRODUCT.type` `general`→`course`. **강좌=`TB_PRODUCT`(공통)+`TB_COURSE`(확장·커리큘럼 루트)→`TB_SECTION`(course_id)→`TB_LESSON`(차시)** 계층 정립. `TB_LECTURE`→`TB_LESSON`, `TB_LECTURE_PROGRESS`→`TB_LESSON_PROGRESS`(`lecture_id`→`lesson_id`)로 개명. 라이브=**YouTube Live 전용**(`TB_PRODUCT_LIVE` 재모델: `live_kind`/`platform`/`capacity`/`stream_url` 제거, `youtube_url`·`youtube_video_id`·`recorded_content_id` 추가), 화상=`TB_PRODUCT_VIDEO_CALL`(zoom/google_meet) **신설 분리**. (+`TB_COURSE`·`TB_PRODUCT_VIDEO_CALL` → 총 91+14=105 테이블)
> 수강 등록 재구성(2026-06-30): `TB_ENROLLMENT`→**`TB_COURSE_USER`(수강생관리)** 개명·확장. LM `LM_COURSE_USER` 참고로 진도(`progress_ratio`/`progress_score`)·성적(`exam`/`homework`/`forum`/`etc`/`total`)·수료(`complete_yn`/`complete_no`/`complete_date`)·정지(`pause_cnt`/`pause_day`)·마감·구독·`course_id`/`package_id`/`subscription_id`/`order_item_id`/`tutor_user_id` 추가, 날짜 varchar→DATE/DATETIME·점수 DECIMAL·Y/N→TINYINT 변환. 참조 3종(`TB_LESSON_PROGRESS`/`TB_CERTIFICATE`/`TB_REVIEW`)의 `enrollment_id`→`course_user_id`. LM의 `SITE_ID`/`TERM_ID`/`TERM_USER_ID`/`LC_EXAM_ID`/`SUBSCRIBE_USER_ID`/`ENROLL_NOTI_RECEIVED`는 범위 밖 제외. (개명만 — 테이블 수 91 불변)

- **마스터** = 플랫폼 ↔ 크리에이터 관계: 사이트(테넌트) 레지스트리, 셀러·운영자 통합 계정(`TB_USER`), SaaS 요금제·구독·청구·결제,
  **크레딧(플랫폼이 크리에이터에게 판매)**, 토스 웹훅, 플랫폼 운영자, 프로비저닝 이력.
- **테넌트** = 각 크리에이터 사이트 운영 전체: 수강생/스태프·상품·콘텐츠·학습·주문/결제·정산·
  마케팅·알림·커뮤니티·사이트설정. `site_id` 컬럼 없음(스키마 자체가 테넌트).

### 신규 테넌트 프로비저닝(개념)
1. `master.TB_USER`(user_type=seller)/`TB_SITE` 행 생성 → `schema_name` 확정(예: `solsol_t000123`)
2. `CREATE DATABASE solsol_t000123 ...` 후 `tenant_template.sql`을 그 스키마에 적용
3. 시드(역할·기본 게시판·플레이어 설정·알림 라우팅) 입력 → `TB_SITE.provisioned_at` 기록

```sql
CREATE DATABASE solsol_master         DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE solsol_t000123        DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- master.sql → solsol_master,  tenant_template.sql → solsol_t000123
```

> 스키마명 패턴은 **기본값**(불변 숫자 ID 기반 권장). slug 기반(`solsol_johndoe`)도 가능하나
> slug 변경·문자셋 리스크가 있어 비권장. 변경 원하면 알려주세요.

---

## 적용 컨벤션 (요청 사항)

| 항목 | 규칙 |
| --- | --- |
| 테이블명 | `TB_` 접두 + **영어 단수**(UPPER_SNAKE) |
| PK | `id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY` (전 테이블) |
| 상태 | `status INT NOT NULL DEFAULT 1` — **1=정상 / 0=중지 / -1=삭제** (전 테이블, 소프트삭제) |
| 금액·크레딧·통화·수수료율 | `DECIMAL(18,6)` |
| 일시 | `TIMESTAMP`(내부 **UTC** 저장 — 세션/서버 tz 무관), 표시 시 로컬(KST 등) 변환. `created_at`/`updated_at`은 `CURRENT_TIMESTAMP`/`ON UPDATE` 기본시. 날짜 단위는 `DATE`. ※ DATETIME 대신 TIMESTAMP 채택 이유: dev Aurora 서버 tz=Asia/Seoul + **Hyperdrive가 세션 `SET time_zone` 미유지**라 DATETIME은 KST로 저장됨 → TIMESTAMP로 UTC 보장(OQ-TZ) |
| 외래키 | **약한 FK** = 논리적 FK(네이밍 + 조인 인덱스)만, DB `FOREIGN KEY` 제약·CASCADE 미설정 |
| FK 네이밍 | 참조테이블단수`_id`. `TB_USER`→`user_id`, `TB_SITE`→`site_id`. 동일 테이블 다중 참조 → 역할명`_user_id`(예: `instructor_user_id`) |
| 엔진/문자셋 | InnoDB / `utf8mb4` / `utf8mb4_unicode_ci` |

크로스 스키마 참조(테넌트→마스터: `credit_ledger_id` 등, 마스터 내부: `site_id`)는 전부 **논리 FK**.
schema-per-tenant라 DB 레벨 FK는 한 스키마 내부에서도 걸지 않는다(약한 FK 일관).

---

## 핵심 설계 결정

1. **통합 `TB_USER`(테넌트 내)** — 수강생/강사/서브강사/운영자를 `user_type`+RBAC로 구분.
   소셜 로그인은 `TB_USER`에 5종 SNS 컬럼 비정규화(`*_uid` 각 UNIQUE·`primary_provider`), ID/PW만 `TB_USER_CREDENTIAL` 분리. 권한(`TB_ROLE`/`TB_USER_ROLE`/`TB_ADMIN_PERMISSION` M-2).
2. **셀러·플랫폼 운영자 통합 계정은 마스터** — `master.TB_USER`(`user_type`=seller/admin)로 통합, **ID/PW 인라인**(login_id·email·password_hash). (구 `TB_SELLER`+`TB_PLATFORM_ADMIN`+`TB_SELLER_CREDENTIAL` 병합)
3. **구독 분리** — 셀러 SaaS 구독은 `master.TB_SUBSCRIPTION`(plan 기반), 학습자 멤버십/커뮤니티 구독은 `tenant.TB_SUBSCRIPTION`.
4. **크레딧은 마스터(은행통장식 단일 원장)** — 플랫폼이 크리에이터에게 판매. **`TB_CREDIT_LEDGER`** 하나에 증가(charge/bonus/refund_restore=lot, `remaining`·`expires_at`·`is_expiring` 보유)와 차감(usage/expire/adjust)을 시간순 적재(각 행 `balance_after`). 유효기간 있는(만료)·없는(무기한) lot을 FIFO(임박 만료 우선)로 소진, 부분소진은 **`TB_CREDIT_ALLOCATION`**(차감행↔lot) 매핑. **`TB_CREDIT_ACCOUNT`**=잔액 캐시(전체+expiring/permanent 분리). 종량·멱등(M-3, uk `site_id`+`idempotency_key`). 테넌트 캠페인/AI는 `credit_ledger_id`로 사용 차감행을 논리 참조. (구 `TB_CREDIT_CHARGE` 흡수, `TB_PAYMENT.credit_charge_id`→`credit_ledger_id`)
5. **상품 7종 통합(CTI)** — `TB_PRODUCT`(`type`: `course`/`live`/`video_call`/`digital`/`package`/`membership`/`community`) + 유형별 확장. 알림 단일 라우팅(R-1), 쿠폰 정액 only(C-4), 결제 비가역(M-8).
   - **강좌(course)** = `TB_PRODUCT`(공통) + `TB_COURSE`(확장·커리큘럼 루트, 1:1 `uk_course_product`) → `TB_SECTION`(`course_id`) → `TB_LESSON`(차시). 진도는 `TB_LESSON_PROGRESS`(`course_user_id`+`lesson_id` 유니크).
   - **라이브(live)** = `TB_PRODUCT_LIVE`(**YouTube Live 전용**: `youtube_url`/`youtube_video_id`/`recorded_content_id`, 입장 즉시 자동수료). **화상(video_call)** = `TB_PRODUCT_VIDEO_CALL`(zoom/google_meet, `meeting_url`/`capacity`)로 분리.
6. `TB_SITE`(구 단일DB) → 테넌트 내 단일행 `TB_SITE_CONFIG`(표시 설정)로 전환. 테넌트 레지스트리는 `master.TB_SITE`.
7. **게시판류=범용 엔진** — `TB_BOARD`(정의)/`TB_POST`(게시물)/`TB_COMMENT`(댓글)/`TB_FILE`(첨부)/`TB_BOARD_CATEGORY`(카테고리)를 `module`/`module_id` 기반으로 통합. 공지·FAQ·1:1문의(qna)·자유게시판을 `board_type`으로 분기. 기존 `TB_FAQ*`·`TB_INQUIRY*`·`TB_POST_LIKE`·`TB_ATTACHMENT`는 흡수. **프리미엄 커뮤니티는 별도**(`TB_COMMUNITY_POST`/`TB_COMMUNITY_COMMENT`, 첨부는 `TB_FILE module='community_post'` 재사용).
8. **수강 등록 = `TB_COURSE_USER`(수강생관리)** — LM `LM_COURSE_USER` 참고. 단순 수강권을 넘어 진도·성적(시험/과제/토론/기타/전체)·수료·정지·마감·구독까지 한 테이블에 집약. `course_id`(강좌)·`package_id`(패키지 경유)·`subscription_id`(구독 부여)로 부여 경로 추적, `tutor_user_id`로 담당 강사 지정. 진도/성적/수료 참조는 `course_user_id`로 통일(`TB_LESSON_PROGRESS`/`TB_CERTIFICATE`/`TB_REVIEW`).

---

## 보안·개인정보 구현 요건 (Round1 반영)

모델 수준 설계 결정 사항으로, 앱계층 구현 시 반드시 준수한다.

- **토큰·코드 해시 저장**: `TB_AUTH_CODE.code_hash`, `TB_PASSWORD_RESET_TOKEN.token_hash`, `TB_INVITE_TOKEN.token_hash` — 원문은 DB에 저장하지 않는다. `TB_SESSION.refresh_token_hash`와 동일 패턴.
- **빌링키·계좌 암호화**: `toss_billing_key`(master/tenant) — AES-256-GCM 암호화 저장, 키는 KMS/wrangler secret 관리, API 응답에 미포함. `account_no` — 저장 암호화, 조회 시 부분마스킹.
- **비밀번호 해시 알고리즘**: `password_hash` — bcrypt 또는 argon2id(영문·숫자·특수문자 3종 8~16자, C-3). 응답 미포함.
- **보관·파기 배치**: 인증코드·토큰·세션 ip — 만료 후 물리파기 또는 익명화. 탈퇴 PII(`email`·`phone`·`name`) — `status=-1` 소프트삭제 후 보관기간(개인정보보호법 §21 기준) 경과 시 익명화/삭제 배치 필수.
- **약한 FK 앱계층 무결성 가드**: DB `FOREIGN KEY` 제약 미사용(약한 FK 컨벤션) → 삭제·상태 변경 전 참조 정합성을 앱계층에서 검증.
- **RBAC own 스코프 IDOR 필터**: `TB_ADMIN_PERMISSION.data_scope='own'`인 경우 쿼리에 `instructor_user_id = 요청자` 필터를 앱계층에서 강제.
- **R2 다운로드 권한 가드**: `r2_key`가 있는 리소스(콘텐츠·정산프로필 서류·수강 자료) — presigned URL 발급 전 enrollment/role 검증 필수.
- **이체내역 마스킹**: `TB_REFUND.transfer_note`, `TB_REFUND_LOG.transfer_note` — 저장 전 계좌번호·예금주 마스킹 처리.

---

## 미결 / 추정 (실 적용 전 확정)

- **크레딧 단가**(`unit_price`) — 모델=종량제 확정, 값은 Open(M-3) → config 별도.
- **토스 웹훅** 상세(서명검증·재시도·정산 자동화) — 골격만.
- **세금계산서** 전용 엔티티 — SoT 부재(매출전표=PG 외부 영수증 대체).
- **캠페인 채널** — 목업/02=단일 vs 06=배열. 본 스키마는 단일 채널.
- `TB_MARKETING_TOOL`·`TB_SEO_OVERRIDE`·`TB_BANNER` — 목업/계약 근거 약함(추정).
- 테넌트 `TB_SUBSCRIPTION`의 `plan_id`/seller-plan 컬럼은 멤버십/커뮤니티 용도로는 미사용(마스터로 이관).

---

## 검증 상태

- 정적 구조: master(12)·tenant(91) 각각 `CREATE TABLE = ENGINE = PRIMARY KEY (id)` 일치, 괄호 균형 OK(SQL 구문), 테넌트 `site_id` 0건. 강좌 도메인 재정의 후 `TB_LECTURE`/`lecture_id` 잔존 0, `TB_SECTION.product_id` 0, `TB_PRODUCT_LIVE` 내 `live_kind`/`platform`/`stream_url`/`capacity` 0건 확인. 수강 등록 재구성 후 `TB_ENROLLMENT`/`enrollment_id` 잔존 0건(전부 `TB_COURSE_USER`/`course_user_id`) 확인.
- ⚠️ **라이브 DB 문법 검증 미실행**(로컬 MySQL 미기동). Aurora/MySQL 8.0에서 `SOURCE` 1회 적용 검증 권장.
