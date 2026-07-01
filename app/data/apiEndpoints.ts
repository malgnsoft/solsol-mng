// 쏠쏠 크리에이터 백엔드(solsol-api) API 엔드포인트 인벤토리 — 정적 데이터.
// 정본:
//  - 사용자단(FR01): scratchpad/inventory-front.md (조백개 · 프론트 HTTP 계약 인벤토리)
//  - 관리자단(AD01): scratchpad/inventory-admin.md (임관개 · 관리자 엔드포인트 역도출)
// 실제 마운트 프리픽스: 사용자단 /api/* (+ 기구현 /auth·/me·/tenant), 관리자단 /api/admin/* (일부는 공용 /api/* + roleGuard).
// gate = 비가역 게이트(결제/환불/정산/크레딧/발송/구독) 여부.
// status: '기구현'(solsol-api 실구현·계약 일치) | '구현'(신규 구현 대상, 계약 확정) | '게이트'(비가역·확인 필요 액션).

export type ApiArea = 'FR01' | 'AD01'
export type ApiMethod = 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE'
export type ApiAuth = 'public' | 'user' | 'staff'
export type ApiStatus = '기구현' | '구현' | '게이트'

export interface ApiEndpoint {
  id: string
  domain: string
  area: ApiArea
  method: ApiMethod
  path: string
  auth: ApiAuth
  /** staff 인증 시 roleGuard 메뉴키(RBAC 화이트리스트) */
  menuKey?: string
  summary: string
  requestSummary: string
  responseSummary: string
  gate: boolean
  status: ApiStatus
  /** 비고: 멱등/마스킹/추정경로 등 */
  notes?: string
}

// ─────────────────────────────────────────────────────────────
// 사용자단 (FR01) — inventory-front.md §2
// ─────────────────────────────────────────────────────────────
const front: ApiEndpoint[] = [
  // 2.1 auth
  { id: 'FR-auth-authorize', domain: 'auth', area: 'FR01', method: 'GET', path: '/auth/social/authorize', auth: 'public', summary: '소셜 로그인 인가 시작(리다이렉트)', requestSummary: 'query: provider(google/kakao/naver/facebook/apple)', responseSummary: '브라우저 리다이렉트(JSON 아님)', gate: false, status: '기구현', notes: 'window.location.href 이동' },
  { id: 'FR-auth-callback', domain: 'auth', area: 'FR01', method: 'POST', path: '/auth/social/callback', auth: 'public', summary: '소셜 콜백 — 신규/기존 분기', requestSummary: 'body: { provider, code, state } · credentials:include', responseSummary: '신규 { isNew, signupTicket } / 기존 { access, user, needsTerms }', gate: false, status: '기구현', notes: 'err: OAUTH_FAILED/STATE_INVALID' },
  { id: 'FR-auth-nickname', domain: 'auth', area: 'FR01', method: 'GET', path: '/auth/nickname/check', auth: 'public', summary: '닉네임 중복 확인', requestSummary: 'query: nickname', responseSummary: '{ available: boolean }', gate: false, status: '기구현' },
  { id: 'FR-auth-signup', domain: 'auth', area: 'FR01', method: 'POST', path: '/auth/signup', auth: 'public', summary: '가입 확정(약관 동의)', requestSummary: 'body: { signupTicket, nickname, agreements[] } · credentials:include', responseSummary: '{ user, access }', gate: false, status: '기구현', notes: 'err: TERMS_REQUIRED/NICKNAME_DUP/TICKET_EXPIRED' },
  { id: 'FR-auth-refresh', domain: 'auth', area: 'FR01', method: 'POST', path: '/auth/refresh', auth: 'public', summary: '액세스 토큰 재발급', requestSummary: '(바디없음) · credentials:include(refresh 쿠키)', responseSummary: '{ access }', gate: false, status: '기구현' },
  { id: 'FR-auth-logout', domain: 'auth', area: 'FR01', method: 'POST', path: '/auth/logout', auth: 'user', summary: '로그아웃', requestSummary: '(바디없음) · credentials:include', responseSummary: '—', gate: false, status: '기구현' },

  // 2.2 me
  { id: 'FR-me-get', domain: 'me', area: 'FR01', method: 'GET', path: '/me', auth: 'user', summary: '내 프로필 조회', requestSummary: '(헤더 Bearer)', responseSummary: 'UserProfile', gate: false, status: '기구현' },
  { id: 'FR-me-patch', domain: 'me', area: 'FR01', method: 'PATCH', path: '/me', auth: 'user', summary: '내 프로필 수정(부분)', requestSummary: 'body: { avatarUrl } | { nickname } | { marketingAgreed }', responseSummary: 'UserProfile(갱신본)', gate: false, status: '기구현' },
  { id: 'FR-me-delete', domain: 'me', area: 'FR01', method: 'DELETE', path: '/me', auth: 'user', summary: '회원 탈퇴', requestSummary: 'body: { reason, detail } · credentials:include', responseSummary: '—', gate: false, status: '기구현' },
  { id: 'FR-me-social-unlink', domain: 'me', area: 'FR01', method: 'DELETE', path: '/me/socials/:provider', auth: 'user', summary: 'SNS 연결 해제', requestSummary: 'path: provider', responseSummary: '{ socials: SocialLink[] }', gate: false, status: '기구현', notes: 'err: PRIMARY_UNLINK_BLOCKED/LAST_SOCIAL' },

  // 2.3 tenant
  { id: 'FR-tenant-get', domain: 'tenant', area: 'FR01', method: 'GET', path: '/tenant', auth: 'public', summary: '사이트(테넌트) 메타 조회', requestSummary: 'X-Tenant 헤더 or host 기반', responseSummary: '{ id, name, slug, termsVersion, siteConfig?, bizInfo? }', gate: false, status: '기구현' },

  // 2.4 products
  { id: 'FR-products-list', domain: 'products', area: 'FR01', method: 'GET', path: '/api/products', auth: 'public', summary: '상품 목록', requestSummary: 'query: site_id, category, type, sale_status, live_status, platform, q, sort', responseSummary: '{ items: Product[], total }', gate: false, status: '구현' },
  { id: 'FR-products-detail', domain: 'products', area: 'FR01', method: 'GET', path: '/api/products/:id', auth: 'public', summary: '상품 상세', requestSummary: 'path: id', responseSummary: 'ProductDetail', gate: false, status: '구현' },
  { id: 'FR-categories-list', domain: 'products', area: 'FR01', method: 'GET', path: '/api/categories', auth: 'public', summary: '카테고리 목록', requestSummary: 'query: site_id', responseSummary: '{ id, name }[]', gate: false, status: '구현' },
  { id: 'FR-my-products', domain: 'products', area: 'FR01', method: 'GET', path: '/api/my-products', auth: 'user', summary: '내 수강상품', requestSummary: 'query: site_id, type, completion, q, sort', responseSummary: '{ items: MyProduct[], total }', gate: false, status: '구현' },
  { id: 'FR-review-create', domain: 'products', area: 'FR01', method: 'POST', path: '/api/products/:productId/reviews', auth: 'user', summary: '후기 작성', requestSummary: 'body: { rating, content }', responseSummary: 'ProductReview', gate: false, status: '구현' },
  { id: 'FR-review-update', domain: 'products', area: 'FR01', method: 'PATCH', path: '/api/reviews/:reviewId', auth: 'user', summary: '후기 수정', requestSummary: 'body: { rating, content }', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-review-delete', domain: 'products', area: 'FR01', method: 'DELETE', path: '/api/reviews/:reviewId', auth: 'user', summary: '후기 삭제', requestSummary: 'path: reviewId', responseSummary: '—', gate: false, status: '구현' },

  // 2.5 learning
  { id: 'FR-classroom', domain: 'learning', area: 'FR01', method: 'GET', path: '/api/classrooms/:productId', auth: 'user', summary: '수강 강의실', requestSummary: 'path: productId, query: site_id', responseSummary: 'ClassroomData(sections 등)', gate: false, status: '구현' },
  { id: 'FR-progress', domain: 'learning', area: 'FR01', method: 'POST', path: '/api/enrollments/:enrollmentId/progress', auth: 'user', summary: '진도 리포트', requestSummary: 'body: { chapterId, position_sec, completed }', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-classroom-dash', domain: 'learning', area: 'FR01', method: 'GET', path: '/api/classrooms/:productId/dashboard', auth: 'user', summary: '수강 대시보드', requestSummary: 'path: productId, query: site_id', responseSummary: 'DashboardData', gate: false, status: '구현' },
  { id: 'FR-liveroom', domain: 'learning', area: 'FR01', method: 'GET', path: '/api/live-rooms/:productId', auth: 'user', summary: '라이브 강의실', requestSummary: 'path: productId, query: site_id', responseSummary: 'LiveRoomData', gate: false, status: '구현' },
  { id: 'FR-livechat-get', domain: 'learning', area: 'FR01', method: 'GET', path: '/api/live-rooms/:productId/chat', auth: 'user', summary: '라이브 채팅 조회(폴링)', requestSummary: 'path: productId', responseSummary: 'LiveChatMessage[]', gate: false, status: '구현' },
  { id: 'FR-livechat-post', domain: 'learning', area: 'FR01', method: 'POST', path: '/api/live-rooms/:productId/chat', auth: 'user', summary: '라이브 채팅 전송', requestSummary: 'body: { content }', responseSummary: 'LiveChatMessage', gate: false, status: '구현' },

  // 2.6 order / payment
  { id: 'FR-orders-list', domain: 'order', area: 'FR01', method: 'GET', path: '/api/orders', auth: 'user', summary: '내 주문/결제내역', requestSummary: 'query: site_id, type, status, sort', responseSummary: '{ items: MyOrder[], summary, total }', gate: false, status: '구현' },
  { id: 'FR-order-cancel', domain: 'order', area: 'FR01', method: 'POST', path: '/api/orders/:orderId/cancel', auth: 'user', summary: '주문 취소/환불', requestSummary: 'path: orderId', responseSummary: '취소 결과', gate: true, status: '게이트', notes: '환불 = 비가역. 정책상 관리자 확인 흐름' },
  { id: 'FR-checkout', domain: 'order', area: 'FR01', method: 'GET', path: '/api/orders/checkout', auth: 'user', summary: '체크아웃 상품 로드', requestSummary: 'query: site_id, product_ids(다중)', responseSummary: '{ items: CheckoutProduct[] }', gate: false, status: '구현' },
  { id: 'FR-order-create', domain: 'order', area: 'FR01', method: 'POST', path: '/api/orders', auth: 'user', summary: '결제 실행(주문 생성)', requestSummary: 'body: { product_ids[], coupon_id?, billing_card_id?, agreed_terms? }', responseSummary: 'CreateOrderResult{ orderNo, success, amount, ... }', gate: true, status: '게이트', notes: '멱등성 키 필요(중복 과금 차단)' },
  { id: 'FR-coupons-usable', domain: 'order', area: 'FR01', method: 'GET', path: '/api/coupons/usable', auth: 'user', summary: '체크아웃 사용가능 쿠폰', requestSummary: 'query: site_id', responseSummary: '{ items: CheckoutCoupon[] }', gate: false, status: '구현' },
  { id: 'FR-cards-list', domain: 'order', area: 'FR01', method: 'GET', path: '/api/billing/cards', auth: 'user', summary: '빌링 카드 목록', requestSummary: 'query: site_id', responseSummary: '{ items: BillingCard[] } (usePayment는 { cards })', gate: false, status: '구현', notes: '응답 래핑 불일치(items vs cards) — 계약 확정 필요. 카드 부분마스킹' },
  { id: 'FR-card-primary', domain: 'order', area: 'FR01', method: 'PATCH', path: '/api/billing/cards/:cardId/primary', auth: 'user', summary: '대표카드 지정', requestSummary: 'path: cardId', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-card-delete', domain: 'order', area: 'FR01', method: 'DELETE', path: '/api/billing/cards/:cardId', auth: 'user', summary: '카드 삭제', requestSummary: 'path: cardId', responseSummary: '—', gate: false, status: '구현' },

  // 2.7 subscription
  { id: 'FR-sub-products-comm', domain: 'subscription', area: 'FR01', method: 'GET', path: '/api/subscription-products', auth: 'public', summary: '구독상품 목록(커뮤니티/멤버십)', requestSummary: 'query: site_id, type(community|membership), preview?', responseSummary: '{ items: SubscriptionProduct[] }', gate: false, status: '구현' },
  { id: 'FR-sub-product-detail', domain: 'subscription', area: 'FR01', method: 'GET', path: '/api/subscription-products/:id', auth: 'public', summary: '구독상품 상세', requestSummary: 'path: id', responseSummary: 'SubscriptionProduct', gate: false, status: '구현' },
  { id: 'FR-sub-current', domain: 'subscription', area: 'FR01', method: 'GET', path: '/api/subscriptions/current', auth: 'user', summary: '현재 구독 상태', requestSummary: '—', responseSummary: 'SubscriptionStatus', gate: false, status: '구현' },
  { id: 'FR-sub-create', domain: 'subscription', area: 'FR01', method: 'POST', path: '/api/subscriptions', auth: 'user', summary: '구독 시작', requestSummary: 'body: { plan, billing_cycle }', responseSummary: 'SubscriptionStatus', gate: true, status: '게이트', notes: '정기결제 — 멱등성 권장' },
  { id: 'FR-sub-plan', domain: 'subscription', area: 'FR01', method: 'PATCH', path: '/api/subscriptions/:currentSubscriptionId/plan', auth: 'user', summary: '플랜 변경', requestSummary: 'body: { plan }', responseSummary: '—', gate: true, status: '게이트', notes: '과금 변동 수반' },
  { id: 'FR-sub-mine', domain: 'subscription', area: 'FR01', method: 'GET', path: '/api/subscriptions/mine', auth: 'user', summary: '내 구독 목록', requestSummary: '—', responseSummary: '{ membership, communities[] }', gate: false, status: '구현' },
  { id: 'FR-sub-cancel', domain: 'subscription', area: 'FR01', method: 'DELETE', path: '/api/subscriptions/:subscriptionId', auth: 'user', summary: '구독 해지(즉시/만료)', requestSummary: 'body: { mode }', responseSummary: 'SubscriptionStatus', gate: true, status: '게이트', notes: '해지 = 비가역 정산 영향' },

  // 2.8 coupon
  { id: 'FR-coupons-mine', domain: 'coupon', area: 'FR01', method: 'GET', path: '/api/coupons/mine', auth: 'user', summary: '내 쿠폰', requestSummary: 'query: site_id', responseSummary: '{ claimable[], available[] }', gate: false, status: '구현' },
  { id: 'FR-coupon-claim', domain: 'coupon', area: 'FR01', method: 'POST', path: '/api/coupons/:couponId/claim', auth: 'user', summary: '쿠폰 발급받기', requestSummary: 'path: couponId', responseSummary: '—', gate: true, status: '게이트', notes: '이중 발급 차단 — 멱등성 권장' },

  // 2.9 board / community
  { id: 'FR-posts-list', domain: 'board', area: 'FR01', method: 'GET', path: '/api/boards/:boardId/posts', auth: 'user', summary: '게시판 글 목록', requestSummary: 'path: boardId, query: site_id, q', responseSummary: '{ items: BoardPostSummary[], total, boardName }', gate: false, status: '구현' },
  { id: 'FR-post-detail', domain: 'board', area: 'FR01', method: 'GET', path: '/api/boards/:boardId/posts/:postId', auth: 'user', summary: '글 상세', requestSummary: 'path: boardId, postId', responseSummary: 'BoardPost', gate: false, status: '구현' },
  { id: 'FR-post-create', domain: 'board', area: 'FR01', method: 'POST', path: '/api/boards/:boardId/posts', auth: 'user', summary: '글 작성', requestSummary: 'body: { title, contentHtml, attachmentIds[], isSecret? }', responseSummary: '{ id }', gate: false, status: '구현' },
  { id: 'FR-post-update', domain: 'board', area: 'FR01', method: 'PATCH', path: '/api/posts/:postId', auth: 'user', summary: '글 수정', requestSummary: 'body: { title, contentHtml, attachmentIds, isSecret? }', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-post-delete', domain: 'board', area: 'FR01', method: 'DELETE', path: '/api/posts/:postId', auth: 'user', summary: '글 삭제', requestSummary: 'path: postId', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-comments-list', domain: 'board', area: 'FR01', method: 'GET', path: '/api/posts/:postId/comments', auth: 'user', summary: '댓글 목록', requestSummary: 'path: postId', responseSummary: '{ items: BoardComment[] }', gate: false, status: '구현' },
  { id: 'FR-comment-create', domain: 'board', area: 'FR01', method: 'POST', path: '/api/posts/:postId/comments', auth: 'user', summary: '댓글 작성', requestSummary: 'body: { content, depth, parentId, replyToNickname, imageUrl, isSecret? }', responseSummary: 'BoardComment', gate: false, status: '구현' },
  { id: 'FR-comment-update', domain: 'board', area: 'FR01', method: 'PATCH', path: '/api/comments/:commentId', auth: 'user', summary: '댓글 수정', requestSummary: 'body: { content, imageUrl }', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-comment-delete', domain: 'board', area: 'FR01', method: 'DELETE', path: '/api/comments/:commentId', auth: 'user', summary: '댓글 삭제', requestSummary: 'path: commentId', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-upload-attachment', domain: 'board', area: 'FR01', method: 'POST', path: '/api/uploads/attachment', auth: 'user', summary: '첨부 업로드(multipart)', requestSummary: 'FormData(file)', responseSummary: 'BoardAttachmentFile', gate: false, status: '구현' },
  { id: 'FR-upload-image', domain: 'board', area: 'FR01', method: 'POST', path: '/api/uploads/image', auth: 'user', summary: '본문 이미지 업로드(multipart)', requestSummary: 'FormData(file)', responseSummary: '{ url, sizeBytes }', gate: false, status: '구현' },

  // 2.10 faq
  { id: 'FR-faqs', domain: 'faq', area: 'FR01', method: 'GET', path: '/api/faqs', auth: 'public', summary: 'FAQ 목록', requestSummary: 'query: site_id, q, category', responseSummary: '{ items: FaqItem[], total, categories[] }', gate: false, status: '구현' },

  // 2.11 inquiry
  { id: 'FR-inquiries-list', domain: 'inquiry', area: 'FR01', method: 'GET', path: '/api/inquiries', auth: 'user', summary: '내 문의 목록', requestSummary: 'query: site_id, q', responseSummary: '{ items: InquirySummary[], total }', gate: false, status: '구현' },
  { id: 'FR-inquiry-detail', domain: 'inquiry', area: 'FR01', method: 'GET', path: '/api/inquiries/:id', auth: 'user', summary: '문의 상세', requestSummary: 'path: id', responseSummary: 'InquiryDetail', gate: false, status: '구현' },
  { id: 'FR-inquiry-create', domain: 'inquiry', area: 'FR01', method: 'POST', path: '/api/inquiries', auth: 'user', summary: '문의 작성', requestSummary: 'body: { type, title, contentHtml, refInfo, attachmentIds[] }', responseSummary: '{ id }', gate: false, status: '구현' },
  { id: 'FR-inquiry-delete', domain: 'inquiry', area: 'FR01', method: 'DELETE', path: '/api/inquiries/:id', auth: 'user', summary: '문의 삭제', requestSummary: 'path: id', responseSummary: '—', gate: false, status: '구현' },
  { id: 'FR-inquiry-reply', domain: 'inquiry', area: 'FR01', method: 'POST', path: '/api/inquiries/:inquiryId/replies', auth: 'user', summary: '문의 답글(스레드)', requestSummary: 'body: { content, imageUrl }', responseSummary: 'BoardComment', gate: false, status: '구현' },

  // 2.12 certificate — 실제 마운트 /api/me/certificates
  { id: 'FR-cert-list', domain: 'certificate', area: 'FR01', method: 'GET', path: '/api/me/certificates', auth: 'user', summary: '수료증 목록', requestSummary: 'query: site_id, type, issue_status, sort, q', responseSummary: '{ items: CertificateCardItem[], total }', gate: false, status: '구현' },
  { id: 'FR-cert-detail', domain: 'certificate', area: 'FR01', method: 'GET', path: '/api/me/certificates/:id', auth: 'user', summary: '수료증 상세', requestSummary: 'path: id', responseSummary: 'CertificateDetail', gate: false, status: '구현' },
  { id: 'FR-cert-pdf', domain: 'certificate', area: 'FR01', method: 'GET', path: '/api/me/certificates/:id/pdf', auth: 'user', summary: '수료증 PDF 다운로드', requestSummary: 'path: id', responseSummary: '파일 or 서명 URL(형태 모호)', gate: false, status: '구현', notes: '응답 형태 계약 미정(바이너리 vs URL)' },

  // 2.13 notification — 실제 마운트 /api/me/notifications
  { id: 'FR-noti-list', domain: 'notification', area: 'FR01', method: 'GET', path: '/api/me/notifications', auth: 'user', summary: '알림 목록', requestSummary: 'query: site_id', responseSummary: '{ items: NotificationItem[] }', gate: false, status: '구현' },
  { id: 'FR-noti-readall', domain: 'notification', area: 'FR01', method: 'POST', path: '/api/me/notifications/read-all', auth: 'user', summary: '모두 읽음 처리', requestSummary: '(바디없음)', responseSummary: '—', gate: false, status: '구현' },

  // 2.14 wishlist
  { id: 'FR-wishlist', domain: 'wishlist', area: 'FR01', method: 'GET', path: '/api/wishlist', auth: 'user', summary: '위시리스트 목록', requestSummary: 'query: site_id', responseSummary: '{ items: Product[] }', gate: false, status: '구현' },
  { id: 'FR-wishlist-add', domain: 'wishlist', area: 'FR01', method: 'POST', path: '/api/products/:productId/wishlist', auth: 'user', summary: '찜 추가(토글)', requestSummary: 'path: productId', responseSummary: '{ isWished: boolean }', gate: false, status: '구현' },
  { id: 'FR-wishlist-remove', domain: 'wishlist', area: 'FR01', method: 'DELETE', path: '/api/products/:productId/wishlist', auth: 'user', summary: '찜 해제', requestSummary: 'path: productId', responseSummary: '—', gate: false, status: '구현' },
]

// ─────────────────────────────────────────────────────────────
// 관리자단 (AD01) — inventory-admin.md §2 (경로 상당수 [추정])
// ─────────────────────────────────────────────────────────────
const admin: ApiEndpoint[] = [
  // 2.1 인증/프로필
  { id: 'AD-auth-login', domain: 'auth', area: 'AD01', method: 'POST', path: '/api/auth/login', auth: 'public', summary: '관리자/강사 로그인', requestSummary: 'body: { email, password, role, site_id }', responseSummary: '{ token, user }', gate: false, status: '구현', notes: '06 §2.2 확정. err UNREGISTERED/MISMATCH/ROLE_MISMATCH/SUSPENDED' },
  { id: 'AD-auth-signup', domain: 'auth', area: 'AD01', method: 'POST', path: '/api/auth/signup', auth: 'public', summary: '관리자 가입', requestSummary: 'body: { site_id, email, password, name, agreements[] }', responseSummary: '201 { user, token }', gate: false, status: '구현', notes: '06 §2.3 확정' },
  { id: 'AD-auth-code-issue', domain: 'auth', area: 'AD01', method: 'POST', path: '/api/auth/email-code/issue', auth: 'public', summary: '이메일 인증코드 발급', requestSummary: 'body: { purpose, email }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §2.4. TTL 600/1800/172800s' },
  { id: 'AD-auth-code-verify', domain: 'auth', area: 'AD01', method: 'POST', path: '/api/auth/email-code/verify', auth: 'public', summary: '이메일 인증코드 검증', requestSummary: 'body: { email, code }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §2.4' },
  { id: 'AD-auth-reset-req', domain: 'auth', area: 'AD01', method: 'POST', path: '/api/auth/password/reset-request', auth: 'public', summary: '비밀번호 재설정 요청', requestSummary: 'body: { email }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §2.5. 연속 10회 RATE_LIMIT' },
  { id: 'AD-auth-reset', domain: 'auth', area: 'AD01', method: 'POST', path: '/api/auth/password/reset', auth: 'public', summary: '비밀번호 재설정', requestSummary: 'body: { token, newPassword }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §2.5' },
  { id: 'AD-me-get', domain: 'auth', area: 'AD01', method: 'GET', path: '/api/me', auth: 'staff', menuKey: 'settings', summary: '내 프로필(본인=비마스킹)', requestSummary: '—', responseSummary: '{ id, name, nickname, email, phone, role, avatarUrl }', gate: false, status: '구현', notes: '06 §2.6' },
  { id: 'AD-me-patch', domain: 'auth', area: 'AD01', method: 'PATCH', path: '/api/me', auth: 'staff', menuKey: 'settings', summary: '내 프로필 수정', requestSummary: 'body: { nickname?, name?, phone?, avatarUrl? }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '닉네임 409 NICKNAME_DUP. 휴대폰 NICE 본인인증' },
  { id: 'AD-perm-get', domain: 'auth', area: 'AD01', method: 'GET', path: '/api/admin/users/:id/permissions', auth: 'staff', menuKey: 'users', summary: 'RBAC 권한 조회', requestSummary: 'path: id', responseSummary: '{ permissions: [{ menu_key, allowed, data_scope }] }', gate: false, status: '구현', notes: '06 §2.7 확정(관리자 전용)' },
  { id: 'AD-perm-put', domain: 'auth', area: 'AD01', method: 'PUT', path: '/api/admin/users/:id/permissions', auth: 'staff', menuKey: 'users', summary: 'RBAC 권한 일괄교체', requestSummary: 'body: { permissions[] } (P-AD-19)', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §2.7. rbacPreset.ts payload' },

  // 2.2 회원 관리
  { id: 'AD-learners-list', domain: 'users', area: 'AD01', method: 'GET', path: '/api/admin/learners', auth: 'staff', menuKey: 'users', summary: '학습자 목록', requestSummary: 'query: status, keyword, page', responseSummary: 'data:[학습자], meta', gate: false, status: '구현', notes: '[추정] 경로. 마스킹 적용' },
  { id: 'AD-learner-detail', domain: 'users', area: 'AD01', method: 'GET', path: '/api/admin/learners/:id', auth: 'staff', menuKey: 'users', summary: '학습자 상세', requestSummary: 'path: id', responseSummary: '학습자 상세(수강/결제/문의 이력)', gate: false, status: '구현', notes: '[추정]. 상세 필드 미확정' },
  { id: 'AD-learner-status', domain: 'users', area: 'AD01', method: 'PATCH', path: '/api/admin/learners/:id/status', auth: 'staff', menuKey: 'users', summary: '학습자 상태변경(정지/해제)', requestSummary: 'body: { status }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. 파괴적 변경(확인)' },
  { id: 'AD-instructors-list', domain: 'users', area: 'AD01', method: 'GET', path: '/api/admin/instructors', auth: 'staff', menuKey: 'users', summary: '강사 목록', requestSummary: 'query: status, keyword', responseSummary: 'data:[강사]', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-instructor-detail', domain: 'users', area: 'AD01', method: 'GET', path: '/api/admin/instructors/:id', auth: 'staff', menuKey: 'users', summary: '강사 상세', requestSummary: 'path: id', responseSummary: '강사 상세 + 권한', gate: false, status: '구현', notes: '[추정]. permissions 별도' },
  { id: 'AD-instructor-invite', domain: 'users', area: 'AD01', method: 'POST', path: '/api/admin/instructors/invite', auth: 'staff', menuKey: 'users', summary: '강사 초대(메일)', requestSummary: 'body: { emails[] }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. 링크 48h. owner만' },
  { id: 'AD-admins-list', domain: 'users', area: 'AD01', method: 'GET', path: '/api/admin/admins', auth: 'staff', menuKey: 'users', summary: '관리자 목록', requestSummary: 'query: status, keyword', responseSummary: 'data:[관리자] (isLastOwner)', gate: false, status: '구현', notes: '[추정]. 마지막 owner 삭제 차단' },
  { id: 'AD-admins-invite', domain: 'users', area: 'AD01', method: 'POST', path: '/api/admin/admins/invite', auth: 'staff', menuKey: 'users', summary: '관리자 초대', requestSummary: 'body: { emails[] }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-admin-status', domain: 'users', area: 'AD01', method: 'PATCH', path: '/api/admin/admins/:id', auth: 'staff', menuKey: 'users', summary: '관리자 상태/삭제', requestSummary: 'body: { status }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. isLastOwner 차단' },

  // 2.3 상품·코스
  { id: 'AD-products-list', domain: 'products', area: 'AD01', method: 'GET', path: '/api/products', auth: 'staff', menuKey: 'products', summary: '상품(코스) 목록', requestSummary: 'query: category, type, q, sort, page', responseSummary: 'data:[상품]', gate: false, status: '구현', notes: '06 §3.1 확정. type=general. roleGuard 분기' },
  { id: 'AD-product-detail', domain: 'products', area: 'AD01', method: 'GET', path: '/api/products/:id', auth: 'staff', menuKey: 'products', summary: '코스 상세', requestSummary: 'path: id', responseSummary: '코스 상세 + 커리큘럼/콘텐츠 매핑', gate: false, status: '구현', notes: '06 §3.1' },
  { id: 'AD-product-create', domain: 'products', area: 'AD01', method: 'POST', path: '/api/products', auth: 'staff', menuKey: 'products', summary: '상품 생성(유형별)', requestSummary: 'body: 유형별 폼(type=general|live|video_call|digital|package|membership|community)', responseSummary: '201', gate: false, status: '구현', notes: '[추정]. visibility/saleStatus' },
  { id: 'AD-product-update', domain: 'products', area: 'AD01', method: 'PATCH', path: '/api/products/:id', auth: 'staff', menuKey: 'products', summary: '상품 수정/삭제', requestSummary: 'body: 유형별 폼', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-categories', domain: 'products', area: 'AD01', method: 'POST', path: '/api/product-categories', auth: 'staff', menuKey: 'products', summary: '상품 카테고리 CRUD', requestSummary: 'body: { name, parentId(최대2단계), order, sortMode }', responseSummary: '카테고리 트리', gate: false, status: '구현', notes: '[추정]. LRN-03' },

  // 2.4 커뮤니티
  { id: 'AD-comm-subscribers', domain: 'community', area: 'AD01', method: 'GET', path: '/api/community/:id/subscribers', auth: 'staff', menuKey: 'products', summary: '커뮤니티 구독자 목록', requestSummary: 'path: id', responseSummary: '[{ name, nickname, status, subscribedAt, nextPayAt }]', gate: false, status: '구현', notes: '[추정]. 마스킹' },
  { id: 'AD-comm-posts', domain: 'community', area: 'AD01', method: 'POST', path: '/api/community/:id/posts', auth: 'staff', menuKey: 'products', summary: '커뮤니티 글 CRUD', requestSummary: 'body: { title, content, isPinned }', responseSummary: '[커뮤니티글]', gate: false, status: '구현', notes: '[추정]. 고정글 우선' },
  { id: 'AD-comm-comments', domain: 'community', area: 'AD01', method: 'POST', path: '/api/community/posts/:id/comments', auth: 'staff', menuKey: 'products', summary: '커뮤니티 댓글', requestSummary: 'body: { content, parentId? }', responseSummary: '댓글트리', gate: false, status: '구현', notes: '[추정]. SUP-04' },

  // 2.5 콘텐츠 라이브러리
  { id: 'AD-contents-list', domain: 'contents', area: 'AD01', method: 'GET', path: '/api/contents', auth: 'staff', menuKey: 'contents', summary: '콘텐츠 목록', requestSummary: 'query: folderId, type, q, page', responseSummary: '[콘텐츠(video/image/file/youtube)]', gate: false, status: '구현', notes: '[추정]. LRN-04/07' },
  { id: 'AD-contents-capacity', domain: 'contents', area: 'AD01', method: 'GET', path: '/api/contents/capacity', auth: 'staff', menuKey: 'contents', summary: '용량 현황', requestSummary: '—', responseSummary: '{ limitBytes, segments[] }', gate: false, status: '구현', notes: '[추정]. ≥90% 경고. LRN-06' },
  { id: 'AD-contents-upload', domain: 'contents', area: 'AD01', method: 'POST', path: '/api/contents', auth: 'staff', menuKey: 'contents', summary: '콘텐츠 업로드(R2/youtube)', requestSummary: 'multipart(R2) 또는 { youtube_url }', responseSummary: '201 { id, upload_status }', gate: false, status: '구현', notes: '06 §1.5. 인코딩 pending/processing/done/failed' },
  { id: 'AD-content-detail', domain: 'contents', area: 'AD01', method: 'GET', path: '/api/contents/:id', auth: 'staff', menuKey: 'contents', summary: '콘텐츠 상세', requestSummary: 'path: id', responseSummary: 'ContentDetail(자막/사용처)', gate: false, status: '구현', notes: '06 §1.5' },
  { id: 'AD-content-update', domain: 'contents', area: 'AD01', method: 'PATCH', path: '/api/contents/:id', auth: 'staff', menuKey: 'contents', summary: '콘텐츠 수정/삭제', requestSummary: 'body: { active, folderId, ... }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-content-subtitle', domain: 'contents', area: 'AD01', method: 'PATCH', path: '/api/contents/:id/subtitle', auth: 'staff', menuKey: 'contents', summary: '자막 편집', requestSummary: '자막 라인 [{ start, end, text }]', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. AI자막' },
  { id: 'AD-content-ai', domain: 'contents', area: 'AD01', method: 'POST', path: '/api/contents/:id/ai-tutor', auth: 'staff', menuKey: 'contents', summary: 'AI 튜터/번역/자막 요청', requestSummary: 'body: { lang? } (ai-tutor|ai-translate|ai-caption)', responseSummary: '크레딧 차감', gate: true, status: '게이트', notes: '[추정]. 크레딧 차감(비가역). LRN-17' },
  { id: 'AD-content-folders', domain: 'contents', area: 'AD01', method: 'POST', path: '/api/content-folders', auth: 'staff', menuKey: 'contents', summary: '콘텐츠 폴더 CRUD', requestSummary: 'body: { name, parentId(최대2), order }', responseSummary: '폴더트리', gate: false, status: '구현', notes: '[추정]. P-AD-57' },

  // 2.6 사이트 설정
  { id: 'AD-settings-basic', domain: 'settings', area: 'AD01', method: 'PUT', path: '/api/admin/settings/basic', auth: 'staff', menuKey: 'settings', summary: '기본 설정', requestSummary: 'body: { siteName, siteUrl, company, bizNo, address, manager* }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. P-AD-113' },
  { id: 'AD-settings-player', domain: 'settings', area: 'AD01', method: 'PUT', path: '/api/admin/settings/player', auth: 'staff', menuKey: 'settings', summary: '플레이어 설정', requestSummary: 'body: { play[], study[] }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. P-AD-114' },
  { id: 'AD-settings-noti', domain: 'settings', area: 'AD01', method: 'PUT', path: '/api/admin/settings/notification', auth: 'staff', menuKey: 'settings', summary: '알림 채널 설정', requestSummary: '카테고리별 { key, email, push, kakao }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. SUP-09' },
  { id: 'AD-cert-templates', domain: 'settings', area: 'AD01', method: 'GET', path: '/api/admin/certificate-templates', auth: 'staff', menuKey: 'settings', summary: '수료증 템플릿 목록', requestSummary: '—', responseSummary: '[{ id, name, gradient, isActive, inUse }]', gate: false, status: '구현', notes: '[추정]. LRN-19. 사용중 비활성 불가' },
  { id: 'AD-cert-template', domain: 'settings', area: 'AD01', method: 'PUT', path: '/api/admin/certificate-templates/:id', auth: 'staff', menuKey: 'settings', summary: '수료증 템플릿 상세', requestSummary: 'body: { title, issuer, signer, displayItems[], isActive }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-staff-notices', domain: 'settings', area: 'AD01', method: 'POST', path: '/api/admin/staff-notices', auth: 'staff', menuKey: 'settings', summary: '스태프 공지 CRUD', requestSummary: 'body: { title, target, isImportant, isPinned, content }', responseSummary: '[공지]', gate: false, status: '구현', notes: '[추정]. SUP-08' },

  // 2.7 사이트 디자인
  { id: 'AD-site-basic', domain: 'site_design', area: 'AD01', method: 'PUT', path: '/api/admin/site/basic', auth: 'staff', menuKey: 'site_design', summary: '사이트 기본정보', requestSummary: 'body: { siteName, siteUrl, siteDesc, logo*, sns, callPages }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. P-AD-93' },
  { id: 'AD-site-menus', domain: 'site_design', area: 'AD01', method: 'POST', path: '/api/admin/site/menus', auth: 'staff', menuKey: 'site_design', summary: '사이트 메뉴 CRUD', requestSummary: 'body: { name, linkType, linkUrl, newTab, visible, audience, order }', responseSummary: '[SiteMenu]', gate: false, status: '구현', notes: '[추정]. P-AD-95' },
  { id: 'AD-site-pages', domain: 'site_design', area: 'AD01', method: 'POST', path: '/api/admin/site/pages', auth: 'staff', menuKey: 'site_design', summary: '사이트 페이지(빌더) CRUD', requestSummary: 'body: { name, slug, description, isDefault, html, sections[] }', responseSummary: '[SitePage]', gate: false, status: '구현', notes: '[추정]. P-AD-99~102 섹션9유형' },
  { id: 'AD-site-meta', domain: 'site_design', area: 'AD01', method: 'PUT', path: '/api/admin/site/meta', auth: 'staff', menuKey: 'site_design', summary: '메타 코드', requestSummary: 'body: { naver, google, custom }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-site-seo', domain: 'site_design', area: 'AD01', method: 'PUT', path: '/api/admin/site/seo', auth: 'staff', menuKey: 'site_design', summary: 'SEO 설정', requestSummary: 'body: { siteConfig, pageRows[], productRows[] }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. P-AD-104 변수토큰' },
  { id: 'AD-site-footer', domain: 'site_design', area: 'AD01', method: 'PUT', path: '/api/admin/site/footer', auth: 'staff', menuKey: 'site_design', summary: '푸터 설정', requestSummary: 'body: { company, ceo, bizNo, ..., sns, visible }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. P-AD-106' },

  // 2.8 운영
  { id: 'AD-boards-list', domain: 'operation', area: 'AD01', method: 'GET', path: '/api/boards', auth: 'staff', menuKey: 'operation', summary: '게시판 목록', requestSummary: '—', responseSummary: '[{ id, name, type, isVisible, postCount, menuLinked }]', gate: false, status: '구현', notes: '06 §6.2 리소스 확정' },
  { id: 'AD-board-detail', domain: 'operation', area: 'AD01', method: 'POST', path: '/api/boards/:id', auth: 'staff', menuKey: 'operation', summary: '게시판 CRUD', requestSummary: 'body: { name, type, isVisible, *Permission, secretPolicy }', responseSummary: 'BoardDetail', gate: false, status: '구현', notes: '06 §6.2. 권한/비밀글정책' },
  { id: 'AD-board-posts', domain: 'operation', area: 'AD01', method: 'POST', path: '/api/boards/:boardId/posts', auth: 'staff', menuKey: 'operation', summary: '게시판 글 CRUD', requestSummary: 'body: { title, content, isPinned, isSecret }', responseSummary: '[BoardPost]', gate: false, status: '구현', notes: '06 §6.2 확정' },
  { id: 'AD-board-comment', domain: 'operation', area: 'AD01', method: 'POST', path: '/api/posts/:id/comments', auth: 'staff', menuKey: 'operation', summary: '게시글 댓글', requestSummary: 'body: { content }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §6.2 확정' },
  { id: 'AD-popups', domain: 'operation', area: 'AD01', method: 'POST', path: '/api/admin/popups', auth: 'staff', menuKey: 'operation', summary: '팝업 CRUD', requestSummary: 'body: { name, imageUrl, linkUrl, startAt, endAt, position, closeRule }', responseSummary: '[PopupListItem]', gate: false, status: '구현', notes: '[추정]. 노출기간' },

  // 2.9 판매
  { id: 'AD-orders-list', domain: 'sales', area: 'AD01', method: 'GET', path: '/api/admin/orders', auth: 'staff', menuKey: 'sales', summary: '주문 목록', requestSummary: 'query: status, type, q, page', responseSummary: '[주문(paid/pending/refund/...)]', gate: false, status: '구현', notes: '[추정]. 마스킹' },
  { id: 'AD-order-detail', domain: 'sales', area: 'AD01', method: 'GET', path: '/api/admin/orders/:id', auth: 'staff', menuKey: 'sales', summary: '주문 상세', requestSummary: 'path: id', responseSummary: 'OrderDetail(카드 부분마스킹, logs[])', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-coupons-list', domain: 'sales', area: 'AD01', method: 'GET', path: '/api/coupons', auth: 'staff', menuKey: 'sales', summary: '쿠폰 목록', requestSummary: '—', responseSummary: '[{ id, name, code, discountAmount, issuedCount, usedCount, status }]', gate: false, status: '구현', notes: '06 §5.3 리소스' },
  { id: 'AD-coupon-create', domain: 'sales', area: 'AD01', method: 'POST', path: '/api/coupons', auth: 'staff', menuKey: 'sales', summary: '쿠폰 생성', requestSummary: 'body: { discount_type, discount_amount, target, issued_qty }', responseSummary: '201', gate: false, status: '구현', notes: '06 §5.3 확정. 발행<등록인원→400' },
  { id: 'AD-coupon-update', domain: 'sales', area: 'AD01', method: 'PATCH', path: '/api/coupons/:id', auth: 'staff', menuKey: 'sales', summary: '쿠폰 수정/상태', requestSummary: 'body: { status, ... }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. 발행수량 floor' },
  { id: 'AD-refunds-list', domain: 'sales', area: 'AD01', method: 'GET', path: '/api/admin/refunds', auth: 'staff', menuKey: 'sales', summary: '환불 목록', requestSummary: 'query: status, q', responseSummary: '[환불(계산 파생)]', gate: false, status: '구현', notes: '[추정]. PAY-11' },
  { id: 'AD-refund-detail', domain: 'sales', area: 'AD01', method: 'GET', path: '/api/admin/refunds/:id', auth: 'staff', menuKey: 'sales', summary: '환불 상세', requestSummary: 'path: id', responseSummary: 'RefundDetail(basisKind, logs[])', gate: false, status: '구현', notes: '[추정]. 06 §4.6' },
  { id: 'AD-refund-request', domain: 'sales', area: 'AD01', method: 'POST', path: '/api/orders/:id/refund-request', auth: 'staff', menuKey: 'sales', summary: '환불 접수/처리', requestSummary: 'body: { mode, reason }', responseSummary: '{ ok }', gate: true, status: '게이트', notes: '06 §4.6. 자동환불 불가(CMP-06), 관리자 확인 후' },

  // 2.10 정산
  { id: 'AD-settlements-list', domain: 'settlement', area: 'AD01', method: 'GET', path: '/api/settlements', auth: 'staff', menuKey: 'settlement', summary: '정산 내역', requestSummary: 'query: period_month (강사=본인스코프)', responseSummary: '[{ monthLabel, grossPayment, vat, saleFee, pgFee, payStatus }]', gate: true, status: '게이트', notes: '06 §4.8 확정. 부가세10%/판매수수료11%/PG4%' },
  { id: 'AD-settlement-detail', domain: 'settlement', area: 'AD01', method: 'GET', path: '/api/settlements/:month', auth: 'staff', menuKey: 'settlement', summary: '정산 월별 상세', requestSummary: 'path: month', responseSummary: 'SettlementDetail(products[], cancels[])', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-settlement-profile', domain: 'settlement', area: 'AD01', method: 'PUT', path: '/api/admin/settlement-profile', auth: 'staff', menuKey: 'settlement', summary: '정산 프로필(계좌)', requestSummary: 'body: { bizType, name, bizNo, bankName, accountNo, accountHolder, bankbook(R2) }', responseSummary: '{ status(미등록|심사중|approved), processLog[] }', gate: true, status: '게이트', notes: '[추정]. PAY-20 승인 게이트. 계좌 마스킹' },
  { id: 'AD-vat-reports', domain: 'settlement', area: 'AD01', method: 'GET', path: '/api/admin/vat-reports', auth: 'staff', menuKey: 'settlement', summary: '부가세 신고자료', requestSummary: 'query: 기간', responseSummary: '[{ periodLabel, year, taxable, exempt, vat }]', gate: false, status: '구현', notes: '[추정]' },

  // 2.11 크레딧
  { id: 'AD-credits-get', domain: 'credits', area: 'AD01', method: 'GET', path: '/api/credits', auth: 'staff', menuKey: 'settlement', summary: '크레딧 잔액/내역', requestSummary: '—', responseSummary: '{ balance, summary, entries[] }', gate: false, status: '구현', notes: '[추정]. 단가 미노출' },
  { id: 'AD-credits-charge-products', domain: 'credits', area: 'AD01', method: 'GET', path: '/api/credits/charge-products', auth: 'staff', menuKey: 'settlement', summary: '크레딧 충전상품', requestSummary: '—', responseSummary: '[{ credit, bonus, price, badge }]', gate: false, status: '구현', notes: '[추정]. PAY-19 10,000원 단위' },
  { id: 'AD-credits-charge', domain: 'credits', area: 'AD01', method: 'POST', path: '/api/credits/charge', auth: 'staff', menuKey: 'settlement', summary: '크레딧 충전(토스 빌링)', requestSummary: 'body: { productId, cardId }', responseSummary: '201 { orderNo, orderStatus }', gate: true, status: '게이트', notes: '[추정]. 결제=서버경유(토스)' },
  { id: 'AD-credits-debit', domain: 'credits', area: 'AD01', method: 'POST', path: '/api/credits/debit', auth: 'staff', menuKey: 'settlement', summary: '크레딧 차감(내부)', requestSummary: 'body: { reason, unit_count, idempotency_key, ref_type?, ref_id? }', responseSummary: '201 { ledger_id, status:pending, balance_after }', gate: true, status: '게이트', notes: '06 §5.4 확정. 멱등. 잔액부족 402/400' },
  { id: 'AD-credits-settle', domain: 'credits', area: 'AD01', method: 'POST', path: '/api/credits/ledger/:id/settle', auth: 'staff', menuKey: 'settlement', summary: '크레딧 원장 정산(내부)', requestSummary: '—', responseSummary: 'settled', gate: true, status: '게이트', notes: '06 §5.4 확정' },
  { id: 'AD-credits-refund', domain: 'credits', area: 'AD01', method: 'POST', path: '/api/credits/ledger/:id/refund', auth: 'staff', menuKey: 'settlement', summary: '크레딧 원장 환불(내부 배치)', requestSummary: '—', responseSummary: 'refunded', gate: true, status: '게이트', notes: '06 §5.4 확정. 멱등' },

  // 2.12 통계
  { id: 'AD-stats-learners', domain: 'stats', area: 'AD01', method: 'GET', path: '/api/admin/stats/learners', auth: 'staff', menuKey: 'stats', summary: '학습자 통계', requestSummary: 'query: period', responseSummary: '{ kpis[], trend[], typeDistribution[], byDay[], byHour[] }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-stats-sales', domain: 'stats', area: 'AD01', method: 'GET', path: '/api/admin/stats/sales', auth: 'staff', menuKey: 'stats', summary: '매출 통계', requestSummary: 'query: period', responseSummary: '{ kpis[], trend[], typeRevenue[], ratings[], topProducts[] }', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-stats-contents', domain: 'stats', area: 'AD01', method: 'GET', path: '/api/admin/stats/contents', auth: 'staff', menuKey: 'stats', summary: '콘텐츠 통계', requestSummary: 'query: period', responseSummary: '{ kpis[], uploadTrend[], typeDistribution[], popularContents[] }', gate: false, status: '구현', notes: '[추정]' },

  // 2.13 마케팅
  { id: 'AD-campaigns-list', domain: 'marketing', area: 'AD01', method: 'GET', path: '/api/campaigns', auth: 'staff', menuKey: 'marketing', summary: '캠페인 목록', requestSummary: 'query: 필터', responseSummary: '[{ name, channels[], status, purpose, recipients, scheduledAt }]', gate: false, status: '구현', notes: '[추정]' },
  { id: 'AD-campaign-create', domain: 'marketing', area: 'AD01', method: 'POST', path: '/api/campaigns', auth: 'staff', menuKey: 'marketing', summary: '캠페인 생성(발송)', requestSummary: 'body: { name, channels[], recipient_group_id, schedule }', responseSummary: '201', gate: true, status: '게이트', notes: '06 §5.1 확정. 예약 최소10분후. 발송=크레딧 가차감' },
  { id: 'AD-groups-list', domain: 'marketing', area: 'AD01', method: 'GET', path: '/api/recipient-groups', auth: 'staff', menuKey: 'marketing', summary: '수신자 그룹 목록', requestSummary: '—', responseSummary: '[{ name, desc, updateMode, count, inUse }]', gate: false, status: '구현', notes: '06 §5.2 확정' },
  { id: 'AD-groups-crud', domain: 'marketing', area: 'AD01', method: 'POST', path: '/api/recipient-groups', auth: 'staff', menuKey: 'marketing', summary: '수신자 그룹 CRUD', requestSummary: 'body: { name, desc, updateMode, condition|memberIds[] }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §5.2. 사용중 삭제 409' },
  { id: 'AD-send-history', domain: 'marketing', area: 'AD01', method: 'GET', path: '/api/admin/send-history', auth: 'staff', menuKey: 'marketing', summary: '발송 이력', requestSummary: 'query: 필터', responseSummary: '[{ title, channel, recipients, success, fail, status }]', gate: false, status: '구현', notes: '[추정]. 수신자 마스킹. MKT-08' },
  { id: 'AD-landing-pages', domain: 'marketing', area: 'AD01', method: 'POST', path: '/api/admin/landing-pages', auth: 'staff', menuKey: 'marketing', summary: '랜딩 페이지 CRUD', requestSummary: 'body: { name, type, isVisible, products[max4], couponId }', responseSummary: '[LandingRow]', gate: false, status: '구현', notes: '[추정]. MKT-13' },
  { id: 'AD-surveys', domain: 'marketing', area: 'AD01', method: 'POST', path: '/api/admin/surveys', auth: 'staff', menuKey: 'marketing', summary: '설문 CRUD', requestSummary: 'body: { name, status, respondentType, isPublic, questions[] }', responseSummary: '[SurveyRow]', gate: false, status: '구현', notes: '[추정]. MKT-11' },
  { id: 'AD-message-templates', domain: 'marketing', area: 'AD01', method: 'POST', path: '/api/admin/message-templates', auth: 'staff', menuKey: 'marketing', summary: '메시지 템플릿 CRUD', requestSummary: 'body: { name, channel, status, advertising, body }', responseSummary: '[MessageTemplateRow]', gate: false, status: '구현', notes: '[추정]. MKT-09/10' },
  { id: 'AD-kakao-templates', domain: 'marketing', area: 'AD01', method: 'GET', path: '/api/admin/kakao-templates', auth: 'staff', menuKey: 'marketing', summary: '카카오 템플릿(승인)', requestSummary: '—', responseSummary: '[{ code, name, approval }]', gate: false, status: '구현', notes: '[추정]. 승인코드만 발송(Read-only). MKT-04' },
  { id: 'AD-marketing-tools', domain: 'marketing', area: 'AD01', method: 'PUT', path: '/api/admin/marketing-tools', auth: 'staff', menuKey: 'marketing', summary: '마케팅 도구 연동', requestSummary: 'body: { kind(kakao|ga4|gtm|pixel), value, connected }', responseSummary: '[MarketingTool]', gate: false, status: '구현', notes: '[추정]. MKT-12. 형식검증' },

  // 2.14 알림
  { id: 'AD-noti-list', domain: 'notification', area: 'AD01', method: 'GET', path: '/api/me/notifications', auth: 'staff', menuKey: 'dashboard', summary: '알림 목록', requestSummary: 'query: unread, cursor', responseSummary: '[{ code(N-01~N-10), title, body, link, isRead }]', gate: false, status: '구현', notes: '06 §5b.4 확정. 역할 스코프 공유' },
  { id: 'AD-noti-read', domain: 'notification', area: 'AD01', method: 'POST', path: '/api/me/notifications/:id/read', auth: 'staff', menuKey: 'dashboard', summary: '알림 읽음', requestSummary: 'path: id', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §5b.4 확정' },
  { id: 'AD-noti-readall', domain: 'notification', area: 'AD01', method: 'POST', path: '/api/me/notifications/read-all', auth: 'staff', menuKey: 'dashboard', summary: '알림 모두 읽음', requestSummary: '—', responseSummary: '{ ok }', gate: false, status: '구현', notes: '06 §5b.4 확정' },
  { id: 'AD-noti-settings', domain: 'notification', area: 'AD01', method: 'PATCH', path: '/api/me/notification-settings', auth: 'staff', menuKey: 'settings', summary: '알림 설정', requestSummary: 'body: { updates:[{ category, channel, enabled }] }', responseSummary: 'settings[]', gate: false, status: '구현', notes: '06 §5b.2/3. 필수=토글불가 400' },

  // 2.15 문의
  { id: 'AD-inquiries-list', domain: 'inquiry', area: 'AD01', method: 'GET', path: '/api/inquiries', auth: 'staff', menuKey: 'operation', summary: '문의 목록', requestSummary: 'query: type, status, q', responseSummary: '[{ type, title, authorName, status, assignee }]', gate: false, status: '구현', notes: '[추정]. 마스킹' },
  { id: 'AD-inquiry-detail', domain: 'inquiry', area: 'AD01', method: 'GET', path: '/api/inquiries/:id', auth: 'staff', menuKey: 'operation', summary: '문의 상세', requestSummary: 'path: id', responseSummary: 'InquiryDetail(attachments[], comments[])', gate: false, status: '구현', notes: '[추정]. 06 §6.1' },
  { id: 'AD-inquiry-comment', domain: 'inquiry', area: 'AD01', method: 'POST', path: '/api/inquiries/:id/comments', auth: 'staff', menuKey: 'operation', summary: '문의 답변', requestSummary: 'body: { content, parentId? }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. 상태머신' },
  { id: 'AD-inquiry-status', domain: 'inquiry', area: 'AD01', method: 'PATCH', path: '/api/inquiries/:id', auth: 'staff', menuKey: 'operation', summary: '문의 상태/담당자', requestSummary: 'body: { status, assignee }', responseSummary: '{ ok }', gate: false, status: '구현', notes: '[추정]. 답변대기→답변중→완료→종료' },
]

export const apiEndpoints: ApiEndpoint[] = [...front, ...admin]

// ── 파생 메타 ──
export const API_METHODS: ApiMethod[] = ['GET', 'POST', 'PATCH', 'PUT', 'DELETE']
export const API_AREAS: { key: ApiArea, label: string }[] = [
  { key: 'FR01', label: '사용자단 (FR01)' },
  { key: 'AD01', label: '관리자단 (AD01)' },
]
export const API_AUTHS: { key: ApiAuth, label: string }[] = [
  { key: 'public', label: '공개' },
  { key: 'user', label: '사용자' },
  { key: 'staff', label: '스태프(RBAC)' },
]
export const API_STATUSES: ApiStatus[] = ['기구현', '구현', '게이트']

// 도메인 표시 라벨(한국어)
export const DOMAIN_LABELS: Record<string, string> = {
  auth: '인증/가입',
  me: '내 정보',
  tenant: '테넌트',
  products: '상품·코스',
  learning: '수강·라이브',
  order: '주문·결제',
  subscription: '구독·멤버십',
  coupon: '쿠폰',
  board: '게시판·커뮤니티',
  community: '커뮤니티',
  faq: 'FAQ',
  inquiry: '1:1 문의',
  certificate: '수료증',
  notification: '알림',
  wishlist: '위시리스트',
  users: '회원 관리',
  contents: '콘텐츠',
  settings: '사이트 설정',
  site_design: '사이트 디자인',
  operation: '운영(게시판/팝업)',
  sales: '판매(주문/쿠폰/환불)',
  settlement: '정산',
  credits: '크레딧',
  stats: '통계',
  marketing: '마케팅',
}

export function domainLabel(key: string): string {
  return DOMAIN_LABELS[key] ?? key
}
