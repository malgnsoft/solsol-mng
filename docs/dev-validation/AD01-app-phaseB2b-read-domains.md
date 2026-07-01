# AD01 신규 앱 — Phase B2b 조회형 전 도메인 실 API 전환 라운드

> 실연동 2차 배치. 1차([B2 실연동](AD01-app-phaseB2-real-integration.md))가 대시보드·사용자였고, 본 라운드는 **나머지 조회형 도메인 전체**를 `/api/proxy/admin/*` 실 request로 전환.

- **일시**: 2026-07-01 (KST)
- **대상**: `solsol-admin/` — 상품·콘텐츠·판매·마케팅·운영·사이트디자인·정산·설정·통계 조회 화면. 백엔드 solsol-api 라이브(무수정).
- **구현**: 병렬 3그룹(P 상품·콘텐츠 / S 판매·마케팅 / O 운영·사이트·정산·설정·통계). **게이트**: qa.

## 종합 판정: ⭕ qa 게이트 통과(blocker 0) — 중 2·하 3 표시 정정 후 배포

## A. 전환 패턴
- 도메인별 어댑터 컴포저블 9종(`app/composables/use{Products,Contents,Sales,Marketing,Ops,Site,Settlement,Settings,Stats}Api.ts`) — `/api/proxy/admin/*` GET(BFF httpOnly 세션) → 응답 shape 매핑 → 실패/빈응답 시 **기존 목 폴백**(회귀 0).

## B. 커버리지 (라이브 실증 · demo-login owner 세션)
- **실데이터 렌더**: 쿠폰 2 · 게시판 3 · 상품 7유형(general 2·나머지 1) · 콘텐츠 · 주문 1(마스킹) · 정산 프로필 · 통계 KPI(sales/members/contents) · site basic/footer · settings basic/player.
- **빈폴백(정상)**: 환불·팝업·캠페인·설문·정산내역/부가세·수료증·공지·템플릿·마케팅툴·메뉴/페이지·콘텐츠폴더 — 실 200 빈 응답 → 목/빈상태.
- **목유지(날조 0·정직 보고)**: 멤버십(등급 tier 구조)·settings/notification(라우트 카탈로그 vs 매트릭스 불일치)·site/meta(키 불일치)·통계 비-KPI(비중·평점·상위상품)·상세/생성/쓰기 — 대응 shape 없음 → 목 유지.

## C. qa 게이트 & 표시 정정
| 심각도 | 결함 | 조치 |
|:--:|---|---|
| 중 | 쿠폰 code 없어 `CPN-{id}` 파생(실코드 오인) | 코드 컬럼 `-`(상세에서 확인)·가짜코드 제거 |
| 중 | 주문 productType membership/course 2값 축약(오분류) | 유형칩 `-`/미확정(실값 상세 배치) |
| 하 | 실연동 도메인 이중마스킹(백엔드 masked에 프론트 재적용) | 실연동 경로 재마스킹 생략·목 폴백만 프론트 마스킹(무해·안전방향) |
| 하 | site/meta 키불일치 / 상품 부속필드 목록 미포함 | 목 유지·정직 보고(상세 배치 대상) |
- 마스킹 유출 0(백엔드 마스킹 신뢰). SSRF 가드(화이트리스트 `admin/*`·`..` 방어·GET/HEAD) 무손상 재확인. 병합 빌드 GREEN.

## D. 배포
- solsol-admin 커밋 **`f89e790`**(origin) → Pages 재배포(`a152a3ca`) → https://solsol-admin.pages.dev. 라이브 스모크: demo-login 200·coupons 200(2)·boards 200(3)·무쿠키 401·페이지 200.

## E. 다음
- **상세(detail) 실 전환**: 유형별 부속필드·주문/쿠폰 상세·상품 부속(일정/정원/구독자/다운로드) 조인.
- **쓰기형 CRUD**: 프록시 GET 전용 → **CSRF 방어 갖춘 전용 BFF 쓰기 핸들러** 신설 후 생성/수정/삭제/상태변경 배선.
- 목록 필터/정렬/페이지네이션 서버 위임. site/meta 키 컨벤션 합의·notification 매트릭스 API·멤버십 등급 조회.
