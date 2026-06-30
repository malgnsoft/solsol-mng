-- 화면(/screens) 디자인 검수(review) 컬럼 + 화면별 다중 코멘트 테이블.
-- 적용: wrangler d1 execute solsol-project --remote --file=server/db/migrations/0005_screen_review_comment.sql
ALTER TABLE screen_status ADD COLUMN review integer NOT NULL DEFAULT 0;
CREATE TABLE IF NOT EXISTS screen_comment (
  id integer PRIMARY KEY AUTOINCREMENT,
  screen_id text NOT NULL,
  body text NOT NULL,
  author text NOT NULL DEFAULT '',
  created_at text NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_screen_comment_screen ON screen_comment(screen_id);
