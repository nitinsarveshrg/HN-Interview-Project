# syntax=docker/dockerfile:1.7-labs
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY package.json package-lock.json* .npmrc* ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev || npm i --omit=dev

COPY src ./src

EXPOSE 3000
CMD ["node", "src/server.js"]


