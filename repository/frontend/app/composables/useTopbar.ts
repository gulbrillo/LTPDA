// Module-level ref persists across the app (SPA — single instance).
// Pages call setTitle() to control what the persistent topbar shows:
//   null  → brand mode  (logo + "LTPDA Repository", no back-link)
//   string → breadcrumb (logo → /dashboard link / current page title)

const _title = ref<string | null>(null)

export function useTopbar() {
  return {
    title: _title as Ref<string | null>,
    setTitle: (t: string | null) => { _title.value = t },
  }
}
