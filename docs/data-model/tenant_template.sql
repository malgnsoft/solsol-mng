-- =====================================================================
--  쏠쏠 크리에이터 LMS — 테넌트(크리에이터) 스키마 템플릿 (Aurora MySQL 8.0)
--  schema-per-tenant: 크리에이터 1명 = DB(스키마) 1개. 이 파일을 신규 테넌트마다 적용.
--  스키마명 패턴(기본): solsol_t{테넌트ID 6자리}  예) solsol_t000123
--  플랫폼↔크리에이터 공통 데이터는 master.sql 참조.
-- ---------------------------------------------------------------------
--  컨벤션: TB_ 단수 / id BIGINT AUTO_INCREMENT PK / status INT(1정상 0중지 -1삭제)
--          금액·크레딧 DECIMAL(18,6) / TIMESTAMP UTC + created_at·updated_at 기본시
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
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트 표시 설정(테넌트 내 단일행)';

CREATE TABLE TB_USER (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  user_type          VARCHAR(20)  NOT NULL DEFAULT 'learner' COMMENT 'learner(수강생)/staff(강사·서브강사·운영자)',
  login_id           VARCHAR(255)     NULL                COMMENT '로그인 아이디. staff=별도 아이디(변경불가) / learner=소셜 이메일과 동일(login_id=email)',
  email              VARCHAR(255)     NULL                COMMENT '이메일(연락·소셜 통합 키). learner=소셜 이메일(login_id와 동일)',
  nickname           VARCHAR(15)      NULL                COMMENT '2~15자 단일규칙(C-1)·중복/금칙어',
  name               VARCHAR(50)      NULL                COMMENT '실명',
  phone              VARCHAR(20)      NULL,
  dept               VARCHAR(50)      NULL                COMMENT '부서(staff)',
  intro              TEXT             NULL                COMMENT '소개글(강사)',
  avatar_key         VARCHAR(255)     NULL                COMMENT '프로필 이미지 R2 키',
  google_uid         VARCHAR(255)     NULL                COMMENT 'Google 소셜 고유 ID(연동 시 비NULL)',
  kakao_uid          VARCHAR(255)     NULL                COMMENT 'Kakao 소셜 고유 ID(연동 시 비NULL)',
  naver_uid          VARCHAR(255)     NULL                COMMENT 'Naver 소셜 고유 ID(연동 시 비NULL)',
  apple_uid          VARCHAR(255)     NULL                COMMENT 'Apple 소셜 고유 ID(연동 시 비NULL)',
  facebook_uid       VARCHAR(255)     NULL                COMMENT 'Facebook 소셜 고유 ID(연동 시 비NULL)',
  primary_provider   VARCHAR(20)      NULL                COMMENT '대표(최초 연동) SNS: google/kakao/naver/apple/facebook',
  marketing_agreed   TINYINT      NOT NULL DEFAULT 0      COMMENT '마케팅 수신 동의 스냅샷(정본은 TB_USER_AGREEMENT)',
  last_login_at      TIMESTAMP         NULL,
  withdrawn_at       TIMESTAMP         NULL                COMMENT '탈퇴 시각(status=-1 연동)',
  status             INT          NOT NULL DEFAULT 1      COMMENT '1활성 0중지(suspended) -1탈퇴',
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일',
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_login_id (login_id),
  UNIQUE KEY uk_user_nickname (nickname),
  UNIQUE KEY uk_user_email (email),
  UNIQUE KEY uk_user_google (google_uid),
  UNIQUE KEY uk_user_kakao (kakao_uid),
  UNIQUE KEY uk_user_naver (naver_uid),
  UNIQUE KEY uk_user_apple (apple_uid),
  UNIQUE KEY uk_user_facebook (facebook_uid),
  KEY idx_user_type (user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='통합 회원(수강생/강사/서브강사/운영자) — 소셜 5종 비정규화(어떤 SNS로 로그인해도 1회원)';

CREATE TABLE TB_USER_CREDENTIAL (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  user_id             BIGINT       NOT NULL,
  password_hash       VARCHAR(255) NOT NULL                COMMENT '영문·숫자·특수문자 3종 8~16자(C-3) 해시. 응답 미포함',
  password_updated_at TIMESTAMP         NULL,
  two_factor_email    TINYINT      NOT NULL DEFAULT 0      COMMENT '이메일 2단계 인증',
  invited_by_user_id  BIGINT           NULL                COMMENT '초대한 관리자(TB_USER)',
  status              INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_credential_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ID+PW 자격증명(운영자/강사)';

CREATE TABLE TB_ROLE (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  code       VARCHAR(30)  NOT NULL                COMMENT 'owner/instructor/sub_instructor/learner',
  name       VARCHAR(50)  NOT NULL,
  status     INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_role_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='역할 카탈로그(RBAC)';

CREATE TABLE TB_USER_ROLE (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  role_id    BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  agreed_at     TIMESTAMP        NULL,
  status        INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  expires_at  TIMESTAMP     NOT NULL              COMMENT 'C-2 TTL',
  verified_at TIMESTAMP         NULL,
  send_count  INT          NOT NULL DEFAULT 0    COMMENT '연속 발송(10회 초과 제한)',
  verify_count INT         NOT NULL DEFAULT 0    COMMENT '검증 시도 횟수(무차별 방지)',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_authcode_target (target, purpose, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='인증코드(TTL)';

CREATE TABLE TB_PASSWORD_RESET_TOKEN (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  user_id    BIGINT       NOT NULL,
  token_hash VARCHAR(255) NOT NULL               COMMENT '재설정 토큰 해시(원문 미저장)',
  expires_at TIMESTAMP     NOT NULL               COMMENT '발급+30분',
  used_at    TIMESTAMP         NULL,
  status     INT          NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  expires_at       TIMESTAMP     NOT NULL              COMMENT '발급+48시간',
  accepted_at      TIMESTAMP         NULL,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  expires_at         TIMESTAMP     NOT NULL,
  revoked_at         TIMESTAMP         NULL,
  status             INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_device (user_id, device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='푸시 디바이스 토큰';

CREATE TABLE TB_OAUTH_CONFIG (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  provider      VARCHAR(20)  NOT NULL                COMMENT 'google/kakao/naver/apple/facebook',
  client_id     VARCHAR(255)     NULL                COMMENT 'OAuth client id(앱 키). 평문 저장 가능',
  client_secret TEXT             NULL                COMMENT 'AES-GCM 암호문(base64) 저장. 평문 금지',
  redirect_uri  VARCHAR(255)     NULL                COMMENT '이 테넌트의 provider 콜백 URI(또는 base)',
  extra_json    TEXT             NULL                COMMENT 'apple 전용 등: {teamId,keyId,privateKey(암호문)} JSON',
  enabled       TINYINT      NOT NULL DEFAULT 0      COMMENT '해당 provider 활성 여부(1켜짐 0꺼짐)',
  status        INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_oauth_provider (provider),
  KEY idx_oauth_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='테넌트별 소셜 OAuth 자격증명(provider당 1행·멀티테넌트)';

CREATE TABLE TB_CATEGORY (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  parent_id  BIGINT          NULL                COMMENT '상위 카테고리(self). 최대 2단계',
  name       VARCHAR(50) NOT NULL,
  sort_order INT         NOT NULL DEFAULT 0,
  status     INT         NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_category_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 카테고리(2단계)';

CREATE TABLE TB_PRODUCT (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  owner_user_id     BIGINT        NOT NULL              COMMENT '담당 강사(TB_USER). 데이터스코프 기준',
  category_id       BIGINT            NULL              COMMENT '1상품 1카테고리(멤버십 제외)',
  type              VARCHAR(20)   NOT NULL              COMMENT 'course/live/video_call/digital/package/membership/community',
  title             VARCHAR(100)  NOT NULL,
  sub_title         VARCHAR(255)      NULL,
  description       TEXT              NULL,
  thumbnail_key     VARCHAR(255)      NULL              COMMENT 'R2 키(16:9)',
  price_type        VARCHAR(10)   NOT NULL DEFAULT 'paid' COMMENT 'free/paid',
  list_price             DECIMAL(18,6)     NULL              COMMENT '정가',
  discount_rate     INT               NULL              COMMENT '할인율(%) UI 표시 전용·결제 계산 미사용(C-4 정액 only)',
  visibility        VARCHAR(10)   NOT NULL DEFAULT 'private' COMMENT 'public/partial/private. 신규 기본 private',
  sale_status       VARCHAR(15)   NOT NULL DEFAULT 'on_sale' COMMENT 'on_sale/sale_closed/sale_stopped/sale_ended',
  allow_review      TINYINT       NOT NULL DEFAULT 1,
  allow_qna         TINYINT       NOT NULL DEFAULT 1,
  enroll_period_days INT              NULL              COMMENT '수강기간(일). NULL=무제한',
  avg_rating        DECIMAL(2,1)      NULL              COMMENT '평균 별점(파생)',
  status            INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_owner (owner_user_id),
  KEY idx_product_type (type),
  KEY idx_product_category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='상품 공통(7종 통합)';

CREATE TABLE TB_PRODUCT_LIVE (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  product_id          BIGINT       NOT NULL              COMMENT '상품(TB_PRODUCT type=live)',
  youtube_url         VARCHAR(500)     NULL              COMMENT '유튜브 라이브 URL',
  youtube_video_id    VARCHAR(50)      NULL              COMMENT '유튜브 영상 ID',
  start_at            TIMESTAMP         NULL              COMMENT '방송 시작',
  end_at              TIMESTAMP         NULL              COMMENT '방송 종료',
  enter_open_min      INT          NOT NULL DEFAULT 10   COMMENT '입장 활성(시작 N분 전) 10~60',
  live_status         VARCHAR(10)  NOT NULL DEFAULT 'upcoming' COMMENT 'upcoming/live/ended',
  instant_complete    TINYINT      NOT NULL DEFAULT 1    COMMENT '입장 즉시 자동수료',
  certificate_template_id BIGINT       NULL              COMMENT '수료증 템플릿(TB_CERTIFICATE_TEMPLATE). NULL=수료증 미사용, 설정 시 자동발급',
  recorded_content_id BIGINT           NULL              COMMENT '종료 후 녹화본(TB_CONTENT)',
  status              INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_live_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='라이브 강의(YouTube Live 전용)';

CREATE TABLE TB_PRODUCT_VIDEO_CALL (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  product_id     BIGINT       NOT NULL              COMMENT '상품(TB_PRODUCT type=video_call)',
  platform       VARCHAR(12)      NULL              COMMENT 'zoom/google_meet',
  meeting_url    VARCHAR(500)     NULL              COMMENT '접속 URL',
  start_at       TIMESTAMP         NULL,
  end_at         TIMESTAMP         NULL,
  capacity       INT              NULL              COMMENT '모집인원',
  enter_open_min INT          NOT NULL DEFAULT 10   COMMENT '입장 활성(시작 N분 전)',
  status         INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_videocall_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='화상 강의(zoom/google_meet)';

CREATE TABLE TB_PRODUCT_DIGITAL_FILE (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  product_id     BIGINT       NOT NULL,
  content_id     BIGINT           NULL              COMMENT '라이브러리 콘텐츠 연결',
  file_name      VARCHAR(255) NOT NULL,
  r2_key         VARCHAR(255)     NULL,
  download_limit INT          NOT NULL DEFAULT 0    COMMENT '파일별 최대 다운로드(0=무제한, 1~100)',
  status         INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_digital_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='디지털 상품 구성 파일';

CREATE TABLE TB_DIGITAL_DOWNLOAD_LOG (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  digital_file_id BIGINT       NOT NULL              COMMENT '디지털 파일(TB_PRODUCT_DIGITAL_FILE)',
  product_id      BIGINT       NOT NULL              COMMENT '상품(TB_PRODUCT) 비정규화',
  user_id         BIGINT       NOT NULL              COMMENT '다운로드 회원(TB_USER)',
  order_id        BIGINT           NULL              COMMENT '구매 주문(TB_ORDER) — 구매권 근거·정산/환불 추적',
  order_item_id   BIGINT           NULL              COMMENT '구매 주문항목(TB_ORDER_ITEM) — 해당 디지털 상품 라인',
  file_name       VARCHAR(255)     NULL              COMMENT '다운로드 파일명 스냅샷',
  ip_addr         VARCHAR(64)      NULL              COMMENT '접속주소',
  user_agent      VARCHAR(500)     NULL              COMMENT '접속환경',
  status          INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '다운로드 시각',
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_dldlog_file_user (digital_file_id, user_id),
  KEY idx_dldlog_user (user_id, created_at),
  KEY idx_dldlog_order (order_id),
  KEY idx_dldlog_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='디지털 상품 다운로드 이력(누가·언제·어느 주문)';

CREATE TABLE TB_PACKAGE_ITEM (
  id                 BIGINT   NOT NULL AUTO_INCREMENT,
  package_product_id BIGINT   NOT NULL              COMMENT '패키지 상품',
  item_product_id    BIGINT   NOT NULL              COMMENT '구성 상품',
  sort_order         INT      NOT NULL DEFAULT 0,
  status             INT      NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_package_item (package_product_id, item_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='패키지 구성 상품(≤10)';

CREATE TABLE TB_MEMBERSHIP_TIER (
  id          BIGINT        NOT NULL AUTO_INCREMENT,
  product_id  BIGINT        NOT NULL,
  name        VARCHAR(50)   NOT NULL,
  monthly_price DECIMAL(18,6) NOT NULL,
  sort_order  INT           NOT NULL DEFAULT 0,
  status      INT           NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tier_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='멤버십 등급';

CREATE TABLE TB_MEMBERSHIP_CATEGORY (
  id          BIGINT   NOT NULL AUTO_INCREMENT,
  tier_id     BIGINT   NOT NULL,
  category_id BIGINT   NOT NULL,
  status      INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_tier_category (tier_id, category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='멤버십 등급-이용 카테고리';

CREATE TABLE TB_PRODUCT_COMMUNITY (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  product_id   BIGINT        NOT NULL,
  monthly_price  DECIMAL(18,6) NOT NULL              COMMENT '월 구독료(자동결제)',
  auto_payment TINYINT       NOT NULL DEFAULT 1,
  status       INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_community_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프리미엄 커뮤니티 확장';

CREATE TABLE TB_PRODUCT_BENEFIT (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  product_id   BIGINT       NOT NULL,
  benefit_text VARCHAR(255) NOT NULL,
  sort_order   INT          NOT NULL DEFAULT 0,
  status       INT          NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_benefit_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='멤버십/커뮤니티 혜택';

CREATE TABLE TB_COURSE (
  id                 BIGINT       NOT NULL AUTO_INCREMENT,
  product_id         BIGINT       NOT NULL              COMMENT '상품(TB_PRODUCT type=course)',
  level              VARCHAR(20)      NULL              COMMENT '난이도(beginner/intermediate/advanced)',
  total_section_cnt  INT          NOT NULL DEFAULT 0    COMMENT '섹션수(캐시)',
  total_lesson_cnt   INT          NOT NULL DEFAULT 0    COMMENT '강의수(캐시)',
  total_duration_sec INT          NOT NULL DEFAULT 0    COMMENT '총 재생시간 초(캐시)',
  min_progress_rate  INT          NOT NULL DEFAULT 80   COMMENT '수료 최소 진도율 10~100',
  watch_mode         VARCHAR(12)  NOT NULL DEFAULT 'free' COMMENT '시청방식 free/sequential(순차시청)',
  certificate_template_id BIGINT      NULL              COMMENT '수료증 템플릿(TB_CERTIFICATE_TEMPLATE). NULL=수료증 미사용, 설정 시 자동발급',
  status             INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_course_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강좌(type=course 확장·커리큘럼 루트·수료조건)';

CREATE TABLE TB_COURSE_TUTOR (
  id          BIGINT        NOT NULL AUTO_INCREMENT,
  course_id   BIGINT        NOT NULL              COMMENT '강좌(TB_COURSE)',
  user_id     BIGINT        NOT NULL              COMMENT '강사(TB_USER)',
  type        VARCHAR(10)   NOT NULL              COMMENT '구분(main 주강사/sub 보조강사 등)',
  class       VARCHAR(100)  NOT NULL DEFAULT '1'  COMMENT '분반',
  ratio       DECIMAL(18,6) NOT NULL DEFAULT 0    COMMENT '정산비율(%)',
  sort_order  INT               NULL DEFAULT 0    COMMENT '정렬순서',
  is_display  TINYINT       NOT NULL DEFAULT 1    COMMENT '노출여부',
  status      INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_coursetutor (course_id, user_id, type),
  KEY idx_coursetutor_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='과정강사관리(강좌-강사)';

CREATE TABLE TB_SECTION (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  course_id  BIGINT       NOT NULL                 COMMENT '강좌(TB_COURSE)',
  title      VARCHAR(255) NOT NULL,
  sort_order INT          NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_section_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강의 섹션';

CREATE TABLE TB_LESSON (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  section_id BIGINT       NOT NULL                 COMMENT '섹션(TB_SECTION)',
  course_id  BIGINT       NOT NULL                 COMMENT '강좌(TB_COURSE) 비정규화',
  content_id BIGINT           NULL                 COMMENT '연결 콘텐츠(강의당 1개)',
  title      VARCHAR(255) NOT NULL,
  seq        INT          NOT NULL DEFAULT 0       COMMENT '섹션 내 순번',
  is_preview TINYINT      NOT NULL DEFAULT 0       COMMENT '맛보기(무료공개)',
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_lesson_section (section_id),
  KEY idx_lesson_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강의(차시)';

CREATE TABLE TB_CONTENT_FOLDER (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  parent_id  BIGINT           NULL                 COMMENT '상위 폴더(self). 최대 2단계',
  name       VARCHAR(100) NOT NULL,
  sort_order INT          NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='콘텐츠 폴더';

CREATE TABLE TB_CONTENT (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  folder_id        BIGINT           NULL,
  name             VARCHAR(255) NOT NULL,
  media_type       VARCHAR(10)  NOT NULL DEFAULT 'video' COMMENT 'video/doc/image/etc',
  source_type      VARCHAR(10)  NOT NULL DEFAULT 'wecandeo' COMMENT 'wecandeo(영상 VOD)/youtube(임베드)/upload(문서·이미지 R2)',
  wecandeo_video_key VARCHAR(100)   NULL              COMMENT '위캔디오 VOD 키/ID(영상)',
  r2_key           VARCHAR(255)     NULL              COMMENT '문서·이미지 R2 키(upload)',
  youtube_url      VARCHAR(500)     NULL,
  upload_status    VARCHAR(12)  NOT NULL DEFAULT 'pending' COMMENT '위캔디오 인코딩/업로드 상태 pending/processing/done/failed',
  duration_sec     INT              NULL,
  size_bytes       BIGINT           NULL              COMMENT '용량(한도 집계)',
  thumbnail_key    VARCHAR(255)     NULL              COMMENT '썸네일(위캔디오 제공/R2)',
  has_ai_tutor     TINYINT      NOT NULL DEFAULT 0,
  has_ai_translate TINYINT      NOT NULL DEFAULT 0,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_content_folder (folder_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='콘텐츠(미디어 자산)';

-- 자막은 위캔디오(Wecandeo)가 보관·제공 → 별도 TB_SUBTITLE/TB_SUBTITLE_LINE 미사용(삭제)

CREATE TABLE TB_COURSE_USER (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  product_id      BIGINT        NOT NULL              COMMENT '수강 상품(TB_PRODUCT)',
  course_id       BIGINT            NULL              COMMENT '강좌(TB_COURSE) — type=course일 때',
  package_id      BIGINT            NULL              COMMENT '패키지 상품(TB_PRODUCT type=package) 경유 구매 시',
  user_id         BIGINT        NOT NULL              COMMENT '수강생(TB_USER)',
  order_id        BIGINT            NULL              COMMENT '주문(TB_ORDER)',
  order_item_id   BIGINT            NULL              COMMENT '주문항목(TB_ORDER_ITEM)',
  subscription_id BIGINT            NULL              COMMENT '정기구독(TB_SUBSCRIPTION) — 구독 부여 시',
  grant_source    VARCHAR(12)   NOT NULL DEFAULT 'purchase' COMMENT 'purchase/subscription/package/membership',
  learn_status    VARCHAR(12)   NOT NULL DEFAULT 'before'   COMMENT 'before/learning/completed(편의 상태)',
  start_date      DATE              NULL              COMMENT '수강시작일',
  end_date        DATE              NULL              COMMENT '수강종료일',
  renew_cnt       INT           NOT NULL DEFAULT 0    COMMENT '연장횟수(학습기간 추가)',
  progress_ratio  DECIMAL(11,2) NOT NULL DEFAULT 0.00 COMMENT '진도율(완료 기준 — 시험 미사용)',
  is_complete     TINYINT       NOT NULL DEFAULT 0    COMMENT '수료여부(1수료 0미수료)',
  complete_no     VARCHAR(50)       NULL              COMMENT '수료번호',
  complete_date   TIMESTAMP          NULL              COMMENT '수료일',
  status          INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '구매/등록일',
  updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_courseuser_user (user_id),
  KEY idx_courseuser_product (product_id),
  KEY idx_courseuser_course (course_id, user_id),
  KEY idx_courseuser_order (order_id),
  KEY idx_courseuser_dashboard (status, is_complete, course_id, user_id),
  KEY idx_courseuser_period (status, end_date, start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수강생관리(수강 등록·진도·성적·수료)';

CREATE TABLE TB_LESSON_PROGRESS (
  id             BIGINT         NOT NULL AUTO_INCREMENT,
  course_user_id BIGINT         NOT NULL              COMMENT '수강(TB_COURSE_USER)',
  lesson_id      BIGINT         NOT NULL              COMMENT '강의(TB_LESSON)',
  course_id      BIGINT         NOT NULL              COMMENT '강좌(TB_COURSE) 비정규화',
  user_id        BIGINT         NOT NULL              COMMENT '회원(TB_USER) 비정규화',
  chapter        INT                NULL              COMMENT '장',
  ai_session_id  BIGINT             NULL              COMMENT 'AI튜터 세션',
  lesson_type    VARCHAR(2)         NULL              COMMENT '영상/콘텐츠 타입',
  study_page     INT            NOT NULL DEFAULT 0    COMMENT '학습페이지 수',
  study_time     INT            NOT NULL DEFAULT 0    COMMENT '학습시간(초)',
  curr_page      VARCHAR(255)       NULL              COMMENT '현재 페이지(문서형)',
  curr_time      INT            NOT NULL DEFAULT 0    COMMENT '현재 위치(초, 이어보기)',
  last_time      INT            NOT NULL DEFAULT 0    COMMENT '최대 위치(초)',
  paragraph      VARCHAR(4000)      NULL              COMMENT '수강한 절 번호',
  ratio          DECIMAL(11,2)  NOT NULL DEFAULT 0.00 COMMENT '진도율',
  is_complete    TINYINT        NOT NULL DEFAULT 0    COMMENT '완료여부',
  complete_date  TIMESTAMP           NULL              COMMENT '완료일',
  view_cnt       INT            NOT NULL DEFAULT 0    COMMENT '수강 횟수',
  last_date      TIMESTAMP           NULL              COMMENT '마지막 수강일',
  change_user_id BIGINT             NULL              COMMENT '임의변경자(TB_USER)',
  status         INT            NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_progress_courseuser_lesson (course_user_id, lesson_id),
  KEY idx_lessonprog_course_lesson (course_id, lesson_id),
  KEY idx_lessonprog_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='진도관리(강의별 진도)';

CREATE TABLE TB_COURSE_USER_LOG (
  id                   BIGINT         NOT NULL AUTO_INCREMENT,
  course_user_id       BIGINT         NOT NULL              COMMENT '수강(TB_COURSE_USER)',
  user_id              BIGINT         NOT NULL              COMMENT '회원(TB_USER)',
  course_id            BIGINT             NULL              COMMENT '강좌(TB_COURSE)',
  lesson_id            BIGINT         NOT NULL              COMMENT '강의(TB_LESSON)',
  chapter              INT                NULL              COMMENT '차시(장)',
  progress_ratio       DECIMAL(11,2)      NULL              COMMENT '차시진도율',
  is_progress_complete TINYINT            NULL              COMMENT '차시완료여부',
  ip_addr              VARCHAR(64)        NULL              COMMENT '접속주소',
  user_agent           VARCHAR(500)       NULL              COMMENT '접속환경',
  status               INT            NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '접속일',
  updated_at           TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_courseuserlog_courseuser (course_user_id, created_at),
  KEY idx_courseuserlog_user (user_id),
  KEY idx_courseuserlog_lesson (lesson_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='학습 기록(강의실 접속 로그)';

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
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수료증 템플릿';

CREATE TABLE TB_CERTIFICATE (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  course_user_id BIGINT       NOT NULL              COMMENT '수강(TB_COURSE_USER)',
  user_id       BIGINT        NOT NULL,
  product_id    BIGINT        NOT NULL,
  template_id   BIGINT        NOT NULL              COMMENT '발급 시점 템플릿',
  cert_no       VARCHAR(50)   NOT NULL              COMMENT '수료번호',
  learner_name  VARCHAR(100)  NOT NULL              COMMENT '수료자명 스냅샷',
  product_title VARCHAR(255)  NOT NULL              COMMENT '상품명 스냅샷',
  study_hours   DECIMAL(6,2)      NULL,
  started_at    TIMESTAMP          NULL,
  completed_at  TIMESTAMP      NOT NULL,
  revoked       TINYINT       NOT NULL DEFAULT 0    COMMENT '무효(환불/취소 시)',
  issued_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status        INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cert_no (cert_no),
  KEY idx_cert_user (user_id),
  KEY idx_cert_courseuser (course_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수료증 발급 이력';

CREATE TABLE TB_WISHLIST (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  user_id    BIGINT   NOT NULL,
  product_id BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1           COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_wishlist (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='위시리스트(찜)';

CREATE TABLE TB_REVIEW (
  id            BIGINT   NOT NULL AUTO_INCREMENT,
  user_id       BIGINT   NOT NULL                   COMMENT '작성 수강생(TB_USER)',
  product_id    BIGINT   NOT NULL                   COMMENT '대상 상품(TB_PRODUCT)',
  course_user_id BIGINT      NULL                   COMMENT '수강(TB_COURSE_USER). NULL=구매 없이 작성 불가 정책 적용 시 NOT NULL로 변경',
  rating        INT      NOT NULL                   COMMENT '별점 1~5',
  content       TEXT         NULL                   COMMENT '후기 본문',
  status        INT      NOT NULL DEFAULT 1         COMMENT '1공개 0숨김(운영자) -1삭제',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  credit_id        BIGINT          NULL              COMMENT '크레딧 차감 원장행(master.TB_CREDIT) 논리참조',
  status           INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  current_period_start TIMESTAMP      NOT NULL,
  current_period_end   TIMESTAMP      NOT NULL,
  next_billing_at      TIMESTAMP          NULL,
  cancel_scheduled     TINYINT       NOT NULL DEFAULT 0    COMMENT '기간종료후 해지 예약',
  canceled_at          TIMESTAMP          NULL,
  started_at           TIMESTAMP          NULL              COMMENT '최초 구독 시작일',
  grace_until          TIMESTAMP          NULL              COMMENT '유예 종료일',
  status               INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제 (구독상태는 sub_state)',
  sub_state            VARCHAR(12)   NOT NULL DEFAULT 'active' COMMENT 'active/grace/expired/canceled',
  created_at           TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sub_user (user_id),
  KEY idx_sub_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='구독(판매자 플랜/멤버십/커뮤니티)';

CREATE TABLE TB_ORDER (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  order_no        VARCHAR(30)   NOT NULL              COMMENT 'ORD-YYYYMMDD-NNNN',
  user_id         BIGINT        NOT NULL              COMMENT '주문자',
  ref_type        VARCHAR(20)   NOT NULL DEFAULT 'product' COMMENT 'product/credit_charge',
  list_price        DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '정가 합계',
  shop_discount_price   DECIMAL(18,6) NOT NULL DEFAULT 0,
  coupon_id       BIGINT            NULL,
  coupon_discount_price DECIMAL(18,6) NOT NULL DEFAULT 0,
  vat_price             DECIMAL(18,6) NOT NULL DEFAULT 0,
  pay_price           DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '총 결제금액',
  is_subscription TINYINT       NOT NULL DEFAULT 0,
  paid_at         TIMESTAMP          NULL,
  order_state     VARCHAR(15)   NOT NULL DEFAULT 'pending' COMMENT 'pending/paying/paid/failed/grace/unpaid/canceled/refunded/partial_refund',
  status          INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  discount_price       DECIMAL(18,6) NOT NULL DEFAULT 0,
  pay_price              DECIMAL(18,6) NOT NULL DEFAULT 0 COMMENT '항목 결제금액',
  status              INT           NOT NULL DEFAULT 1 COMMENT '1정상 0중지 -1삭제',
  created_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_orderitem_order (order_id),
  KEY idx_orderitem_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='주문 항목';

CREATE TABLE TB_INVOICE (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  subscription_id   BIGINT        NOT NULL,
  period_start      TIMESTAMP      NOT NULL,
  period_end        TIMESTAMP      NOT NULL,
  pay_price            DECIMAL(18,6) NOT NULL,
  vat_price               DECIMAL(18,6) NOT NULL DEFAULT 0,
  unpaid_carryover_price  DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '미납 이월액',
  billing_due_at    TIMESTAMP      NOT NULL,
  retry_count       INT           NOT NULL DEFAULT 0    COMMENT '재시도 회차(최대 6)',
  paid_payment_id   BIGINT            NULL,
  issued_at         TIMESTAMP          NULL              COMMENT '청구 발행 시각',
  paid_at           TIMESTAMP          NULL              COMMENT '납부 완료 시각',
  invoice_state     VARCHAR(10)   NOT NULL DEFAULT 'open' COMMENT 'open/paying/paid/failed/grace/void',
  status            INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  pay_price           DECIMAL(18,6) NOT NULL,
  method           INT           NOT NULL DEFAULT 1   COMMENT '1=card(계좌이체 미지원)',
  retry_count      INT           NOT NULL DEFAULT 0,
  fail_code        VARCHAR(50)       NULL,
  fail_message     VARCHAR(255)      NULL,
  approved_at      TIMESTAMP          NULL,
  pay_state        VARCHAR(15)   NOT NULL DEFAULT 'ready' COMMENT 'ready/approved/failed/canceled/partial_canceled',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  registered_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_billing_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='빌링키(등록 결제수단)';

CREATE TABLE TB_REFUND (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  order_id         BIGINT        NOT NULL,
  payment_id       BIGINT            NULL,
  refund_type      INT           NOT NULL DEFAULT 1   COMMENT '1=full/2=partial',
  requested_price DECIMAL(18,6)     NULL,
  refund_price    DECIMAL(18,6) NOT NULL,
  reason           VARCHAR(255)      NULL,
  transfer_note    VARCHAR(255)      NULL              COMMENT '이체내역(저장 전 계좌/예금주 마스킹)',
  channel          INT           NOT NULL DEFAULT 1   COMMENT '1=self/2=inquiry',
  inquiry_id       BIGINT            NULL              COMMENT '(1:1문의=TB_POST board_type=qna 의 게시물 id)',
  revoke_course    TINYINT       NOT NULL DEFAULT 0   COMMENT '수강권 회수',
  void_certificate TINYINT       NOT NULL DEFAULT 0   COMMENT '수료증 무효',
  requested_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  refunded_at      TIMESTAMP          NULL,
  handler_user_id  BIGINT            NULL,
  refund_state     VARCHAR(12)   NOT NULL DEFAULT 'requested' COMMENT 'requested/completed/rejected',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_refund_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='환불(비가역 게이트)';

CREATE TABLE TB_REFUND_LOG (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  refund_id       BIGINT        NOT NULL,
  processed_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  handler_user_id BIGINT            NULL,
  refund_price   DECIMAL(18,6)     NULL,
  transfer_note   VARCHAR(255)      NULL              COMMENT '이체내역(저장 전 계좌/예금주 마스킹)',
  content         VARCHAR(255)      NULL,
  status          INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_refundlog_refund (refund_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='환불 처리 로그';

CREATE TABLE TB_COUPON (
  id                 BIGINT        NOT NULL AUTO_INCREMENT,
  name               VARCHAR(100)  NOT NULL,
  description        VARCHAR(255)      NULL,
  discount_type      INT           NOT NULL DEFAULT 1   COMMENT '1=AMOUNT only(C-4). 정률 미사용',
  discount_price    DECIMAL(18,6) NOT NULL              COMMENT '정액 할인액',
  min_order_price   DECIMAL(18,6)     NULL,
  scope_type         INT           NOT NULL DEFAULT 1   COMMENT '1=ALL/2=SPECIFIC',
  target_type        INT           NOT NULL DEFAULT 1   COMMENT '1=ALL_MEMBER/2=GROUP',
  recipient_group_id BIGINT            NULL,
  issue_quantity     INT               NULL              COMMENT 'NULL=제한없음',
  use_period_start   TIMESTAMP          NULL,
  use_period_end     TIMESTAMP          NULL,
  valid_days         INT               NULL              COMMENT '발급 후 유효일수',
  coupon_state       VARCHAR(12)   NOT NULL DEFAULT 'active' COMMENT 'active/suspended/revoked',
  status             INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰(정액 only)';

CREATE TABLE TB_COUPON_PRODUCT (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  coupon_id  BIGINT   NOT NULL,
  product_id BIGINT   NOT NULL,
  status     INT      NOT NULL DEFAULT 1           COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_coupon_product (coupon_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='쿠폰-상품 매핑';

CREATE TABLE TB_COUPON_ISSUE (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  coupon_id        BIGINT        NOT NULL,
  user_id          BIGINT        NOT NULL,
  coupon_code      VARCHAR(50)       NULL,
  order_id         BIGINT            NULL,
  discount_price DECIMAL(18,6)     NULL,
  issued_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at       TIMESTAMP          NULL,
  used_at          TIMESTAMP          NULL,
  issue_state      VARCHAR(12)   NOT NULL DEFAULT 'issued' COMMENT 'issued/used/revoked',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  approved_at        TIMESTAMP         NULL,
  status             INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_settleprofile_instructor (instructor_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='정산 정보(승인 게이트)';

CREATE TABLE TB_SETTLEMENT (
  id                 BIGINT        NOT NULL AUTO_INCREMENT,
  instructor_user_id BIGINT            NULL              COMMENT '강사 스코프(NULL=전사)(=06 §1.9 instructor_admin_id)',
  period_month       VARCHAR(7)    NOT NULL              COMMENT 'YYYY-MM',
  period_start       TIMESTAMP          NULL,
  period_end         TIMESTAMP          NULL,
  pay_date           TIMESTAMP      NOT NULL              COMMENT '지급 예정(익월 10일)',
  settle_count       INT               NULL,
  payment_count      INT               NULL,
  cancel_count       INT               NULL,
  gross_price       DECIMAL(18,6) NOT NULL DEFAULT 0,
  supply_price      DECIMAL(18,6) NOT NULL DEFAULT 0,
  vat_price                DECIMAL(18,6) NOT NULL DEFAULT 0,
  sales_fee_price          DECIMAL(18,6) NOT NULL DEFAULT 0,
  sales_fee_rate     DECIMAL(18,6)     NULL,
  pg_fee_price             DECIMAL(18,6) NOT NULL DEFAULT 0,
  canceled_price    DECIMAL(18,6) NOT NULL DEFAULT 0,
  net_price         DECIMAL(18,6) NOT NULL DEFAULT 0,
  bank_snapshot      VARCHAR(255)      NULL,
  settle_state       VARCHAR(12)   NOT NULL DEFAULT 'pending' COMMENT 'pending/approved/paid',
  approved_at        TIMESTAMP          NULL,
  status             INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  gross_price  DECIMAL(18,6) NOT NULL DEFAULT 0,
  sales_fee_price     DECIMAL(18,6)     NULL,
  pg_fee_price        DECIMAL(18,6)     NULL,
  net_price    DECIMAL(18,6) NOT NULL DEFAULT 0,
  status        INT           NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_settleitem_settle (settlement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='정산 상품별 매출';

CREATE TABLE TB_TAX_REPORT (
  id             BIGINT        NOT NULL AUTO_INCREMENT,
  period_month   VARCHAR(7)    NOT NULL              COMMENT 'YYYY-MM',
  approve_count  INT               NULL,
  cancel_count   INT               NULL,
  net_count      INT               NULL,
  paid_price     DECIMAL(18,6) NOT NULL DEFAULT 0,
  canceled_price DECIMAL(18,6) NOT NULL DEFAULT 0,
  net_price      DECIMAL(18,6) NOT NULL DEFAULT 0,
  status         INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_taxreport_site (period_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='부가세 신고 자료(참고)';

CREATE TABLE TB_TAX_REPORT_ITEM (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  tax_report_id BIGINT        NOT NULL,
  order_id      BIGINT            NULL,
  trade_type    INT           NOT NULL DEFAULT 1     COMMENT '1=approve/2=cancel',
  pay_price        DECIMAL(18,6) NOT NULL DEFAULT 0,
  traded_at     TIMESTAMP          NULL,
  status        INT           NOT NULL DEFAULT 1     COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  received_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  event_state        VARCHAR(12)  NOT NULL DEFAULT 'received' COMMENT 'received/processed/duplicate/failed',
  status             INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='수신자 그룹';

CREATE TABLE TB_RECIPIENT_GROUP_MEMBER (
  id                 BIGINT      NOT NULL AUTO_INCREMENT,
  recipient_group_id BIGINT      NOT NULL,
  user_id            BIGINT      NOT NULL,
  added_by           VARCHAR(20) NOT NULL DEFAULT 'manual' COMMENT 'manual/condition',
  status             INT         NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at             TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at             TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  scheduled_at        TIMESTAMP          NULL              COMMENT '예약(>= now+10분)',
  send_condition      JSON              NULL,
  est_credit_cost     DECIMAL(18,6)     NULL              COMMENT '예상 크레딧 소모',
  recipient_count     INT               NULL,
  success_count       INT               NULL,
  fail_count          INT               NULL,
  open_count          INT               NULL,
  send_state          VARCHAR(20)   NOT NULL DEFAULT 'reserved' COMMENT 'reserved/sending/sent/stopped/failed',
  status              INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  opened_at      TIMESTAMP         NULL,
  excluded       TINYINT      NOT NULL DEFAULT 0,
  resent_count   INT          NOT NULL DEFAULT 0,
  status         INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='설문폼';

CREATE TABLE TB_SURVEY_QUESTION (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  survey_id  BIGINT       NOT NULL,
  seq        INT          NOT NULL,
  text       VARCHAR(500) NOT NULL,
  qtype      VARCHAR(20)  NOT NULL DEFAULT 'text' COMMENT 'text/long/radio/check/rating',
  rating_max INT              NULL              COMMENT 'rating 척도 최대(예 5). qtype=rating',
  option1    VARCHAR(500)     NULL              COMMENT '보기1(radio/check)',
  option2    VARCHAR(500)     NULL              COMMENT '보기2',
  option3    VARCHAR(500)     NULL              COMMENT '보기3',
  option4    VARCHAR(500)     NULL              COMMENT '보기4',
  option5    VARCHAR(500)     NULL              COMMENT '보기5',
  option6    VARCHAR(500)     NULL              COMMENT '보기6',
  option7    VARCHAR(500)     NULL              COMMENT '보기7',
  option8    VARCHAR(500)     NULL              COMMENT '보기8',
  option9    VARCHAR(500)     NULL              COMMENT '보기9',
  option10   VARCHAR(500)     NULL              COMMENT '보기10',
  required   TINYINT      NOT NULL DEFAULT 0,
  status     INT          NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_question_survey (survey_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='설문 문항(보기 option1~10 인라인)';

CREATE TABLE TB_SURVEY_RESPONSE (
  id           BIGINT   NOT NULL AUTO_INCREMENT,
  survey_id    BIGINT   NOT NULL,
  user_id      BIGINT       NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status       INT      NOT NULL DEFAULT 1          COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_response_survey (survey_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='설문 응답';

CREATE TABLE TB_SURVEY_ANSWER (
  id                 BIGINT   NOT NULL AUTO_INCREMENT,
  survey_response_id BIGINT   NOT NULL,
  survey_question_id BIGINT   NOT NULL,
  option_no          INT          NULL              COMMENT '선택 보기 번호(1~10, TB_SURVEY_QUESTION.option*) — radio/check. check는 보기당 1행',
  answer_text        TEXT         NULL              COMMENT '주관식 답(text/long)',
  rating_value       INT          NULL              COMMENT '척도 답(rating)',
  status             INT      NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_answer_response (survey_response_id),
  KEY idx_answer_question (survey_question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='문항별 답변(보기는 option_no, 복수선택은 다행)';

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
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='랜딩페이지';

CREATE TABLE TB_LANDING_PRODUCT (
  id              BIGINT   NOT NULL AUTO_INCREMENT,
  landing_page_id BIGINT   NOT NULL,
  product_id      BIGINT   NOT NULL,
  seq             INT      NOT NULL DEFAULT 0       COMMENT '진열 순서(0~3)',
  status          INT      NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_landingprod_page (landing_page_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='랜딩 진열 상품(≤4)';

CREATE TABLE TB_MARKETING_TOOL (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  tool_type    VARCHAR(30)  NOT NULL              COMMENT 'kakao_channel/google_analytics/google_tag_manager/meta_pixel',
  connected    TINYINT      NOT NULL DEFAULT 0,
  config_value VARCHAR(300)     NULL,
  status       INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  ref_type          VARCHAR(20)      NULL             COMMENT 'post(1:1문의)/order/refund/content/campaign/settlement',
  ref_id            BIGINT           NULL,
  filter_type       VARCHAR(20)      NULL             COMMENT 'inquiry/payment/system',
  is_read           TINYINT      NOT NULL DEFAULT 0,
  read_at           TIMESTAMP         NULL,
  send_result       VARCHAR(20)      NULL,
  status            INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_notiset_user (user_id, category, channel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 알림 수신설정';

CREATE TABLE TB_STAT_DAILY (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  stat_date    DATE          NOT NULL,
  metric_key   VARCHAR(40)   NOT NULL              COMMENT 'sales/orders/signups/completions ...',
  metric_value DECIMAL(18,6) NOT NULL DEFAULT 0,
  status       INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_stat_daily (stat_date, metric_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='일/월 통계 사전집계(선택)';

CREATE TABLE TB_BOARD (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  code          VARCHAR(50)   NOT NULL              COMMENT '코드',
  board_nm      VARCHAR(100)  NOT NULL              COMMENT '게시판명',
  layout        VARCHAR(100)      NULL              COMMENT '레이아웃',
  breadcrumb    VARCHAR(255)      NULL              COMMENT '현재경로명',
  board_type    VARCHAR(50)       NULL              COMMENT '게시판타입(notice/faq/qna/free 등)',
  admin_idx     VARCHAR(1000)     NULL DEFAULT '||' COMMENT '게시판관리자',
  auth_list     VARCHAR(1000)     NULL              COMMENT '목록권한',
  auth_read     VARCHAR(1000)     NULL              COMMENT '읽기권한',
  auth_write    VARCHAR(1000)     NULL              COMMENT '쓰기권한',
  auth_reply    VARCHAR(1000)     NULL              COMMENT '답글권한',
  auth_comm     VARCHAR(1000)     NULL              COMMENT '댓글권한',
  auth_download VARCHAR(1000)     NULL              COMMENT '다운로드권한',
  list_num      INT               NULL DEFAULT 10   COMMENT '게시물수',
  is_notice     TINYINT       NOT NULL DEFAULT 0    COMMENT '공지글사용',
  is_reply      TINYINT       NOT NULL DEFAULT 0    COMMENT '답글사용',
  is_delete     TINYINT       NOT NULL DEFAULT 1    COMMENT '덧글달린글삭제가능',
  is_comment    TINYINT       NOT NULL DEFAULT 0    COMMENT '댓글사용',
  is_category   TINYINT       NOT NULL DEFAULT 0    COMMENT '카테고리사용',
  is_upload     TINYINT       NOT NULL DEFAULT 0    COMMENT '파일첨부사용',
  is_image      TINYINT       NOT NULL DEFAULT 1    COMMENT '목록이미지노출',
  is_captcha    TINYINT       NOT NULL DEFAULT 0    COMMENT '자동등록방지',
  is_private    TINYINT       NOT NULL DEFAULT 0    COMMENT '작성자글만보기',
  is_point      TINYINT           NULL DEFAULT 0    COMMENT '포인트부여',
  allow_type    VARCHAR(255)      NULL              COMMENT '허용확장자',
  deny_ext      VARCHAR(255)      NULL              COMMENT '거부확장자',
  header_html   VARCHAR(4000)     NULL              COMMENT '상단HTML',
  footer_html   VARCHAR(4000)     NULL              COMMENT '하단HTML',
  user_template MEDIUMTEXT        NULL              COMMENT '사용자단 게시물템플릿',
  sort_type     VARCHAR(50)       NULL DEFAULT 'rd desc' COMMENT '정렬타입',
  sort          INT           NOT NULL DEFAULT 1    COMMENT '정렬순서',
  status        INT           NOT NULL DEFAULT 1    COMMENT '1공개 0비공개 -1삭제',
  created_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_board_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='게시판 정의(범용 엔진)';

CREATE TABLE TB_BOARD_CATEGORY (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  board_id    BIGINT       NOT NULL              COMMENT '게시판(TB_BOARD)',
  category_nm VARCHAR(100) NOT NULL              COMMENT '카테고리명',
  sort        INT              NULL              COMMENT '순서',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_boardcat_board (board_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='게시판 카테고리(board_id 종속)';

CREATE TABLE TB_POST (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  board_id    BIGINT           NULL              COMMENT 'FK(TB_BOARD)',
  category_id BIGINT           NULL              COMMENT 'FK(TB_BOARD_CATEGORY)',
  thread      INT          NOT NULL              COMMENT '쓰레드',
  depth       VARCHAR(255)     NULL              COMMENT '깊이',
  user_id     BIGINT           NULL              COMMENT 'FK(TB_USER)',
  writer      VARCHAR(100)     NULL              COMMENT '글쓴이',
  subject     VARCHAR(255)     NULL              COMMENT '제목',
  content     TEXT             NULL              COMMENT '내용',
  youtube_cd  VARCHAR(50)      NULL              COMMENT '유튜브코드',
  is_notice   TINYINT      NOT NULL DEFAULT 0    COMMENT '공지글',
  is_secret   TINYINT      NOT NULL DEFAULT 0    COMMENT '비밀글(1:1문의 등)',
  hit_cnt     INT          NOT NULL DEFAULT 0    COMMENT '조회수',
  comm_cnt    INT          NOT NULL DEFAULT 0    COMMENT '댓글수',
  recomm_cnt  INT          NOT NULL DEFAULT 0    COMMENT '추천수',
  report_cnt  INT          NOT NULL DEFAULT 0    COMMENT '신고수',
  file_cnt    INT          NOT NULL DEFAULT 0    COMMENT '첨부수',
  is_display  TINYINT      NOT NULL DEFAULT 1    COMMENT '노출여부',
  sort        INT              NULL DEFAULT 1    COMMENT '순서',
  proc_status INT          NOT NULL DEFAULT 0    COMMENT '진행상태(1:1문의 답변상태 등)',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1공개 0비공개 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_post_board (board_id, created_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='게시물(범용 엔진 — 공지/FAQ/1:1문의/자유)';

CREATE TABLE TB_COMMENT (
  id            BIGINT      NOT NULL AUTO_INCREMENT,
  parent_id     BIGINT          NULL DEFAULT 0     COMMENT '답글대상',
  module        VARCHAR(50) NOT NULL DEFAULT 'post' COMMENT '모듈',
  module_id     BIGINT      NOT NULL DEFAULT 0     COMMENT '모듈아이디',
  post_id       BIGINT          NULL              COMMENT 'FK(TB_POST) 게시물(편의)',
  user_id       BIGINT          NULL              COMMENT 'FK(TB_USER)',
  writer        VARCHAR(50)     NULL              COMMENT '작성자',
  reply_user_id BIGINT          NULL DEFAULT 0    COMMENT '답글대상회원',
  content       MEDIUMTEXT      NULL              COMMENT '내용',
  status        INT         NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_comment_module (module, module_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='댓글(범용 module 기반)';

CREATE TABLE TB_FILE (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  module       VARCHAR(50)  NOT NULL              COMMENT '모듈',
  module_id    BIGINT       NOT NULL DEFAULT 0    COMMENT '모듈아이디',
  is_main      TINYINT      NOT NULL DEFAULT 0    COMMENT '메인여부',
  file_nm      VARCHAR(255)     NULL              COMMENT '표시 파일명',
  filename     VARCHAR(255) NOT NULL              COMMENT '원본파일명',
  realname     VARCHAR(255) NOT NULL              COMMENT '서버 실파일명(R2 키)',
  filesize     BIGINT           NULL              COMMENT '파일크기(byte)',
  filetype     VARCHAR(100)     NULL              COMMENT '파일종류',
  file_uuid    VARCHAR(40)      NULL              COMMENT '파일UUID',
  download_cnt INT          NOT NULL DEFAULT 0    COMMENT '다운로드횟수',
  is_download  TINYINT      NOT NULL DEFAULT 1    COMMENT '다운로드가능',
  status       INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_file_module (module, module_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='첨부파일(범용 module 기반)';

CREATE TABLE TB_COMMUNITY_CATEGORY (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  product_id  BIGINT       NOT NULL              COMMENT '커뮤니티 상품(TB_PRODUCT type=community)',
  category_nm VARCHAR(100) NOT NULL              COMMENT '카테고리명',
  sort        INT              NULL              COMMENT '순서',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_communitycat_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프리미엄 커뮤니티 카테고리(product_id 종속)';

CREATE TABLE TB_COMMUNITY_POST (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  product_id  BIGINT       NOT NULL              COMMENT 'FK 커뮤니티 상품(TB_PRODUCT type=community)',
  category_id BIGINT           NULL              COMMENT 'FK(TB_COMMUNITY_CATEGORY)',
  user_id     BIGINT       NOT NULL              COMMENT 'FK 작성자(TB_USER)',
  subject     VARCHAR(255)     NULL              COMMENT '제목',
  content     TEXT             NULL              COMMENT '내용',
  is_notice   TINYINT      NOT NULL DEFAULT 0    COMMENT '공지',
  is_secret   TINYINT      NOT NULL DEFAULT 0    COMMENT '비밀글',
  hit_cnt     INT          NOT NULL DEFAULT 0    COMMENT '조회수',
  comm_cnt    INT          NOT NULL DEFAULT 0    COMMENT '댓글수',
  recomm_cnt  INT          NOT NULL DEFAULT 0    COMMENT '추천수',
  report_cnt  INT          NOT NULL DEFAULT 0    COMMENT '신고수',
  file_cnt    INT          NOT NULL DEFAULT 0    COMMENT '첨부수',
  is_display  TINYINT      NOT NULL DEFAULT 1    COMMENT '노출여부',
  sort        INT              NULL DEFAULT 1    COMMENT '순서',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1공개 0비공개 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_community_post_product (product_id, created_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프리미엄 커뮤니티 게시물(별도)';

CREATE TABLE TB_COMMUNITY_COMMENT (
  id                BIGINT     NOT NULL AUTO_INCREMENT,
  community_post_id BIGINT     NOT NULL           COMMENT 'FK 커뮤니티 게시물',
  parent_id         BIGINT         NULL DEFAULT 0 COMMENT '답글대상',
  user_id           BIGINT     NOT NULL           COMMENT 'FK(TB_USER)',
  reply_user_id     BIGINT         NULL DEFAULT 0 COMMENT '답글대상회원',
  content           MEDIUMTEXT     NULL           COMMENT '내용',
  status            INT        NOT NULL DEFAULT 1 COMMENT '1정상 0중지 -1삭제',
  created_at        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_community_comment_post (community_post_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프리미엄 커뮤니티 댓글(별도)';

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
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='강사/관리자 공지';

CREATE TABLE TB_ADMIN_NOTICE_READ (
  id              BIGINT   NOT NULL AUTO_INCREMENT,
  admin_notice_id BIGINT   NOT NULL,
  user_id         BIGINT   NOT NULL,
  read_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status          INT      NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_noticeread (admin_notice_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='공지 읽음 처리';

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
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트 푸터';

CREATE TABLE TB_SITE_META (
  id         BIGINT      NOT NULL AUTO_INCREMENT,
  meta_key   VARCHAR(64) NOT NULL,
  meta_value TEXT            NULL,
  status     INT         NOT NULL DEFAULT 1       COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='배너';

-- =====================================================================
--  끝. 테넌트 92개 테이블.
--  (Round1 교정 반영: TB_REVIEW 추가, 토큰/코드 해시, 정산프로필 소유자, 유니크/인덱스 보강)
--  (Round2: 게시판류=범용 엔진(TB_BOARD/POST/COMMENT/FILE/BOARD_CATEGORY, module 기반)으로
--   재구성, 우리 컨벤션 변환. FAQ/INQUIRY/POST_LIKE/ATTACHMENT 흡수. 프리미엄 커뮤니티는 별도(TB_COMMUNITY_*).)
--  (Round3: TB_OAUTH_CONFIG 추가 — 소셜 OAuth 자격증명을 테넌트 스키마 테이블에 저장(provider당 1행,
--   client_secret/privateKey는 AES-GCM 암호문). 전역 Worker 시크릿이 아닌 테넌트별 저장이 정본.)
-- =====================================================================
