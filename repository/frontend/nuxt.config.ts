import { readFileSync } from 'fs'
const { version } = JSON.parse(readFileSync('./package.json', 'utf-8'))

export default defineNuxtConfig({
  ssr: false,

  experimental: {
    payloadExtraction: false,
  },

  app: {
    pageTransition: { name: 'page' },
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
      version,
    },
  },
})
