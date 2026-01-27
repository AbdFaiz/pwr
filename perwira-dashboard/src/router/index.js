// import { createRouter, createWebHistory } from 'vue-router'

// const router = createRouter({
//   history: createWebHistory(import.meta.env.BASE_URL),
//   routes: [],
// })

// export default router
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'

// Views
import Login from '../views/Auth/Login.vue'
import Home from '../views/Dashboard/Home.vue'
import UserList from '../views/Users/UserList.vue'
import UserForm from '../views/Users/UserForm.vue'
import InvoiceList from '../views/Invoices/InvoiceList.vue'
import InvoiceDetail from '../views/Invoices/InvoiceDetail.vue'
import RewardList from '../views/Rewards/RewardList.vue'
import RedemptionList from '../views/Redemptions/RedemptionList.vue'
import { useAuthStore } from '../stores/auth';


const routes = [
    { path: '/', redirect: '/login' },
    { path: '/login', component: Login, meta: { guest: true } },
    { path: '/dashboard', component: Home, meta: { auth: true } },

    // Users
    { path: '/users', component: UserList, meta: { auth: true, role: 'manager' } },
    { path: '/users/create', component: UserForm, meta: { auth: true, role: 'manager' } },
    { path: '/users/:id/edit', component: UserForm, meta: { auth: true, role: 'manager' } },

    // Invoices
    { path: '/invoices', component: InvoiceList, meta: { auth: true, role: ['manager', 'sales'] } },
    { path: '/invoices/:id/detail', component: InvoiceDetail, meta: { auth: true, role: ['manager', 'sales'] } },

    // Rewards
    { path: '/rewards', component: RewardList, meta: { auth: true, role: ['manager', 'sales'] } },
    {
        path: '/rewards/create',
        component: () =>
            import('../views/Rewards/RewardForm.vue'),
        meta: { auth: true, role: ['manager', 'sales'] }
    },
    {
        path: '/rewards/:id/edit',
        component: () =>
            import('../views/Rewards/RewardForm.vue'),
        meta: { auth: true, role: ['manager', 'sales'] }
    },

    // Redemptions
    { path: '/redemptions', component: RedemptionList, meta: { auth: true, role: ['manager', 'sales'] } }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// Global guard
router.beforeEach((to, from, next) => {
    const store = useAuthStore()

    if (to.meta.auth && !store.isAuthenticated) {
        next('/login')
    } else if (to.meta.guest && store.isAuthenticated) {
        next('/dashboard')
    } else {
        // Role check
        if (to.meta.role) {
            const userRole = store.user && store.user.role ? store.user.role : null
            const allowedRoles = Array.isArray(to.meta.role) ? to.meta.role : [to.meta.role]
            if (!allowedRoles.includes(userRole)) { return next('/dashboard') }
        }
        next()
    }
})

export default router