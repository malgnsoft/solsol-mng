<template>
  <div class="page">
    <section class="hero">
      <h1 class="hero-title">솔솔 프로젝트 관리</h1>
      <p class="hero-desc">
        솔솔 프로젝트의 문서·기록·진행 사항을 한곳에서 조망합니다.
      </p>
    </section>

    <!-- 프로젝트 개요 (목표 · 기획 방향) -->
    <section class="overview">
      <div class="overview-head">
        <h2 class="overview-title">프로젝트 개요</h2>
        <NuxtLink to="/docs/wbs" class="overview-more">WBS 문서 →</NuxtLink>
      </div>
      <div class="overview-grid">
        <div class="ov-card">
          <p class="ov-label">목표</p>
          <p class="ov-goal">
            맑은소프트가 크리에이터(강사)가 자체 브랜드 사이트로 온라인 강의·디지털 콘텐츠·멤버십을 판매·운영하는
            <b>멀티 테넌트 크리에이터 LMS SaaS “솔솔”</b>을 구축한다.
          </p>
          <div class="ov-channels">
            <span v-for="ch in channels" :key="ch" class="ov-chip">{{ ch }}</span>
          </div>
        </div>
        <div class="ov-card">
          <p class="ov-label">기획 방향</p>
          <ul class="ov-list">
            <li v-for="d in directions" :key="d">{{ d }}</li>
          </ul>
        </div>
      </div>
    </section>

    <!-- 프로젝트 현황 (현황판 요약) -->
    <section class="board-summary">
      <div class="board-summary-head">
        <h2 class="board-summary-title">프로젝트 현황</h2>
        <NuxtLink to="/board" class="board-summary-more">현황판 전체 보기 →</NuxtLink>
      </div>

      <div v-if="wbsPending" class="board-summary-state">현황 불러오는 중…</div>
      <div v-else-if="wbsError || !wbsDoc" class="board-summary-state">현황을 불러올 수 없습니다.</div>
      <AppWbsOverview
        v-else
        :stages="stages"
        :weighted-average="weightedAverage"
      >
        <template #aside>
          <div class="links-card">
            <p class="links-title">바로가기</p>
            <ul class="links">
              <li v-for="link in shortcuts" :key="link.url">
                <a :href="link.url" target="_blank" rel="noopener noreferrer" class="link">
                  <span class="link-main">
                    <span class="link-label">{{ link.label }}</span>
                    <span class="link-url">{{ stripProto(link.url) }}</span>
                  </span>
                  <UIcon name="i-lucide-arrow-up-right" class="link-ext" />
                </a>
              </li>
            </ul>
          </div>
        </template>
      </AppWbsOverview>
    </section>

    <div class="grid">
      <section class="col">
        <div class="col-head">
          <h2 class="col-title">문서</h2>
          <NuxtLink to="/docs" class="col-more">전체 보기 →</NuxtLink>
        </div>
        <ul class="card-list">
          <li v-for="doc in topDocs" :key="doc.path">
            <NuxtLink :to="'/docs' + doc.path" class="doc-card">
              <UIcon name="i-lucide-file-text" class="doc-card-ico" />
              <span class="doc-card-body">
                <span class="doc-card-title">{{ doc.title || doc.path }}</span>
                <span v-if="doc.description" class="doc-card-desc">{{ doc.description }}</span>
              </span>
            </NuxtLink>
          </li>
        </ul>
      </section>

      <section class="col">
        <div class="col-head">
          <h2 class="col-title">최근 작업 이력</h2>
          <NuxtLink to="/history" class="col-more">전체 보기 →</NuxtLink>
        </div>
        <ul class="card-list">
          <li v-for="h in recentHistory" :key="h.path">
            <NuxtLink :to="'/docs' + h.path" class="doc-card">
              <span class="hist-date">{{ formatYmd(historyDate(h.path)) }}</span>
              <span class="doc-card-body">
                <span class="doc-card-title">{{ h.title || h.path }}</span>
              </span>
            </NuxtLink>
          </li>
        </ul>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
const shortcuts = [
  { label: 'Brand site', url: 'https://brand.solsol-dev.workers.dev' },
  { label: 'Customer Admin', url: 'https://customer-admin.solsol-dev.workers.dev' },
  { label: 'Customer Front', url: 'https://customer-front.solsol-dev.workers.dev' },
  { label: 'BackOffice', url: 'https://backoffice.solsol-dev.workers.dev' },
  { label: 'GitHub', url: 'https://github.com/malgnsoft/creatorlms' },
]

const stripProto = (u: string) => u.replace(/^https?:\/\//, '')

const channels = ['온라인 강의', '디지털 콘텐츠', '멤버십 / 구독', '커뮤니티 / 게시판', 'AI 튜터', 'AI 자막 / 번역']
const directions = [
  '멀티 테넌트 SaaS — 크리에이터(테넌트)별 자체 브랜드 사이트({slug}.solsol.so)',
  '4개 앱: Brand site · Customer Admin(강사) · Customer Front(수강생) · BackOffice(운영)',
  '결제 토스페이먼츠 · 정산 기업 펌뱅킹 · 본인인증 NICE · 알림 NHN · 동영상 위캔디오',
  '핵심 도메인: 강의/콘텐츠 · 상품/멤버십 · 커뮤니티 · 결제/정산 · 회원/인증 · AI 튜터 · 알림',
  '스택: Frontend/Backend · DB MySQL · Cloudflare Workers (solsol-dev)',
]

const {
  doc: wbsDoc,
  stages,
  weightedAverage,
  pending: wbsPending,
  error: wbsError,
} = useWbs()

const { data: all } = await useAllDocs()

const docs = computed(() => (all.value ?? []).filter(d => !isHistory(d.path)))
const histories = computed(() =>
  (all.value ?? [])
    .filter(d => isHistory(d.path) && historyDate(d.path))
    .sort((a, b) => (historyDate(b.path) ?? '').localeCompare(historyDate(a.path) ?? ''))
)

const topDocs = computed(() => docs.value.slice(0, 8))
const recentHistory = computed(() => histories.value.slice(0, 6))
</script>

<style scoped>
.page {
  max-width: 1080px;
  margin: 0 auto;
  padding: 40px 24px 64px;
}
.hero {
  margin-bottom: 32px;
}
/* 전체 진행률 옆 간단 바로가기 */
.links-card {
  height: 100%;
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: 12px;
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
}
.links-title {
  font-size: 12px;
  font-weight: 600;
  color: var(--ink-400);
  margin-bottom: 6px;
}
.links {
  display: flex;
  flex-direction: column;
}
.link {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 0;
  border-top: 1px solid var(--ink-50);
}
.links li:first-child .link { border-top: 0; }
.link-main {
  display: flex;
  flex-direction: row;
  align-items: baseline;
  gap: 8px;
  min-width: 0;
}
.link-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-800);
  flex-shrink: 0;
}
.link-url {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--ink-400);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.link:hover .link-label { color: var(--accent-ink); }
.link:hover .link-url { color: var(--accent-ink); }
.link-ext {
  width: 14px;
  height: 14px;
  color: var(--ink-300);
  flex-shrink: 0;
}
.link:hover .link-ext { color: var(--accent-ink); }

/* 프로젝트 개요 */
.overview { margin-bottom: 44px; }
.overview-head { display: flex; align-items: baseline; justify-content: space-between; margin-bottom: 14px; }
.overview-title { font-size: 16px; font-weight: 700; color: var(--ink-900); }
.overview-more { font-size: 13px; color: var(--accent-ink); }
.overview-grid { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 12px; }
@media (max-width: 780px) { .overview-grid { grid-template-columns: 1fr; } }
.ov-card { background: var(--white); border: 1px solid var(--line); border-radius: 12px; padding: 18px 20px; }
.ov-label { font-size: 12px; font-weight: 600; color: var(--ink-400); margin-bottom: 8px; }
.ov-goal { font-size: 14px; line-height: 1.65; color: var(--ink-700); }
.ov-goal b { font-weight: 600; color: var(--ink-900); }
.ov-channels { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 14px; }
.ov-chip { font-size: 12px; font-weight: 500; color: var(--ink-700); background: var(--ink-50); border: 1px solid var(--line); border-radius: 999px; padding: 3px 10px; }
.ov-list { display: flex; flex-direction: column; gap: 8px; }
.ov-list li { position: relative; padding-left: 14px; font-size: 13px; line-height: 1.55; color: var(--ink-700); }
.ov-list li::before { content: ""; position: absolute; left: 0; top: 8px; width: 4px; height: 4px; border-radius: 50%; background: var(--accent); }

.board-summary {
  margin-bottom: 44px;
}
.board-summary-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 14px;
}
.board-summary-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--ink-900);
}
.board-summary-more {
  font-size: 13px;
  color: var(--accent-ink);
}
.board-summary-state {
  padding: 28px;
  text-align: center;
  font-size: 14px;
  color: var(--ink-400);
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: 12px;
}
.hero-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: -0.02em;
}
.hero-desc {
  margin-top: 8px;
  font-size: 15px;
  color: var(--ink-500);
}
.grid {
  display: grid;
  /* minmax(0, 1fr): 카드 내부의 nowrap 긴 텍스트(max-content)가 컬럼을
     밀어내 그리드가 .page 최대폭을 넘어 오버플로하던 문제 방지 → 위 현황
     섹션과 동일 폭 유지. */
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 32px;
}
.col {
  min-width: 0;
}
@media (max-width: 780px) {
  .grid { grid-template-columns: minmax(0, 1fr); }
}
.col-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 12px;
}
.col-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--ink-800);
}
.col-more {
  font-size: 13px;
  color: var(--accent-ink);
}
.card-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.doc-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: 10px;
}
.doc-card:hover {
  border-color: var(--ink-300);
}
.doc-card-ico {
  width: 18px;
  height: 18px;
  color: var(--ink-400);
  flex-shrink: 0;
}
.doc-card-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}
.doc-card-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-900);
}
.doc-card-desc {
  font-size: 12px;
  color: var(--ink-400);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.hist-date {
  flex-shrink: 0;
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--accent-ink);
  width: 78px;
}
</style>
