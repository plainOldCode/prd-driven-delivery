#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="${1:-${PREVIEW_DASHBOARD_OUTPUT:-/tmp/prd-driven-delivery-preview-dashboard.html}}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

kubectl get namespace -l prd-driven-delivery.io/preview=true -o json > "${TMP_DIR}/namespaces.json"
kubectl get deployment -A -o json > "${TMP_DIR}/deployments.json"
kubectl get ingress -A -o json > "${TMP_DIR}/ingresses.json"

python3 - "${TMP_DIR}/namespaces.json" "${TMP_DIR}/deployments.json" "${TMP_DIR}/ingresses.json" "${OUTPUT_FILE}" <<'PY'
import html
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

namespaces_path, deployments_path, ingresses_path, output_path = sys.argv[1:5]

with open(namespaces_path, "r", encoding="utf-8") as fh:
    namespaces = json.load(fh)
with open(deployments_path, "r", encoding="utf-8") as fh:
    deployments = json.load(fh)
with open(ingresses_path, "r", encoding="utf-8") as fh:
    ingresses = json.load(fh)

deployment_map = {}
for item in deployments.get("items", []):
    namespace = item["metadata"]["namespace"]
    deployment_map.setdefault(namespace, []).append(item)

ingress_map = {}
for item in ingresses.get("items", []):
    namespace = item["metadata"]["namespace"]
    ingress_map.setdefault(namespace, []).append(item)

def ready_summary(namespace: str):
    rows = []
    for item in deployment_map.get(namespace, []):
        desired = max(item.get("status", {}).get("replicas", 0), 1)
        available = item.get("status", {}).get("availableReplicas", 0)
        rows.append((item["metadata"]["name"], available, desired))

    if not rows:
        return "No deployments", "pending"

    all_ready = all(available >= desired for _, available, desired in rows)
    summary = ", ".join(f"{name}: {available}/{desired}" for name, available, desired in rows)
    return summary, "ready" if all_ready else "degraded"

def first_host(namespace: str):
    entries = ingress_map.get(namespace, [])
    if not entries:
        return "-"
    rules = entries[0].get("spec", {}).get("rules", [])
    if not rules:
        return "-"
    return rules[0].get("host", "-")

def created_at(value: str):
    try:
        dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
        return dt.astimezone(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    except Exception:
        return value

items = namespaces.get("items", [])
cards = []

if not items:
    cards.append(
        """
        <section class="empty">
          <h2>No active preview environments</h2>
          <p>Create one with <code>make pr-env-create-local PREVIEW_PR_NUMBER=204</code>.</p>
        </section>
        """
    )
else:
    rows = []
    for item in items:
        metadata = item.get("metadata", {})
        labels = metadata.get("labels", {})
        annotations = metadata.get("annotations", {})
        namespace = metadata["name"]
        readiness, state = ready_summary(namespace)
        rows.append(
            {
                "namespace": namespace,
                "preview_id": annotations.get("prd-driven-delivery.io/preview-id", namespace),
                "source": labels.get("prd-driven-delivery.io/source", "unknown"),
                "source_ref": annotations.get("prd-driven-delivery.io/source-ref", "-"),
                "release": annotations.get("prd-driven-delivery.io/release", namespace),
                "host": annotations.get("prd-driven-delivery.io/host", first_host(namespace)),
                "url": annotations.get("prd-driven-delivery.io/url", "#"),
                "readiness": readiness,
                "state": state,
                "created": created_at(metadata.get("creationTimestamp", "-")),
            }
        )

    rows.sort(key=lambda row: row["namespace"])

    for row in rows:
        cards.append(
            f"""
            <article class="card">
              <div class="card-top">
                <div>
                  <p class="kicker">{html.escape(row["source"])}</p>
                  <h2>{html.escape(row["preview_id"])}</h2>
                </div>
                <span class="badge badge-{html.escape(row["state"])}">{html.escape(row["state"])}</span>
              </div>
              <dl class="grid">
                <div><dt>Namespace</dt><dd>{html.escape(row["namespace"])}</dd></div>
                <div><dt>Release</dt><dd>{html.escape(row["release"])}</dd></div>
                <div><dt>Source Ref</dt><dd>{html.escape(row["source_ref"])}</dd></div>
                <div><dt>Created</dt><dd>{html.escape(row["created"])}</dd></div>
                <div class="wide"><dt>Host</dt><dd>{html.escape(row["host"])}</dd></div>
                <div class="wide"><dt>Readiness</dt><dd>{html.escape(row["readiness"])}</dd></div>
              </dl>
              <p class="links"><a href="{html.escape(row["url"])}">{html.escape(row["url"])}</a></p>
            </article>
            """
        )

document = f"""<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="refresh" content="20" />
    <title>PRD-Driven Delivery Preview Dashboard</title>
    <style>
      :root {{
        --bg: #f6efe2;
        --panel: rgba(255, 255, 255, 0.88);
        --ink: #1d2940;
        --muted: #5e6c84;
        --line: rgba(29, 41, 64, 0.12);
        --ready-bg: #e3f4dc;
        --ready-ink: #1f6b2b;
        --degraded-bg: #fde3d0;
        --degraded-ink: #9e4f16;
      }}
      body {{
        margin: 0;
        font-family: Arial, Helvetica, sans-serif;
        color: var(--ink);
        background:
          radial-gradient(circle at top left, rgba(255, 199, 92, 0.35), transparent 28%),
          radial-gradient(circle at top right, rgba(86, 137, 214, 0.24), transparent 24%),
          var(--bg);
      }}
      main {{
        max-width: 1180px;
        margin: 0 auto;
        padding: 48px 24px 72px;
      }}
      h1 {{
        margin: 0 0 8px;
        font-size: 42px;
      }}
      .summary {{
        margin: 0;
        max-width: 760px;
        color: var(--muted);
        font-size: 18px;
        line-height: 1.6;
      }}
      .meta {{
        margin-top: 14px;
        color: var(--muted);
        font-size: 14px;
      }}
      .cards {{
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
        gap: 18px;
        margin-top: 28px;
      }}
      .card, .empty {{
        border: 1px solid var(--line);
        border-radius: 24px;
        background: var(--panel);
        padding: 24px;
        box-shadow: 0 18px 44px rgba(40, 52, 74, 0.08);
      }}
      .card-top {{
        display: flex;
        justify-content: space-between;
        gap: 16px;
      }}
      .kicker {{
        margin: 0 0 6px;
        text-transform: uppercase;
        letter-spacing: 0.08em;
        color: #905800;
        font-size: 12px;
        font-weight: 700;
      }}
      h2 {{
        margin: 0;
        font-size: 28px;
        line-height: 1.15;
      }}
      .badge {{
        align-self: flex-start;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 8px 12px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
      }}
      .badge-ready {{
        background: var(--ready-bg);
        color: var(--ready-ink);
      }}
      .badge-degraded, .badge-pending {{
        background: var(--degraded-bg);
        color: var(--degraded-ink);
      }}
      .grid {{
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 12px;
        margin: 22px 0 18px;
      }}
      .grid div {{
        padding: 14px 16px;
        border-radius: 16px;
        background: rgba(242, 236, 222, 0.82);
      }}
      .grid .wide {{
        grid-column: 1 / -1;
      }}
      dt {{
        color: var(--muted);
        font-size: 12px;
        text-transform: uppercase;
        margin-bottom: 6px;
      }}
      dd {{
        margin: 0;
        font-size: 15px;
        line-height: 1.45;
        word-break: break-word;
      }}
      .links a {{
        color: #1d56c2;
        font-weight: 700;
        text-decoration: none;
      }}
      .links a:hover {{
        text-decoration: underline;
      }}
      code {{
        padding: 2px 6px;
        border-radius: 6px;
        background: rgba(29, 41, 64, 0.08);
      }}
    </style>
  </head>
  <body>
    <main>
      <header>
        <h1>Preview Dashboard</h1>
        <p class="summary">Observe active branch and pull-request previews in one place, open the local URLs directly, and refresh every 20 seconds while decisions are being made.</p>
        <p class="meta">Generated at {datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")}</p>
      </header>
      <section class="cards">
        {''.join(cards)}
      </section>
    </main>
  </body>
</html>
"""

Path(output_path).write_text(document, encoding="utf-8")
print(output_path)
PY

echo "Preview dashboard written to ${OUTPUT_FILE}"
