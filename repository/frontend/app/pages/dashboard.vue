<script setup lang="ts">
import { FolderOpen, Database, ArrowRight } from 'lucide-vue-next'

definePageMeta({ layout: 'default' })

const { apiFetch, user } = useAuth()
const { setTitle } = useTopbar()
setTitle(null) // brand mode

interface Repo {
  id: number
  db_name: string
  name: string
  description: string | null
  version: number
  obj_count: number
}

const repos = ref<Repo[]>([])
const loading = ref(true)
const error = ref('')

async function loadRepos() {
  loading.value = true
  error.value = ''
  try {
    repos.value = await apiFetch<Repo[]>('/repos')
  } catch (e: unknown) {
    const fe = e as { data?: { detail?: string }; message?: string }
    error.value = fe?.data?.detail || fe?.message || 'Failed to load repositories.'
  } finally {
    loading.value = false
  }
}

onMounted(() => loadRepos())
</script>

<template>
  <main class="content">

    <div class="page-head">
      <h1>Repositories</h1>
      <p class="page-sub">Browse your accessible data repositories.</p>
    </div>

    <div v-if="error" class="banner-error">
      {{ error }}
      <button @click="error = ''">✕</button>
    </div>

    <div v-if="loading" class="loading-wrap">
      <div class="spin" />
    </div>

    <div v-else-if="repos.length === 0 && !error" class="empty">
      <div class="empty-icon">
        <FolderOpen :size="56" />
      </div>
      <h2>No repositories yet</h2>
      <p v-if="user?.is_admin">
        Create a repository from the
        <NuxtLink to="/admin/repos">Repositories</NuxtLink> admin page.
      </p>
      <p v-else>You have not been granted access to any repositories yet.</p>
    </div>

    <div v-else class="repo-grid">
      <NuxtLink
        v-for="repo in repos"
        :key="repo.db_name"
        :to="`/repos/${repo.db_name}`"
        class="repo-card"
      >
        <div class="repo-card-body">
          <div class="repo-name">{{ repo.name }}</div>
          <code class="repo-db">{{ repo.db_name }}</code>
          <p v-if="repo.description" class="repo-desc">{{ repo.description }}</p>
        </div>
        <div class="repo-card-foot">
          <span class="obj-count">
            <Database :size="12" />
            {{ repo.obj_count.toLocaleString() }} object{{ repo.obj_count === 1 ? '' : 's' }}
          </span>
          <span class="browse-link">
            Browse
            <ArrowRight :size="13" />
          </span>
        </div>
      </NuxtLink>
    </div>

  </main>
</template>

<style scoped>
.content { flex: 1; padding: 2.5rem 2rem; max-width: 1100px; margin: 0 auto; width: 100%; }

.page-head { margin-bottom: 1.75rem; }
h1 { font-size: 1.2rem; font-weight: 700; letter-spacing: -0.025em; color: #1e3050; }
.page-sub { font-size: 0.825rem; color: #6a84a0; margin-top: 0.25rem; }

.loading-wrap { display: flex; justify-content: center; padding: 4rem; }

.empty { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; text-align: center; padding: 4rem 0; }
.empty-icon { margin-bottom: 0.75rem; color: #b0c8e0; }
.empty h2 { font-size: 1rem; font-weight: 600; letter-spacing: -0.02em; color: #1e3050; }
.empty p { font-size: 0.825rem; color: #6a84a0; }
.empty a { color: #2a70c8; text-decoration: none; }
.empty a:hover { text-decoration: underline; }

.repo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
}

.repo-card {
  display: flex; flex-direction: column;
  background: #fff; border: 1px solid #d0dcea; border-radius: 12px;
  text-decoration: none; overflow: hidden;
  transition: border-color 0.15s, box-shadow 0.15s;
}
.repo-card:hover {
  border-color: #2a70c8; box-shadow: 0 4px 16px rgba(42,112,200,0.12);
}

.repo-card-body { flex: 1; padding: 1.25rem 1.25rem 0.75rem; }
.repo-name { font-size: 0.925rem; font-weight: 700; color: #1e3050; letter-spacing: -0.02em; margin-bottom: 0.3rem; }
.repo-db {
  display: inline-block;
  font-family: 'JetBrains Mono', ui-monospace, monospace;
  font-size: 0.75rem; color: #6a84a0; background: #eef2f7;
  padding: 0.1em 0.4em; border-radius: 4px; margin-bottom: 0.6rem;
}
.repo-desc { font-size: 0.8rem; color: #4a6080; line-height: 1.5; margin: 0; }

.repo-card-foot {
  display: flex; align-items: center; justify-content: space-between;
  padding: 0.75rem 1.25rem;
  background: #f8fafe; border-top: 1px solid #e8eef6;
  font-size: 0.775rem;
}
.obj-count { display: flex; align-items: center; gap: 0.35rem; color: #6a84a0; }
.browse-link { display: flex; align-items: center; gap: 0.25rem; color: #2a70c8; font-weight: 600; }
</style>
