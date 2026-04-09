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
        <div class="user-field">
          <span class="user-field-name">{{ (user?.first_name && user?.last_name) ? `${user.first_name} ${user.last_name}` : user?.username }}</span>
          <button class="user-field-signout" @click="logout">Sign out</button>
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

.user-field {
  display: flex; align-items: stretch;
  border: 1px solid rgba(255,255,255,0.25); border-radius: 8px; overflow: hidden;
}
.user-field-name {
  display: flex; align-items: center;
  padding: 0.3rem 0.65rem;
  background: rgba(255,255,255,0.1);
  font-size: 0.8rem; font-weight: 500; color: rgba(255,255,255,0.75);
  white-space: nowrap; user-select: none;
}
.user-field-signout {
  display: flex; align-items: center;
  padding: 0 0.65rem;
  background: rgba(255,255,255,0.18); border: none; border-left: 1px solid rgba(255,255,255,0.25);
  font-size: 0.8rem; font-weight: 600; color: rgba(255,255,255,0.75);
  cursor: pointer; white-space: nowrap;
  transition: background 0.1s, color 0.1s;
}
.user-field-signout:hover { background: rgba(255,255,255,0.28); color: #fff; }
</style>
