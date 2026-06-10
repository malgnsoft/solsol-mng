// 자동 생성(시드) — D1 바인딩이 없는 로컬 dev 폴백용. 정본은 D1(solsol-project).
import type { WbsDocument } from '~/composables/useWbs'

export const boardSeed: WbsDocument = {
  "projectName": "쏠쏠",
  "lastUpdated": "2026-06-10",
  "stages": [
    {
      "id": "step-1",
      "no": "Step 1",
      "name": "기획 · 정책",
      "emoji": "🎯",
      "summary": "전체 스펙 리뷰 · 4개 앱 프로토타입 · 서비스 정책(회원/가격/구독/알림/저작권/도메인) 확정",
      "weight": 8,
      "progress": 95,
      "tasks": [
        {
          "id": "step-1-1-1",
          "group": "리뷰 · 프로토타입",
          "title": "전체 스펙 요구사항 리뷰회의",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.01.30",
          "completionDate": "2026.01.30"
        },
        {
          "id": "step-1-1-2",
          "group": "리뷰 · 프로토타입",
          "title": "프로토타입 — Customer Admin",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.01.26",
          "completionDate": "2026.01.26",
          "href": "https://creatorlms-admin.pages.dev/"
        },
        {
          "id": "step-1-1-3",
          "group": "리뷰 · 프로토타입",
          "title": "프로토타입 — Customer Front",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.01.26",
          "completionDate": "2026.01.26",
          "href": "https://front-creator.pages.dev/front/index.html"
        },
        {
          "id": "step-1-1-4",
          "group": "리뷰 · 프로토타입",
          "title": "프로토타입 — Brand site",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.01.23",
          "completionDate": "2026.01.23",
          "href": "https://brand-creator.pages.dev/brand/index.html"
        },
        {
          "id": "step-1-1-5",
          "group": "리뷰 · 프로토타입",
          "title": "프로토타입 — BackOffice",
          "status": "done",
          "owner": "유회광",
          "targetDate": "2026.02.25",
          "completionDate": "2026.02.25",
          "href": "https://juksim.ubik.co.kr/creatorlms/app.php"
        },
        {
          "id": "step-1-2-1",
          "group": "서비스 정책",
          "title": "회원가입 정책 (소셜로그인 · 이메일 인증)",
          "status": "done",
          "owner": "유빅 · 김덕조",
          "note": "CF 소셜로그인만 허용(구글·카카오·네이버·페이스북·애플). 이메일 없으면 가입불가. Brand 회원가입은 이메일/비밀번호.",
          "targetDate": "2026.02.03",
          "completionDate": "2026.02.03"
        },
        {
          "id": "step-1-2-2",
          "group": "서비스 정책",
          "title": "가격 정책 (경쟁사 분석 · 종량제)",
          "status": "done",
          "owner": "김덕조",
          "note": "온라인 3개사 가격체계·Features 비교. Notification·AI 튜터·자동 자막/번역 종량제 설계.",
          "targetDate": "2026.02.06",
          "completionDate": "2026.02.06"
        },
        {
          "id": "step-1-2-3",
          "group": "서비스 정책",
          "title": "구독 정책 (결제 · 환불)",
          "status": "done",
          "owner": "김덕조",
          "note": "Creator LMS 구독정책 초안 완료.",
          "targetDate": "2026.02.13",
          "completionDate": "2026.02.13"
        },
        {
          "id": "step-1-2-4",
          "group": "서비스 정책",
          "title": "닉네임 정책",
          "status": "done",
          "owner": "김혜인",
          "targetDate": "2026.02.13",
          "completionDate": "2026.02.13"
        },
        {
          "id": "step-1-2-5",
          "group": "서비스 정책",
          "title": "컨텐츠 및 저작권 정책 (DRM)",
          "status": "done",
          "owner": "방준영",
          "note": "콘텐츠 소유권(강사 vs 쏠쏠)·무단복제·라이선스 관리.",
          "targetDate": "2026.02.13",
          "completionDate": "2026.02.13"
        },
        {
          "id": "step-1-2-6",
          "group": "서비스 정책",
          "title": "멤버십 상품 / 프리미엄 콘텐츠 정책",
          "status": "done",
          "owner": "김혜인",
          "note": "최초 6개 상품 구성(크리에이터 ON/OFF). 디지털 다운로드 옵션.",
          "targetDate": "2026.02.13",
          "completionDate": "2026.02.13"
        },
        {
          "id": "step-1-2-7",
          "group": "서비스 정책",
          "title": "게시판 · 결제 · 1:1문의 정책",
          "status": "done",
          "owner": "김혜인",
          "targetDate": "2026.02.13",
          "completionDate": "2026.02.13"
        },
        {
          "id": "step-1-2-8",
          "group": "서비스 정책",
          "title": "알림 정책 (알림톡 · SMS · 메일 템플릿)",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.02.27",
          "completionDate": "2026.02.27"
        },
        {
          "id": "step-1-2-9",
          "group": "서비스 정책",
          "title": "브랜딩 작업",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.02.27",
          "completionDate": "2026.02.27"
        },
        {
          "id": "step-1-2-10",
          "group": "서비스 정책",
          "title": "도메인 구조 확정 (solsol.so)",
          "status": "done",
          "owner": "김덕조",
          "note": "CF: {slug}.solsol.so · CA: ceo.solsol.so/@slug · BO: so.solsol.so · Brand: solsol.so",
          "targetDate": "2026.04.15",
          "completionDate": "2026.04.15"
        },
        {
          "id": "step-1-2-11",
          "group": "서비스 정책",
          "title": "BackOffice 정책 (도메인/SSL · 국가/언어 · AI번역 · 환불)",
          "status": "in_progress",
          "owner": "방준영 · 김혜인",
          "targetDate": "2026.03.29"
        }
      ]
    },
    {
      "id": "step-2",
      "no": "Step 2",
      "name": "화면설계",
      "emoji": "📋",
      "summary": "4개 앱 메뉴 구조도 · 화면설계 v1.1 · 알림 기획 · 문구 통일",
      "weight": 10,
      "progress": 90,
      "tasks": [
        {
          "id": "step-2-1-1",
          "group": "메뉴 구조도",
          "title": "Customer Admin 메뉴 구조도",
          "status": "done",
          "owner": "조안이혜",
          "targetDate": "2026.03.13",
          "completionDate": "2026.03.13"
        },
        {
          "id": "step-2-1-2",
          "group": "메뉴 구조도",
          "title": "Customer Front 메뉴 구조도",
          "status": "done",
          "owner": "김혜인",
          "targetDate": "2026.02.10",
          "completionDate": "2026.02.10"
        },
        {
          "id": "step-2-1-3",
          "group": "메뉴 구조도",
          "title": "Brand site 메뉴 구조도",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.02.10",
          "completionDate": "2026.02.10"
        },
        {
          "id": "step-2-1-4",
          "group": "메뉴 구조도",
          "title": "BackOffice 메뉴 구조도",
          "status": "done",
          "owner": "유회광",
          "targetDate": "2026.02.28",
          "completionDate": "2026.02.28"
        },
        {
          "id": "step-2-1-5",
          "group": "메뉴 구조도",
          "title": "Guide site 메뉴 구조도",
          "status": "in_progress",
          "owner": "방준영",
          "targetDate": "2026.06.26"
        },
        {
          "id": "step-2-2-1",
          "group": "화면설계",
          "title": "Customer Admin 화면설계 v1.1",
          "status": "done",
          "owner": "김혜인 · 조안이혜",
          "note": "v1.1 완료(디스크립션 미작성).",
          "targetDate": "2026.04.02",
          "completionDate": "2026.04.02"
        },
        {
          "id": "step-2-2-2",
          "group": "화면설계",
          "title": "Customer Front 화면설계 v1.1",
          "status": "in_progress",
          "owner": "김혜인",
          "note": "v1.1 작업중.",
          "targetDate": "2026.03.04"
        },
        {
          "id": "step-2-2-3",
          "group": "화면설계",
          "title": "Brand site 화면설계 (피그마)",
          "status": "done",
          "owner": "김덕조",
          "targetDate": "2026.03.13",
          "completionDate": "2026.03.13"
        },
        {
          "id": "step-2-2-4",
          "group": "화면설계",
          "title": "BackOffice 화면설계",
          "status": "done",
          "owner": "유회광",
          "targetDate": "2026.03.05",
          "completionDate": "2026.03.05"
        },
        {
          "id": "step-2-2-5",
          "group": "화면설계",
          "title": "Guide site 화면설계",
          "status": "done",
          "owner": "방준영",
          "targetDate": "2026.03.20",
          "completionDate": "2026.03.20"
        },
        {
          "id": "step-2-3-1",
          "group": "알림 · 문구",
          "title": "서비스 알림 기획",
          "status": "done",
          "owner": "김혜인",
          "targetDate": "2026.04.15",
          "completionDate": "2026.04.15"
        },
        {
          "id": "step-2-3-2",
          "group": "알림 · 문구",
          "title": "마케팅 서비스 알림 추가",
          "status": "done",
          "owner": "조안이혜",
          "targetDate": "2026.04.25",
          "completionDate": "2026.04.25"
        },
        {
          "id": "step-2-3-3",
          "group": "알림 · 문구",
          "title": "얼럿/컨펌 문구 통일 정리",
          "status": "done",
          "owner": "조안이혜 · 김혜인",
          "targetDate": "2026.04.16",
          "completionDate": "2026.04.16"
        }
      ]
    },
    {
      "id": "step-3",
      "no": "Step 3",
      "name": "디자인",
      "emoji": "🎨",
      "summary": "Customer Front · Admin · Brand 디자인 시안 · 브랜드 로고",
      "weight": 6,
      "progress": 85,
      "tasks": [
        {
          "id": "step-3-1-1",
          "group": "디자인 시안",
          "title": "Customer Front 시안 (피그마)",
          "status": "done",
          "owner": "전진주",
          "targetDate": "2026.03.20",
          "completionDate": "2026.03.20"
        },
        {
          "id": "step-3-1-2",
          "group": "디자인 시안",
          "title": "Customer Admin 시안",
          "status": "in_progress",
          "owner": "이승미"
        },
        {
          "id": "step-3-1-3",
          "group": "디자인 시안",
          "title": "Brand site - main (피그마)",
          "status": "done",
          "owner": "전진주",
          "targetDate": "2026.03.25",
          "completionDate": "2026.03.25"
        },
        {
          "id": "step-3-1-4",
          "group": "디자인 시안",
          "title": "Brand site - sub",
          "status": "done",
          "owner": "전진주"
        },
        {
          "id": "step-3-2-1",
          "group": "브랜드",
          "title": "브랜드 로고",
          "status": "done",
          "owner": "방준영",
          "targetDate": "2026.03.25",
          "completionDate": "2026.03.25"
        }
      ]
    },
    {
      "id": "step-4",
      "no": "Step 4",
      "name": "퍼블리싱",
      "emoji": "🧩",
      "summary": "Customer Admin · Front · Brand · BackOffice · Guide 퍼블리싱",
      "weight": 8,
      "progress": 70,
      "tasks": [
        {
          "id": "step-4-1-1",
          "group": "퍼블리싱",
          "title": "Customer Admin 퍼블리싱",
          "status": "in_progress",
          "owner": "박윤희",
          "targetDate": "2026.05.31"
        },
        {
          "id": "step-4-1-2",
          "group": "퍼블리싱",
          "title": "Customer Front 퍼블리싱",
          "status": "in_progress",
          "owner": "박윤희",
          "targetDate": "2026.05.31"
        },
        {
          "id": "step-4-1-3",
          "group": "퍼블리싱",
          "title": "Brand site 퍼블리싱",
          "status": "in_progress",
          "owner": "김덕조"
        },
        {
          "id": "step-4-1-4",
          "group": "퍼블리싱",
          "title": "BackOffice 퍼블리싱",
          "status": "in_progress",
          "owner": "유회광"
        },
        {
          "id": "step-4-1-5",
          "group": "퍼블리싱",
          "title": "Guide site 퍼블리싱",
          "status": "pending",
          "owner": "방준영"
        }
      ]
    },
    {
      "id": "step-5",
      "no": "Step 5",
      "name": "개발 설계",
      "emoji": "📐",
      "summary": "개발 플랫폼/방법론 · DB·ERD · 기능명세 · API 명세 · 외부연계 설계",
      "weight": 10,
      "progress": 80,
      "tasks": [
        {
          "id": "step-5-1-1",
          "group": "설계 산출물",
          "title": "개발 플랫폼 세팅 및 방법론 정의",
          "status": "done",
          "owner": "서만원",
          "note": "Frontend/Backend · DB MySQL · 시스템 구성도 · 서버구조(MSA) · API 인증 · 배포 정책.",
          "targetDate": "2026.04.30",
          "completionDate": "2026.04.30",
          "href": "https://github.com/malgnsoft/creatorlms"
        },
        {
          "id": "step-5-1-2",
          "group": "설계 산출물",
          "title": "DB 설계 (테이블 구조 · ERD)",
          "status": "done",
          "owner": "서만원",
          "targetDate": "2026.04.30",
          "completionDate": "2026.04.30"
        },
        {
          "id": "step-5-1-3",
          "group": "설계 산출물",
          "title": "기능명세서 (페이지명세서)",
          "status": "done",
          "owner": "서만원",
          "targetDate": "2026.04.30",
          "completionDate": "2026.04.30"
        },
        {
          "id": "step-5-1-4",
          "group": "설계 산출물",
          "title": "API 명세서 1차",
          "status": "done",
          "owner": "서만원",
          "targetDate": "2026.05.31",
          "completionDate": "2026.05.31"
        },
        {
          "id": "step-5-1-5",
          "group": "설계 산출물",
          "title": "API 명세서 2차",
          "status": "in_progress",
          "owner": "서만원",
          "targetDate": "2026.06.30"
        },
        {
          "id": "step-5-1-6",
          "group": "설계 산출물",
          "title": "외부 연계 설계 (NHN · NICE · PG · 위캔디오 · 펌뱅킹)",
          "status": "in_progress",
          "owner": "서만원",
          "note": "대체로 7/1부터 2개월간 실 연동.",
          "targetDate": "2026.08.31"
        }
      ]
    },
    {
      "id": "step-6",
      "no": "Step 6",
      "name": "서비스 개발",
      "emoji": "🛠️",
      "summary": "종합 베타 진척 44% (dev /progress, 6/7) — CA 45% · BO 66% · CF 17% · Brand 2%. 상세는 WBS 간트.",
      "weight": 43,
      "progress": 44,
      "tasks": [
        {
          "id": "step-6-1-1",
          "group": "공통 · 백엔드",
          "title": "프레임워크 설계 · 개발",
          "status": "done",
          "owner": "서만원",
          "note": "웹앱 개별 세팅.",
          "targetDate": "2026.05.10",
          "completionDate": "2026.05.10"
        },
        {
          "id": "step-6-1-2",
          "group": "공통 · 백엔드",
          "title": "공통 모듈 개발 (코드/파일/약관/메모)",
          "status": "in_progress",
          "owner": "서만원",
          "targetDate": "2026.06.07"
        },
        {
          "id": "step-6-1-3",
          "group": "공통 · 백엔드",
          "title": "외부 API 어댑터 · 연동",
          "status": "in_progress",
          "owner": "조수현 · 서만원",
          "note": "소셜로그인·메시징 적용 · 결제PG·본인인증·위캔디오는 CF 거래데이터 대기.",
          "targetDate": "2026.05.10"
        },
        {
          "id": "step-6-1-4",
          "group": "공통 · 백엔드",
          "title": "API 개발",
          "status": "in_progress",
          "owner": "서만원"
        },
        {
          "id": "step-6-1-5",
          "group": "공통 · 백엔드",
          "title": "배치 프로세스 개발",
          "status": "pending",
          "owner": "서만원"
        },
        {
          "id": "step-6-2-1",
          "group": "Customer Admin",
          "title": "CA — 인증 + 사용자 관리",
          "status": "done",
          "owner": "조수현",
          "note": "[상] 사용자 95% · 목록·상세·탭·모달 배선 완료."
        },
        {
          "id": "step-6-2-2",
          "group": "Customer Admin",
          "title": "CA — 콘텐츠 관리",
          "status": "in_progress",
          "owner": "서만원",
          "note": "[상] 85% · assets·cert·영상(벤더) 잔여."
        },
        {
          "id": "step-6-2-3",
          "group": "Customer Admin",
          "title": "CA — 상품 (강의 · 디지털 · 패키지)",
          "status": "in_progress",
          "owner": "서만원",
          "note": "[상] 78% · 전 상품유형 CRUD 완료 · 후행탭 CF 데이터 의존."
        },
        {
          "id": "step-6-2-4",
          "group": "Customer Admin",
          "title": "CA — 상품 (커뮤니티 · 멤버십)",
          "status": "in_progress",
          "owner": "서만원",
          "note": "[상] 결제/수강생/후기/수료증 후행탭 보류(CF 의존)."
        },
        {
          "id": "step-6-2-5",
          "group": "Customer Admin",
          "title": "CA — 판매 · 마케팅 · 사이트 · 운영 · 정산 · 설정 · 통계",
          "status": "in_progress",
          "owner": "조수현 · 서만원",
          "note": "운영 92%·판매 55%·설정 35%·마케팅 25%·사이트 20%·정산 10%·통계 0%."
        },
        {
          "id": "step-6-3-1",
          "group": "Customer Front",
          "title": "CF — 인증 + 가입 (소셜)",
          "status": "in_progress",
          "owner": "조수현",
          "note": "[상] 소셜 회원가입·로그인."
        },
        {
          "id": "step-6-3-2",
          "group": "Customer Front",
          "title": "CF — 상품 목록/상세 (일반강의)",
          "status": "in_progress",
          "owner": "서만원",
          "note": "[중] 일반강의 55% · 코어 카탈로그 · 상품결제 대기."
        },
        {
          "id": "step-6-3-3",
          "group": "Customer Front",
          "title": "CF — 커뮤니티 · 멤버십 · 마이페이지 · 게시판",
          "status": "pending",
          "owner": "조수현 · 서만원",
          "note": "공지 90% 외 대부분 미착수(상품관리·결제PG·본인인증 선행)."
        },
        {
          "id": "step-6-4-1",
          "group": "Brand site",
          "title": "Brand — 인증 + 가입",
          "status": "pending",
          "owner": "조수현",
          "note": "[상] Brand 전체 2% · 거의 미착수."
        },
        {
          "id": "step-6-4-2",
          "group": "Brand site",
          "title": "Brand — 플랜 구독 (결제)",
          "status": "pending",
          "owner": "서만원",
          "note": "[상]"
        },
        {
          "id": "step-6-4-3",
          "group": "Brand site",
          "title": "Brand — 마이페이지 · 서비스 소개",
          "status": "pending",
          "owner": "조수현 · 서만원"
        },
        {
          "id": "step-6-5-1",
          "group": "BackOffice · 인프라",
          "title": "BackOffice 개발 (범위 미정)",
          "status": "in_progress",
          "owner": "서만원",
          "note": "전체 66% · 고객·테넌트 90%·개발자 95% · 결제정산·운영도구는 CF 거래데이터 대기."
        },
        {
          "id": "step-6-5-2",
          "group": "BackOffice · 인프라",
          "title": "AI 튜터 설계 및 개발",
          "status": "pending",
          "owner": "김도형"
        },
        {
          "id": "step-6-5-3",
          "group": "BackOffice · 인프라",
          "title": "학습분석리포트 설계",
          "status": "pending",
          "owner": "김도형"
        },
        {
          "id": "step-6-5-4",
          "group": "BackOffice · 인프라",
          "title": "인프라 구축",
          "status": "in_progress",
          "owner": "맑은소프트",
          "note": "클라우드 · 도메인 · SSL."
        },
        {
          "id": "step-6-5-5",
          "group": "BackOffice · 인프라",
          "title": "CI/CD",
          "status": "in_progress",
          "owner": "맑은소프트"
        }
      ]
    },
    {
      "id": "step-7",
      "no": "Step 7",
      "name": "운영 · 계약",
      "emoji": "📦",
      "summary": "운영 방안 · 약관/개인정보 · QA · 마케팅(크리에이터 섭외) · 외부 계약(PG·NHN·펌뱅킹·NICE)",
      "weight": 15,
      "progress": 15,
      "tasks": [
        {
          "id": "step-7-1-1",
          "group": "운영 방안",
          "title": "운영 서비스 기획",
          "status": "in_progress",
          "owner": "방준영"
        },
        {
          "id": "step-7-1-2",
          "group": "운영 방안",
          "title": "이용약관 · 개인정보처리방침 셋팅",
          "status": "pending",
          "owner": "방준영",
          "note": "화면설계 및 정책서 이후 작업."
        },
        {
          "id": "step-7-1-3",
          "group": "운영 방안",
          "title": "정산 운영 방안 (기업 펌뱅킹)",
          "status": "pending",
          "owner": "방준영",
          "note": "신한은행 · K뱅크 · 카카오뱅크 중 택일."
        },
        {
          "id": "step-7-2-1",
          "group": "테스트 · 정책",
          "title": "전체 QA (기획·디자인·퍼블리싱 산출물 체크)",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-2-2",
          "group": "테스트 · 정책",
          "title": "운영가이드 작업",
          "status": "pending",
          "owner": "방준영"
        },
        {
          "id": "step-7-2-3",
          "group": "테스트 · 정책",
          "title": "FAQ 작성 · 마케팅동의 약관",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-3-1",
          "group": "마케팅",
          "title": "크리에이터 섭외 (베타오픈 10명)",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-3-2",
          "group": "마케팅",
          "title": "알림 마케팅 기획 · 오픈 프로모션",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-4-1",
          "group": "외부 계약",
          "title": "토스페이먼츠 PG 계약",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-4-2",
          "group": "외부 계약",
          "title": "NHN Cloud 신청",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-4-3",
          "group": "외부 계약",
          "title": "신한은행 펌뱅킹 계약",
          "status": "pending",
          "owner": "미정"
        },
        {
          "id": "step-7-4-4",
          "group": "외부 계약",
          "title": "나이스평가정보 심사 및 계약",
          "status": "pending",
          "owner": "미정"
        }
      ]
    }
  ]
}
