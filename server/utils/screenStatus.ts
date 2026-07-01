import { eq } from 'drizzle-orm'
import type { H3Event } from 'h3'
import { screenStatus } from '../db/schema'

// 화면 진척 상태 저장소 — 프로덕션 D1(Drizzle), dev(바인딩 없음)은 인메모리 폴백.
// 화면ID 키로 상태/링크 오버라이드만 보관(목록 골격은 정본 screenList).

export interface StatusRow {
  screenId: string
  design: boolean
  publish: boolean
  review: boolean
  dev: boolean
  test: boolean
  mockupUrl: string
  devUrl: string
  updatedAt: string | null
}
export type StatusPatch = Partial<Pick<StatusRow, 'design' | 'publish' | 'review' | 'dev' | 'test' | 'mockupUrl' | 'devUrl'>>

function nowIso(): string { return new Date().toISOString() }

interface StatusRepo {
  all(): Promise<StatusRow[]>
  // defaults: 신규 행일 때의 base(정적 화면목록 값). 없으면 하드코딩 기본값.
  upsert(id: string, patch: StatusPatch, defaults?: Partial<StatusRow>): Promise<StatusRow>
}

// ─── dev 인메모리 폴백 ─────────────────────────────────────
const memStore = new Map<string, StatusRow>()
function applyPatch(prev: StatusRow | undefined, id: string, patch: StatusPatch, defaults?: Partial<StatusRow>): StatusRow {
  // 신규 행이면 base = 하드코딩 기본값 위에 정적 화면목록 값(defaults)을 얹는다.
  // → 정적 목록에만 있던 publish/mockupUrl 등이 한 필드 토글 시 초기화되는 버그 방지.
  const base: StatusRow = prev ?? { screenId: id, design: true, publish: false, review: false, dev: false, test: false, mockupUrl: '', devUrl: '', updatedAt: null, ...defaults }
  return { ...base, ...patch, screenId: id, updatedAt: nowIso() }
}
const memRepo: StatusRepo = {
  all: () => Promise.resolve([...memStore.values()]),
  upsert: (id, patch, defaults) => {
    const row = applyPatch(memStore.get(id), id, patch, defaults)
    memStore.set(id, row)
    return Promise.resolve(row)
  },
}

// ─── D1 구현 ──────────────────────────────────────────────
type Db = NonNullable<ReturnType<typeof useDb>>
function d1Repo(db: Db): StatusRepo {
  return {
    all: () => db.select().from(screenStatus).all() as Promise<StatusRow[]>,
    upsert: async (id, patch, defaults) => {
      const existing = (await db.select().from(screenStatus).where(eq(screenStatus.screenId, id)).limit(1))[0] as StatusRow | undefined
      const row = applyPatch(existing, id, patch, defaults)
      await db.insert(screenStatus).values(row)
        .onConflictDoUpdate({ target: screenStatus.screenId, set: { design: row.design, publish: row.publish, review: row.review, dev: row.dev, test: row.test, mockupUrl: row.mockupUrl, devUrl: row.devUrl, updatedAt: row.updatedAt } })
      return row
    },
  }
}

export function useScreenStatus(event: H3Event): StatusRepo {
  const db = useDb(event)
  return db ? d1Repo(db) : memRepo
}
