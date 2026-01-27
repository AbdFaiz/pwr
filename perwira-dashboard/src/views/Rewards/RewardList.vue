<!-- src/views/Rewards/RewardList.vue -->
<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';
import Button from '@/components/UI/Button.vue';
import Card from '@/components/UI/Card.vue';
import { useToast } from 'vue-toastification';
import { Eye, Edit, Trash2 } from 'lucide-vue-next';

const rewards = ref({ data: [], links: [] });
const loading = ref(true);
const error = ref(null);
const search = ref('');
const router = useRouter();
const toast = useToast();

const previewImage = ref(null);

const loadRewards = async () => {
  loading.value = true;
  error.value = null;
  try {
    const res = await api.get('/rewards');
    rewards.value = res.data;
  } catch (err) {
    error.value = err.response?.data?.message || 'Gagal memuat data rewards.';
  } finally {
    loading.value = false;
  }
};

onMounted(loadRewards);

const filteredRewards = computed(() => {
  if (!rewards.value?.data) return [];
  return rewards.value.data.filter((r) =>
    r.name.toLowerCase().includes(search.value.toLowerCase())
  );
});

const handleDelete = async (id) => {
  if (!confirm('Yakin ingin menghapus reward ini?')) return;

  try {
    await api.delete(`/rewards/${id}`);
    toast.success('Reward berhasil dihapus.');
    await loadRewards();
  } catch (err) {
    toast.error(err.response?.data?.message || 'Gagal menghapus reward.');
  }
};
</script>

<template>
  <div class="p-6 space-y-6">
    <div class="flex justify-between items-center">
      <h2 class="text-2xl font-bold text-slate-800">Manajemen Reward</h2>
      <RouterLink to="/rewards/create">
        <Button
          class="bg-red-600 hover:bg-red-700 text-white font-medium px-4 py-2 rounded-lg flex items-center gap-2 cursor-pointer"
        >
          + Tambah Reward
        </Button>
      </RouterLink>
    </div>

    <!-- Error -->
    <div v-if="error" class="bg-red-50 border border-red-400 text-red-700 px-4 py-3 rounded-lg">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-12 text-slate-600">Memuat data...</div>

    <!-- Table -->
    <div v-else class="bg-white rounded-xl shadow-md overflow-hidden border border-slate-200">
      <table class="min-w-full divide-y divide-slate-200">
        <thead class="bg-slate-50 text-slate-700 uppercase text-sm">
          <tr>
            <th class="px-6 py-3 text-left font-semibold">Gambar</th>
            <th class="px-6 py-3 text-left font-semibold">Nama</th>
            <th class="px-6 py-3 text-left font-semibold">Deskripsi</th>
            <th class="px-6 py-3 text-left font-semibold">Poin</th>
            <th class="px-6 py-3 text-left font-semibold">Aksi</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr
            v-for="reward in filteredRewards"
            :key="reward.id"
            class="hover:bg-slate-50 transition"
          >
            <td class="px-6 py-3">
              <div
                class="relative group w-16 h-16 rounded-lg overflow-hidden border border-slate-200"
              >
                <img
                  v-if="reward.image_url"
                  :src="reward.image_url"
                  alt="Reward Image"
                  class="w-full h-full object-cover"
                />
                <div
                  v-else
                  class="w-full h-full flex items-center justify-center bg-slate-100 text-slate-400 text-xs"
                >
                  Tidak ada
                </div>

                <!-- Hover Eye -->
                <div
                  v-if="reward.image_url"
                  class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition cursor-pointer"
                  @click="previewImage = reward.image_url"
                >
                  <Eye class="w-5 h-5 text-white" />
                </div>
              </div>
            </td>
            <td class="px-6 py-3 font-medium text-slate-800">
              {{ reward.name }}
            </td>
            <td class="px-6 py-3 text-slate-600 text-sm max-w-xs truncate">
              {{ reward.description }}
            </td>
            <td class="px-6 py-3 text-slate-700">{{ reward.points_required }} poin</td>
            <td class="px-6 py-3 flex gap-2">
              <RouterLink :to="`/rewards/${reward.id}/edit`">
                <button
                  class="flex items-center gap-1 px-3 py-1.5 rounded-lg text-slate-700 bg-slate-100 hover:bg-slate-200 transition"
                >
                  <Edit class="w-4 h-8" />
                </button>
              </RouterLink>
              <button
                class="flex items-center gap-1 px-3 py-1.5 rounded-lg text-white bg-red-600 hover:bg-red-700 transition"
                @click="handleDelete(reward.id)"
              >
                <Trash2 class="w-4 h-8" />
              </button>
            </td>
          </tr>

          <tr v-if="filteredRewards.length === 0">
            <td colspan="5" class="text-center py-8 text-slate-500">Tidak ada reward ditemukan.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div
      v-if="!loading && rewards.links?.length"
      class="flex flex-wrap gap-2 mt-6 justify-center text-sm"
    >
      <a
        v-for="link in rewards.links.filter((l) => l.url)"
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

    <!-- Modal Preview -->
    <div
      v-if="previewImage"
      class="fixed inset-0 bg-black/60 flex items-center justify-center z-50"
      @click.self="previewImage = null"
    >
      <div class="relative bg-white p-3 rounded-xl shadow-lg max-w-lg w-full">
        <img :src="previewImage" alt="Preview" class="w-full h-auto rounded-lg" />
        <button
          class="absolute -top-3 -right-3 bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center shadow cursor-pointer"
          @click="previewImage = null"
        >
          ✕
        </button>
      </div>
    </div>
  </div>
</template>
