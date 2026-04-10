<script setup lang="ts">
import { Plus, X, Eye, EyeOff, UserRound, RefreshCw } from 'lucide-vue-next'

definePageMeta({ layout: 'default' })

interface User {
  id: number
  username: string
  first_name: string | null
  last_name: string | null
  email: string | null
  institution: string | null
  is_admin: boolean
  created_at: string
}

const { apiFetch, user: currentUser } = useAuth()
const { setTitle } = useTopbar()
onMounted(() => setTitle('Users'))

const users = ref<User[]>([])
const loading = ref(false)
const error = ref('')
const notice = ref('')

const shaking = ref(false)
function onOverlayClick() {
  if (shaking.value) return
  shaking.value = true
  setTimeout(() => { shaking.value = false }, 420)
}

const showDialog = ref(false)
const editTarget = ref<User | null>(null)
const showPw = ref(false)
const showMysqlPw = ref(false)
const saving = ref(false)
const dialogError = ref('')
const dialogSuccess = ref('')
const form = reactive({
  username: '',
  password: '',
  mysql_password: '',
  first_name: '',
  last_name: '',
  email: '',
  institution: '',
  is_admin: false,
})

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

// Converts a fetch/network error into a user-facing message.
// Distinguishes between "server unreachable" (no status code) and "server returned an error".
function apiErrorMessage(e: unknown): string {
  const fe = e as { status?: number; statusCode?: number; data?: { detail?: string; error?: string }; message?: string }
  const status = fe.status ?? fe.statusCode
  if (!status) return 'Cannot reach the server. Check your connection or try again later.'
  const detail = fe.data?.detail || fe.data?.error
  if (detail) return detail
  if (status === 401) return 'Session expired — please log in again.'
  if (status === 403) return 'You do not have permission to do this.'
  if (status === 409) return 'Conflict: that username already exists.'
  if (status >= 500) return `Server error (${status}). Check the server logs for details.`
  return fe.message || `Unexpected error (${status}).`
}

async function loadUsers() {
  loading.value = true
  try {
    users.value = await apiFetch<User[]>('/users')
  } catch (e: unknown) {
    error.value = apiErrorMessage(e)
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editTarget.value = null
  showPw.value = false
  showMysqlPw.value = false
  dialogError.value = ''
  dialogSuccess.value = ''
  Object.assign(form, { username: '', password: '', mysql_password: '', first_name: '', last_name: '', email: '', institution: '', is_admin: false })
  showDialog.value = true
}

function openEdit(u: User) {
  editTarget.value = u
  showPw.value = false
  showMysqlPw.value = false
  dialogError.value = ''
  dialogSuccess.value = ''
  Object.assign(form, { username: u.username, password: '', mysql_password: '', first_name: u.first_name ?? '', last_name: u.last_name ?? '', email: u.email ?? '', institution: u.institution ?? '', is_admin: u.is_admin })
  showDialog.value = true
}

async function saveUser() {
  saving.value = true
  dialogError.value = ''
  dialogSuccess.value = ''
  try {
    if (editTarget.value) {
      const body: Record<string, unknown> = {
        first_name: form.first_name || null,
        last_name: form.last_name || null,
        email: form.email || null,
        institution: form.institution || null,
        is_admin: form.is_admin,
      }
      if (form.password) body.password = form.password
      if (form.mysql_password) body.mysql_password = form.mysql_password
      await apiFetch(`/users/${editTarget.value.id}`, { method: 'PUT', body })
    } else {
      await apiFetch('/users', { method: 'POST', body: { ...form } })
    }
    await loadUsers()
    dialogSuccess.value = 'User saved.'
    setTimeout(() => { showDialog.value = false; dialogSuccess.value = '' }, 1500)
  } catch (e: unknown) {
    dialogError.value = apiErrorMessage(e)
  } finally {
    saving.value = false
  }
}

const deleteTarget = ref<User | null>(null)
const deleting = ref(false)

function openDelete(u: User) {
  deleteTarget.value = u
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  const u = deleteTarget.value
  deleting.value = true
  error.value = ''
  notice.value = ''
  try {
    await apiFetch(`/users/${u.id}`, { method: 'DELETE' })
    deleteTarget.value = null
    await loadUsers()
    notice.value = `"${u.username}" deleted.`
    setTimeout(() => { notice.value = '' }, 4000)
  } catch (e: unknown) {
    error.value = apiErrorMessage(e)
    deleteTarget.value = null
  } finally {
    deleting.value = false
  }
}

function initials(u: User) {
  if (u.first_name && u.last_name) return (u.first_name[0] + u.last_name[0]).toUpperCase()
  return u.username[0].toUpperCase()
}

function fullName(u: User) {
  return [u.first_name, u.last_name].filter(Boolean).join(' ')
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
}

onMounted(() => loadUsers())
</script>

<template>
  <div class="page-wrap">
  <main class="main">

      <div class="page-head">
        <div>
          <h1>Users</h1>
          <p class="page-sub">Manage who has access to this repository.</p>
        </div>
        <button class="btn-primary" @click="openCreate">
          <Plus :size="13" />
          New user
        </button>
      </div>

      <div v-if="notice" class="banner-ok">{{ notice }}</div>
      <div v-if="error" class="banner-error">
        {{ error }}
        <button @click="error = ''">✕</button>
      </div>

      <!-- Table -->
      <div class="table-wrap">

        <div v-if="loading" class="table-loading">
          <div class="spin"/>
        </div>

        <template v-else-if="users.length">
          <table class="table">
            <thead>
              <tr>
                <th>User</th>
                <th>Email</th>
                <th>Institution</th>
                <th>Role</th>
                <th>Joined</th>
                <th/>
              </tr>
            </thead>
            <tbody>
              <tr v-for="u in users" :key="u.id">
                <td>
                  <div class="user-cell">
                    <div class="user-av">{{ initials(u) }}</div>
                    <div class="user-meta">
                      <span class="user-name">{{ u.username }}</span>
                      <span v-if="fullName(u)" class="user-full">{{ fullName(u) }}</span>
                    </div>
                  </div>
                </td>
                <td>{{ u.email || '—' }}</td>
                <td>{{ u.institution || '—' }}</td>
                <td>
                  <span class="badge" :class="u.is_admin ? 'badge-admin' : 'badge-user'">
                    {{ u.is_admin ? 'Admin' : 'Member' }}
                  </span>
                </td>
                <td>{{ formatDate(u.created_at) }}</td>
                <td class="row-actions">
                  <button class="act-btn" @click="openEdit(u)">Edit</button>
                  <button
                    class="act-btn act-danger"
                    :disabled="u.id === currentUser?.id"
                    @click="openDelete(u)"
                  >Remove</button>
                </td>
              </tr>
            </tbody>
          </table>
        </template>

        <div v-else class="empty-state">
          <UserRound :size="52" />
          <p>No users yet</p>
        </div>

      </div>
  </main>

  <!-- Dialog -->
  <Teleport to="body">
      <Transition name="modal">
        <div v-if="showDialog" class="overlay" @click.self="onOverlayClick">
          <div class="dialog" :class="{ 'dialog-shake': shaking }">

          <div class="dialog-top">
            <div>
              <h2>{{ editTarget ? 'Edit user' : 'Create user' }}</h2>
              <p v-if="editTarget" class="dialog-sub">{{ editTarget.username }}</p>
            </div>
            <button class="close-btn" @click="showDialog = false" aria-label="Close">
              <X :size="14" />
            </button>
          </div>

          <form @submit.prevent="saveUser">

            <div v-if="!editTarget" class="field">
              <label>Username <span class="req">*</span></label>
              <input v-model="form.username" required autocomplete="off" placeholder="e.g. jsmith"/>
            </div>

            <div class="field-pair">
              <div class="field">
                <label>First name</label>
                <input v-model="form.first_name" placeholder="Jane"/>
              </div>
              <div class="field">
                <label>Last name</label>
                <input v-model="form.last_name" placeholder="Smith"/>
              </div>
            </div>

            <div class="field">
              <label>Email address</label>
              <input v-model="form.email" type="email" placeholder="jane@example.com"/>
            </div>

            <div class="field">
              <label>Institution</label>
              <input v-model="form.institution" placeholder="University / organisation"/>
            </div>

            <div class="field">
              <label>
                Web UI password
                <span v-if="!editTarget" class="req">*</span>
              </label>
              <div class="pw-row">
                <input
                  v-model="form.password"
                  :type="showPw ? 'text' : 'password'"
                  :required="!editTarget"
                  :placeholder="editTarget ? 'Leave blank to keep current' : ''"
                  autocomplete="new-password"
                  class="pw-input"
                />
                <button type="button" class="eye-btn" @click="showPw = !showPw">
                  <EyeOff v-if="showPw" /><Eye v-else />
                </button>
                <button type="button" class="gen-btn" @click="form.password = generatePassword(); showPw = true">
                  <RefreshCw :size="11" /> Generate
                </button>
              </div>
            </div>

            <div class="field">
              <label>MySQL / MATLAB password</label>
              <div class="pw-row">
                <input
                  v-model="form.mysql_password"
                  :type="showMysqlPw ? 'text' : 'password'"
                  :placeholder="editTarget ? 'Leave blank to keep current' : 'Leave blank to use web UI password'"
                  autocomplete="new-password"
                  class="pw-input"
                />
                <button type="button" class="eye-btn" @click="showMysqlPw = !showMysqlPw">
                  <EyeOff v-if="showMysqlPw" /><Eye v-else />
                </button>
                <button type="button" class="gen-btn" @click="form.mysql_password = generatePassword(); showMysqlPw = true">
                  <RefreshCw :size="11" /> Generate
                </button>
              </div>
              <p class="field-hint">Used by MATLAB to connect via JDBC. Can differ from the web UI password.</p>
            </div>

            <!-- Admin toggle -->
            <label class="toggle-row" :class="{ 'toggle-on': form.is_admin }">
              <div class="toggle-text">
                <span class="toggle-label">Administrator</span>
                <span class="toggle-desc">Can manage users and repository settings</span>
              </div>
              <div class="toggle-track" :class="{ active: form.is_admin }">
                <input v-model="form.is_admin" type="checkbox" class="sr-only"/>
                <div class="toggle-thumb"/>
              </div>
            </label>

            <div v-if="dialogError" class="dialog-banner dialog-banner-error">{{ dialogError }}</div>
            <div v-if="dialogSuccess" class="dialog-banner dialog-banner-ok">{{ dialogSuccess }}</div>

            <div class="dialog-foot">
              <button type="button" class="btn-cancel" @click="showDialog = false">Cancel</button>
              <button type="submit" class="btn-primary" :disabled="saving">
                <span v-if="saving" class="spin spin-sm"/>
                {{ editTarget ? 'Save changes' : 'Create user' }}
              </button>
            </div>

          </form>
          </div>
        </div>
      </Transition>
  </Teleport>

  <!-- Delete confirmation dialog -->
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="deleteTarget" class="overlay" @click.self="deleteTarget = null">
        <div class="dialog">
          <div class="dialog-top">
            <h2>Delete user</h2>
            <button class="close-btn" @click="deleteTarget = null" aria-label="Close"><X :size="14" /></button>
          </div>
          <p class="del-body">Permanently delete user <strong>{{ deleteTarget.username }}</strong>?</p>
          <p class="del-warn">This will remove the app account and drop the MySQL user. This cannot be undone.</p>
          <div class="dialog-foot">
            <button type="button" class="btn-cancel" @click="deleteTarget = null">Cancel</button>
            <button type="button" class="btn-danger" :disabled="deleting" @click="confirmDelete">
              <span v-if="deleting" class="spin spin-sm" />
              Delete permanently
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
  </div>
</template>

<style scoped>
/* ── Main content ── */
.page-wrap { flex: 1; display: flex; flex-direction: column; }
.main { flex: 1; padding: 2.5rem 2rem; max-width: 1000px; margin: 0 auto; width: 100%; }
.page-head {
  display: flex; align-items: flex-start; justify-content: space-between;
  gap: 1rem; margin-bottom: 1.75rem;
}
h1 { font-size: 1.2rem; font-weight: 700; letter-spacing: -0.025em; color: #1e3050; }
.page-sub { font-size: 0.825rem; color: #6a84a0; margin-top: 0.25rem; }

/* ── Table ── */
.table-wrap { background: #ffffff; border: 1px solid #d0dcea; border-radius: 12px; overflow: hidden; }
.table-loading { display: flex; justify-content: center; align-items: center; padding: 4rem; }
.table { width: 100%; border-collapse: collapse; font-size: 0.825rem; }
.table thead th {
  padding: 0.75rem 1.25rem; text-align: left;
  font-size: 0.68rem; font-weight: 700;
  text-transform: uppercase; letter-spacing: 0.09em;
  color: #8aa0b8; background: #f4f7fb; border-bottom: 1px solid #d0dcea;
}
.table tbody tr { transition: background 0.1s; }
.table tbody tr:hover { background: #f8fafd; }
.table tbody td { padding: 1rem 1.25rem; border-bottom: 1px solid #e8eef6; color: #4a6080; vertical-align: middle; }
.table tbody tr:last-child td { border-bottom: none; }

.user-cell { display: flex; align-items: center; gap: 0.75rem; }
.user-av {
  width: 32px; height: 32px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  background: #e8f0f8; color: #2f5596; border-radius: 50%; font-size: 0.72rem; font-weight: 700;
}
.user-meta { display: flex; flex-direction: column; gap: 0.1rem; }
.user-name { font-weight: 600; color: #1e3050; }
.user-full { font-size: 0.775rem; color: #8aa0b8; }

.row-actions { display: flex; gap: 0.4rem; }
.act-btn {
  font-size: 0.775rem; font-weight: 500; color: #6a84a0;
  background: none; border: 1px solid #d0dcea;
  border-radius: 6px; padding: 0.3rem 0.65rem; cursor: pointer; white-space: nowrap;
  transition: background 0.1s, color 0.1s, border-color 0.1s;
}
.act-btn:hover:not(:disabled) { background: #f0f5fb; color: #2f5596; border-color: #b8cce0; }
.act-danger:hover:not(:disabled) { background: #fef2f2; color: #b91c1c; border-color: #fecaca; }
.act-btn:disabled { opacity: 0.25; cursor: not-allowed; }

.empty-state {
  display: flex; flex-direction: column; align-items: center;
  gap: 0.75rem; padding: 4rem; color: #b8cce0; font-size: 0.825rem;
}

/* ── Toggle ── */
.toggle-row {
  display: flex; align-items: center; justify-content: space-between; gap: 1.5rem;
  padding: 1rem; background: #f8fafd; border: 1px solid #d0dcea;
  border-radius: 10px; cursor: pointer; margin-bottom: 1.75rem;
  transition: border-color 0.12s, background 0.12s;
}
.toggle-row.toggle-on { border-color: #f0a32a; background: #fffbee; }
.toggle-text { display: flex; flex-direction: column; gap: 0.2rem; }
.toggle-label { font-size: 0.825rem; font-weight: 600; color: #1e3050; }
.toggle-desc { font-size: 0.775rem; color: #6a84a0; }
.toggle-track {
  flex-shrink: 0; width: 38px; height: 22px; background: #c8d8ec;
  border-radius: 999px; position: relative; transition: background 0.18s;
}
.toggle-track.active { background: #f0a32a; }
.toggle-thumb {
  position: absolute; top: 3px; left: 3px; width: 16px; height: 16px;
  background: #fff; border-radius: 50%; transition: transform 0.18s;
  box-shadow: 0 1px 3px rgba(0,0,0,0.15);
}
.toggle-track.active .toggle-thumb { transform: translateX(16px); }
.sr-only { position: absolute; opacity: 0; pointer-events: none; width: 1px; height: 1px; overflow: hidden; }



</style>
