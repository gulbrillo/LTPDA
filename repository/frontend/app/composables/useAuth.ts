interface User {
  id: number
  username: string
  first_name: string | null
  last_name: string | null
  email: string | null
  institution: string | null
  is_admin: boolean
  created_at: string
}

/** Decode the exp claim from a JWT payload without verifying the signature. */
function getTokenExpiry(token: string): number | null {
  try {
    const payload = JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')))
    return typeof payload.exp === 'number' ? payload.exp : null
  } catch {
    return null
  }
}

export const useAuth = () => {
  const config = useRuntimeConfig()
  const token = useState<string | null>('auth.token', () => {
    if (import.meta.client) return localStorage.getItem('auth_token')
    return null
  })
  const user = useState<User | null>('auth.user', () => null)
  const reAuthVisible = useState<boolean>('auth.reauth', () => false)
  const lastActivity = useState<number>('auth.lastActivity', () => 0)

  const apiFetch = async <T>(path: string, options: Record<string, unknown> = {}): Promise<T> => {
    // Track last activity so the idle timer can detect inactivity
    if (import.meta.client) lastActivity.value = Date.now()

    // Auto-refresh the token when it's within 5 minutes of expiry (15 min of token lifetime used).
    // Skipped for /auth/refresh and /auth/login to avoid recursion.
    if (token.value && !path.includes('/auth/refresh') && !path.includes('/auth/login')) {
      const exp = getTokenExpiry(token.value)
      if (exp !== null && exp * 1000 - Date.now() < 5 * 60 * 1000) {
        try {
          const refreshed = await $fetch<{ access_token: string }>(
            `${config.public.apiBase}/auth/refresh`,
            {
              method: 'POST',
              headers: { Authorization: `Bearer ${token.value}`, 'Content-Type': 'application/json' },
            },
          )
          token.value = refreshed.access_token
          if (import.meta.client) localStorage.setItem('auth_token', refreshed.access_token)
        } catch { /* continue with existing token; will get 401 if truly expired */ }
      }
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string> ?? {}),
    }
    if (token.value) headers['Authorization'] = `Bearer ${token.value}`

    try {
      return await $fetch<T>(`${config.public.apiBase}${path}`, { ...options, headers })
    } catch (e: unknown) {
      const fe = e as { status?: number; statusCode?: number }
      if ((fe.status ?? fe.statusCode) === 401 && !path.includes('/auth/login')) {
        token.value = null
        if (import.meta.client) localStorage.removeItem('auth_token')
        reAuthVisible.value = true
      }
      throw e
    }
  }

  const fetchUser = async () => {
    try {
      user.value = await apiFetch<User>('/auth/me')
    } catch {
      // Preserve user.value when a 401 triggered the re-auth dialog — the username
      // is needed to pre-fill the dialog. Only clear it on other errors (e.g. network).
      if (!reAuthVisible.value) user.value = null
    }
  }

  const login = async (username: string, password: string) => {
    const data = await $fetch<{ access_token: string }>(`${config.public.apiBase}/auth/login`, {
      method: 'POST',
      body: { username, password },
    })
    token.value = data.access_token
    if (import.meta.client) {
      localStorage.setItem('auth_token', data.access_token)
      lastActivity.value = Date.now()
    }
    await fetchUser()
    await navigateTo('/dashboard')
  }

  const logout = async () => {
    try { await apiFetch('/auth/pma-token', { method: 'DELETE' }) } catch {}
    token.value = null
    user.value = null
    reAuthVisible.value = false
    if (import.meta.client) {
      localStorage.removeItem('auth_token')
      lastActivity.value = 0
    }
    navigateTo('/login')
  }

  const reAuth = async (password: string) => {
    const username = user.value?.username
    if (!username) throw new Error('No active session')
    const isAdmin = user.value?.is_admin ?? false

    const data = await $fetch<{ access_token: string }>(`${config.public.apiBase}/auth/login`, {
      method: 'POST',
      body: { username, password },
    })
    token.value = data.access_token
    if (import.meta.client) {
      localStorage.setItem('auth_token', data.access_token)
      lastActivity.value = Date.now()
    }
    await fetchUser()

    // Re-issue the phpMyAdmin cookie so PMA keeps working after re-auth
    if (isAdmin) {
      try {
        await $fetch(`${config.public.apiBase}/auth/pma-token`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${data.access_token}`, 'Content-Type': 'application/json' },
        })
      } catch {}
    }

    reAuthVisible.value = false
  }

  /** Called by the idle timer in app.vue after 15 minutes of no API calls. */
  const triggerIdleTimeout = async () => {
    token.value = null
    if (import.meta.client) localStorage.removeItem('auth_token')
    // Best-effort: clear the phpMyAdmin cookie so PMA access also expires
    try { await $fetch(`${config.public.apiBase}/auth/pma-token`, { method: 'DELETE' }) } catch {}
    reAuthVisible.value = true
  }

  const initFromStorage = async () => {
    if (import.meta.client && !token.value) {
      const stored = localStorage.getItem('auth_token')
      if (stored) {
        token.value = stored
        await fetchUser()
      }
    }
  }

  return {
    token, user, reAuthVisible, lastActivity,
    login, logout, reAuth, fetchUser, initFromStorage, apiFetch, triggerIdleTimeout,
  }
}
