<script setup lang="ts">
import {
  apiEndpoints, API_AREAS, API_AUTHS, API_METHODS, API_STATUSES,
  domainLabel,
  type ApiEndpoint, type ApiMethod, type ApiArea, type ApiAuth, type ApiStatus,
} from '~/data/apiEndpoints'

useHead({ title: 'API' })

// ── 필터 상태 ──
const kw = ref('')
const fArea = ref<ApiArea | ''>('')
const fDomain = ref<string>('')
const fMethod = ref<ApiMethod | ''>('')
const fAuth = ref<ApiAuth | ''>('')
const fStatus = ref<ApiStatus | ''>('')
const fGate = ref<'' | 'gate' | 'nogate'>('')

// ── 정렬 상태 ──
type SortKey = 'method' | 'path' | 'domain' | 'auth' | 'area'
const sortKey = ref<SortKey>('area')
const sortDir = ref<1 | -1>(1)
function sortBy(k: SortKey) {
  if (sortKey.value === k) sortDir.value = (sortDir.value * -1) as 1 | -1
  else { sortKey.value = k; sortDir.value = 1 }
}

// 도메인 옵션(현재 area 필터 반영)
const domainOptions = computed(() => {
  const src = fArea.value ? apiEndpoints.filter(e => e.area === fArea.value) : apiEndpoints
  return [...new Set(src.map(e => e.domain))].sort()
})

const filtered = computed<ApiEndpoint[]>(() => {
  const q = kw.value.trim().toLowerCase()
  const rows = apiEndpoints.filter((e) => {
    if (fArea.value && e.area !== fArea.value) return false
    if (fDomain.value && e.domain !== fDomain.value) return false
    if (fMethod.value && e.method !== fMethod.value) return false
    if (fAuth.value && e.auth !== fAuth.value) return false
    if (fStatus.value && e.status !== fStatus.value) return false
    if (fGate.value === 'gate' && !e.gate) return false
    if (fGate.value === 'nogate' && e.gate) return false
    if (q) {
      const hay = `${e.path} ${e.summary} ${e.method} ${domainLabel(e.domain)} ${e.requestSummary} ${e.responseSummary} ${e.notes ?? ''}`.toLowerCase()
      if (!hay.includes(q)) return false
    }
    return true
  })
  const dir = sortDir.value
  const k = sortKey.value
  return [...rows].sort((a, b) => {
    const av = String(a[k] ?? '')
    const bv = String(b[k] ?? '')
    return av === bv ? 0 : (av < bv ? -dir : dir)
  })
})

function resetFilters() {
  kw.value = ''; fArea.value = ''; fDomain.value = ''
  fMethod.value = ''; fAuth.value = ''; fStatus.value = ''; fGate.value = ''
}
const hasFilter = computed(() =>
  !!(kw.value || fArea.value || fDomain.value || fMethod.value || fAuth.value || fStatus.value || fGate.value))

// area 변경 시 도메인 필터가 새 목록에 없으면 초기화
watch(fArea, () => {
  if (fDomain.value && !domainOptions.value.includes(fDomain.value)) fDomain.value = ''
})

// ── 집계 카드 ──
const stats = computed(() => {
  const all = apiEndpoints
  return {
    total: all.length,
    fr: all.filter(e => e.area === 'FR01').length,
    ad: all.filter(e => e.area === 'AD01').length,
    domains: new Set(all.map(e => e.domain)).size,
    gate: all.filter(e => e.gate).length,
    ready: all.filter(e => e.status === '기구현').length,
  }
})

// ── 상세 (드로어) ──
const active = ref<ApiEndpoint | null>(null)
function open(e: ApiEndpoint) { active.value = e }
function close() { active.value = null }

// ── 표시 헬퍼 ──
const METHOD_CLASS: Record<ApiMethod, string> = {
  GET: 'm-get', POST: 'm-post', PATCH: 'm-patch', PUT: 'm-put', DELETE: 'm-del',
}
const AUTH_LABEL: Record<ApiAuth, string> = { public: '공개', user: '사용자', staff: '스태프' }
const STATUS_CLASS: Record<ApiStatus, string> = { 기구현: 's-ready', 구현: 's-todo', 게이트: 's-gate' }
</script>

<template>
  <div class="page">
    <header class="head">
      <h1>API</h1>
      <p class="sub">쏠쏠 크리에이터 백엔드(<b>solsol-api</b>) HTTP 엔드포인트 인벤토리. 영역(<b>사용자단 FR01 · 관리자단 AD01</b>)·도메인·메서드·인증·게이트로
        필터하고, 행을 클릭해 요청/응답·비고를 확인합니다. 정본은 프론트 계약 인벤토리(조백개·임관개)이며 관리자 경로 상당수는 <b>[추정]</b>입니다.
        화면 목록은 <NuxtLink to="/screens" class="lnk">화면</NuxtLink>에서 확인하세요.</p>
    </header>

    <!-- 집계 카드 -->
    <div class="cards">
      <div class="card"><span class="c-n">{{ stats.total }}</span><span class="c-l">전체 엔드포인트</span></div>
      <div class="card"><span class="c-n">{{ stats.fr }}</span><span class="c-l">사용자단 FR01</span></div>
      <div class="card"><span class="c-n">{{ stats.ad }}</span><span class="c-l">관리자단 AD01</span></div>
      <div class="card"><span class="c-n">{{ stats.domains }}</span><span class="c-l">도메인</span></div>
      <div class="card"><span class="c-n gate">{{ stats.gate }}</span><span class="c-l">비가역 게이트</span></div>
      <div class="card"><span class="c-n ready">{{ stats.ready }}</span><span class="c-l">기구현</span></div>
    </div>

    <!-- 필터 -->
    <div class="filters">
      <div class="f-search">
        <UIcon name="i-lucide-search" class="f-ico" />
        <input v-model="kw" type="text" placeholder="경로·요약·비고 검색" aria-label="검색">
        <button v-if="kw" type="button" class="f-clear" aria-label="검색어 지우기" @click="kw = ''">✕</button>
      </div>
      <select v-model="fArea" class="f-sel" aria-label="영역">
        <option value="">영역 전체</option>
        <option v-for="a in API_AREAS" :key="a.key" :value="a.key">{{ a.label }}</option>
      </select>
      <select v-model="fDomain" class="f-sel" aria-label="도메인">
        <option value="">도메인 전체</option>
        <option v-for="d in domainOptions" :key="d" :value="d">{{ domainLabel(d) }}</option>
      </select>
      <select v-model="fMethod" class="f-sel" aria-label="메서드">
        <option value="">메서드 전체</option>
        <option v-for="m in API_METHODS" :key="m" :value="m">{{ m }}</option>
      </select>
      <select v-model="fAuth" class="f-sel" aria-label="인증">
        <option value="">인증 전체</option>
        <option v-for="a in API_AUTHS" :key="a.key" :value="a.key">{{ a.label }}</option>
      </select>
      <select v-model="fStatus" class="f-sel" aria-label="상태">
        <option value="">상태 전체</option>
        <option v-for="s in API_STATUSES" :key="s" :value="s">{{ s }}</option>
      </select>
      <select v-model="fGate" class="f-sel" aria-label="게이트">
        <option value="">게이트 전체</option>
        <option value="gate">게이트만</option>
        <option value="nogate">일반만</option>
      </select>
      <button v-if="hasFilter" type="button" class="f-reset" @click="resetFilters">초기화</button>
      <span class="f-count">{{ filtered.length }}건</span>
    </div>

    <!-- 표 -->
    <div class="tbl-wrap">
      <table class="tbl">
        <thead>
          <tr>
            <th class="c-mt sortable" @click="sortBy('method')">메서드<i v-if="sortKey === 'method'">{{ sortDir === 1 ? '▲' : '▼' }}</i></th>
            <th class="c-pt sortable" @click="sortBy('path')">경로<i v-if="sortKey === 'path'">{{ sortDir === 1 ? '▲' : '▼' }}</i></th>
            <th class="c-dm sortable" @click="sortBy('domain')">도메인<i v-if="sortKey === 'domain'">{{ sortDir === 1 ? '▲' : '▼' }}</i></th>
            <th class="c-ar sortable" @click="sortBy('area')">영역<i v-if="sortKey === 'area'">{{ sortDir === 1 ? '▲' : '▼' }}</i></th>
            <th class="c-au sortable" @click="sortBy('auth')">인증<i v-if="sortKey === 'auth'">{{ sortDir === 1 ? '▲' : '▼' }}</i></th>
            <th class="c-gt">게이트</th>
            <th class="c-sm">요약</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="e in filtered" :key="e.id" class="row" tabindex="0" @click="open(e)" @keydown.enter="open(e)">
            <td class="c-mt"><span class="mth" :class="METHOD_CLASS[e.method]">{{ e.method }}</span></td>
            <td class="c-pt"><code>{{ e.path }}</code></td>
            <td class="c-dm">{{ domainLabel(e.domain) }}</td>
            <td class="c-ar"><span class="area-tag" :class="e.area === 'FR01' ? 'a-fr' : 'a-ad'">{{ e.area }}</span></td>
            <td class="c-au">
              <span class="auth" :class="'au-' + e.auth">{{ AUTH_LABEL[e.auth] }}</span>
              <code v-if="e.menuKey" class="mk">{{ e.menuKey }}</code>
            </td>
            <td class="c-gt"><span v-if="e.gate" class="gate-b" title="비가역 게이트">게이트</span><span v-else class="gate-n">·</span></td>
            <td class="c-sm">{{ e.summary }}</td>
          </tr>
          <tr v-if="!filtered.length">
            <td colspan="7" class="empty">조건에 맞는 엔드포인트가 없습니다.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 상세 드로어 -->
    <div v-if="active" class="dr-backdrop" @click="close" />
    <transition name="dr-slide">
      <aside v-if="active" class="dr" role="dialog" aria-label="엔드포인트 상세">
        <div class="dr-head">
          <div class="dr-title">
            <span class="mth" :class="METHOD_CLASS[active.method]">{{ active.method }}</span>
            <code class="dr-path">{{ active.path }}</code>
          </div>
          <button type="button" class="dr-close" title="닫기" aria-label="닫기" @click="close">✕</button>
        </div>
        <div class="dr-body">
          <p class="dr-summary">{{ active.summary }}</p>

          <div class="dr-tags">
            <span class="area-tag" :class="active.area === 'FR01' ? 'a-fr' : 'a-ad'">{{ active.area }}</span>
            <span class="dr-tag">{{ domainLabel(active.domain) }}</span>
            <span class="auth" :class="'au-' + active.auth">{{ AUTH_LABEL[active.auth] }}</span>
            <code v-if="active.menuKey" class="mk">roleGuard: {{ active.menuKey }}</code>
            <span class="status-b" :class="STATUS_CLASS[active.status]">{{ active.status }}</span>
            <span v-if="active.gate" class="gate-b">비가역 게이트</span>
          </div>

          <dl class="dr-dl">
            <dt>요청</dt>
            <dd><code class="blk">{{ active.requestSummary }}</code></dd>
            <dt>응답</dt>
            <dd><code class="blk">{{ active.responseSummary }}</code></dd>
            <dt v-if="active.notes">비고</dt>
            <dd v-if="active.notes" class="note">{{ active.notes }}</dd>
          </dl>

          <p class="dr-hint">
            실제 마운트 프리픽스 — 사용자단 <code>/api/*</code>(+기구현 <code>/auth</code>·<code>/me</code>·<code>/tenant</code>),
            관리자단 <code>/api/admin/*</code> 또는 공용 <code>/api/*</code>+roleGuard.
            클라이언트는 반드시 서버 계층을 경유합니다(외부 API·시크릿 직접 호출 금지).
          </p>
        </div>
      </aside>
    </transition>
  </div>
</template>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; padding: 32px 24px 80px; }
.head h1 { font-size: 24px; font-weight: 700; color: var(--ink-900); }
.sub { margin: 6px 0 24px; font-size: 14px; color: var(--ink-500); line-height: 1.6; }
.sub b { color: var(--ink-800); font-weight: 600; }
.lnk { color: var(--accent-ink); font-weight: 600; }

/* 집계 카드 */
.cards { display: grid; grid-template-columns: repeat(6, 1fr); gap: 12px; margin-bottom: 22px; }
@media (max-width: 880px) { .cards { grid-template-columns: repeat(3, 1fr); } }
@media (max-width: 520px) { .cards { grid-template-columns: repeat(2, 1fr); } }
.card { background: var(--white); border: 1px solid var(--line); border-radius: 12px; padding: 14px 16px; display: flex; flex-direction: column; gap: 4px; }
.c-n { font-size: 22px; font-weight: 700; color: var(--ink-900); font-variant-numeric: tabular-nums; }
.c-n.gate { color: #b45309; }
.c-n.ready { color: var(--accent-ink); }
.c-l { font-size: 11.5px; color: var(--ink-400); }

/* 필터 */
.filters { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-bottom: 18px; }
.f-search { position: relative; display: flex; align-items: center; flex: 1 1 220px; min-width: 180px; }
.f-ico { position: absolute; left: 10px; width: 15px; height: 15px; color: var(--ink-400); pointer-events: none; }
.f-search input { width: 100%; height: 34px; padding: 0 30px 0 30px; border: 1px solid var(--line); border-radius: 8px; font-size: 13px; font-family: inherit; color: var(--ink-900); background: var(--white); }
.f-search input:focus { outline: 2px solid var(--accent-soft); border-color: var(--accent); }
.f-clear { position: absolute; right: 8px; width: 18px; height: 18px; border: 0; border-radius: 4px; background: var(--ink-100); color: var(--ink-500); font-size: 10px; cursor: pointer; }
.f-sel { height: 34px; padding: 0 8px; border: 1px solid var(--line); border-radius: 8px; font-size: 12.5px; font-family: inherit; color: var(--ink-800); background: var(--white); cursor: pointer; }
.f-sel:focus { outline: 2px solid var(--accent-soft); border-color: var(--accent); }
.f-reset { height: 34px; padding: 0 12px; border: 1px solid var(--line); border-radius: 8px; font-size: 12px; font-weight: 600; color: var(--ink-500); background: var(--white); cursor: pointer; font-family: inherit; }
.f-reset:hover { color: var(--ink-900); background: var(--ink-50); }
.f-count { margin-left: auto; font-size: 12px; color: var(--ink-400); font-variant-numeric: tabular-nums; white-space: nowrap; }

/* 표 */
.tbl-wrap { background: var(--white); border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
.tbl { width: 100%; border-collapse: collapse; }
.tbl th, .tbl td { padding: 9px 12px; font-size: 13px; border-bottom: 1px solid var(--ink-50); text-align: left; vertical-align: middle; }
.tbl th { background: var(--ink-50); font-size: 11px; font-weight: 600; color: var(--ink-500); white-space: nowrap; }
.tbl th.sortable { cursor: pointer; user-select: none; }
.tbl th.sortable:hover { color: var(--ink-900); }
.tbl th i { font-style: normal; font-size: 9px; margin-left: 3px; color: var(--accent-ink); }
.tbl tr:last-child td { border-bottom: 0; }
.row { cursor: pointer; transition: background .1s; }
.row:hover { background: var(--accent-soft); }
.row:focus-visible { outline: 2px solid var(--accent); outline-offset: -2px; }
.c-mt { width: 78px; } .c-pt code { font-family: var(--font-mono); font-size: 11.5px; color: var(--ink-700); word-break: break-all; }
.c-dm { width: 116px; color: var(--ink-700); }
.c-ar { width: 62px; } .c-au { width: 120px; } .c-gt { width: 66px; text-align: center !important; }
.c-sm { color: var(--ink-800); }

/* 메서드 뱃지 — 색만이 아니라 텍스트로도 구분(색약 배려) */
.mth { display: inline-block; min-width: 52px; text-align: center; font-size: 10.5px; font-weight: 700; letter-spacing: .02em; padding: 3px 6px; border-radius: 5px; font-family: var(--font-mono); }
.m-get { background: #e6f0ff; color: #1d4ed8; }
.m-post { background: #e9f9e8; color: #16a34a; }
.m-patch { background: #fef3c7; color: #b45309; }
.m-put { background: #f3e8ff; color: #7c3aed; }
.m-del { background: #fee2e2; color: #dc2626; }

.area-tag { display: inline-block; font-size: 10px; font-weight: 700; padding: 2px 6px; border-radius: 4px; }
.a-fr { background: var(--accent-soft); color: var(--accent-ink); }
.a-ad { background: #eef2ff; color: #4338ca; }

.auth { display: inline-block; font-size: 10.5px; font-weight: 600; padding: 2px 7px; border-radius: 999px; }
.au-public { background: var(--ink-100); color: var(--ink-600); }
.au-user { background: #e6f0ff; color: #1d4ed8; }
.au-staff { background: #eef2ff; color: #4338ca; }
.mk { display: inline-block; margin-left: 4px; font-family: var(--font-mono); font-size: 9.5px; color: var(--ink-400); }

.gate-b { display: inline-block; font-size: 10px; font-weight: 700; color: #b45309; background: #fef3c7; padding: 2px 7px; border-radius: 4px; }
.gate-n { color: var(--ink-200); }
.status-b { display: inline-block; font-size: 10px; font-weight: 700; padding: 2px 7px; border-radius: 4px; }
.s-ready { background: #e9f9e8; color: #16a34a; }
.s-todo { background: var(--ink-100); color: var(--ink-600); }
.s-gate { background: #fef3c7; color: #b45309; }

.empty { padding: 34px; text-align: center; font-size: 13px; color: var(--ink-400); }

/* 상세 드로어 */
.dr-backdrop { position: fixed; inset: 0; z-index: 60; background: rgba(20, 30, 48, .12); }
.dr { position: fixed; top: 0; right: 0; bottom: 0; z-index: 61; width: 460px; max-width: 94vw; display: flex; flex-direction: column; background: var(--white); border-left: 1px solid var(--line); box-shadow: -8px 0 28px rgba(20, 30, 48, .14); }
.dr-head { flex-shrink: 0; display: flex; align-items: center; gap: 10px; padding: 14px 16px; border-bottom: 1px solid var(--line); }
.dr-title { display: flex; align-items: center; gap: 8px; min-width: 0; }
.dr-path { font-family: var(--font-mono); font-size: 12.5px; color: var(--ink-900); word-break: break-all; }
.dr-close { margin-left: auto; flex-shrink: 0; width: 28px; height: 28px; border: 0; border-radius: 8px; background: var(--ink-50); color: var(--ink-500); font-size: 13px; cursor: pointer; }
.dr-close:hover { background: var(--ink-100); color: var(--ink-900); }
.dr-body { flex: 1; overflow-y: auto; padding: 18px 16px; }
.dr-summary { font-size: 15px; font-weight: 600; color: var(--ink-900); line-height: 1.5; margin-bottom: 14px; }
.dr-tags { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; margin-bottom: 18px; }
.dr-tag { font-size: 11px; font-weight: 600; color: var(--ink-600); background: var(--ink-50); padding: 3px 8px; border-radius: 5px; }
.dr-dl { display: flex; flex-direction: column; gap: 4px; margin: 0; }
.dr-dl dt { font-size: 11px; font-weight: 700; color: var(--ink-500); margin-top: 12px; }
.dr-dl dt:first-child { margin-top: 0; }
.dr-dl dd { margin: 4px 0 0; }
.blk { display: block; font-family: var(--font-mono); font-size: 11.5px; color: var(--ink-800); background: var(--ink-50); border: 1px solid var(--line); border-radius: 8px; padding: 9px 11px; line-height: 1.55; white-space: pre-wrap; word-break: break-word; }
.dr-dl dd.note { font-size: 12.5px; color: var(--ink-700); line-height: 1.6; background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; padding: 9px 11px; }
.dr-hint { margin-top: 20px; padding-top: 14px; border-top: 1px solid var(--line); font-size: 11.5px; color: var(--ink-400); line-height: 1.7; }
.dr-hint code { font-family: var(--font-mono); font-size: 10.5px; color: var(--ink-600); background: var(--ink-50); padding: 1px 4px; border-radius: 3px; }

.dr-slide-enter-active, .dr-slide-leave-active { transition: transform .22s ease; }
.dr-slide-enter-from, .dr-slide-leave-to { transform: translateX(100%); }
</style>
