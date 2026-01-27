<script setup>
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/services/api';
import Button from '@/components/UI/Button.vue';
import Card from '@/components/UI/Card.vue';
import { useToast } from 'vue-toastification';
import { CheckCircle, XCircle, Loader2, Eye } from 'lucide-vue-next';
import { useAuthStore } from '@/stores/auth';

const router = useRouter();
const authStore = useAuthStore();
const toast = useToast();

const invoices = ref({ data: [], links: [] });
const loading = ref(true);
const error = ref(null);
const search = ref('');
const startDate = ref('');
const endDate = ref('');
const currentPage = ref(1);

const showModal = ref(false);
const modalAction = ref(null); // 'approve' | 'reject'
const selectedInvoice = ref(null);
const imagePreview = ref({ show: false, url: '' });

onMounted(async () => {
  await loadInvoices();
});

const loadInvoices = async (page = 1) => {
  try {
    loading.value = true;
    error.value = null;
    currentPage.value = page;

    const params = {
      search: search.value,
      start_date: startDate.value,
      end_date: endDate.value,
      page: page,
    };

    if (authStore.user?.role === 'sales') {
      params.sales_code = authStore.user.sales_code;
    }

    // Remove empty params
    Object.keys(params).forEach(key => {
      if (!params[key]) delete params[key];
    });

    const queryString = new URLSearchParams(params).toString();
    const url = `/invoices${queryString ? '?' + queryString : ''}`;

    const response = await api.get(url);
    invoices.value = response.data || { data: [], links: [], meta: {} };
  } catch (err) {
    error.value = err.response?.data?.message || 'Gagal memuat invoice.';
    invoices.value = { data: [], links: [] };
  } finally {
    loading.value = false;
  }
};

const openModal = (invoice, action) => {
  selectedInvoice.value = invoice;
  modalAction.value = action;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedInvoice.value = null;
  modalAction.value = null;
};

const handleAction = async () => {
  if (!selectedInvoice.value) return;

  const id = selectedInvoice.value.id;
  const action = modalAction.value;
  const endpoint = `/invoices/${id}/${action}`;
  const label = action === 'approve' ? 'approve' : 'reject';

  try {
    await api.put(endpoint);
    toast.success(`Invoice berhasil di-${label}.`);
    await loadInvoices(currentPage.value);
    closeModal();
  } catch (err) {
    toast.error(err.response?.data?.message || `Gagal ${label} invoice.`);
  }
};

const viewImage = (url) => {
  if (url) {
    imagePreview.value = { show: true, url: url };
  }
};

const closeImagePreview = () => {
  imagePreview.value = { show: false, url: '' };
};

const resetFilters = () => {
  search.value = '';
  startDate.value = '';
  endDate.value = '';
  loadInvoices(1);
};

// Handle keyboard events for modals
const handleKeydown = (event) => {
  if (event.key === 'Escape') {
    if (showModal.value) {
      closeModal();
    }
    if (imagePreview.value.show) {
      closeImagePreview();
    }
  }
};

// Add event listener for keyboard
onMounted(() => {
  document.addEventListener('keydown', handleKeydown);
});
</script>

<template>
  <Card title="Daftar Invoice" class="p-6">
    <!-- Filter Section -->
    <div class="flex flex-wrap gap-4 mb-6 items-end">
      <div class="flex-1 min-w-[200px]">
        <label class="block text-sm font-medium text-slate-700 mb-1">Cari Invoice</label>
        <input
          v-model="search"
          type="text"
          placeholder="Cari berdasarkan nomor invoice atau customer..."
          class="w-full border border-slate-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-red-500 focus:border-red-500 focus:outline-none transition"
          @keyup.enter="loadInvoices(1)"
        />
      </div>
      
      <div class="flex gap-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Dari Tanggal</label>
          <input
            v-model="startDate"
            type="date"
            class="border border-slate-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-red-500 focus:border-red-500 focus:outline-none transition"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Sampai Tanggal</label>
          <input
            v-model="endDate"
            type="date"
            class="border border-slate-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-red-500 focus:border-red-500 focus:outline-none transition"
          />
        </div>
      </div>

      <div class="flex gap-2">
        <Button
          variant="primary"
          @click="loadInvoices(1)"
          class="bg-red-600 hover:bg-red-700 text-white font-medium px-4 py-2 rounded-lg flex items-center gap-2"
        >
          <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
          Filter
        </Button>
        <Button
          variant="outline"
          @click="resetFilters"
          class="border border-slate-300 hover:bg-slate-50 text-slate-700 font-medium px-4 py-2 rounded-lg"
        >
          Reset
        </Button>
      </div>
    </div>

    <!-- Error Message -->
    <div
      v-if="error"
      class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4 flex items-center"
    >
      <XCircle class="w-5 h-5 mr-2" />
      {{ error }}
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12 text-slate-500">
      <Loader2 class="w-6 h-6 animate-spin mr-3" />
      <span>Memuat data invoice...</span>
    </div>

    <!-- Table -->
    <div v-else class="bg-white rounded-lg border border-slate-200 shadow-sm overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="py-3 px-4 text-left text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Customer
              </th>
              <th class="py-3 px-4 text-left text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Total
              </th>
              <th class="py-3 px-4 text-left text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Status
              </th>
              <th class="py-3 px-4 text-left text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Tanggal
              </th>
              <th class="py-3 px-4 text-left text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Sales
              </th>
              <th class="py-3 px-4 text-left text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Gambar
              </th>
              <th class="py-3 px-4 text-center text-xs font-semibold text-slate-700 uppercase tracking-wider">
                Aksi
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-slate-200">
            <tr
              v-for="(inv, index) in invoices.data"
              :key="inv.id"
              class="hover:bg-slate-50 transition-colors"
            >	
              <td class="py-3 px-4 whitespace-nowrap text-sm text-slate-900">
                {{ inv.user?.name || '-' }}
              </td>
              <td class="py-3 px-4 whitespace-nowrap text-sm font-semibold text-slate-900">
                Rp {{ Number(inv.total_amount).toLocaleString('id-ID') }}
              </td>
              <td class="py-3 px-4 whitespace-nowrap">
                <span
                  :class="[
                    'px-3 py-1 text-xs font-semibold rounded-full capitalize',
                    {
                      'bg-green-100 text-green-800': inv.status === 'approved',
                      'bg-red-100 text-red-800': inv.status === 'rejected',
                      'bg-yellow-100 text-yellow-800': inv.status === 'pending',
                    }
                  ]"
                >
                  {{ inv.status }}
                </span>
              </td>
              <td class="py-3 px-4 whitespace-nowrap text-sm text-slate-900">
                {{ new Date(inv.created_at).toLocaleDateString('id-ID') }}
              </td>
              <td class="py-3 px-4 whitespace-nowrap text-sm font-mono text-slate-900">
                {{ inv.sales_code }}
              </td>
              <td class="py-3 px-4 whitespace-nowrap">
                <div v-if="inv.file_url" class="flex items-center gap-2">
                  <img
                    :src="inv.file_url"
                    alt="Invoice"
                    class="w-12 h-12 object-cover rounded border cursor-pointer hover:opacity-80 transition"
                    @click="viewImage(inv.file_url)"
                  />
                  <button
                    @click="viewImage(inv.file_url)"
                    class="text-red-600 hover:text-red-700 p-1 rounded"
                  >
                    <Eye class="w-4 h-4" />
                  </button>
                </div>
                <span v-else class="text-slate-400 text-sm">-</span>
              </td>
              <td class="py-3 px-4 whitespace-nowrap text-center">
                <div class="flex justify-center gap-2">
                  <Button
                    variant="success"
                    size="sm"
                    @click="openModal(inv, 'approve')"
                    :disabled="inv.status !== 'pending'"
                    class="text-white px-3 py-1 text-xs bg-green-600 hover:bg-green-700 cursor-pointer"
                  >
                    Approve
                  </Button>
                  <Button
                    variant="danger"
                    size="sm"
                    @click="openModal(inv, 'reject')"
                    :disabled="inv.status !== 'pending'"
                    class="text-white px-3 py-1 text-xs bg-red-600 hover:bg-red-700 cursor-pointer"
                  >
                    Reject
                  </Button>
                </div>
              </td>
            </tr>

            <!-- Empty State -->
            <tr v-if="invoices.data.length === 0">
              <td colspan="8" class="py-8 text-center">
                <div class="text-slate-500">
                  <p class="text-lg font-medium mb-2">Tidak ada invoice ditemukan</p>
                  <p class="text-sm">Coba ubah filter pencarian Anda</p>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Pagination -->
    <div
      v-if="!loading && invoices.links && invoices.links.length > 2"
      class="flex flex-wrap justify-center gap-1 mt-6"
    >
      <button
        v-for="link in invoices.links"
        :key="link.label"
        @click="link.url && loadInvoices(link.url.split('page=')[1])"
        :disabled="!link.url || link.active"
        :class="[
          'px-3 py-2 rounded text-sm font-medium transition-all min-w-[40px]',
          link.active
            ? 'bg-red-600 text-white shadow-sm cursor-default'
            : link.url
            ? 'bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 cursor-pointer'
            : 'bg-slate-100 text-slate-400 cursor-not-allowed'
        ]"
        v-html="link.label"
      ></button>
    </div>

    <!-- Action Confirmation Modal -->
    <div
      v-if="showModal"
      class="fixed inset-0 flex items-center justify-center bg-black/60 backdrop-blur-sm z-50 p-4"
      @click.self="closeModal"
    >
      <div class="bg-white rounded-xl shadow-xl p-6 w-full max-w-md">
        <div class="flex items-center gap-3 mb-4">
          <component
            :is="modalAction === 'approve' ? CheckCircle : XCircle"
            class="w-6 h-6"
            :class="modalAction === 'approve' ? 'text-green-600' : 'text-red-600'"
          />
          <h2 class="text-xl font-semibold text-slate-800">
            Konfirmasi {{ modalAction === 'approve' ? 'Approve' : 'Reject' }}
          </h2>
        </div>
        
        <p class="text-slate-600 mb-6">
          Apakah Anda yakin ingin
          <span
            :class="
              modalAction === 'approve'
                ? 'text-green-700 font-semibold'
                : 'text-red-700 font-semibold'
            "
          >
            {{ modalAction === 'approve' ? 'menyetujui' : 'menolak' }}
          </span>
          invoice <span class="font-semibold text-slate-800">{{ selectedInvoice?.invoice_number }}</span>?
        </p>
        
        <div class="flex justify-end gap-3">
          <button
            class="px-4 py-2 rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200 transition font-medium"
            @click="closeModal"
          >
            Batal
          </button>
          <button
            class="px-4 py-2 rounded-lg text-white font-medium transition"
            :class="
              modalAction === 'approve'
                ? 'bg-green-600 hover:bg-green-700'
                : 'bg-red-600 hover:bg-red-700'
            "
            @click="handleAction"
          >
            {{ modalAction === 'approve' ? 'Approve' : 'Reject' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Image Preview Modal -->
    <div
      v-if="imagePreview.show"
      class="fixed inset-0 flex items-center justify-center bg-black/90 backdrop-blur-sm z-50 p-4"
      @click.self="closeImagePreview"
    >
      <div class="relative max-w-4xl max-h-full">
        <button
          @click="closeImagePreview"
          class="absolute -top-12 right-0 text-white hover:text-slate-300 transition"
        >
          <XCircle class="w-8 h-8" />
        </button>
        <img
          :src="imagePreview.url"
          alt="Preview Invoice"
          class="max-w-full max-h-[80vh] object-contain rounded-lg"
        />
      </div>
    </div>
  </Card>
</template>
