FROM mcr.microsoft.com/playwright:v1.56.1-noble

WORKDIR /tests

COPY e2e-test/package.json e2e-test/playwright.config.ts e2e-test/tsconfig.json ./
COPY e2e-test/tests ./tests

RUN corepack enable && pnpm install
