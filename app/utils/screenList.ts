// 화면 목록 — docs/validation/00_화면목록.md v1.2(정본·읽기전용) 기준 재생성.
// 본화면(§3.x) + 실제 모달/팝업 _pu(§3.x.2, 부모 아래 중첩) + 공유 모달 컴포넌트 C##(§3.x.3, '공유 모달 컴포넌트' 그룹).
// FR01 은 solsol-mockup 배포 라우트로 mockupUrl 연결(publish=true). design=true(미설계 제외). D1 상태 있으면 머지 시 우선.

export interface ScreenItem {
  id: string; name: string; group: string
  design: boolean; publish: boolean; dev: boolean; test: boolean
  mockupUrl?: string; devUrl?: string
  modals?: ScreenItem[]
}
export interface ScreenArea { key: string; label: string; source: string; screens: ScreenItem[]; pending?: boolean }

export const screenAreas: ScreenArea[] = [
  {
    "key": "creator-front",
    "label": "쏠쏠 크리에이터 사용자단",
    "source": "검증 화면목록 00_화면목록.md · FR01 (v1.2)",
    "screens": [
      {
        "id": "S-FR01-9001-001",
        "name": "결제 유예기간 이용 제한 인트로",
        "group": "시스템·공통",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/auth/payment-restricted",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-001",
        "name": "회원가입 - 소셜 시작",
        "group": "회원·인증",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/auth/signup",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-002",
        "name": "회원가입 - 약관 동의",
        "group": "회원·인증",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/auth/signup-terms",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-002_pu01",
            "name": "약관 보기 모달(이용약관/개인정보/마케팅)",
            "group": "회원·인증",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/auth/signup-terms",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0302-001",
        "name": "로그인 (소셜)",
        "group": "회원·인증",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/auth/login",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-9002-001",
        "name": "알림센터",
        "group": "시스템·공통",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/notifications",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0102-001",
        "name": "일반강의 목록",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0102-002",
        "name": "일반강의 상세",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/detail",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0102-002_pu01",
            "name": "공유하기 모달(카카오/페이스북/링크복사)",
            "group": "강의·상품",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/courses/detail",
            "devUrl": ""
          },
          {
            "id": "S-FR01-0102-002_pu02",
            "name": "맛보기 영상 모달",
            "group": "강의·상품",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/courses/detail",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0103-001",
        "name": "라이브강의 목록",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/live",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0103-002",
        "name": "라이브강의 상세",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/live/detail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0104-001",
        "name": "화상강의 목록",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/video",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0104-002",
        "name": "화상강의 상세",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/video/detail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0105-001",
        "name": "패키지상품 목록",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/package",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0105-002",
        "name": "패키지상품 상세",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/package/detail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0106-001",
        "name": "디지털 상품 목록",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/digital",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0106-002",
        "name": "디지털 상품 상세",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/digital/detail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0107-001",
        "name": "프리미엄 커뮤니티(소개/구독)",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/premium",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0107-002",
        "name": "커뮤니티 게시판 리스트",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/premium/board",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0107-003",
        "name": "커뮤니티 게시글 글쓰기",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/premium/write",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0107-004",
        "name": "커뮤니티 게시글 상세",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/premium/detail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0107-005",
        "name": "커뮤니티 게시글 수정",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/premium/write",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0108-001",
        "name": "멤버십 상품(구독)",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/membership",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0109-001/002",
        "name": "공지사항 목록·상세",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/notice",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0110-001~005",
        "name": "자유게시판 (목록/상세/글쓰기/수정)",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/free",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0111-001",
        "name": "FAQ (자주 묻는 질문)",
        "group": "커뮤니티·게시판",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/community/faq",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0201-001",
        "name": "결제 (주문/결제)",
        "group": "결제",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/payment/checkout",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0201-001_pu01",
            "name": "쿠폰 선택 모달",
            "group": "결제",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/payment/checkout",
            "devUrl": ""
          },
          {
            "id": "S-FR01-0201-001_pu02",
            "name": "결제 항목별 약관 모달",
            "group": "결제",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/payment/checkout",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0201-002",
        "name": "결제 완료",
        "group": "결제",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/payment/complete",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0201-003",
        "name": "결제 실패",
        "group": "결제",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/payment/fail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-101",
        "name": "마이페이지 - 구독 관리",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/subscription",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-101_pu01",
            "name": "구독 취소 모달(멤버십/커뮤니티)",
            "group": "마이페이지",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/subscription",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0301-102",
        "name": "마이페이지 - 내 상품",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/products",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-102_pu01",
            "name": "패키지 상품 리스트 모달",
            "group": "강의·상품",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/products",
            "devUrl": ""
          },
          {
            "id": "S-FR01-0301-102_pu02",
            "name": "디지털 상품 리스트 모달(잔여차감)",
            "group": "강의·상품",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/products",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0301-201",
        "name": "강의실 (영상 플레이어·커리큘럼/AI튜터/자료실)",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/learn/player",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-201_pu01",
            "name": "영상 전체보기(전체화면 플레이어)",
            "group": "강의·상품",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/courses/learn/player",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0301-202",
        "name": "강의실 - 대시보드",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/learn/dashboard",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-202_pu01",
            "name": "상품후기 작성 모달",
            "group": "강의·상품",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/courses/learn/dashboard",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0301-203",
        "name": "라이브 강의실 (라이브 참여하기)",
        "group": "강의·상품",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/courses/learn/live",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-103",
        "name": "마이페이지 - 수료증",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/certificate",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-103_pu01",
            "name": "수료증 모달(PDF 다운로드)",
            "group": "마이페이지",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/certificate",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-FR01-0301-104",
        "name": "마이페이지 - 찜하기",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/wishlist",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-105",
        "name": "마이페이지 - 쿠폰",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/coupon",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-106",
        "name": "마이페이지 - 결제 내역",
        "group": "결제",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/payments",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-107",
        "name": "마이페이지 - 결제 정보",
        "group": "결제",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/payment-info",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-108",
        "name": "마이페이지 - 내 게시글",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/posts",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-109",
        "name": "1:1 문의하기 (작성)",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/inquiry/write",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-110",
        "name": "1:1 문의내역 (목록)",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/inquiry",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-111",
        "name": "1:1 문의 상세",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/inquiry/detail",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-FR01-0301-112",
        "name": "마이페이지 - 프로필 (설정)",
        "group": "마이페이지",
        "design": true,
        "publish": true,
        "dev": false,
        "test": false,
        "mockupUrl": "/mypage/profile",
        "devUrl": "",
        "modals": [
          {
            "id": "S-FR01-0301-112_pu01",
            "name": "프로필 설정 모달(이미지/1:1 크롭)",
            "group": "마이페이지",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/profile",
            "devUrl": ""
          },
          {
            "id": "S-FR01-0301-112_pu02",
            "name": "닉네임 변경 모달(2~15자/중복체크)",
            "group": "마이페이지",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/profile",
            "devUrl": ""
          },
          {
            "id": "S-FR01-0301-112_pu03",
            "name": "계정 탈퇴 모달(사유 입력)",
            "group": "마이페이지",
            "design": true,
            "publish": true,
            "dev": false,
            "test": false,
            "mockupUrl": "/mypage/profile",
            "devUrl": ""
          }
        ]
      }
    ]
  },
  {
    "key": "creator-admin",
    "label": "쏠쏠 크리에이터 관리자단",
    "source": "검증 화면목록 00_화면목록.md · AD01 (v1.2)",
    "screens": [
      {
        "id": "S-AD01-0100-001",
        "name": "대시보드",
        "group": "대시보드",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0901-001",
        "name": "통계 - 학습자 통계",
        "group": "통계",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0902-001",
        "name": "통계 - 매출 통계",
        "group": "통계",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0903-001",
        "name": "통계 - 콘텐츠 통계",
        "group": "통계",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9001-001",
        "name": "결제 유예 이용 제한(어드민 차단)",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0301-001",
        "name": "어드민 로그인",
        "group": "인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0302-001",
        "name": "비밀번호 찾기(재설정 메일)",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0302-002",
        "name": "새 비밀번호 설정",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0303-001",
        "name": "어드민 회원가입",
        "group": "인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9002-001",
        "name": "알림센터",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9003-001",
        "name": "내 정보(계정 정보)",
        "group": "문의·계정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-9003-001_pu01",
            "name": "프로필 설정 모달(5MB·5:5 크롭)",
            "group": "문의·계정",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-9004-001",
        "name": "1:1 문의 관리(목록)",
        "group": "문의·계정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9004-002",
        "name": "1:1 문의 상세",
        "group": "문의·계정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9004-003",
        "name": "1:1 문의 수정",
        "group": "문의·계정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9005-001",
        "name": "크레딧 관리",
        "group": "크레딧",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-9005-001_pu01",
            "name": "크레딧 영수증 모달",
            "group": "크레딧",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-9005-001_pu02",
            "name": "크레딧 상세 모달(결제취소)",
            "group": "크레딧",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-9005-002",
        "name": "크레딧 충전",
        "group": "크레딧",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-9005-003",
        "name": "크레딧 결제완료/실패",
        "group": "크레딧",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0101-001",
        "name": "사용자 - 학습자 목록",
        "group": "사용자",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0101-002",
        "name": "사용자 - 학습자 상세",
        "group": "사용자",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0101-002_pu01",
            "name": "수강 강좌 목록 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0101-002_pu02",
            "name": "구독관리 모달(멤버십/커뮤니티)",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0101-002_pu03",
            "name": "수료여부 변경 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0101-002_pu04",
            "name": "다운로드 내역 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0102-001",
        "name": "사용자 - 강사 목록",
        "group": "사용자",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0102-001_pu01",
            "name": "강사 초대 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0102-002",
        "name": "사용자 - 강사 상세",
        "group": "사용자",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0102-002_pu01",
            "name": "개설 강의 목록 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0102-002_pu02",
            "name": "수강자수 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0103-001",
        "name": "사용자 - 관리자 목록",
        "group": "사용자",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0103-001_pu01",
            "name": "관리자 초대 모달",
            "group": "사용자",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0103-002",
        "name": "사용자 - 관리자 상세",
        "group": "사용자",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0201-001",
        "name": "상품 - 일반강의 목록",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0201-001_pu01",
            "name": "카테고리 선택 모달(목록 필터)",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0201-001_pu02",
            "name": "상품 복사 모달(후기복사 옵션)",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0201-001_pu03",
            "name": "카테고리 이동 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0202-001",
        "name": "상품 - 카테고리 관리",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0202-001_pu01",
            "name": "상품 정렬 설정 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0201-002",
        "name": "일반강의 생성 Step1.상품정보",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0201-002_pu01",
            "name": "썸네일 설정 모달(16:9 크롭)",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0201-002_pu02",
            "name": "카테고리 선택 모달(상품생성·라디오)",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0201-002_pu03",
            "name": "대표강사 추가 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0201-002_pu04",
            "name": "서브강사 추가 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0201-003",
        "name": "일반강의 생성 Step2.커리큘럼",
        "group": "기타",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0201-004",
        "name": "일반강의 생성 Step3.콘텐츠 등록",
        "group": "콘텐츠",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0201-004_pu01",
            "name": "콘텐츠 선택 모달(일반강의·단일)",
            "group": "콘텐츠",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0201-005",
        "name": "일반강의 생성 Step4.결제설정",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0201-006",
        "name": "일반강의 상세페이지(탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0201-006_pu01",
            "name": "수료증 미리보기 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0201-006_pu02",
            "name": "학습기간 설정 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0203-001",
        "name": "상품 - 라이브강의 목록",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0203-002",
        "name": "라이브강의 생성(3단계)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0203-003",
        "name": "라이브강의 상세페이지(탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0204-001",
        "name": "상품 - 화상강의 목록",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0204-002",
        "name": "화상강의 생성(3단계)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0204-003",
        "name": "화상강의 상세페이지(탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0205-001",
        "name": "상품 - 디지털 상품 목록",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0205-002",
        "name": "디지털 상품 생성(3단계)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0205-002_pu01",
            "name": "콘텐츠 선택 모달(디지털·다중)",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0205-003",
        "name": "디지털 상품 상세페이지(탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0205-003_pu01",
            "name": "파일별 다운로드 상태 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0206-001",
        "name": "상품 - 패키지 상품 목록",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0206-002",
        "name": "패키지 상품 생성(3단계)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0206-002_pu01",
            "name": "상품 검색 모달(패키지 구성)",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0206-003",
        "name": "패키지 상품 상세페이지(탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0207-001",
        "name": "상품 - 프리미엄 커뮤니티 목록",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0207-002",
        "name": "프리미엄 커뮤니티 생성(2단계)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0207-003",
        "name": "프리미엄 커뮤니티 상세페이지(탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0207-003_pu01",
            "name": "일괄 고정글설정 모달",
            "group": "상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0207-004",
        "name": "커뮤니티 게시글 쓰기(어드민)",
        "group": "기타",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0207-005",
        "name": "커뮤니티 게시글 상세(어드민)",
        "group": "기타",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0208-001",
        "name": "상품 - 멤버십(목록·탭형)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0208-002",
        "name": "멤버십 생성(2단계)",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0208-003",
        "name": "멤버십 상세페이지",
        "group": "상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0301-001",
        "name": "콘텐츠 라이브러리(목록)",
        "group": "콘텐츠",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0301-002",
        "name": "콘텐츠 - 폴더 관리",
        "group": "콘텐츠",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0301-002_pu01",
            "name": "폴더 이동 모달(라이브러리 일괄)",
            "group": "콘텐츠",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0301-003",
        "name": "콘텐츠 등록(업로드)",
        "group": "콘텐츠",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0301-004",
        "name": "콘텐츠 상세페이지(탭형)",
        "group": "콘텐츠",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0301-004_pu01",
            "name": "폴더 변경 모달(콘텐츠 상세)",
            "group": "콘텐츠",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0301-005",
        "name": "콘텐츠 - 자막 편집",
        "group": "콘텐츠",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0401-001",
        "name": "판매 - 주문(목록)",
        "group": "판매",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0401-002",
        "name": "주문 상세페이지",
        "group": "판매",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0402-001",
        "name": "판매 - 쿠폰(목록)",
        "group": "판매",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0402-002",
        "name": "쿠폰 등록/수정/조회(일원화)",
        "group": "판매",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0402-002_pu01",
            "name": "개별 상품 선택 모달(쿠폰 적용범위)",
            "group": "판매",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0403-001",
        "name": "판매 - 환불(목록)",
        "group": "판매",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0403-002",
        "name": "환불 상세/접수",
        "group": "판매",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0501-001",
        "name": "운영 - 게시판(목록)",
        "group": "운영",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0501-002",
        "name": "게시판 생성",
        "group": "운영",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0501-003",
        "name": "게시판 상세페이지(탭형)",
        "group": "운영",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0501-004",
        "name": "게시판 상세(자유게시판)",
        "group": "운영",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0501-004_pu01",
            "name": "일괄 비밀글설정 모달",
            "group": "운영",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0502-001",
        "name": "운영 - 팝업(목록)",
        "group": "운영",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0502-002",
        "name": "팝업 생성/수정",
        "group": "운영",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0502-002_pu01",
            "name": "팝업 이미지 설정 모달(4:5 크롭)",
            "group": "운영",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0601-001",
        "name": "마케팅 - 캠페인(목록)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0601-002",
        "name": "캠페인 생성/수정",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0601-002_pu01",
            "name": "설문폼 추가 모달(캠페인)",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0601-002_pu02",
            "name": "테스트 발송 모달",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0602-001",
        "name": "마케팅 - 발송내역(목록)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0602-002",
        "name": "발송내역 상세",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0602-002_pu01",
            "name": "재발송 모달(발송내역 상세)",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0603-001",
        "name": "마케팅 - 수신자 그룹(목록)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0603-002",
        "name": "수신자 그룹 생성/수정",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0603-002_pu01",
            "name": "수신자 추가 모달(개인별)",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0604-001",
        "name": "마케팅 - 메시지 템플릿(목록)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0604-001_pu01",
            "name": "메시지 템플릿 미리보기 모달",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0604-002",
        "name": "메시지 템플릿 생성/수정",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0605-001",
        "name": "마케팅 - 설문폼 관리(목록)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0605-001_pu01",
            "name": "설문폼 미리보기 모달",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0605-002",
        "name": "설문폼 상세/등록(탭형)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0605-002_pu01",
            "name": "설문 추가 모달(질문 추가)",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0605-002_pu02",
            "name": "답변 보기 모달(개별 응답)",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0605-002_pu03",
            "name": "알림톡 발송번호 선택 모달",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0606-001",
        "name": "마케팅 - 마케팅 툴 연동",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0607-001",
        "name": "마케팅 - 가입 랜딩페이지(목록)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0607-002",
        "name": "가입 랜딩페이지 생성/수정(기본형)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0607-002_pu01",
            "name": "가입 랜딩(기본형) 미리보기 모달",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0607-003",
        "name": "가입 랜딩페이지 생성/수정(확장형)",
        "group": "마케팅",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0607-003_pu01",
            "name": "가입 랜딩(확장형) 미리보기 모달",
            "group": "마케팅",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0701-001",
        "name": "사이트 디자인 - 기본 정보",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0702-001",
        "name": "사이트 디자인 - 메뉴 목록",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0702-002",
        "name": "사이트 디자인 - 메뉴 생성/수정",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0703-001",
        "name": "사이트 디자인 - 페이지 목록",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0703-002",
        "name": "사이트 디자인 - 페이지 생성/수정",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0703-003",
        "name": "사이트 디자인 - 페이지 빌더(꾸미기)",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0703-003_pu01",
            "name": "페이지 빌더 미리보기 모달",
            "group": "사이트 디자인",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0703-003_pu02",
            "name": "로케이션 주소 검색 모달",
            "group": "사이트 디자인",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0703-003_pu03",
            "name": "게시판 섹션 - 게시글 선택 모달(검색·다중)",
            "group": "사이트 디자인",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0703-003_pu04",
            "name": "후기 섹션 - 후기 선택 모달(검색·다중)",
            "group": "사이트 디자인",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          },
          {
            "id": "S-AD01-0703-003_pu05",
            "name": "설문 섹션 - 설문폼 선택 모달(발행상태만)",
            "group": "사이트 디자인",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0704-001",
        "name": "사이트 디자인 - 메타코드",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-0705-001",
        "name": "사이트 디자인 - SEO 설정(3탭)",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-0705-001_pu01",
            "name": "SEO 변수 추가 모달",
            "group": "사이트 디자인",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-0706-001",
        "name": "사이트 디자인 - 푸터",
        "group": "사이트 디자인",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1001-001",
        "name": "정산 - 정산 정보(미등록)",
        "group": "정산",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1001-002",
        "name": "정산 - 정산 정보 등록/수정(3유형)",
        "group": "정산",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1002-001",
        "name": "정산 - 정산 내역 목록",
        "group": "정산",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1002-002",
        "name": "정산 - 정산 내역 상세(3탭)",
        "group": "정산",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1003-001",
        "name": "정산 - 부가세 신고 자료 목록",
        "group": "정산",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1003-002",
        "name": "정산 - 부가세 신고 자료 상세",
        "group": "정산",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1101-001",
        "name": "설정 - 기본정보",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1102-001",
        "name": "설정 - 플레이어",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1103-001",
        "name": "설정 - 수료증 템플릿 목록",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1103-002",
        "name": "설정 - 수료증 템플릿 상세",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-AD01-1104-001",
        "name": "설정 - 강사/관리자 공지 목록",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-1104-001_pu01",
            "name": "노출대상 리스트 보기 모달",
            "group": "설정",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-1104-002",
        "name": "설정 - 공지 등록/수정",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-1104-002_pu01",
            "name": "노출대상 추가 모달",
            "group": "설정",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-1105-001",
        "name": "설정 - 학습자 알림",
        "group": "설정",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-AD01-1105-001_pu01",
            "name": "학습자 알림 미리보기 모달",
            "group": "설정",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-AD01-C10",
        "name": "간단 메모 모달",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      },
      {
        "id": "S-AD01-C11",
        "name": "수신자 그룹 선택 모달",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      },
      {
        "id": "S-AD01-C12",
        "name": "카테고리/개별상품 선택 모달",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      },
      {
        "id": "S-AD01-C13",
        "name": "연결 대상(페이지/게시판) 선택 모달",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      },
      {
        "id": "S-AD01-C14",
        "name": "카카오 채널 연결 모달",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      },
      {
        "id": "S-AD01-C15",
        "name": "어드민 공지 확인 모달(로그인 시)",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      },
      {
        "id": "S-AD01-C16",
        "name": "권한 설정 모달(RBAC 체크트리)",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      }
    ]
  },
  {
    "key": "brand-front",
    "label": "쏠쏠 브랜드 사용자단",
    "source": "검증 화면목록 00_화면목록.md · BR01 (v1.2)",
    "screens": [
      {
        "id": "S-BR01-0101-001",
        "name": "메인(main 랜딩)",
        "group": "메인·소개",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0102-001",
        "name": "플랫폼 소개",
        "group": "메인·소개",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0103-001",
        "name": "프로덕트",
        "group": "메인·소개",
        "design": false,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0104-001",
        "name": "데모보기",
        "group": "메인·소개",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0105-001",
        "name": "주요기능 소개",
        "group": "메인·소개",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0301-001",
        "name": "회원가입 - Free",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0301-002",
        "name": "회원가입(동의 통합 폼)",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-BR01-0301-002_pu01",
            "name": "인증코드 발송 PU(3분 유효)",
            "group": "회원·인증",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-BR01-0301-003",
        "name": "회원가입 - Free 완료",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0302-001",
        "name": "로그인",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0302-002",
        "name": "비밀번호 재설정(인증메일)",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0302-003",
        "name": "새 비밀번호 설정",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-BR01-0302-003_pu01",
            "name": "새 비밀번호 설정 - 완료 컨펌",
            "group": "회원·인증",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-BR01-0401-001",
        "name": "내 사이트 만들기",
        "group": "사이트 관리",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-BR01-0401-001_pu01",
            "name": "도메인 중복 체크 결과",
            "group": "사이트 관리",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-BR01-0401-002",
        "name": "내 사이트 관리(목록)",
        "group": "사이트 관리",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0501-001",
        "name": "공지/소식(목록)",
        "group": "메인·소개",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0501-002",
        "name": "공지/소식 상세",
        "group": "메인·소개",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0601-001",
        "name": "가격(요금제 main)",
        "group": "가격·결제",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0601-002",
        "name": "유료플랜 구매/플랜 업그레이드",
        "group": "회원·인증",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0601-003",
        "name": "결제 완료(최초)",
        "group": "가격·결제",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0601-004",
        "name": "결제 완료(플랜 업그레이드)",
        "group": "가격·결제",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0601-005",
        "name": "결제 실패",
        "group": "가격·결제",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0701-001",
        "name": "문의하기",
        "group": "문의",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0701-002",
        "name": "문의하기 - 접수 완료",
        "group": "문의",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0702-001",
        "name": "마이페이지 - 문의 내역(목록)",
        "group": "문의",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0702-002",
        "name": "마이페이지 - 문의 내역 상세",
        "group": "문의",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0801-001",
        "name": "마이페이지 - 이용상품 정보(상태별)",
        "group": "계정·이용상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-BR01-0801-001_pu01",
            "name": "구독 취소 완료",
            "group": "계정·이용상품",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-BR01-0801-002",
        "name": "마이페이지 - 사용 연장하기",
        "group": "계정·이용상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0901-001",
        "name": "마이페이지 - 계정관리(계정정보)",
        "group": "계정·이용상품",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-0901-002",
        "name": "마이페이지 - 결제 이메일 변경",
        "group": "가격·결제",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": [
          {
            "id": "S-BR01-0901-002_pu01",
            "name": "결제 이메일 인증코드 발송 PU(3분)",
            "group": "가격·결제",
            "design": true,
            "publish": false,
            "dev": false,
            "test": false,
            "mockupUrl": "",
            "devUrl": ""
          }
        ]
      },
      {
        "id": "S-BR01-1001-001",
        "name": "마이페이지 - 결제 내역",
        "group": "가격·결제",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-1101-001",
        "name": "이용약관",
        "group": "약관·정책",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-1101-002",
        "name": "무료약정상품 이용약관",
        "group": "약관·정책",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-1101-003",
        "name": "유료약정상품 이용약관",
        "group": "약관·정책",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-1101-004",
        "name": "개인정보처리방침",
        "group": "약관·정책",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-1101-005",
        "name": "마케팅 정보 수신 동의",
        "group": "약관·정책",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-9001-001",
        "name": "시스템 일부 에러 페이지",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-9001-002",
        "name": "404 페이지",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-9001-003",
        "name": "네트워크 연결 오류",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-9001-004",
        "name": "서비스 긴급점검(전체장애)",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-9001-005",
        "name": "서비스 정기점검",
        "group": "시스템·공통",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": "",
        "modals": []
      },
      {
        "id": "S-BR01-C01",
        "name": "약관 상세보기 모달",
        "group": "공유 모달 컴포넌트",
        "design": true,
        "publish": false,
        "dev": false,
        "test": false,
        "mockupUrl": "",
        "devUrl": ""
      }
    ]
  },
  {
    "key": "brand-admin",
    "label": "쏠쏠 브랜드 관리자단",
    "source": "화면목록 미정 (대기)",
    "screens": [],
    "pending": true
  }
]
