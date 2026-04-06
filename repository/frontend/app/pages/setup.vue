<script setup lang="ts">
definePageMeta({ layout: false })

const config = useRuntimeConfig()
const router = useRouter()

const form = reactive({
  mysql_host: 'host.docker.internal',
  mysql_port: 3306,
  mysql_database: 'ltpda_repo',
  admin_username: 'root',
  admin_password: '',
  service_username: 'ltpda_svc',
  service_password: '',
  app_admin_username: 'admin',
  app_admin_password: '',
  app_admin_given_name: '',
  app_admin_family_name: '',
  app_admin_email: '',
})

const loading = ref(false)
const error = ref('')
const step = ref(1)

async function runSetup() {
  loading.value = true
  error.value = ''
  try {
    await $fetch(`${config.public.apiBase}/setup/run`, {
      method: 'POST',
      body: form,
    })
    await router.push('/login')
  } catch (e: unknown) {
    const err = e as { data?: { detail?: string } }
    error.value = err?.data?.detail ?? 'Setup failed. Check your MySQL credentials and try again.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="setup-page">
    <div class="setup-card">
      <h1>LTPDA Repository Setup</h1>
      <p class="subtitle">Configure your repository server. This wizard runs once.</p>

      <form @submit.prevent="runSetup">
        <!-- Step 1: MySQL -->
        <section>
          <h2>1. MySQL Connection</h2>
          <p class="hint">Admin credentials are used once to create the database and a limited service account. They are never stored.</p>
          <div class="field">
            <label>Host</label>
            <input v-model="form.mysql_host" required />
          </div>
          <div class="field field-row">
            <div>
              <label>Port</label>
              <input v-model.number="form.mysql_port" type="number" required />
            </div>
            <div class="grow">
              <label>Database name</label>
              <input v-model="form.mysql_database" required />
            </div>
          </div>
          <div class="field">
            <label>Admin username</label>
            <input v-model="form.admin_username" required />
          </div>
          <div class="field">
            <label>Admin password</label>
            <input v-model="form.admin_password" type="password" required />
          </div>
        </section>

        <!-- Step 2: Service account -->
        <section>
          <h2>2. Service Account</h2>
          <p class="hint">A MySQL account with SELECT/INSERT/UPDATE/DELETE only. Credentials stored in config.json.</p>
          <div class="field">
            <label>Service username</label>
            <input v-model="form.service_username" required />
          </div>
          <div class="field">
            <label>Service password</label>
            <input v-model="form.service_password" type="password" required />
          </div>
        </section>

        <!-- Step 3: First admin user -->
        <section>
          <h2>3. First Admin User</h2>
          <div class="field field-row">
            <div class="grow">
              <label>Username</label>
              <input v-model="form.app_admin_username" required />
            </div>
            <div class="grow">
              <label>Password</label>
              <input v-model="form.app_admin_password" type="password" required />
            </div>
          </div>
          <div class="field field-row">
            <div class="grow">
              <label>Given name</label>
              <input v-model="form.app_admin_given_name" />
            </div>
            <div class="grow">
              <label>Family name</label>
              <input v-model="form.app_admin_family_name" />
            </div>
          </div>
          <div class="field">
            <label>Email</label>
            <input v-model="form.app_admin_email" type="email" />
          </div>
        </section>

        <div v-if="error" class="error-msg">{{ error }}</div>

        <button type="submit" :disabled="loading" class="btn-primary">
          {{ loading ? 'Setting up…' : 'Run Setup' }}
        </button>
      </form>
    </div>
  </div>
</template>

<style scoped>
.setup-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  padding: 2rem;
}
.setup-card {
  background: white;
  border-radius: 8px;
  padding: 2.5rem;
  width: 100%;
  max-width: 560px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
}
h1 { margin: 0 0 0.25rem; font-size: 1.5rem; }
h2 { font-size: 1rem; margin: 1.5rem 0 0.5rem; color: #333; }
.subtitle { color: #666; margin: 0 0 1.5rem; font-size: 0.9rem; }
.hint { font-size: 0.8rem; color: #888; margin: 0 0 0.75rem; }
section { border-top: 1px solid #eee; padding-top: 0.5rem; }
.field { margin-bottom: 0.75rem; display: flex; flex-direction: column; gap: 0.25rem; }
.field-row { flex-direction: row; gap: 1rem; }
.field-row > div { display: flex; flex-direction: column; gap: 0.25rem; }
.grow { flex: 1; }
label { font-size: 0.85rem; font-weight: 500; color: #444; }
input {
  padding: 0.45rem 0.6rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 0.9rem;
  width: 100%;
  box-sizing: border-box;
}
input:focus { outline: none; border-color: #2563eb; }
.error-msg { color: #dc2626; font-size: 0.85rem; margin-bottom: 0.75rem; }
.btn-primary {
  width: 100%;
  padding: 0.65rem;
  background: #2563eb;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 1rem;
}
.btn-primary:disabled { background: #93c5fd; cursor: not-allowed; }
.btn-primary:hover:not(:disabled) { background: #1d4ed8; }
</style>
