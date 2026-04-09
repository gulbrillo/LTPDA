<script setup lang="ts">
import { LayoutDashboard, Database, Users, Settings } from 'lucide-vue-next'
const { user, logout } = useAuth()
const { title } = useTopbar()
</script>

<template>
  <div class="page">

    <nav class="topbar">
      <!-- Brand (dashboard) vs breadcrumb (all other pages) -->
      <div v-if="title === null" class="brand">
        <AppLogo :size="22" />
        <span>LTPDA Repository</span>
      </div>
      <div v-else class="breadcrumb">
        <AppLogo :size="20" class="logo-mark" />
        <NuxtLink to="/dashboard" class="bc-link">LTPDA Repository</NuxtLink>
        <span class="bc-sep">/</span>
        <span class="bc-current">{{ title }}</span>
      </div>

      <div class="nav-right">
        <NuxtLink to="/dashboard" class="nav-link">
          <LayoutDashboard :size="14" />
          Dashboard
        </NuxtLink>
        <template v-if="user?.is_admin">
          <NuxtLink to="/admin/repos" class="nav-link">
            <Database :size="14" />
            Repositories
          </NuxtLink>
          <NuxtLink to="/admin/users" class="nav-link">
            <Users :size="14" />
            Users
          </NuxtLink>
          <NuxtLink to="/admin/settings" class="nav-link">
            <Settings :size="14" />
            Settings
          </NuxtLink>
        </template>
        <div class="user-pill">
          <span class="avatar">{{ user?.username?.[0]?.toUpperCase() }}</span>
          <span class="uname">{{ user?.username }}</span>
          <span v-if="user?.is_admin" class="admin-dot" title="Administrator" />
          <span class="pill-sep" />
          <button class="pill-signout" @click="logout">Sign out</button>
        </div>
      </div>
    </nav>

    <slot />

  </div>
</template>

<style scoped>
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
.nav-link.router-link-exact-active { background: rgba(255,255,255,0.18); color: #fff; }

.user-pill {
  display: flex; align-items: center; gap: 0.45rem;
  padding: 0.22rem 0 0.22rem 0.28rem;
  background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.2);
  border-radius: 999px; position: relative;
}
.pill-sep {
  width: 1px; height: 16px;
  background: rgba(255,255,255,0.25); flex-shrink: 0;
}
.pill-signout {
  font-size: 0.8rem; font-weight: 500; color: rgba(255,255,255,0.75);
  background: none; border: none; cursor: pointer;
  padding: 0.1rem 0.65rem 0.1rem 0.4rem;
  border-radius: 0 999px 999px 0;
  transition: background 0.12s, color 0.12s;
}
.pill-signout:hover { background: rgba(255,255,255,0.12); color: #fff; }
</style>
