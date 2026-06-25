<script setup lang="ts">
import { screenAreas } from '~/utils/screenList'
import type { ScreenItem } from '~/utils/screenList'

useHead({ title: '화면 진척' })

const STAGES = [
  { key: 'design', label: '디자인' },
  { key: 'publish', label: '퍼블리싱' },
  { key: 'dev', label: '개발' },
  { key: 'test', label: '테스트' },
] as const

function pct(items: ScreenItem[], stage: keyof ScreenItem): number {
  if (!items.length) return 0
  const done = items.filter(i => i[stage] === true).length
  return Math.round((done / items.length) * 100)
}
function areaAll(area: typeof screenAreas[number]) {
  return [...area.pages, ...area.modals]
}
</script>

<template>
  <div class="page">
    <header class="head">
      <h1>화면 진척</h1>
      <p class="sub">영역별 화면 목록과 <b>디자인 · 퍼블리싱(목업) · 개발 · 테스트</b> 진척. 일반 페이지와 모달창을 구분합니다.
        화면 정본은 <NuxtLink to="/validation" class="lnk">검증 화면목록</NuxtLink>(읽기 전용).</p>
    </header>

    <!-- 영역 요약 -->
    <div class="summary">
      <div v-for="a in screenAreas" :key="a.key" class="sum-card" :class="{ pending: a.pending }">
        <div class="sum-top">
          <span class="sum-label">{{ a.label }}</span>
          <span v-if="a.pending" class="sum-badge">대기</span>
          <span v-else class="sum-count">{{ a.pages.length }}P · {{ a.modals.length }}M</span>
        </div>
        <div v-if="!a.pending" class="sum-bars">
          <div v-for="s in STAGES" :key="s.key" class="sum-bar">
            <span class="sb-l">{{ s.label }}</span>
            <span class="sb-track"><i :style="{ width: pct(areaAll(a), s.key) + '%' }" /></span>
            <span class="sb-v">{{ pct(areaAll(a), s.key) }}%</span>
          </div>
        </div>
        <div v-else class="sum-pending">{{ a.source }}</div>
      </div>
    </div>

    <!-- 영역별 상세 -->
    <section v-for="a in screenAreas" :key="a.key" class="area">
      <div class="area-head">
        <h2>{{ a.label }}</h2>
        <span class="area-src">{{ a.source }}</span>
      </div>

      <div v-if="a.pending" class="empty">Figma 추출 대기 — 해당 영역 링크를 주시면 같은 방식으로 채웁니다.</div>

      <template v-else>
        <!-- 일반 페이지 -->
        <h3 class="grp-title">일반 페이지 <span class="n">{{ a.pages.length }}</span></h3>
        <div class="tbl-wrap">
          <table class="tbl">
            <thead>
              <tr><th class="c-grp">구분</th><th class="c-id">화면ID</th><th class="c-nm">화면명</th>
                <th v-for="s in STAGES" :key="s.key" class="c-st">{{ s.label }}</th></tr>
            </thead>
            <tbody>
              <tr v-for="(it, i) in a.pages" :key="a.key + 'p' + i">
                <td class="c-grp">{{ it.group }}</td>
                <td class="c-id"><code v-if="it.id">{{ it.id }}</code><span v-else class="dash">—</span></td>
                <td class="c-nm">{{ it.name }}</td>
                <td v-for="s in STAGES" :key="s.key" class="c-st">
                  <span class="dot" :class="it[s.key] ? 'on' : 'off'">{{ it[s.key] ? '✓' : '·' }}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- 모달창 -->
        <h3 class="grp-title">모달창 <span class="n">{{ a.modals.length }}</span></h3>
        <div class="tbl-wrap">
          <table class="tbl">
            <thead>
              <tr><th class="c-grp">위치</th><th class="c-id">화면ID</th><th class="c-nm">모달명</th>
                <th v-for="s in STAGES" :key="s.key" class="c-st">{{ s.label }}</th></tr>
            </thead>
            <tbody>
              <tr v-for="(it, i) in a.modals" :key="a.key + 'm' + i">
                <td class="c-grp">{{ it.group }}</td>
                <td class="c-id"><span class="dash">—</span></td>
                <td class="c-nm">{{ it.name }}</td>
                <td v-for="s in STAGES" :key="s.key" class="c-st">
                  <span class="dot" :class="it[s.key] ? 'on' : 'off'">{{ it[s.key] ? '✓' : '·' }}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>
    </section>
  </div>
</template>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; padding: 32px 24px 80px; }
.head h1 { font-size: 24px; font-weight: 700; color: var(--ink-900); }
.sub { margin: 6px 0 24px; font-size: 14px; color: var(--ink-500); line-height: 1.6; }
.sub b { color: var(--ink-800); font-weight: 600; }
.lnk { color: var(--accent-ink); font-weight: 600; }

.summary { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 36px; }
@media (max-width: 880px) { .summary { grid-template-columns: 1fr 1fr; } }
.sum-card { background: var(--white); border: 1px solid var(--line); border-radius: 12px; padding: 16px; }
.sum-card.pending { background: var(--ink-50); }
.sum-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.sum-label { font-size: 13px; font-weight: 700; color: var(--ink-900); }
.sum-count { font-size: 11px; color: var(--ink-400); font-variant-numeric: tabular-nums; }
.sum-badge { font-size: 10px; font-weight: 700; color: var(--ink-400); background: var(--ink-100); padding: 2px 7px; border-radius: 999px; }
.sum-bars { display: flex; flex-direction: column; gap: 6px; }
.sum-bar { display: grid; grid-template-columns: 48px 1fr 34px; align-items: center; gap: 8px; }
.sb-l { font-size: 11px; color: var(--ink-500); }
.sb-track { height: 6px; background: var(--ink-50); border-radius: 3px; overflow: hidden; }
.sb-track i { display: block; height: 100%; background: var(--accent); border-radius: 3px; }
.sb-v { font-size: 11px; color: var(--ink-500); text-align: right; font-variant-numeric: tabular-nums; }
.sum-pending { font-size: 11px; color: var(--ink-400); }

.area { margin-bottom: 44px; }
.area-head { display: flex; align-items: baseline; gap: 10px; margin-bottom: 16px; padding-bottom: 10px; border-bottom: 2px solid var(--ink-900); }
.area-head h2 { font-size: 18px; font-weight: 700; color: var(--ink-900); }
.area-src { font-size: 12px; color: var(--ink-400); }
.empty { padding: 28px; text-align: center; font-size: 13px; color: var(--ink-400); background: var(--white); border: 1px dashed var(--line); border-radius: 12px; }
.grp-title { font-size: 14px; font-weight: 700; color: var(--ink-800); margin: 22px 0 10px; }
.grp-title .n { font-size: 12px; font-weight: 600; color: var(--ink-400); margin-left: 4px; }

.tbl-wrap { background: var(--white); border: 1px solid var(--line); border-radius: 10px; overflow: hidden; }
.tbl { width: 100%; border-collapse: collapse; }
.tbl th, .tbl td { padding: 10px 12px; font-size: 13px; border-bottom: 1px solid var(--ink-50); text-align: left; }
.tbl th { background: var(--ink-50); font-size: 11px; font-weight: 600; color: var(--ink-500); }
.tbl tr:last-child td { border-bottom: 0; }
.c-grp { width: 150px; color: var(--ink-500); font-size: 12px; }
.c-id { width: 150px; } .c-id code { font-family: var(--font-mono); font-size: 11px; color: var(--ink-600); }
.c-nm { color: var(--ink-900); font-weight: 500; }
.c-st { width: 64px; text-align: center !important; }
.dash { color: var(--ink-300); }
.dot { display: inline-grid; place-items: center; width: 22px; height: 22px; border-radius: 6px; font-size: 12px; font-weight: 700; }
.dot.on { background: #e9f9e8; color: #16a34a; }
.dot.off { background: var(--ink-50); color: var(--ink-300); }
</style>
