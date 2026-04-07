<script setup lang="ts">
withDefaults(defineProps<{
  size?: number
  variant?: 'light' | 'dark'
}>(), { size: 20, variant: 'light' })
</script>

<template>
  <svg :width="size" :height="size" viewBox="0 0 20 20" fill="none">
    <rect
      width="20" height="20" rx="5"
      :fill="variant === 'dark' ? 'rgba(255,255,255,0.15)' : '#2f5596'"
      :stroke="variant === 'dark' ? 'rgba(255,255,255,0.25)' : 'none'"
      stroke-width="1"
    />
    <path d="M5 10c0-2.761 2.239-5 5-5s5 2.239 5 5" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
    <circle cx="10" cy="13" r="1.75" fill="white"/>
  </svg>
</template>
