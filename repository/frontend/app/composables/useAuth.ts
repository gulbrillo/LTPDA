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

export const useAuth = () => {
  const config = useRuntimeConfig()
  const token = useState<string | null>('auth.token', () => {
    if (import.meta.client) return localStorage.getItem('auth_token')
    return null
  })
  const user = useState<User | null>('auth.user', () => null)

  const apiFetch = async <T>(path: string, options: Record<string, unknown> = {}): Promise<T> => {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string> ?? {}),
    }
    if (token.value) headers['Authorization'] = `Bearer ${token.value}`
    return $fetch<T>(`${config.public.apiBase}${path}`, { ...options, headers })
  }

  const fetchUser = async () => {
    try {
      user.value = await apiFetch<User>('/auth/me')
    } catch {
      user.value = null
    }
  }

  const login = async (username: string, password: string) => {
    const data = await $fetch<{ access_token: string }>(`${config.public.apiBase}/auth/login`, {
      method: 'POST',
      body: { username, password },
    })
    token.value = data.access_token
    if (import.meta.client) localStorage.setItem('auth_token', data.access_token)
    await fetchUser()
    await navigateTo('/dashboard')
  }

  const logout = async () => {
    try { await apiFetch('/auth/pma-token', { method: 'DELETE' }) } catch {}
    token.value = null
    user.value = null
    if (import.meta.client) localStorage.removeItem('auth_token')
    navigateTo('/login')
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

  return { token, user, login, logout, fetchUser, initFromStorage, apiFetch }
}
