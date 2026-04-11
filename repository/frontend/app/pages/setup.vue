<script setup lang="ts">
import { Eye, EyeOff, Info, ChevronDown, Package, Database, Settings, TriangleAlert } from 'lucide-vue-next'
definePageMeta({ layout: false, pageTransition: false })

const config = useRuntimeConfig()
const router = useRouter()

type Mode = 'bundled' | 'external'
const mode = ref<Mode>('bundled')

const bundled = reactive({ root_password: '', public_url: '' })
const external = reactive({ host: '', port: 3306, admin_user: 'root', admin_password: '' })
const adminDb = ref('ltpda_admin')
const adminUser = reactive({ username: 'admin', password: '', mysql_password: '', first_name: '', last_name: '', email: '' })

const loading = ref(false)
const error = ref('')
const infoOpen = ref(false)
const configOpen = ref(false)
const success = ref<{ sshSync: boolean } | null>(null)

const show = reactive({ bundledPw: false, externalPw: false, appAdminPw: false, appAdminMysqlPw: false })

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

async function runSetup() {
  loading.value = true
  error.value = ''
  try {
    const body: Record<string, unknown> = {
      mode: mode.value,
      admin_db: adminDb.value,
      app_admin_username: adminUser.username,
      app_admin_password: adminUser.password,
      app_admin_mysql_password: adminUser.mysql_password,
      app_admin_first_name: adminUser.first_name || null,
      app_admin_last_name: adminUser.last_name || null,
      app_admin_email: adminUser.email || null,
    }
    if (mode.value === 'bundled') {
      body.mysql_host = 'mysql'
      body.mysql_port = 3306
      body.mysql_admin_user = 'root'
      body.mysql_admin_password = bundled.root_password
      if (bundled.public_url) body.public_url = bundled.public_url
    } else {
      body.mysql_host = external.host
      body.mysql_port = external.port
      body.mysql_admin_user = external.admin_user
      body.mysql_admin_password = external.admin_password
    }
    const data = await $fetch(`${config.public.apiBase}/setup/run`, { method: 'POST', body }) as { ok: boolean; ssh_sync_verified?: boolean }
    success.value = { sshSync: !!data.ssh_sync_verified }
    setTimeout(() => router.push('/login'), 2500)
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string; error?: string }; message?: string }
    error.value =
      fe?.data?.detail ||
      fe?.data?.error ||
      fe?.message ||
      'Setup failed. Check your credentials and try again.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="shell">

      <!-- Header -->
      <div class="hd">
        <AppLogo :size="42" class="hd-logo" />
        <div>
          <h1>LTPDA Repository</h1>
          <p class="hd-sub">v{{ config.public.version }} — Docker Image Initial Setup</p>
        </div>
      </div>

      <!-- ── How it works (collapsible) ── -->
      <div class="info-panel" :class="{ 'info-open': infoOpen }">
        <button type="button" class="info-toggle" @click="infoOpen = !infoOpen">
          <Info :size="14" />
          How does the repository work?
          <ChevronDown :size="14" class="info-chevron" />
        </button>
        <div v-if="infoOpen" class="info-body">
          <div class="info-grid">
            <div class="info-block">
              <div class="info-block-title">MySQL databases</div>
              <p>One MySQL database is created per repository (e.g. <code>myrepo</code>). A separate admin database (default: <code>ltpda_admin</code>) stores the user registry and the list of repositories. This is the same structure as v2.5.</p>
            </div>
            <div class="info-block">
              <div class="info-block-title">MySQL user accounts</div>
              <p>Every repository user also gets a MySQL account (<code>username@'%'</code>). MATLAB connects directly to repository databases over JDBC using those MySQL credentials — the web API is bypassed entirely.</p>
            </div>
            <div class="info-block">
              <div class="info-block-title">Privileged MySQL account</div>
              <p>The setup wizard needs a MySQL account with <code>CREATE DATABASE</code>, <code>CREATE USER</code>, and <code>GRANT</code> privileges. This account is stored in <code>config/config.json</code> and used permanently — it is needed every time a repository or user is created or deleted.</p>
            </div>
            <div class="info-block">
              <div class="info-block-title">Two passwords per user</div>
              <p>Each user has a <strong>web UI password</strong> (bcrypt, for logging in here) and a separate <strong>MySQL password</strong> (for MATLAB JDBC access). They can be the same value but are managed independently.</p>
            </div>
            <div class="info-block">
              <div class="info-block-title">Docker &amp; web server</div>
              <p>Docker runs the FastAPI backend and nginx (serving this UI). Your existing Apache or Nginx reverse-proxies the Docker container on port 8080. MySQL runs either inside Docker (bundled) or on a dedicated server you provide.</p>
            </div>
            <div class="info-block">
              <div class="info-block-title">Shared hosting not supported</div>
              <p>The repository must create and drop databases and MySQL users. It is not compatible with cPanel, Plesk, or any environment where you don't have full MySQL superuser access.</p>
            </div>
          </div>
        </div>
      </div>

      <form @submit.prevent="runSetup">

        <!-- ── MySQL deployment mode ── -->
        <div class="section">
          <div class="section-title">MySQL deployment</div>
          <div class="mode-grid">

            <!-- Bundled -->
            <button
              type="button"
              class="mode-card"
              :class="{ 'is-active': mode === 'bundled' }"
              @click="mode = 'bundled'"
            >
              <div class="mode-check"><span v-if="mode === 'bundled'" class="check-dot"/></div>
              <div class="mode-icon"><Package :size="26" /></div>
              <div class="mode-title">Bundled MySQL</div>
              <div class="mode-desc">MySQL runs inside the Docker container. Simplest option — recommended for new deployments.</div>
            </button>

            <!-- External -->
            <button
              type="button"
              class="mode-card"
              :class="{ 'is-active': mode === 'external' }"
              @click="mode = 'external'"
            >
              <div class="mode-check"><span v-if="mode === 'external'" class="check-dot"/></div>
              <div class="mode-icon"><Database :size="26" /></div>
              <div class="mode-title">External MySQL</div>
              <div class="mode-desc">Connect to an existing dedicated MySQL server that you manage separately.</div>
            </button>

          </div>
        </div>

        <!-- ── MySQL configuration requirements (collapsible, mode-aware) ── -->
        <div class="info-panel" :class="{ 'info-open': configOpen }">
          <button type="button" class="info-toggle" @click="configOpen = !configOpen">
            <Settings :size="14" />
            MySQL server configuration
            <span class="cfg-badge" :class="mode === 'bundled' ? 'cfg-badge-ok' : 'cfg-badge-warn'">
              {{ mode === 'bundled' ? 'preconfigured' : 'manual steps required' }}
            </span>
            <ChevronDown :size="14" class="info-chevron" />
          </button>

          <div v-if="configOpen" class="info-body">

            <!-- Bundled: everything is taken care of -->
            <template v-if="mode === 'bundled'">
              <p class="config-note">All required MySQL settings are applied automatically via Docker command flags. No host configuration needed.</p>
              <div class="config-list">
                <div class="config-item config-ok">
                  <StatusOk />
                  <div><strong>max_allowed_packet = 256 MB</strong><p>Set via <code>--max-allowed-packet=268435456</code>. Required for LTPDA binary analysis object BLOBs.</p></div>
                </div>
                <div class="config-item config-ok">
                  <StatusOk />
                  <div><strong>innodb_buffer_pool_size = 256 MB</strong><p>Default tuning. Increase in <code>docker-compose.yml</code> for large deployments.</p></div>
                </div>
                <div class="config-item config-ok">
                  <StatusOk />
                  <div><strong>Data persistence</strong><p>MySQL data is stored in the <code>mysql_data</code> Docker volume and survives container restarts and upgrades.</p></div>
                </div>
                <div class="config-item config-ok">
                  <StatusOk />
                  <div><strong>MySQL exposed on host port 3307</strong><p>Port 3307 (not 3306, which is taken by the host's own MySQL) is bound to <code>127.0.0.1</code> only — not reachable from the internet. This is set in <code>docker-compose.yml</code> and requires no other host configuration.</p></div>
                </div>
                <div class="config-item config-ok">
                  <StatusOk />
                  <div>
                    <strong>MATLAB SSH tunnel — no setup required</strong>
                    <p>An SSH gateway container starts automatically with Docker on port 2222. MATLAB users tunnel using their MySQL/MATLAB credentials — no Linux accounts needed.</p>
                    <p class="step-paths"><code>ssh -L 3306:db:3306 -p 2222 username@yourserver.edu</code></p>
                    <p>In LTPDAprefs, set <strong>hostname = localhost</strong>, <strong>port = 3306</strong>. Open port 2222 in the server firewall: <code>sudo ufw allow 2222/tcp</code></p>
                  </div>
                </div>
              </div>
            </template>

            <!-- External: numbered manual steps -->
            <template v-else>
              <p class="config-note">Complete these steps on the MySQL server <strong>before</strong> clicking Run Setup.</p>
              <div class="config-list">
                <div class="config-item config-manual">
                  <span class="step-num">1</span>
                  <div>
                    <strong>max_allowed_packet = 256M</strong>
                    <p>LTPDA stores binary analysis objects as MySQL BLOBs that exceed the default packet limit. Add <code>max_allowed_packet = 256M</code> to the <code>[mysqld]</code> section of your config file and restart MySQL.</p>
                    <p class="step-paths">Linux: <code>/etc/mysql/mysql.conf.d/mysqld.cnf</code> &nbsp;·&nbsp; Windows: <code>my.ini</code></p>
                  </div>
                </div>
                <div class="config-item config-manual">
                  <span class="step-num">2</span>
                  <div>
                    <strong>Allow remote connections (bind-address)</strong>
                    <p>MySQL binds to <code>127.0.0.1</code> only by default. Set <code>bind-address = 0.0.0.0</code> (or your server's LAN IP) in the same config file, then restart MySQL.</p>
                  </div>
                </div>
                <div class="config-item config-manual">
                  <span class="step-num">3</span>
                  <div>
                    <strong>Firewall: open port 3306 to Docker</strong>
                    <p>Allow TCP 3306 from Docker's bridge network (<code>172.16.0.0/12</code>). Keep the port closed to the internet.</p>
                    <p class="step-paths">Example (ufw): <code>ufw allow from 172.16.0.0/12 to any port 3306</code></p>
                  </div>
                </div>
                <div class="config-item config-manual">
                  <span class="step-num">4</span>
                  <div>
                    <strong>host.docker.internal — Linux only</strong>
                    <p>On macOS/Windows Docker Desktop this hostname resolves automatically. On Linux, the <code>docker-compose.yml</code> already adds <code>extra_hosts: host-gateway</code> so containers can reach the host as <code>host.docker.internal</code>. If your MySQL runs on a separate machine, enter its IP address directly in the Host field above instead.</p>
                  </div>
                </div>
              </div>
            </template>

          </div>
        </div>

        <!-- ── Bundled: root password + public URL ── -->
        <template v-if="mode === 'bundled'">
          <div class="section">
            <div class="section-title">MySQL root password</div>
            <p class="note">
              Set this to the same value as <code class="inline-code">MYSQL_ROOT_PASSWORD</code> in your
              <code class="inline-code">.env</code> file before running
              <code class="inline-code">docker compose --profile bundled up -d</code>.
            </p>
            <div class="field">
              <label>Root password <span class="req">*</span></label>
              <div class="pw-wrap">
                <input v-model="bundled.root_password" :type="show.bundledPw ? 'text' : 'password'" required class="pw-input"/>
                <button type="button" class="pw-eye" @click="show.bundledPw = !show.bundledPw"><EyeOff v-if="show.bundledPw" /><Eye v-else /></button>
                <button type="button" class="pw-gen" @click="bundled.root_password = generatePassword(); show.bundledPw = true">Generate</button>
              </div>
            </div>
            <div class="field" style="margin-top:0.5rem">
              <label>Server public URL</label>
              <input v-model="bundled.public_url" type="url" placeholder="https://repo.yourdomain.com"/>
              <p class="field-hint">Required for phpMyAdmin (Admin → Settings). No trailing slash. Can be set later in Settings if you don't know it yet.</p>
            </div>
          </div>
        </template>

        <!-- ── External: connection details ── -->
        <template v-else>
          <div class="section">
            <div class="section-title">External MySQL server</div>

            <!-- Warning banner -->
            <div class="warn-banner">
              <TriangleAlert :size="18" />
              <div>
                <strong>Dedicated server required.</strong>
                The LTPDA repository creates and manages its own MySQL databases and user accounts.
                It is <strong>not compatible</strong> with shared hosting environments (cPanel, Plesk, shared MySQL servers).
              </div>
            </div>

            <div class="row-2" style="margin-top:1rem">
              <div class="field" style="flex:2">
                <label>Host <span class="req">*</span></label>
                <input v-model="external.host" required placeholder="e.g. 192.168.1.10 or db.example.com"/>
              </div>
              <div class="field" style="flex:0 0 96px">
                <label>Port</label>
                <input v-model.number="external.port" type="number" required/>
              </div>
            </div>
            <div class="row-2">
              <div class="field">
                <label>Privileged MySQL username <span class="req">*</span></label>
                <input v-model="external.admin_user" required placeholder="root"/>
              </div>
              <div class="field">
                <label>Privileged MySQL password <span class="req">*</span></label>
                <div class="pw-wrap">
                  <input v-model="external.admin_password" :type="show.externalPw ? 'text' : 'password'" required class="pw-input"/>
                  <button type="button" class="pw-eye" @click="show.externalPw = !show.externalPw"><EyeOff v-if="show.externalPw" /><Eye v-else /></button>
                </div>
              </div>
            </div>
            <p class="note">Needs CREATE DATABASE, CREATE USER, and GRANT — does not need to be root.</p>
          </div>
        </template>

        <!-- ── Admin database name ── -->
        <div class="section">
          <div class="section-title">Admin database</div>
          <p class="note">The setup wizard will create this database to store users and the repository registry.</p>
          <div class="field" style="max-width:260px">
            <label>Database name</label>
            <input v-model="adminDb" required placeholder="ltpda_admin"/>
          </div>
        </div>

        <!-- ── First repository user (will be admin) ── -->
        <div class="section">
          <div class="section-title">Repository administrator</div>
          <div class="row-2">
            <div class="field">
              <label>Username <span class="req">*</span></label>
              <input v-model="adminUser.username" required/>
            </div>
            <div class="field">
              <label>Web UI password <span class="req">*</span></label>
              <div class="pw-wrap">
                <input v-model="adminUser.password" :type="show.appAdminPw ? 'text' : 'password'" required class="pw-input"/>
                <button type="button" class="pw-eye" @click="show.appAdminPw = !show.appAdminPw"><EyeOff v-if="show.appAdminPw" /><Eye v-else /></button>
                <button type="button" class="pw-gen" @click="adminUser.password = generatePassword(); show.appAdminPw = true">Generate</button>
              </div>
            </div>
          </div>
          <div class="field">
            <label>MySQL / MATLAB password <span class="req">*</span></label>
            <div class="pw-wrap">
              <input v-model="adminUser.mysql_password" :type="show.appAdminMysqlPw ? 'text' : 'password'" required class="pw-input"/>
              <button type="button" class="pw-eye" @click="show.appAdminMysqlPw = !show.appAdminMysqlPw"><EyeOff v-if="show.appAdminMysqlPw" /><Eye v-else /></button>
              <button type="button" class="pw-gen" @click="adminUser.mysql_password = generatePassword(); show.appAdminMysqlPw = true">Generate</button>
            </div>
            <p class="field-hint">Used to create a MySQL account for this user. MATLAB connects to the repository via JDBC using these credentials.</p>
          </div>
          <div class="row-3">
            <div class="field">
              <label>First name</label>
              <input v-model="adminUser.first_name" placeholder="Optional"/>
            </div>
            <div class="field">
              <label>Last name</label>
              <input v-model="adminUser.last_name" placeholder="Optional"/>
            </div>
            <div class="field" style="flex:1.5">
              <label>Email</label>
              <input v-model="adminUser.email" type="email" placeholder="Optional"/>
            </div>
          </div>
        </div>

        <!-- ── Submit ── -->
        <div v-if="error" class="err-banner">{{ error }}</div>

        <div v-if="success" class="success-panel">
          <div class="success-item success-ok">✓ Database configured and admin user created</div>
          <div class="success-item" :class="success.sshSync ? 'success-ok' : 'success-warn'">
            {{ success.sshSync ? '✓ SSH sync daemon verified — tunnel login is active' : '⚠ SSH sync not verified' }}
          </div>
          <p class="success-redirect">Redirecting to login…</p>
        </div>

        <button v-else type="submit" :disabled="loading" class="btn-submit">
          <span v-if="loading" class="spin"/>
          {{ loading ? 'Setting up…' : 'Run Setup' }}
        </button>

      </form>
    </div>
  </div>
</template>


<style scoped>
/* ── Page (setup: column layout, child centred on cross axis) ── */
.page {
  align-items: center;
  padding: 3.5rem 1.25rem 5rem;
}
.shell { width: 100%; max-width: 640px; }

/* ── Header ── */
.hd { display: flex; align-items: center; gap: 1rem; margin-bottom: 2.5rem; }
.hd-logo { width: 42px; height: 42px; flex-shrink: 0; }
h1 { font-size: 1.35rem; font-weight: 700; letter-spacing: -0.03em; color: #1e3050; line-height: 1.2; }
.hd-sub { font-size: 0.825rem; color: #6a84a0; margin-top: 0.2rem; }

/* ── Section cards ── */
.section, .info-panel {
  background: #ffffff; border: 1px solid #d0dcea;
  border-radius: 12px; margin-bottom: 0.85rem;
}
.section { padding: 1.5rem; }
.section-title {
  font-size: 0.68rem; font-weight: 700; letter-spacing: 0.1em; text-transform: uppercase;
  color: #8aa0b8; margin-bottom: 1.25rem;
}
.note { font-size: 0.8rem; color: #6a84a0; margin-top: -0.5rem; margin-bottom: 1.25rem; line-height: 1.65; }
.field-hint { font-size: 0.775rem; color: #8aa0b8; margin-top: 0.35rem; line-height: 1.55; }

/* ── Mode selector ── */
.mode-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
.mode-card {
  position: relative; display: flex; flex-direction: column;
  align-items: flex-start; gap: 0.65rem; padding: 1.25rem;
  background: #f8fafd; border: 1.5px solid #d0dcea;
  border-radius: 10px; cursor: pointer; text-align: left;
  transition: border-color 0.15s, background 0.15s;
}
.mode-card:hover:not(.is-active) { background: #f0f5fb; border-color: #b8cce0; }
.mode-card.is-active { background: #fff8ee; border-color: #f0a32a; box-shadow: 0 0 0 1px #f0a32a; }
.mode-check {
  position: absolute; top: 0.85rem; right: 0.85rem;
  width: 18px; height: 18px; border-radius: 50%;
  border: 1.5px solid #c8d8ec; background: #ffffff;
  display: flex; align-items: center; justify-content: center;
}
.mode-card.is-active .mode-check { border-color: #f0a32a; background: #f0a32a; }
.check-dot { width: 8px; height: 8px; border-radius: 50%; background: #fff; }
.mode-icon {
  width: 38px; height: 38px;
  display: flex; align-items: center; justify-content: center;
  background: #e8eef6; border-radius: 9px; color: #5a9bd3;
  transition: background 0.15s, color 0.15s;
}
.mode-card.is-active .mode-icon { background: #f0a32a; color: #1a3461; }
.mode-icon svg { width: 26px; height: 26px; }
.mode-title { font-size: 0.9rem; font-weight: 700; color: #1e3050; letter-spacing: -0.02em; }
.mode-desc { font-size: 0.775rem; color: #6a84a0; line-height: 1.55; }

/* ── Warning banner ── */
.warn-banner {
  display: flex; gap: 0.75rem; align-items: flex-start;
  padding: 0.9rem 1rem; background: #fffbeb; border: 1px solid #fde68a;
  border-radius: 9px; font-size: 0.8rem; color: #78450f; line-height: 1.6;
}
.warn-banner svg { width: 18px; height: 18px; flex-shrink: 0; margin-top: 0.1rem; color: #d97706; }
.warn-banner strong { font-weight: 700; color: #92400e; }

/* ── Grid rows ── */
.row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; margin-bottom: 0.75rem; }
.row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0.75rem; }
.field { gap: 0.35rem; margin-bottom: 0.75rem; }
.field:last-child { margin-bottom: 0; }

/* ── Code snippet ── */
.inline-code {
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
  font-size: 0.8em; background: #e8eef6; border: 1px solid #c8d8ec;
  border-radius: 4px; padding: 0.1em 0.4em; color: #2f5596;
}

/* ── Info panel ── */
.info-panel { overflow: hidden; }
.info-toggle {
  display: flex; align-items: center; gap: 0.55rem;
  width: 100%; padding: 1rem 1.25rem;
  background: none; border: none; cursor: pointer;
  font-size: 0.825rem; font-weight: 600; color: #4a6080;
  text-align: left; transition: background 0.12s;
}
.info-toggle:hover { background: #f4f8fd; }
.info-toggle > svg:first-child { color: #5a9bd3; flex-shrink: 0; }
.info-chevron { margin-left: auto; color: #b8cce0; transition: transform 0.2s; }
.info-open .info-chevron { transform: rotate(180deg); }
.info-body { border-top: 1px solid #e8eef6; padding: 1.25rem 1.25rem 1.5rem; }
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem 1.5rem; }
.info-block-title { font-size: 0.75rem; font-weight: 700; color: #2f5596; margin-bottom: 0.35rem; }
.info-block p { font-size: 0.775rem; color: #6a84a0; line-height: 1.65; margin: 0; }
.info-block code {
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
  font-size: 0.8em; background: #e8eef6; border: 1px solid #c8d8ec;
  border-radius: 3px; padding: 0.05em 0.35em; color: #2f5596;
}

/* ── Error / Submit ── */
.err-banner {
  font-size: 0.825rem; color: #b91c1c;
  background: #fef2f2; border: 1px solid #fecaca;
  border-radius: 9px; padding: 0.75rem 1rem; margin-bottom: 0.75rem;
}
.btn-submit {
  display: flex; align-items: center; justify-content: center;
  gap: 0.5rem; width: 100%; padding: 0.9rem;
  background: #f0a32a; color: #1a3461; border: none; border-radius: 10px;
  font-size: 0.9rem; font-weight: 800; letter-spacing: -0.01em;
  cursor: pointer; margin-top: 0.5rem;
  transition: background 0.15s, box-shadow 0.15s;
}
.btn-submit:hover:not(:disabled) { background: #e8961a; box-shadow: 0 4px 20px rgba(240,163,42,0.35); }
.btn-submit:disabled { opacity: 0.4; cursor: not-allowed; }
/* spinner on setup is slightly smaller */
.spin { width: 15px; height: 15px; border-width: 2.5px; }

/* ── Config badge (inside info-toggle) ── */
.cfg-badge {
  margin-left: 0.5rem; font-size: 0.68rem; font-weight: 600;
  letter-spacing: 0.03em; padding: 0.15rem 0.5rem;
  border-radius: 999px; flex-shrink: 0;
}
.cfg-badge-ok   { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
.cfg-badge-warn { background: #fff3d6; color: #b45309; border: 1px solid #fde68a; }

/* ── Config content ── */
.config-note {
  font-size: 0.8rem; color: #6a84a0; line-height: 1.65;
  margin-bottom: 1rem;
}
.config-list { display: flex; flex-direction: column; gap: 0.85rem; }
.config-item {
  display: flex; gap: 0.85rem; align-items: flex-start;
}
.config-item > div { display: flex; flex-direction: column; gap: 0.25rem; }
.config-item strong { font-size: 0.825rem; font-weight: 700; color: #1e3050; }
.config-item p { font-size: 0.775rem; color: #6a84a0; line-height: 1.6; margin: 0; }
.config-item code {
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, monospace;
  font-size: 0.8em; background: #e8eef6; border: 1px solid #c8d8ec;
  border-radius: 3px; padding: 0.05em 0.35em; color: #2f5596;
}
.step-num {
  flex-shrink: 0; width: 22px; height: 22px; margin-top: 0.05rem;
  display: flex; align-items: center; justify-content: center;
  background: #e8eef6; border: 1px solid #c8d8ec; border-radius: 50%;
  font-size: 0.7rem; font-weight: 700; color: #2f5596;
}
.step-paths {
  font-size: 0.75rem !important; color: #8aa0b8 !important; margin-top: 0.15rem !important;
}
.config-future {
  font-size: 0.75rem !important; color: #a8bdd0 !important;
  border-left: 2px solid #c8d8ec; padding-left: 0.6rem !important;
  margin-top: 0.4rem !important; font-style: italic;
}

/* ── Setup success panel ── */
.success-panel {
  background: #f0fdf4; border: 1px solid #bbf7d0;
  border-radius: 10px; padding: 1.25rem 1.5rem;
  display: flex; flex-direction: column; gap: 0.6rem;
  margin-bottom: 0.75rem;
}
.success-item { font-size: 0.85rem; font-weight: 600; }
.success-ok { color: #15803d; }
.success-warn { color: #b45309; }
.success-redirect { font-size: 0.775rem; color: #6a84a0; margin: 0.25rem 0 0; }

/* ── Toggle (reused from admin/users, scoped to setup) ── */
.toggle-row {
  display: flex; align-items: center; justify-content: space-between; gap: 1.5rem;
  padding: 1rem; background: #f8fafd; border: 1px solid #d0dcea;
  border-radius: 10px; cursor: pointer; margin-bottom: 0;
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

</style>
