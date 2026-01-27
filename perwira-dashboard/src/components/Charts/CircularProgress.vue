<!-- src/components/Charts/CircularProgress.vue -->
<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  percentage: Number,
  target: Number,
  revenue: Number,
  today: Number,
  message: String
})

const progressColor = computed(() => {
  const p = props.percentage
  if (p >= 90) return 'text-green-600'
  if (p >= 70) return 'text-blue-600'
  if (p >= 50) return 'text-yellow-600'
  return 'text-red-600'
})
</script>

<template>
  <div class="bg-white p-6 rounded-lg shadow">
    <div class="flex justify-between items-center mb-4">
      <h3 class="text-sm font-medium text-gray-500">Monthly Target</h3>
      <button class="text-gray-400 hover:text-gray-600">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
      </button>
    </div>

    <!-- Circular Progress -->
    <div class="relative flex justify-center items-center my-6">
      <svg class="w-32 h-32 transform -rotate-90">
        <circle cx="64" cy="64" r="56" stroke="#e5e7eb" stroke-width="8" fill="none" />
        <circle
          cx="64"
          cy="64"
          r="56"
          stroke="#3b82f6"
          stroke-width="8"
          fill="none"
          :stroke-dasharray="`${2 * Math.PI * 56}`"
          :stroke-dashoffset="`${2 * Math.PI * 56 * (1 - percentage / 100)}`"
          stroke-linecap="round"
        />
      </svg>
      <div class="absolute text-center">
        <div class="text-3xl font-bold" :class="progressColor">{{ percentage }}%</div>
        <div v-if="percentage > 0" class="text-xs text-green-500 mt-1">+10%</div>
      </div>
    </div>

    <p class="text-sm text-gray-600 text-center mt-4">{{ message }}</p>

    <!-- Stats -->
    <div class="grid grid-cols-3 gap-4 mt-6 pt-4 border-t border-gray-100">
      <div class="text-center">
        <div class="text-xs text-gray-500">Target</div>
        <div class="font-semibold">${{ target }}K</div>
      </div>
      <div class="text-center">
        <div class="text-xs text-gray-500">Revenue</div>
        <div class="font-semibold">${{ revenue }}K</div>
      </div>
      <div class="text-center">
        <div class="text-xs text-gray-500">Today</div>
        <div class="font-semibold">${{ today }}K</div>
      </div>
    </div>
  </div>
</template>
