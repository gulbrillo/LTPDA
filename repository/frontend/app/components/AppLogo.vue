<script setup lang="ts">
import { DatabaseZap } from 'lucide-vue-next'
withDefaults(defineProps<{ size?: number, dark?: boolean }>(), { size: 24, dark: false })
</script>

<template>
  <DatabaseZap :size="size" :color="dark ? '#2f5596' : 'white'" />
</template>
