<script setup>
defineProps({
  type: { type: String, default: 'button' },
  variant: { type: String, default: 'primary' },
  disabled: Boolean,
});
</script>

<template>
  <button :type="type" :disabled="disabled" :class="['px-4 py-2 rounded font-medium']">
    <slot />
  </button>
</template>
