<script setup lang="ts">
import { Network } from 'lucide-vue-next'
withDefaults(defineProps<{ size?: number }>(), { size: 24 })
</script>

<template>
  <Network :size="size" color="white" />
</template>
