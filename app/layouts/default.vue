<template>
  <div class="layout-default">
    <header class="gnb" :class="{ 'gnb-hidden': gnbHidden }">
      <div class="gnb-inner">
        <NuxtLink to="/" class="brand">
          <span class="brand-icon"><AppLogoMark /></span>
          <span class="brand-text">쏠쏠</span>
          <span class="brand-sub">프로젝트 관리</span>
        </NuxtLink>
        <nav class="gnb-nav">
          <NuxtLink
            v-for="item in nav"
            :key="item.to"
            :to="item.to"
            class="gnb-link"
          >
            <UIcon :name="item.icon" class="gnb-link-ico" />
            {{ item.label }}
          </NuxtLink>
        </nav>
        <a
          class="gnb-link gnb-repo"
          href="https://github.com/malgnsoft/solsol-mng"
          target="_blank"
          rel="noopener"
        >
          <UIcon name="i-lucide-github" class="gnb-link-ico" />
          GitHub
        </a>
        <button type="button" class="gnb-link gnb-auth" @click="logout">
          <UIcon name="i-lucide-log-out" class="gnb-link-ico" />
          로그아웃
        </button>
      </div>
    </header>

    <main class="layout-main">
      <slot />
    </main>

    <footer v-if="!isFullScreen" class="footer">
      <span>쏠쏠 프로젝트 문서·작업 이력</span>
    </footer>
  </div>
</template>

<script setup lang="ts">
// /wbs(간트)는 100vh 풀스크린 앱이라 푸터를 숨겨 바깥 페이지 스크롤을 없앤다.
// (바깥 스크롤이 생기면 간트 내부 sticky 헤더·좌측 담당 영역이 함께 밀려 올라감)
const route = useRoute()
const isFullScreen = computed(() => route.path === '/wbs')

// /wbs 간트 스크롤 다운 시 GNB도 함께 접는다(wbs.vue 가 set 하는 공유 상태).
const chromeHidden = useState('wbsChromeHidden', () => false)
const gnbHidden = computed(() => isFullScreen.value && chromeHidden.value)

const nav = [
  { to: '/', label: '대시보드', icon: 'i-lucide-layout-dashboard' },
  { to: '/board', label: '현황판', icon: 'i-lucide-gauge' },
  { to: '/wbs', label: 'WBS', icon: 'i-lucide-gantt-chart' },
  { to: '/docs', label: '문서', icon: 'i-lucide-book-text' },
  { to: '/history', label: '작업 이력', icon: 'i-lucide-history' }
]

// 비밀번호 게이트 — 인증 쿠키를 지우고 로그인 화면으로.
const auth = useCookie('mng_auth')
async function logout() {
  auth.value = null
  await navigateTo('/login')
}
</script>

<style scoped>
.layout-default {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: var(--paper);
  overflow-x: clip;
}

.gnb {
  position: sticky;
  top: 0;
  z-index: 40;
  height: 56px;
  background: var(--white);
  border-bottom: 1px solid var(--line);
  overflow: hidden;
  transition: height .24s ease, border-color .24s ease;
}
/* /wbs 스크롤 다운 시 GNB를 위로 접음 (간트 영역 확장) */
.gnb.gnb-hidden {
  height: 0;
  border-bottom-color: transparent;
}
.gnb-inner {
  display: flex;
  align-items: center;
  gap: 24px;
  height: 100%;
  max-width: 1080px;
  margin: 0 auto;
  padding: 0 24px;
}
/* 사용자단(solsol) GNB 로고와 동일 — 마크 아이콘 + "쏠쏠" */
.brand {
  display: flex;
  align-items: center;
  gap: 7px;
  flex-shrink: 0;
}
.brand-icon {
  width: 24px;
  height: 24px;
  background: var(--ink-900);
  color: var(--white);
  border-radius: var(--r-md, 8px);
  display: grid;
  place-items: center;
}
.brand-text {
  font-size: 16px;
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: -0.01em;
  line-height: 1;
}
.brand-sub {
  margin-left: 3px;
  font-size: 12px;
  font-weight: 600;
  color: var(--accent-ink);
  line-height: 1;
}
.gnb-nav {
  display: flex;
  gap: 4px;
  margin-right: auto;
}
.gnb-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-500);
}
.gnb-link:hover {
  color: var(--ink-900);
  background: var(--ink-50);
}
.gnb-link.router-link-active {
  color: var(--ink-900);
  background: var(--ink-50);
}
.gnb-link-ico {
  width: 16px;
  height: 16px;
}
.gnb-repo {
  color: var(--ink-400);
}
.gnb-auth {
  color: var(--ink-400);
  background: none;
  border: none;
  cursor: pointer;
  font-family: inherit;
}

.layout-main {
  flex: 1;
  width: 100%;
  min-width: 0;
}

.footer {
  border-top: 1px solid var(--line);
  padding: 20px 24px;
  text-align: center;
  font-size: 12px;
  color: var(--ink-400);
}
</style>
