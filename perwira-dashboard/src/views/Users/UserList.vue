<script setup>
import { onMounted, ref } from 'vue';
import api from '@/services/api';
import Button from '@/components/UI/Button.vue';
import Card from '@/components/UI/Card.vue';
import { useToast } from 'vue-toastification';

// Lucide Icons
import { UserPlus, Edit, Trash2, Loader2 } from 'lucide-vue-next';

const toast = useToast();
const users = ref({ data: [], links: [] });
const loading = ref(true);
const error = ref(null);
const showModal = ref(false);
const selectedUser = ref(null);

onMounted(async () => {
  await loadUsers();
});

const loadUsers = async () => {
  try {
    const res = await api.get('/users');
    users.value = res.data.data || { data: [], links: [] };
    console.log(users.value);
  } catch (err) {
    error.value = err.response?.data?.message || 'Gagal memuat data user.';
    users.value = { data: [], links: [] };
  } finally {
    loading.value = false;
  }
};

const confirmDelete = (user) => {
  selectedUser.value = user;
  showModal.value = true;
};

const handleDelete = async () => {
  if (!selectedUser.value) return;
  try {
    await api.delete(`/users/${selectedUser.value.id}`);
    await loadUsers();
    closeModal();
    toast.success('Berhasil menghapus user');
  } catch (err) {
    toast.error(err.response?.data?.message || 'Gagal menghapus.');
  }
};

const closeModal = () => {
  showModal.value = false;
  selectedUser.value = null;
};
</script>

<template>
  <div class="p-6 space-y-6">
    <div class="flex justify-between items-center">
      <h2 class="text-2xl font-bold text-slate-800 flex items-center gap-2">Manajemen Pengguna</h2>
      <RouterLink to="/users/create">
        <Button
          class="bg-red-600 hover:bg-red-700 text-white font-medium px-4 py-2 rounded-lg flex items-center gap-2 cursor-pointer"
        >
          <UserPlus class="w-4 h-4" /> Tambah User
        </Button>
      </RouterLink>
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
            <th class="px-6 py-3 text-left font-semibold">Nama</th>
            <th class="px-6 py-3 text-left font-semibold">Email</th>
            <th class="px-6 py-3 text-left font-semibold">No. Telp</th>
            <th class="px-6 py-3 text-left font-semibold">Role</th>
            <th class="px-6 py-3 text-left font-semibold">Sales Code</th>
            <th class="px-6 py-3 text-left font-semibold">Aksi</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr v-for="user in users.data" :key="user.id" class="hover:bg-slate-50 transition-colors">
            <td class="px-6 py-3 text-slate-800 font-medium">{{ user.name }}</td>
            <td class="px-6 py-3 text-slate-600">{{ user.email }}</td>
            <td class="px-6 py-3 text-slate-600">{{ user.phone || '-' }}</td>
            <td class="px-6 py-3">
              <span
                class="px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-800 capitalize"
              >
                {{ user.role }}
              </span>
            </td>
            <td class="px-6 py-3 text-slate-600">{{ user.sales_code || '-' }}</td>
            <td class="px-6 py-3 flex gap-2">
              <RouterLink :to="`/users/${user.id}/edit`">
                <Button
                  class="flex items-center gap-1 px-3 py-1.5 rounded-lg text-slate-700 bg-slate-100 hover:bg-slate-200 transition"
                >
                  <Edit class="w-4 h-4" />
                </Button>
              </RouterLink>
              <Button
                class="flex items-center gap-1 px-3 py-1.5 rounded-lg text-white bg-red-600 hover:bg-red-700 transition"
                @click="confirmDelete(user)"
              >
                <Trash2 class="w-4 h-4" />
              </Button>
            </td>
          </tr>

          <tr v-if="users.data.length === 0">
            <td colspan="5" class="px-6 py-8 text-center text-slate-500">
              Tidak ada user ditemukan.
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div v-if="users.links" class="flex flex-wrap gap-2 mt-6 justify-center text-sm">
      <a
        v-for="link in users.links.filter((l) => l.url)"
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

    <!-- Modal konfirmasi -->
    <div
      v-if="showModal"
      class="fixed inset-0 flex items-center justify-center bg-black/60 backdrop-blur-sm z-50"
    >
      <div class="bg-white rounded-xl shadow-xl p-6 w-full max-w-md">
        <h2 class="text-xl font-semibold text-slate-800 mb-4 flex items-center gap-2">
          <Trash2 class="w-5 h-5 text-red-600" /> Konfirmasi Hapus
        </h2>
        <p class="text-slate-600 mb-6">
          Apakah Anda yakin ingin menghapus user
          <span class="font-semibold text-slate-900">{{ selectedUser?.name }}</span
          >?
        </p>
        <div class="flex justify-end gap-3">
          <Button
            class="px-4 py-2 rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200 transition"
            @click="closeModal"
          >
            Batal
          </Button>
          <Button
            class="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 transition"
            @click="handleDelete"
          >
            Hapus
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>
