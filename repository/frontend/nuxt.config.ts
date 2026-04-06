export default defineNuxtConfig({
  ssr: false,

  devtools: { enabled: true },

  modules: ['@primevue/nuxt-module', '@pinia/nuxt'],

  primevue: {
    options: {
      theme: 'none',
    },
  },

  css: ['primeicons/primeicons.css'],

  runtimeConfig: {
    public: {
      apiBase: '/api',
    },
  },
})
