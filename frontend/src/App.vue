<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import WorkspaceCard from "./components/WorkspaceCard.vue";
import type { HealthDto } from "./api/DTO/HealthDto";
import type { SampleTaskDto } from "./api/DTO/SampleTaskDto";
import { fetchHealth } from "./api/health";
import { fetchTasks } from "./api/tasks";

const cards = [
  {
    name: "backend",
    description: "Owns the Kotlin + Spring Boot API and now serves live task data from MariaDB.",
    accent: "amber",
  },
  {
    name: "frontend",
    description: "Uses the backend API for runtime health and seeded task data instead of static-only content.",
    accent: "blue",
  },
  {
    name: "database",
    description: "Holds the MariaDB Compose setup and the bootstrap SQL consumed by the backend.",
    accent: "green",
  },
  {
    name: "e2e-test",
    description: "Smoke tests now cover both the API status path and task-driven UI rendering.",
    accent: "ink",
  },
  {
    name: "infrastructure",
    description: "Provides the k3s Helm chart and PR environment scripts for the same workspace shape.",
    accent: "red",
  },
] as const;

const health = ref<HealthDto | null>(null);
const tasks = ref<SampleTaskDto[]>([]);
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
    const [healthResponse, taskResponse] = await Promise.all([fetchHealth(), fetchTasks()]);

    health.value = healthResponse;
    tasks.value = taskResponse;
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
      <p class="eyebrow">PRD-Driven Delivery</p>
      <h1>One product document can drive one complete feature</h1>
      <p class="summary">
        This workspace demonstrates a docs-first delivery model across backend, frontend, database, e2e-test,
        and k3d validation. The goal is to keep product intent, implementation, and verification aligned across
        projects.
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
            <dt>tasks</dt>
            <dd>{{ tasks.length || "-" }}</dd>
          </div>
          <div>
            <dt>error</dt>
            <dd>{{ error ?? "-" }}</dd>
          </div>
        </dl>
      </div>
    </section>

    <section class="content-grid">
      <section class="task-panel">
        <div class="section-head">
          <div>
            <p class="section-kicker">Backend data</p>
            <h2>Live tasks from MariaDB</h2>
          </div>
          <p class="section-note">Rendered through the Vue API layer from <code>/api/tasks</code>.</p>
        </div>

        <p v-if="loading" class="empty-state">Loading tasks from the backend...</p>
        <p v-else-if="error" class="empty-state">Backend request failed. Check `make backend-run` and retry.</p>
        <ol v-else class="task-list">
          <li v-for="task in tasks" :key="task.id" class="task-item">
            <div class="task-topline">
              <span class="task-id">#{{ task.id }}</span>
              <strong class="task-status" :data-status="task.status.toLowerCase()">{{ task.status }}</strong>
            </div>
            <p class="task-title">{{ task.title }}</p>
            <p class="task-meta">{{ task.createdAt }}</p>
          </li>
        </ol>
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

.content-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(0, 0.95fr);
  gap: 24px;
  margin-top: 24px;
}

.task-panel {
  padding: 24px;
  border: 1px solid rgba(22, 32, 51, 0.08);
  border-radius: 28px;
  background:
    linear-gradient(160deg, rgba(255, 252, 244, 0.92), rgba(238, 245, 255, 0.82)),
    rgba(255, 255, 255, 0.72);
  box-shadow: 0 16px 42px rgba(32, 28, 18, 0.08);
}

.section-head {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: end;
  margin-bottom: 18px;
}

.section-kicker {
  margin: 0 0 8px;
  color: #8a4f00;
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

h2 {
  margin: 0;
  font-size: clamp(1.4rem, 2vw, 2rem);
}

.section-note {
  max-width: 260px;
  margin: 0;
  color: #536178;
  font-size: 0.92rem;
  line-height: 1.5;
}

.empty-state {
  margin: 0;
  padding: 24px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.72);
  color: #536178;
}

.task-list {
  display: grid;
  gap: 14px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.task-item {
  padding: 18px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.88);
  border: 1px solid rgba(22, 32, 51, 0.08);
}

.task-topline {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
}

.task-id {
  color: #6d7a8f;
  font-size: 0.86rem;
  font-weight: 700;
}

.task-status {
  display: inline-flex;
  padding: 6px 10px;
  border-radius: 999px;
  background: #e6ebf3;
  color: #233148;
  font-size: 0.82rem;
  letter-spacing: 0.04em;
}

.task-status[data-status="ready"] {
  background: #dff7e6;
  color: #0d6b2f;
}

.task-status[data-status="todo"] {
  background: #fff2cf;
  color: #805200;
}

.task-title {
  margin: 14px 0 6px;
  font-size: 1.08rem;
  font-weight: 700;
  line-height: 1.45;
}

.task-meta {
  margin: 0;
  color: #6d7a8f;
  font-size: 0.9rem;
}

.grid {
  display: grid;
  align-content: start;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
}

code {
  padding: 0.1rem 0.35rem;
  border-radius: 0.4rem;
  background: rgba(22, 32, 51, 0.08);
  font-family: "SFMono-Regular", "SF Mono", "Consolas", monospace;
}

@media (max-width: 900px) {
  .content-grid {
    grid-template-columns: 1fr;
  }

  .section-head {
    flex-direction: column;
    align-items: start;
  }

  .section-note {
    max-width: none;
  }
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
