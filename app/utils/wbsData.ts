// 간트 WBS 데이터 — 솔솔 크리에이터 LMS 서비스 개발(앱 단위). 날짜는 YYYY-MM-DD.
// 진척은 dev /progress (6/7) 실측 · 마감 8월말. D1(wbs_item) 정본의 dev 폴백 · seed.sql 과 동일.

export interface GanttItem {
  step: 1 | 2 | 3 | 4 | 5
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
  1: "Step 1 · 서버·공통",
  2: "Step 2 · Customer Admin",
  3: "Step 3 · Customer Front",
  4: "Step 4 · Brand site",
  5: "Step 5 · BackOffice·인프라",
}

// 단계 가중치·진행률 — WBS 간트 KPI(전체 진척 = 가중평균). 앱(트랙) 단위.
export const wbsStageMeta: Record<number, { weight: number, progress: number }> = {
  1: { weight: 22, progress: 85 },
  2: { weight: 30, progress: 45 },
  3: { weight: 22, progress: 17 },
  4: { weight: 16, progress: 3 },
  5: { weight: 10, progress: 75 },
}

export const wbsGantt: GanttItem[] = [
  { step: 1, group: "기반", name: "프레임워크 설계 (기반문서 작성)", owner: "서만원", start: "2026-04-13", end: "2026-04-19", progress: 100 },
  { step: 1, group: "기반", name: "스키마 설계", owner: "서만원", start: "2026-05-11", end: "2026-05-17", progress: 100 },
  { step: 1, group: "기반", name: "프레임워크 개발", owner: "서만원", start: "2026-04-20", end: "2026-05-10", progress: 100, note: "웹앱 개별 세팅" },
  { step: 1, group: "공통", name: "공통 모듈 개발", owner: "서만원", start: "2026-04-20", end: "2026-07-31", progress: 85, note: "코드관리 · 파일업로드 · 약관관리 · 메모 …" },
  { step: 1, group: "공통", name: "외부 API 분석 및 어댑터 설계", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-05-31", progress: 90, note: "소셜로그인 · 메시징 · 결제 · 본인인증 · 위캔디오" },
  { step: 1, group: "공통", name: "외부 API 연동", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-08-31", progress: 65, note: "소셜·메시징 적용 · 결제PG·NICE·위캔디오 7~8월 실 연동" },
  { step: 1, group: "백엔드", name: "API 개발", owner: "서만원", start: "2026-04-27", end: "2026-08-15", progress: 80 },
  { step: 1, group: "백엔드", name: "배치 프로세스 개발", owner: "서만원", start: "2026-07-13", end: "2026-08-15", progress: 0 },
  { step: 2, group: "Customer Admin", name: "CA - 인증 + 사용자 관리", owner: "조수현", start: "2026-04-27", end: "2026-06-30", progress: 95, note: "[상] 사용자 95% 완료 · 목록·상세·탭·모달 배선" },
  { step: 2, group: "Customer Admin", name: "CA - 콘텐츠 관리", owner: "서만원", start: "2026-04-27", end: "2026-07-15", progress: 85, note: "[상] assets·cert·영상(벤더) 잔여" },
  { step: 2, group: "Customer Admin", name: "CA - 상품 (강의 · 디지털 · 패키지)", owner: "서만원", start: "2026-04-27", end: "2026-07-31", progress: 78, note: "[상] 전 상품유형 CRUD 완료 · 후행탭 CF 의존" },
  { step: 2, group: "Customer Admin", name: "CA - 상품 (커뮤니티 · 멤버십)", owner: "서만원", start: "2026-04-27", end: "2026-07-31", progress: 55, note: "[상] 결제/수강생/후기/수료증 후행탭 보류" },
  { step: 2, group: "Customer Admin", name: "CA - 판매", owner: "조수현", start: "2026-04-27", end: "2026-07-15", progress: 55, note: "[하] 쿠폰 완결 · 주문/환불 CF #18 의존" },
  { step: 2, group: "Customer Admin", name: "CA - 마케팅", owner: "서만원, 조수현", start: "2026-05-04", end: "2026-07-31", progress: 25, note: "[하] 설문 조수현 · 나머지 서만원" },
  { step: 2, group: "Customer Admin", name: "CA - 사이트 디자인", owner: "조수현, 서만원", start: "2026-05-04", end: "2026-07-31", progress: 20, note: "[하] 메뉴 서만원(CF노출) · 나머지 조수현(빌더)" },
  { step: 2, group: "Customer Admin", name: "CA - 운영", owner: "조수현, 서만원", start: "2026-05-04", end: "2026-06-30", progress: 90, note: "[중] 운영관리 92% · 공지·팝업 완료" },
  { step: 2, group: "Customer Admin", name: "CA - 정산", owner: "서만원, 조수현", start: "2026-06-01", end: "2026-08-15", progress: 10, note: "[하] 매출/정산 10% · CF 거래데이터 대기" },
  { step: 2, group: "Customer Admin", name: "CA - 설정", owner: "조수현", start: "2026-05-04", end: "2026-07-15", progress: 35, note: "[중] 공지·수료증 일부 배선" },
  { step: 2, group: "Customer Admin", name: "CA - 통계", owner: "", start: "2026-07-15", end: "2026-08-15", progress: 0, note: "[하] 미착수" },
  { step: 3, group: "Customer Front", name: "CF - 인증 + 가입", owner: "조수현", start: "2026-04-27", end: "2026-06-30", progress: 30, note: "[상] 소셜 회원가입 · 로그인" },
  { step: 3, group: "Customer Front", name: "CF - 상품 목록/상세 (일반강의)", owner: "서만원", start: "2026-04-27", end: "2026-07-31", progress: 50, note: "[중] 일반강의 55% · 코어 카탈로그 · 상품결제 대기" },
  { step: 3, group: "Customer Front", name: "CF - 커뮤니티", owner: "조수현, 서만원", start: "2026-06-15", end: "2026-08-31", progress: 5, note: "[중] 미착수 · 상품관리/커뮤니티·로그인 선행" },
  { step: 3, group: "Customer Front", name: "CF - 멤버십", owner: "조수현", start: "2026-06-15", end: "2026-08-31", progress: 5, note: "[중] 미착수 · 결제PG·본인인증 선행" },
  { step: 3, group: "Customer Front", name: "CF - 마이페이지", owner: "서만원, 조수현", start: "2026-06-01", end: "2026-08-15", progress: 10, note: "[중] nav 외 · 구매·결제 의존" },
  { step: 3, group: "Customer Front", name: "CF - 게시판 + 기타", owner: "조수현", start: "2026-06-01", end: "2026-08-15", progress: 20, note: "[중] 공지 90% · 1:1문의 5%" },
  { step: 4, group: "Brand site", name: "Brand - 인증 + 가입", owner: "조수현", start: "2026-06-15", end: "2026-07-15", progress: 5, note: "[상] Brand 전체 2% · 거의 미착수" },
  { step: 4, group: "Brand site", name: "Brand - 플랜 구독", owner: "서만원", start: "2026-07-01", end: "2026-08-15", progress: 0, note: "[상] 결제 · 미착수" },
  { step: 4, group: "Brand site", name: "Brand - 마이페이지", owner: "서만원, 조수현", start: "2026-07-15", end: "2026-08-31", progress: 0, note: "[중] 미착수" },
  { step: 4, group: "Brand site", name: "Brand - 서비스 소개 + 기타", owner: "조수현", start: "2026-08-01", end: "2026-08-31", progress: 0, note: "[하] 게시판류 · 일반 페이지" },
  { step: 5, group: "BackOffice", name: "BackOffice (범위 미정)", owner: "서만원", start: "2026-04-27", end: "2026-08-15", progress: 66, note: "전체 66% · 고객·테넌트 90%·개발자 95% · 결제정산·운영도구 대기" },
  { step: 5, group: "인프라", name: "인프라 구축", owner: "맑은소프트", start: "2026-04-13", end: "2026-06-30", progress: 90, note: "클라우드 · 도메인 · SSL · 베타 외 인프라 ~90%" },
  { step: 5, group: "인프라", name: "CI/CD", owner: "맑은소프트", start: "2026-04-20", end: "2026-07-31", progress: 55 },
]
