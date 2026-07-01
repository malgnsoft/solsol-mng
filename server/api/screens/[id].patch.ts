import { getSessionMemberId } from '../../utils/auth'
import { useScreenStatus } from '../../utils/screenStatus'
import type { StatusPatch } from '../../utils/screenStatus'
import { screenAreas } from '../../../app/utils/screenList'
import type { ScreenItem } from '../../../app/utils/screenList'

// 정적 화면목록 id → 정적 상태(신규 D1 행의 base). 정적 목록의 publish/mockupUrl 등이
// 한 필드 토글 시 초기화되지 않도록 base 로 시드한다.
const staticMap = (() => {
  const m = new Map<string, Partial<ScreenItem>>()
  for (const a of screenAreas) for (const p of a.screens) {
    m.set(p.id, p)
    for (const mo of p.modals ?? []) m.set(mo.id, mo)
  }
  return m
})()

// 화면 상태/링크 갱신 — 세션 필수. 화면ID별 design·publish·review·dev·test 토글 + mockupUrl·devUrl.
export default defineEventHandler(async (event) => {
  const memberId = await getSessionMemberId(event)
  if (!memberId) throw createError({ statusCode: 401, statusMessage: '로그인이 필요합니다' })

  const id = decodeURIComponent(getRouterParam(event, 'id') ?? '').trim()
  if (!id) throw createError({ statusCode: 400, statusMessage: '화면ID가 없습니다' })

  const b = await readBody(event) ?? {}
  const patch: StatusPatch = {}
  for (const k of ['design', 'publish', 'review', 'spike', 'dev', 'test'] as const) {
    if (typeof b[k] === 'boolean') patch[k] = b[k]
  }
  for (const k of ['mockupUrl', 'devUrl'] as const) {
    if (typeof b[k] === 'string') patch[k] = b[k].trim()
  }
  if (!Object.keys(patch).length) throw createError({ statusCode: 400, statusMessage: '변경할 값이 없습니다' })

  // 신규 행일 때 정적 화면목록 값을 base 로(정적의 publish/mockupUrl 보존)
  const s = staticMap.get(id)
  const defaults = s
    ? { design: s.design ?? true, publish: s.publish ?? false, dev: s.dev ?? false, test: s.test ?? false, mockupUrl: s.mockupUrl ?? '', devUrl: s.devUrl ?? '' }
    : undefined

  const row = await useScreenStatus(event).upsert(id, patch, defaults)
  return { data: row }
})
