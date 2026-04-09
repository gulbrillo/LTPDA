<script setup lang="ts">
import { Eye, EyeOff } from 'lucide-vue-next'
definePageMeta({ layout: false, pageTransition: false })

const { login } = useAuth()
const username = ref('')
const password = ref('')
const showPw = ref(false)
const error = ref('')
const loading = ref(false)

async function submit() {
  loading.value = true
  error.value = ''
  try {
    await login(username.value, password.value)
  } catch {
    error.value = 'Invalid username or password.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="card">
      <div class="logo">
        <AppLogo :size="44" />
      </div>
      <h1>LTPDA Repository</h1>
      <p class="tagline">Sign in to your account</p>

      <form @submit.prevent="submit">
        <div class="field">
          <label>Username</label>
          <input v-model="username" autofocus required autocomplete="username" />
        </div>
        <div class="field">
          <label>Password</label>
          <div class="pw-wrap">
            <input v-model="password" :type="showPw ? 'text' : 'password'" required autocomplete="current-password" class="pw-input" />
            <button type="button" class="pw-eye" @click="showPw = !showPw" :title="showPw ? 'Hide' : 'Show'">
              <EyeOff v-if="showPw" />
              <Eye v-else />
            </button>
          </div>
        </div>

        <p v-if="error" class="error">{{ error }}</p>

        <button type="submit" :disabled="loading" class="btn-primary">
          <span v-if="loading" class="spinner" />
          {{ loading ? 'Signing in…' : 'Sign in' }}
        </button>
      </form>

      <p class="footer">LTPDA Repository v3.0</p>
    </div>
  </div>
</template>

<style scoped>
/* login.vue — vertically + horizontally centred card */
.page {
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
}
.card {
  background: #ffffff;
  border: 1px solid #d0dcea;
  border-radius: 14px;
  padding: 2.5rem 2rem;
  width: 100%; max-width: 360px;
  display: flex; flex-direction: column; align-items: center;
}
.logo { margin-bottom: 1.25rem; }
h1 {
  font-size: 1.2rem; font-weight: 700;
  letter-spacing: -0.03em; color: #1e3050; margin-bottom: 0.3rem;
}
.tagline { font-size: 0.825rem; color: #6a84a0; margin-bottom: 1.75rem; }
form { width: 100%; display: flex; flex-direction: column; }
.field { gap: 0.3rem; margin-bottom: 0.85rem; }
.error {
  font-size: 0.8rem; color: #b91c1c;
  background: #fef2f2; border: 1px solid #fecaca;
  border-radius: 8px; padding: 0.5rem 0.7rem; margin-bottom: 0.85rem;
}
.btn-primary {
  width: 100%; padding: 0.7rem;
  font-size: 0.875rem; font-weight: 800;
  margin-top: 0.25rem; border-radius: 9px;
}
.spinner {
  width: 14px; height: 14px; flex-shrink: 0;
  border: 2px solid rgba(26,52,97,0.3); border-top-color: #1a3461;
  border-radius: 50%; animation: spin 0.6s linear infinite;
}
.footer { font-size: 0.75rem; color: #a8bdd0; margin-top: 1.75rem; }
</style>
