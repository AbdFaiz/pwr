<!-- src/views/Rewards/RewardForm.vue -->
<script setup>
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { Eye } from 'lucide-vue-next';
import api from '@/services/api';
import { useToast } from 'vue-toastification';
import Card from '@/components/UI/Card.vue';
import Button from '@/components/UI/Button.vue';

const toast = useToast();
const router = useRouter();
const route = useRoute();

const form = ref({
  name: '',
  description: '',
  points_required: '',
  image: null,
});

const previewImage = ref(null);
const modalVisible = ref(false);
const errors = ref({});
const loading = ref(false);
const isEdit = ref(false);

const apiBase = api.defaults?.baseURL || '';
const baseUrl = apiBase ? apiBase.replace(/\/api\/?$/i, '') : window.location.origin;

const formatImage = (src) => {
  if (!src) return null;
  if (src.startsWith('data:')) return src;
  if (/^https?:\/\//i.test(src)) return src;
  const clean = src.replace(/^\/+/, '');
  if (clean.startsWith('storage/')) return `${baseUrl}/${clean}`;
  return `${baseUrl}/storage/${clean}`;
};

// --- Load data ketika edit ---
onMounted(async () => {
  if (!route.params.id) return;
  isEdit.value = true;

  try {
    const res = await api.get(`/rewards/${route.params.id}`);
    const reward = res.data?.data ?? res.data;

    form.value.name = reward.name ?? '';
    form.value.description = reward.description ?? '';
    form.value.points_required = reward.points_required ?? '';

    if (reward.image_url) {
      previewImage.value = formatImage(reward.image_url);
    }
  } catch (err) {
    console.error('❌ Gagal memuat reward:', err);
    toast.error('Gagal memuat data reward.');
    router.push('/rewards');
  }
});

// --- Handle Upload ---
const handleImageChange = (e) => {
  const file = e.target.files?.[0];
  if (!file) return;
  form.value.image = file;

  const reader = new FileReader();
  reader.onload = (ev) => (previewImage.value = ev.target.result);
  reader.readAsDataURL(file);
};

const clearImage = () => {
  form.value.image = null;
  previewImage.value = null;
};

// --- Submit ---
const submit = async () => {
  loading.value = true;
  errors.value = {};

  const url = isEdit.value ? `/rewards/${route.params.id}` : '/rewards';
  const formData = new FormData();
  formData.append('name', form.value.name);
  formData.append('description', form.value.description);
  formData.append('points_required', form.value.points_required);

  if (form.value.image) {
    formData.append('image', form.value.image);
  }

  if (isEdit.value) formData.append('_method', 'PUT');

  try {
    await api.post(url, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    toast.success(isEdit.value ? 'Reward berhasil diperbarui.' : 'Reward berhasil dibuat.');
    router.push('/rewards');
  } catch (err) {
    if (err.response?.data?.errors) {
      errors.value = err.response.data.errors;
    } else {
      toast.error(err.response?.data?.message || 'Terjadi kesalahan server.');
    }
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="p-6">
    <Card :title="isEdit ? 'Edit Reward' : 'Tambah Reward Baru'">
      <form @submit.prevent="submit" class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Nama Reward -->
          <div>
            <label class="font-medium text-slate-700">Nama Reward</label>
            <input
              v-model="form.name"
              type="text"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              required
            />
            <p v-if="errors.name" class="text-red-500 text-sm mt-1">{{ errors.name[0] }}</p>
          </div>

          <!-- Poin Dibutuhkan -->
          <div>
            <label class="font-medium text-slate-700">Poin yang Dibutuhkan</label>
            <input
              v-model="form.points_required"
              type="number"
              min="1"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              required
            />
            <p v-if="errors.points_required" class="text-red-500 text-sm mt-1">
              {{ errors.points_required[0] }}
            </p>
          </div>

          <!-- Upload Gambar -->
          <div class="md:col-span-2">
            <label class="font-medium text-slate-700">Gambar Reward</label>
            <div class="flex flex-col gap-3 mt-1">
              <div class="flex items-center gap-3">
                <label
                  class="bg-red-600 text-white px-4 py-2 rounded-xl cursor-pointer hover:bg-red-700 transition inline-block"
                >
                  Pilih Gambar
                  <input type="file" accept="image/*" @change="handleImageChange" class="hidden" />
                </label>

                <button
                  v-if="previewImage"
                  type="button"
                  @click="clearImage"
                  class="px-3 py-2 text-slate-600 border border-slate-300 rounded-xl hover:bg-slate-100 transition text-sm"
                >
                  Hapus
                </button>
              </div>

              <p v-if="errors.image" class="text-red-500 text-sm mt-1">{{ errors.image[0] }}</p>

              <div
                v-if="previewImage"
                class="mt-3 relative group w-full max-w-xs aspect-square overflow-hidden rounded-xl border border-slate-200 shadow-sm"
              >
                <img
                  :src="formatImage(previewImage)"
                  alt="Preview"
                  class="w-full h-full object-cover"
                />

                <!-- Hover Eye Icon -->
                <div
                  class="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 flex items-center justify-center transition"
                >
                  <button
                    type="button"
                    @click="modalVisible = true"
                    class="bg-white/90 p-3 rounded-full shadow hover:bg-white"
                  >
                    <Eye class="w-6 h-6 text-slate-700" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Deskripsi -->
        <div>
          <label class="font-medium text-slate-700">Deskripsi</label>
          <textarea
            v-model="form.description"
            rows="4"
            class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
            placeholder="Jelaskan reward ini..."
          ></textarea>
          <p v-if="errors.description" class="text-red-500 text-sm mt-1">
            {{ errors.description[0] }}
          </p>
        </div>

        <!-- Buttons -->
        <div class="flex justify-end space-x-3 pt-4">
          <Button
            type="button"
            @click="router.back()"
            class="px-4 py-2 border border-slate-300 rounded-xl text-slate-600 hover:bg-slate-100 transition cursor-pointer"
          >
            Batal
          </Button>
          <Button
            :disabled="loading"
            type="submit"
            class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-xl cursor-pointer"
          >
            {{ loading ? (isEdit ? 'Menyimpan...' : 'Membuat...') : isEdit ? 'Simpan' : 'Buat' }}
          </Button>
        </div>
      </form>
    </Card>

    <!-- Modal Preview -->
    <div
      v-if="modalVisible"
      class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center"
      @click.self="modalVisible = false"
    >
      <div class="relative">
        <img
          :src="formatImage(previewImage)"
          alt="Full preview"
          class="max-w-[90vw] max-h-[85vh] rounded-xl shadow-lg object-contain"
        />
        <button
          @click="modalVisible = false"
          class="absolute top-3 right-3 bg-white/90 p-2 rounded-full hover:bg-white"
        >
          ✕
        </button>
      </div>
    </div>
  </div>
</template>
