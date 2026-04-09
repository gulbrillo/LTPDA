<script setup lang="ts">
const route = useRoute()
</script>

<template>
  <NuxtLayout>
    <Transition name="page" mode="out-in">
      <NuxtPage :key="route.path" />
    </Transition>
  </NuxtLayout>
</template>
