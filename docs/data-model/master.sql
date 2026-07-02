-- =====================================================================
--  쏠쏠 크리에이터 LMS — 마스터(플랫폼 관리) 스키마 (Aurora MySQL 8.0)
--  schema-per-tenant 아키텍처의 중앙 통제 DB. 스키마명(기본): solsol_master
--  플랫폼 ↔ 크리에이터(테넌트) 관계 데이터만 보관.
--  각 크리에이터 운영 데이터는 tenant_template.sql(테넌트별 개별 스키마) 참조.
-- ---------------------------------------------------------------------
--  컨벤션: TB_ 단수 / id BIGINT AUTO_INCREMENT PK / status INT(1정상 0중지 -1삭제)
--          금액·크레딧 DECIMAL(18,6) / TIMESTAMP UTC + created_at·updated_at 기본시
--          약한 FK(네이밍+인덱스, DB제약 미설정) / utf8mb4_unicode_ci
--  ※ site_id = TB_SITE.id 참조(테넌트 스코프 행). 크로스스키마 참조는 논리 FK.
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';


-- 크리에이터 사이트(테넌트) 레지스트리 — 스키마 라우팅의 정본
CREATE TABLE TB_SITE (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  slug            VARCHAR(50)  NOT NULL                COMMENT '식별 슬러그(불변 권장)',
  schema_name     VARCHAR(64)  NOT NULL                COMMENT '테넌트 DB(스키마)명. 예: solsol_t000123',
  domain          VARCHAR(255)     NULL                COMMENT '연결 도메인(커스텀/서브도메인)',
  name            VARCHAR(100) NOT NULL                COMMENT '사이트/브랜드명',
  owner_user_id BIGINT       NOT NULL                COMMENT '소유 셀러(TB_USER user_type=seller)',
  plan_id         BIGINT           NULL                COMMENT '현재 SaaS 요금제(TB_PLAN)',
  plan_state      VARCHAR(12)  NOT NULL DEFAULT 'active' COMMENT 'active/grace/expired/canceled',
  provisioned_at  TIMESTAMP         NULL                COMMENT '테넌트 스키마 생성 완료 시각',
  status          INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지(정지) -1삭제',
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_site_slug (slug),
  UNIQUE KEY uk_site_schema (schema_name),
  UNIQUE KEY uk_site_domain (domain),
  KEY idx_site_owner (owner_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크리에이터 사이트(테넌트) 레지스트리';

-- 플랫폼 계정 — 셀러(크리에이터) + 운영자(쏠쏠 직원) 통합. user_type으로 구분. ID/PW 인라인.
CREATE TABLE TB_USER (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  user_type           VARCHAR(12)  NOT NULL              COMMENT 'seller(크리에이터)/admin(플랫폼 운영자)',
  login_id            VARCHAR(255) NOT NULL              COMMENT '플랫폼 로그인 아이디',
  email               VARCHAR(255) NOT NULL              COMMENT '이메일(연락)',
  password_hash       VARCHAR(255) NOT NULL              COMMENT '비밀번호 해시(3종 8~16자 C-3, bcrypt/argon2id). 응답 미포함',
  password_updated_at TIMESTAMP         NULL,
  two_factor_email    TINYINT      NOT NULL DEFAULT 0    COMMENT '이메일 2단계 인증',
  name                VARCHAR(50)  NOT NULL,
  phone               VARCHAR(20)      NULL,
  role                VARCHAR(20)      NULL              COMMENT '운영자 역할(user_type=admin): superadmin/admin/support',
  last_login_at       TIMESTAMP         NULL,
  status              INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_login_id (login_id),
  UNIQUE KEY uk_user_email (email),
  KEY idx_user_type (user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플랫폼 계정(셀러+운영자 통합, ID/PW 인라인)';

-- 플랫폼 계정 이용약관 동의 기록 (동의 이력 — 버전·시점 보존)
CREATE TABLE TB_USER_AGREEMENT (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  user_id       BIGINT       NOT NULL,
  agreement_key VARCHAR(20)  NOT NULL              COMMENT 'terms/privacy/marketing 등',
  required      TINYINT      NOT NULL DEFAULT 1    COMMENT '필수(1)/선택(0)',
  agreed        TINYINT      NOT NULL DEFAULT 0    COMMENT '동의(1)/철회(0)',
  terms_version VARCHAR(20)      NULL              COMMENT '동의 당시 약관 버전',
  agreed_at     TIMESTAMP        NULL              COMMENT '동의/철회 시각',
  status        INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_useragr_user (user_id, agreement_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플랫폼 계정 약관 동의 기록';

-- 플랫폼 계정 로그인/로그아웃 이력 (감사·부정로그인 추적, append-only)
CREATE TABLE TB_LOGIN_LOG (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  user_id     BIGINT           NULL              COMMENT '로그인 시도 계정(TB_USER). 실패로 미식별 시 NULL 가능',
  login_id    VARCHAR(255)     NULL              COMMENT '시도한 로그인 아이디(실패 추적용)',
  event       VARCHAR(12)  NOT NULL              COMMENT 'login/logout/login_fail',
  fail_reason VARCHAR(100)     NULL              COMMENT '실패 사유(login_fail)',
  ip_addr     VARCHAR(64)      NULL              COMMENT '접속주소',
  user_agent  VARCHAR(500)     NULL              COMMENT '접속환경',
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '발생 시각',
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_loginlog_user (user_id, created_at),
  KEY idx_loginlog_event (event, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플랫폼 계정 로그인/로그아웃 이력';

-- 사이트 ↔ 회원 권한 배정 (N:M) — 소유자·담당자 통일
--   owner  = 사이트 생성자(TB_SITE.owner_user_id)를 생성 시 자동 배정. 자기 생성 사이트 전체 권한
--   manager= 특정 사이트에 배정된 담당자. 배정된 사이트만 권한
--   권한체크 = 이 테이블에 (site_id, user_id) 배정이 존재하는가
CREATE TABLE TB_SITE_USER (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  site_id    BIGINT       NOT NULL              COMMENT '대상 사이트(TB_SITE)',
  user_id    BIGINT       NOT NULL              COMMENT '배정 회원(TB_USER)',
  role       VARCHAR(12)  NOT NULL DEFAULT 'manager' COMMENT 'owner(생성자)/manager(담당자)',
  status     INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_siteuser (site_id, user_id),
  KEY idx_siteuser_user (user_id),
  KEY idx_siteuser_site (site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사이트-회원 권한 배정(소유자/담당자)';

-- SaaS 요금제 — Free 즉시부여 + 유료(무료체험 미운영 M-1)
CREATE TABLE TB_PLAN (
  id             BIGINT        NOT NULL AUTO_INCREMENT,
  code           VARCHAR(20)   NOT NULL              COMMENT 'free/basic/growth/advanced/enterprise',
  name           VARCHAR(50)   NOT NULL,
  monthly_price  DECIMAL(18,6) NOT NULL DEFAULT 0,
  yearly_price   DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '연 30% 할인 일괄',
  sales_fee_rate DECIMAL(18,6)     NULL              COMMENT '플랜별 판매수수료율',
  member_limit   INT               NULL,
  storage_limit  DECIMAL(18,6)     NULL,
  status         INT           NOT NULL DEFAULT 1    COMMENT '1판매중 0숨김 -1삭제',
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_plan_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS 요금제';

-- 셀러 SaaS 구독 (플랫폼 ↔ 크리에이터)
CREATE TABLE TB_SUBSCRIPTION (
  id                   BIGINT        NOT NULL AUTO_INCREMENT,
  site_id            BIGINT        NOT NULL,
  user_id            BIGINT        NOT NULL,
  plan_id              BIGINT        NOT NULL,
  billing_cycle        INT           NOT NULL DEFAULT 1   COMMENT '1=monthly/2=yearly',
  unit_price           DECIMAL(18,6) NOT NULL,
  billing_key_id       BIGINT            NULL,
  current_period_start TIMESTAMP      NOT NULL,
  current_period_end   TIMESTAMP      NOT NULL,
  next_billing_at      TIMESTAMP          NULL,
  cancel_scheduled     TINYINT       NOT NULL DEFAULT 0,
  canceled_at          TIMESTAMP          NULL,
  started_at           TIMESTAMP          NULL,
  grace_until          TIMESTAMP          NULL,
  sub_state            VARCHAR(12)   NOT NULL DEFAULT 'active' COMMENT 'active/grace/expired/canceled',
  status               INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at           TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sub_site (site_id),
  KEY idx_sub_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='셀러 SaaS 구독';

-- 셀러 빌링키(토스) — SaaS 정기결제 카드
CREATE TABLE TB_BILLING_KEY (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  user_id        BIGINT       NOT NULL,
  toss_billing_key VARCHAR(255) NOT NULL              COMMENT '토스 빌링키(AES-256-GCM 암호화 저장·키는 KMS/wrangler secret·응답 미포함)',
  card_company     VARCHAR(50)      NULL,
  card_type        VARCHAR(20)      NULL,
  card_last4       VARCHAR(4)   NOT NULL,
  is_default       TINYINT      NOT NULL DEFAULT 0,
  registered_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_billing_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='셀러 빌링키(SaaS)';

-- SaaS 정기결제 청구서
CREATE TABLE TB_INVOICE (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  subscription_id   BIGINT        NOT NULL,
  site_id         BIGINT        NOT NULL,
  period_start      TIMESTAMP      NOT NULL,
  period_end        TIMESTAMP      NOT NULL,
  pay_price            DECIMAL(18,6) NOT NULL,
  vat_price               DECIMAL(18,6) NOT NULL DEFAULT 0,
  unpaid_carryover_price  DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '미납 이월액',
  billing_due_at    TIMESTAMP      NOT NULL,
  retry_count       INT           NOT NULL DEFAULT 0,
  paid_payment_id   BIGINT            NULL,
  issued_at         TIMESTAMP          NULL              COMMENT '청구 발행 시각',
  paid_at           TIMESTAMP          NULL              COMMENT '납부 완료 시각',
  invoice_state     VARCHAR(10)   NOT NULL DEFAULT 'open' COMMENT 'open/paying/paid/failed/grace/void',
  status            INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_invoice_sub (subscription_id),
  KEY idx_invoice_site (site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS 정기결제 청구서';

-- SaaS/크레딧 결제(토스)
CREATE TABLE TB_PAYMENT (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  site_id        BIGINT        NOT NULL,
  ref_type         VARCHAR(20)   NOT NULL DEFAULT 'saas' COMMENT 'saas(구독)/credit(크레딧충전)',
  invoice_id       BIGINT            NULL,
  credit_id BIGINT            NULL              COMMENT '크레딧 충전 원장행(TB_CREDIT entry_type=charge)',
  toss_payment_key VARCHAR(255)      NULL,
  toss_order_id    VARCHAR(64)       NULL,
  approve_no       VARCHAR(64)       NULL,
  card_company     VARCHAR(50)       NULL,
  card_last4       VARCHAR(4)        NULL,
  pay_price           DECIMAL(18,6) NOT NULL,
  fail_code        VARCHAR(50)       NULL,
  fail_message     VARCHAR(255)      NULL,
  approved_at      TIMESTAMP          NULL,
  pay_state        VARCHAR(15)   NOT NULL DEFAULT 'ready' COMMENT 'ready/approved/failed/canceled/partial_canceled',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_payment_toss_key (toss_payment_key),
  KEY idx_payment_site (site_id),
  KEY idx_payment_credit (credit_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS/크레딧 결제(토스)';

-- 크레딧 잔액 = TB_CREDIT에서 파생(별도 캐시 테이블 없음)
--   전체잔액   = 최신 행 balance_after_cr (idx_credit_site_created 로 O(1))
--   expiring/permanent = SUM(remaining_cr) WHERE lot_state='open' GROUP BY is_expiring
--   next_expire = MIN(expires_at) WHERE lot_state='open' AND is_expiring=1
--   (읽기 성능이 문제되면 그때 캐시 재도입 — 지금은 원장 단일 정본 유지)

-- 크레딧 통장식 단일 원장(단일 테이블) — 증가(lot)·차감을 시간순 적재
--   증가행(charge/bonus/refund_restore): lot 역할. remaining_cr(사용 후 남은 크레딧)/expires_at/is_expiring 보유
--   차감행(usage/expire/adjust): FIFO(임박 만료 우선)로 증가행 remaining_cr 차감 + source_credit_id 로 소진 lot 기록
--     (한 사용이 여러 lot에 걸치면 lot별로 차감행 분할 → 각 행이 자기 lot 참조 = 단일 테이블로 감사추적)
--   멱등 uk(uk_credit_idem) = (site_id, idempotency_key, source_credit_key). source_credit_key = COALESCE(source_credit_id,0) STORED 파생:
--     증가행은 source_credit_id=NULL→0 으로 병합돼 동일 idempotency_key 중복충전을 DB가 차단, 분할 차감행은 lot(source_credit_id)별로 공존.
CREATE TABLE TB_CREDIT (
  id                 BIGINT        NOT NULL AUTO_INCREMENT,
  site_id            BIGINT        NOT NULL,
  entry_type         VARCHAR(16)   NOT NULL             COMMENT 'charge/bonus/refund_restore(증가) · usage/expire/adjust(차감)',
  direction          VARCHAR(6)    NOT NULL             COMMENT 'credit(증가)/debit(감소) — entry_type 파생',
  reason             VARCHAR(30)       NULL             COMMENT 'campaign_send/ai_tutor/ai_translate/ai_caption/promotion/manual',
  amount_cr             DECIMAL(18,6) NOT NULL             COMMENT '변동량(절대값, 양수). 방향은 direction',
  balance_after_cr      DECIMAL(18,6) NOT NULL             COMMENT '이 거래 직후 전체 잔액(통장 잔고)',
  is_expiring        TINYINT       NOT NULL DEFAULT 1   COMMENT '증가행: 1=유효기간 있음/0=무기한',
  expires_at         TIMESTAMP         NULL             COMMENT 'lot 만료 시각(UTC). NULL=무기한. 증가행 전용',
  remaining_cr          DECIMAL(18,6)     NULL             COMMENT 'lot 잔여량(증가행 전용). 소진될수록 감소',
  lot_state          VARCHAR(12)       NULL             COMMENT 'lot 상태(증가행): open/pending/exhausted/expired/canceled',
  payment_id         BIGINT            NULL             COMMENT '유상 충전행 ↔ TB_PAYMENT(논리 FK)',
  pay_price          DECIMAL(18,6)     NULL             COMMENT '결제 금액(VAT 별도) — charge 증가행',
  product_label      VARCHAR(50)       NULL             COMMENT '충전 상품 라벨',
  unit_count         DECIMAL(18,6)     NULL             COMMENT '사용량(발송건수/토큰) — usage행',
  unit_price         DECIMAL(18,6)     NULL             COMMENT '단가(config, M-3 Open) — usage행',
  source_credit_id   BIGINT            NULL             COMMENT '차감/만료행이 소진한 증가lot 원장행(charge/bonus). 여러 lot 걸치면 lot별 차감행 분할',
  source_credit_key  BIGINT        GENERATED ALWAYS AS (COALESCE(source_credit_id,0)) STORED COMMENT '멱등 uk 파생키: 증가행 NULL→0 병합(동일 idempotency_key 중복충전 차단)·차감행은 lot별 구분',
  reverses_credit_id BIGINT            NULL             COMMENT '환불/취소가 되돌리는 원본 원장 행',
  ref_type           VARCHAR(20)       NULL             COMMENT 'campaign/ai_job (테넌트 스키마 리소스)',
  ref_id             BIGINT            NULL,
  idempotency_key    VARCHAR(100)  NOT NULL             COMMENT '증가/차감 중복 방지(uk). lot 분할 차감은 source_credit_id로 구분',
  credit_state       VARCHAR(12)   NOT NULL DEFAULT 'settled' COMMENT 'pending/settled/refunded/void',
  memo               VARCHAR(255)      NULL,
  status             INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_credit_idem (site_id, idempotency_key, source_credit_key),
  KEY idx_credit_site_created (site_id, id),
  KEY idx_credit_lot_fifo (site_id, is_expiring, expires_at, id),
  KEY idx_credit_open_lot (site_id, lot_state, expires_at),
  KEY idx_credit_payment (payment_id),
  KEY idx_credit_source (source_credit_id),
  KEY idx_credit_ref (ref_type, ref_id),
  KEY idx_credit_reverses (reverses_credit_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크레딧 통장식 단일 원장(증가lot/차감·source_credit_id·remaining_cr·멱등)';

-- 토스 웹훅 수신 로그(멱등) — SaaS/크레딧 결제
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS/크레딧 결제 웹훅 수신 로그(멱등)';

-- 테넌트 프로비저닝 이력
CREATE TABLE TB_SITE_PROVISION_LOG (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  site_id   BIGINT       NOT NULL,
  action      VARCHAR(20)  NOT NULL              COMMENT 'create/migrate/suspend/delete',
  schema_name VARCHAR(64)      NULL,
  detail      VARCHAR(255)     NULL,
  ok          TINYINT      NOT NULL DEFAULT 1,
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_provlog_site (site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='테넌트 프로비저닝 이력';

-- ---------------------------------------------------------------------
--  2026-07-01 추가 — 쏠쏠 브랜드(플랫폼 공개 사이트) 문의·소식
--    브랜드 목업의 문의(contact)·소식(news) 화면 저장소. 플랫폼 레벨(테넌트 무관)이라 마스터에 둠.
--    TB_CONTACT(문의) 1:N TB_CONTACT_REPLY(답변 스레드) · TB_NEWS(공지/소식 — 공개 읽기).
-- ---------------------------------------------------------------------

-- 브랜드 문의 — 방문자/셀러의 상품·결제·제휴·서비스 문의(1:N 답변)
CREATE TABLE TB_CONTACT (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  user_id       BIGINT           NULL              COMMENT '작성 계정(TB_USER). 비로그인 문의 시 NULL 가능',
  type          VARCHAR(20)  NOT NULL              COMMENT '문의 유형: product(상품)/payment(결제)/partnership(제휴)/service(서비스)/etc(기타)',
  subtype       VARCHAR(30)      NULL              COMMENT '세부 유형(유형별 하위 분류)',
  title         VARCHAR(200) NOT NULL              COMMENT '문의 제목',
  content       TEXT         NOT NULL              COMMENT '문의 내용',
  files_json    TEXT             NULL              COMMENT '첨부 파일 메타(JSON 배열: name/r2_key/size 등)',
  contact_state VARCHAR(12)  NOT NULL DEFAULT 'open' COMMENT 'open(접수)/answered(답변완료)/closed(종료)',
  answered_at   TIMESTAMP        NULL              COMMENT '최초 답변 완료 시각',
  status        INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_contact_user (user_id),
  KEY idx_contact_state (contact_state, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='브랜드 문의(상품/결제/제휴/서비스/기타)';

-- 브랜드 문의 답변 스레드 — 문의 1건에 대한 사용자/관리자 답변(시간순)
CREATE TABLE TB_CONTACT_REPLY (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  contact_id     BIGINT       NOT NULL              COMMENT '대상 문의(TB_CONTACT)',
  writer_type    VARCHAR(10)  NOT NULL              COMMENT 'user(문의자)/admin(운영자)',
  writer_user_id BIGINT           NULL              COMMENT '작성 계정(TB_USER). 비로그인/시스템 시 NULL 가능',
  content        TEXT         NOT NULL              COMMENT '답변 내용',
  status         INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_contact_reply_contact (contact_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='브랜드 문의 답변 스레드';

-- 브랜드 소식 — 공지/업데이트/점검(공개 읽기)
CREATE TABLE TB_NEWS (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  category     VARCHAR(20)  NOT NULL              COMMENT 'notice(공지)/update(업데이트)/maintenance(점검)',
  title        VARCHAR(200) NOT NULL              COMMENT '소식 제목',
  content      TEXT         NOT NULL              COMMENT '소식 본문',
  published_at TIMESTAMP        NULL              COMMENT '공개(게시) 시각. NULL=미공개(초안)',
  status       INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_news_category (category, published_at),
  KEY idx_news_published (published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='브랜드 소식(공지/업데이트/점검, 공개 읽기)';

-- =====================================================================
--  끝. 마스터 16개 테이블.
-- =====================================================================
