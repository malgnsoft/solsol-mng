// 비밀번호 게이트 — 회원가입 없이 단일 접근 비밀번호로만 입장.
// 비밀번호는 서버에만 존재(클라이언트 번들에 노출 안 됨). 통과 시 인증 쿠키 발급.
const ACCESS_PASSWORD = 'solsollms2026'
const AUTH_COOKIE = 'mng_auth'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const password = String(body?.password ?? '')
  if (password !== ACCESS_PASSWORD) {
    throw createError({ statusCode: 401, statusMessage: '비밀번호가 올바르지 않습니다.' })
  }
  // 미들웨어가 클라이언트 네비게이션에서도 읽어야 하므로 httpOnly 아님(소프트 게이트).
  setCookie(event, AUTH_COOKIE, '1', {
    httpOnly: false,
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 30, // 30일
  })
  return { ok: true }
})
