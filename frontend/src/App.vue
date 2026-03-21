<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import WorkspaceCard from "./components/WorkspaceCard.vue";
import { fetchHealth } from "./api/health";
import type { HealthDto } from "./api/DTO/HealthDto";

const cards = [
  {
    name: "backend",
    description: "Owns the Kotlin + Spring Boot API and the health endpoint.",
    accent: "amber",
  },
  {
    name: "frontend",
    description: "A Vite-based Vue app that presents the current workspace shape.",
    accent: "blue",
  },
  {
    name: "database",
    description: "Contains the MariaDB Docker Compose setup and bootstrap SQL.",
    accent: "green",
  },
  {
    name: "e2e-test",
    description: "Validates both the UI and the API with Playwright smoke tests.",
    accent: "ink",
  },
  {
    name: "infrastructure",
    description: "Provides the k3s Helm chart and PR environment scripts.",
    accent: "red",
  },
] as const;

const health = ref<HealthDto | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);

const healthBadge = computed(() => {
  if (loading.value) {
    return "checking";
  }

  if (error.value) {
    return "offline";
  }

  return health.value?.status.toLowerCase() ?? "unknown";
});

onMounted(async () => {
  try {
    health.value = await fetchHealth();
  } catch (err) {
    error.value = err instanceof Error ? err.message : "Unknown error";
  } finally {
    loading.value = false;
  }
});
</script>

<template>
  <main class="page">
    <section class="hero">
      <p class="eyebrow">Example Workspace</p>
      <h1>A minimal foundation for a multi-project development workspace</h1>
      <p class="summary">
        This project separates backend, frontend, database, e2e-test, and infrastructure just like a real
        production workspace, while keeping the starting point lean enough for a side project or portfolio piece.
      </p>

      <div class="health-panel">
        <div>
          <span class="label">Backend status</span>
          <strong class="badge" :data-state="healthBadge">{{ healthBadge }}</strong>
        </div>
        <dl class="health-grid">
          <div>
            <dt>service</dt>
            <dd>{{ health?.service ?? "-" }}</dd>
          </div>
          <div>
            <dt>workspace</dt>
            <dd>{{ health?.workspace ?? "-" }}</dd>
          </div>
          <div>
            <dt>profile</dt>
            <dd>{{ health?.profile ?? "-" }}</dd>
          </div>
          <div>
            <dt>error</dt>
            <dd>{{ error ?? "-" }}</dd>
          </div>
        </dl>
      </div>
    </section>

    <section class="grid">
      <WorkspaceCard
        v-for="card in cards"
        :key="card.name"
        :title="card.name"
        :description="card.description"
        :accent="card.accent"
      />
    </section>
  </main>
</template>

<style scoped>
.page {
  max-width: 1120px;
  margin: 0 auto;
  padding: 48px 20px 80px;
}

.hero {
  padding: 36px;
  border: 1px solid rgba(22, 32, 51, 0.08);
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.78);
  box-shadow: 0 20px 50px rgba(70, 58, 32, 0.08);
  backdrop-filter: blur(12px);
}

.eyebrow {
  margin: 0 0 8px;
  color: #8a4f00;
  font-size: 0.82rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  font-size: clamp(2rem, 4vw, 3.6rem);
  line-height: 1.05;
}

.summary {
  max-width: 760px;
  margin: 18px 0 0;
  color: #41506a;
  font-size: 1.02rem;
  line-height: 1.7;
}

.health-panel {
  display: grid;
  gap: 18px;
  margin-top: 28px;
  padding-top: 24px;
  border-top: 1px solid rgba(22, 32, 51, 0.1);
}

.label {
  display: block;
  margin-bottom: 10px;
  color: #58667d;
  font-size: 0.9rem;
}

.badge {
  display: inline-flex;
  align-items: center;
  padding: 8px 14px;
  border-radius: 999px;
  background: #e6ebf3;
  color: #233148;
  text-transform: uppercase;
}

.badge[data-state="up"] {
  background: #dff7e6;
  color: #0d6b2f;
}

.badge[data-state="offline"] {
  background: #ffe5e0;
  color: #8a260f;
}

.badge[data-state="checking"] {
  background: #fff2cf;
  color: #805200;
}

.health-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 14px;
  margin: 0;
}

.health-grid div {
  padding: 14px;
  border-radius: 18px;
  background: #f3efe5;
}

dt {
  margin-bottom: 6px;
  color: #58667d;
  font-size: 0.8rem;
  text-transform: uppercase;
}

dd {
  margin: 0;
  font-weight: 700;
  word-break: break-word;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-top: 24px;
}

@media (max-width: 640px) {
  .page {
    padding-top: 24px;
  }

  .hero {
    padding: 24px;
  }
}
</style>
