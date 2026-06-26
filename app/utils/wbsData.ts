// 간트 WBS 데이터 — 쏠쏠 크리에이터 LMS 전체 일정(보드 7단계 전부). 날짜는 YYYY-MM-DD.
// Step 6=서비스 개발(개발 트랙). 진척은 dev /progress(6/7)+일정 기반. D1(wbs_item) 폴백 · seed.sql 동기화.

export interface GanttItem {
  step: 1 | 2 | 3 | 4 | 5 | 6 | 7
  group: string
  name: string
  owner: string
  responsible?: string // 책임(미설정 시 owner로 표시)
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
  4: "Step 4 · 퍼블리싱(목업)",
  5: "Step 5 · 설계",
  6: "Step 6 · 구현",
  7: "Step 7 · 운영·계약",
}

// 단계 가중치·진행률 — 현황판(board)과 동일 → WBS KPI = 프로젝트 전체 진척.
export const wbsStageMeta: Record<number, { weight: number, progress: number }> = {
  1: { weight: 8, progress: 95 },
  2: { weight: 10, progress: 90 },
  3: { weight: 6, progress: 85 },
  4: { weight: 8, progress: 90 },
  5: { weight: 10, progress: 48 },
  6: { weight: 43, progress: 0 },
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
  { step: 4, group: "사용자단 목업(FR01)", name: "FR 인증·가입 목업 (로그인·소셜가입·약관)", owner: "강프개", responsible: "김도형", start: "2026-06-20", end: "2026-06-24", progress: 100, note: "솔솔 사용자단 목업", href: "https://solsol-mockup.pages.dev" },
  { step: 4, group: "사용자단 목업(FR01)", name: "FR 강의·상품 6유형 목업 (목록/상세)", owner: "강프개", responsible: "김도형", start: "2026-06-20", end: "2026-06-24", progress: 100, href: "https://solsol-mockup.pages.dev" },
  { step: 4, group: "사용자단 목업(FR01)", name: "FR 결제·주문 목업", owner: "강프개", responsible: "김도형", start: "2026-06-20", end: "2026-06-24", progress: 100, href: "https://solsol-mockup.pages.dev" },
  { step: 4, group: "사용자단 목업(FR01)", name: "FR 커뮤니티·게시판·FAQ 목업", owner: "강프개", responsible: "김도형", start: "2026-06-20", end: "2026-06-24", progress: 100, href: "https://solsol-mockup.pages.dev" },
  { step: 4, group: "사용자단 목업(FR01)", name: "FR 마이페이지·강의실·문의 목업", owner: "강프개", responsible: "김도형", start: "2026-06-20", end: "2026-06-24", progress: 100, note: "46화면 · 검증 라운드1 blocker5 보완 대기", href: "https://solsol-mockup.pages.dev" },
  { step: 4, group: "관리자단 목업(AD01)", name: "AD 인증·대시보드·통계 목업", owner: "임관개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, note: "관리자단 목업", href: "https://solsol-admin-mockup.pages.dev" },
  { step: 4, group: "관리자단 목업(AD01)", name: "AD 사용자·상품·콘텐츠 목업", owner: "임관개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, href: "https://solsol-admin-mockup.pages.dev" },
  { step: 4, group: "관리자단 목업(AD01)", name: "AD 판매·운영·마케팅 목업", owner: "임관개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, href: "https://solsol-admin-mockup.pages.dev" },
  { step: 4, group: "관리자단 목업(AD01)", name: "AD 사이트디자인·정산·설정 목업", owner: "임관개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, note: "96P/107화면 전수 · 모달 blocker2 보완 대기", href: "https://solsol-admin-mockup.pages.dev" },
  { step: 4, group: "브랜드 사이트 목업(BR01)", name: "BR 메인·소개·가격 목업", owner: "강프개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, note: "브랜드 사이트 목업", href: "https://solsol-brand-mockup.pages.dev" },
  { step: 4, group: "브랜드 사이트 목업(BR01)", name: "BR 인증·내사이트·결제 목업", owner: "강프개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, href: "https://solsol-brand-mockup.pages.dev" },
  { step: 4, group: "브랜드 사이트 목업(BR01)", name: "BR 마이페이지·약관·시스템 목업", owner: "강프개", responsible: "김도형", start: "2026-06-25", end: "2026-06-25", progress: 100, note: "39화면 · 검증 게이트 통과 · major4 보완", href: "https://solsol-brand-mockup.pages.dev" },
  { step: 4, group: "브랜드 관리자단 목업(BO)", name: "BO 화면목록 확정 + 목업", owner: "강프개", responsible: "김도형", start: "2026-06-30", end: "2026-07-18", progress: 0, note: "화면목록 확정 후 목업" },
  { step: 5, group: "화면설계·정책·검증", name: "화면목록 마스터 (272화면 채번·3중검증)", owner: "김덕조", responsible: "김덕조", start: "2026-06-24", end: "2026-06-25", progress: 100, note: "00_화면목록 v1.2" },
  { step: 5, group: "화면설계·정책·검증", name: "화면설계서 FR/AD/BR (01~03)", owner: "김덕조", responsible: "김덕조", start: "2026-06-26", end: "2026-07-18", progress: 90 },
  { step: 5, group: "화면설계·정책·검증", name: "정책설계서·정책요약 (확정 6건)", owner: "김덕조", responsible: "김덕조", start: "2026-06-26", end: "2026-07-11", progress: 95 },
  { step: 5, group: "화면설계·정책·검증", name: "검증 패키지·개발–검증 절차 (dev-validation 게이트)", owner: "김덕조", responsible: "김덕조", start: "2026-06-23", end: "2026-06-25", progress: 100, note: "docs/validation · DEV_VALIDATION_PROCESS" },
  { step: 5, group: "개발 설계", name: "DB 설계 (테이블·ERD)", owner: "한데관", responsible: "김도형", start: "2026-06-26", end: "2026-07-04", progress: 0 },
  { step: 5, group: "개발 설계", name: "기능명세서 (페이지명세서)", owner: "최기획", responsible: "김도형", start: "2026-06-26", end: "2026-07-04", progress: 0 },
  { step: 5, group: "개발 설계", name: "API 명세서 (1·2차)", owner: "조백개", responsible: "김도형", start: "2026-06-26", end: "2026-08-01", progress: 0 },
  { step: 5, group: "개발 설계", name: "외부 연계 설계 (NHN·NICE·PG·위캔디오·펌뱅킹)", owner: "조백개", responsible: "김도형", start: "2026-07-01", end: "2026-08-29", progress: 0, note: "7/1~ 2개월 실연동" },
  { step: 6, group: "공통·기반", name: "프레임워크·스키마·공통모듈", owner: "조백개", responsible: "김도형", start: "2026-06-26", end: "2026-08-01", progress: 0 },
  { step: 6, group: "공통·기반", name: "외부 API 연동 (소셜·메시징·결제·본인인증·위캔디오)", owner: "조백개", responsible: "김도형", start: "2026-06-26", end: "2026-08-29", progress: 0 },
  { step: 6, group: "공통·기반", name: "인프라·CI/CD", owner: "신배담", responsible: "김도형", start: "2026-06-26", end: "2026-08-15", progress: 0 },
  { step: 6, group: "공통·기반", name: "API 개발", owner: "조백개", responsible: "김도형", start: "2026-06-26", end: "2026-08-22", progress: 0 },
  { step: 6, group: "공통·기반", name: "배치 프로세스", owner: "조백개", responsible: "김도형", start: "2026-08-03", end: "2026-08-29", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 인증·사용자", owner: "임관개", responsible: "김도형", start: "2026-06-26", end: "2026-07-11", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 상품 (강의·디지털·패키지·커뮤니티·멤버십)", owner: "임관개", responsible: "김도형", start: "2026-06-26", end: "2026-08-08", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 콘텐츠", owner: "임관개", responsible: "김도형", start: "2026-06-26", end: "2026-07-25", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 판매 (주문·쿠폰·환불)", owner: "임관개", responsible: "김도형", start: "2026-06-26", end: "2026-08-08", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 운영·설정", owner: "임관개", responsible: "김도형", start: "2026-06-26", end: "2026-08-01", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 마케팅·사이트디자인", owner: "임관개", responsible: "김도형", start: "2026-07-01", end: "2026-08-29", progress: 0 },
  { step: 6, group: "관리자단 구현(AD01)", name: "AD 정산·통계", owner: "임관개", responsible: "김도형", start: "2026-07-15", end: "2026-09-12", progress: 0 },
  { step: 6, group: "사용자단 구현(FR01)", name: "CF 인증·가입", owner: "강프개", responsible: "김도형", start: "2026-06-26", end: "2026-07-25", progress: 0 },
  { step: 6, group: "사용자단 구현(FR01)", name: "CF 강의·상품 (6유형)", owner: "배현우", responsible: "김도형", start: "2026-06-26", end: "2026-08-15", progress: 0 },
  { step: 6, group: "사용자단 구현(FR01)", name: "CF 결제·마이페이지", owner: "강프개", responsible: "김도형", start: "2026-07-15", end: "2026-09-05", progress: 0 },
  { step: 6, group: "사용자단 구현(FR01)", name: "CF 커뮤니티·멤버십·게시판", owner: "강프개", responsible: "김도형", start: "2026-07-15", end: "2026-09-12", progress: 0 },
  { step: 6, group: "브랜드 구현(BR01)", name: "Brand 인증·플랜구독", owner: "강프개", responsible: "김도형", start: "2026-07-15", end: "2026-09-05", progress: 0 },
  { step: 6, group: "브랜드 구현(BR01)", name: "Brand 마이페이지·소개·기타", owner: "강프개", responsible: "김도형", start: "2026-08-03", end: "2026-09-19", progress: 0 },
  { step: 6, group: "브랜드 관리자단(BO)", name: "BackOffice 구현", owner: "임관개", responsible: "김도형", start: "2026-06-26", end: "2026-08-22", progress: 0 },
  { step: 7, group: "운영 · 정책", name: "운영 서비스 기획", owner: "방준영", start: "2026-04-16", end: "2026-07-31", progress: 30 },
  { step: 7, group: "운영 · 정책", name: "이용약관 · 개인정보처리방침 셋팅", owner: "방준영", start: "2026-07-01", end: "2026-08-15", progress: 0 },
  { step: 7, group: "운영 · 정책", name: "전체 QA · 운영가이드 · FAQ", owner: "미정", start: "2026-08-01", end: "2026-08-31", progress: 0 },
  { step: 7, group: "마케팅", name: "크리에이터 섭외 (베타오픈 10명)", owner: "미정", start: "2026-07-01", end: "2026-08-15", progress: 0 },
  { step: 7, group: "마케팅", name: "오픈 프로모션 기획", owner: "미정", start: "2026-08-01", end: "2026-08-31", progress: 0 },
  { step: 7, group: "계약", name: "토스 PG · NHN · 펌뱅킹 · NICE 계약", owner: "미정", start: "2026-06-01", end: "2026-08-15", progress: 0 },
]
