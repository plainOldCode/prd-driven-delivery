<script setup lang="ts">
interface Props {
  title: string;
  description: string;
  accent: "amber" | "blue" | "green" | "ink" | "red";
}

defineProps<Props>();
</script>

<template>
  <article class="card" :data-accent="accent">
    <p class="title">{{ title }}</p>
    <p class="description">{{ description }}</p>
  </article>
</template>

<style scoped>
.card {
  min-height: 180px;
  padding: 22px;
  border-radius: 24px;
  border: 1px solid rgba(22, 32, 51, 0.08);
  background: rgba(255, 255, 255, 0.82);
  box-shadow: 0 14px 30px rgba(0, 0, 0, 0.05);
}

.card[data-accent="amber"] {
  background:
    linear-gradient(180deg, rgba(255, 231, 194, 0.9), rgba(255, 255, 255, 0.82));
}

.card[data-accent="blue"] {
  background:
    linear-gradient(180deg, rgba(211, 229, 255, 0.95), rgba(255, 255, 255, 0.82));
}

.card[data-accent="green"] {
  background:
    linear-gradient(180deg, rgba(214, 245, 224, 0.95), rgba(255, 255, 255, 0.82));
}

.card[data-accent="ink"] {
  background:
    linear-gradient(180deg, rgba(224, 228, 239, 0.98), rgba(255, 255, 255, 0.82));
}

.card[data-accent="red"] {
  background:
    linear-gradient(180deg, rgba(255, 223, 215, 0.95), rgba(255, 255, 255, 0.82));
}

.title {
  margin: 0 0 14px;
  font-size: 1.3rem;
  font-weight: 800;
}

.description {
  margin: 0;
  color: #41506a;
  line-height: 1.65;
}
</style>
