<script setup lang="ts">
interface User {
  id: number
  username: string
  given_name: string | null
  family_name: string | null
  email: string | null
  institution: string | null
  is_admin: boolean
  created_at: string
}

const { apiFetch, user: currentUser, logout } = useAuth()

const users = ref<User[]>([])
const loading = ref(false)
const error = ref('')

const showDialog = ref(false)
const editTarget = ref<User | null>(null)
const form = reactive({
  username: '',
  password: '',
  given_name: '',
  family_name: '',
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
  Object.assign(form, { username: '', password: '', given_name: '', family_name: '', email: '', institution: '', is_admin: false })
  showDialog.value = true
}

function openEdit(u: User) {
  editTarget.value = u
  Object.assign(form, { username: u.username, password: '', given_name: u.given_name ?? '', family_name: u.family_name ?? '', email: u.email ?? '', institution: u.institution ?? '', is_admin: u.is_admin })
  showDialog.value = true
}

async function saveUser() {
  try {
    if (editTarget.value) {
      const body: Record<string, unknown> = { given_name: form.given_name, family_name: form.family_name, email: form.email, institution: form.institution, is_admin: form.is_admin }
      if (form.password) body.password = form.password
      await apiFetch(`/users/${editTarget.value.id}`, { method: 'PUT', body })
    } else {
      await apiFetch('/users', { method: 'POST', body: { ...form } })
    }
    showDialog.value = false
    await loadUsers()
  } catch (e: unknown) {
    const err = e as { data?: { detail?: string } }
    error.value = err?.data?.detail ?? 'Save failed.'
  }
}

async function deleteUser(u: User) {
  if (!confirm(`Delete user "${u.username}"?`)) return
  try {
    await apiFetch(`/users/${u.id}`, { method: 'DELETE' })
    await loadUsers()
  } catch {
    error.value = 'Delete failed.'
  }
}

onMounted(loadUsers)
</script>

<template>
  <div class="page">
    <header class="topbar">
      <div class="breadcrumb">
        <NuxtLink to="/dashboard" class="nav-link">Dashboard</NuxtLink>
        <span class="sep">›</span>
        <span>Users</span>
      </div>
      <div class="user-area">
        <span class="username">{{ currentUser?.username }}</span>
        <button class="btn-logout" @click="logout">Sign out</button>
      </div>
    </header>

    <main class="content">
      <div class="panel">
        <div class="panel-header">
          <h2>Users</h2>
          <button class="btn-primary" @click="openCreate">+ New user</button>
        </div>

        <div v-if="error" class="error-msg">{{ error }}</div>

        <table v-if="users.length" class="user-table">
          <thead>
            <tr>
              <th>Username</th>
              <th>Name</th>
              <th>Email</th>
              <th>Institution</th>
              <th>Admin</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in users" :key="u.id">
              <td>{{ u.username }}</td>
              <td>{{ [u.given_name, u.family_name].filter(Boolean).join(' ') || '—' }}</td>
              <td>{{ u.email || '—' }}</td>
              <td>{{ u.institution || '—' }}</td>
              <td>{{ u.is_admin ? 'Yes' : 'No' }}</td>
              <td class="actions">
                <button class="btn-sm" @click="openEdit(u)">Edit</button>
                <button class="btn-sm btn-danger" :disabled="u.id === currentUser?.id" @click="deleteUser(u)">Delete</button>
              </td>
            </tr>
          </tbody>
        </table>
        <p v-else-if="!loading" class="empty">No users found.</p>
      </div>
    </main>

    <!-- Create / Edit dialog -->
    <div v-if="showDialog" class="dialog-overlay" @click.self="showDialog = false">
      <div class="dialog">
        <h3>{{ editTarget ? 'Edit user' : 'New user' }}</h3>
        <form @submit.prevent="saveUser">
          <div v-if="!editTarget" class="field">
            <label>Username *</label>
            <input v-model="form.username" required />
          </div>
          <div class="field-row">
            <div class="field grow">
              <label>Given name</label>
              <input v-model="form.given_name" />
            </div>
            <div class="field grow">
              <label>Family name</label>
              <input v-model="form.family_name" />
            </div>
          </div>
          <div class="field">
            <label>Email</label>
            <input v-model="form.email" type="email" />
          </div>
          <div class="field">
            <label>Institution</label>
            <input v-model="form.institution" />
          </div>
          <div class="field">
            <label>{{ editTarget ? 'New password (leave blank to keep current)' : 'Password *' }}</label>
            <input v-model="form.password" type="password" :required="!editTarget" />
          </div>
          <div class="field check">
            <input id="is_admin" v-model="form.is_admin" type="checkbox" />
            <label for="is_admin">Administrator</label>
          </div>
          <div class="dialog-actions">
            <button type="button" class="btn-secondary" @click="showDialog = false">Cancel</button>
            <button type="submit" class="btn-primary">Save</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page { min-height: 100vh; display: flex; flex-direction: column; background: #f8fafc; }
.topbar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 1.5rem; height: 56px; background: white; border-bottom: 1px solid #e5e7eb;
}
.breadcrumb { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; }
.sep { color: #9ca3af; }
.nav-link { color: #2563eb; text-decoration: none; }
.nav-link:hover { text-decoration: underline; }
.user-area { display: flex; align-items: center; gap: 1rem; font-size: 0.875rem; }
.username { color: #374151; }
.btn-logout { padding: 0.35rem 0.75rem; border: 1px solid #d1d5db; border-radius: 4px; background: white; cursor: pointer; font-size: 0.875rem; }
.content { flex: 1; padding: 2rem; }
.panel { background: white; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); overflow: hidden; }
.panel-header { display: flex; align-items: center; justify-content: space-between; padding: 1rem 1.5rem; border-bottom: 1px solid #e5e7eb; }
h2 { margin: 0; font-size: 1rem; }
.error-msg { color: #dc2626; font-size: 0.85rem; padding: 0.5rem 1.5rem; }
.empty { color: #9ca3af; text-align: center; padding: 2rem; font-size: 0.9rem; }
.user-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
.user-table th { text-align: left; padding: 0.65rem 1.5rem; background: #f9fafb; color: #6b7280; font-weight: 500; border-bottom: 1px solid #e5e7eb; }
.user-table td { padding: 0.65rem 1.5rem; border-bottom: 1px solid #f3f4f6; }
.user-table tr:last-child td { border-bottom: none; }
.actions { display: flex; gap: 0.5rem; }
.btn-primary { padding: 0.45rem 1rem; background: #2563eb; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.875rem; }
.btn-primary:hover { background: #1d4ed8; }
.btn-secondary { padding: 0.45rem 1rem; background: white; color: #374151; border: 1px solid #d1d5db; border-radius: 4px; cursor: pointer; font-size: 0.875rem; }
.btn-sm { padding: 0.25rem 0.6rem; border: 1px solid #d1d5db; border-radius: 4px; background: white; cursor: pointer; font-size: 0.8rem; }
.btn-danger { border-color: #fca5a5; color: #dc2626; }
.btn-danger:hover:not(:disabled) { background: #fef2f2; }
.btn-sm:disabled { opacity: 0.4; cursor: not-allowed; }
.dialog-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; z-index: 50; }
.dialog { background: white; border-radius: 8px; padding: 1.75rem; width: 100%; max-width: 460px; box-shadow: 0 4px 24px rgba(0,0,0,0.15); }
h3 { margin: 0 0 1.25rem; font-size: 1rem; }
.field { display: flex; flex-direction: column; gap: 0.25rem; margin-bottom: 0.75rem; }
.field-row { display: flex; gap: 1rem; }
.grow { flex: 1; }
.check { flex-direction: row; align-items: center; gap: 0.5rem; }
label { font-size: 0.85rem; font-weight: 500; color: #444; }
input[type="text"], input[type="email"], input[type="password"] {
  padding: 0.45rem 0.6rem; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.875rem; width: 100%; box-sizing: border-box;
}
input:focus { outline: none; border-color: #2563eb; }
.dialog-actions { display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 1.25rem; }
</style>
