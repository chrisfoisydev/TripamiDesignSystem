# Hosted Tripami MCP server (Streamable HTTP).
# Build from the repo root so the design-system sources are in the context:
#   docker build -f mcp/Dockerfile -t tripami-mcp .
#   docker run -p 3000:3000 -e TRIPAMI_MCP_TOKEN=change-me tripami-mcp
FROM node:22-slim AS build
WORKDIR /repo
COPY . .
WORKDIR /repo/mcp
RUN npm ci --no-audit --no-fund && npm run build && npm prune --omit=dev

FROM node:22-slim
WORKDIR /app
COPY --from=build /repo/mcp/package.json ./
COPY --from=build /repo/mcp/node_modules ./node_modules
COPY --from=build /repo/mcp/dist ./dist
ENV TRANSPORT=http PORT=3000
EXPOSE 3000
USER node
CMD ["node", "dist/src/index.js"]
