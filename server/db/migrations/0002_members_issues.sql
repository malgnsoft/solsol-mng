-- 참여자(member) + 이슈 게시판(issue, issue_comment) 신설 + 현황판(board) 제거.
-- drizzle-kit 비대화형 generate 가 막혀 직접 작성 — 원격 D1 에 직접 execute 로 적용:
--   wrangler d1 execute solsol-project --remote --file=server/db/migrations/0002_members_issues.sql
-- 스키마 정본은 server/db/schema.ts.

-- ── 현황판(board) 제거 ──
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS stage;
DROP TABLE IF EXISTS board_meta;

-- ── 참여자(회원) ──
CREATE TABLE IF NOT EXISTS member (
  id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  login_id text NOT NULL,
  password_hash text,
  name text NOT NULL,
  company text DEFAULT '' NOT NULL,
  role text DEFAULT '' NOT NULL,
  grade text DEFAULT 'member' NOT NULL,
  email text DEFAULT '' NOT NULL,
  phone text DEFAULT '' NOT NULL,
  source text DEFAULT 'direct' NOT NULL,
  office_id text,
  status text DEFAULT 'pending' NOT NULL,
  agreed_at text,
  created_at text NOT NULL,
  updated_at text
);
CREATE UNIQUE INDEX IF NOT EXISTS member_login_id_unique ON member (login_id);
CREATE UNIQUE INDEX IF NOT EXISTS member_office_id_unique ON member (office_id);

-- ── 이슈 게시판 ──
CREATE TABLE IF NOT EXISTS issue (
  id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  type text DEFAULT 'issue' NOT NULL,
  title text NOT NULL,
  body text DEFAULT '' NOT NULL,
  status text DEFAULT 'open' NOT NULL,
  priority text,
  author_id integer NOT NULL,
  author_name text DEFAULT '' NOT NULL,
  created_at text NOT NULL,
  updated_at text
);
CREATE INDEX IF NOT EXISTS idx_issue_status ON issue (status);
CREATE INDEX IF NOT EXISTS idx_issue_type ON issue (type);
CREATE INDEX IF NOT EXISTS idx_issue_updated_at ON issue (updated_at);

-- ── 이슈 답글(댓글) ──
CREATE TABLE IF NOT EXISTS issue_comment (
  id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
  issue_id integer NOT NULL,
  body text DEFAULT '' NOT NULL,
  author_id integer NOT NULL,
  author_name text DEFAULT '' NOT NULL,
  created_at text NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_issue_comment_issue ON issue_comment (issue_id);
