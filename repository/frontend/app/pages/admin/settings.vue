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
}

const cfg = ref<Settings | null>(null)
const loading = ref(true)
const pageError = ref('')
const pmaOpening = ref(false)

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

async function loadSettings() {
  loading.value = true
  try {
    cfg.value = await apiFetch<Settings>('/settings')
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

        <!-- ── SSH tunnel ─────────────────────────────────────────────────── -->
        <section v-if="cfg.mysql_mode === 'bundled'" class="card">
          <div class="card-head">
            <h2>MATLAB SSH tunnel</h2>
            <span class="badge-mode badge-bundled">Active</span>
          </div>
          <p class="card-desc">
            An SSH gateway container runs on port 2222 of this server. MATLAB users connect
            using their MySQL/MATLAB credentials — no extra accounts or configuration needed.
          </p>
          <div class="tunnel-cmd">
            <code>ssh -L 3306:db:3306 -p 2222 username@repo.yourdomain.com</code>
          </div>
          <p class="card-note">
            In LTPDAprefs, set <strong>hostname = localhost</strong>, <strong>port = 3306</strong>,
            and use the user's MySQL/MATLAB password. Port 2222 must be open in the server firewall
            (<code>sudo ufw allow 2222/tcp</code>).
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
            <code>/pma/</code> is accessible to anyone who knows the URL — keep this
            server behind a firewall or reverse-proxy authentication if internet-facing.
            Requires <code>LTPDA_PUBLIC_URL</code> to be set in <code>.env</code> for
            phpMyAdmin's internal page links to work correctly.
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

/* ── Database manager button ── */
.pma-btn {
  display: inline-flex; align-items: center;
  padding: 0.5rem 1.1rem; background: #1e3050; color: #fff;
  border-radius: 8px; font-size: 0.825rem; font-weight: 600;
  text-decoration: none; transition: background 0.15s;
}
.pma-btn:hover { background: #2f5596; }

/* ── Tunnel command ── */
.tunnel-cmd {
  background: #1e3050; border-radius: 8px; padding: 0.85rem 1rem; margin-bottom: 0.5rem;
}
.tunnel-cmd code {
  font-family: 'JetBrains Mono', ui-monospace, monospace; font-size: 0.8rem;
  color: #c8e0f8; white-space: pre-wrap; word-break: break-all;
}
</style>
