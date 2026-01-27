// src/stores/auth.js
import { defineStore } from 'pinia'
import { setAuthToken } from '@/services/api'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', {
    state: () => ({
        token: localStorage.getItem('token') || null,
        user: JSON.parse(localStorage.getItem('user')) || null,
        isAuthenticated: !!localStorage.getItem('token')
    }),

    actions: {
        setToken(token) {
            this.token = token
            this.isAuthenticated = true
            localStorage.setItem('token', token)
            setAuthToken(token) // untuk axios
        },

        setUser(user) {
            this.user = user
            localStorage.setItem('user', JSON.stringify(user))
        },

        logout() {
            this.token = null
            this.user = null
            this.isAuthenticated = false
            localStorage.removeItem('token')
            localStorage.removeItem('user')
            setAuthToken(null)
        },

        // ✅ Tambahkan: init dari localStorage
        initializeFromStorage() {
            const token = localStorage.getItem('token')
            const user = localStorage.getItem('user')

            if (token && user) {
                setAuthToken(token)
                this.token = token
                this.user = JSON.parse(user)
                this.isAuthenticated = true
            }
        }
    }
})