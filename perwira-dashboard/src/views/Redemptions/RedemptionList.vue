<script setup>
import { onMounted, ref } from 'vue';
import api from '@/services/api';
import { useAuthStore } from '@/stores/auth';
import Button from '@/components/UI/Button.vue';
import Card from '@/components/UI/Card.vue';
import { Loader2 } from 'lucide-vue-next';
import { useToast } from 'vue-toastification';

const authStore = useAuthStore();
const toast = useToast();

const redemptions = ref({ data: [], links: [] });
const loading = ref(true);
const error = ref(null);
const search = ref('');
const startDate = ref('');
const endDate = ref('');

onMounted(async () => {
  await loadRedemptions();
});

const loadRedemptions = async () => {
  try {
    const params = {
      search: search.value,
      start_date: startDate.value,
      end_date: endDate.value,
    };

    const queryString = new URLSearchParams(params).toString();
    const url = `/redemptions${queryString ? '?' + queryString : ''}`;

    const res = await api.get(url);
    redemptions.value = res.data || { data: [], links: [] };
  } catch (err) {
    error.value = err.response?.data?.message || 'Gagal memuat data penukaran.';
    redemptions.value = { data: [], links: [] };
    toast.error(error.value);
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="p-6 space-y-6">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <h2 class="text-2xl font-bold text-slate-800 flex items-center gap-2">
        Daftar Penukaran Reward
      </h2>
    </div>

    <!-- Filter -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 bg-white p-4 rounded-xl shadow-sm">
      <input
        v-model="search"
        type="text"
        placeholder="Cari nama atau reward..."
        class="px-4 py-2 rounded-lg border border-slate-300 focus:ring-2 focus:ring-red-500 focus:outline-none"
      />
      <input
        v-model="startDate"
        type="date"
        class="px-4 py-2 rounded-lg border border-slate-300 focus:ring-2 focus:ring-red-500 focus:outline-none"
      />
      <input
        v-model="endDate"
        type="date"
        class="px-4 py-2 rounded-lg border border-slate-300 focus:ring-2 focus:ring-red-500 focus:outline-none"
      />
      <Button
        class="bg-red-600 hover:bg-red-700 text-white font-medium px-4 py-2 rounded-lg transition"
        @click="loadRedemptions"
      >
        Filter
      </Button>
    </div>

    <!-- Error -->
    <div v-if="error" class="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded-lg">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-12 text-slate-600">
      <Loader2 class="w-6 h-6 animate-spin mr-2" />
      Memuat data...
    </div>

    <!-- Table -->
    <div v-else class="bg-white rounded-xl shadow-md overflow-hidden">
      <table class="min-w-full divide-y divide-slate-200">
        <thead class="bg-slate-50">
          <tr class="text-slate-600 text-sm uppercase tracking-wide">
            <th class="px-6 py-3 text-left font-semibold">Customer</th>
            <th class="px-6 py-3 text-left font-semibold">Reward</th>
            <th class="px-6 py-3 text-left font-semibold">Poin</th>
            <th class="px-6 py-3 text-left font-semibold">Tanggal</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr v-for="r in redemptions.data" :key="r.id" class="hover:bg-slate-50 transition-colors">
            <td class="px-6 py-3 text-slate-800 font-medium">
              <span v-if="authStore.user?.role !== 'customer'">{{ r.user?.name }}</span>
              <span v-else>-</span>
            </td>
            <td class="px-6 py-3 text-slate-700">{{ r.reward?.name }}</td>
            <td class="px-6 py-3 text-slate-700">{{ r.points_used }} poin</td>
            <td class="px-6 py-3 text-slate-700">
              {{ new Date(r.created_at).toLocaleDateString() }}
            </td>
          </tr>

          <tr v-if="redemptions.data.length === 0">
            <td colspan="4" class="px-6 py-8 text-center text-slate-500">
              Tidak ada data penukaran ditemukan.
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div
      v-if="!loading && redemptions.links && Array.isArray(redemptions.links)"
      class="flex flex-wrap gap-2 mt-6 justify-center text-sm"
    >
      <a
        v-for="link in redemptions.links.filter((l) => l.url)"
        :key="link.label"
        v-html="link.label"
        href="#"
        @click.prevent="$router.push(link.url.replace('/api', ''))"
        :class="[
          'px-3 py-1.5 rounded-lg transition',
          link.active
            ? 'bg-red-600 text-white shadow'
            : 'bg-slate-100 hover:bg-slate-200 text-slate-700',
        ]"
      ></a>
    </div>
  </div>
</template>
