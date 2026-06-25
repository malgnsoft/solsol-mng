<template>
  <div class="page">
    <h1 class="page-title">검증</h1>
    <p class="page-desc">
      Figma 화면설계서 기반 검증 SoT(정본). 개발은 화면ID 단위로 이 문서에 대조한다.
      <br />
      연동 절차: <NuxtLink to="/docs/dev_validation_process" class="page-link">DEV_VALIDATION_PROCESS.md</NuxtLink>
    </p>

    <ul class="doc-list">
      <li v-for="doc in validationDocs" :key="doc.path">
        <NuxtLink :to="'/docs' + doc.path" class="doc-row">
          <UIcon name="i-lucide-clipboard-check" class="doc-row-ico" />
          <span class="doc-row-body">
            <span class="doc-row-title">{{ doc.title || doc.path }}</span>
            <span v-if="doc.description" class="doc-row-desc">{{ doc.description }}</span>
          </span>
          <code class="doc-row-path">{{ doc.path }}</code>
        </NuxtLink>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { useAllDocs } from '~/composables/useDocs'

// 정렬 기준: 권장 순서 맵 (낮을수록 앞)
const ORDER: Record<string, number> = {
  'readme':                0,
  '00_검증가이드':          1,
  '00_화면목록':            2,
  '01_검증체크리스트':       3,
  '01_customer-front':      4,
  '02_customer-admin':      5,
  '03_brand-site':          6,
  '04_정책요약':            7,
  '05_정책설계서':          8,
}

function sortKey(path: string): number {
  // path 예: /validation/01_customer-front
  const filename = path.split('/').pop()?.toLowerCase() ?? ''
  const idx = ORDER[filename]
  return idx !== undefined ? idx : 99
}

const { data: all } = await useAllDocs()

const validationDocs = computed(() =>
  (all.value ?? [])
    .filter(d => d.path.startsWith('/validation/'))
    .sort((a, b) => sortKey(a.path) - sortKey(b.path))
)

useSeoMeta({ title: '검증' })
</script>

<style scoped>
.page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px 64px;
}
.page-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--ink-900);
}
.page-desc {
  margin: 6px 0 28px;
  font-size: 14px;
  color: var(--ink-500);
  line-height: 1.7;
}
.page-link {
  color: var(--accent-ink);
  text-decoration: underline;
  text-underline-offset: 2px;
}
.page-link:hover {
  opacity: 0.75;
}
.doc-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.doc-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: 10px;
}
.doc-row:hover {
  border-color: var(--ink-300);
}
.doc-row-ico {
  width: 18px;
  height: 18px;
  color: var(--ink-400);
  flex-shrink: 0;
}
.doc-row-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
  flex: 1;
}
.doc-row-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-900);
}
.doc-row-desc {
  font-size: 12px;
  color: var(--ink-400);
}
.doc-row-path {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--ink-300);
  flex-shrink: 0;
}
</style>
