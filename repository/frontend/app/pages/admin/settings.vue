<script setup lang="ts">
import { Users, Eye, EyeOff, Wifi, WifiOff } from 'lucide-vue-next'

const { apiFetch, user: currentUser, logout } = useAuth()
const router = useRouter()

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
  ssh_sync_enabled: boolean
  ssh_sync_port: number
  ssh_sync_secret_set: boolean
}

const cfg = ref<Settings | null>(null)
const loading = ref(true)
const pageError = ref('')

async function loadSettings() {
  loading.value = true
  try {
    cfg.value = await apiFetch<Settings>('/settings')
    // Initialise form from loaded values
    form.enabled = cfg.value.ssh_sync_enabled
    form.port = cfg.value.ssh_sync_port
    form.secret = ''
    form.secretDirty = false
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    pageError.value = fe?.data?.detail || fe?.message || 'Failed to load settings.'
  } finally {
    loading.value = false
  }
}

// ── SSH sync form ─────────────────────────────────────────────────────────────
const form = reactive({
  enabled: false,
  port: 9922,
  secret: '',
  secretDirty: false,
})
const showSecret = ref(false)
const saving = ref(false)
const saveError = ref('')
const saveOk = ref(false)

const dirty = computed(() => {
  if (!cfg.value) return false
  if (form.enabled !== cfg.value.ssh_sync_enabled) return true
  if (form.port !== cfg.value.ssh_sync_port) return true
  if (form.secretDirty && form.secret) return true
  return false
})

function generateSecret(): string {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  const bytes = new Uint8Array(32)
  crypto.getRandomValues(bytes)
  return Array.from(bytes, b => chars[b % chars.length]).join('')
}

async function saveSync() {
  saving.value = true
  saveError.value = ''
  saveOk.value = false
  try {
    await apiFetch('/settings/ssh-sync', {
      method: 'PUT',
      body: {
        enabled: form.enabled,
        port: form.port,
        secret: form.secretDirty && form.secret ? form.secret : null,
      },
    })
    saveOk.value = true
    await loadSettings()
    setTimeout(() => { saveOk.value = false }, 3000)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string; error?: string }; message?: string }
    saveError.value = fe?.data?.detail || fe?.data?.error || fe?.message || 'Save failed.'
  } finally {
    saving.value = false
  }
}

// ── SSH sync test ─────────────────────────────────────────────────────────────
const syncTestResult = ref<{ ok: boolean; error?: string; daemon_version?: string } | null>(null)
const syncTesting = ref(false)

async function testSync() {
  syncTesting.value = true
  syncTestResult.value = null
  try {
    syncTestResult.value = await apiFetch('/sync/test', { method: 'POST' })
  } catch {
    syncTestResult.value = { ok: false, error: 'Request failed' }
  } finally {
    syncTesting.value = false
  }
}
</script>

<template>
  <div class="page">

    <!-- Topbar -->
    <nav class="topbar">
      <div class="breadcrumb">
        <AppLogo :size="20" variant="dark" class="logo-mark" />
        <NuxtLink to="/dashboard" class="bc-link">LTPDA Repository</NuxtLink>
        <span class="bc-sep">/</span>
        <span class="bc-current">Settings</span>
      </div>
      <div class="nav-right">
        <NuxtLink to="/admin/users" class="nav-link">
          <Users :size="14" />
          Users
        </NuxtLink>
        <div class="user-chip">
          <span class="avatar">{{ currentUser?.username?.[0]?.toUpperCase() }}</span>
          <span class="uname">{{ currentUser?.username }}</span>
          <span v-if="currentUser?.is_admin" class="admin-dot" title="Administrator" />
        </div>
        <button class="btn-ghost" @click="logout">Sign out</button>
      </div>
    </nav>

    <main class="main">

      <div class="page-head">
        <div>
          <h1>Settings</h1>
          <p class="page-sub">Server configuration and SSH sync daemon management.</p>
        </div>
      </div>

      <div v-if="pageError" class="banner-error">
        {{ pageError }}
        <button @click="pageError = ''">✕</button>
      </div>

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
        </section>

        <!-- ── SSH Sync Daemon ───────────────────────────────────────────── -->
        <section class="card">
          <div class="card-head">
            <h2>SSH sync daemon</h2>
            <span v-if="cfg.mysql_mode !== 'bundled'" class="badge-mode badge-na">
              Bundled MySQL only
            </span>
          </div>

          <p v-if="cfg.mysql_mode !== 'bundled'" class="card-note">
            The SSH sync daemon is only available when using bundled MySQL mode.
          </p>

          <template v-else>
            <p class="card-desc">
              Automatically creates, updates, and removes Linux SSH accounts on the host whenever
              repository users are added, updated, or removed — eliminating the manual
              <code>useradd</code> / <code>userdel</code> step.
            </p>

            <!-- Enable toggle -->
            <label class="toggle-row" :class="{ 'toggle-on': form.enabled }">
              <div class="toggle-text">
                <span class="toggle-label">Enable SSH sync</span>
                <span class="toggle-desc">
                  {{ form.enabled ? 'Accounts are managed automatically by the daemon' : 'Accounts must be created manually on the host' }}
                </span>
              </div>
              <div class="toggle-track" :class="{ active: form.enabled }">
                <input v-model="form.enabled" type="checkbox" class="sr-only" />
                <div class="toggle-thumb" />
              </div>
            </label>

            <template v-if="form.enabled">
              <!-- Port -->
              <div class="field">
                <label>Daemon port</label>
                <input v-model.number="form.port" type="number" min="1024" max="65535" style="max-width:120px" />
              </div>

              <!-- Secret -->
              <div class="field">
                <label>
                  Shared secret
                  <span v-if="cfg.ssh_sync_secret_set" class="secret-hint">(currently set — leave blank to keep)</span>
                  <span v-else class="req">*</span>
                </label>
                <div class="pw-wrap">
                  <input
                    v-model="form.secret"
                    :type="showSecret ? 'text' : 'password'"
                    class="pw-input"
                    :placeholder="cfg.ssh_sync_secret_set ? 'Leave blank to keep current secret' : 'Enter or generate a secret'"
                    @input="form.secretDirty = true"
                  />
                  <button type="button" class="pw-eye" @click="showSecret = !showSecret">
                    <EyeOff v-if="showSecret" />
                    <Eye v-else />
                  </button>
                  <button type="button" class="pw-gen" @click="form.secret = generateSecret(); form.secretDirty = true; showSecret = true">
                    Generate
                  </button>
                </div>
              </div>

              <!-- Test -->
              <div class="test-row">
                <button type="button" class="btn-cancel" :disabled="syncTesting" @click="testSync">
                  <span v-if="syncTesting" class="spin spin-sm" />
                  {{ syncTesting ? 'Testing…' : 'Test daemon connection' }}
                </button>
                <span v-if="syncTestResult !== null" class="test-result" :class="syncTestResult.ok ? 'test-ok' : 'test-fail'">
                  <Wifi v-if="syncTestResult.ok" :size="13" />
                  <WifiOff v-else :size="13" />
                  {{ syncTestResult.ok
                    ? `Reachable${syncTestResult.daemon_version ? ' (v' + syncTestResult.daemon_version + ')' : ''}`
                    : (syncTestResult.error || 'Unknown error') }}
                </span>
              </div>
            </template>

            <!-- Install instructions (always visible when bundled) -->
            <div class="install-note">
              <strong>Install the daemon on the host server</strong>
              <p>Run these commands on the server (not inside Docker):</p>
              <pre class="code-block">sudo mkdir -p /opt/ltpda-ssh-sync
sudo cp repository/ssh-sync-daemon/ssh_sync_daemon.py /opt/ltpda-ssh-sync/
sudo pip3 install flask
sudo cp repository/ssh-sync-daemon/config.example.json /etc/ltpda-ssh-sync.json
sudo nano /etc/ltpda-ssh-sync.json   # set shared_secret to match above
sudo cp repository/ssh-sync-daemon/ltpda-ssh-sync.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ltpda-ssh-sync</pre>
              <p>Firewall: allow port {{ form.port }} from the Docker bridge only:</p>
              <pre class="code-block">sudo ufw allow from 172.16.0.0/12 to any port {{ form.port }}
sudo ufw allow from 192.168.0.0/16 to any port {{ form.port }}</pre>
            </div>

            <!-- Save -->
            <div v-if="saveError" class="banner-error" style="margin-top:1rem">
              {{ saveError }}
              <button @click="saveError = ''">✕</button>
            </div>
            <div v-if="saveOk" class="banner-ok">
              Settings saved.
            </div>
            <div class="save-row">
              <button class="btn-primary" :disabled="!dirty || saving" @click="saveSync">
                <span v-if="saving" class="spin spin-sm" />
                {{ saving ? 'Saving…' : 'Save changes' }}
              </button>
              <span v-if="!dirty && !saveOk" class="save-hint">No unsaved changes</span>
            </div>
          </template>
        </section>

      </template>

    </main>
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
.badge-na { background: #f3f4f6; color: #9ca3af; }

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

/* ── Toggle ── */
.toggle-row {
  display: flex; align-items: center; justify-content: space-between; gap: 1.5rem;
  padding: 1rem; background: #f8fafd; border: 1px solid #d0dcea;
  border-radius: 10px; cursor: pointer; margin-bottom: 1.25rem;
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

/* ── Secret hint ── */
.secret-hint { font-size: 0.75rem; font-weight: 400; color: #a8bdd0; margin-left: 0.4rem; }

/* ── Test row ── */
.test-row { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.test-result {
  display: flex; align-items: center; gap: 0.35rem;
  font-size: 0.8rem; font-weight: 500;
}
.test-ok { color: #16a34a; }
.test-fail { color: #dc2626; }

/* ── Install note ── */
.install-note {
  margin-top: 1.5rem; padding: 1rem 1.25rem;
  background: #f8fafd; border: 1px solid #d0dcea; border-radius: 8px;
  font-size: 0.8rem; color: #4a6080; line-height: 1.6;
}
.install-note strong { font-weight: 700; color: #1e3050; display: block; margin-bottom: 0.4rem; }
.install-note p { margin: 0.75rem 0 0.3rem; }
.code-block {
  background: #1e3050; color: #c8e0f8; font-family: 'JetBrains Mono', ui-monospace, monospace;
  font-size: 0.75rem; line-height: 1.7; padding: 0.85rem 1rem;
  border-radius: 7px; overflow-x: auto; margin: 0.35rem 0 0; white-space: pre;
}

/* ── Save row ── */
.save-row { display: flex; align-items: center; gap: 1rem; margin-top: 1.5rem; }
.save-hint { font-size: 0.775rem; color: #a8bdd0; }

/* ── Banners ── */
.banner-ok {
  padding: 0.65rem 1rem; background: #f0fdf4; border: 1px solid #bbf7d0;
  border-radius: 8px; font-size: 0.825rem; color: #16a34a; margin-top: 1rem;
}
</style>
