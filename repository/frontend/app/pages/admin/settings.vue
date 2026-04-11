<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { apiFetch, user: currentUser } = useAuth()
const router = useRouter()
const { setTitle } = useTopbar()
onMounted(() => setTitle('Settings'))

// ── Auth guard ────────────────────────────────────────────────────────────────
onMounted(async () => {
  if (!currentUser.value) {
    await router.push('/login')
    return
  }
  if (!currentUser.value.is_admin) {
    await router.push('/dashboard')
    return
  }
  await loadSettings()
})

// ── Settings data ─────────────────────────────────────────────────────────────
interface Settings {
  mysql_mode: string
  mysql_host: string
  mysql_port: number
  admin_db: string
  mysql_admin_user: string
  public_url: string
}

const cfg = ref<Settings | null>(null)
const loading = ref(true)
const pageError = ref('')
const pmaOpening = ref(false)
const urlEditing = ref(false)
const urlValue = ref('')
const urlSaving = ref(false)
const urlSuccess = ref('')

interface SshHealth {
  enabled: boolean
  ok?: boolean
  version?: string
  error?: string
}
const sshHealth = ref<SshHealth | null>(null)
const sshHealthLoading = ref(false)
const sshLogs = ref<string[]>([])
const sshLogsNote = ref('')
const sshLogsLoading = ref(false)

async function checkSshHealth() {
  sshHealthLoading.value = true
  sshLogs.value = []
  sshLogsNote.value = ''
  try {
    sshHealth.value = await apiFetch<SshHealth>('/settings/ssh-sync/health')
  } catch {
    sshHealth.value = { enabled: true, ok: false, error: 'Could not reach backend' }
  } finally {
    sshHealthLoading.value = false
  }
  // If daemon is unreachable, automatically fetch logs for diagnostics
  if (sshHealth.value && !sshHealth.value.ok) {
    await loadSshLogs()
  }
}

async function loadSshLogs() {
  sshLogsLoading.value = true
  try {
    const res = await apiFetch<{ lines: string[]; note?: string }>('/settings/ssh-sync/logs')
    sshLogs.value = res.lines ?? []
    sshLogsNote.value = res.note ?? ''
  } catch {
    sshLogs.value = []
    sshLogsNote.value = 'Could not fetch log file.'
  } finally {
    sshLogsLoading.value = false
  }
}

async function openPhpMyAdmin() {
  pmaOpening.value = true
  pageError.value = ''
  try {
    await apiFetch('/auth/pma-token', { method: 'POST' })
    window.open('/pma/', '_blank', 'noopener')
  } catch (e: unknown) {
    const fe = e as { status?: number; statusCode?: number; data?: { detail?: string }; message?: string }
    const status = fe.status ?? fe.statusCode
    pageError.value = !status
      ? 'Cannot reach the server.'
      : (fe.data?.detail || `Error ${status} — could not open phpMyAdmin.`)
  } finally {
    pmaOpening.value = false
  }
}

function startEditUrl() {
  urlValue.value = cfg.value?.public_url ?? ''
  urlEditing.value = true
  urlSuccess.value = ''
}

async function saveUrl() {
  urlSaving.value = true
  pageError.value = ''
  urlSuccess.value = ''
  try {
    await apiFetch('/settings/public-url', { method: 'PUT', body: { public_url: urlValue.value } })
    cfg.value!.public_url = urlValue.value.replace(/\/$/, '')
    urlEditing.value = false
    urlSuccess.value = 'URL saved. Restart the API container for phpMyAdmin to pick it up if it was previously unconfigured.'
    setTimeout(() => { urlSuccess.value = '' }, 6000)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    pageError.value = fe?.data?.detail || fe?.message || 'Failed to save URL.'
  } finally {
    urlSaving.value = false
  }
}

async function loadSettings() {
  loading.value = true
  try {
    cfg.value = await apiFetch<Settings>('/settings')
    if (cfg.value?.mysql_mode === 'bundled') checkSshHealth()
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    pageError.value = fe?.data?.detail || fe?.message || 'Failed to load settings.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <main class="main">

      <div class="page-head">
        <div>
          <h1>Settings</h1>
          <p class="page-sub">Server configuration overview.</p>
        </div>
      </div>

      <div v-if="pageError" class="banner-error">
        {{ pageError }}
        <button @click="pageError = ''">✕</button>
      </div>
      <div v-if="urlSuccess" class="banner-ok">{{ urlSuccess }}</div>

      <div v-if="loading" class="loading-wrap">
        <div class="spin" />
      </div>

      <template v-else-if="cfg">

        <!-- ── MySQL Connection ───────────────────────────────────────────── -->
        <section class="card">
          <div class="card-head">
            <h2>MySQL connection</h2>
            <span class="badge-mode" :class="cfg.mysql_mode === 'bundled' ? 'badge-bundled' : 'badge-external'">
              {{ cfg.mysql_mode === 'bundled' ? 'Bundled' : 'External' }}
            </span>
          </div>
          <div class="info-grid">
            <div class="info-row">
              <span class="info-label">Host</span>
              <span class="info-val"><code>{{ cfg.mysql_host }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Port</span>
              <span class="info-val"><code>{{ cfg.mysql_port }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Admin database</span>
              <span class="info-val"><code>{{ cfg.admin_db }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Admin user</span>
              <span class="info-val"><code>{{ cfg.mysql_admin_user }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Admin password</span>
              <span class="info-val info-masked">••••••••</span>
            </div>
          </div>
          <p class="card-note">
            MySQL credentials are stored in <code>config/config.json</code> on the server.
            To change them, re-run the setup wizard (delete <code>config/config.json</code> and restart).
          </p>

        <!-- ── Public URL ── -->
        <div class="url-row">
          <div class="url-label-block">
            <span class="info-label">Server public URL</span>
            <span v-if="cfg.public_url" class="info-val"><code>{{ cfg.public_url }}</code></span>
            <span v-else class="url-unset">Not set — phpMyAdmin AJAX will not work</span>
          </div>
          <div v-if="!urlEditing" class="url-actions">
            <button class="act-btn" @click="startEditUrl">{{ cfg.public_url ? 'Edit' : 'Set URL' }}</button>
          </div>
          <form v-else class="url-edit-form" @submit.prevent="saveUrl">
            <input v-model="urlValue" type="url" placeholder="https://repo.yourdomain.com" class="url-input" required />
            <button type="submit" class="act-btn act-save" :disabled="urlSaving">Save</button>
            <button type="button" class="act-btn" @click="urlEditing = false">Cancel</button>
          </form>
        </div>
        </section>

        <!-- ── SSH tunnel ─────────────────────────────────────────────────── -->
        <section v-if="cfg.mysql_mode === 'bundled'" class="card">
          <div class="card-head">
            <h2>MATLAB SSH tunnel</h2>
            <!-- Live sync daemon health indicator -->
            <span v-if="sshHealthLoading" class="ssh-status ssh-checking">
              <span class="spin spin-xs" /> Checking…
            </span>
            <span v-else-if="sshHealth?.ok" class="ssh-status ssh-ok">
              ● Sync daemon responding<span v-if="sshHealth.version"> (v{{ sshHealth.version }})</span>
            </span>
            <span v-else-if="sshHealth && !sshHealth.ok" class="ssh-status ssh-err" :title="sshHealth.error">
              ● Sync daemon unreachable
            </span>
            <button class="recheck-btn" :disabled="sshHealthLoading" @click="checkSshHealth" title="Re-check">↺</button>
          </div>
          <p v-if="sshHealth && !sshHealth.ok && sshHealth.error" class="ssh-err-detail">
            {{ sshHealth.error }}
          </p>

          <!-- Daemon log (shown when unreachable) -->
          <div v-if="sshHealth && !sshHealth.ok" class="ssh-log-wrap">
            <div class="ssh-log-head">
              <span>Daemon log</span>
              <span v-if="sshLogsLoading" class="ssh-log-loading"><span class="spin spin-xs" /> fetching…</span>
              <button v-else class="recheck-btn" title="Refresh log" @click="loadSshLogs">↺</button>
            </div>
            <pre v-if="sshLogs.length" class="ssh-log-body">{{ sshLogs.join('\n') }}</pre>
            <p v-else-if="sshLogsNote" class="ssh-log-note">{{ sshLogsNote }}</p>
            <p v-else-if="!sshLogsLoading" class="ssh-log-note">No log lines yet.</p>
          </div>

          <p class="card-desc">
            An SSH gateway container runs on port 2222. User accounts are synced automatically
            from the web UI — SSH uses each user's <strong>web UI login password</strong>.
          </p>
          <div class="tunnel-cmd">
            <code>ssh -N -L 3306:db:3306 -p 2222 username@repo.yourdomain.com</code>
          </div>
          <p class="card-note">
            In LTPDAprefs, set <strong>hostname = localhost</strong>, <strong>port = 3306</strong>,
            and use the user's <strong>MySQL/MATLAB password</strong> for JDBC. Port 2222 must be
            open in the server firewall (<code>sudo ufw allow 2222/tcp</code>).
          </p>
        </section>

        <!-- ── Database manager ──────────────────────────────────────────── -->
        <section v-if="cfg.mysql_mode === 'bundled'" class="card">
          <div class="card-head">
            <h2>Database manager</h2>
            <span class="badge-mode badge-bundled">phpMyAdmin</span>
          </div>
          <p class="card-desc">
            Browse tables, run queries, and inspect or repair data directly in MySQL.
            Opens in a new tab and logs in automatically using the MySQL root account.
          </p>
          <button class="pma-btn" :disabled="pmaOpening" @click="openPhpMyAdmin">
            {{ pmaOpening ? 'Opening…' : 'Open phpMyAdmin' }}
          </button>
          <p class="card-note">
            Access is gated behind your admin session — the button issues a short-lived cookie
            that nginx validates on every request; logging out invalidates it immediately.
          </p>
        </section>

      </template>

  </main>
</template>

<style scoped>
/* ── Main ── */
.main { flex: 1; padding: 2.5rem 2rem; max-width: 760px; margin: 0 auto; width: 100%; }
.page-head { margin-bottom: 1.75rem; }
h1 { font-size: 1.2rem; font-weight: 700; letter-spacing: -0.025em; color: #1e3050; }
.page-sub { font-size: 0.825rem; color: #6a84a0; margin-top: 0.25rem; }

.loading-wrap { display: flex; justify-content: center; padding: 4rem; }

/* ── Cards ── */
.card {
  background: #fff; border: 1px solid #d0dcea; border-radius: 12px;
  padding: 1.75rem; margin-bottom: 1.5rem;
}
.card-head {
  display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;
}
h2 { font-size: 0.9rem; font-weight: 700; letter-spacing: -0.02em; color: #1e3050; }
.card-desc { font-size: 0.825rem; color: #4a6080; line-height: 1.6; margin-bottom: 1.25rem; }
.card-note {
  font-size: 0.775rem; color: #8aa0b8; line-height: 1.6;
  margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #e8eef6;
}
.card-note code { font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.9em; background: #eef2f7; padding: 0.1em 0.3em; border-radius: 3px; }

/* ── Mode badges ── */
.badge-mode {
  font-size: 0.68rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase;
  padding: 0.2rem 0.55rem; border-radius: 999px;
}
.badge-bundled { background: #e8f5e9; color: #2e7d32; }
.badge-external { background: #e3f2fd; color: #1565c0; }

/* ── Info grid (MySQL section) ── */
.info-grid { display: flex; flex-direction: column; gap: 0; }
.info-row {
  display: flex; align-items: baseline; gap: 1rem;
  padding: 0.6rem 0; border-bottom: 1px solid #f0f4fa; font-size: 0.825rem;
}
.info-row:last-child { border-bottom: none; }
.info-label { width: 140px; flex-shrink: 0; font-weight: 600; color: #4a6080; }
.info-val { color: #1e3050; }
.info-val code { font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.9em; background: #eef2f7; padding: 0.15em 0.4em; border-radius: 4px; }
.info-masked { color: #a8bdd0; letter-spacing: 0.15em; }

/* ── Public URL row ── */
.url-row {
  display: flex; align-items: center; flex-wrap: wrap; gap: 0.75rem;
  padding-top: 1rem; margin-top: 1rem; border-top: 1px solid #e8eef6;
}
.url-label-block { display: flex; align-items: baseline; gap: 1rem; flex: 1; min-width: 0; font-size: 0.825rem; }
.url-unset { font-size: 0.8rem; color: #d97706; font-style: italic; }
.url-actions { display: flex; gap: 0.4rem; }
.url-edit-form { display: flex; align-items: center; gap: 0.5rem; flex: 1; flex-wrap: wrap; }
.url-input {
  flex: 1; min-width: 220px; padding: 0.4rem 0.65rem;
  border: 1px solid #c8d8ec; border-radius: 7px; font-size: 0.825rem; color: #1e3050; outline: none;
  transition: border-color 0.12s, box-shadow 0.12s;
}
.url-input:focus { border-color: #2f5596; box-shadow: 0 0 0 3px rgba(47,85,150,0.12); }
.act-btn {
  font-size: 0.775rem; font-weight: 500; color: #6a84a0;
  background: none; border: 1px solid #d0dcea;
  border-radius: 6px; padding: 0.3rem 0.65rem; cursor: pointer; white-space: nowrap;
  transition: background 0.1s, color 0.1s, border-color 0.1s;
}
.act-btn:hover:not(:disabled) { background: #f0f5fb; color: #2f5596; border-color: #b8cce0; }
.act-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.act-save:hover:not(:disabled) { background: #e8f0f8; color: #1e3050; border-color: #a8c0d8; }

/* ── Database manager button ── */
.pma-btn {
  display: inline-flex; align-items: center;
  padding: 0.5rem 1.1rem; background: #1e3050; color: #fff;
  border-radius: 8px; font-size: 0.825rem; font-weight: 600;
  text-decoration: none; transition: background 0.15s;
}
.pma-btn:hover { background: #2f5596; }

/* ── SSH sync health indicator ── */
.ssh-status {
  font-size: 0.72rem; font-weight: 600; letter-spacing: 0.02em;
  display: flex; align-items: center; gap: 0.35rem;
  padding: 0.2rem 0.6rem; border-radius: 999px;
}
.ssh-checking { background: #f0f5fb; color: #6a84a0; }
.ssh-ok  { background: #e8f5e9; color: #2e7d32; }
.ssh-err { background: #fef2f2; color: #b91c1c; cursor: help; }
.ssh-err-detail {
  font-size: 0.775rem; color: #b91c1c; background: #fef2f2;
  border: 1px solid #fecaca; border-radius: 7px;
  padding: 0.5rem 0.75rem; margin-bottom: 1rem;
  word-break: break-word;
}
.recheck-btn {
  margin-left: auto; font-size: 0.9rem; line-height: 1;
  background: none; border: none; cursor: pointer; color: #8aa0b8;
  padding: 0.1rem 0.3rem; border-radius: 4px; transition: color 0.12s;
}
.recheck-btn:hover:not(:disabled) { color: #2f5596; }
.recheck-btn:disabled { opacity: 0.4; cursor: not-allowed; }
.spin-xs { width: 10px; height: 10px; border-width: 1.5px; }

/* ── Daemon log block ── */
.ssh-log-wrap {
  margin-bottom: 1.25rem; border: 1px solid #e8eef6; border-radius: 8px; overflow: hidden;
}
.ssh-log-head {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0.4rem 0.75rem; background: #f5f8fc;
  border-bottom: 1px solid #e8eef6; font-size: 0.72rem; font-weight: 600;
  color: #4a6080; letter-spacing: 0.03em; text-transform: uppercase;
}
.ssh-log-loading { display: flex; align-items: center; gap: 0.3rem; font-weight: 400; color: #8aa0b8; }
.ssh-log-body {
  margin: 0; padding: 0.6rem 0.75rem; background: #1e3050;
  color: #c8e0f8; font-family: 'JetBrains Mono', ui-monospace, monospace;
  font-size: 0.72rem; line-height: 1.55; white-space: pre-wrap; word-break: break-all;
  max-height: 260px; overflow-y: auto;
}
.ssh-log-note {
  margin: 0; padding: 0.5rem 0.75rem; font-size: 0.775rem; color: #8aa0b8; font-style: italic;
}

/* ── Tunnel command ── */
.tunnel-cmd {
  background: #1e3050; border-radius: 8px; padding: 0.85rem 1rem; margin-bottom: 0.5rem;
}
.tunnel-cmd code {
  font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.8rem;
  color: #c8e0f8; white-space: pre-wrap; word-break: break-all;
}
</style>
