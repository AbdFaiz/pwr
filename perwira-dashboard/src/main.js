import { createApp } from 'vue';
import { createPinia } from 'pinia';
import { useAuthStore } from './stores/auth'

import { useToast } from 'vue-toastification'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'

import App from './App.vue';
import router from './router';
import './style.css';

const app = createApp(App);

app.use(createPinia());
app.use(router);

app.use(Toast, {
    position: 'top-right',
    timeout: 3000,
    closeOnClick: true,
    pauseOnFocusLoss: true,
    pauseOnHover: true,
    draggable: true,
    hideProgressBar: false,
    icon: true
})

const authStore = useAuthStore()
authStore.initializeFromStorage()

app.config.globalProperties.$toast = useToast()
app.mount('#app');