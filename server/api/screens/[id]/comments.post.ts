import { getSessionMemberId } from '../../../utils/auth'
import { useScreenComments } from '../../../utils/screenComments'
import { useMembers } from '../../../utils/members'

// 화면 코멘트 작성 — 세션 필수. 작성자 = 세션 회원명 스냅샷.
export default defineEventHandler(async (event) => {
  const memberId = await getSessionMemberId(event)
  if (!memberId) throw createError({ statusCode: 401, statusMessage: '로그인이 필요합니다' })
  const id = decodeURIComponent(getRouterParam(event, 'id') ?? '').trim()
  if (!id) throw createError({ statusCode: 400, statusMessage: '화면ID가 없습니다' })
  const b = await readBody(event) ?? {}
  const body = String(b.body ?? '').trim()
  if (!body) throw createError({ statusCode: 400, statusMessage: '내용을 입력하세요' })
  const me = await useMembers(event).findById(memberId)
  const row = await useScreenComments(event).create(id, body, me?.name ?? '')
  return { data: row }
})
