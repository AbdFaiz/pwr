<!-- src/views/Invoices/InvoiceDetail.vue -->
<script setup>
import { onMounted, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import api from '@/services/api';
import Button from '@/components/UI/Button.vue';
import { useAuthStore } from '@/stores/auth';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const invoice = ref(null);
const loading = ref(true);
const error = ref(null);

onMounted(async () => {
  await loadInvoice();
});

const loadInvoice = async () => {
  try {
    const res = await api.get(`/invoices/${route.params.id}`);
    const data = res.data.data;

    // Cek apakah invoice cocok dengan sales_code user (jika role sales)
    if (authStore.user?.role === 'sales' && data.sales_code !== authStore.user.sales_code) {
      error.value = 'Anda tidak memiliki akses ke invoice ini.';
      return;
    }

    invoice.value = data;
  } catch (err) {
    error.value = err.response?.data?.message || 'Gagal muat detail invoice.';
  } finally {
    loading.value = false;
  }
};

const approveInvoice = async () => {
  if (!confirm('Yakin ingin approve invoice ini?')) return;

  try {
    await api.put(`/invoices/${invoice.value.id}/approve`);
    alert('Invoice berhasil di-approve.');
    await loadInvoice(); // Refresh status
  } catch (err) {
    alert(err.response?.data?.message || 'Gagal approve.');
  }
};

const rejectInvoice = async () => {
  if (!confirm('Yakin ingin reject invoice ini?')) return;

  try {
    await api.put(`/invoices/${invoice.value.id}/reject`);
    alert('Invoice berhasil di-reject.');
    await loadInvoice(); // Refresh status
  } catch (err) {
    alert(err.response?.data?.message || 'Gagal reject.');
  }
};
</script>

<template>
  <Card>
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-xl font-bold">Detail Invoice</h2>
      <RouterLink to="/invoices" class="text-blue-600 hover:underline"
        >← Kembali ke daftar</RouterLink
      >
    </div>

    <!-- Error -->
    <div v-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-8">
      <p>Loading...</p>
    </div>

    <!-- Invoice Detail -->
    <div v-else-if="invoice" class="space-y-6">
      <!-- Invoice Info -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-gray-50 p-4 rounded-lg">
          <h3 class="font-semibold text-gray-700 mb-2">Info Invoice</h3>
          <div class="space-y-2 text-sm">
            <p><span class="font-medium">No. Invoice:</span> {{ invoice.invoice_number }}</p>
            <p>
              <span class="font-medium">Tanggal:</span>
              {{ new Date(invoice.created_at).toLocaleDateString() }}
            </p>
            <p>
              <span class="font-medium">Status:</span>
              <span
                :class="[
                  'ml-2 px-2 py-1 text-xs rounded capitalize',
                  invoice.status === 'approved'
                    ? 'bg-green-100 text-green-800'
                    : invoice.status === 'rejected'
                      ? 'bg-red-100 text-red-800'
                      : 'bg-yellow-100 text-yellow-800',
                ]"
              >
                {{ invoice.status }}
              </span>
            </p>
          </div>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <h3 class="font-semibold text-gray-700 mb-2">Info Customer</h3>
          <div class="space-y-2 text-sm">
            <p><span class="font-medium">Nama:</span> {{ invoice.user?.name || '-' }}</p>
            <p><span class="font-medium">Email:</span> {{ invoice.user?.email || '-' }}</p>
          </div>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <h3 class="font-semibold text-gray-700 mb-2">Detail Keuangan</h3>
          <div class="space-y-2 text-sm">
            <p>
              <span class="font-medium">Total:</span> Rp
              {{ Number(invoice.total_amount).toLocaleString() }}
            </p>
            <p><span class="font-medium">Poin yang Didapat:</span> {{ invoice.points_earned }}</p>
          </div>
        </div>

        <div class="bg-gray-50 p-4 rounded-lg">
          <h3 class="font-semibold text-gray-700 mb-2">Sales</h3>
          <div class="space-y-2 text-sm">
            <p><span class="font-medium">Sales Code:</span> {{ invoice.sales_code }}</p>
          </div>
        </div>
      </div>

      <!-- Invoice Image -->
      <div class="bg-gray-50 p-4 rounded-lg">
        <h3 class="font-semibold text-gray-700 mb-4">Gambar Invoice</h3>
        <div class="flex justify-center">
          <img
            :src="invoice.file_url"
            :alt="'Invoice ' + invoice.invoice_number"
            class="max-w-full h-auto rounded-lg shadow border"
          />
        </div>
      </div>

      <!-- Actions -->
      <div v-if="invoice.status === 'pending'" class="flex justify-center space-x-4 pt-4">
        <Button variant="primary" @click="approveInvoice" class="px-6 py-2"> Approve </Button>
        <Button variant="danger" @click="rejectInvoice" class="px-6 py-2"> Reject </Button>
      </div>

      <div v-else class="text-center py-4 text-gray-500">Invoice sudah {{ invoice.status }}.</div>
    </div>

    <!-- Jika invoice tidak ditemukan -->
    <div v-else class="text-center py-8 text-gray-500">Invoice tidak ditemukan.</div>
  </Card>
</template>
