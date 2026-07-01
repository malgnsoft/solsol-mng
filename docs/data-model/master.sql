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

-- 플랫폼 계정 — 셀러(크리에이터) + 운영자(쏠쏠 직원) 통합. user_type으로 구분
CREATE TABLE TB_USER (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  user_type     VARCHAR(12)  NOT NULL                COMMENT 'seller(크리에이터)/admin(플랫폼 운영자)',
  email         VARCHAR(255) NOT NULL                COMMENT '플랫폼 로그인 ID',
  name          VARCHAR(50)  NOT NULL,
  phone         VARCHAR(20)      NULL,
  role          VARCHAR(20)      NULL                COMMENT '운영자 역할(user_type=admin): superadmin/admin/support',
  last_login_at TIMESTAMP         NULL,
  status        INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_email (email),
  KEY idx_user_type (user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플랫폼 계정(셀러+운영자 통합)';

-- 플랫폼 계정 자격증명 (ID+PW)
CREATE TABLE TB_USER_CREDENTIAL (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  user_id             BIGINT       NOT NULL,
  password_hash       VARCHAR(255) NOT NULL              COMMENT '3종 8~16자(C-3) 해시',
  password_updated_at TIMESTAMP         NULL,
  two_factor_email    TINYINT      NOT NULL DEFAULT 0,
  status              INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_usercred_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플랫폼 계정 자격증명';

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
  credit_charge_id BIGINT            NULL,
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
  KEY idx_payment_credit_charge (credit_charge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS/크레딧 결제(토스)';

-- 크레딧 잔액 (테넌트별) — 플랫폼이 크리에이터에게 판매
CREATE TABLE TB_CREDIT_ACCOUNT (
  id         BIGINT        NOT NULL AUTO_INCREMENT,
  site_id  BIGINT        NOT NULL,
  balance    DECIMAL(18,6) NOT NULL DEFAULT 0,
  status     INT           NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_credit_site (site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크레딧 잔액(테넌트별)';

-- 크레딧 충전 내역
CREATE TABLE TB_CREDIT_CHARGE (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  site_id     BIGINT        NOT NULL,
  payment_id    BIGINT            NULL              COMMENT '충전 결제(TB_PAYMENT)',
  charge_amount DECIMAL(18,6) NOT NULL,
  bonus_amount  DECIMAL(18,6) NOT NULL DEFAULT 0,
  pay_price    DECIMAL(18,6) NOT NULL              COMMENT '결제 금액(VAT 별도)',
  product_label VARCHAR(50)       NULL,
  expires_at    TIMESTAMP      NOT NULL              COMMENT '충전+1년 소멸',
  cancel_state  VARCHAR(12)   NOT NULL DEFAULT 'none' COMMENT 'none/canceled(7일내)',
  canceled_at   TIMESTAMP          NULL,
  status        INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_creditcharge_site (site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크레딧 충전 내역';

-- 크레딧 차감 원장(종량제·멱등 — M-3)
CREATE TABLE TB_CREDIT_LEDGER (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  site_id       BIGINT        NOT NULL,
  direction       VARCHAR(10)   NOT NULL             COMMENT 'debit/refund',
  reason          VARCHAR(30)   NOT NULL             COMMENT 'campaign_send/ai_tutor/ai_translate/ai_caption',
  unit_count      DECIMAL(18,6) NOT NULL,
  unit_price      DECIMAL(18,6)     NULL             COMMENT '단가 — config 참조(M-3 Open)',
  amount          DECIMAL(18,6) NOT NULL,
  balance_after   DECIMAL(18,6)     NULL,
  idempotency_key VARCHAR(100)  NOT NULL,
  ledger_state    VARCHAR(12)   NOT NULL DEFAULT 'pending' COMMENT 'pending/settled/refunded',
  ref_type        VARCHAR(20)       NULL             COMMENT 'campaign/ai_job (테넌트 스키마 리소스)',
  ref_id          BIGINT            NULL,
  status          INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_ledger_idem (site_id, idempotency_key),
  KEY idx_ledger_site (site_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크레딧 차감 원장(종량제)';

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

-- =====================================================================
--  끝. 마스터 14개 테이블.
-- =====================================================================
