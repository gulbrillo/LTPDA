export default defineNuxtConfig({
  ssr: false,

  experimental: {
    payloadExtraction: false,
  },

  devtools: { enabled: true },

  modules: ['@primevue/nuxt-module', '@pinia/nuxt'],

  primevue: {
    options: {
      theme: 'none',
    },
  },

  css: [
    '@fontsource/inter/400.css',
    '@fontsource/inter/500.css',
    '@fontsource/inter/600.css',
    '@fontsource/inter/700.css',
    '@fontsource/inter/800.css',
    'primeicons/primeicons.css',
    '~/assets/css/main.css',
  ],

  runtimeConfig: {
    public: {
      apiBase: '/api',
    },
  },
})
