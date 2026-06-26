-- WBS 책임(responsible) 컬럼 추가 — 담당(owner=실무자/에이전트)과 별도.
-- 적용: wrangler d1 execute solsol-project --remote --file=server/db/migrations/0004_wbs_responsible.sql
ALTER TABLE wbs_item ADD COLUMN responsible text;
UPDATE wbs_item SET responsible = owner WHERE responsible IS NULL OR responsible = '';
