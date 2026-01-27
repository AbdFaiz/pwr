<!-- src/App.vue -->
<script setup>
import TheSidebar from './components/Layout/TheSidebar.vue';
import { RouterView } from 'vue-router';
import { useAuthStore } from './stores/auth';

const store = useAuthStore();
</script>

<template>
  <!-- Login Page -->
  <div
    v-if="$route.path === '/login'"
    class="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 px-4"
  >
    <div class="w-full">
      <RouterView />
    </div>
  </div>

  <!-- Dashboard -->
  <div v-else class="flex min-h-screen bg-gray-50">
    <TheSidebar v-if="store.isAuthenticated" />

    <main :class="['flex-1 transition-all duration-300 ease-in-out']">
      <RouterView />
    </main>
  </div>
</template>
