import { getSessionMemberId } from '../../../utils/auth'
import { useScreenComments } from '../../../utils/screenComments'

// 화면별 코멘트 목록 — 세션 필수.
export default defineEventHandler(async (event) => {
  const memberId = await getSessionMemberId(event)
  if (!memberId) throw createError({ statusCode: 401, statusMessage: '로그인이 필요합니다' })
  const id = decodeURIComponent(getRouterParam(event, 'id') ?? '').trim()
  if (!id) throw createError({ statusCode: 400, statusMessage: '화면ID가 없습니다' })
  const data = await useScreenComments(event).listByScreen(id)
  return { data }
})
