SHELL := /bin/bash

.PHONY: help db-up db-down db-logs backend-run backend-down backend-logs backend-test frontend-dev e2e-test helm-template pr-env-create pr-env-delete

help:
	@echo ""
	@echo "Example Workspace"
	@echo "================="
	@echo "make db-up           Start MariaDB"
	@echo "make db-down         Stop MariaDB"
	@echo "make db-logs         Tail MariaDB logs"
	@echo "make backend-run     Start backend container"
	@echo "make backend-down    Stop backend container"
	@echo "make backend-logs    Tail backend logs"
	@echo "make backend-test    Run backend tests"
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
	cd backend && docker compose up --build -d

backend-down:
	cd backend && docker compose down

backend-logs:
	cd backend && docker compose logs -f backend

backend-test:
	docker run --rm -e GRADLE_USER_HOME=/workspace/.gradle -u $$(id -u):$$(id -g) -v $$(pwd)/backend:/workspace -w /workspace gradle:8.7-jdk21 ./gradlew test

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
