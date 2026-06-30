import { getSessionMemberId } from '../../../utils/auth'
import { useScreenComments } from '../../../utils/screenComments'

// 화면 코멘트 삭제 — 세션 필수.
export default defineEventHandler(async (event) => {
  const memberId = await getSessionMemberId(event)
  if (!memberId) throw createError({ statusCode: 401, statusMessage: '로그인이 필요합니다' })
  const cid = Number(getRouterParam(event, 'cid'))
  if (!cid) throw createError({ statusCode: 400, statusMessage: 'invalid id' })
  const ok = await useScreenComments(event).remove(cid)
  if (!ok) throw createError({ statusCode: 404, statusMessage: 'not found' })
  return { ok: true }
})
