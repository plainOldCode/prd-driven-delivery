SHELL := /bin/bash

K3D_CLUSTER ?= example-local
K3D_HOST_PORT ?= 8088
HELM_RELEASE ?= example-dev
HELM_NAMESPACE ?= $(HELM_RELEASE)
BACKEND_IMAGE ?= prd-delivery-backend:local
FRONTEND_IMAGE ?= prd-delivery-frontend:local
INGRESS_HOST ?= prd-driven-delivery.local
PREVIEW_PR_NUMBER ?= 101
PREVIEW_BRANCH_NAME ?=
PREVIEW_NAMESPACE_PREFIX ?= example-preview
PREVIEW_BASE_DOMAIN ?= previews.prd-driven-delivery.local
PREVIEW_INGRESS_CLASS ?= traefik
PREVIEW_BACKEND_IMAGE ?= $(BACKEND_IMAGE)
PREVIEW_FRONTEND_IMAGE ?= $(FRONTEND_IMAGE)
PREVIEW_LOCAL_BASE_DOMAIN ?= localhost
PREVIEW_LOCAL_PUBLIC_PORT ?= $(K3D_HOST_PORT)
PREVIEW_DASHBOARD_OUTPUT ?= /tmp/prd-driven-delivery-preview-dashboard.html

.PHONY: help db-up db-down db-logs backend-run backend-down backend-logs backend-test frontend-dev e2e-test k3d-up k3d-down k3d-status helm-template helm-deploy-local helm-delete-local helm-smoke-local pr-env-create pr-env-create-local pr-env-test pr-env-delete pr-env-dashboard pr-env-dashboard-open

help:
	@echo ""
	@echo "PRD-Driven Delivery"
	@echo "==================="
	@echo "make db-up           Start MariaDB"
	@echo "make db-down         Stop MariaDB"
	@echo "make db-logs         Tail MariaDB logs"
	@echo "make backend-run     Start backend container"
	@echo "make backend-down    Stop backend container"
	@echo "make backend-logs    Tail backend logs"
	@echo "make backend-test    Run backend tests"
	@echo "make frontend-dev    Run Vue frontend"
	@echo "make e2e-test        Run Playwright smoke tests"
	@echo "make k3d-up          Create a local k3d cluster"
	@echo "make k3d-down        Delete the local k3d cluster"
	@echo "make k3d-status      Show local k3d cluster status"
	@echo "make helm-template   Render k3s Helm chart"
	@echo "make helm-deploy-local Build images and deploy Helm chart to k3d"
	@echo "make helm-delete-local Remove the local Helm release"
	@echo "make helm-smoke-local Probe the local ingress endpoints"
	@echo "make pr-env-create   Deploy a preview release using preview env vars"
	@echo "make pr-env-create-local Build/import local images and deploy a preview to k3d"
	@echo "make pr-env-test     Wait for the preview rollout and curl the local ingress"
	@echo "make pr-env-delete   Remove the preview namespace"
	@echo "make pr-env-dashboard Generate a local HTML dashboard for active previews"
	@echo "make pr-env-dashboard-open Generate and open the local preview dashboard"

db-up:
	cd database/dockerized && docker compose up -d

db-down:
	cd database/dockerized && docker compose down

db-logs:
	cd database/dockerized && docker compose logs -f mariadb

backend-run:
	cd backend && docker compose up --build -d

backend-down:
	cd backend && docker compose down

backend-logs:
	cd backend && docker compose logs -f backend

backend-test:
	docker run --rm -e GRADLE_USER_HOME=/workspace/.gradle -u $$(id -u):$$(id -g) -v $$(pwd)/backend:/workspace -w /workspace gradle:8.7-jdk21 ./gradlew test

frontend-dev:
	cd frontend && corepack pnpm install && corepack pnpm dev

e2e-test:
	cd e2e-test && corepack pnpm install && corepack pnpm test

k3d-up:
	k3d cluster list | awk 'NR > 1 { print $$1 }' | grep -qx "$(K3D_CLUSTER)" || k3d cluster create "$(K3D_CLUSTER)" -p "$(K3D_HOST_PORT):80@loadbalancer" --wait
	kubectl config use-context "k3d-$(K3D_CLUSTER)"

k3d-down:
	k3d cluster delete "$(K3D_CLUSTER)"

k3d-status:
	k3d cluster list
	kubectl --context "k3d-$(K3D_CLUSTER)" get nodes -o wide

helm-template:
	helm template example-stack infrastructure/k3s/helm/example-stack

helm-deploy-local: k3d-up
	docker build -t "$(BACKEND_IMAGE)" backend
	docker build -f infrastructure/k3s/dockerfiles/frontend.Dockerfile -t "$(FRONTEND_IMAGE)" .
	k3d image import "$(BACKEND_IMAGE)" "$(FRONTEND_IMAGE)" -c "$(K3D_CLUSTER)"
	helm upgrade --install "$(HELM_RELEASE)" infrastructure/k3s/helm/example-stack \
		--namespace "$(HELM_NAMESPACE)" \
		--create-namespace \
		--set backend.image="$(BACKEND_IMAGE)" \
		--set frontend.image="$(FRONTEND_IMAGE)" \
		--set ingress.host="$(INGRESS_HOST)"

helm-delete-local:
	helm uninstall "$(HELM_RELEASE)" --namespace "$(HELM_NAMESPACE)" || true
	kubectl delete namespace "$(HELM_NAMESPACE)" --ignore-not-found=true

helm-smoke-local:
	@bash infrastructure/k3s/scripts/pr-env-test.sh "$(HELM_NAMESPACE)" "$(HELM_RELEASE)"
	@curl --retry 20 --retry-delay 1 --retry-all-errors -sf -H "Host: $(INGRESS_HOST)" "http://127.0.0.1:$(K3D_HOST_PORT)/api/health"
	@printf '\n'
	@curl --retry 20 --retry-delay 1 --retry-all-errors -sf -H "Host: $(INGRESS_HOST)" "http://127.0.0.1:$(K3D_HOST_PORT)/api/tasks"
	@printf '\n'

pr-env-create:
	PREVIEW_PR_NUMBER="$(PREVIEW_PR_NUMBER)" \
	PREVIEW_BRANCH_NAME="$(PREVIEW_BRANCH_NAME)" \
	PREVIEW_NAMESPACE_PREFIX="$(PREVIEW_NAMESPACE_PREFIX)" \
	PREVIEW_BASE_DOMAIN="$(PREVIEW_BASE_DOMAIN)" \
	PREVIEW_INGRESS_CLASS="$(PREVIEW_INGRESS_CLASS)" \
	PREVIEW_BACKEND_IMAGE="$(PREVIEW_BACKEND_IMAGE)" \
	PREVIEW_FRONTEND_IMAGE="$(PREVIEW_FRONTEND_IMAGE)" \
	bash infrastructure/k3s/scripts/pr-env-create.sh

pr-env-create-local: k3d-up
	docker build -t "$(PREVIEW_BACKEND_IMAGE)" backend
	docker build -f infrastructure/k3s/dockerfiles/frontend.Dockerfile -t "$(PREVIEW_FRONTEND_IMAGE)" .
	k3d image import "$(PREVIEW_BACKEND_IMAGE)" "$(PREVIEW_FRONTEND_IMAGE)" -c "$(K3D_CLUSTER)"
	PREVIEW_PR_NUMBER="$(PREVIEW_PR_NUMBER)" \
	PREVIEW_BRANCH_NAME="$(PREVIEW_BRANCH_NAME)" \
	PREVIEW_NAMESPACE_PREFIX="$(PREVIEW_NAMESPACE_PREFIX)" \
	PREVIEW_BASE_DOMAIN="$(PREVIEW_LOCAL_BASE_DOMAIN)" \
	PREVIEW_INGRESS_CLASS="$(PREVIEW_INGRESS_CLASS)" \
	PREVIEW_URL_SCHEME="http" \
	PREVIEW_PUBLIC_PORT="$(PREVIEW_LOCAL_PUBLIC_PORT)" \
	PREVIEW_BACKEND_IMAGE="$(PREVIEW_BACKEND_IMAGE)" \
	PREVIEW_FRONTEND_IMAGE="$(PREVIEW_FRONTEND_IMAGE)" \
	PREVIEW_BACKEND_IMAGE_PULL_POLICY="IfNotPresent" \
	PREVIEW_FRONTEND_IMAGE_PULL_POLICY="IfNotPresent" \
	bash infrastructure/k3s/scripts/pr-env-create.sh

pr-env-test:
	PREVIEW_PR_NUMBER="$(PREVIEW_PR_NUMBER)" \
	PREVIEW_BRANCH_NAME="$(PREVIEW_BRANCH_NAME)" \
	PREVIEW_NAMESPACE_PREFIX="$(PREVIEW_NAMESPACE_PREFIX)" \
	PREVIEW_BASE_DOMAIN="$(PREVIEW_LOCAL_BASE_DOMAIN)" \
	PREVIEW_URL_SCHEME="http" \
	PREVIEW_PUBLIC_PORT="$(PREVIEW_LOCAL_PUBLIC_PORT)" \
	PREVIEW_DIRECT_URL="true" \
	bash infrastructure/k3s/scripts/pr-env-test.sh

pr-env-delete:
	PREVIEW_PR_NUMBER="$(PREVIEW_PR_NUMBER)" \
	PREVIEW_BRANCH_NAME="$(PREVIEW_BRANCH_NAME)" \
	PREVIEW_NAMESPACE_PREFIX="$(PREVIEW_NAMESPACE_PREFIX)" \
	bash infrastructure/k3s/scripts/pr-env-delete.sh

pr-env-dashboard:
	PREVIEW_DASHBOARD_OUTPUT="$(PREVIEW_DASHBOARD_OUTPUT)" \
	bash infrastructure/k3s/scripts/pr-env-dashboard.sh "$(PREVIEW_DASHBOARD_OUTPUT)"

pr-env-dashboard-open: pr-env-dashboard
	open "$(PREVIEW_DASHBOARD_OUTPUT)"
