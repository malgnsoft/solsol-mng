# 2026-06-30 — 크리에이터 LMS 데이터 모델·ERD·인증 슬라이스 + 모델 검증 2라운드

> **한 줄 요약** — 검증 정본(`docs/validation`)·양 목업을 분석해 **Aurora MySQL schema-per-tenant 데이터 모델**(master 14 + tenant 91 = 105테이블)을 설계·DDL화하고, Hyperdrive(`malgn-dev-solsol-prv`)로 dev DB(`solsol`=master / `solsol_lms`=tenant1)에 적용·검증. 모델을 검증정본 대비 **2라운드 적합성 검증(게이트 통과)**, **Figma ERD**(컬럼·자료형·PK(FK)·코멘트) 보드화, 인증(AUTH) 풀스택 슬라이스(프론트 화면 + API + mock E2E)까지 착수. 본 커밋은 **solsol-mng 문서**만 배포.

## 1. 데이터 모델 (Aurora MySQL · schema-per-tenant)

- 5개 도메인 병렬 분석(에이전트팀)으로 엔티티·필드·관계 추출 → 통합 DDL.
- **컨벤션**: `TB_` 단수 · `id BIGINT AUTO_INCREMENT PK` · `status INT(1/0/-1)` · 금액/크레딧 `DECIMAL(18,6)` · `DATETIME` UTC + 기본시 · **약한 FK**(네이밍+인덱스, 제약 없음) · utf8mb4.
- **schema-per-tenant**: 크리에이터 1=스키마 1. `master`(플랫폼↔크리에이터: 테넌트 레지스트리·셀러·SaaS구독·결제·크레딧) + `tenant_template`(사이트 운영 전체).
- dev 매핑(확정): master=`solsol`, 개발 테넌트=`solsol_lms`, 이후 `solsol_lms_<site_id>`.

## 2. Hyperdrive DB 연결·적용

- Cloudflare Hyperdrive `malgn-dev-solsol-prv`(id `a14c69…`, MySQL 8.0.42, 터널) 연결 검증(`wrangler dev --remote`). **USE 미지원** 확인 → 스키마 정규화 쿼리(`mysqlSchema(schema).table()`) 채택(OQ-DRZ 해소).
- `solsol-api`에 마이그레이션 러너 + `/ops/{reset,migrate,seed,verify}` 구축. dev DB 클린 리빌드 적용: master 14 / tenant 91 무오류 + 시드(셀러·테넌트).

## 3. 모델 적합성 검증 (Round 1·2)

- 4축(QA·보안·개인정보·DBA)으로 검증정본 대비 점검. **Round1**: blocker 7 식별. **교정**(토큰/코드 해시·정산프로필 소유자·`TB_REVIEW` 신설·암호화 요건·세션 UNIQUE 등) 후 클린 리빌드 재적용. **Round2**: ❌'상' 0건 → **게이트 통과**. 잔여는 중/하(앱계층·문서·biz-legal 트랙).

## 4. Figma ERD

- 마스터/테넌트 **별도 보드 2개**, 도메인별 다이어그램, 표기순 **컬럼명·자료형·PK(FK)·코멘트**.
- 마스터 v2 <https://www.figma.com/board/UR6M26ECZvEStba9rs3zVt> · 테넌트 v2 <https://www.figma.com/board/tds3QGtVLaj5InmKM56um5>

## 5. 인증(AUTH) 풀스택 슬라이스 — 착수(미배포)

- ADR `docs/architecture/AUTH_SPRINT1.md` + 클라우드 준비 체크리스트.
- 프론트 `solsol/`(신규 앱, 목업 동결): 로그인·가입·약관게이트·콜백·프로필/탈퇴 화면 + useAuth/useApi/미들웨어, 빌드 GREEN.
- API `solsol-api`: A1~A6 + M1~M7 + JWT/리프레시(해시·회전·재사용감지) + **mock provider E2E 11건 PASS**.
- ⏸ 운영 전: 소셜 5종 OAuth 키(OQ-OAUTH)·프론트↔API 실연동·인증 QA 라운드.


## 산출물

- `docs/data-model/`: `master.sql`·`tenant_template.sql`·`README.md`·`ERD.md`
- `docs/architecture/`: `AUTH_SPRINT1.md`·`CLOUD_PREREQUISITES.md`
- `docs/dev-validation/`: `data-model-vs-validation-round1.md`·`round2.md`·`BR01-brand-site-v3-round1.md`
- (별도 레포·미배포) `solsol-api` 인증 API, `solsol/` 신규 프론트 앱
- 본 배포: solsol-mng 문서 커밋·푸시(malgn). 앱 코드/콘텐츠 변경 없음 → Pages 재배포 생략.

## 6. 회원 모델 조정 (소셜 비정규화 + 로그인아이디/이메일 분리)

- **`TB_USER_SOCIAL` 폐지 → `TB_USER` 비정규화**: `google_uid`·`kakao_uid`·`naver_uid`·`apple_uid`·`facebook_uid`(각 UNIQUE, NULL 다건 허용) + `primary_provider`(대표 SNS). 어떤 SNS로 로그인해도 1회원, 로그인 조회는 provider별 UNIQUE 인덱스. 테넌트 91→**90**.
- **`login_id` / `email` 분리**: staff=별도 로그인 아이디(변경불가), learner=소셜 이메일을 `login_id`·`email`에 동일 입력. `login_id` VARCHAR(255)·`uk_user_login_id` UNIQUE.
- 영향: `solsol-api` 인증 코드(미커밋·mock)가 `TB_USER_SOCIAL`·email-as-login 전제 → 실연동 시 재작성 필요. **dev DB 재적용은 미실행**(모델 파일만 반영).

## 7. 게시판류 범용 엔진 재구성 + 프리미엄 커뮤니티 별도

- 사용자가 제공한 **범용 게시판 엔진 DDL**(TB_BOARD/POST/COMMENT/FILE/CATEGORY, module 기반)을 **우리 컨벤션으로 변환**해 게시판류를 재구성. 소문자·`id BIGINT AI`·`DATETIME`·Y/N→TINYINT·`site_id` 없음.
- **교체(3)**: `TB_BOARD`(엔진 정의·`uk_board_code`)·`TB_POST`(`board_type` 분기·`idx(board_id,created_at,id)`)·`TB_COMMENT`(module 기반). **신설(4)**: `TB_BOARD_CATEGORY`·`TB_FILE`(module 기반, `TB_ATTACHMENT` 대체)·`TB_COMMUNITY_POST`·`TB_COMMUNITY_COMMENT`(프리미엄 커뮤니티 별도). **삭제(6)**: `TB_FAQ`·`TB_FAQ_CATEGORY`·`TB_INQUIRY`·`TB_INQUIRY_REPLY`·`TB_POST_LIKE`·`TB_ATTACHMENT`.
- 공지=`notice`·FAQ=`faq`·**1:1문의=`qna`**(`secret_yn`+`proc_status`)·자유=`free`. 게시판류만 적용(상품 카테고리/파일 현행 유지).
- 테넌트 **88** / 총 **102**. dev DB 클린 리빌드 반영 완료(reset→migrate 88·seed). Figma 테넌트 보드 커뮤니티 도메인 **제자리 갱신**(URL 유지 `tds3QGtVLaj5InmKM56um5`).
- (앞서) 회원 소셜 5종 비정규화 + `login_id`/`email` 분리도 dev DB 반영·ERD 인증 도메인 제자리 갱신 완료.

## 8. 강좌·수강 도메인 재구조화 + 게시판 카테고리 정비 (동기화)

사용자 제공 malgn 표준 테이블(`LM_COURSE_USER`/`LM_COURSE_PROGRESS`/`LM_COURSE_USER_LOG`/`LM_COURSE_TUTOR`)을 우리 컨벤션으로 변환·반영.
- **강좌 계층**: `TB_PRODUCT.type` general→**course**. `TB_PRODUCT`(공통) ─1:1─ **`TB_COURSE`**(강좌) ─1:N─ `TB_SECTION`(course_id) ─1:N─ **`TB_LESSON`**(`TB_LECTURE` 개명). **`TB_COURSE_TUTOR`**(과정강사·정산비율) 신설.
- **라이브=YouTube Live 전용** 재모델(`TB_PRODUCT_LIVE`), **화상=`TB_PRODUCT_VIDEO_CALL`** 분리.
- **수강/학습 3계층**: `TB_ENROLLMENT`→**`TB_COURSE_USER`**(수강생관리·진도/성적/수료/정지/구독), **`TB_LESSON_PROGRESS`**(진도관리·이어보기), **`TB_COURSE_USER_LOG`**(학습기록·접속로그). 참조 `enrollment_id`→`course_user_id`.
- **게시판 카테고리**: `TB_BOARD_CATEGORY`를 `module`→**`board_id`** 종속으로, 프리미엄 커뮤니티용 **`TB_COMMUNITY_CATEGORY`**(product_id) 신설.
- **컨벤션**: 전 컬럼 **`_yn`→`is_`**, 날짜 varchar→DATE/DATETIME, 점수 DECIMAL, site_id 없음.
- 테넌트 **93** / 총 **107**. **동기화 완료**: dev DB 클린 리빌드(93) + Figma ERD 상품·학습/커뮤니티 도메인 제자리 갱신(URL 유지) + 커밋.

## 9. 디지털 상품 다운로드 이력 + Figma ERD 전면 재구성

- **`TB_DIGITAL_DOWNLOAD_LOG`** 신설 — 유료 디지털 상품의 다운로드 1건=1행(누가·무엇을·언제·어느 주문). `digital_file_id`·`product_id`·`course_user_id`·`user_id`·`order_id`·`ip_addr`·`user_agent`·`created_at`(다운로드시각). 한도(`download_limit`) 집계·구매검증·환불추적 근거. 테넌트 **94** / 총 **108**. dev DB 클린 리빌드 반영(94, 0오류).
- **Figma 테넌트 ERD 전면 재구성** — 누적 갱신으로 노드 ID/배치가 뒤섞여, 보드 전체(227노드) 삭제 후 정본(94)에서 **5개 도메인을 처음부터 재생성**(URL 유지 `tds3QGtVLaj5InmKM56um5`). 검증: 홈 테이블 94 전수 존재(누락 0), 총 107노드·커넥터 129.

## 10. 디지털 다운로드 이력·수강생 테이블 컬럼 정리(레거시 제거)

- **`TB_DIGITAL_DOWNLOAD_LOG`**: `course_user_id`(수강) 제거 — 디지털 구매는 수강 개념과 무관. 구매권 근거를 **`order_id`+`order_item_id`**(주문/주문항목)로 정정. 인덱스 `idx_dldlog_order`.
- **`TB_COURSE_USER`**: malgn 레거시 컬럼 26종 제거(검증 정본 학습자/수료/학습기간 화면 기준). 성적체계(progress_score·exam/homework/forum/etc·total_score) — 쏠쏠은 **완료 기준=진도율**(시험 P1 미구현)이라 불필요 → 삭제. 반명·담당강사·회원등급·학점·수료당시소속·미수료사유·관리자메모·마감(3)·정지(2)·구독사용유무·상태변경일 제거. **유지 18컬럼**: 구매연결(product/course/package/order/order_item/subscription)·grant_source·learn_status·start/end_date·renew_cnt·progress_ratio·is_complete·complete_no·complete_date·status. 
- dev DB 클린 리빌드 반영(94, 0오류). Figma 도메인2 제자리 갱신(노드 ID 접두사 기준 정밀 교체, URL 유지). 테넌트 **94** 유지.
- 참고: 수료여부 변경 모달의 '변경 사유'(필수, 05) 보존이 필요하면 `TB_COURSE_USER_STATUS_LOG`(상태변경 이력) 별도 신설 검토.

## 11. 수료조건을 TB_COURSE로 흡수 + TB_COMPLETION_RULE 삭제

- 수료 조건을 별도 테이블이 아닌 **`TB_COURSE` 컬럼**으로 이동: `min_progress_rate`(수료 최소 진도율 10~100, 기본 80)·`watch_mode`(free/sequential 순차시청)·`certificate_template_id`(수료증 템플릿, NULL=미사용·설정 시 자동발급).
- **`TB_COMPLETION_RULE` 삭제**(강좌 1:1이라 별도 테이블 불필요). 레거시 `min_exam_score`는 시험 미구현·성적 제거 일관성으로 미이전.
- 테넌트 **93** / 총 **107**. dev DB 클린 리빌드(93, 0오류) + Figma 도메인2 제자리 갱신(URL 유지).
- 참고: 라이브 수료증(②수료 탭)도 템플릿이 필요하면 `TB_PRODUCT_LIVE`에 `certificate_template_id` 추가 검토(현재 course만 보유).

## 12. 금액 컬럼 네이밍 통일(_price) 

- **통화 금액 컬럼 = `_price` 접미** 규칙 확정: 정가 `list_price`·할인액 `discount_price`·거래액 `pay_price`. tenant 35건·master 5건 치환.
  - 주요: `TB_PRODUCT.price→list_price` · `TB_ORDER`(subtotal→list_price·shop_discount→shop_discount_price·coupon_discount→coupon_discount_price·vat→vat_price·total→pay_price) · `TB_ORDER_ITEM`(item_discount→discount_price·amount→pay_price) · `TB_PAYMENT/INVOICE.amount→pay_price`·vat→vat_price · `TB_REFUND`(requested/refund_amount→requested/refund_price) · `TB_COUPON`(discount/min_order_amount→discount/min_order_price) · 정산·세금(gross/supply/sales_fee/pg_fee/net/canceled/paid→*_price) · 멤버십/커뮤니티 monthly_fee→monthly_price · master invoice/payment/credit_charge.pay_amount.
  - **유지**(통화 아님): 비율 `*_rate`(sales_fee_rate)·진도율 ratio·평점 avg_rating·횟수 unit_count·크레딧 단위(balance·charge/bonus/ledger amount)·study_hours·metric_value.
- dev DB 클린 리빌드(master 14·tenant 93, 0오류). Figma 도메인2·3 제자리 갱신 — **금액 컬럼을 처음으로 ERD에 노출**(기존 파서가 DECIMAL(p,s) 콤마로 누락하던 것 수정). URL 유지.
- 참고: 마스터 Figma 보드(`UR6M…`)의 invoice/payment/credit 금액 표기 갱신은 별도 요청 시.

## 13. 설문 보기 정규화(JSON 제거)

- 설문의 JSON 컬럼 제거 → 관계형 정규화. **`TB_SURVEY_OPTION`**(문항 보기) 신설(survey_question_id·seq·label).
  - `TB_SURVEY_QUESTION.options(JSON)` 제거 → 보기는 `TB_SURVEY_OPTION` 행, rating은 `rating_max` 컬럼.
  - `TB_SURVEY_ANSWER.answer_option(JSON)` 제거 → `survey_option_id`(radio/check, 복수선택은 보기당 1행)·`rating_value`(척도)·`answer_text`(주관식).
- 테넌트 **94** / 총 **108**. dev DB 클린 리빌드(94, 0오류) + Figma 도메인4 제자리 갱신(URL 유지).
- 남은 JSON 컬럼(설문 외): `TB_RECIPIENT_GROUP.condition_logic`·`TB_PAGE_SECTION.config`·`TB_CERTIFICATE_TEMPLATE.display_items` 등 — 필요 시 동일 방식 정규화 검토.

## 14. 설문 보기 인라인화(option1~10) + TB_SURVEY_OPTION 삭제

- 13의 정규화를 되돌려 **고정 보기 컬럼** 방식 채택: `TB_SURVEY_QUESTION`에 `option1~option10`(VARCHAR(500)) 추가. **`TB_SURVEY_OPTION` 삭제**.
- `TB_SURVEY_ANSWER.survey_option_id`(FK) → **`option_no`**(INT, 보기 번호 1~10). radio/check 동일, 복수선택은 보기당 1행.
- 테넌트 **93** / 총 **107**. dev DB 클린 리빌드(93, 0오류) + Figma 도메인4 제자리 갱신(URL 유지).

## 15. 영상 콘텐츠 = 위캔디오(Wecandeo) VOD

- 강의 영상 호스팅을 **위캔디오** 서비스로 결정. `TB_CONTENT` 반영:
  - `source_type` 기본값 `upload`→**`wecandeo`**(영상 VOD)/youtube(임베드)/upload(문서·이미지 R2)
  - **`wecandeo_video_key`**(위캔디오 VOD 키/ID) 신설. `r2_key`는 문서·이미지용으로 한정, 썸네일/인코딩 상태 주석 갱신.
- 테넌트 **93** 유지. dev DB 클린 리빌드(93, 0오류) + Figma 도메인2 제자리 갱신(URL 유지).
- 후속: 위캔디오 업로드/재생(서명URL·플레이어) 연동 시 API 키·웹훅(인코딩 완료 콜백) 설계. 자막(TB_SUBTITLE)·AI 자막/번역은 위캔디오 소스 기준 처리.

## 16. 자막 테이블 삭제(위캔디오 관리)

- 자막을 **위캔디오가 보관·제공**하므로 `TB_SUBTITLE`·`TB_SUBTITLE_LINE` 삭제(별도 저장 불필요).
- 테넌트 **91** / 총 **105**. dev DB 클린 리빌드(91, 0오류) + Figma 도메인2 제자리 갱신(URL 유지).
- 참고: AI 자막/번역(`TB_AI_JOB` kind=ai_caption/ai_translate, `TB_CONTENT.has_ai_translate`)은 유지 — 생성 결과는 위캔디오로 반영.

## 17. 시간대 UTC — DATETIME→TIMESTAMP 전면 전환 (OQ-TZ)

- **문제**: dev Aurora(`malgn-dev-solsol-prv`) 서버 `time_zone=Asia/Seoul` → `DATETIME DEFAULT CURRENT_TIMESTAMP`가 KST 저장(UTC 컨벤션 위반). **Hyperdrive는 세션 `SET time_zone`을 쿼리 간 유지하지 않아**(동일 핸들 SET→SELECT도 실패, 검증) 앱 레벨 UTC 강제 불가. 파라미터그룹 UTC는 **공용 클러스터(타 프로젝트 DB 공존)** 라 영향.
- **결정**: 시각 컬럼 **`DATETIME`→`TIMESTAMP` 전면 전환**(tenant 239·master 49건). TIMESTAMP는 세션/서버 tz와 무관하게 **내부 UTC 저장** → solsol 스키마만 바꿔 UTC 보장, 타 프로젝트 무영향. `DATE`(날짜 단위 8개)는 유지.
- dev DB 클린 리빌드(master 14·tenant 91, 0오류 — MySQL 8.0 다중 TIMESTAMP DEFAULT OK). README 컨벤션 문구 갱신.
- `solsol-api` DB 클라이언트(`createConn`)는 효과 없는 세션 SET 제거 + Hyperdrive 한계 주석. 공용 지식베이스(`malgn-family.md`)에 Hyperdrive 세션 비유지·DATETIME tz 함정 기록.
- 읽기 주의: 현재 KST 세션으로 읽으면 KST로 렌더(절대시각은 UTC로 정확). UTC 문자열이 필요하면 `UNIX_TIMESTAMP`/`CONVERT_TZ` 또는 prod에서 세션 UTC.
- ⏳ ERD 타입 라벨(일부 `datetime` 표기)은 코스메틱 미반영 — 요청 시 보드 일괄 갱신.

## 18. 관리 허브(solsol-mng) 개선 — 화면 페이지·WBS

- **`/screens` 디자인 검수 단계 추가**: 퍼블리싱↔개발 사이 **「디자인 검수」**(review) 칸 신설(클릭 토글·D1 저장). schema·마이그레이션 0005·screenStatus·API(get merge·patch)·페이지 STAGES·영역 탭 진척바 일괄.
- **`/screens` 화면별 다중 코멘트**: `screen_comment` 테이블 + `screenComments` 유틸(D1+폴백) + API(목록/작성/삭제) + GET `/api/screens` 코멘트수 머지. 💬 버튼 → **우측 채팅 레이어(drawer)**로 작성·삭제(작성자=로그인 회원). 영역 탭 "디자인 검수" 라벨 줄바꿈 방지(라벨열 66px+nowrap).
- **WBS 담당 필터 = 담당 ∪ 책임**: `peopleCount`·`taskPass`가 owner만 보던 것을 owner∪responsible로 확장(책임=김도형 항목도 칩에 카운트·필터).
- **사이트 타이틀** "쏠쏠 관리" → **"쏠쏠 프로젝트 관리"**(nuxt.config title·titleTemplate).
- **WBS 현행화**(상기 §1~5 반영): DB설계·ERD 0→95%·API명세 0→25% / 프레임워크·스키마 0→35%·API개발 0→10%·외부API연동 0→5%·CF 인증·가입 0→35%. 진척 자동산출 → 스텝5 63%·스텝6 4%·**전체 39.5→43.3%**. 라이브 D1 + wbsData·seed 동기.
- 마이그레이션 0005(screen_status.review + screen_comment) 원격 D1 적용. solsol-mng 다수 배포.

## 18. 마스터 스키마 — TB_TENANT → TB_SITE 개명

- 마스터 테넌트 레지스트리 **`TB_TENANT`→`TB_SITE`** 개명 + FK 컬럼 **`tenant_id`→`site_id`**(8개 테이블)·키명(`uk_site_*`/`idx_*_site`)·`TB_TENANT_PROVISION_LOG`→**`TB_SITE_PROVISION_LOG`** 일괄 정리.
- `solsol-api` 코드 동기: `schema.master.ts`(ms.table 'TB_SITE') · `ops.ts`(seed/verify `solsol.TB_SITE`). JS 라우팅 변수 `tenant`은 멀티테넌시 개념이라 유지.
- dev DB 클린 리빌드(master 14·tenant 91, 0오류) — `TB_SITE` 시드 정상. README 참조 갱신.
- Figma: 마스터 보드(`UR6M…`) 전면 재생성(TB_SITE·_price·timestamp 반영). **이후 Figma는 사용자 요청 시 일괄 갱신**(건별 갱신 중단).

## 19. 마스터 계정 통합 — TB_SELLER + TB_PLATFORM_ADMIN → TB_USER

- 마스터의 **셀러(`TB_SELLER`) + 플랫폼 운영자(`TB_PLATFORM_ADMIN`)를 `TB_USER`로 통합**, `user_type`(seller/admin)으로 구분. 운영자 역할은 `role`(superadmin/admin/support, admin일 때) 컬럼 유지.
- 자격증명 패턴을 테넌트와 통일: `TB_SELLER_CREDENTIAL`→**`TB_USER_CREDENTIAL`**(운영자 인라인 password_hash도 흡수). `seller_id`→`user_id`.
- 참조 정리: `TB_SITE.owner_seller_id`→**`owner_user_id`**, `TB_SUBSCRIPTION`/`TB_BILLING_KEY.seller_id`→`user_id`, 키명 `idx_*_user`.
- 마스터 **14→13** 테이블. `solsol-api` 시드(`ops.ts`) `TB_USER`(user_type=seller)로 갱신, verify 기대치 13.
- dev DB 클린 리빌드(master 13·tenant 91, 0오류) — 시드 `TB_SITE.owner_user_id=1` 정상. 정본 4종(sql·README·ERD.md·DB) 동기. **Figma는 다음 일괄 갱신 시 반영.**

## 20. 마스터 TB_USER — login_id + 비밀번호 인라인, TB_USER_CREDENTIAL 흡수

- `TB_USER`에 **`login_id`**(로그인 아이디, uk_user_login_id)·**`password_hash`/`password_updated_at`/`two_factor_email`** 추가. email은 연락용으로 분리.
- **`TB_USER_CREDENTIAL` 삭제**(마스터는 소셜 없이 ID/PW뿐이라 분리 이점 없음 → 인라인). 테넌트 `TB_USER_CREDENTIAL`은 소셜/분리 유지.
- 마스터 **13→12**. `solsol-api` 시드(login_id·password_hash)·verify(12) 동기, dev DB 클린 리빌드(master 12·tenant 91, 0오류).
- 정본 sql·README·ERD.md 갱신. Figma 마스터 보드는 다음 일괄 갱신 시.

## 21. 크레딧 도메인 재설계 — 은행통장식 단일 원장 + 유효기간 lot (에이전트팀 DBA 설계)

사용자 요구(①유효기간 있는/없는 크레딧 구분 ②증가·차감이 한 테이블에 통장식으로) → **DBA 에이전트에 설계 위임**, 총괄이 통합·적용.
- **`TB_CREDIT_LEDGER`(통장식 단일 원장)**: 구 `TB_CREDIT_CHARGE`+`TB_CREDIT_LEDGER` 통합. 증가행(charge/bonus/refund_restore)=lot(`remaining`·`expires_at`·`is_expiring`·`lot_state`), 차감행(usage/expire/adjust). 각 행 `balance_after`(통장 잔고). `direction`(credit/debit)+양수 `amount`. 멱등 uk(`site_id`,`idempotency_key`).
- **`TB_CREDIT_ALLOCATION`(신설)**: 차감행↔소진 lot 매핑(1차감:N lot). FIFO(임박 만료 우선, 무기한 후순위) 부분소진 정밀 추적. 통장은 사용 1건=1행 유지.
- **`TB_CREDIT_ACCOUNT`(확장)**: 잔액 캐시에 `expiring_balance`/`permanent_balance`/`next_expire_at`/`last_ledger_id` 추가(원장이 정본, 캐시는 스냅샷).
- **삭제**: `TB_CREDIT_CHARGE`(→원장 charge 증가행 흡수). `TB_PAYMENT.credit_charge_id`→**`credit_ledger_id`**.
- 마스터 **12 유지**(−CHARGE +ALLOCATION). dev DB 클린 리빌드(master 12·tenant 91, 0오류). 정본 sql·README·ERD.md 갱신. Figma 다음 일괄.
- 앱계층 주의(설계 근거): usage=1트랜잭션(차감행+lot UPDATE+allocation+account 캐시), lot 잠금(FOR UPDATE)로 경합 직렬화, 불변식 `lot.remaining=amount−Σconsume+Σrestore`·`balance_after` 연쇄·음수 금지. 기존 운영데이터 있으면 CHARGE→원장 백필 별도.

## 22. TB_CREDIT_ACCOUNT 삭제 — 잔액은 원장 파생

- `TB_CREDIT_ACCOUNT`는 `TB_CREDIT_LEDGER`에서 100% 파생되는 캐시(드리프트·정합배치 부담)라 **삭제**. 잔액=최신 `balance_after`, expiring/permanent=열린 lot `SUM(remaining)` by `is_expiring`, next_expire=`MIN(expires_at)`. 읽기 성능 이슈 시 캐시 재도입 여지만 주석으로 남김.
- 마스터 **12→11**. dev DB 클린 리빌드(11/91, 0오류). README·ERD.md 갱신, ops verify 기대치 11.

## 23. 크레딧 단일 테이블화 — TB_CREDIT_ALLOCATION 삭제

- 사용자 요청: 크레딧 생성/차감 내역 + 증가행의 "사용 후 남은 크레딧(`remaining`)"만 있으면 **한 테이블로 충분**.
- **`TB_CREDIT_ALLOCATION` 삭제** → 차감 시 FIFO(임박 만료 우선)로 증가행 `remaining`을 **직접 차감**(별도 매핑 없음). 통장·잔액·유효기간 소진 모두 `TB_CREDIT_LEDGER` 단일 테이블로 처리.
- 트레이드오프: "어느 사용이 어느 lot을 깠나"의 lot 단위 감사추적은 포기(잔액·만료 정확성은 remaining으로 보장). 필요 시 재도입 여지.
- 마스터 **11→10**(크레딧=`TB_CREDIT_LEDGER` 1개). dev DB 클린 리빌드(10/91, 0오류). README·ERD.md 갱신, ops verify 10.

## 24. 크레딧 lot 감사추적 — source_ledger_id (단일 테이블 유지)

- 매핑 테이블 없이도 lot 추적 가능: 차감행에 **`source_ledger_id`**(소진한 증가lot 원장행 id) 추가. 한 사용이 여러 lot에 걸치면 **lot별 차감행 분할**(각 행이 자기 lot 참조). 단일 `TB_CREDIT_LEDGER`로 통장+FIFO+감사추적 동시 충족.
- 멱등 uk를 `(site_id, idempotency_key, source_ledger_id)`로 확장(분할 차감 허용). `idx_ledger_source` 추가. 마스터 10 유지.
- dev DB 클린 리빌드(10/91, 0오류). ⚠️ `solsol-api` `wrangler.toml` APP_ENV=production으로 ops가 403 → dev 세션은 `--var APP_ENV:local` 오버라이드로 적용(운영 안전가드 정상 동작 확인).

## 다음 단계 / 알려진 한계

- **dev DB(`solsol_lms`) 재적용 보류** — 회원 모델 변경(소셜 통합·login_id)을 reset→migrate로 반영 필요(확인 후).
- 소셜 5종 OAuth 키 준비 → mock→실 provider 교체, 프론트↔API 실연동(`NUXT_PUBLIC_API_BASE`·refresh 쿠키 도메인). 콜백 식별을 `*_uid`/`login_id` 기준으로 보강.
- 인증 QA 라운드(화면ID 커버리지+9축) → `docs/dev-validation/auth-round1.md`.
- 인프라: 테넌트 자동 프로비저닝 전용 DB 계정(B-7). biz-legal: 국외이전·고유식별정보 수집근거.
- 모델 잔여 중/하: avg_rating 집계경로·instructor_user_id 명칭통일·subject_type default 등.
