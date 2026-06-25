// 화면 진척 데이터 — 4개 영역 × (일반 페이지 / 모달) × 상태(디자인·퍼블리싱·개발·테스트)
// 크리에이터 사용자단(FR01)은 Figma "CustomerLMS 01. Customer Front" + 검증 화면목록에서 추출.
// 나머지 3개 영역은 Figma 추출 대기(추후 채움). 정본: docs/validation/00_화면목록.md (읽기 전용).

export interface ScreenItem { id: string; name: string; group: string; design: boolean; publish: boolean; dev: boolean; test: boolean }
export interface ScreenArea { key: string; label: string; source: string; pages: ScreenItem[]; modals: ScreenItem[]; pending?: boolean }

export const screenAreas: ScreenArea[] = [
  {
    key: 'creator-front',
    label: '쏠쏠 크리에이터 사용자단',
    source: 'Figma · CustomerLMS 01. Customer Front (FR01)',
    pages: [
  {
    "id": "S-FR01-9001-001",
    "name": "결제 유예기간 이용 제한 인트로",
    "group": "시스템·공통",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-001",
    "name": "회원가입 - 소셜 시작",
    "group": "회원·인증",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-002",
    "name": "회원가입 - 약관 동의",
    "group": "회원·인증",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0302-001",
    "name": "로그인 (소셜)",
    "group": "회원·인증",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-9002-001",
    "name": "알림센터",
    "group": "시스템·공통",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0102-001",
    "name": "일반강의 목록",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0102-002",
    "name": "일반강의 상세",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0103-001",
    "name": "라이브강의 목록",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0103-002",
    "name": "라이브강의 상세",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0104-001",
    "name": "화상강의 목록",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0104-002",
    "name": "화상강의 상세",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0105-001",
    "name": "패키지상품 목록",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0105-002",
    "name": "패키지상품 상세",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0106-001",
    "name": "디지털 상품 목록",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0106-002",
    "name": "디지털 상품 상세",
    "group": "강의·상품",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0107-001",
    "name": "프리미엄 커뮤니티(소개/구독)",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0107-002",
    "name": "커뮤니티 게시판 리스트",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0107-003",
    "name": "커뮤니티 게시글 글쓰기",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0107-004",
    "name": "커뮤니티 게시글 상세",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0107-005",
    "name": "커뮤니티 게시글 수정",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0108-001",
    "name": "멤버십 상품(구독)",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0109-001/002",
    "name": "공지사항 목록·상세",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0110-001~005",
    "name": "자유게시판 (목록/상세/글쓰기/수정)",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0111-001",
    "name": "FAQ (자주 묻는 질문)",
    "group": "커뮤니티·게시판",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0201-001",
    "name": "결제 (주문/결제)",
    "group": "결제",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0201-002",
    "name": "결제 완료",
    "group": "결제",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0201-003",
    "name": "결제 실패",
    "group": "결제",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-101",
    "name": "마이페이지 - 구독 관리",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-102",
    "name": "마이페이지 - 내 상품",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-201",
    "name": "강의실 (영상 플레이어·커리큘럼/AI튜터/자료실)",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-202",
    "name": "강의실 - 대시보드",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-203",
    "name": "라이브 강의실 (라이브 참여하기)",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-103",
    "name": "마이페이지 - 수료증",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-104",
    "name": "마이페이지 - 찜하기",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-105",
    "name": "마이페이지 - 쿠폰",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-106",
    "name": "마이페이지 - 결제 내역",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-107",
    "name": "마이페이지 - 결제 정보",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-108",
    "name": "마이페이지 - 내 게시글",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-109",
    "name": "1:1 문의하기 (작성)",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-110",
    "name": "1:1 문의내역 (목록)",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-111",
    "name": "1:1 문의 상세",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "S-FR01-0301-112",
    "name": "마이페이지 - 프로필 (설정)",
    "group": "마이페이지·강의실",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  }
],
    modals: [
  {
    "id": "",
    "name": "공유 모달",
    "group": "강의 상세 > 공유(P01)",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "맛보기 영상 모달",
    "group": "강의 상세 > 맛보기(P02)",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "본인확인 모달 (NICE)",
    "group": "결제 > 본인확인",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "쿠폰 선택 모달",
    "group": "결제 > 쿠폰",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "약관 동의 모달",
    "group": "결제·회원가입 > 약관",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "카드 등록 모달 (toss)",
    "group": "결제 > 카드등록",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "구독 취소 모달",
    "group": "구독 관리(P01)",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "상품 리스트 모달",
    "group": "내 상품(P01/P02)",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "영상 전체보기 모달",
    "group": "강의실(P01)",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  },
  {
    "id": "",
    "name": "게시글 신고/더보기 모달",
    "group": "커뮤니티 상세",
    "design": true,
    "publish": false,
    "dev": false,
    "test": false
  }
],
  },
  { key: 'creator-admin', label: '쏠쏠 크리에이터 관리자단', source: 'Figma 추출 대기 (AD01)', pages: [], modals: [], pending: true },
  { key: 'brand-front', label: '쏠쏠 브랜드 사용자단', source: 'Figma 추출 대기 (BR01)', pages: [], modals: [], pending: true },
  { key: 'brand-admin', label: '쏠쏠 브랜드 관리자단', source: 'Figma 추출 대기', pages: [], modals: [], pending: true },
]
