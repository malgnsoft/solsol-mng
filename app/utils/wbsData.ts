// 간트 WBS 데이터 — 솔솔 크리에이터 LMS 서비스 개발(앱 단위). 날짜는 YYYY-MM-DD.
// D1(wbs_item) 정본의 dev 폴백. seed.sql 의 wbs_item 과 동일 내용 유지.

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
  1: { weight: 25, progress: 75 },
  2: { weight: 30, progress: 30 },
  3: { weight: 20, progress: 18 },
  4: { weight: 15, progress: 15 },
  5: { weight: 10, progress: 40 },
}

export const wbsGantt: GanttItem[] = [
  { step: 1, group: "기반", name: "프레임워크 설계 (기반문서 작성)", owner: "서만원", start: "2026-04-13", end: "2026-04-19", progress: 100 },
  { step: 1, group: "기반", name: "스키마 설계", owner: "서만원", start: "2026-05-11", end: "2026-05-17", progress: 100 },
  { step: 1, group: "기반", name: "프레임워크 개발", owner: "서만원", start: "2026-04-20", end: "2026-05-10", progress: 100, note: "웹앱 개별 세팅" },
  { step: 1, group: "공통", name: "공통 모듈 개발", owner: "서만원", start: "2026-04-20", end: "2026-06-07", progress: 85, note: "코드관리 · 파일업로드 · 약관관리 · 메모 …" },
  { step: 1, group: "공통", name: "외부 API 분석 및 어댑터 설계", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-05-10", progress: 100, note: "소셜로그인 · 메시징 · 결제 · 본인인증 · 위캔디오" },
  { step: 1, group: "공통", name: "외부 API 연동", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-05-10", progress: 90 },
  { step: 1, group: "백엔드", name: "API 개발", owner: "서만원", start: "2026-04-27", end: "2026-05-10", progress: 90 },
  { step: 1, group: "백엔드", name: "배치 프로세스 개발", owner: "서만원", progress: 0 },
  { step: 2, group: "Customer Admin", name: "CA - 인증 + 사용자 관리", owner: "조수현", start: "2026-04-27", end: "2026-05-24", progress: 60, note: "[상] CRUD 우선 · 나머지탭 후순위 · 권한관리" },
  { step: 2, group: "Customer Admin", name: "CA - 콘텐츠 관리", owner: "서만원", start: "2026-04-27", end: "2026-05-10", progress: 70, note: "[상]" },
  { step: 2, group: "Customer Admin", name: "CA - 상품 (강의 · 디지털 · 패키지)", owner: "서만원", start: "2026-04-27", end: "2026-06-07", progress: 50, note: "[상] CRUD 우선 · 나머지탭 CF 작업 후" },
  { step: 2, group: "Customer Admin", name: "CA - 상품 (커뮤니티 · 멤버십)", owner: "서만원", start: "2026-04-27", end: "2026-06-07", progress: 40, note: "[상] CRUD 우선 · 나머지탭 CF 작업 후" },
  { step: 2, group: "Customer Admin", name: "CA - 판매", owner: "조수현", start: "2026-04-27", end: "2026-05-17", progress: 35, note: "[하] 쿠폰(우선) 서만원 · 나머지 조수현" },
  { step: 2, group: "Customer Admin", name: "CA - 마케팅", owner: "서만원, 조수현", start: "2026-05-04", end: "2026-05-17", progress: 25, note: "[하] 설문 조수현 · 나머지 서만원" },
  { step: 2, group: "Customer Admin", name: "CA - 사이트 디자인", owner: "조수현, 서만원", start: "2026-05-04", end: "2026-05-31", progress: 20, note: "[하] 메뉴 서만원(CF노출) · 나머지 조수현(빌더 포함)" },
  { step: 2, group: "Customer Admin", name: "CA - 운영", owner: "조수현, 서만원", start: "2026-05-04", end: "2026-05-17", progress: 20, note: "[중] 팝업 조수현(CA노출) · 게시판 서만원" },
  { step: 2, group: "Customer Admin", name: "CA - 정산", owner: "서만원, 조수현", start: "2026-05-04", end: "2026-05-31", progress: 10, note: "[하] 웹 조수현 · 배치 서만원 · CF 작업 후" },
  { step: 2, group: "Customer Admin", name: "CA - 설정", owner: "조수현", start: "2026-05-04", end: "2026-05-17", progress: 20, note: "[중]" },
  { step: 2, group: "Customer Admin", name: "CA - 통계", owner: "", progress: 0, note: "[하] 범위 미정" },
  { step: 3, group: "Customer Front", name: "CF - 인증 + 가입", owner: "조수현", start: "2026-04-27", end: "2026-05-24", progress: 40, note: "[상] 소셜 회원가입 · 로그인" },
  { step: 3, group: "Customer Front", name: "CF - 상품 목록/상세", owner: "서만원", start: "2026-04-27", end: "2026-05-31", progress: 15, note: "[중] 상품결제" },
  { step: 3, group: "Customer Front", name: "CF - 커뮤니티", owner: "조수현, 서만원", start: "2026-04-27", end: "2026-05-31", progress: 15, note: "[중] 게시판 조수현 · 상품결제 서만원" },
  { step: 3, group: "Customer Front", name: "CF - 멤버십", owner: "조수현", start: "2026-04-27", end: "2026-05-31", progress: 15, note: "[중] 구독결제 · 본인인증" },
  { step: 3, group: "Customer Front", name: "CF - 마이페이지", owner: "서만원, 조수현", start: "2026-04-27", end: "2026-05-31", progress: 15, note: "[중] 내상품 서만원(카드등록) · 나머지 조수현" },
  { step: 3, group: "Customer Front", name: "CF - 게시판 + 기타", owner: "조수현", start: "2026-04-27", end: "2026-05-31", progress: 10, note: "[중]" },
  { step: 4, group: "Brand site", name: "Brand - 인증 + 가입", owner: "조수현", start: "2026-05-04", end: "2026-05-24", progress: 30, note: "[상]" },
  { step: 4, group: "Brand site", name: "Brand - 플랜 구독", owner: "서만원", start: "2026-05-18", end: "2026-06-14", progress: 20, note: "[상] 결제" },
  { step: 4, group: "Brand site", name: "Brand - 마이페이지", owner: "서만원, 조수현", start: "2026-05-18", end: "2026-06-14", progress: 15, note: "[중] 내사이트관리 서만원 · 나머지 조수현" },
  { step: 4, group: "Brand site", name: "Brand - 서비스 소개 + 기타", owner: "조수현", progress: 0, note: "[하] 게시판류 · 일반 페이지" },
  { step: 5, group: "BackOffice", name: "BackOffice (범위 미정)", owner: "서만원", start: "2026-04-27", end: "2026-06-07", progress: 20, note: "범위 미정" },
  { step: 5, group: "인프라", name: "인프라 구축", owner: "맑은소프트", start: "2026-04-13", end: "2026-05-31", progress: 70, note: "클라우드 · 도메인 · SSL" },
  { step: 5, group: "인프라", name: "CI/CD", owner: "맑은소프트", start: "2026-04-20", end: "2026-06-14", progress: 50 },
]
