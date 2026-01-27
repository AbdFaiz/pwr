// src/services/api.js
import axios from 'axios';

let token = null;

// Fungsi untuk set token global
export const setAuthToken = (newToken) => {
    token = newToken;
};

const api = axios.create({
    baseURL: 'http://localhost:8001/api',
    headers: {
        'Content-Type': 'application/json',
    },
});

api.interceptors.request.use(
    (config) => {
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
            console.log(config.headers.Authorization);
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

export default api;