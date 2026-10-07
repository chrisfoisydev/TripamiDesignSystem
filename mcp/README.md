# Tripami MCP server

Gives Claude (and any MCP client: Cursor, Claude Desktop, VS Code…) structured access to the Tripami design system. It answers from this repo's own sources: `tokens/`, `docs/`, the Flutter package in `lib/` and the Claude Design cards. A rebuild picks up every change, so it can't drift from the system.

## Tools

All tools are read-only and take `format: "markdown" | "json"`.

| Tool | Answers |
|---|---|
| `tripami_get_overview` | What Tripami is, the six rules, install and theme. Call first. |
| `tripami_get_tokens` | Colors (light and dark), tints and shades, type, spacing, radius, size, elevation, motion, haptics, braid, icons, each with its Flutter and CSS name |
| `tripami_list_components` | Every component, its group and Flutter widget |
| `tripami_get_component` | Usage rules, motion and haptics, Flutter constructors (params, types, defaults) and web props. Also any Flutter API: `TPMotion`, `TPColors`, `TPTone`… |
| `tripami_check_contrast` | WCAG ratio and verdict, plus Tripami grades, for any token, ramp step or hex pairing |
| `tripami_suggest_tone` | Contrast-safe `subtle` / `muted` / `border` / `text` / `solid` roles for a ramp, light and dark |
| `tripami_match_color` | Nearest tokens to any color, for migrating hard-coded values |
| `tripami_search_guidelines` | Rules and rationale from the brand book and docs ("can the accent fill a button?") |
| `tripami_review_code` | Lints Flutter or web UI code: hard-coded colors, type, spacing, radii and durations (with the token to use), Material icons and curves, raw haptics, accent misuse, copy rules |

## Connect

### Claude Code, in this repo
Nothing to do: the repo's `.mcp.json` starts it. Approve the `tripami` server when Claude Code asks. The first start installs and builds it (about 20 seconds); later starts are instant and rebuild only when the design system has changed.

### Claude Code, in the Tripami app repo
Check this repo out next to the app (`../TripamiDesignSystem`), then in the app repo:

```bash
claude mcp add tripami --scope project -- node ../TripamiDesignSystem/mcp/run.mjs
```

That writes the app repo's `.mcp.json`. In a Claude Code cloud session, ask Claude to "add chrisfoisydev/TripamiDesignSystem to this session" and clone it beside the app first.

### Cursor, Claude Desktop and other local clients
Point the client at the launcher:

```json
{ "mcpServers": { "tripami": { "command": "node", "args": ["/absolute/path/to/TripamiDesignSystem/mcp/run.mjs"] } } }
```

### Hosted, for claude.ai and remote clients
claude.ai connectors and remote agents need a public URL. The server speaks stateless Streamable HTTP:

```bash
docker build -f mcp/Dockerfile -t tripami-mcp .        # from the repo root
docker run -p 3000:3000 -e TRIPAMI_MCP_TOKEN=change-me tripami-mcp
```

It serves `POST /mcp` (MCP) and `GET /health`. Set `TRIPAMI_MCP_TOKEN` to require `Authorization: Bearer <token>`. The design system isn't secret, but the token keeps the endpoint private. Deploy the image anywhere that runs containers (Fly.io, Render, Cloud Run), then:

```bash
claude mcp add --transport http tripami https://your-host/mcp --header "Authorization: Bearer change-me"
```

On claude.ai, add it as a custom connector (Settings → Connectors). Custom connectors authenticate with OAuth rather than a fixed header, so for claude.ai leave `TRIPAMI_MCP_TOKEN` unset (it only exposes design-system content, no app or user data) or put the server behind an OAuth-capable proxy.

## Develop

```bash
cd mcp
npm install
npm test          # builds (tsc + data) and runs the end-to-end tests over stdio and HTTP
npm run inspect   # opens the MCP Inspector
```

- `scripts/build-data.mjs` compiles the repo into `dist/data/tripami.json`.
- `src/server.ts` holds the tools.
- `src/review.ts` holds the code-review rules.
- `src/color.ts` holds the color math, which matches `tool/ramps/color.py`.
