<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import WorkspaceCard from "./components/WorkspaceCard.vue";
import type { CreateBusinessTaskRequest } from "./api/DTO/CreateBusinessTaskRequest";
import type { HealthDto } from "./api/DTO/HealthDto";
import type { SampleTaskDto } from "./api/DTO/SampleTaskDto";
import { fetchHealth } from "./api/health";
import { ApiRequestError } from "./api/http";
import { createTask, fetchTasks } from "./api/tasks";

const cards = [
  {
    name: "backend",
    description: "Owns the Kotlin + Spring Boot API and now handles business-task intake with validated planning fields.",
    accent: "amber",
  },
  {
    name: "frontend",
    description: "Turns the PRD into a task intake form, live planning board, and API-backed delivery view.",
    accent: "blue",
  },
  {
    name: "database",
    description: "Stores seeded planning rows plus the business fields required for customer request, estimate, date, and owner.",
    accent: "green",
  },
  {
    name: "e2e-test",
    description: "Smoke tests cover the read path and the task intake flow across API and UI surfaces.",
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
const submitting = ref(false);
const submitError = ref<string | null>(null);
const submitSuccess = ref<string | null>(null);
const fieldErrors = ref<Record<string, string>>({});

const form = ref<CreateBusinessTaskRequest>({
  customerRequest: "",
  requestedWork: "",
  targetDeliveryDate: "",
  buildEstimate: "",
  owner: "",
});

const healthBadge = computed(() => {
  if (loading.value) {
    return "checking";
  }

  if (error.value) {
    return "offline";
  }

  return health.value?.status.toLowerCase() ?? "unknown";
});

async function loadWorkspace() {
  try {
    const [healthResponse, taskResponse] = await Promise.all([fetchHealth(), fetchTasks()]);

    health.value = healthResponse;
    tasks.value = taskResponse;
  } catch (err) {
    error.value = err instanceof Error ? err.message : "Unknown error";
  } finally {
    loading.value = false;
  }
}

function resetForm() {
  form.value = {
    customerRequest: "",
    requestedWork: "",
    targetDeliveryDate: "",
    buildEstimate: "",
    owner: "",
  };
}

async function submitTask() {
  submitting.value = true;
  submitError.value = null;
  submitSuccess.value = null;
  fieldErrors.value = {};

  try {
    await createTask(form.value);
    tasks.value = await fetchTasks();
    submitSuccess.value = "Business task created.";
    resetForm();
  } catch (err) {
    if (err instanceof ApiRequestError) {
      submitError.value = err.message;
      fieldErrors.value = err.fieldErrors;
    } else {
      submitError.value = err instanceof Error ? err.message : "Unknown error";
    }
  } finally {
    submitting.value = false;
  }
}

onMounted(async () => {
  await loadWorkspace();
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
            <h2>Business task intake and planning</h2>
          </div>
          <p class="section-note">Rendered through the Vue API layer from <code>/api/tasks</code> and <code>POST /api/tasks</code>.</p>
        </div>

        <form class="task-form" @submit.prevent="submitTask">
          <div class="form-grid">
            <label class="field">
              <span>Customer request</span>
              <input v-model="form.customerRequest" :disabled="submitting" name="customerRequest" />
              <small v-if="fieldErrors.customerRequest" class="field-error">{{ fieldErrors.customerRequest }}</small>
            </label>

            <label class="field field-wide">
              <span>Requested work</span>
              <textarea v-model="form.requestedWork" :disabled="submitting" name="requestedWork" rows="3" />
              <small v-if="fieldErrors.requestedWork" class="field-error">{{ fieldErrors.requestedWork }}</small>
            </label>

            <label class="field">
              <span>Delivery date</span>
              <input
                v-model="form.targetDeliveryDate"
                :disabled="submitting"
                name="targetDeliveryDate"
                type="date"
              />
              <small v-if="fieldErrors.targetDeliveryDate" class="field-error">{{ fieldErrors.targetDeliveryDate }}</small>
            </label>

            <label class="field">
              <span>Build estimate</span>
              <input v-model="form.buildEstimate" :disabled="submitting" name="buildEstimate" />
              <small v-if="fieldErrors.buildEstimate" class="field-error">{{ fieldErrors.buildEstimate }}</small>
            </label>

            <label class="field">
              <span>Owner</span>
              <input v-model="form.owner" :disabled="submitting" name="owner" />
              <small v-if="fieldErrors.owner" class="field-error">{{ fieldErrors.owner }}</small>
            </label>
          </div>

          <div class="form-actions">
            <p v-if="submitSuccess" class="form-message form-message-success">{{ submitSuccess }}</p>
            <p v-else-if="submitError" class="form-message form-message-error">{{ submitError }}</p>
            <button class="submit-button" type="submit" :disabled="submitting">
              {{ submitting ? "Creating..." : "Create business task" }}
            </button>
          </div>
        </form>

        <p v-if="loading" class="empty-state">Loading tasks from the backend...</p>
        <p v-else-if="error" class="empty-state">Backend request failed. Check `make backend-run` and retry.</p>
        <ol v-else class="task-list">
          <li v-for="task in tasks" :key="task.id" class="task-item">
            <div class="task-topline">
              <span class="task-id">#{{ task.id }}</span>
              <strong class="task-status" :data-status="task.status.toLowerCase()">{{ task.status }}</strong>
            </div>
            <p class="task-title">{{ task.title }}</p>
            <p v-if="task.requestedWork !== task.title" class="task-requested-work">{{ task.requestedWork }}</p>
            <p class="task-request">{{ task.customerRequest }}</p>
            <dl class="task-details">
              <div>
                <dt>delivery</dt>
                <dd>{{ task.targetDeliveryDate }}</dd>
              </div>
              <div>
                <dt>estimate</dt>
                <dd>{{ task.buildEstimate }}</dd>
              </div>
              <div>
                <dt>owner</dt>
                <dd>{{ task.owner }}</dd>
              </div>
              <div>
                <dt>created</dt>
                <dd>{{ task.createdAt }}</dd>
              </div>
            </dl>
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

.task-form {
  display: grid;
  gap: 16px;
  margin-bottom: 20px;
  padding: 18px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.84);
  border: 1px solid rgba(22, 32, 51, 0.08);
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.field {
  display: grid;
  gap: 8px;
}

.field-wide {
  grid-column: 1 / -1;
}

.field span {
  color: #475874;
  font-size: 0.82rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.field input,
.field textarea {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid rgba(22, 32, 51, 0.14);
  border-radius: 16px;
  background: rgba(247, 244, 236, 0.92);
  color: #162033;
}

.field textarea {
  resize: vertical;
  min-height: 92px;
}

.field-error {
  color: #8a260f;
  font-size: 0.84rem;
}

.form-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.form-message {
  margin: 0;
  color: #536178;
  font-size: 0.92rem;
}

.form-message-success {
  color: #0d6b2f;
}

.form-message-error {
  color: #8a260f;
}

.submit-button {
  border: 0;
  border-radius: 999px;
  padding: 12px 18px;
  background: #162033;
  color: #f7f4ec;
  font-weight: 700;
  cursor: pointer;
}

.submit-button:disabled {
  cursor: wait;
  opacity: 0.72;
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

.task-requested-work,
.task-request {
  margin: 0 0 10px;
  color: #41506a;
  line-height: 1.6;
}

.task-details {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  margin: 0;
}

.task-details div {
  padding: 12px 14px;
  border-radius: 18px;
  background: #f6f2e7;
}

.task-details dt {
  margin-bottom: 6px;
}

.task-details dd {
  margin: 0;
}

.task-request {
  font-weight: 600;
}

.task-meta,
.task-requested-work {
  margin: 0;
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

  .form-grid,
  .task-details {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
    align-items: stretch;
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
