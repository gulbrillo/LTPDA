<script setup lang="ts">
import { LayoutDashboard, Database, Users, Settings, Eye, EyeOff, RefreshCw, X } from 'lucide-vue-next'
const { user, logout, apiFetch, fetchUser } = useAuth()
const { title } = useTopbar()

// ── Profile dialog ────────────────────────────────────────────────────────────
const showProfile = ref(false)
const showPw = ref(false)
const showMysqlPw = ref(false)
const saving = ref(false)
const profileError = ref('')
const profileSuccess = ref('')
const form = reactive({ first_name: '', last_name: '', email: '', institution: '', password: '', mysql_password: '' })

const shaking = ref(false)
function onOverlayClick() {
  if (shaking.value) return
  shaking.value = true
  setTimeout(() => { shaking.value = false }, 420)
}

function generatePassword(): string {
  const lower = 'abcdefghijklmnopqrstuvwxyz'
  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  const digits = '0123456789'
  const symbols = '!@#$%^&*-_=+'
  const all = lower + upper + digits + symbols
  const bytes = new Uint8Array(24)
  crypto.getRandomValues(bytes)
  const pick = (charset: string, byte: number) => charset[byte % charset.length]
  const chars = [
    pick(lower, bytes[0]), pick(upper, bytes[1]), pick(digits, bytes[2]), pick(symbols, bytes[3]),
    ...Array.from(bytes.slice(4), b => all[b % all.length]),
  ]
  for (let i = chars.length - 1; i > 0; i--) {
    const j = bytes[i % bytes.length] % (i + 1)
    ;[chars[i], chars[j]] = [chars[j], chars[i]]
  }
  return chars.join('')
}

function openProfile() {
  Object.assign(form, {
    first_name: user.value?.first_name ?? '',
    last_name: user.value?.last_name ?? '',
    email: user.value?.email ?? '',
    institution: user.value?.institution ?? '',
    password: '',
    mysql_password: '',
  })
  showPw.value = false
  showMysqlPw.value = false
  profileError.value = ''
  profileSuccess.value = ''
  showProfile.value = true
}

async function saveProfile() {
  saving.value = true
  profileError.value = ''
  profileSuccess.value = ''
  try {
    const body: Record<string, unknown> = {
      first_name: form.first_name || null,
      last_name: form.last_name || null,
      email: form.email || null,
      institution: form.institution || null,
    }
    if (form.password) body.password = form.password
    if (form.mysql_password) body.mysql_password = form.mysql_password
    await apiFetch('/users/me', { method: 'PUT', body })
    await fetchUser()
    profileSuccess.value = 'Profile saved.'
    setTimeout(() => { showProfile.value = false; profileSuccess.value = '' }, 1500)
  } catch (e: unknown) {
    const fe = e as { status?: number; statusCode?: number; data?: { detail?: string }; message?: string }
    const s = fe.status ?? fe.statusCode
    profileError.value = !s
      ? 'Cannot reach the server.'
      : (fe.data?.detail || `Error ${s}.`)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="page">

    <nav class="topbar">
      <!-- Brand (dashboard) vs breadcrumb (all other pages) -->
      <div v-if="title === null" class="brand">
        <AppLogo :size="22" />
        <span>LTPDA Repository</span>
      </div>
      <div v-else class="breadcrumb">
        <AppLogo :size="20" class="logo-mark" />
        <NuxtLink to="/dashboard" class="bc-link">LTPDA Repository</NuxtLink>
        <span class="bc-sep">/</span>
        <span class="bc-current">{{ title }}</span>
      </div>

      <div class="nav-right">
        <NuxtLink to="/dashboard" class="nav-link">
          <LayoutDashboard :size="14" />
          Dashboard
        </NuxtLink>
        <template v-if="user?.is_admin">
          <NuxtLink to="/admin/repos" class="nav-link">
            <Database :size="14" />
            Repositories
          </NuxtLink>
          <NuxtLink to="/admin/users" class="nav-link">
            <Users :size="14" />
            Users
          </NuxtLink>
          <NuxtLink to="/admin/settings" class="nav-link">
            <Settings :size="14" />
            Settings
          </NuxtLink>
        </template>
        <div class="user-field">
          <button class="user-field-name" @click="openProfile">{{ (user?.first_name && user?.last_name) ? `${user.first_name} ${user.last_name}` : user?.username }}</button>
          <button class="user-field-signout" @click="logout">Sign out</button>
        </div>
      </div>
    </nav>

    <slot />

  <!-- Profile dialog -->
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="showProfile" class="profile-overlay" @click.self="onOverlayClick">
        <div class="profile-dialog" :class="{ 'dialog-shake': shaking }">

          <div class="dialog-top">
            <div>
              <h2>My profile</h2>
              <p class="dialog-sub">{{ user?.username }}</p>
            </div>
            <button class="close-btn" @click="showProfile = false" aria-label="Close"><X :size="14" /></button>
          </div>

          <form @submit.prevent="saveProfile">

            <div class="field-pair">
              <div class="field">
                <label>First name</label>
                <input v-model="form.first_name" placeholder="Jane" />
              </div>
              <div class="field">
                <label>Last name</label>
                <input v-model="form.last_name" placeholder="Smith" />
              </div>
            </div>

            <div class="field">
              <label>Email address</label>
              <input v-model="form.email" type="email" placeholder="jane@example.com" />
            </div>

            <div class="field">
              <label>Institution</label>
              <input v-model="form.institution" placeholder="University / organisation" />
            </div>

            <div class="field">
              <label>Web UI password</label>
              <div class="pw-row">
                <input v-model="form.password" :type="showPw ? 'text' : 'password'" placeholder="Leave blank to keep current" autocomplete="new-password" class="pw-input" />
                <button type="button" class="eye-btn" @click="showPw = !showPw"><EyeOff v-if="showPw" /><Eye v-else /></button>
                <button type="button" class="gen-btn" @click="form.password = generatePassword(); showPw = true"><RefreshCw :size="11" /> Generate</button>
              </div>
            </div>

            <div class="field">
              <label>MySQL / MATLAB password</label>
              <div class="pw-row">
                <input v-model="form.mysql_password" :type="showMysqlPw ? 'text' : 'password'" placeholder="Leave blank to keep current" autocomplete="new-password" class="pw-input" />
                <button type="button" class="eye-btn" @click="showMysqlPw = !showMysqlPw"><EyeOff v-if="showMysqlPw" /><Eye v-else /></button>
                <button type="button" class="gen-btn" @click="form.mysql_password = generatePassword(); showMysqlPw = true"><RefreshCw :size="11" /> Generate</button>
              </div>
              <p class="field-hint">Used by MATLAB to connect via JDBC.</p>
            </div>

            <div v-if="profileError" class="dialog-banner dialog-banner-error">{{ profileError }}</div>
            <div v-if="profileSuccess" class="dialog-banner dialog-banner-ok">{{ profileSuccess }}</div>

            <div class="dialog-foot">
              <button type="button" class="btn-cancel" @click="showProfile = false">Cancel</button>
              <button type="submit" class="btn-save" :disabled="saving">
                <span v-if="saving" class="spin spin-sm" />
                Save changes
              </button>
            </div>

          </form>
        </div>
      </div>
    </Transition>
  </Teleport>

  </div>
</template>

<style scoped>
.brand {
  display: flex; align-items: center; gap: 0.6rem;
  font-size: 0.875rem; font-weight: 600; letter-spacing: -0.02em; color: #fff;
}
.nav-link {
  display: flex; align-items: center; gap: 0.35rem;
  font-size: 0.8rem; font-weight: 500; color: rgba(255,255,255,0.75);
  text-decoration: none; padding: 0.3rem 0.6rem; border-radius: 6px;
  transition: background 0.15s, color 0.15s;
}
.nav-link:hover { background: rgba(255,255,255,0.12); color: #fff; }
.nav-link.router-link-exact-active { background: rgba(255,255,255,0.18); color: #fff; }

.user-field {
  display: flex; align-items: stretch;
  border: 1px solid rgba(255,255,255,0.25); border-radius: 8px; overflow: hidden;
}
.user-field-name {
  display: flex; align-items: center;
  padding: 0.3rem 0.65rem;
  background: rgba(255,255,255,0.1);
  font-size: 0.8rem; font-weight: 500; color: rgba(255,255,255,0.75);
  white-space: nowrap; user-select: none;
  border: none; cursor: pointer; transition: background 0.1s, color 0.1s;
}
.user-field-name:hover { background: rgba(255,255,255,0.18); color: #fff; }
.user-field-signout {
  display: flex; align-items: center;
  padding: 0 0.65rem;
  background: rgba(255,255,255,0.18); border: none; border-left: 1px solid rgba(255,255,255,0.25);
  font-size: 0.8rem; font-weight: 600; color: rgba(255,255,255,0.75);
  cursor: pointer; white-space: nowrap;
  transition: background 0.1s, color 0.1s;
}
.user-field-signout:hover { background: rgba(255,255,255,0.28); color: #fff; }

/* ── Profile dialog ── */
.profile-overlay {
  position: fixed; inset: 0; background: rgba(30,48,80,0.4);
  backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center;
  z-index: 50; padding: 1.5rem;
}
.profile-dialog {
  background: #fff; border: 1px solid #d0dcea; border-radius: 14px;
  width: 100%; max-width: 480px; padding: 2rem;
  box-shadow: 0 8px 32px rgba(30,48,80,0.12);
}
.dialog-shake { animation: shake 0.42s ease; }
@keyframes shake {
  0%,100% { transform: translateX(0); }
  20%      { transform: translateX(-6px); }
  40%      { transform: translateX(6px); }
  60%      { transform: translateX(-4px); }
  80%      { transform: translateX(4px); }
}
.dialog-top {
  display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 1.75rem;
}
.dialog-top h2 { font-size: 1rem; font-weight: 700; letter-spacing: -0.02em; color: #1e3050; }
.dialog-sub { font-size: 0.775rem; color: #8aa0b8; margin-top: 0.2rem; }
.close-btn {
  width: 28px; height: 28px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer; color: #a8bdd0;
  border-radius: 6px; transition: background 0.1s, color 0.1s;
}
.close-btn:hover { background: #f0f5fb; color: #4a6080; }
.close-btn svg { width: 12px; height: 12px; }
.field { display: flex; flex-direction: column; gap: 0.4rem; margin-bottom: 1.1rem; }
.field label { font-size: 0.775rem; font-weight: 600; color: #4a6080; }
.field input {
  padding: 0.5rem 0.75rem; border: 1px solid #c8d8ec; border-radius: 8px;
  font-size: 0.825rem; color: #1e3050; background: #fff; outline: none;
  transition: border-color 0.12s, box-shadow 0.12s;
}
.field input:focus { border-color: #2f5596; box-shadow: 0 0 0 3px rgba(47,85,150,0.12); }
.field-pair { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
.pw-row {
  display: flex; align-items: stretch; background: #fff;
  border: 1px solid #c8d8ec; border-radius: 8px; overflow: hidden;
  transition: border-color 0.12s, box-shadow 0.12s;
}
.pw-row:focus-within { border-color: #2f5596; box-shadow: 0 0 0 3px rgba(47,85,150,0.12); }
.pw-input { flex: 1; min-width: 0; padding: 0.5rem 0.75rem; border: none; outline: none; font-size: 0.825rem; color: #1e3050; background: transparent; }
.eye-btn {
  flex-shrink: 0; width: 36px; display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer; color: #a8bdd0; transition: color 0.12s;
}
.eye-btn:hover { color: #4a6080; }
.eye-btn svg { width: 15px; height: 15px; }
.gen-btn {
  flex-shrink: 0; display: flex; align-items: center; gap: 0.3rem;
  padding: 0 0.65rem; background: #eef2f7; border: none; border-left: 1px solid #c8d8ec;
  font-size: 0.72rem; font-weight: 600; color: #4a6080; cursor: pointer; white-space: nowrap;
  transition: background 0.1s, color 0.1s;
}
.gen-btn:hover { background: #dce8f5; color: #2f5596; }
.field-hint { font-size: 0.75rem; color: #8aa0b8; margin-top: 0.3rem; line-height: 1.5; }
.dialog-banner {
  padding: 0.6rem 0.85rem; border-radius: 8px; font-size: 0.8rem; line-height: 1.5; margin-bottom: 1rem;
}
.dialog-banner-error { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
.dialog-banner-ok    { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
.dialog-foot { display: flex; justify-content: flex-end; gap: 0.6rem; padding-top: 0.25rem; }
.btn-cancel {
  padding: 0.5rem 1.1rem; background: none; border: 1px solid #d0dcea;
  border-radius: 8px; font-size: 0.825rem; font-weight: 500; color: #6a84a0; cursor: pointer;
  transition: background 0.1s, border-color 0.1s;
}
.btn-cancel:hover { background: #f4f7fb; border-color: #b8cce0; }
.btn-save {
  display: inline-flex; align-items: center; gap: 0.4rem;
  padding: 0.5rem 1.1rem; background: #1e3050; color: #fff;
  border: none; border-radius: 8px; font-size: 0.825rem; font-weight: 600; cursor: pointer;
  transition: background 0.15s;
}
.btn-save:hover:not(:disabled) { background: #2f5596; }
.btn-save:disabled { opacity: 0.6; cursor: not-allowed; }
.spin { display: inline-block; width: 14px; height: 14px; border: 2px solid rgba(255,255,255,0.4); border-top-color: #fff; border-radius: 50%; animation: spin 0.6s linear infinite; }
.spin-sm { width: 12px; height: 12px; }
@keyframes spin { to { transform: rotate(360deg); } }
.modal-enter-active, .modal-leave-active { transition: opacity 0.18s ease; }
.modal-enter-from, .modal-leave-to { opacity: 0; }
</style>
