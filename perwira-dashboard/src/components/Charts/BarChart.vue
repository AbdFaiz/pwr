<!-- src/components/Charts/BarChart.vue -->
<script setup>
import { ref, onMounted } from 'vue'
import { BarChart, useChart } from '@vue/chartjs'

const props = defineProps({
  labels: Array,
  data: Array,
  title: String
})

const chartData = ref({
  labels: props.labels,
  datasets: [
    {
      label: props.title,
      data: props.data,
      backgroundColor: '#3B82F6',
      borderColor: '#2563EB',
      borderWidth: 1
    }
  ]
})

const chartOptions = ref({
  responsive: true,
  plugins: {
    legend: { display: false },
    tooltip: { enabled: true }
  },
  scales: {
    y: {
      beginAtZero: true,
      grid: { color: 'rgba(0,0,0,0.05)' },
      ticks: { stepSize: 100 }
    },
    x: {
      grid: { display: false }
    }
  }
})
</script>

<template>
  <div class="bg-white p-6 rounded-lg shadow">
    <h3 class="text-sm font-medium text-gray-500 mb-4">{{ title }}</h3>
    <BarChart :data="chartData" :options="chartOptions" />
  </div>
</template>
