<script setup lang="ts">
import { Plus, X, Database, Users, Pencil, Trash2, ChevronDown, ChevronUp } from 'lucide-vue-next'

definePageMeta({ layout: 'default' })

interface Repo {
  id: number
  db_name: string
  name: string
  description: string | null
  version: number
  obj_count: number
}

interface AccessEntry {
  username: string
  can_read: boolean
  can_write: boolean
}

const { apiFetch, user: currentUser } = useAuth()
const router = useRouter()
const { setTitle } = useTopbar()
setTitle('Repositories')

const repos = ref<Repo[]>([])
const loading = ref(false)
const error = ref('')
const notice = ref('')

// ── Create / edit dialog ────────────────────────────────────────────────────
const showDialog = ref(false)
const editTarget = ref<Repo | null>(null)
const saving = ref(false)
const dialogError = ref('')
const dialogSuccess = ref('')
const form = reactive({ db_name: '', name: '', description: '' })
const DB_NAME_RE = /^[a-z0-9_]+$/

// ── Access panel ────────────────────────────────────────────────────────────
const shaking = ref(false)
function onOverlayClick() {
  if (shaking.value) return
  shaking.value = true
  setTimeout(() => { shaking.value = false }, 420)
}

const expandedRepo = ref<string | null>(null)
const accessData = ref<Record<string, AccessEntry[]>>({})
const accessLoading = ref<Record<string, boolean>>({})
const accessError = ref<Record<string, string>>({})
const toggleSaving = ref<Record<string, boolean>>({})

// ── Auth guard ───────────────────────────────────────────────────────────────
onMounted(async () => {
  if (!currentUser.value || !currentUser.value.is_admin) {
    await router.push('/dashboard')
    return
  }
  await loadRepos()
})

async function loadRepos() {
  loading.value = true
  try {
    repos.value = await apiFetch<Repo[]>('/repos')
  } catch {
    error.value = 'Failed to load repositories.'
  } finally {
    loading.value = false
  }
}

// ── Repo CRUD ────────────────────────────────────────────────────────────────
function openCreate() {
  editTarget.value = null
  dialogError.value = ''
  dialogSuccess.value = ''
  Object.assign(form, { db_name: '', name: '', description: '' })
  showDialog.value = true
}

function openEdit(r: Repo) {
  editTarget.value = r
  dialogError.value = ''
  dialogSuccess.value = ''
  Object.assign(form, { db_name: r.db_name, name: r.name, description: r.description ?? '' })
  showDialog.value = true
}

async function saveRepo() {
  dialogError.value = ''
  dialogSuccess.value = ''

  if (!editTarget.value && !DB_NAME_RE.test(form.db_name)) {
    dialogError.value = 'Database name must contain only lowercase letters, digits, and underscores.'
    return
  }

  saving.value = true
  try {
    if (editTarget.value) {
      await apiFetch(`/repos/${editTarget.value.db_name}`, {
        method: 'PUT',
        body: { name: form.name, description: form.description || null },
      })
    } else {
      await apiFetch('/repos', {
        method: 'POST',
        body: { db_name: form.db_name, name: form.name, description: form.description || null },
      })
    }
    await loadRepos()
    dialogSuccess.value = editTarget.value ? 'Repository updated.' : 'Repository created.'
    setTimeout(() => { showDialog.value = false; dialogSuccess.value = '' }, 1500)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    dialogError.value = fe?.data?.detail || fe?.message || 'Save failed.'
  } finally {
    saving.value = false
  }
}

async function deleteRepo(r: Repo) {
  if (!confirm(`Delete repository "${r.name}" (${r.db_name})?\n\nThis will permanently drop the MySQL database and all its data. This cannot be undone.`)) return
  error.value = ''
  notice.value = ''
  try {
    await apiFetch(`/repos/${r.db_name}`, { method: 'DELETE' })
    await loadRepos()
    if (expandedRepo.value === r.db_name) expandedRepo.value = null
    notice.value = `Repository "${r.name}" deleted.`
    setTimeout(() => { notice.value = '' }, 5000)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    error.value = fe?.data?.detail || fe?.message || 'Delete failed.'
  }
}

// ── Access management ────────────────────────────────────────────────────────
async function toggleAccess(db_name: string) {
  if (expandedRepo.value === db_name) {
    expandedRepo.value = null
    return
  }
  expandedRepo.value = db_name
  if (accessData.value[db_name]) return  // already loaded
  await loadAccess(db_name)
}

async function loadAccess(db_name: string) {
  accessLoading.value[db_name] = true
  accessError.value[db_name] = ''
  try {
    accessData.value[db_name] = await apiFetch<AccessEntry[]>(`/repos/${db_name}/access`)
  } catch {
    accessError.value[db_name] = 'Failed to load access list.'
  } finally {
    accessLoading.value[db_name] = false
  }
}

async function setAccess(db_name: string, username: string, can_read: boolean, can_write: boolean) {
  const key = `${db_name}:${username}`
  toggleSaving.value[key] = true
  try {
    await apiFetch(`/repos/${db_name}/access/${username}`, {
      method: 'POST',
      body: { can_read, can_write },
    })
    // Update local state
    const entry = accessData.value[db_name]?.find(e => e.username === username)
    if (entry) { entry.can_read = can_read; entry.can_write = can_write }
  } catch {
    // Reload on failure
    await loadAccess(db_name)
  } finally {
    toggleSaving.value[key] = false
  }
}

function onReadToggle(db_name: string, entry: AccessEntry) {
  const newRead = !entry.can_read
  const newWrite = newRead ? entry.can_write : false
  setAccess(db_name, entry.username, newRead, newWrite)
}

function onWriteToggle(db_name: string, entry: AccessEntry) {
  if (!entry.can_read) return  // write requires read
  setAccess(db_name, entry.username, true, !entry.can_write)
}
</script>

<template>
  <main class="main">

      <div class="page-head">
        <div>
          <h1>Repositories</h1>
          <p class="page-sub">Create and manage repository databases, and control user access.</p>
        </div>
        <button class="btn-primary" @click="openCreate">
          <Plus :size="13" />
          New repository
        </button>
      </div>

      <div v-if="notice" class="banner-ok">{{ notice }}</div>
      <div v-if="error" class="banner-error">
        {{ error }}
        <button @click="error = ''">✕</button>
      </div>

      <div class="table-wrap">

        <div v-if="loading" class="table-loading">
          <div class="spin" />
        </div>

        <template v-else-if="repos.length">
          <table class="table">
            <thead>
              <tr>
                <th>Repository</th>
                <th>Database</th>
                <th>Objects</th>
                <th>Description</th>
                <th />
              </tr>
            </thead>
            <tbody>
              <template v-for="repo in repos" :key="repo.db_name">
                <tr :class="{ 'row-expanded': expandedRepo === repo.db_name }">
                  <td>
                    <div class="repo-cell">
                      <Database :size="14" class="repo-icon" />
                      <span class="repo-name">{{ repo.name }}</span>
                    </div>
                  </td>
                  <td><code class="db-tag">{{ repo.db_name }}</code></td>
                  <td class="count-cell">{{ repo.obj_count.toLocaleString() }}</td>
                  <td class="desc-cell">{{ repo.description || '—' }}</td>
                  <td class="row-actions">
                    <button class="act-btn" @click="openEdit(repo)">
                      <Pencil :size="12" />
                      Edit
                    </button>
                    <button
                      class="act-btn"
                      :class="{ 'act-active': expandedRepo === repo.db_name }"
                      @click="toggleAccess(repo.db_name)"
                    >
                      <Users :size="12" />
                      Access
                      <ChevronUp v-if="expandedRepo === repo.db_name" :size="11" />
                      <ChevronDown v-else :size="11" />
                    </button>
                    <button class="act-btn act-danger" @click="deleteRepo(repo)">
                      <Trash2 :size="12" />
                      Delete
                    </button>
                  </td>
                </tr>

                <!-- Access sub-panel -->
                <tr v-if="expandedRepo === repo.db_name" class="access-row">
                  <td colspan="5" class="access-cell">
                    <div class="access-panel">
                      <div class="access-panel-head">
                        <span>User access — <strong>{{ repo.db_name }}</strong></span>
                        <span class="access-hint">Read = SELECT on all tables + INSERT on transactions. Write = INSERT on all tables (submit new objects).</span>
                      </div>

                      <div v-if="accessLoading[repo.db_name]" class="access-loading">
                        <div class="spin spin-sm" />
                      </div>
                      <div v-else-if="accessError[repo.db_name]" class="access-error">
                        {{ accessError[repo.db_name] }}
                      </div>
                      <template v-else>
                        <table class="access-table">
                          <thead>
                            <tr>
                              <th>Username</th>
                              <th class="toggle-th">Read</th>
                              <th class="toggle-th">Write</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr v-for="entry in accessData[repo.db_name]" :key="entry.username">
                              <td class="access-user">{{ entry.username }}</td>
                              <td class="toggle-td">
                                <button
                                  class="mini-toggle"
                                  :class="{ active: entry.can_read }"
                                  :disabled="!!toggleSaving[`${repo.db_name}:${entry.username}`]"
                                  @click="onReadToggle(repo.db_name, entry)"
                                >
                                  <div class="mini-thumb" />
                                </button>
                              </td>
                              <td class="toggle-td">
                                <button
                                  class="mini-toggle"
                                  :class="{ active: entry.can_write, disabled: !entry.can_read }"
                                  :disabled="!entry.can_read || !!toggleSaving[`${repo.db_name}:${entry.username}`]"
                                  @click="onWriteToggle(repo.db_name, entry)"
                                >
                                  <div class="mini-thumb" />
                                </button>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </template>
                    </div>
                  </td>
                </tr>
              </template>
            </tbody>
          </table>
        </template>

        <div v-else class="empty-state">
          <Database :size="48" />
          <p>No repositories yet. Create one to get started.</p>
        </div>

      </div>
  </main>

  <!-- Create / Edit dialog -->
  <Teleport to="body">
      <Transition name="modal">
        <div v-if="showDialog" class="overlay" @click.self="onOverlayClick">
          <div class="dialog" :class="{ 'dialog-shake': shaking }">

          <div class="dialog-top">
            <h2>{{ editTarget ? 'Edit repository' : 'Create repository' }}</h2>
            <button class="close-btn" @click="showDialog = false" aria-label="Close">
              <X :size="14" />
            </button>
          </div>

          <form @submit.prevent="saveRepo">

            <div class="field">
              <label>Display name <span class="req">*</span></label>
              <input v-model="form.name" required placeholder="e.g. My Repository" />
            </div>

            <div class="field">
              <label>
                Database name
                <span v-if="!editTarget" class="req">*</span>
              </label>
              <input
                v-model="form.db_name"
                :disabled="!!editTarget"
                :required="!editTarget"
                placeholder="e.g. myrepo (lowercase, digits, underscores)"
                autocomplete="off"
              />
              <p v-if="!editTarget" class="field-hint">
                The MySQL database name. Cannot be changed after creation.
                Allowed characters: <code>a–z 0–9 _</code>
              </p>
            </div>

            <div class="field">
              <label>Description</label>
              <textarea v-model="form.description" rows="3" placeholder="Optional description" />
            </div>

            <div v-if="dialogError" class="dialog-banner dialog-banner-error">{{ dialogError }}</div>
            <div v-if="dialogSuccess" class="dialog-banner dialog-banner-ok">{{ dialogSuccess }}</div>

            <div class="dialog-foot">
              <button type="button" class="btn-cancel" @click="showDialog = false">Cancel</button>
              <button type="submit" class="btn-primary" :disabled="saving">
                <span v-if="saving" class="spin spin-sm" />
                {{ editTarget ? 'Save changes' : 'Create repository' }}
              </button>
            </div>

          </form>
          </div>
        </div>
      </Transition>
  </Teleport>
</template>

<style scoped>
.main { flex: 1; padding: 2.5rem 2rem; max-width: 1100px; margin: 0 auto; width: 100%; }
.page-head {
  display: flex; align-items: flex-start; justify-content: space-between;
  gap: 1rem; margin-bottom: 1.75rem;
}
h1 { font-size: 1.2rem; font-weight: 700; letter-spacing: -0.025em; color: #1e3050; }
.page-sub { font-size: 0.825rem; color: #6a84a0; margin-top: 0.25rem; }

.table-wrap { background: #fff; border: 1px solid #d0dcea; border-radius: 12px; overflow: hidden; }
.table-loading { display: flex; justify-content: center; align-items: center; padding: 4rem; }
.table { width: 100%; border-collapse: collapse; font-size: 0.825rem; }
.table thead th {
  padding: 0.75rem 1.25rem; text-align: left;
  font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.09em;
  color: #8aa0b8; background: #f4f7fb; border-bottom: 1px solid #d0dcea;
}
.table tbody tr { transition: background 0.1s; }
.table tbody tr:hover:not(.access-row) { background: #f8fafd; }
.table tbody td { padding: 1rem 1.25rem; border-bottom: 1px solid #e8eef6; color: #4a6080; vertical-align: middle; }
.table tbody tr:last-child td,
.table tbody tr.access-row td { border-bottom: 1px solid #e8eef6; }
.table tbody tr.row-expanded td { border-bottom: none; background: #f8fafd; }

.repo-cell { display: flex; align-items: center; gap: 0.5rem; }
.repo-icon { color: #6a84a0; flex-shrink: 0; }
.repo-name { font-weight: 600; color: #1e3050; }
.db-tag {
  font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.75rem;
  color: #6a84a0; background: #eef2f7; padding: 0.15em 0.4em; border-radius: 4px;
}
.count-cell { text-align: right; font-variant-numeric: tabular-nums; color: #6a84a0; }
.desc-cell { max-width: 240px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.row-actions { display: flex; gap: 0.35rem; align-items: center; white-space: nowrap; }
.act-btn {
  display: flex; align-items: center; gap: 0.3rem;
  font-size: 0.75rem; font-weight: 500; color: #6a84a0;
  background: none; border: 1px solid #d0dcea;
  border-radius: 6px; padding: 0.3rem 0.6rem; cursor: pointer;
  transition: background 0.1s, color 0.1s, border-color 0.1s;
}
.act-btn:hover { background: #f0f5fb; color: #2f5596; border-color: #b8cce0; }
.act-btn.act-active { background: #eff6ff; color: #1d4ed8; border-color: #bfdbfe; }
.act-danger:hover { background: #fef2f2; color: #b91c1c; border-color: #fecaca; }

.empty-state {
  display: flex; flex-direction: column; align-items: center;
  gap: 0.75rem; padding: 4rem; color: #b8cce0; font-size: 0.825rem;
}

/* ── Access sub-panel ── */
.access-row td { padding: 0; border-bottom: 1px solid #d0dcea !important; }
.access-cell { background: #f4f7fb; }
.access-panel { padding: 1rem 1.5rem 1.25rem; }
.access-panel-head {
  display: flex; align-items: baseline; gap: 1.5rem;
  font-size: 0.8rem; color: #4a6080; margin-bottom: 0.9rem;
}
.access-panel-head strong { color: #1e3050; }
.access-hint { font-size: 0.73rem; color: #8aa0b8; }
.access-loading { display: flex; align-items: center; gap: 0.5rem; font-size: 0.8rem; color: #6a84a0; padding: 0.5rem 0; }
.access-error { font-size: 0.8rem; color: #b91c1c; padding: 0.4rem 0; }

.access-table { width: 100%; border-collapse: collapse; background: #fff; border: 1px solid #d0dcea; border-radius: 8px; overflow: hidden; font-size: 0.8rem; }
.access-table thead th {
  padding: 0.5rem 0.9rem; text-align: left;
  font-size: 0.65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em;
  color: #8aa0b8; background: #f4f7fb; border-bottom: 1px solid #d0dcea;
}
.toggle-th { text-align: center; width: 72px; }
.access-table tbody tr { border-bottom: 1px solid #e8eef6; }
.access-table tbody tr:last-child { border-bottom: none; }
.access-table tbody td { padding: 0.55rem 0.9rem; color: #4a6080; vertical-align: middle; }
.access-user { font-weight: 500; color: #1e3050; font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.78rem; }
.toggle-td { text-align: center; }

.mini-toggle {
  display: inline-flex; align-items: center;
  width: 32px; height: 18px; background: #c8d8ec;
  border: none; border-radius: 999px; padding: 0 3px; cursor: pointer;
  transition: background 0.18s; position: relative;
}
.mini-toggle.active { background: #22c55e; }
.mini-toggle.disabled { opacity: 0.35; cursor: not-allowed; }
.mini-toggle:disabled:not(.disabled) { opacity: 0.6; }
.mini-thumb {
  width: 12px; height: 12px; background: #fff; border-radius: 50%;
  box-shadow: 0 1px 2px rgba(0,0,0,0.15); transition: transform 0.18s;
  position: absolute; left: 3px;
}
.mini-toggle.active .mini-thumb { transform: translateX(14px); }

/* ── Notice / error banners ── */
.banner-ok {
  padding: 0.65rem 1rem; margin-bottom: 1rem;
  background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px;
  font-size: 0.825rem; color: #15803d;
}

/* ── Dialog ── */
.overlay {
  position: fixed; inset: 0; background: rgba(30,48,80,0.4);
  backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center; z-index: 50; padding: 1.5rem;
}
.dialog {
  background: #fff; border: 1px solid #d0dcea; border-radius: 14px;
  width: 100%; max-width: 480px; padding: 2rem;
  box-shadow: 0 8px 32px rgba(30,48,80,0.12);
}
.dialog-top {
  display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.75rem;
}
.dialog-top h2 { font-size: 1rem; font-weight: 700; letter-spacing: -0.02em; color: #1e3050; }
.close-btn {
  width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;
  background: none; border: none; cursor: pointer; color: #a8bdd0; border-radius: 6px;
  transition: background 0.1s, color 0.1s;
}
.close-btn:hover { background: #f0f5fb; color: #4a6080; }
.close-btn svg { width: 12px; height: 12px; }

textarea { resize: vertical; min-height: 68px; }
.field-hint { font-size: 0.75rem; color: #8aa0b8; margin-top: 0.3rem; line-height: 1.5; }
.field-hint code { font-family: 'JetBrains Mono', ui-monospace, monospace; background: #eef2f7; padding: 0.1em 0.3em; border-radius: 3px; font-size: 0.9em; }

.dialog-banner { padding: 0.6rem 0.85rem; border-radius: 8px; font-size: 0.8rem; margin-bottom: 1rem; }
.dialog-banner-error { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
.dialog-banner-ok    { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
.dialog-foot { display: flex; justify-content: flex-end; gap: 0.6rem; padding-top: 0.25rem; }
</style>
