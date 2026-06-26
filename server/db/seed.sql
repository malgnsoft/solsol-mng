-- 자동 생성 시드 (solsol-project) — 쏠쏠 프로젝트 관리
-- 회원(member) 기본 관리자 + WBS 간트(wbs_item). 이슈/댓글은 사용자 작성 데이터라 시드 없음.
-- 적용(원격): pnpm db:seed  (wrangler d1 execute solsol-project --remote --file=server/db/seed.sql)

-- ── 기본 관리자 계정 (로그인: admin / 비밀번호: solsol2026) ──
DELETE FROM member;
INSERT INTO member (id,login_id,password_hash,name,company,role,grade,email,phone,source,office_id,status,agreed_at,created_at,updated_at)
  VALUES (1,'admin','pbkdf2$100000$h8N9NWJuj0dGeTXaP1KbFg==$UKTOSQv9NcHWiMwmFVHUO9HX0o6Wg10qHwdBFeYtrBs=','관리자','맑은소프트','프로젝트 관리자','admin','','','direct',NULL,'active',NULL,'2026-06-17T00:00:00.000Z',NULL);

-- ── WBS 간트 ──
DELETE FROM wbs_item;
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (1,1,'리뷰 · 프로토타입','전체 스펙 요구사항 리뷰회의','김덕조','김덕조','2026-01-26','2026-01-30',100,NULL,NULL,0);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (2,1,'리뷰 · 프로토타입','4개 앱 프로토타입 (CA·CF·Brand·BO)','김덕조, 유회광','김덕조, 유회광','2026-01-23','2026-02-25',100,'creatorlms 프로토타입 5종',NULL,1);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (3,1,'서비스 정책','서비스 정책 확정 (회원·가격·구독·알림·저작권)','김덕조, 김혜인','김덕조, 김혜인','2026-02-03','2026-02-27',100,NULL,NULL,2);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (4,1,'서비스 정책','도메인 구조 확정 (solsol.so)','김덕조','김덕조','2026-04-15','2026-04-15',100,'CF {slug}.solsol.so · CA ceo.solsol.so · BO so.solsol.so · Brand solsol.so',NULL,3);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (5,1,'서비스 정책','BackOffice 정책 (도메인/SSL·국가/언어·AI번역·환불)','방준영, 김혜인','방준영, 김혜인','2026-03-29','2026-06-15',70,NULL,NULL,4);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (6,2,'메뉴 구조도','4개 앱 메뉴 구조도','조안이혜, 김혜인, 유회광, 김덕조','조안이혜, 김혜인, 유회광, 김덕조','2026-02-10','2026-03-13',100,NULL,NULL,5);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (7,2,'메뉴 구조도','Guide site 메뉴 구조도','방준영','방준영','2026-05-01','2026-06-26',40,NULL,NULL,6);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (8,2,'화면설계','Customer Admin 화면설계 v1.1','김혜인, 조안이혜','김혜인, 조안이혜','2026-03-16','2026-04-02',100,NULL,NULL,7);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (9,2,'화면설계','Customer Front 화면설계 v1.1','김혜인','김혜인','2026-03-04','2026-06-30',70,'v1.1 작업중',NULL,8);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (10,2,'화면설계','Brand · BackOffice · Guide 화면설계','김덕조, 유회광, 방준영','김덕조, 유회광, 방준영','2026-03-05','2026-03-20',100,NULL,NULL,9);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (11,2,'알림 · 문구','서비스/마케팅 알림 기획','김혜인, 조안이혜','김혜인, 조안이혜','2026-04-15','2026-04-25',100,NULL,NULL,10);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (12,2,'알림 · 문구','얼럿/컨펌 문구 통일','조안이혜, 김혜인','조안이혜, 김혜인','2026-04-16','2026-04-16',100,NULL,NULL,11);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (13,3,'디자인 시안','Customer Front · Brand 시안 (피그마)','전진주','전진주','2026-03-20','2026-03-25',100,NULL,NULL,12);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (14,3,'디자인 시안','Customer Admin 시안','이승미','이승미','2026-04-01','2026-06-15',60,NULL,NULL,13);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (15,3,'브랜드','브랜드 로고','방준영','방준영','2026-03-24','2026-03-25',100,NULL,NULL,14);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (200,4,'사용자단 목업(FR01)','FR 인증·가입 목업 (로그인·소셜가입·약관)','frontend-developer','김도형','2026-06-20','2026-06-24',100,'솔솔 사용자단 목업','https://solsol-mockup.pages.dev',200);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (201,4,'사용자단 목업(FR01)','FR 강의·상품 6유형 목업 (목록/상세)','frontend-developer','김도형','2026-06-20','2026-06-24',100,NULL,'https://solsol-mockup.pages.dev',201);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (202,4,'사용자단 목업(FR01)','FR 결제·주문 목업','frontend-developer','김도형','2026-06-20','2026-06-24',100,NULL,'https://solsol-mockup.pages.dev',202);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (203,4,'사용자단 목업(FR01)','FR 커뮤니티·게시판·FAQ 목업','frontend-developer','김도형','2026-06-20','2026-06-24',100,NULL,'https://solsol-mockup.pages.dev',203);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (204,4,'사용자단 목업(FR01)','FR 마이페이지·강의실·문의 목업','frontend-developer','김도형','2026-06-20','2026-06-24',100,'46화면 · 검증 라운드1 blocker5 보완 대기','https://solsol-mockup.pages.dev',204);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (205,4,'관리자단 목업(AD01)','AD 인증·대시보드·통계 목업','admin-developer','김도형','2026-06-25','2026-06-25',100,'관리자단 목업','https://solsol-admin-mockup.pages.dev',205);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (206,4,'관리자단 목업(AD01)','AD 사용자·상품·콘텐츠 목업','admin-developer','김도형','2026-06-25','2026-06-25',100,NULL,'https://solsol-admin-mockup.pages.dev',206);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (207,4,'관리자단 목업(AD01)','AD 판매·운영·마케팅 목업','admin-developer','김도형','2026-06-25','2026-06-25',100,NULL,'https://solsol-admin-mockup.pages.dev',207);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (208,4,'관리자단 목업(AD01)','AD 사이트디자인·정산·설정 목업','admin-developer','김도형','2026-06-25','2026-06-25',100,'96P/107화면 전수 · 모달 blocker2 보완 대기','https://solsol-admin-mockup.pages.dev',208);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (209,4,'브랜드 사이트 목업(BR01)','BR 메인·소개·가격 목업','frontend-developer','김도형','2026-06-25','2026-06-25',100,'브랜드 사이트 목업','https://solsol-brand-mockup.pages.dev',209);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (210,4,'브랜드 사이트 목업(BR01)','BR 인증·내사이트·결제 목업','frontend-developer','김도형','2026-06-25','2026-06-25',100,NULL,'https://solsol-brand-mockup.pages.dev',210);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (211,4,'브랜드 사이트 목업(BR01)','BR 마이페이지·약관·시스템 목업','frontend-developer','김도형','2026-06-25','2026-06-25',100,'39화면 · 검증 게이트 통과 · major4 보완','https://solsol-brand-mockup.pages.dev',211);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (212,4,'브랜드 관리자단 목업(BO)','BO 화면목록 확정 + 목업','frontend-developer','김도형','2026-06-30','2026-07-18',0,'화면목록 확정 후 목업',NULL,212);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (213,5,'화면설계·정책·검증','화면목록 마스터 (272화면 채번·3중검증)','김덕조','김덕조','2026-06-24','2026-06-25',100,'00_화면목록 v1.2',NULL,213);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (214,5,'화면설계·정책·검증','화면설계서 FR/AD/BR (01~03)','김덕조','김덕조','2026-06-26','2026-07-18',90,NULL,NULL,214);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (215,5,'화면설계·정책·검증','정책설계서·정책요약 (확정 6건)','김덕조','김덕조','2026-06-26','2026-07-11',95,NULL,NULL,215);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (216,5,'화면설계·정책·검증','검증 패키지·개발–검증 절차 (dev-validation 게이트)','김덕조','김덕조','2026-06-23','2026-06-25',100,'docs/validation · DEV_VALIDATION_PROCESS',NULL,216);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (217,5,'개발 설계','DB 설계 (테이블·ERD)','dba','김도형','2026-06-26','2026-07-04',0,NULL,NULL,217);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (218,5,'개발 설계','기능명세서 (페이지명세서)','planner','김도형','2026-06-26','2026-07-04',0,NULL,NULL,218);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (219,5,'개발 설계','API 명세서 (1·2차)','api-developer','김도형','2026-06-26','2026-08-01',0,NULL,NULL,219);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (220,5,'개발 설계','외부 연계 설계 (NHN·NICE·PG·위캔디오·펌뱅킹)','api-developer','김도형','2026-07-01','2026-08-29',0,'7/1~ 2개월 실연동',NULL,220);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (221,6,'공통·기반','프레임워크·스키마·공통모듈','api-developer','김도형','2026-06-26','2026-08-01',0,NULL,NULL,221);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (222,6,'공통·기반','외부 API 연동 (소셜·메시징·결제·본인인증·위캔디오)','api-developer','김도형','2026-06-26','2026-08-29',0,NULL,NULL,222);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (223,6,'공통·기반','인프라·CI/CD','deployer','김도형','2026-06-26','2026-08-15',0,NULL,NULL,223);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (224,6,'공통·기반','API 개발','api-developer','김도형','2026-06-26','2026-08-22',0,NULL,NULL,224);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (225,6,'공통·기반','배치 프로세스','api-developer','김도형','2026-08-03','2026-08-29',0,NULL,NULL,225);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (226,6,'관리자단 구현(AD01)','AD 인증·사용자','admin-developer','김도형','2026-06-26','2026-07-11',0,NULL,NULL,226);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (227,6,'관리자단 구현(AD01)','AD 상품 (강의·디지털·패키지·커뮤니티·멤버십)','admin-developer','김도형','2026-06-26','2026-08-08',0,NULL,NULL,227);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (228,6,'관리자단 구현(AD01)','AD 콘텐츠','admin-developer','김도형','2026-06-26','2026-07-25',0,NULL,NULL,228);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (229,6,'관리자단 구현(AD01)','AD 판매 (주문·쿠폰·환불)','admin-developer','김도형','2026-06-26','2026-08-08',0,NULL,NULL,229);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (230,6,'관리자단 구현(AD01)','AD 운영·설정','admin-developer','김도형','2026-06-26','2026-08-01',0,NULL,NULL,230);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (231,6,'관리자단 구현(AD01)','AD 마케팅·사이트디자인','admin-developer','김도형','2026-07-01','2026-08-29',0,NULL,NULL,231);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (232,6,'관리자단 구현(AD01)','AD 정산·통계','admin-developer','김도형','2026-07-15','2026-09-12',0,NULL,NULL,232);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (233,6,'사용자단 구현(FR01)','CF 인증·가입','frontend-developer','김도형','2026-06-26','2026-07-25',0,NULL,NULL,233);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (234,6,'사용자단 구현(FR01)','CF 강의·상품 (6유형)','lms-developer','김도형','2026-06-26','2026-08-15',0,NULL,NULL,234);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (235,6,'사용자단 구현(FR01)','CF 결제·마이페이지','frontend-developer','김도형','2026-07-15','2026-09-05',0,NULL,NULL,235);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (236,6,'사용자단 구현(FR01)','CF 커뮤니티·멤버십·게시판','frontend-developer','김도형','2026-07-15','2026-09-12',0,NULL,NULL,236);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (237,6,'브랜드 구현(BR01)','Brand 인증·플랜구독','frontend-developer','김도형','2026-07-15','2026-09-05',0,NULL,NULL,237);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (238,6,'브랜드 구현(BR01)','Brand 마이페이지·소개·기타','frontend-developer','김도형','2026-08-03','2026-09-19',0,NULL,NULL,238);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (239,6,'브랜드 관리자단(BO)','BackOffice 구현','admin-developer','김도형','2026-06-26','2026-08-22',0,NULL,NULL,239);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (57,7,'운영 · 정책','운영 서비스 기획','방준영','방준영','2026-04-16','2026-07-31',30,NULL,NULL,56);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (58,7,'운영 · 정책','이용약관 · 개인정보처리방침 셋팅','방준영','방준영','2026-07-01','2026-08-15',0,NULL,NULL,57);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (59,7,'운영 · 정책','전체 QA · 운영가이드 · FAQ','미정','미정','2026-08-01','2026-08-31',0,NULL,NULL,58);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (60,7,'마케팅','크리에이터 섭외 (베타오픈 10명)','미정','미정','2026-07-01','2026-08-15',0,NULL,NULL,59);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (61,7,'마케팅','오픈 프로모션 기획','미정','미정','2026-08-01','2026-08-31',0,NULL,NULL,60);
INSERT INTO wbs_item (id,step,grp,name,owner,responsible,start,end,progress,note,href,sort) VALUES (62,7,'계약','토스 PG · NHN · 펌뱅킹 · NICE 계약','미정','미정','2026-06-01','2026-08-15',0,NULL,NULL,61);
