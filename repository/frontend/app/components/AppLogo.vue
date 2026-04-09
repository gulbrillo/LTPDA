<script setup lang="ts">
withDefaults(defineProps<{
  size?: number
}>(), { size: 24 })
</script>

<template>
  <img
    src="~/assets/img/logo.webp"
    :width="size"
    :height="size"
    alt="LTPDA"
    style="display:block; object-fit:contain;"
  />
</template>
