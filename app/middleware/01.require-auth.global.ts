// 전역 인증 게이트 — 공개 allowlist 외 모든 페이지/문서는 로그인 필수.
// 공개 경로: 로그인·회원가입(가입은 승인 대기라 세션 미발급 → 완료 안내 페이지도 공개).
// 그 외(/, /docs, /wbs, /history, /account, /members, /issues, /weekly …)는 전부 보호.
//
// 문서/이력은 빌드 타임 프리렌더(@nuxt/content) 대상이므로, 프리렌더 중에는 게이트를
// 건너뛴다 — 정적 산출물을 정상 생성하고, 실제 차단은 런타임(하이드레이션 시
// 클라이언트 useAuth 상태)에서 수행한다.
const PUBLIC_PATHS = new Set(['/login', '/signup', '/signup/complete'])

export default defineNuxtRouteMiddleware((to) => {
  if (import.meta.prerender) return
  if (PUBLIC_PATHS.has(to.path)) return

  const { member } = useAuth()
  if (!member.value) {
    return navigateTo(`/login?redirect=${encodeURIComponent(to.fullPath)}`)
  }
})
