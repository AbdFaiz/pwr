<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import api, { setAuthToken } from '@/services/api';
import { useAuthStore } from '@/stores/auth';

// Lucide Icons
import { Eye, EyeClosed } from 'lucide-vue-next';

const router = useRouter();
const store = useAuthStore();

const form = ref({
  credential: '',
  password: '',
});

const errors = ref({});
const loading = ref(false);
const showPassword = ref(false); // 👈 untuk toggle

const login = async () => {
  loading.value = true;
  errors.value = {};

  try {
    const res = await api.post('/login', form.value);
    const { token, user } = res.data;

    store.setToken(token);
    store.setUser(user);
    setAuthToken(token);

    router.push('/dashboard');
  } catch (err) {
    if (err.response?.data?.errors) {
      errors.value = err.response.data.errors;
    } else {
      errors.value.form = 'Email atau password salah.';
    }
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4">
    <div class="flex w-full max-w-7xl bg-white rounded-2xl shadow-2xl overflow-hidden">
      <!-- Left Section -->
      <div
        class="hidden lg:flex w-1/2 relative bg-[url(./public/loginn.jpg)] bg-center bg-cover text-white flex-col items-center justify-center p-12"
      >
        <!-- overlay -->
        <div class="absolute inset-0 bg-black/50"></div>
        <div class="relative max-w-md space-y-6">
          <h1 class="text-4xl font-bold leading-tight">
            Perwira Steel<br />
            Rewards Dashboard
          </h1>
          <p class="opacity-90">Only authorized parties can access this website.</p>
        </div>
      </div>

      <!-- Right Section -->
      <div class="w-full lg:w-1/2 flex items-center justify-center p-16">
        <div class="max-w-md w-full space-y-12">
          <div>
            <h2 class="text-3xl font-bold text-gray-900">Get Started Now</h2>
            <p class="mt-2 text-gray-600 text-sm">Please log in to your account to continue.</p>
            <hr class="mt-4" />
          </div>
          <!-- Form -->
          <form @submit.prevent="login" class="space-y-10">
            <!-- Email -->
            <div>
              <label for="credential" class="block text-sm font-medium text-gray-700 mb-2">Email</label>
              <input
                id="credential"
                v-model="form.credential"
                type="text"
                placeholder="you@example.com"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all"
                required
              />
              <p v-if="errors.credential" class="mt-1 text-sm text-red-500">{{ errors.email[0] }}</p>
            </div>

            <!-- Password -->
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700 mb-2"
                >Password</label
              >
              <div class="relative">
                <input
                  id="password"
                  v-model="form.password"
                  :type="showPassword ? 'text' : 'password'"
                  placeholder="••••••••"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all pr-12"
                  required
                />
                <!-- toggle button -->
                <button
                  type="button"
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-500 hover:text-gray-700"
                  @click="showPassword = !showPassword"
                  tabindex="-1"
                >
                  <component v-if="showPassword" :is="EyeClosed"> </component>
                  <component v-else :is="Eye"> </component>
                </button>
              </div>
              <p v-if="errors.password" class="mt-1 text-sm text-red-500">
                {{ errors.password[0] }}
              </p>
            </div>

            <!-- Error Global -->
            <div
              v-if="errors.form"
              class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm"
            >
              {{ errors.form }}
            </div>

            <!-- Button -->
            <button
              type="submit"
              :disabled="loading"
              class="w-full bg-red-600 hover:bg-red-700 text-white py-3 rounded-lg font-medium transition-all disabled:bg-gray-400 cursor-pointer"
            >
              {{ loading ? 'Memuat...' : 'Login' }}
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
