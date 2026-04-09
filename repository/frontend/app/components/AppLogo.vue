<script setup lang="ts">
import { CircuitBoard } from 'lucide-vue-next'
withDefaults(defineProps<{ size?: number }>(), { size: 24 })
</script>

<template>
  <CircuitBoard :size="size" color="white" />
</template>
