import { getSessionMemberId } from '../../utils/auth'
import { useScreenStatus } from '../../utils/screenStatus'
import type { StatusRow } from '../../utils/screenStatus'
import { useScreenComments } from '../../utils/screenComments'
import { screenAreas } from '../../../app/utils/screenList'
import type { ScreenItem, ScreenArea } from '../../../app/utils/screenList'

// 화면 진척 목록 — 정본(screenList, 읽기전용 골격) + D1 저장 상태/링크/검수/코멘트수 머지.
// 세션 필수(앱 전역 게이트와 동일).
export default defineEventHandler(async (event) => {
  const memberId = await getSessionMemberId(event)
  if (!memberId) throw createError({ statusCode: 401, statusMessage: '로그인이 필요합니다' })

  const rows = await useScreenStatus(event).all()
  const map = new Map<string, StatusRow>(rows.map(r => [r.screenId, r]))
  const counts = await useScreenComments(event).counts()

  const merge = (it: ScreenItem): ScreenItem => {
    const cc = it.id ? (counts[it.id] ?? 0) : 0
    const s = it.id ? map.get(it.id) : undefined
    if (!s) return { ...it, commentCount: cc }
    // URL 은 D1 값 우선, 비어 있으면 정적 목록으로 폴백(정적 목업 링크 보존)
    return { ...it, design: s.design, publish: s.publish, review: s.review, dev: s.dev, test: s.test, mockupUrl: s.mockupUrl || it.mockupUrl, devUrl: s.devUrl || it.devUrl, commentCount: cc }
  }
  const areas: ScreenArea[] = screenAreas.map(a => ({
    ...a,
    screens: a.screens.map(p => ({ ...merge(p), modals: (p.modals ?? []).map(merge) })),
  }))
  return { data: areas }
})
