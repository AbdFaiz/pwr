<script setup>
import { onMounted, ref } from 'vue';
import { useAuthStore } from '@/stores/auth';
import api from '@/services/api';

// Lucide Icons
import { Users, FileText, Gift, CheckCircle } from 'lucide-vue-next';

const authStore = useAuthStore();

const stats = ref([
  { label: 'Total Users', value: null, icon: Users, color: 'bg-red-500' },
  { label: 'Invoices Pending', value: null, icon: FileText, color: 'bg-red-600' },
  { label: 'Total Rewards', value: null, icon: Gift, color: 'bg-red-700' },
  { label: 'Redemptions', value: null, icon: CheckCircle, color: 'bg-red-800' },
]);

onMounted(async () => {
  try {
    const res = await api.get('/dashboard-stats');
    // pastikan responsenya sesuai
    stats.value[0].value = res.data.total_users ?? 0;
    stats.value[1].value = res.data.invoices_pending ?? 0;
    stats.value[2].value = res.data.total_rewards ?? 0;
    stats.value[3].value = res.data.redemptions ?? 0;
  } catch (err) {
    // fallback kalau API error
    stats.value.forEach((s) => (s.value = 0));
  }
});
</script>

<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold mb-8 text-gray-800">Dashboard</h1>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
      <div
        v-for="(stat, index) in stats"
        :key="index"
        class="bg-white rounded-2xl shadow-md p-6 flex items-center hover:shadow-lg transition"
      >
        <div :class="['p-3 rounded-xl text-white flex items-center justify-center', stat.color]">
          <component :is="stat.icon" class="w-6 h-6" />
        </div>
        <div class="ml-4">
          <p class="text-gray-500 text-sm">{{ stat.label }}</p>
          <p class="text-3xl font-bold text-gray-900">
            {{ stat.value ?? 0 }}
          </p>
        </div>
      </div>
    </div>

    <!-- Welcome Card -->
    <div class="bg-white rounded-2xl shadow-md p-6">
      <h2 class="text-2xl font-semibold mb-2 text-gray-800">
        Selamat datang, {{ authStore.user?.name ?? 'User' }}!
      </h2>
      <p class="text-gray-600">
        Anda login sebagai <strong>{{ authStore.user?.role ?? 'Guest' }}</strong
        >. Gunakan menu di kiri untuk mengelola sistem.
      </p>
    </div>
  </div>
</template>
