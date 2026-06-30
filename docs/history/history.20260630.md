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

- **WBS 현행화**(2026-06-30): DB 설계·ERD(검증 2라운드 게이트 통과·102테이블·Figma ERD) → 스텝5 DB설계 0→95%·API명세 0→25%. 인증 슬라이스(프론트 화면+API+mock E2E) → 스텝6 프레임워크·스키마 0→35%·API개발 0→10%·외부API연동 0→5%·CF 인증·가입 0→35%. 진척 자동산출로 스텝/전체 반영(라이브 D1 + wbsData·seed 동기).

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

## 다음 단계 / 알려진 한계

- **dev DB(`solsol_lms`) 재적용 보류** — 회원 모델 변경(소셜 통합·login_id)을 reset→migrate로 반영 필요(확인 후).
- 소셜 5종 OAuth 키 준비 → mock→실 provider 교체, 프론트↔API 실연동(`NUXT_PUBLIC_API_BASE`·refresh 쿠키 도메인). 콜백 식별을 `*_uid`/`login_id` 기준으로 보강.
- 인증 QA 라운드(화면ID 커버리지+9축) → `docs/dev-validation/auth-round1.md`.
- 인프라: 테넌트 자동 프로비저닝 전용 DB 계정(B-7). biz-legal: 국외이전·고유식별정보 수집근거.
- 모델 잔여 중/하: avg_rating 집계경로·instructor_user_id 명칭통일·subject_type default 등.
