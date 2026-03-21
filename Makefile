SHELL := /bin/bash

.PHONY: help db-up db-down db-logs backend-run frontend-dev e2e-test helm-template pr-env-create pr-env-delete

help:
	@echo ""
	@echo "Example Workspace"
	@echo "================="
	@echo "make db-up           Start MariaDB"
	@echo "make db-down         Stop MariaDB"
	@echo "make db-logs         Tail MariaDB logs"
	@echo "make backend-run     Run Spring Boot backend"
	@echo "make frontend-dev    Run Vue frontend"
	@echo "make e2e-test        Run Playwright smoke tests"
	@echo "make helm-template   Render k3s Helm chart"
	@echo "make pr-env-create   Print PR environment install command"
	@echo "make pr-env-delete   Print PR environment delete command"

db-up:
	cd database/dockerized && docker compose up -d

db-down:
	cd database/dockerized && docker compose down

db-logs:
	cd database/dockerized && docker compose logs -f mariadb

backend-run:
	cd backend && gradle bootRun

frontend-dev:
	cd frontend && pnpm install && pnpm dev

e2e-test:
	cd e2e-test && pnpm install && pnpm test

helm-template:
	helm template example-stack infrastructure/k3s/helm/example-stack

pr-env-create:
	bash infrastructure/k3s/scripts/pr-env-create.sh 101

pr-env-delete:
	bash infrastructure/k3s/scripts/pr-env-delete.sh example-pr-101
