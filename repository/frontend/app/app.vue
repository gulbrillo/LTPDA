<script setup lang="ts">
const route = useRoute()
const { token, reAuthVisible, triggerIdleTimeout, lastActivity } = useAuth()

const IDLE_MS = 15 * 60 * 1000  // 15 minutes

const pageTransition = {
  name: 'page',
  onLeave(el: Element) {
    const h = el as HTMLElement
    const { offsetTop, offsetLeft, offsetWidth, offsetHeight } = h
    h.style.position = 'absolute'
    h.style.top      = `${offsetTop}px`
    h.style.left     = `${offsetLeft}px`
    h.style.width    = `${offsetWidth}px`
    h.style.height   = `${offsetHeight}px`
  },
  onAfterLeave(el: Element) {
    const h = el as HTMLElement
    h.style.position = ''
    h.style.top      = ''
    h.style.left     = ''
    h.style.width    = ''
    h.style.height   = ''
  },
}

// Idle-timeout timer: checks every 30 s, triggers re-auth after 15 min of no API calls.
let idleTimer: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  idleTimer = setInterval(() => {
    if (!token.value || reAuthVisible.value) return
    if (lastActivity.value > 0 && Date.now() - lastActivity.value > IDLE_MS) {
      triggerIdleTimeout()
    }
  }, 30_000)
})

onBeforeUnmount(() => {
  if (idleTimer !== null) clearInterval(idleTimer)
})
</script>

<template>
  <NuxtLayout>
    <NuxtPage :page-key="route.path" :transition="pageTransition" />
  </NuxtLayout>
  <ReAuthModal />
</template>
