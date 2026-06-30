-- =====================================================================
--  쏠쏠 크리에이터 LMS — 마스터(플랫폼 관리) 스키마 (Aurora MySQL 8.0)
--  schema-per-tenant 아키텍처의 중앙 통제 DB. 스키마명(기본): solsol_master
--  플랫폼 ↔ 크리에이터(테넌트) 관계 데이터만 보관.
--  각 크리에이터 운영 데이터는 tenant_template.sql(테넌트별 개별 스키마) 참조.
-- ---------------------------------------------------------------------
--  컨벤션: TB_ 단수 / id BIGINT AUTO_INCREMENT PK / status INT(1정상 0중지 -1삭제)
--          금액·크레딧 DECIMAL(18,6) / DATETIME UTC + created_at·updated_at 기본시
--          약한 FK(네이밍+인덱스, DB제약 미설정) / utf8mb4_unicode_ci
--  ※ tenant_id = TB_TENANT.id 참조(테넌트 스코프 행). 크로스스키마 참조는 논리 FK.
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';


-- 크리에이터 사이트(테넌트) 레지스트리 — 스키마 라우팅의 정본
CREATE TABLE TB_TENANT (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  slug            VARCHAR(50)  NOT NULL                COMMENT '식별 슬러그(불변 권장)',
  schema_name     VARCHAR(64)  NOT NULL                COMMENT '테넌트 DB(스키마)명. 예: solsol_t000123',
  domain          VARCHAR(255)     NULL                COMMENT '연결 도메인(커스텀/서브도메인)',
  name            VARCHAR(100) NOT NULL                COMMENT '사이트/브랜드명',
  owner_seller_id BIGINT       NOT NULL                COMMENT '소유 크리에이터(TB_SELLER)',
  plan_id         BIGINT           NULL                COMMENT '현재 SaaS 요금제(TB_PLAN)',
  plan_state      VARCHAR(12)  NOT NULL DEFAULT 'active' COMMENT 'active/grace/expired/canceled',
  provisioned_at  DATETIME         NULL                COMMENT '테넌트 스키마 생성 완료 시각',
  status          INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지(정지) -1삭제',
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_tenant_slug (slug),
  UNIQUE KEY uk_tenant_schema (schema_name),
  UNIQUE KEY uk_tenant_domain (domain),
  KEY idx_tenant_owner (owner_seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크리에이터 사이트(테넌트) 레지스트리';

-- 크리에이터(셀러) — 플랫폼 레벨 소유자 계정
CREATE TABLE TB_SELLER (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  email         VARCHAR(255) NOT NULL                COMMENT '플랫폼 로그인 ID',
  name          VARCHAR(50)  NOT NULL,
  phone         VARCHAR(20)      NULL,
  last_login_at DATETIME         NULL,
  status        INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_seller_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크리에이터(셀러) 플랫폼 계정';

-- 셀러 자격증명 (ID+PW)
CREATE TABLE TB_SELLER_CREDENTIAL (
  id                  BIGINT       NOT NULL AUTO_INCREMENT,
  seller_id           BIGINT       NOT NULL,
  password_hash       VARCHAR(255) NOT NULL              COMMENT '3종 8~16자(C-3) 해시',
  password_updated_at DATETIME         NULL,
  two_factor_email    TINYINT      NOT NULL DEFAULT 0,
  status              INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sellercred_seller (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='셀러 자격증명';

-- 플랫폼 운영자 (쏠쏠 직원/슈퍼관리자)
CREATE TABLE TB_PLATFORM_ADMIN (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  email         VARCHAR(255) NOT NULL,
  name          VARCHAR(50)  NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role          VARCHAR(20)  NOT NULL DEFAULT 'admin' COMMENT 'superadmin/admin/support',
  last_login_at DATETIME         NULL,
  status        INT          NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_padmin_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플랫폼 운영자';

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
  created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_plan_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS 요금제';

-- 셀러 SaaS 구독 (플랫폼 ↔ 크리에이터)
CREATE TABLE TB_SUBSCRIPTION (
  id                   BIGINT        NOT NULL AUTO_INCREMENT,
  tenant_id            BIGINT        NOT NULL,
  seller_id            BIGINT        NOT NULL,
  plan_id              BIGINT        NOT NULL,
  billing_cycle        INT           NOT NULL DEFAULT 1   COMMENT '1=monthly/2=yearly',
  unit_price           DECIMAL(18,6) NOT NULL,
  billing_key_id       BIGINT            NULL,
  current_period_start DATETIME      NOT NULL,
  current_period_end   DATETIME      NOT NULL,
  next_billing_at      DATETIME          NULL,
  cancel_scheduled     TINYINT       NOT NULL DEFAULT 0,
  canceled_at          DATETIME          NULL,
  started_at           DATETIME          NULL,
  grace_until          DATETIME          NULL,
  sub_state            VARCHAR(12)   NOT NULL DEFAULT 'active' COMMENT 'active/grace/expired/canceled',
  status               INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sub_tenant (tenant_id),
  KEY idx_sub_seller (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='셀러 SaaS 구독';

-- 셀러 빌링키(토스) — SaaS 정기결제 카드
CREATE TABLE TB_BILLING_KEY (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  seller_id        BIGINT       NOT NULL,
  toss_billing_key VARCHAR(255) NOT NULL              COMMENT '토스 빌링키(AES-256-GCM 암호화 저장·키는 KMS/wrangler secret·응답 미포함)',
  card_company     VARCHAR(50)      NULL,
  card_type        VARCHAR(20)      NULL,
  card_last4       VARCHAR(4)   NOT NULL,
  is_default       TINYINT      NOT NULL DEFAULT 0,
  registered_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status           INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_billing_seller (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='셀러 빌링키(SaaS)';

-- SaaS 정기결제 청구서
CREATE TABLE TB_INVOICE (
  id                BIGINT        NOT NULL AUTO_INCREMENT,
  subscription_id   BIGINT        NOT NULL,
  tenant_id         BIGINT        NOT NULL,
  period_start      DATETIME      NOT NULL,
  period_end        DATETIME      NOT NULL,
  amount            DECIMAL(18,6) NOT NULL,
  vat               DECIMAL(18,6) NOT NULL DEFAULT 0,
  unpaid_carryover  DECIMAL(18,6) NOT NULL DEFAULT 0   COMMENT '미납 이월액',
  billing_due_at    DATETIME      NOT NULL,
  retry_count       INT           NOT NULL DEFAULT 0,
  paid_payment_id   BIGINT            NULL,
  issued_at         DATETIME          NULL              COMMENT '청구 발행 시각',
  paid_at           DATETIME          NULL              COMMENT '납부 완료 시각',
  invoice_state     VARCHAR(10)   NOT NULL DEFAULT 'open' COMMENT 'open/paying/paid/failed/grace/void',
  status            INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_invoice_sub (subscription_id),
  KEY idx_invoice_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS 정기결제 청구서';

-- SaaS/크레딧 결제(토스)
CREATE TABLE TB_PAYMENT (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  tenant_id        BIGINT        NOT NULL,
  ref_type         VARCHAR(20)   NOT NULL DEFAULT 'saas' COMMENT 'saas(구독)/credit(크레딧충전)',
  invoice_id       BIGINT            NULL,
  credit_charge_id BIGINT            NULL,
  toss_payment_key VARCHAR(255)      NULL,
  toss_order_id    VARCHAR(64)       NULL,
  approve_no       VARCHAR(64)       NULL,
  card_company     VARCHAR(50)       NULL,
  card_last4       VARCHAR(4)        NULL,
  amount           DECIMAL(18,6) NOT NULL,
  fail_code        VARCHAR(50)       NULL,
  fail_message     VARCHAR(255)      NULL,
  approved_at      DATETIME          NULL,
  pay_state        VARCHAR(15)   NOT NULL DEFAULT 'ready' COMMENT 'ready/approved/failed/canceled/partial_canceled',
  status           INT           NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_payment_toss_key (toss_payment_key),
  KEY idx_payment_tenant (tenant_id),
  KEY idx_payment_credit_charge (credit_charge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS/크레딧 결제(토스)';

-- 크레딧 잔액 (테넌트별) — 플랫폼이 크리에이터에게 판매
CREATE TABLE TB_CREDIT_ACCOUNT (
  id         BIGINT        NOT NULL AUTO_INCREMENT,
  tenant_id  BIGINT        NOT NULL,
  balance    DECIMAL(18,6) NOT NULL DEFAULT 0,
  status     INT           NOT NULL DEFAULT 1      COMMENT '1정상 0중지 -1삭제',
  created_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_credit_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크레딧 잔액(테넌트별)';

-- 크레딧 충전 내역
CREATE TABLE TB_CREDIT_CHARGE (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  tenant_id     BIGINT        NOT NULL,
  payment_id    BIGINT            NULL              COMMENT '충전 결제(TB_PAYMENT)',
  charge_amount DECIMAL(18,6) NOT NULL,
  bonus_amount  DECIMAL(18,6) NOT NULL DEFAULT 0,
  pay_amount    DECIMAL(18,6) NOT NULL              COMMENT '결제 금액(VAT 별도)',
  product_label VARCHAR(50)       NULL,
  expires_at    DATETIME      NOT NULL              COMMENT '충전+1년 소멸',
  cancel_state  VARCHAR(12)   NOT NULL DEFAULT 'none' COMMENT 'none/canceled(7일내)',
  canceled_at   DATETIME          NULL,
  status        INT           NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_creditcharge_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='크레딧 충전 내역';

-- 크레딧 차감 원장(종량제·멱등 — M-3)
CREATE TABLE TB_CREDIT_LEDGER (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  tenant_id       BIGINT        NOT NULL,
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
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_ledger_idem (tenant_id, idempotency_key),
  KEY idx_ledger_tenant (tenant_id)
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
  received_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  event_state        VARCHAR(12)  NOT NULL DEFAULT 'received' COMMENT 'received/processed/duplicate/failed',
  status             INT          NOT NULL DEFAULT 1   COMMENT '1정상 0중지 -1삭제',
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_webhook_event (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SaaS/크레딧 결제 웹훅 수신 로그(멱등)';

-- 테넌트 프로비저닝 이력
CREATE TABLE TB_TENANT_PROVISION_LOG (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  tenant_id   BIGINT       NOT NULL,
  action      VARCHAR(20)  NOT NULL              COMMENT 'create/migrate/suspend/delete',
  schema_name VARCHAR(64)      NULL,
  detail      VARCHAR(255)     NULL,
  ok          TINYINT      NOT NULL DEFAULT 1,
  status      INT          NOT NULL DEFAULT 1    COMMENT '1정상 0중지 -1삭제',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_provlog_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='테넌트 프로비저닝 이력';

-- =====================================================================
--  끝. 마스터 14개 테이블.
-- =====================================================================
