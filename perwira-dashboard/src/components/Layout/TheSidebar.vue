<!-- src/components/Layout/TheSidebar.vue -->
<script setup>
import { useAuthStore } from '@/stores/auth';
import { computed, ref } from 'vue';
import { useRouter } from 'vue-router';

// Lucide Icons
import { Home, Users, FileText, Gift, CheckCircle, LogOut, Menu } from 'lucide-vue-next';

const store = useAuthStore();
const router = useRouter();
const isMobileMenuOpen = ref(false);
const isCollapsed = ref(false);

// Toggle mobile menu
const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value;
};
const closeMobileMenu = () => {
  if (window.innerWidth <= 768) isMobileMenuOpen.value = false;
};

// Toggle collapse
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
};

// Role check
const hasAccess = (requiredRole) => {
  if (!store.user?.role) return false;
  if (!requiredRole) return true;
  const userRole = store.user.role;
  return Array.isArray(requiredRole) ? requiredRole.includes(userRole) : requiredRole === userRole;
};

const isActive = (path) => router.currentRoute.value.path === path;

const menuItems = computed(() => [
  { label: 'Dashboard', path: '/dashboard', icon: Home },
  { label: 'Users', path: '/users', icon: Users, role: 'manager' },
  { label: 'Invoices', path: '/invoices', icon: FileText, role: ['manager', 'sales'] },
  { label: 'Rewards', path: '/rewards', icon: Gift, role: ['manager', 'sales'] },
  { label: 'Redemptions', path: '/redemptions', icon: CheckCircle, role: ['manager', 'sales'] },
]);
</script>

<template>
  <!-- Mobile Header -->
  <div class="md:hidden flex items-center px-4 py-3 bg-red-600 text-white shadow-sm">
    <span class="text-lg font-semibold tracking-wide">Perwira</span>
    <button
      @click="toggleMobileMenu"
      class="ml-auto p-2 rounded hover:bg-red-700 transition shrink-0"
    >
      <Menu v-if="!isMobileMenuOpen" class="w-5 h-5" />
      <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M6 18L18 6M6 6l12 12"
        />
      </svg>
    </button>
  </div>

  <!-- Sidebar -->
  <aside
    :class="[
      'fixed md:relative z-50 inset-y-0 left-0 bg-white border-r border-gray-200 shadow-lg transform transition-all duration-300 ease-out flex flex-col',
      isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0',
      isCollapsed ? 'w-20' : 'w-64',
    ]"
  >
    <!-- Logo/Header -->
    <div
      :class="[
        'p-4 bg-red-600 text-white flex items-center',
        isCollapsed ? 'justify-center' : 'justify-between',
      ]"
    >
      <!-- Logo + Title hanya kalau tidak collapsed -->
      <div v-if="!isCollapsed" class="flex items-center gap-3">
        <img src="/logopth.png" alt="Logo" class="h-8 w-auto" />
        <h2 class="text-lg font-bold whitespace-nowrap">Perwira Steel</h2>
      </div>

      <!-- Tombol collapse -->
      <button
        @click="toggleCollapse"
        class="w-10 h-10 flex items-center justify-center rounded hover:bg-red-700 transition shrink-0"
      >
        <Menu class="w-5 h-5 text-white" />
      </button>
    </div>

    <!-- Navigation -->
    <nav class="p-4 flex-1 overflow-y-auto">
      <ul class="space-y-1">
        <li v-for="item in menuItems" :key="item.path">
          <router-link
            v-if="hasAccess(item.role)"
            :to="item.path"
            @click="closeMobileMenu"
            :class="[
              'flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 group',
              isActive(item.path)
                ? 'bg-red-600 text-white shadow-sm'
                : 'text-gray-700 hover:bg-red-50 hover:text-red-600',
              isCollapsed ? 'justify-center' : 'space-x-3',
            ]"
          >
            <component
              :is="item.icon"
              class="w-5 h-5 flex-shrink-0"
              :class="[
                isActive(item.path) ? 'text-white' : 'text-gray-600 group-hover:text-red-600',
              ]"
            />
            <span v-if="!isCollapsed">{{ item.label }}</span>
          </router-link>
        </li>
      </ul>
    </nav>

    <!-- Logout -->
    <div class="p-4 border-t border-gray-100 bg-gray-50">
      <button
        @click="
          store.logout();
          $router.push('/login');
        "
        :class="[
          'flex items-center w-full px-3 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg transition-all group cursor-pointer',
          isCollapsed ? 'justify-center' : 'space-x-3',
        ]"
      >
        <LogOut class="w-5 h-5 text-red-600 group-hover:text-red-700" />
        <span v-if="!isCollapsed">Logout</span>
      </button>
    </div>
  </aside>

  <!-- Overlay -->
  <div
    v-if="isMobileMenuOpen"
    @click="toggleMobileMenu"
    class="md:hidden fixed inset-0 bg-black/30 backdrop-blur-sm z-40"
  ></div>
</template>
