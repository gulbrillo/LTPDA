<script setup lang="ts">
import { Eye, EyeOff } from 'lucide-vue-next'

const { reAuthVisible, reAuth, logout, user } = useAuth()
const password = ref('')
const showPw = ref(false)
const error = ref('')
const loading = ref(false)

async function submit() {
  if (!password.value) return
  loading.value = true
  error.value = ''
  try {
    await reAuth(password.value)
    password.value = ''
    showPw.value = false
  } catch {
    error.value = 'Incorrect password.'
  } finally {
    loading.value = false
  }
}

watch(reAuthVisible, (visible) => {
  if (visible) {
    password.value = ''
    showPw.value = false
    error.value = ''
  }
})
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="reAuthVisible" class="overlay">
        <div class="dialog">

          <div class="dialog-top">
            <h2>Session expired</h2>
            <p class="dialog-sub">You have been inactive for 15 minutes.</p>
          </div>

          <p class="dialog-desc">Enter your password to continue where you left off.</p>

          <form @submit.prevent="submit">
            <div class="field">
              <label>Username</label>
              <input :value="user?.username ?? ''" disabled class="input-disabled" autocomplete="username" />
            </div>

            <div class="field">
              <label>Password</label>
              <div class="pw-wrap">
                <input
                  v-model="password"
                  :type="showPw ? 'text' : 'password'"
                  autofocus
                  required
                  autocomplete="current-password"
                  class="pw-input"
                />
                <button type="button" class="pw-eye" @click="showPw = !showPw" :title="showPw ? 'Hide' : 'Show'">
                  <EyeOff v-if="showPw" /><Eye v-else />
                </button>
              </div>
            </div>

            <div v-if="error" class="error">{{ error }}</div>

            <div class="dialog-foot">
              <button type="button" class="btn-signout" @click="logout">Sign out instead</button>
              <button type="submit" class="btn-continue" :disabled="loading">
                <span v-if="loading" class="spin" />
                {{ loading ? 'Verifying…' : 'Continue' }}
              </button>
            </div>
          </form>

        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(15, 28, 54, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
}
.dialog {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 24px 60px rgba(10, 20, 50, 0.22);
  width: 100%;
  max-width: 360px;
  padding: 2rem;
}
.dialog-top {
  margin-bottom: 0.75rem;
}
.dialog-top h2 {
  font-size: 1rem;
  font-weight: 700;
  color: #1e3050;
  margin: 0 0 0.2rem;
}
.dialog-sub {
  font-size: 0.8rem;
  color: #6a84a0;
  margin: 0;
}
.dialog-desc {
  font-size: 0.825rem;
  color: #374151;
  margin-bottom: 1.5rem;
}
.field {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  margin-bottom: 0.85rem;
}
.input-disabled {
  background: #f4f6f9;
  color: #6a84a0;
  cursor: default;
}
.pw-wrap {
  display: flex;
  align-items: stretch;
}
.pw-input {
  flex: 1;
  border-radius: 8px 0 0 8px !important;
}
.pw-eye {
  padding: 0 0.65rem;
  border: 1px solid #d0dcea;
  border-left: none;
  border-radius: 0 8px 8px 0;
  background: #f4f6f9;
  color: #6a84a0;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background 0.1s;
}
.pw-eye:hover {
  background: #e8edf4;
}
.error {
  font-size: 0.8rem;
  color: #b91c1c;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 8px;
  padding: 0.5rem 0.7rem;
  margin-bottom: 0.85rem;
}
.dialog-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  gap: 0.75rem;
}
.btn-signout {
  font-size: 0.8rem;
  color: #6a84a0;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.3rem 0.25rem;
  text-decoration: underline;
  text-underline-offset: 2px;
  transition: color 0.1s;
}
.btn-signout:hover {
  color: #374151;
}
.btn-continue {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.55rem 1.25rem;
  background: #1e3050;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 0.825rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s;
}
.btn-continue:hover:not(:disabled) {
  background: #2f5596;
}
.btn-continue:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.spin {
  display: inline-block;
  width: 12px;
  height: 12px;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
</style>
