-- =====================================================================
--  쏠쏠 크리에이터 LMS — 테넌트(크리에이터) 스키마 템플릿 (Aurora MySQL 8.0)
--  schema-per-tenant: 크리에이터 1명 = DB(스키마) 1개. 이 파일을 신규 테넌트마다 적용.
--  스키마명 패턴(기본): solsol_t{테넌트ID 6자리}  예) solsol_t000123
--  플랫폼↔크리에이터 공통 데이터는 master.sql 참조.
-- ---------------------------------------------------------------------
--  컨벤션: TB_ 단수 / id BIGINT AUTO_INCREMENT PK / status INT(1정상 0중지 -1삭제)
--          금액·크레딧 DECIMAL(18,6) / DATETIME UTC + created_at·updated_at 기본시
--          약한 FK(네이밍+인덱스, DB제약 미설정) / utf8mb4_unicode_ci
--  ※ 테넌트=스키마 이므로 site_id 컬럼 없음. 크로스스키마 참조는 논리 FK.
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';


CREATE TABLE TB_SITE_CONFIG (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  name            VARCHAR(100) NOT NULL                COMMENT '사이트명(로고 텍스트 바인딩)',
  url             VARCHAR(255)     NULL                COMMENT '사이트 URL',
  description     VARCHAR(160)     NULL                COMMENT '사이트 설명(검색엔진용)',
  email           VARCHAR(255)     NULL                COMMENT '대표 이메일',
  logo_key        VARCHAR(255)     NULL                COMMENT '로고 R2 키',
  favicon_key     VARCHAR(255)     NULL                COMMENT '파비콘 R2 키',
  sns_youtube     VARCHAR(255)     NULL,
  sns_instagram   VARCHAR(255)     NULL,
  sns_twitter     VARCHAR(255)     NULL,
  sns_facebook    VARCHAR(255)     NULL,
  seo_title       VARCHAR(255)     NULL,
  seo_description VARCHAR(160)     NULL,
  og_image_key    VARCHAR(255)     NULL                COMMENT 'OG 이미지 R2 키(1200x630)',
  status          INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트 표시 설정(테넌트 내 단일행)';

CREATE TABLE TB_USER (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  user_type          VARCHAR(20)  NOT NULL DEFAULT 'learner' COMMENT 'learner(수강생)/staff(강사·서브강사·운영자)',
  email              VARCHAR(255)     NULL                COMMENT '로그인 ID 겸용(staff 필수·변경불가)',
  nickname           VARCHAR(15)      NULL                COMMENT '2~15자 단일규칙(C-1)·중복/금칙어',
  name               VARCHAR(50)      NULL                COMMENT '실명',
  phone              VARCHAR(20)      NULL,
  dept               VARCHAR(50)      NULL                COMMENT '부서(staff)',
  intro              TEXT             NULL                COMMENT '소개글(강사)',
  avatar_key         VARCHAR(255)     NULL                COMMENT '프로필 이미지 R2 키',
  is_primary_account TINYINT      NOT NULL DEFAULT 0      COMMENT '최초 연동 SNS=대표(learner)',
  marketing_agreed   TINYINT      NOT NULL DEFAULT 0      COMMENT '마케팅 수신 동의 스냅샷(정본은 TB_USER_AGREEMENT)',
  last_login_at      DATETIME         NULL,
  withdrawn_at       DATETIME         NULL                COMMENT '탈퇴 시각(status=-1 연동)',
  status             INT          NOT NULL DEFAULT 1      COMMENT '1활성 0중지(suspended) -1탈퇴',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일',
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_nickname (nickname),
  UNIQUE KEY uk_user_email (email),
  KEY idx_user_type (user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='통합 회원(수강생/강사/서브강사/운영자)';

CREATE TABLE TB_USER_SOCIAL (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  user_id        BIGINT       NOT NULL,
  provider       VARCHAR(20)  NOT NULL                COMMENT 'google/kakao/naver/apple/facebook',
  provider_uid   VARCHAR(255) NOT NULL                COMMENT '소셜 측 고유 ID',
  provider_email VARCHAR(255)     NULL,
  is_primary     TINYINT      NOT NULL DEFAULT 0,
  linked_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status         INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_social_provider (provider, provider_uid),
  KEY idx_social_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='소셜 로그인 연동(수강생)';

CREATE TABLE TB_USER_CREDENTIAL (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  user_id             BIGINT       NOT NULL,
  password_hash       VARCHAR(255) NOT NULL                COMMENT '영문·숫자·특수문자 3종 8~16자(C-3) 해시. 응답 미포함',
  password_updated_at DATETIME         NULL,
  two_factor_email    TINYINT      NOT NULL DEFAULT 0      COMMENT '이메일 2단계 인증',
  invited_by_user_id  BIGINT           NULL                COMMENT '초대한 관리자(TB_USER)',
  status              INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_credential_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ID+PW 자격증명(운영자/강사)';

CREATE TABLE TB_ROLE (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  code       VARCHAR(30)  NOT NULL                COMMENT 'owner/instructor/sub_instructor/learner',
  name       VARCHAR(50)  NOT NULL,
  status     INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_role_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='역할 카탈로그(RBAC)';

CREATE TABLE TB_USER_ROLE (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  role_id    BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_role (user_id, role_id),
  KEY idx_user_role_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자-역할 매핑';

CREATE TABLE TB_ADMIN_PERMISSION (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  user_id    BIGINT      NOT NULL                 COMMENT '대상 staff',
  menu_key   VARCHAR(30) NOT NULL                 COMMENT 'dashboard/users/products/contents/sales/operation/marketing/site_design/stats/settlement/settings',
  allowed    TINYINT     NOT NULL DEFAULT 0       COMMENT '노출 허용(1)/차단(0)',
  data_scope VARCHAR(10) NOT NULL DEFAULT 'own'   COMMENT 'all(전사)/own(본인 담당)',
  status     INT         NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_perm_user_menu (user_id, menu_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='메뉴 화이트리스트+데이터스코프 RBAC(M-2)';

CREATE TABLE TB_USER_AGREEMENT (
  id            BIGINT      NOT NULL AUTO_INCREMENT,
  user_id       BIGINT      NOT NULL,
  agreement_key VARCHAR(30) NOT NULL              COMMENT 'age14/terms/privacy/marketing',
  required      TINYINT     NOT NULL DEFAULT 1    COMMENT '필수(1)/선택(0)',
  agreed        TINYINT     NOT NULL DEFAULT 0,
  terms_version VARCHAR(20)     NULL              COMMENT '동의 당시 약관 버전',
  agreed_at     DATETIME        NULL,
  status        INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_agreement (user_id, agreement_key),
  KEY idx_agreement_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='약관 동의 이력';

CREATE TABLE TB_AUTH_CODE (
  id          BIGINT      NOT NULL AUTO_INCREMENT,
  purpose     VARCHAR(20) NOT NULL               COMMENT 'signup/email_change/reset',
  target_type VARCHAR(10) NOT NULL DEFAULT 'email' COMMENT 'email/phone',
  target      VARCHAR(255) NOT NULL              COMMENT '이메일/휴대폰',
  code_hash   VARCHAR(255) NOT NULL              COMMENT '인증코드 해시(원문 미저장)',
  expires_at  DATETIME     NOT NULL              COMMENT 'C-2 TTL',
  verified_at DATETIME         NULL,
  send_count  INT          NOT NULL DEFAULT 0    COMMENT '연속 발송(10회 초과 제한)',
  verify_count INT         NOT NULL DEFAULT 0    COMMENT '검증 시도 횟수(무차별 방지)',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_authcode_target (target, purpose, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='인증코드(TTL)';

CREATE TABLE TB_PASSWORD_RESET_TOKEN (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  token_hash VARCHAR(255) NOT NULL               COMMENT '재설정 토큰 해시(원문 미저장)',
  expires_at DATETIME     NOT NULL               COMMENT '발급+30분',
  used_at    DATETIME         NULL,
  status     INT          NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_reset_token_hash (token_hash),
  KEY idx_reset_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='비밀번호 재설정 토큰(30분)';

CREATE TABLE TB_INVITE_TOKEN (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  email            VARCHAR(255) NOT NULL,
  role_id          BIGINT           NULL              COMMENT '초대 역할',
  token_hash       VARCHAR(255) NOT NULL              COMMENT '초대 토큰 해시(원문 미저장)',
  inviter_user_id  BIGINT       NOT NULL              COMMENT '초대자(TB_USER)',
  expires_at       DATETIME     NOT NULL              COMMENT '발급+48시간',
  accepted_at      DATETIME         NULL,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_invite_token_hash (token_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강사/관리자 초대 토큰(48h)';

CREATE TABLE TB_SESSION (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  user_id            BIGINT       NOT NULL,
  refresh_token_hash VARCHAR(255) NOT NULL              COMMENT '리프레시 토큰 해시',
  user_agent         VARCHAR(255)     NULL,
  ip                 VARCHAR(64)      NULL,
  remember           TINYINT      NOT NULL DEFAULT 0,
  expires_at         DATETIME     NOT NULL,
  revoked_at         DATETIME         NULL,
  status             INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_session_refresh (refresh_token_hash), -- 해시 길이 191 prefix 적용 권장(VARCHAR(255) 인덱스 한계)
  KEY idx_session_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='세션/리프레시 토큰';

CREATE TABLE TB_DEVICE_TOKEN (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  device_id  VARCHAR(128) NOT NULL,
  token      VARCHAR(512) NOT NULL                COMMENT 'FCM/APNs 토큰',
  platform   VARCHAR(10)  NOT NULL                COMMENT 'ios/android',
  status     INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_device (user_id, device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='푸시 디바이스 토큰';

CREATE TABLE TB_CATEGORY (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  parent_id  BIGINT          NULL                COMMENT '상위 카테고리(self). 최대 2단계',
  name       VARCHAR(50) NOT NULL,
  sort_order INT         NOT NULL DEFAULT 0,
  status     INT         NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_category_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 카테고리(2단계)';

CREATE TABLE TB_PRODUCT (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  owner_user_id     BIGINT        NOT NULL              COMMENT '담당 강사(TB_USER). 데이터스코프 기준',
  category_id       BIGINT            NULL              COMMENT '1상품 1카테고리(멤버십 제외)',
  type              VARCHAR(20)   NOT NULL              COMMENT 'general/live/video_call/digital/package/membership/community',
  title             VARCHAR(100)  NOT NULL,
  sub_title         VARCHAR(255)      NULL,
  description       TEXT              NULL,
  thumbnail_key     VARCHAR(255)      NULL              COMMENT 'R2 키(16:9)',
  price_type        VARCHAR(10)   NOT NULL DEFAULT 'paid' COMMENT 'free/paid',
  price             DECIMAL(18,6)     NULL              COMMENT '정가',
  discount_rate     INT               NULL              COMMENT '할인율(%) UI 표시 전용·결제 계산 미사용(C-4 정액 only)',
  visibility        VARCHAR(10)   NOT NULL DEFAULT 'private' COMMENT 'public/partial/private. 신규 기본 private',
  sale_status       VARCHAR(15)   NOT NULL DEFAULT 'on_sale' COMMENT 'on_sale/sale_closed/sale_stopped/sale_ended',
  allow_review      TINYINT       NOT NULL DEFAULT 1,
  allow_qna         TINYINT       NOT NULL DEFAULT 1,
  enroll_period_days INT              NULL              COMMENT '수강기간(일). NULL=무제한',
  avg_rating        DECIMAL(2,1)      NULL              COMMENT '평균 별점(파생)',
  status            INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_owner (owner_user_id),
  KEY idx_product_type (type),
  KEY idx_product_category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 공통(7종 통합)';

CREATE TABLE TB_PRODUCT_LIVE (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  product_id       BIGINT       NOT NULL,
  live_kind        VARCHAR(12)  NOT NULL              COMMENT 'youtube_live/video_call',
  platform         VARCHAR(12)      NULL              COMMENT 'zoom/google_meet(화상)',
  start_at         DATETIME     NOT NULL,
  end_at           DATETIME         NULL,
  stream_url       VARCHAR(500)     NULL,
  capacity         INT              NULL              COMMENT '모집인원(화상 필수)',
  enter_open_min   INT          NOT NULL DEFAULT 10   COMMENT '입장 활성(시작 N분 전) 10~60',
  live_status      VARCHAR(10)  NOT NULL DEFAULT 'upcoming' COMMENT 'upcoming/live/ended',
  instant_complete TINYINT      NOT NULL DEFAULT 1    COMMENT '입장 즉시 자동수료(라이브)',
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_live_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='라이브/화상강의 확장';

CREATE TABLE TB_PRODUCT_DIGITAL_FILE (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  product_id     BIGINT       NOT NULL,
  content_id     BIGINT           NULL              COMMENT '라이브러리 콘텐츠 연결',
  file_name      VARCHAR(255) NOT NULL,
  r2_key         VARCHAR(255)     NULL,
  download_limit INT          NOT NULL DEFAULT 0    COMMENT '파일별 최대 다운로드(0=무제한, 1~100)',
  status         INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_digital_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='디지털 상품 구성 파일';

CREATE TABLE TB_PACKAGE_ITEM (
  id                 BIGINT   NOT NULL AUTO_INCREMENT,
  package_product_id BIGINT   NOT NULL              COMMENT '패키지 상품',
  item_product_id    BIGINT   NOT NULL              COMMENT '구성 상품',
  sort_order         INT      NOT NULL DEFAULT 0,
  status             INT      NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_package_item (package_product_id, item_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='패키지 구성 상품(≤10)';

CREATE TABLE TB_MEMBERSHIP_TIER (
  id          BIGINT        NOT NULL AUTO_INCREMENT,
  product_id  BIGINT        NOT NULL,
  name        VARCHAR(50)   NOT NULL,
  monthly_fee DECIMAL(18,6) NOT NULL,
  sort_order  INT           NOT NULL DEFAULT 0,
  status      INT           NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tier_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='멤버십 등급';

CREATE TABLE TB_MEMBERSHIP_CATEGORY (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  tier_id     BIGINT   NOT NULL,
  category_id BIGINT   NOT NULL,
  status      INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_tier_category (tier_id, category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='멤버십 등급-이용 카테고리';

CREATE TABLE TB_PRODUCT_COMMUNITY (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  product_id   BIGINT        NOT NULL,
  monthly_fee  DECIMAL(18,6) NOT NULL              COMMENT '월 구독료(자동결제)',
  auto_payment TINYINT       NOT NULL DEFAULT 1,
  status       INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_community_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프리미엄 커뮤니티 확장';

CREATE TABLE TB_PRODUCT_BENEFIT (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  product_id   BIGINT       NOT NULL,
  benefit_text VARCHAR(255) NOT NULL,
  sort_order   INT          NOT NULL DEFAULT 0,
  status       INT          NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_benefit_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='멤버십/커뮤니티 혜택';

CREATE TABLE TB_SECTION (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  product_id BIGINT       NOT NULL,
  title      VARCHAR(255) NOT NULL,
  sort_order INT          NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_section_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강의 섹션';

CREATE TABLE TB_LECTURE (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  section_id BIGINT       NOT NULL,
  product_id BIGINT       NOT NULL                 COMMENT '비정규화(조인 단축)',
  content_id BIGINT           NULL                 COMMENT '연결 콘텐츠(차시당 1개)',
  title      VARCHAR(255) NOT NULL,
  seq        INT          NOT NULL DEFAULT 0       COMMENT '섹션 내 차시번호',
  is_preview TINYINT      NOT NULL DEFAULT 0       COMMENT '맛보기(무료공개)',
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_lecture_section (section_id),
  KEY idx_lecture_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='차시';

CREATE TABLE TB_COMPLETION_RULE (
  id                     BIGINT      NOT NULL AUTO_INCREMENT,
  product_id             BIGINT      NOT NULL,
  min_progress_rate      INT         NOT NULL DEFAULT 80  COMMENT '수료 최소 진도율 10~100',
  min_exam_score         INT             NULL             COMMENT '시험 점수 기준(시험 기능 P1(미구현) — 별도 TB_EXAM* 신설 시 활성)',
  certificate_template_id BIGINT         NULL             COMMENT '설정 시 자동발급',
  watch_mode             VARCHAR(12) NOT NULL DEFAULT 'free' COMMENT 'free/sequential',
  status                 INT         NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at             DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_completion_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수료 기준';

CREATE TABLE TB_CONTENT_FOLDER (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  parent_id  BIGINT           NULL                 COMMENT '상위 폴더(self). 최대 2단계',
  name       VARCHAR(100) NOT NULL,
  sort_order INT          NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='콘텐츠 폴더';

CREATE TABLE TB_CONTENT (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  folder_id        BIGINT           NULL,
  name             VARCHAR(255) NOT NULL,
  media_type       VARCHAR(10)  NOT NULL DEFAULT 'video' COMMENT 'video/doc/image/etc',
  source_type      VARCHAR(10)  NOT NULL DEFAULT 'upload' COMMENT 'upload/youtube',
  r2_key           VARCHAR(255)     NULL,
  youtube_url      VARCHAR(500)     NULL,
  upload_status    VARCHAR(12)  NOT NULL DEFAULT 'pending' COMMENT 'pending/processing/done/failed',
  duration_sec     INT              NULL,
  size_bytes       BIGINT           NULL              COMMENT '용량(한도 집계)',
  thumbnail_key    VARCHAR(255)     NULL,
  has_ai_tutor     TINYINT      NOT NULL DEFAULT 0,
  has_ai_translate TINYINT      NOT NULL DEFAULT 0,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_content_folder (folder_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='콘텐츠(미디어 자산)';

CREATE TABLE TB_SUBTITLE (
  id              BIGINT      NOT NULL AUTO_INCREMENT,
  content_id      BIGINT      NOT NULL,
  lang            VARCHAR(5)  NOT NULL              COMMENT 'ko/en/ja/zh/...(AI 75개국)',
  is_ai_generated TINYINT     NOT NULL DEFAULT 0,
  is_default      TINYINT     NOT NULL DEFAULT 0,
  vtt_key         VARCHAR(255)    NULL,
  status          INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_subtitle_lang (content_id, lang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='자막 트랙(다국어)';

CREATE TABLE TB_SUBTITLE_LINE (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  subtitle_id BIGINT   NOT NULL,
  seq         INT      NOT NULL,
  start_ms    INT      NOT NULL,
  end_ms      INT      NOT NULL,
  text        TEXT     NOT NULL,
  status      INT      NOT NULL DEFAULT 1           COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_subline_subtitle (subtitle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='자막 라인';

CREATE TABLE TB_ENROLLMENT (
  id            BIGINT      NOT NULL AUTO_INCREMENT,
  user_id       BIGINT      NOT NULL,
  product_id    BIGINT      NOT NULL,
  grant_source  VARCHAR(12) NOT NULL DEFAULT 'purchase' COMMENT 'purchase/subscription/package/membership',
  order_id      BIGINT          NULL,
  learn_status  VARCHAR(12) NOT NULL DEFAULT 'before' COMMENT 'before/learning/completed',
  progress_rate INT         NOT NULL DEFAULT 0    COMMENT '전체 진도율(%)',
  started_at    DATETIME        NULL,
  expire_at     DATETIME        NULL              COMMENT '만료일. NULL=무제한',
  completed_at  DATETIME        NULL,
  status        INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '구매/등록일',
  updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_enroll_user_product (user_id, product_id),
  KEY idx_enroll_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수강권';

CREATE TABLE TB_LECTURE_PROGRESS (
  id                BIGINT   NOT NULL AUTO_INCREMENT,
  enrollment_id     BIGINT   NOT NULL,
  lecture_id        BIGINT   NOT NULL,
  user_id           BIGINT   NOT NULL              COMMENT '비정규화',
  completed         TINYINT  NOT NULL DEFAULT 0,
  watched_sec       INT      NOT NULL DEFAULT 0,
  last_position_sec INT      NOT NULL DEFAULT 0    COMMENT '이어보기 위치',
  status            INT      NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_progress_enroll_lecture (enrollment_id, lecture_id),
  KEY idx_progress_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='차시별 진도';

CREATE TABLE TB_CERTIFICATE_TEMPLATE (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  name          VARCHAR(50)  NOT NULL,
  design_theme  VARCHAR(50)      NULL,
  cert_title    VARCHAR(100) NOT NULL DEFAULT '수료증',
  issuer_name   VARCHAR(100) NOT NULL,
  signer_name   VARCHAR(100)     NULL,
  signature_key VARCHAR(255)     NULL,
  logo_key      VARCHAR(255)     NULL,
  display_items JSON             NULL              COMMENT '표시항목 토글',
  is_active     TINYINT      NOT NULL DEFAULT 1,
  status        INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수료증 템플릿';

CREATE TABLE TB_CERTIFICATE (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  enrollment_id BIGINT        NOT NULL,
  user_id       BIGINT        NOT NULL,
  product_id    BIGINT        NOT NULL,
  template_id   BIGINT        NOT NULL              COMMENT '발급 시점 템플릿',
  cert_no       VARCHAR(50)   NOT NULL              COMMENT '수료번호',
  learner_name  VARCHAR(100)  NOT NULL              COMMENT '수료자명 스냅샷',
  product_title VARCHAR(255)  NOT NULL              COMMENT '상품명 스냅샷',
  study_hours   DECIMAL(6,2)      NULL,
  started_at    DATETIME          NULL,
  completed_at  DATETIME      NOT NULL,
  revoked       TINYINT       NOT NULL DEFAULT 0    COMMENT '무효(환불/취소 시)',
  issued_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status        INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cert_no (cert_no),
  KEY idx_cert_user (user_id),
  KEY idx_cert_enroll (enrollment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수료증 발급 이력';

CREATE TABLE TB_WISHLIST (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  product_id BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1           COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_wishlist (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='위시리스트(찜)';

CREATE TABLE TB_REVIEW (
  id            BIGINT   NOT NULL AUTO_INCREMENT,
  user_id       BIGINT   NOT NULL                   COMMENT '작성 수강생(TB_USER)',
  product_id    BIGINT   NOT NULL                   COMMENT '대상 상품(TB_PRODUCT)',
  enrollment_id BIGINT       NULL                   COMMENT '수강권(TB_ENROLLMENT). NULL=구매 없이 작성 불가 정책 적용 시 NOT NULL로 변경',
  rating        INT      NOT NULL                   COMMENT '별점 1~5',
  content       TEXT         NULL                   COMMENT '후기 본문',
  status        INT      NOT NULL DEFAULT 1         COMMENT '1공개 0숨김(운영자) -1삭제',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_review_user_product (user_id, product_id),
  KEY idx_review_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 후기(별점+본문)';

CREATE TABLE TB_AI_JOB (
  id               BIGINT      NOT NULL AUTO_INCREMENT,
  content_id       BIGINT      NOT NULL,
  kind             VARCHAR(12) NOT NULL              COMMENT 'ai_tutor/ai_caption/ai_translate',
  target_lang      VARCHAR(5)      NULL,
  job_status       VARCHAR(12) NOT NULL DEFAULT 'pending' COMMENT 'pending/processing/done/failed',
  credit_ledger_id BIGINT          NULL              COMMENT '크레딧 차감 원장 연결',
  status           INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_aijob_content (content_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 부가기능 생성 작업';

CREATE TABLE TB_COURSE_RESOURCE (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  product_id BIGINT       NOT NULL,
  file_name  VARCHAR(255) NOT NULL,
  r2_key     VARCHAR(255) NOT NULL,
  sort_order INT          NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_resource_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강의 자료실 첨부';

CREATE TABLE TB_PLAYER_SETTING (
  id                BIGINT   NOT NULL AUTO_INCREMENT,
  auto_next         TINYINT  NOT NULL DEFAULT 1,
  remember_position TINYINT  NOT NULL DEFAULT 1,
  allow_speed       TINYINT  NOT NULL DEFAULT 1,
  show_subtitle     TINYINT  NOT NULL DEFAULT 1,
  progress_save     TINYINT  NOT NULL DEFAULT 1,
  restrict_skip     TINYINT  NOT NULL DEFAULT 0    COMMENT '구간 탐색 제한',
  force_watch_order TINYINT  NOT NULL DEFAULT 0    COMMENT '순차 시청 강제',
  status            INT      NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플레이어 전역 설정';

CREATE TABLE TB_SUBSCRIPTION (
  id                   BIGINT        NOT NULL AUTO_INCREMENT,
  user_id              BIGINT            NULL              COMMENT '구독 주체(학습자 멤버십/커뮤니티). 판매자 플랜은 사이트 소유자',
  subject_type         INT           NOT NULL DEFAULT 1    COMMENT '2=MEMBERSHIP/3=COMMUNITY (테넌트는 SELLER_PLAN 미사용 — 마스터 전담)',
  plan_id              BIGINT            NULL,
  product_id           BIGINT            NULL,
  billing_cycle        INT           NOT NULL DEFAULT 1    COMMENT '1=monthly/2=yearly',
  unit_price           DECIMAL(18,6) NOT NULL              COMMENT '구독료 스냅샷',
  billing_key_id       BIGINT            NULL,
  current_period_start DATETIME      NOT NULL,
  current_period_end   DATETIME      NOT NULL,
  next_billing_at      DATETIME          NULL,
  cancel_scheduled     TINYINT       NOT NULL DEFAULT 0    COMMENT '기간종료후 해지 예약',
  canceled_at          DATETIME          NULL,
  started_at           DATETIME          NULL              COMMENT '최초 구독 시작일',
  grace_until          DATETIME          NULL              COMMENT '유예 종료일',
  status               INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제 (구독상태는 sub_state)',
  sub_state            VARCHAR(12)   NOT NULL DEFAULT 'active' COMMENT 'active/grace/expired/canceled',
  created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sub_user (user_id),
  KEY idx_sub_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='구독(판매자 플랜/멤버십/커뮤니티)';

CREATE TABLE TB_ORDER (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  order_no        VARCHAR(30)   NOT NULL              COMMENT 'ORD-YYYYMMDD-NNNN',
  user_id         BIGINT        NOT NULL              COMMENT '주문자',
  ref_type        VARCHAR(20)   NOT NULL DEFAULT 'product' COMMENT 'product/credit_charge',
  subtotal        DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '정가 합계',
  shop_discount   DECIMAL(18,6) NOT NULL DEFAULT 0,
  coupon_id       BIGINT            NULL,
  coupon_discount DECIMAL(18,6) NOT NULL DEFAULT 0,
  vat             DECIMAL(18,6) NOT NULL DEFAULT 0,
  total           DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '총 결제금액',
  is_subscription TINYINT       NOT NULL DEFAULT 0,
  paid_at         DATETIME          NULL,
  order_state     VARCHAR(15)   NOT NULL DEFAULT 'pending' COMMENT 'pending/paying/paid/failed/grace/unpaid/canceled/refunded/partial_refund',
  status          INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_order_no (order_no),
  KEY idx_order_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 헤더';

CREATE TABLE TB_ORDER_ITEM (
  id                  BIGINT        NOT NULL AUTO_INCREMENT,
  order_id            BIGINT        NOT NULL,
  product_id          BIGINT        NOT NULL,
  product_type        INT           NOT NULL DEFAULT 1 COMMENT '1일반/2라이브/3화상/4패키지/5디지털/6멤버십/7커뮤니티',
  product_name        VARCHAR(255)  NOT NULL          COMMENT '상품명 스냅샷',
  instructor_user_id  BIGINT            NULL          COMMENT '담당 강사(정산 스코프)(=06 §1.9 instructor_admin_id)',
  list_price          DECIMAL(18,6) NOT NULL DEFAULT 0 COMMENT '정가 스냅샷',
  item_discount       DECIMAL(18,6) NOT NULL DEFAULT 0,
  amount              DECIMAL(18,6) NOT NULL DEFAULT 0 COMMENT '항목 결제금액',
  status              INT           NOT NULL DEFAULT 1 COMMENT '1정상 0중지 -1삭제',
  created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_orderitem_order (order_id),
  KEY idx_orderitem_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 항목';

CREATE TABLE TB_INVOICE (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  subscription_id   BIGINT        NOT NULL,
  period_start      DATETIME      NOT NULL,
  period_end        DATETIME      NOT NULL,
  amount            DECIMAL(18,6) NOT NULL,
  vat               DECIMAL(18,6) NOT NULL DEFAULT 0,
  unpaid_carryover  DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '미납 이월액',
  billing_due_at    DATETIME      NOT NULL,
  retry_count       INT           NOT NULL DEFAULT 0    COMMENT '재시도 회차(최대 6)',
  paid_payment_id   BIGINT            NULL,
  issued_at         DATETIME          NULL              COMMENT '청구 발행 시각',
  paid_at           DATETIME          NULL              COMMENT '납부 완료 시각',
  invoice_state     VARCHAR(10)   NOT NULL DEFAULT 'open' COMMENT 'open/paying/paid/failed/grace/void',
  status            INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_invoice_sub (subscription_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='정기결제 청구서';

CREATE TABLE TB_PAYMENT (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  order_id         BIGINT            NULL,
  invoice_id       BIGINT            NULL,
  toss_payment_key VARCHAR(255)      NULL,
  toss_order_id    VARCHAR(64)       NULL              COMMENT '토스 orderId(=order_no 매핑)',
  approve_no       VARCHAR(64)       NULL,
  acquirer         VARCHAR(50)       NULL,
  card_company     VARCHAR(50)       NULL,
  card_last4       VARCHAR(4)        NULL              COMMENT '카드 뒤 4자리만(마스킹)',
  install_months   INT           NOT NULL DEFAULT 0,
  amount           DECIMAL(18,6) NOT NULL,
  method           INT           NOT NULL DEFAULT 1   COMMENT '1=card(계좌이체 미지원)',
  retry_count      INT           NOT NULL DEFAULT 0,
  fail_code        VARCHAR(50)       NULL,
  fail_message     VARCHAR(255)      NULL,
  approved_at      DATETIME          NULL,
  pay_state        VARCHAR(15)   NOT NULL DEFAULT 'ready' COMMENT 'ready/approved/failed/canceled/partial_canceled',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_toss_payment_key (toss_payment_key),
  KEY idx_payment_order (order_id),
  KEY idx_payment_invoice (invoice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PG(토스) 결제';

CREATE TABLE TB_ORDER_LOG (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  order_id      BIGINT       NOT NULL,
  log_type      VARCHAR(50)  NOT NULL,
  description   VARCHAR(255)     NULL,
  actor_type    INT          NOT NULL DEFAULT 1     COMMENT '1=system/2=admin',
  actor_user_id BIGINT           NULL,
  status        INT          NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_orderlog_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문/결제 상태 이력';

CREATE TABLE TB_BILLING_KEY (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  user_id          BIGINT       NOT NULL,
  toss_billing_key VARCHAR(255) NOT NULL              COMMENT '토스 빌링키(AES-256-GCM 암호화 저장·키는 KMS/wrangler secret·응답 미포함)',
  card_company     VARCHAR(50)      NULL,
  card_type        VARCHAR(20)      NULL              COMMENT '신용/체크',
  card_last4       VARCHAR(4)   NOT NULL              COMMENT '뒤 4자리(표시)',
  is_default       TINYINT      NOT NULL DEFAULT 0    COMMENT '대표카드',
  registered_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_billing_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='빌링키(등록 결제수단)';

CREATE TABLE TB_REFUND (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  order_id         BIGINT        NOT NULL,
  payment_id       BIGINT            NULL,
  refund_type      INT           NOT NULL DEFAULT 1   COMMENT '1=full/2=partial',
  requested_amount DECIMAL(18,6)     NULL,
  refund_amount    DECIMAL(18,6) NOT NULL,
  reason           VARCHAR(255)      NULL,
  transfer_note    VARCHAR(255)      NULL              COMMENT '이체내역(저장 전 계좌/예금주 마스킹)',
  channel          INT           NOT NULL DEFAULT 1   COMMENT '1=self/2=inquiry',
  inquiry_id       BIGINT            NULL,
  revoke_course    TINYINT       NOT NULL DEFAULT 0   COMMENT '수강권 회수',
  void_certificate TINYINT       NOT NULL DEFAULT 0   COMMENT '수료증 무효',
  requested_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  refunded_at      DATETIME          NULL,
  handler_user_id  BIGINT            NULL,
  refund_state     VARCHAR(12)   NOT NULL DEFAULT 'requested' COMMENT 'requested/completed/rejected',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_refund_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='환불(비가역 게이트)';

CREATE TABLE TB_REFUND_LOG (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  refund_id       BIGINT        NOT NULL,
  processed_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  handler_user_id BIGINT            NULL,
  refund_amount   DECIMAL(18,6)     NULL,
  transfer_note   VARCHAR(255)      NULL              COMMENT '이체내역(저장 전 계좌/예금주 마스킹)',
  content         VARCHAR(255)      NULL,
  status          INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_refundlog_refund (refund_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='환불 처리 로그';

CREATE TABLE TB_COUPON (
  id                 BIGINT        NOT NULL AUTO_INCREMENT,
  name               VARCHAR(100)  NOT NULL,
  description        VARCHAR(255)      NULL,
  discount_type      INT           NOT NULL DEFAULT 1   COMMENT '1=AMOUNT only(C-4). 정률 미사용',
  discount_amount    DECIMAL(18,6) NOT NULL              COMMENT '정액 할인액',
  min_order_amount   DECIMAL(18,6)     NULL,
  scope_type         INT           NOT NULL DEFAULT 1   COMMENT '1=ALL/2=SPECIFIC',
  target_type        INT           NOT NULL DEFAULT 1   COMMENT '1=ALL_MEMBER/2=GROUP',
  recipient_group_id BIGINT            NULL,
  issue_quantity     INT               NULL              COMMENT 'NULL=제한없음',
  use_period_start   DATETIME          NULL,
  use_period_end     DATETIME          NULL,
  valid_days         INT               NULL              COMMENT '발급 후 유효일수',
  coupon_state       VARCHAR(12)   NOT NULL DEFAULT 'active' COMMENT 'active/suspended/revoked',
  status             INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰(정액 only)';

CREATE TABLE TB_COUPON_PRODUCT (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  coupon_id  BIGINT   NOT NULL,
  product_id BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1           COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_coupon_product (coupon_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰-상품 매핑';

CREATE TABLE TB_COUPON_ISSUE (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  coupon_id        BIGINT        NOT NULL,
  user_id          BIGINT        NOT NULL,
  coupon_code      VARCHAR(50)       NULL,
  order_id         BIGINT            NULL,
  discount_applied DECIMAL(18,6)     NULL,
  issued_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at       DATETIME          NULL,
  used_at          DATETIME          NULL,
  issue_state      VARCHAR(12)   NOT NULL DEFAULT 'issued' COMMENT 'issued/used/revoked',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_coupon_issue (coupon_id, user_id),
  KEY idx_couponissue_coupon (coupon_id),
  KEY idx_couponissue_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰 발급/사용 이력';

CREATE TABLE TB_SETTLEMENT_PROFILE (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  instructor_user_id BIGINT       NOT NULL             COMMENT '소유 강사(TB_USER)',
  profile_type       INT          NOT NULL             COMMENT '1개인사업자/2법인사업자/3개인',
  biz_no             VARCHAR(20)      NULL,
  company_name       VARCHAR(100)     NULL,
  ceo_name           VARCHAR(50)      NULL,
  biz_address        VARCHAR(255)     NULL,
  biz_category       VARCHAR(50)      NULL,
  biz_item           VARCHAR(50)      NULL,
  biz_license_key    VARCHAR(255)     NULL              COMMENT '사업자등록증 R2 키',
  birth_date         DATE             NULL,
  telecom            VARCHAR(20)      NULL,
  identity_verified  TINYINT      NOT NULL DEFAULT 0,
  manager_name       VARCHAR(50)  NOT NULL,
  manager_phone      VARCHAR(20)  NOT NULL,
  manager_email      VARCHAR(255) NOT NULL,
  email_verified     TINYINT      NOT NULL DEFAULT 0,
  bank_name          VARCHAR(50)  NOT NULL,
  account_no         VARCHAR(50)  NOT NULL             COMMENT '계좌번호(저장 암호화·조회 시 부분마스킹)',
  account_holder     VARCHAR(50)  NOT NULL,
  account_verified   TINYINT      NOT NULL DEFAULT 0,
  bankbook_key       VARCHAR(255)     NULL             COMMENT '통장 사본 R2 키',
  approve_state      INT          NOT NULL DEFAULT 0   COMMENT '0=none/1=pending/2=approved/3=rejected',
  approved_at        DATETIME         NULL,
  status             INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_settleprofile_instructor (instructor_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='정산 정보(승인 게이트)';

CREATE TABLE TB_SETTLEMENT (
  id                 BIGINT        NOT NULL AUTO_INCREMENT,
  instructor_user_id BIGINT            NULL              COMMENT '강사 스코프(NULL=전사)(=06 §1.9 instructor_admin_id)',
  period_month       VARCHAR(7)    NOT NULL              COMMENT 'YYYY-MM',
  period_start       DATETIME          NULL,
  period_end         DATETIME          NULL,
  pay_date           DATETIME      NOT NULL              COMMENT '지급 예정(익월 10일)',
  settle_count       INT               NULL,
  payment_count      INT               NULL,
  cancel_count       INT               NULL,
  gross_amount       DECIMAL(18,6) NOT NULL DEFAULT 0,
  supply_amount      DECIMAL(18,6) NOT NULL DEFAULT 0,
  vat                DECIMAL(18,6) NOT NULL DEFAULT 0,
  sales_fee          DECIMAL(18,6) NOT NULL DEFAULT 0,
  sales_fee_rate     DECIMAL(18,6)     NULL,
  pg_fee             DECIMAL(18,6) NOT NULL DEFAULT 0,
  canceled_amount    DECIMAL(18,6) NOT NULL DEFAULT 0,
  net_amount         DECIMAL(18,6) NOT NULL DEFAULT 0,
  bank_snapshot      VARCHAR(255)      NULL,
  settle_state       VARCHAR(12)   NOT NULL DEFAULT 'pending' COMMENT 'pending/approved/paid',
  approved_at        DATETIME          NULL,
  status             INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_settle_instructor_month (instructor_user_id, period_month),
  KEY idx_settle_month (period_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='월별 정산 내역';

CREATE TABLE TB_SETTLEMENT_ITEM (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  settlement_id BIGINT        NOT NULL,
  product_id    BIGINT            NULL,
  product_name  VARCHAR(255)  NOT NULL,
  product_type  INT               NULL,
  sold_count    INT               NULL,
  gross_amount  DECIMAL(18,6) NOT NULL DEFAULT 0,
  sales_fee     DECIMAL(18,6)     NULL,
  pg_fee        DECIMAL(18,6)     NULL,
  net_amount    DECIMAL(18,6) NOT NULL DEFAULT 0,
  status        INT           NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_settleitem_settle (settlement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='정산 상품별 매출';

CREATE TABLE TB_TAX_REPORT (
  id             BIGINT        NOT NULL AUTO_INCREMENT,
  period_month   VARCHAR(7)    NOT NULL              COMMENT 'YYYY-MM',
  approve_count  INT               NULL,
  cancel_count   INT               NULL,
  net_count      INT               NULL,
  paid_total     DECIMAL(18,6) NOT NULL DEFAULT 0,
  canceled_total DECIMAL(18,6) NOT NULL DEFAULT 0,
  net_total      DECIMAL(18,6) NOT NULL DEFAULT 0,
  status         INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_taxreport_site (period_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='부가세 신고 자료(참고)';

CREATE TABLE TB_TAX_REPORT_ITEM (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  tax_report_id BIGINT        NOT NULL,
  order_id      BIGINT            NULL,
  trade_type    INT           NOT NULL DEFAULT 1     COMMENT '1=approve/2=cancel',
  amount        DECIMAL(18,6) NOT NULL DEFAULT 0,
  traded_at     DATETIME          NULL,
  status        INT           NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_taxitem_report (tax_report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='부가세 신고 거래 내역';

CREATE TABLE TB_TOSS_WEBHOOK_EVENT (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  event_id           VARCHAR(128) NOT NULL              COMMENT '토스 이벤트 ID(멱등키)',
  event_type         VARCHAR(60)  NOT NULL,
  toss_payment_key   VARCHAR(255)     NULL,
  toss_order_id      VARCHAR(64)      NULL,
  payment_id         BIGINT           NULL,
  signature_verified TINYINT      NOT NULL DEFAULT 0,
  raw_payload        TEXT             NULL,
  received_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  event_state        VARCHAR(12)  NOT NULL DEFAULT 'received' COMMENT 'received/processed/duplicate/failed',
  status             INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_webhook_event (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='LMS 상품결제 웹훅 수신 로그(멱등) — SaaS/크레딧 웹훅은 master.TB_TOSS_WEBHOOK_EVENT';

CREATE TABLE TB_RECIPIENT_GROUP (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  name            VARCHAR(200) NOT NULL,
  update_mode     VARCHAR(20)  NOT NULL DEFAULT 'manual' COMMENT 'auto(조건 동적)/manual(명단)',
  condition_logic JSON             NULL              COMMENT '조건 트리(auto)',
  member_count    INT              NULL              COMMENT '추출/등록 인원(캐시)',
  status          INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수신자 그룹';

CREATE TABLE TB_RECIPIENT_GROUP_MEMBER (
  id                 BIGINT      NOT NULL AUTO_INCREMENT,
  recipient_group_id BIGINT      NOT NULL,
  user_id            BIGINT      NOT NULL,
  added_by           VARCHAR(20) NOT NULL DEFAULT 'manual' COMMENT 'manual/condition',
  status             INT         NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_recgroup_member (recipient_group_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='그룹-회원 매핑';

CREATE TABLE TB_MESSAGE_TEMPLATE (
  id                     BIGINT       NOT NULL AUTO_INCREMENT,
  name                   VARCHAR(200) NOT NULL,
  channel                VARCHAR(20)  NOT NULL          COMMENT 'email/sms/alimtalk',
  subject                VARCHAR(300)     NULL,
  content                TEXT         NOT NULL,
  include_unsubscribe    TINYINT      NOT NULL DEFAULT 1,
  alimtalk_template_code VARCHAR(100)     NULL          COMMENT '카카오 승인 템플릿코드',
  status                 INT          NOT NULL DEFAULT 1 COMMENT '1정상 0중지 -1삭제',
  created_at             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='메시지 템플릿';

CREATE TABLE TB_CAMPAIGN (
  id                  BIGINT        NOT NULL AUTO_INCREMENT,
  name                VARCHAR(200)  NOT NULL,
  channel             VARCHAR(20)   NOT NULL             COMMENT 'email/sms/mms/alimtalk',
  recipient_group_id  BIGINT        NOT NULL,
  message_template_id BIGINT            NULL,
  subject             VARCHAR(300)      NULL,
  content             TEXT          NOT NULL,
  schedule_type       VARCHAR(20)   NOT NULL DEFAULT 'now' COMMENT 'now/scheduled/condition',
  scheduled_at        DATETIME          NULL              COMMENT '예약(>= now+10분)',
  send_condition      JSON              NULL,
  est_credit_cost     DECIMAL(18,6)     NULL              COMMENT '예상 크레딧 소모',
  recipient_count     INT               NULL,
  success_count       INT               NULL,
  fail_count          INT               NULL,
  open_count          INT               NULL,
  send_state          VARCHAR(20)   NOT NULL DEFAULT 'reserved' COMMENT 'reserved/sending/sent/stopped/failed',
  status              INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_campaign_group (recipient_group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='발송 캠페인';

CREATE TABLE TB_CAMPAIGN_RECIPIENT (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  campaign_id    BIGINT       NOT NULL,
  user_id        BIGINT           NULL,
  contact        VARCHAR(120)     NULL,
  recipient_name VARCHAR(100)     NULL,
  send_result    VARCHAR(20)  NOT NULL DEFAULT 'success' COMMENT 'success/fail',
  opened         TINYINT      NOT NULL DEFAULT 0,
  opened_at      DATETIME         NULL,
  excluded       TINYINT      NOT NULL DEFAULT 0,
  resent_count   INT          NOT NULL DEFAULT 0,
  status         INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_camprecipient_campaign (campaign_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='캠페인 수신자별 결과';

CREATE TABLE TB_SURVEY (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  name            VARCHAR(200) NOT NULL,
  respondent_type VARCHAR(20)  NOT NULL DEFAULT 'all' COMMENT 'all/learner/completer/subscriber',
  is_public       TINYINT      NOT NULL DEFAULT 0,
  published       TINYINT      NOT NULL DEFAULT 0,
  response_count  INT              NULL,
  status          INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='설문폼';

CREATE TABLE TB_SURVEY_QUESTION (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  survey_id  BIGINT       NOT NULL,
  seq        INT          NOT NULL,
  text       VARCHAR(500) NOT NULL,
  qtype      VARCHAR(20)  NOT NULL DEFAULT 'text' COMMENT 'text/long/radio/check/rating',
  options    JSON             NULL,
  required   TINYINT      NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_question_survey (survey_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='설문 문항';

CREATE TABLE TB_SURVEY_RESPONSE (
  id           BIGINT   NOT NULL AUTO_INCREMENT,
  survey_id    BIGINT   NOT NULL,
  user_id      BIGINT       NULL,
  submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status       INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_response_survey (survey_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='설문 응답';

CREATE TABLE TB_SURVEY_ANSWER (
  id                 BIGINT   NOT NULL AUTO_INCREMENT,
  survey_response_id BIGINT   NOT NULL,
  survey_question_id BIGINT   NOT NULL,
  answer_text        TEXT         NULL,
  answer_option      JSON         NULL,
  status             INT      NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_answer_response (survey_response_id),
  KEY idx_answer_question (survey_question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='문항별 답변';

CREATE TABLE TB_LANDING_PAGE (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  name             VARCHAR(200) NOT NULL,
  page_type        VARCHAR(20)  NOT NULL DEFAULT 'basic' COMMENT 'basic/extended',
  headline         VARCHAR(300) NOT NULL,
  sub_title        VARCHAR(300)     NULL,
  body             TEXT             NULL,
  visual_image_key VARCHAR(500)     NULL,
  cta_text         VARCHAR(100)     NULL,
  is_visible       TINYINT      NOT NULL DEFAULT 0,
  signup_count     INT              NULL,
  status           INT          NOT NULL DEFAULT 1  COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='랜딩페이지';

CREATE TABLE TB_LANDING_PRODUCT (
  id              BIGINT   NOT NULL AUTO_INCREMENT,
  landing_page_id BIGINT   NOT NULL,
  product_id      BIGINT   NOT NULL,
  seq             INT      NOT NULL DEFAULT 0       COMMENT '진열 순서(0~3)',
  status          INT      NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_landingprod_page (landing_page_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='랜딩 진열 상품(≤4)';

CREATE TABLE TB_MARKETING_TOOL (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  tool_type    VARCHAR(30)  NOT NULL              COMMENT 'kakao_channel/google_analytics/google_tag_manager/meta_pixel',
  connected    TINYINT      NOT NULL DEFAULT 0,
  config_value VARCHAR(300)     NULL,
  status       INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_mktool_site_type (tool_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='외부 마케팅 툴 연동';

CREATE TABLE TB_NOTIFICATION_ROUTE (
  id                  BIGINT      NOT NULL AUTO_INCREMENT,
  code                VARCHAR(20) NOT NULL             COMMENT 'N-01~N-10/N-F1/N-F2/MKT-CAMPAIGN',
  event               VARCHAR(60) NOT NULL             COMMENT '트리거 이벤트',
  audience            VARCHAR(20) NOT NULL             COMMENT 'operator/instructor/learner',
  data_scope          VARCHAR(10) NOT NULL DEFAULT 'all' COMMENT 'all/own(M-2)',
  channel             VARCHAR(20) NOT NULL             COMMENT 'inapp/email/push/sms/alimtalk',
  category            VARCHAR(20) NOT NULL DEFAULT 'transactional' COMMENT 'transactional(필수)/marketing(선택)',
  is_required         TINYINT     NOT NULL DEFAULT 0   COMMENT '필수 트랜잭션(OFF 불가)',
  message_template_id BIGINT          NULL,
  night_block         TINYINT     NOT NULL DEFAULT 0   COMMENT '야간발송 차단(21~08)',
  status              INT         NOT NULL DEFAULT 1   COMMENT '1활성 0비활성 -1삭제',
  created_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_notiroute_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='알림 라우팅 카탈로그(R-1 단일화)';

CREATE TABLE TB_NOTIFICATION (
  id                BIGINT       NOT NULL AUTO_INCREMENT,
  route_code        VARCHAR(20)  NOT NULL             COMMENT '생성 라우팅 코드',
  recipient_user_id BIGINT       NOT NULL,
  channel           VARCHAR(20)  NOT NULL,
  title             VARCHAR(300) NOT NULL,
  body              TEXT             NULL,
  ref_type          VARCHAR(20)      NULL             COMMENT 'inquiry/order/refund/content/campaign/settlement',
  ref_id            BIGINT           NULL,
  filter_type       VARCHAR(20)      NULL             COMMENT 'inquiry/payment/system',
  is_read           TINYINT      NOT NULL DEFAULT 0,
  read_at           DATETIME         NULL,
  send_result       VARCHAR(20)      NULL,
  status            INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_noti_recipient (recipient_user_id, is_read),
  KEY idx_noti_ref (ref_type, ref_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='발송 알림 로그+인앱 수신함';

CREATE TABLE TB_NOTIFICATION_SETTING (
  id          BIGINT      NOT NULL AUTO_INCREMENT,
  user_id     BIGINT      NOT NULL,
  category    VARCHAR(40) NOT NULL,
  channel     VARCHAR(20) NOT NULL              COMMENT 'email/push/sms/alimtalk/inapp',
  is_required TINYINT     NOT NULL DEFAULT 0    COMMENT 'true면 항상 enabled',
  enabled     TINYINT     NOT NULL DEFAULT 1,
  status      INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_notiset_user (user_id, category, channel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 알림 수신설정';

CREATE TABLE TB_STAT_DAILY (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  stat_date    DATE          NOT NULL,
  metric_key   VARCHAR(40)   NOT NULL              COMMENT 'sales/orders/signups/completions ...',
  metric_value DECIMAL(18,6) NOT NULL DEFAULT 0,
  status       INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_stat_daily (stat_date, metric_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='일/월 통계 사전집계(선택)';

CREATE TABLE TB_BOARD (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  type               INT          NOT NULL             COMMENT '1notice/2faq/3free/4premium (변경불가)',
  product_id         BIGINT           NULL             COMMENT 'premium 유형일 때 상품 참조',
  name               VARCHAR(100) NOT NULL,
  write_permission   INT          NOT NULL DEFAULT 1   COMMENT '1all/2member/3admin',
  comment_permission INT          NOT NULL DEFAULT 1   COMMENT '1all/2member/3admin/0none',
  allow_secret       TINYINT      NOT NULL DEFAULT 0,
  menu_linked        TINYINT      NOT NULL DEFAULT 0,
  sort_order         INT          NOT NULL DEFAULT 0,
  status             INT          NOT NULL DEFAULT 1   COMMENT '1공개 0비공개 -1삭제',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_board_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='게시판 정의';

CREATE TABLE TB_POST (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  board_id      BIGINT       NOT NULL,
  user_id       BIGINT       NOT NULL              COMMENT '작성자',
  author_role   INT              NULL              COMMENT '1admin/2instructor/3member(캐시)',
  sub_type      INT              NULL              COMMENT 'premium 분류 1일반/2질문/3공지',
  title         VARCHAR(100) NOT NULL,
  content       TEXT         NOT NULL,
  is_secret     TINYINT      NOT NULL DEFAULT 0,
  is_pinned     TINYINT      NOT NULL DEFAULT 0,
  view_count    INT          NOT NULL DEFAULT 0,
  like_count    INT          NOT NULL DEFAULT 0,
  comment_count INT          NOT NULL DEFAULT 0,
  status        INT          NOT NULL DEFAULT 1    COMMENT '1공개 0비공개 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_post_board (board_id),
  KEY idx_post_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='게시글';

CREATE TABLE TB_COMMENT (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  post_id     BIGINT   NOT NULL,
  parent_id   BIGINT       NULL                   COMMENT '상위 댓글(self). NULL=댓글, 값=답글',
  user_id     BIGINT   NOT NULL,
  author_role INT          NULL                   COMMENT '1admin/2instructor/3member',
  content     TEXT     NOT NULL,
  is_secret   TINYINT  NOT NULL DEFAULT 0,
  is_deleted  TINYINT  NOT NULL DEFAULT 0         COMMENT '삭제유지(스레드 보존)',
  status      INT      NOT NULL DEFAULT 1         COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_comment_post (post_id),
  KEY idx_comment_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='댓글/답글';

CREATE TABLE TB_POST_LIKE (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  post_id    BIGINT   NOT NULL,
  user_id    BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_postlike (post_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='게시글 좋아요';

CREATE TABLE TB_FAQ_CATEGORY (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  name       VARCHAR(50) NOT NULL,
  sort_order INT         NOT NULL DEFAULT 0,
  status     INT         NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='FAQ 카테고리';

CREATE TABLE TB_FAQ (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  faq_category_id BIGINT           NULL,
  question        VARCHAR(255) NOT NULL,
  answer          TEXT         NOT NULL,
  sort_order      INT          NOT NULL DEFAULT 0,
  status          INT          NOT NULL DEFAULT 1 COMMENT '1노출 0숨김 -1삭제',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_faq_cat (faq_category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='FAQ 항목';

CREATE TABLE TB_ADMIN_NOTICE (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  target          INT          NOT NULL             COMMENT '1all/2instructor/3admin (변경불가)',
  title           VARCHAR(255) NOT NULL,
  content         TEXT         NOT NULL,
  is_pinned       TINYINT      NOT NULL DEFAULT 0,
  is_important    TINYINT      NOT NULL DEFAULT 0,
  read_count      INT          NOT NULL DEFAULT 0,
  created_user_id BIGINT       NOT NULL             COMMENT '작성 운영자',
  status          INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강사/관리자 공지';

CREATE TABLE TB_ADMIN_NOTICE_READ (
  id              BIGINT   NOT NULL AUTO_INCREMENT,
  admin_notice_id BIGINT   NOT NULL,
  user_id         BIGINT   NOT NULL,
  read_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status          INT      NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_noticeread (admin_notice_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='공지 읽음 처리';

CREATE TABLE TB_INQUIRY (
  id                BIGINT       NOT NULL AUTO_INCREMENT,
  user_id           BIGINT       NOT NULL              COMMENT '작성 학습자',
  type              INT          NOT NULL              COMMENT '1product/2payment/3report/4etc',
  ref_type          VARCHAR(20)      NULL              COMMENT 'product/post/comment/order',
  ref_id            BIGINT           NULL,
  title             VARCHAR(100) NOT NULL,
  content           TEXT         NOT NULL,
  inquiry_state     INT          NOT NULL DEFAULT 1    COMMENT '1waiting/2in_progress/3answered/4closed',
  assignee_user_id  BIGINT           NULL              COMMENT '담당자(최초 답변자)',
  has_attachment    TINYINT      NOT NULL DEFAULT 0,
  last_reply_at     DATETIME         NULL,
  status            INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '접수일',
  updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_inquiry_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='1:1 문의(헤더)';

CREATE TABLE TB_INQUIRY_REPLY (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  inquiry_id  BIGINT   NOT NULL,
  parent_id   BIGINT       NULL                   COMMENT '답글(self)',
  author_type INT      NOT NULL                   COMMENT '1admin(답변)/2user(추가질문)',
  user_id     BIGINT       NULL                   COMMENT '작성자(TB_USER)',
  content     TEXT     NOT NULL,
  is_deleted  TINYINT  NOT NULL DEFAULT 0         COMMENT '삭제유지',
  status      INT      NOT NULL DEFAULT 1         COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_reply_inquiry (inquiry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='문의 답변/추가질문';

CREATE TABLE TB_SITE_FOOTER (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  company       VARCHAR(100) NOT NULL,
  ceo           VARCHAR(50)      NULL,
  biz_no        VARCHAR(20)      NULL,
  mail_order_no VARCHAR(50)      NULL,
  address       VARCHAR(255)     NULL,
  tel           VARCHAR(30)      NULL,
  email         VARCHAR(255)     NULL,
  show_footer   TINYINT      NOT NULL DEFAULT 1,
  status        INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트 푸터';

CREATE TABLE TB_SITE_META (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  meta_key   VARCHAR(64) NOT NULL,
  meta_value TEXT            NULL,
  status     INT         NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_meta_site_key (meta_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트 메타/확장설정';

CREATE TABLE TB_SEO_OVERRIDE (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  target_type  INT          NOT NULL              COMMENT '1page/2product',
  target_id    BIGINT       NOT NULL,
  title        VARCHAR(255)     NULL,
  description  VARCHAR(160)     NULL,
  og_image_key VARCHAR(255)     NULL,
  status       INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_seo_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='페이지/상품별 SEO';

CREATE TABLE TB_MENU (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  parent_id          BIGINT           NULL          COMMENT '상위 메뉴(self)',
  name               VARCHAR(50)  NOT NULL,
  link_type          INT          NOT NULL DEFAULT 1 COMMENT '1page/2board/3product/4url',
  page_id            BIGINT           NULL,
  board_id           BIGINT           NULL,
  product_id         BIGINT           NULL,
  link_url           VARCHAR(255)     NULL,
  new_tab            TINYINT      NOT NULL DEFAULT 0,
  audience           INT          NOT NULL DEFAULT 1 COMMENT '1all/2member/3guest/4group',
  recipient_group_id BIGINT           NULL,
  is_default         TINYINT      NOT NULL DEFAULT 0,
  sort_order         INT          NOT NULL DEFAULT 0,
  status             INT          NOT NULL DEFAULT 1 COMMENT '1노출 0숨김 -1삭제',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_menu_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트 메뉴';

CREATE TABLE TB_PAGE (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  name        VARCHAR(100) NOT NULL,
  slug        VARCHAR(100) NOT NULL,
  description VARCHAR(160)     NULL,
  html        TEXT             NULL,
  is_default  TINYINT      NOT NULL DEFAULT 0,
  menu_linked TINYINT      NOT NULL DEFAULT 0,
  status      INT          NOT NULL DEFAULT 1     COMMENT '1발행 0임시저장 -1삭제',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_page_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='커스텀 페이지';

CREATE TABLE TB_PAGE_SECTION (
  id           BIGINT      NOT NULL AUTO_INCREMENT,
  page_id      BIGINT      NOT NULL,
  section_type VARCHAR(20) NOT NULL              COMMENT 'hero/text/products/board/review/survey/address/banner/html',
  sort_order   INT         NOT NULL DEFAULT 0,
  config       JSON            NULL,
  status       INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_pagesection_page (page_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='페이지 빌더 섹션';

CREATE TABLE TB_POPUP (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  name         VARCHAR(100) NOT NULL,
  image_key    VARCHAR(255)     NULL,
  link_url     VARCHAR(255)     NULL,
  start_date   DATE         NOT NULL,
  end_date     DATE         NOT NULL,
  display_rule INT          NOT NULL DEFAULT 1   COMMENT '1always/2once_day/3once_week/4once_visit',
  status       INT          NOT NULL DEFAULT 1   COMMENT '1공개 0비공개 -1삭제',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='팝업';

CREATE TABLE TB_BANNER (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  position   VARCHAR(30)  NOT NULL              COMMENT 'product_top/page_section/main_hero ...',
  image_key  VARCHAR(255)     NULL,
  title      VARCHAR(255)     NULL,
  link_url   VARCHAR(255)     NULL,
  start_date DATE             NULL,
  end_date   DATE             NULL,
  sort_order INT          NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1    COMMENT '1노출 0숨김 -1삭제',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배너';

CREATE TABLE TB_ATTACHMENT (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  owner_type    VARCHAR(20)  NOT NULL              COMMENT 'post/comment/inquiry/inquiry_reply',
  owner_id      BIGINT       NOT NULL,
  user_id       BIGINT           NULL              COMMENT '업로더',
  r2_key        VARCHAR(255) NOT NULL,
  original_name VARCHAR(255) NOT NULL,
  display_name  VARCHAR(255)     NULL,
  mime_type     VARCHAR(100)     NULL,
  size_bytes    BIGINT           NULL,
  sort_order    INT          NOT NULL DEFAULT 0,
  status        INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attachment_owner (owner_type, owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='공용 첨부파일(polymorphic)';

-- =====================================================================
--  끝. 테넌트 91개 테이블.
--  (Round1 교정 반영: TB_REVIEW 추가, 토큰/코드 해시, 정산프로필 소유자, 유니크/인덱스 보강)
-- =====================================================================
