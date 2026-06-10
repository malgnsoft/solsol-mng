<template>
  <div class="login-screen">
    <div class="login-card">
      <div class="login-mark"><AppLogoMark /></div>
      <h1 class="login-title">쏠쏠 프로젝트 관리</h1>
      <p class="login-sub">쏠쏠 크리에이터 LMS 프로젝트 관리 허브</p>

      <form class="login-form" @submit.prevent="submit">
        <label class="login-label" for="login-pw">접근 비밀번호</label>
        <input
          id="login-pw"
          v-model="password"
          type="password"
          class="login-input"
          autocomplete="current-password"
          :disabled="loading"
          autofocus
        >
        <p v-if="error" class="login-error">{{ error }}</p>
        <button type="submit" class="login-btn" :disabled="loading || !password">
          {{ loading ? '확인 중…' : '입장하기' }}
        </button>
      </form>

      <p class="login-hint">회원가입 없이 비밀번호로만 입장합니다.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false })
useHead({ title: '로그인' })

const route = useRoute()
const password = ref('')
const loading = ref(false)
const error = ref('')

async function submit() {
  if (loading.value || !password.value) return
  error.value = ''
  loading.value = true
  try {
    await $fetch('/api/login', { method: 'POST', body: { password: password.value } })
    const redirect = (route.query.redirect as string) || '/'
    await navigateTo(redirect.startsWith('/') ? redirect : '/')
  } catch (e: unknown) {
    const err = e as { data?: { statusMessage?: string }, statusMessage?: string }
    error.value = err?.data?.statusMessage || err?.statusMessage || '비밀번호가 올바르지 않습니다.'
    password.value = ''
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-screen {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 24px;
  background:
    radial-gradient(1200px 600px at 50% -10%, var(--accent-soft) 0%, transparent 60%),
    var(--paper);
}
.login-card {
  width: 100%;
  max-width: 400px;
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: 16px;
  box-shadow: var(--shadow-modal);
  padding: 40px 32px 28px;
  text-align: center;
}
.login-mark {
  width: 48px;
  height: 48px;
  margin: 0 auto 18px;
  background: var(--ink-900);
  color: var(--white);
  border-radius: 12px;
  display: grid;
  place-items: center;
}
.login-mark :deep(svg) {
  width: 26px;
  height: 26px;
}
.login-title {
  font-size: 22px;
  font-weight: 700;
  color: var(--ink-900);
  letter-spacing: -0.01em;
}
.login-sub {
  margin-top: 6px;
  font-size: 13px;
  color: var(--ink-400);
}
.login-form {
  margin-top: 28px;
  text-align: left;
}
.login-label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: var(--ink-700);
  margin-bottom: 8px;
}
.login-input {
  width: 100%;
  height: 46px;
  padding: 0 14px;
  font-size: 15px;
  color: var(--ink-900);
  background: var(--ink-50);
  border: 1px solid var(--line);
  border-radius: 10px;
  outline: none;
  transition: border-color .15s ease, background .15s ease;
}
.login-input:focus {
  background: var(--white);
  border-color: var(--accent);
}
.login-input:disabled {
  opacity: .6;
}
.login-error {
  margin-top: 10px;
  font-size: 13px;
  color: var(--danger-ink);
}
.login-btn {
  width: 100%;
  height: 48px;
  margin-top: 18px;
  font-size: 15px;
  font-weight: 700;
  color: var(--white);
  background: var(--ink-900);
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: opacity .15s ease, transform .05s ease;
}
.login-btn:hover:not(:disabled) {
  opacity: .9;
}
.login-btn:active:not(:disabled) {
  transform: translateY(1px);
}
.login-btn:disabled {
  opacity: .5;
  cursor: not-allowed;
}
.login-hint {
  margin-top: 18px;
  font-size: 12px;
  color: var(--ink-400);
}
</style>
