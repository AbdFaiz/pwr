<script setup>
defineProps({
  title: String,
});
</script>

<template>
  <div class="bg-white shadow rounded-lg p-6">
    <h3 v-if="title" class="text-lg font-semibold mb-4">{{ title }}</h3>
    <slot />
  </div>
</template>
