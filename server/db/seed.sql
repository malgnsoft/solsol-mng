-- 자동 생성 시드 (solsol-project) — 쏠쏠 프로젝트 관리
-- 회원(member) 기본 관리자 + WBS 간트(wbs_item). 이슈/댓글은 사용자 작성 데이터라 시드 없음.
-- 적용(원격): pnpm db:seed  (wrangler d1 execute solsol-project --remote --file=server/db/seed.sql)

-- ── 기본 관리자 계정 (로그인: admin / 비밀번호: solsol2026) ──
DELETE FROM member;
INSERT INTO member (id,login_id,password_hash,name,company,role,grade,email,phone,source,office_id,status,agreed_at,created_at,updated_at)
  VALUES (1,'admin','pbkdf2$100000$h8N9NWJuj0dGeTXaP1KbFg==$UKTOSQv9NcHWiMwmFVHUO9HX0o6Wg10qHwdBFeYtrBs=','관리자','맑은소프트','프로젝트 관리자','admin','','','direct',NULL,'active',NULL,'2026-06-17T00:00:00.000Z',NULL);

-- ── WBS 간트 ──
DELETE FROM wbs_item;
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (1,1,'리뷰 · 프로토타입','전체 스펙 요구사항 리뷰회의','김덕조','2026-01-26','2026-01-30',100,NULL,NULL,0);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (2,1,'리뷰 · 프로토타입','4개 앱 프로토타입 (CA·CF·Brand·BO)','김덕조, 유회광','2026-01-23','2026-02-25',100,'creatorlms 프로토타입 5종',NULL,1);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (3,1,'서비스 정책','서비스 정책 확정 (회원·가격·구독·알림·저작권)','김덕조, 김혜인','2026-02-03','2026-02-27',100,NULL,NULL,2);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (4,1,'서비스 정책','도메인 구조 확정 (solsol.so)','김덕조','2026-04-15','2026-04-15',100,'CF {slug}.solsol.so · CA ceo.solsol.so · BO so.solsol.so · Brand solsol.so',NULL,3);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (5,1,'서비스 정책','BackOffice 정책 (도메인/SSL·국가/언어·AI번역·환불)','방준영, 김혜인','2026-03-29','2026-06-15',70,NULL,NULL,4);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (6,2,'메뉴 구조도','4개 앱 메뉴 구조도','조안이혜, 김혜인, 유회광, 김덕조','2026-02-10','2026-03-13',100,NULL,NULL,5);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (7,2,'메뉴 구조도','Guide site 메뉴 구조도','방준영','2026-05-01','2026-06-26',40,NULL,NULL,6);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (8,2,'화면설계','Customer Admin 화면설계 v1.1','김혜인, 조안이혜','2026-03-16','2026-04-02',100,NULL,NULL,7);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (9,2,'화면설계','Customer Front 화면설계 v1.1','김혜인','2026-03-04','2026-06-30',70,'v1.1 작업중',NULL,8);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (10,2,'화면설계','Brand · BackOffice · Guide 화면설계','김덕조, 유회광, 방준영','2026-03-05','2026-03-20',100,NULL,NULL,9);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (11,2,'알림 · 문구','서비스/마케팅 알림 기획','김혜인, 조안이혜','2026-04-15','2026-04-25',100,NULL,NULL,10);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (12,2,'알림 · 문구','얼럿/컨펌 문구 통일','조안이혜, 김혜인','2026-04-16','2026-04-16',100,NULL,NULL,11);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (13,3,'디자인 시안','Customer Front · Brand 시안 (피그마)','전진주','2026-03-20','2026-03-25',100,NULL,NULL,12);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (14,3,'디자인 시안','Customer Admin 시안','이승미','2026-04-01','2026-06-15',60,NULL,NULL,13);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (15,3,'브랜드','브랜드 로고','방준영','2026-03-24','2026-03-25',100,NULL,NULL,14);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (16,4,'퍼블리싱','Customer Admin 퍼블리싱','박윤희','2026-03-19','2026-06-20',80,NULL,NULL,15);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (17,4,'퍼블리싱','Customer Front 퍼블리싱','박윤희','2026-03-19','2026-06-20',80,NULL,NULL,16);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (18,4,'퍼블리싱','Brand site 퍼블리싱','김덕조','2026-05-01','2026-06-30',40,NULL,NULL,17);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (19,4,'퍼블리싱','BackOffice · Guide 퍼블리싱','유회광, 방준영','2026-05-01','2026-07-15',20,NULL,NULL,18);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (20,5,'설계 산출물','개발 플랫폼 · 방법론 정의','서만원','2026-03-27','2026-04-30',100,'github.com/malgnsoft/creatorlms',NULL,19);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (21,5,'설계 산출물','DB 설계 (테이블 · ERD)','서만원','2026-04-01','2026-04-30',100,NULL,NULL,20);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (22,5,'설계 산출물','기능명세서 (페이지명세서)','서만원','2026-04-01','2026-04-30',100,NULL,NULL,21);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (23,5,'설계 산출물','API 명세서 (1·2차)','서만원','2026-05-01','2026-06-30',70,NULL,NULL,22);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (24,5,'설계 산출물','외부 연계 설계 (NHN·NICE·PG·위캔디오·펌뱅킹)','서만원','2026-06-01','2026-08-31',30,'7/1부터 2개월 실 연동',NULL,23);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (25,6,'기반','프레임워크 설계 (기반문서 작성)','서만원','2026-04-13','2026-04-19',100,NULL,NULL,24);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (26,6,'기반','스키마 설계','서만원','2026-05-11','2026-05-17',100,NULL,NULL,25);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (27,6,'기반','프레임워크 개발','서만원','2026-04-20','2026-05-10',100,'웹앱 개별 세팅',NULL,26);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (28,6,'공통','공통 모듈 개발','서만원','2026-04-20','2026-07-31',85,'코드관리 · 파일업로드 · 약관관리 · 메모 …',NULL,27);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (29,6,'공통','외부 API 분석 및 어댑터 설계','조수현, 서만원','2026-04-27','2026-05-31',90,'소셜로그인 · 메시징 · 결제 · 본인인증 · 위캔디오',NULL,28);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (30,6,'공통','외부 API 연동','조수현, 서만원','2026-04-27','2026-08-31',65,'소셜·메시징 적용 · 결제PG·NICE·위캔디오 7~8월 실 연동',NULL,29);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (31,6,'백엔드','API 개발','서만원','2026-04-27','2026-08-15',80,NULL,NULL,30);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (32,6,'백엔드','배치 프로세스 개발','서만원','2026-07-13','2026-08-15',0,NULL,NULL,31);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (33,6,'Customer Admin','CA - 인증 + 사용자 관리','조수현','2026-04-27','2026-06-30',95,'[상] 사용자 95% 완료 · 목록·상세·탭·모달 배선',NULL,32);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (34,6,'Customer Admin','CA - 콘텐츠 관리','서만원','2026-04-27','2026-07-15',85,'[상] assets·cert·영상(벤더) 잔여',NULL,33);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (35,6,'Customer Admin','CA - 상품 (강의 · 디지털 · 패키지)','서만원','2026-04-27','2026-07-31',78,'[상] 전 상품유형 CRUD 완료 · 후행탭 CF 의존',NULL,34);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (36,6,'Customer Admin','CA - 상품 (커뮤니티 · 멤버십)','서만원','2026-04-27','2026-07-31',55,'[상] 결제/수강생/후기/수료증 후행탭 보류',NULL,35);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (37,6,'Customer Admin','CA - 판매','조수현','2026-04-27','2026-07-15',55,'[하] 쿠폰 완결 · 주문/환불 CF #18 의존',NULL,36);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (38,6,'Customer Admin','CA - 마케팅','서만원, 조수현','2026-05-04','2026-07-31',25,'[하] 설문 조수현 · 나머지 서만원',NULL,37);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (39,6,'Customer Admin','CA - 사이트 디자인','조수현, 서만원','2026-05-04','2026-07-31',20,'[하] 메뉴 서만원(CF노출) · 나머지 조수현(빌더)',NULL,38);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (40,6,'Customer Admin','CA - 운영','조수현, 서만원','2026-05-04','2026-06-30',90,'[중] 운영관리 92% · 공지·팝업 완료',NULL,39);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (41,6,'Customer Admin','CA - 정산','서만원, 조수현','2026-06-01','2026-08-15',10,'[하] 매출/정산 10% · CF 거래데이터 대기',NULL,40);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (42,6,'Customer Admin','CA - 설정','조수현','2026-05-04','2026-07-15',35,'[중] 공지·수료증 일부 배선',NULL,41);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (43,6,'Customer Admin','CA - 통계','','2026-07-15','2026-08-15',0,'[하] 미착수',NULL,42);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (44,6,'Customer Front','CF - 인증 + 가입','조수현','2026-04-27','2026-06-30',30,'[상] 소셜 회원가입 · 로그인',NULL,43);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (45,6,'Customer Front','CF - 상품 목록/상세 (일반강의)','서만원','2026-04-27','2026-07-31',50,'[중] 일반강의 55% · 코어 카탈로그 · 상품결제 대기',NULL,44);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (46,6,'Customer Front','CF - 커뮤니티','조수현, 서만원','2026-06-15','2026-08-31',5,'[중] 미착수 · 상품관리/커뮤니티·로그인 선행',NULL,45);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (47,6,'Customer Front','CF - 멤버십','조수현','2026-06-15','2026-08-31',5,'[중] 미착수 · 결제PG·본인인증 선행',NULL,46);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (48,6,'Customer Front','CF - 마이페이지','서만원, 조수현','2026-06-01','2026-08-15',10,'[중] nav 외 · 구매·결제 의존',NULL,47);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (49,6,'Customer Front','CF - 게시판 + 기타','조수현','2026-06-01','2026-08-15',20,'[중] 공지 90% · 1:1문의 5%',NULL,48);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (50,6,'Brand site','Brand - 인증 + 가입','조수현','2026-06-15','2026-07-15',5,'[상] Brand 전체 2% · 거의 미착수',NULL,49);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (51,6,'Brand site','Brand - 플랜 구독','서만원','2026-07-01','2026-08-15',0,'[상] 결제 · 미착수',NULL,50);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (52,6,'Brand site','Brand - 마이페이지','서만원, 조수현','2026-07-15','2026-08-31',0,'[중] 미착수',NULL,51);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (53,6,'Brand site','Brand - 서비스 소개 + 기타','조수현','2026-08-01','2026-08-31',0,'[하] 게시판류 · 일반 페이지',NULL,52);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (54,6,'BackOffice','BackOffice (범위 미정)','서만원','2026-04-27','2026-08-15',66,'전체 66% · 고객·테넌트 90%·개발자 95% · 결제정산·운영도구 대기',NULL,53);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (55,6,'인프라','인프라 구축','맑은소프트','2026-04-13','2026-06-30',90,'클라우드 · 도메인 · SSL · 베타 외 인프라 ~90%',NULL,54);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (56,6,'인프라','CI/CD','맑은소프트','2026-04-20','2026-07-31',55,NULL,NULL,55);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (57,7,'운영 · 정책','운영 서비스 기획','방준영','2026-04-16','2026-07-31',30,NULL,NULL,56);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (58,7,'운영 · 정책','이용약관 · 개인정보처리방침 셋팅','방준영','2026-07-01','2026-08-15',0,NULL,NULL,57);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (59,7,'운영 · 정책','전체 QA · 운영가이드 · FAQ','미정','2026-08-01','2026-08-31',0,NULL,NULL,58);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (60,7,'마케팅','크리에이터 섭외 (베타오픈 10명)','미정','2026-07-01','2026-08-15',0,NULL,NULL,59);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (61,7,'마케팅','오픈 프로모션 기획','미정','2026-08-01','2026-08-31',0,NULL,NULL,60);
INSERT INTO wbs_item (id,step,grp,name,owner,start,end,progress,note,href,sort) VALUES (62,7,'계약','토스 PG · NHN · 펌뱅킹 · NICE 계약','미정','2026-06-01','2026-08-15',0,NULL,NULL,61);
