<!-- src/views/Users/UserForm.vue -->
<script setup>
import { ref, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import api from '@/services/api';
import { useToast } from 'vue-toastification';
import Card from '@/components/UI/Card.vue';
import Button from '@/components/UI/Button.vue';

const toast = useToast();
const router = useRouter();
const route = useRoute();

const form = ref({
  name: '',
  phone: '',
  address: '',
  email: '',
  password: '',
  password_confirmation: '',
  role: 'customer',
  sales_code: '',
});

const errors = ref({});
const loading = ref(false);
const isEdit = ref(false);
const userId = ref(null);

onMounted(async () => {
  if (route.params.id) {
    isEdit.value = true;
    userId.value = route.params.id;

    try {
      const res = await api.get(`/users/${userId.value}`);
      const user = res.data.data;

      form.value = {
        name: user.name || '',
        phone: user.phone || '',
        address: user.address || '',
        email: user.email || '',
        password: '',
        password_confirmation: '',
        role: user.role || 'customer',
        sales_code: user.sales_code || '',
      };
    } catch (err) {
      toast.error('Gagal memuat data user.');
      router.push('/users');
    }
  }
});

const submit = async () => {
  loading.value = true;
  errors.value = {};

  const url = isEdit.value ? `/users/${userId.value}` : '/users';
  const method = isEdit.value ? 'put' : 'post';

  try {
    await api[method](url, form.value);
    toast.success(isEdit.value ? 'User berhasil diperbarui.' : 'User berhasil dibuat.');
    router.push('/users');
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
    <Card :title="isEdit ? 'Edit User' : 'Tambah User Baru'">
      <form @submit.prevent="submit" class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Nama Lengkap -->
          <div>
            <label class="font-medium text-slate-700">Nama Lengkap</label>
            <input
              v-model="form.name"
              type="text"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              required
            />
            <p v-if="errors.name" class="text-red-500 text-sm mt-1">{{ errors.name[0] }}</p>
          </div>

          <!-- Telepon -->
          <div>
            <label class="font-medium text-slate-700">Telepon (Opsional)</label>
            <input
              v-model="form.phone"
              type="text"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
            />
            <p v-if="errors.phone" class="text-red-500 text-sm mt-1">{{ errors.phone[0] }}</p>
          </div>

          <!-- Email -->
          <div>
            <label class="font-medium text-slate-700">Email</label>
            <input
              v-model="form.email"
              type="email"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              required
            />
            <p v-if="errors.email" class="text-red-500 text-sm mt-1">{{ errors.email[0] }}</p>
          </div>

          <!-- Role -->
          <div>
            <label class="font-medium text-slate-700">Role</label>
            <select
              v-model="form.role"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl bg-white focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
            >
              <option value="customer">Customer</option>
              <option value="sales">Sales</option>
              <option value="manager">Manager</option>
            </select>
            <p v-if="errors.role" class="text-red-500 text-sm mt-1">{{ errors.role[0] }}</p>
          </div>

          <!-- Sales Code -->
          <div v-if="form.role === 'sales'" class="col-span-2">
            <label class="font-medium text-slate-700">Kode Sales</label>
            <input
              v-model="form.sales_code"
              type="text"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              placeholder="Contoh: AB"
            />
            <p v-if="errors.sales_code" class="text-red-500 text-sm mt-1">
              {{ errors.sales_code[0] }}
            </p>
          </div>

          <!-- Alamat -->
          <div class="md:col-span-2">
            <label class="font-medium text-slate-700">Alamat</label>
            <textarea
              v-model="form.address"
              rows="3"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              placeholder="Masukkan alamat lengkap"
            ></textarea>
            <p v-if="errors.address" class="text-red-500 text-sm mt-1">{{ errors.address[0] }}</p>
          </div>

          <!-- Password -->
          <div>
            <label class="font-medium text-slate-700">
              {{ isEdit ? 'Password Baru (Opsional)' : 'Password' }}
            </label>
            <input
              v-model="form.password"
              type="password"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              :required="!isEdit"
              placeholder="••••••••"
            />
            <p v-if="errors.password" class="text-red-500 text-sm mt-1">{{ errors.password[0] }}</p>
          </div>

          <!-- Konfirmasi Password -->
          <div>
            <label class="font-medium text-slate-700">Konfirmasi Password</label>
            <input
              v-model="form.password_confirmation"
              type="password"
              class="w-full mt-1 px-3 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none transition"
              :required="!isEdit"
              placeholder="••••••••"
            />
          </div>
        </div>

        <!-- Tombol -->
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
  </div>
</template>
