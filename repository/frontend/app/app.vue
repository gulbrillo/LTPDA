<script setup lang="ts">
const route = useRoute()

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
</script>

<template>
  <NuxtLayout>
    <NuxtPage :page-key="route.path" :transition="pageTransition" />
  </NuxtLayout>
</template>
