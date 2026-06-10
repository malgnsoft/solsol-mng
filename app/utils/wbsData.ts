// 간트 WBS 데이터 — 솔솔 크리에이터 LMS 전체 일정(보드 7단계 전부). 날짜는 YYYY-MM-DD.
// Step 6=서비스 개발(개발 트랙). 진척은 dev /progress(6/7)+일정 기반. D1(wbs_item) 폴백 · seed.sql 동기화.

export interface GanttItem {
  step: 1 | 2 | 3 | 4 | 5 | 6 | 7
  group: string
  name: string
  owner: string
  start?: string // 미정이면 생략(간트 막대 없음)
  end?: string
  progress: number
  note?: string
  href?: string
}

export const wbsSteps: Record<number, string> = {
  1: "Step 1 · 기획·정책",
  2: "Step 2 · 화면설계",
  3: "Step 3 · 디자인",
  4: "Step 4 · 퍼블리싱",
  5: "Step 5 · 개발 설계",
  6: "Step 6 · 서비스 개발",
  7: "Step 7 · 운영·계약",
}

// 단계 가중치·진행률 — 현황판(board)과 동일 → WBS KPI = 프로젝트 전체 진척.
export const wbsStageMeta: Record<number, { weight: number, progress: number }> = {
  1: { weight: 8, progress: 95 },
  2: { weight: 10, progress: 90 },
  3: { weight: 6, progress: 85 },
  4: { weight: 8, progress: 70 },
  5: { weight: 10, progress: 80 },
  6: { weight: 43, progress: 44 },
  7: { weight: 15, progress: 15 },
}

export const wbsGantt: GanttItem[] = [
  { step: 1, group: "리뷰 · 프로토타입", name: "전체 스펙 요구사항 리뷰회의", owner: "김덕조", start: "2026-01-26", end: "2026-01-30", progress: 100 },
  { step: 1, group: "리뷰 · 프로토타입", name: "4개 앱 프로토타입 (CA·CF·Brand·BO)", owner: "김덕조, 유회광", start: "2026-01-23", end: "2026-02-25", progress: 100, note: "creatorlms 프로토타입 5종" },
  { step: 1, group: "서비스 정책", name: "서비스 정책 확정 (회원·가격·구독·알림·저작권)", owner: "김덕조, 김혜인", start: "2026-02-03", end: "2026-02-27", progress: 100 },
  { step: 1, group: "서비스 정책", name: "도메인 구조 확정 (solsol.so)", owner: "김덕조", start: "2026-04-15", end: "2026-04-15", progress: 100, note: "CF {slug}.solsol.so · CA ceo.solsol.so · BO so.solsol.so · Brand solsol.so" },
  { step: 1, group: "서비스 정책", name: "BackOffice 정책 (도메인/SSL·국가/언어·AI번역·환불)", owner: "방준영, 김혜인", start: "2026-03-29", end: "2026-06-15", progress: 70 },
  { step: 2, group: "메뉴 구조도", name: "4개 앱 메뉴 구조도", owner: "조안이혜, 김혜인, 유회광, 김덕조", start: "2026-02-10", end: "2026-03-13", progress: 100 },
  { step: 2, group: "메뉴 구조도", name: "Guide site 메뉴 구조도", owner: "방준영", start: "2026-05-01", end: "2026-06-26", progress: 40 },
  { step: 2, group: "화면설계", name: "Customer Admin 화면설계 v1.1", owner: "김혜인, 조안이혜", start: "2026-03-16", end: "2026-04-02", progress: 100 },
  { step: 2, group: "화면설계", name: "Customer Front 화면설계 v1.1", owner: "김혜인", start: "2026-03-04", end: "2026-06-30", progress: 70, note: "v1.1 작업중" },
  { step: 2, group: "화면설계", name: "Brand · BackOffice · Guide 화면설계", owner: "김덕조, 유회광, 방준영", start: "2026-03-05", end: "2026-03-20", progress: 100 },
  { step: 2, group: "알림 · 문구", name: "서비스/마케팅 알림 기획", owner: "김혜인, 조안이혜", start: "2026-04-15", end: "2026-04-25", progress: 100 },
  { step: 2, group: "알림 · 문구", name: "얼럿/컨펌 문구 통일", owner: "조안이혜, 김혜인", start: "2026-04-16", end: "2026-04-16", progress: 100 },
  { step: 3, group: "디자인 시안", name: "Customer Front · Brand 시안 (피그마)", owner: "전진주", start: "2026-03-20", end: "2026-03-25", progress: 100 },
  { step: 3, group: "디자인 시안", name: "Customer Admin 시안", owner: "이승미", start: "2026-04-01", end: "2026-06-15", progress: 60 },
  { step: 3, group: "브랜드", name: "브랜드 로고", owner: "방준영", start: "2026-03-24", end: "2026-03-25", progress: 100 },
  { step: 4, group: "퍼블리싱", name: "Customer Admin 퍼블리싱", owner: "박윤희", start: "2026-03-19", end: "2026-06-20", progress: 80 },
  { step: 4, group: "퍼블리싱", name: "Customer Front 퍼블리싱", owner: "박윤희", start: "2026-03-19", end: "2026-06-20", progress: 80 },
  { step: 4, group: "퍼블리싱", name: "Brand site 퍼블리싱", owner: "김덕조", start: "2026-05-01", end: "2026-06-30", progress: 40 },
  { step: 4, group: "퍼블리싱", name: "BackOffice · Guide 퍼블리싱", owner: "유회광, 방준영", start: "2026-05-01", end: "2026-07-15", progress: 20 },
  { step: 5, group: "설계 산출물", name: "개발 플랫폼 · 방법론 정의", owner: "서만원", start: "2026-03-27", end: "2026-04-30", progress: 100, note: "github.com/malgnsoft/creatorlms" },
  { step: 5, group: "설계 산출물", name: "DB 설계 (테이블 · ERD)", owner: "서만원", start: "2026-04-01", end: "2026-04-30", progress: 100 },
  { step: 5, group: "설계 산출물", name: "기능명세서 (페이지명세서)", owner: "서만원", start: "2026-04-01", end: "2026-04-30", progress: 100 },
  { step: 5, group: "설계 산출물", name: "API 명세서 (1·2차)", owner: "서만원", start: "2026-05-01", end: "2026-06-30", progress: 70 },
  { step: 5, group: "설계 산출물", name: "외부 연계 설계 (NHN·NICE·PG·위캔디오·펌뱅킹)", owner: "서만원", start: "2026-06-01", end: "2026-08-31", progress: 30, note: "7/1부터 2개월 실 연동" },
  { step: 6, group: "기반", name: "프레임워크 설계 (기반문서 작성)", owner: "서만원", start: "2026-04-13", end: "2026-04-19", progress: 100 },
  { step: 6, group: "기반", name: "스키마 설계", owner: "서만원", start: "2026-05-11", end: "2026-05-17", progress: 100 },
  { step: 6, group: "기반", name: "프레임워크 개발", owner: "서만원", start: "2026-04-20", end: "2026-05-10", progress: 100, note: "웹앱 개별 세팅" },
  { step: 6, group: "공통", name: "공통 모듈 개발", owner: "서만원", start: "2026-04-20", end: "2026-07-31", progress: 85, note: "코드관리 · 파일업로드 · 약관관리 · 메모 …" },
  { step: 6, group: "공통", name: "외부 API 분석 및 어댑터 설계", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-05-31", progress: 90, note: "소셜로그인 · 메시징 · 결제 · 본인인증 · 위캔디오" },
  { step: 6, group: "공통", name: "외부 API 연동", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-08-31", progress: 65, note: "소셜·메시징 적용 · 결제PG·NICE·위캔디오 7~8월 실 연동" },
  { step: 6, group: "백엔드", name: "API 개발", owner: "서만원", start: "2026-04-27", end: "2026-08-15", progress: 80 },
  { step: 6, group: "백엔드", name: "배치 프로세스 개발", owner: "서만원", start: "2026-07-13", end: "2026-08-15", progress: 0 },
  { step: 6, group: "Customer Admin", name: "CA - 인증 + 사용자 관리", owner: "조수현", start: "2026-04-27", end: "2026-06-30", progress: 95, note: "[상] 사용자 95% 완료 · 목록·상세·탭·모달 배선" },
  { step: 6, group: "Customer Admin", name: "CA - 콘텐츠 관리", owner: "서만원", start: "2026-04-27", end: "2026-07-15", progress: 85, note: "[상] assets·cert·영상(벤더) 잔여" },
  { step: 6, group: "Customer Admin", name: "CA - 상품 (강의 · 디지털 · 패키지)", owner: "서만원", start: "2026-04-27", end: "2026-07-31", progress: 78, note: "[상] 전 상품유형 CRUD 완료 · 후행탭 CF 의존" },
  { step: 6, group: "Customer Admin", name: "CA - 상품 (커뮤니티 · 멤버십)", owner: "서만원", start: "2026-04-27", end: "2026-07-31", progress: 55, note: "[상] 결제/수강생/후기/수료증 후행탭 보류" },
  { step: 6, group: "Customer Admin", name: "CA - 판매", owner: "조수현", start: "2026-04-27", end: "2026-07-15", progress: 55, note: "[하] 쿠폰 완결 · 주문/환불 CF #18 의존" },
  { step: 6, group: "Customer Admin", name: "CA - 마케팅", owner: "서만원, 조수현", start: "2026-05-04", end: "2026-07-31", progress: 25, note: "[하] 설문 조수현 · 나머지 서만원" },
  { step: 6, group: "Customer Admin", name: "CA - 사이트 디자인", owner: "조수현, 서만원", start: "2026-05-04", end: "2026-07-31", progress: 20, note: "[하] 메뉴 서만원(CF노출) · 나머지 조수현(빌더)" },
  { step: 6, group: "Customer Admin", name: "CA - 운영", owner: "조수현, 서만원", start: "2026-05-04", end: "2026-06-30", progress: 90, note: "[중] 운영관리 92% · 공지·팝업 완료" },
  { step: 6, group: "Customer Admin", name: "CA - 정산", owner: "서만원, 조수현", start: "2026-06-01", end: "2026-08-15", progress: 10, note: "[하] 매출/정산 10% · CF 거래데이터 대기" },
  { step: 6, group: "Customer Admin", name: "CA - 설정", owner: "조수현", start: "2026-05-04", end: "2026-07-15", progress: 35, note: "[중] 공지·수료증 일부 배선" },
  { step: 6, group: "Customer Admin", name: "CA - 통계", owner: "", start: "2026-07-15", end: "2026-08-15", progress: 0, note: "[하] 미착수" },
  { step: 6, group: "Customer Front", name: "CF - 인증 + 가입", owner: "조수현", start: "2026-04-27", end: "2026-06-30", progress: 30, note: "[상] 소셜 회원가입 · 로그인" },
  { step: 6, group: "Customer Front", name: "CF - 상품 목록/상세 (일반강의)", owner: "서만원", start: "2026-04-27", end: "2026-07-31", progress: 50, note: "[중] 일반강의 55% · 코어 카탈로그 · 상품결제 대기" },
  { step: 6, group: "Customer Front", name: "CF - 커뮤니티", owner: "조수현, 서만원", start: "2026-06-15", end: "2026-08-31", progress: 5, note: "[중] 미착수 · 상품관리/커뮤니티·로그인 선행" },
  { step: 6, group: "Customer Front", name: "CF - 멤버십", owner: "조수현", start: "2026-06-15", end: "2026-08-31", progress: 5, note: "[중] 미착수 · 결제PG·본인인증 선행" },
  { step: 6, group: "Customer Front", name: "CF - 마이페이지", owner: "서만원, 조수현", start: "2026-06-01", end: "2026-08-15", progress: 10, note: "[중] nav 외 · 구매·결제 의존" },
  { step: 6, group: "Customer Front", name: "CF - 게시판 + 기타", owner: "조수현", start: "2026-06-01", end: "2026-08-15", progress: 20, note: "[중] 공지 90% · 1:1문의 5%" },
  { step: 6, group: "Brand site", name: "Brand - 인증 + 가입", owner: "조수현", start: "2026-06-15", end: "2026-07-15", progress: 5, note: "[상] Brand 전체 2% · 거의 미착수" },
  { step: 6, group: "Brand site", name: "Brand - 플랜 구독", owner: "서만원", start: "2026-07-01", end: "2026-08-15", progress: 0, note: "[상] 결제 · 미착수" },
  { step: 6, group: "Brand site", name: "Brand - 마이페이지", owner: "서만원, 조수현", start: "2026-07-15", end: "2026-08-31", progress: 0, note: "[중] 미착수" },
  { step: 6, group: "Brand site", name: "Brand - 서비스 소개 + 기타", owner: "조수현", start: "2026-08-01", end: "2026-08-31", progress: 0, note: "[하] 게시판류 · 일반 페이지" },
  { step: 6, group: "BackOffice", name: "BackOffice (범위 미정)", owner: "서만원", start: "2026-04-27", end: "2026-08-15", progress: 66, note: "전체 66% · 고객·테넌트 90%·개발자 95% · 결제정산·운영도구 대기" },
  { step: 6, group: "인프라", name: "인프라 구축", owner: "맑은소프트", start: "2026-04-13", end: "2026-06-30", progress: 90, note: "클라우드 · 도메인 · SSL · 베타 외 인프라 ~90%" },
  { step: 6, group: "인프라", name: "CI/CD", owner: "맑은소프트", start: "2026-04-20", end: "2026-07-31", progress: 55 },
  { step: 7, group: "운영 · 정책", name: "운영 서비스 기획", owner: "방준영", start: "2026-04-16", end: "2026-07-31", progress: 30 },
  { step: 7, group: "운영 · 정책", name: "이용약관 · 개인정보처리방침 셋팅", owner: "방준영", start: "2026-07-01", end: "2026-08-15", progress: 0 },
  { step: 7, group: "운영 · 정책", name: "전체 QA · 운영가이드 · FAQ", owner: "미정", start: "2026-08-01", end: "2026-08-31", progress: 0 },
  { step: 7, group: "마케팅", name: "크리에이터 섭외 (베타오픈 10명)", owner: "미정", start: "2026-07-01", end: "2026-08-15", progress: 0 },
  { step: 7, group: "마케팅", name: "오픈 프로모션 기획", owner: "미정", start: "2026-08-01", end: "2026-08-31", progress: 0 },
  { step: 7, group: "계약", name: "토스 PG · NHN · 펌뱅킹 · NICE 계약", owner: "미정", start: "2026-06-01", end: "2026-08-15", progress: 0 },
]
