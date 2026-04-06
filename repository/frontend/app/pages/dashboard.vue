<script setup lang="ts">
const { user, logout } = useAuth()
</script>

<template>
  <div class="page">
    <header class="topbar">
      <span class="brand">LTPDA Repository</span>
      <div class="user-area">
        <span class="username">{{ user?.username }}</span>
        <span v-if="user?.is_admin" class="badge">Admin</span>
        <NuxtLink v-if="user?.is_admin" to="/admin/users" class="nav-link">Users</NuxtLink>
        <button class="btn-logout" @click="logout">Sign out</button>
      </div>
    </header>

    <main class="content">
      <div class="empty-state">
        <div class="empty-icon">🗄️</div>
        <h2>No repositories yet</h2>
        <p>Repository management will be available in a future release.</p>
        <p class="version">LTPDA Repository v3.0</p>
      </div>
    </main>
  </div>
</template>

<style scoped>
.page { min-height: 100vh; display: flex; flex-direction: column; background: #f8fafc; }
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.5rem;
  height: 56px;
  background: white;
  border-bottom: 1px solid #e5e7eb;
}
.brand { font-weight: 600; font-size: 1rem; color: #111; }
.user-area { display: flex; align-items: center; gap: 1rem; font-size: 0.875rem; }
.username { color: #374151; }
.badge {
  background: #dbeafe;
  color: #1d4ed8;
  padding: 0.1rem 0.5rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
}
.nav-link { color: #2563eb; text-decoration: none; }
.nav-link:hover { text-decoration: underline; }
.btn-logout {
  padding: 0.35rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  font-size: 0.875rem;
  color: #374151;
}
.btn-logout:hover { background: #f9fafb; }
.content { flex: 1; display: flex; align-items: center; justify-content: center; }
.empty-state { text-align: center; color: #6b7280; }
.empty-icon { font-size: 3rem; margin-bottom: 1rem; }
h2 { font-size: 1.25rem; color: #111827; margin: 0 0 0.5rem; }
p { margin: 0.25rem 0; font-size: 0.9rem; }
.version { font-size: 0.75rem; color: #9ca3af; margin-top: 0.75rem; }
</style>
