-- 화면 상태에 스파이크(1차 개발/PoC) 열 추가 — 디자인 검수와 개발 사이 단계.
ALTER TABLE screen_status ADD COLUMN spike integer NOT NULL DEFAULT 0;
