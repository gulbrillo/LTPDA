export default defineNuxtRouteMiddleware(async (to) => {
  // Public routes that never require auth
  if (to.path === '/setup' || to.path === '/login') return

  const config = useRuntimeConfig()

  // Check if server is configured; redirect to /setup if not
  try {
    const status = await $fetch<{ configured: boolean }>(`${config.public.apiBase}/setup/status`)
    if (!status.configured) return navigateTo('/setup')
  } catch {
    return navigateTo('/setup')
  }

  // Check auth token
  const { token, fetchUser, user } = useAuth()

  if (import.meta.client && !token.value) {
    const stored = localStorage.getItem('auth_token')
    if (stored) token.value = stored
  }

  if (!token.value) return navigateTo('/login')

  if (!user.value) await fetchUser()
  if (!user.value) return navigateTo('/login')
})
