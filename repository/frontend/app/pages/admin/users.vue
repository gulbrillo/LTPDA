<script setup lang="ts">
import { Plus, X, Eye, EyeOff, UserRound, Users, Settings, Database } from 'lucide-vue-next'

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

const { apiFetch, user: currentUser, logout } = useAuth()

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
const saving = ref(false)
const dialogError = ref('')
const dialogSuccess = ref('')
const form = reactive({
  username: '',
  password: '',
  first_name: '',
  last_name: '',
  email: '',
  institution: '',
  is_admin: false,
})

async function loadUsers() {
  loading.value = true
  try {
    users.value = await apiFetch<User[]>('/users')
  } catch {
    error.value = 'Failed to load users.'
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editTarget.value = null
  showPw.value = false
  dialogError.value = ''
  dialogSuccess.value = ''
  Object.assign(form, { username: '', password: '', first_name: '', last_name: '', email: '', institution: '', is_admin: false })
  showDialog.value = true
}

function openEdit(u: User) {
  editTarget.value = u
  showPw.value = false
  dialogError.value = ''
  dialogSuccess.value = ''
  Object.assign(form, { username: u.username, password: '', first_name: u.first_name ?? '', last_name: u.last_name ?? '', email: u.email ?? '', institution: u.institution ?? '', is_admin: u.is_admin })
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
      await apiFetch(`/users/${editTarget.value.id}`, { method: 'PUT', body })
    } else {
      await apiFetch('/users', { method: 'POST', body: { ...form } })
    }
    await loadUsers()
    dialogSuccess.value = 'User saved.'
    setTimeout(() => { showDialog.value = false; dialogSuccess.value = '' }, 1500)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string; error?: string }; message?: string }
    dialogError.value = fe?.data?.detail || fe?.data?.error || fe?.message || 'Save failed.'
  } finally {
    saving.value = false
  }
}

async function deleteUser(u: User) {
  if (!confirm(`Delete "${u.username}"? This cannot be undone.`)) return
  error.value = ''
  notice.value = ''
  try {
    await apiFetch(`/users/${u.id}`, { method: 'DELETE' })
    await loadUsers()
    notice.value = `"${u.username}" deleted.`
    setTimeout(() => { notice.value = '' }, 4000)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string; error?: string }; message?: string }
    error.value = fe?.data?.detail || fe?.data?.error || fe?.message || 'Delete failed.'
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
  <div class="page">

    <!-- Topbar -->
    <nav class="topbar">
      <div class="breadcrumb">
        <AppLogo :size="20" variant="dark" class="logo-mark" />
        <NuxtLink to="/dashboard" class="bc-link">LTPDA Repository</NuxtLink>
        <span class="bc-sep">/</span>
        <span class="bc-current">Users</span>
      </div>
      <div class="nav-right">
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
        <div class="user-chip">
          <span class="avatar">{{ currentUser?.username?.[0]?.toUpperCase() }}</span>
          <span class="uname">{{ currentUser?.username }}</span>
          <span v-if="currentUser?.is_admin" class="admin-dot" title="Administrator"/>
        </div>
        <button class="btn-ghost" @click="logout">Sign out</button>
      </div>
    </nav>

    <!-- Main -->
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
                    @click="deleteUser(u)"
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
            <h2>{{ editTarget ? 'Edit user' : 'Create user' }}</h2>
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
                {{ editTarget ? 'New password' : 'Password' }}
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
                  <EyeOff v-if="showPw" />
                  <Eye v-else />
                </button>
              </div>
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

  </div>
</template>

<style scoped>
/* ── Nav link ── */
.nav-link {
  display: flex; align-items: center; gap: 0.35rem;
  font-size: 0.8rem; font-weight: 500; color: rgba(255,255,255,0.75);
  text-decoration: none; padding: 0.3rem 0.6rem; border-radius: 6px;
  transition: background 0.15s, color 0.15s;
}
.nav-link:hover { background: rgba(255,255,255,0.12); color: #fff; }
.nav-link.router-link-exact-active { background: rgba(255,255,255,0.18); color: #fff; }

/* ── Main content ── */
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

/* ── Dialog overlay ── */
.overlay {
  position: fixed; inset: 0; background: rgba(30,48,80,0.4);
  backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center;
  z-index: 50; padding: 1.5rem;
}
.dialog {
  background: #ffffff; border: 1px solid #d0dcea;
  border-radius: 14px; width: 100%; max-width: 480px; padding: 2rem;
  box-shadow: 0 8px 32px rgba(30,48,80,0.12);
}
.dialog-top {
  display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.75rem;
}
.dialog-top h2 { font-size: 1rem; font-weight: 700; letter-spacing: -0.02em; color: #1e3050; }
.close-btn {
  width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer;
  color: #a8bdd0; border-radius: 6px; transition: background 0.1s, color 0.1s;
}
.close-btn:hover { background: #f0f5fb; color: #4a6080; }
.close-btn svg { width: 12px; height: 12px; }

/* ── Password row (dialog variant — horizontal, no gen button) ── */
.pw-row {
  display: flex; align-items: stretch;
  background: #ffffff; border: 1px solid #c8d8ec;
  border-radius: 8px; overflow: hidden;
  transition: border-color 0.12s, box-shadow 0.12s;
}
.pw-row:focus-within { border-color: #2f5596; box-shadow: 0 0 0 3px rgba(47,85,150,0.12); }
.eye-btn {
  flex-shrink: 0; width: 38px; display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer; color: #a8bdd0; transition: color 0.12s;
}
.eye-btn:hover { color: #4a6080; }
.eye-btn svg { width: 15px; height: 15px; }

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

/* ── Page notice (success) ── */
.banner-ok {
  padding: 0.65rem 1rem; margin-bottom: 1rem;
  background: #f0fdf4; border: 1px solid #bbf7d0;
  border-radius: 8px; font-size: 0.825rem; color: #15803d;
}

/* ── Dialog banners ── */
.dialog-banner {
  padding: 0.6rem 0.85rem; border-radius: 8px;
  font-size: 0.8rem; line-height: 1.5; margin-bottom: 1rem;
}
.dialog-banner-error { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
.dialog-banner-ok    { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }

/* ── Dialog footer ── */
.dialog-foot { display: flex; justify-content: flex-end; gap: 0.6rem; padding-top: 0.25rem; }


</style>
