// 전체 사이트 비밀번호 게이트.
// 인증 쿠키(mng_auth)가 없으면 /login 으로 보낸다. 통과 후 원래 경로로 복귀.
// (SSR 라우트는 서버에서 차단, 프리렌더 문서/이력은 하이드레이션 시 클라이언트에서 차단)
export default defineNuxtRouteMiddleware((to) => {
  // 빌드 타임 프리렌더(문서/이력) 중에는 게이트를 건너뛴다 — 정적 산출물을 정상 생성하고,
  // 실제 차단은 런타임(하이드레이션 시 클라이언트)에서 수행한다.
  if (import.meta.prerender) return

  const auth = useCookie('mng_auth')
  if (to.path === '/login') {
    if (auth.value) return navigateTo('/')
    return
  }
  if (!auth.value) {
    return navigateTo({ path: '/login', query: { redirect: to.fullPath } })
  }
})
