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
      <div v-if="reAuthVisible" class="overlay reauth-overlay">
        <div class="dialog reauth-dialog">

          <!-- dialog-top needs an inner <div> wrapping title+sub so they stack vertically
               (global .dialog-top is display:flex justify-content:space-between) -->
          <div class="dialog-top">
            <div>
              <h2>Session expired</h2>
              <p class="dialog-sub">You have been inactive for 15 minutes.</p>
            </div>
          </div>

          <p class="reauth-desc">Enter your password to continue where you left off.</p>

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

            <div v-if="error" class="banner-error reauth-error">{{ error }}</div>

            <div class="dialog-foot reauth-foot">
              <button type="button" class="btn-signout" @click="logout">Sign out instead</button>
              <button type="submit" class="btn-continue" :disabled="loading">
                <span v-if="loading" class="spin spin-sm" />
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
/* Sit above all other overlays (global .overlay is z-index:50) */
.reauth-overlay { z-index: 9999; }

/* Narrower than the default 480px dialog */
.reauth-dialog { max-width: 360px; }

/* Description line between header and fields */
.reauth-desc {
  font-size: 0.825rem;
  color: var(--text-2);
  margin-top: -1rem;      /* pull up under the dialog-top margin */
  margin-bottom: 1.5rem;
}

/* Disabled username input */
.input-disabled {
  background: #f4f6f9 !important;
  color: var(--text-3) !important;
  cursor: default;
}

/* Error banner: remove the bottom margin the global .banner-error doesn't add */
.reauth-error { margin-bottom: 1rem; }

/* Footer: sign-out on the left, continue on the right */
.reauth-foot { justify-content: space-between; }

.btn-signout {
  font-size: 0.8rem;
  color: var(--text-3);
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.3rem 0.25rem;
  text-decoration: underline;
  text-underline-offset: 2px;
  transition: color 0.1s;
}
.btn-signout:hover { color: var(--text); }

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
.btn-continue:hover:not(:disabled) { background: #2f5596; }
.btn-continue:disabled { opacity: 0.6; cursor: not-allowed; }
</style>
