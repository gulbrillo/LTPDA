<script setup lang="ts">
definePageMeta({ layout: false })

const { login } = useAuth()
const username = ref('')
const password = ref('')
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
  <div class="login-page">
    <div class="login-card">
      <h1>LTPDA Repository</h1>
      <p class="subtitle">Sign in to continue</p>
      <form @submit.prevent="submit">
        <div class="field">
          <label>Username</label>
          <input v-model="username" autofocus required />
        </div>
        <div class="field">
          <label>Password</label>
          <input v-model="password" type="password" required />
        </div>
        <div v-if="error" class="error-msg">{{ error }}</div>
        <button type="submit" :disabled="loading" class="btn-primary">
          {{ loading ? 'Signing in…' : 'Sign in' }}
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
}
.login-card {
  background: white;
  border-radius: 8px;
  padding: 2.5rem;
  width: 100%;
  max-width: 360px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
}
h1 { margin: 0 0 0.25rem; font-size: 1.5rem; }
.subtitle { color: #666; margin: 0 0 1.5rem; font-size: 0.9rem; }
.field { display: flex; flex-direction: column; gap: 0.25rem; margin-bottom: 0.75rem; }
label { font-size: 0.85rem; font-weight: 500; color: #444; }
input {
  padding: 0.5rem 0.6rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 0.9rem;
}
input:focus { outline: none; border-color: #2563eb; }
.error-msg { color: #dc2626; font-size: 0.85rem; margin-bottom: 0.5rem; }
.btn-primary {
  width: 100%;
  padding: 0.65rem;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 0.5rem;
}
.btn-primary:disabled { background: #93c5fd; cursor: not-allowed; }
.btn-primary:hover:not(:disabled) { background: #1d4ed8; }
</style>
