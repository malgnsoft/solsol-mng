import { asc, eq, sql } from 'drizzle-orm'
import type { H3Event } from 'h3'
import { screenComment } from '../db/schema'

// 화면별 코멘트(다중) 저장소 — 프로덕션 D1(Drizzle), dev(바인딩 없음)은 인메모리 폴백.

export interface CommentRow {
  id: number
  screenId: string
  body: string
  author: string
  createdAt: string
}

function nowIso(): string { return new Date().toISOString() }

interface CommentRepo {
  listByScreen(screenId: string): Promise<CommentRow[]>
  create(screenId: string, body: string, author: string): Promise<CommentRow>
  remove(id: number): Promise<boolean>
  counts(): Promise<Record<string, number>> // 화면ID별 코멘트 수
}

// ─── dev 인메모리 폴백 ─────────────────────────────────────
const mem: CommentRow[] = []
let memSeq = 1
const memRepo: CommentRepo = {
  listByScreen: id => Promise.resolve(mem.filter(c => c.screenId === id).sort((a, b) => a.createdAt.localeCompare(b.createdAt))),
  create: (screenId, body, author) => {
    const row: CommentRow = { id: memSeq++, screenId, body, author, createdAt: nowIso() }
    mem.push(row)
    return Promise.resolve(row)
  },
  remove: (id) => {
    const i = mem.findIndex(c => c.id === id)
    if (i < 0) return Promise.resolve(false)
    mem.splice(i, 1)
    return Promise.resolve(true)
  },
  counts: () => {
    const m: Record<string, number> = {}
    for (const c of mem) m[c.screenId] = (m[c.screenId] ?? 0) + 1
    return Promise.resolve(m)
  },
}

// ─── D1 구현 ──────────────────────────────────────────────
type Db = NonNullable<ReturnType<typeof useDb>>
function d1Repo(db: Db): CommentRepo {
  return {
    listByScreen: id => db.select().from(screenComment).where(eq(screenComment.screenId, id)).orderBy(asc(screenComment.createdAt)).all() as Promise<CommentRow[]>,
    create: async (screenId, body, author) => {
      const [row] = await db.insert(screenComment).values({ screenId, body, author, createdAt: nowIso() }).returning()
      return row as CommentRow
    },
    remove: async (id) => {
      const res = await db.delete(screenComment).where(eq(screenComment.id, id)).returning()
      return res.length > 0
    },
    counts: async () => {
      const rows = await db.select({ screenId: screenComment.screenId, n: sql<number>`count(*)` }).from(screenComment).groupBy(screenComment.screenId).all()
      const m: Record<string, number> = {}
      for (const r of rows as { screenId: string, n: number }[]) m[r.screenId] = Number(r.n)
      return m
    },
  }
}

export function useScreenComments(event: H3Event): CommentRepo {
  const db = useDb(event)
  return db ? d1Repo(db) : memRepo
}
