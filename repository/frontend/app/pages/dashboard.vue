<script setup lang="ts">
import { Users, FolderOpen } from 'lucide-vue-next'
const { user, logout } = useAuth()
</script>

<template>
  <div class="page">
    <nav class="topbar">
      <div class="brand">
        <AppLogo :size="22" variant="dark" />
        <span>LTPDA Repository</span>
      </div>
      <div class="nav-right">
        <NuxtLink v-if="user?.is_admin" to="/admin/users" class="nav-link">
          <Users :size="14" />
          Users
        </NuxtLink>
        <div class="user-chip">
          <span class="avatar">{{ user?.username?.[0]?.toUpperCase() }}</span>
          <span class="uname">{{ user?.username }}</span>
          <span v-if="user?.is_admin" class="admin-dot" title="Administrator" />
        </div>
        <button class="btn-ghost" @click="logout">Sign out</button>
      </div>
    </nav>

    <main class="content">
      <div class="empty">
        <div class="empty-icon">
          <FolderOpen :size="56" />
        </div>
        <h2>No repositories yet</h2>
        <p>Repository management will be available in a future release.</p>
        <span class="version-tag">v3.0.0</span>
      </div>
    </main>
  </div>
</template>

<style scoped>
.topbar { padding: 0 1.25rem; }

.brand {
  display: flex; align-items: center; gap: 0.6rem;
  font-size: 0.875rem; font-weight: 600; letter-spacing: -0.02em; color: #fff;
}
.nav-link {
  display: flex; align-items: center; gap: 0.35rem;
  font-size: 0.8rem; font-weight: 500; color: rgba(255,255,255,0.75);
  text-decoration: none; padding: 0.3rem 0.6rem; border-radius: 6px;
  transition: background 0.15s, color 0.15s;
}
.nav-link:hover { background: rgba(255,255,255,0.12); color: #fff; }

.content { flex: 1; display: flex; align-items: center; justify-content: center; padding: 3rem 1.5rem; }
.empty { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; text-align: center; }
.empty-icon { margin-bottom: 0.75rem; color: #b0c8e0; }
h2 { font-size: 1rem; font-weight: 600; letter-spacing: -0.02em; color: #1e3050; }
p { font-size: 0.825rem; color: #6a84a0; }
.version-tag {
  display: inline-block; margin-top: 0.5rem;
  font-size: 0.7rem; font-weight: 500; color: #8aa0b8;
  background: #e8eef6; border: 1px solid #d0dcea;
  border-radius: 999px; padding: 0.2rem 0.6rem; letter-spacing: 0.03em;
}
</style>
