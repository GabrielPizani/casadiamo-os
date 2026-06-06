# AGENTS.md

Guidance for AI agents working in the **Casa Di Amo OS** (`casadiamo-os`) repository.

## Repository status

This repository is in the **Planning & Architecture Phase**. It contains documentation and directory scaffolding only — there is no application source code, dependency manifest, or CI configuration yet.

| Directory    | Purpose (planned)                          | Current contents |
|-------------|---------------------------------------------|------------------|
| `frontend/` | React + TypeScript UI (Lovable)             | Empty README     |
| `api/`      | Supabase-backed API layer                   | Empty README     |
| `database/` | PostgreSQL schema / migrations              | Empty README     |
| `ai-content/` | Vision, architecture, tech stack docs     | Markdown docs    |
| `docs/`     | Project documentation                       | Empty README     |

## Planned tech stack

See `ai-content/tech-stack` and root `README.md`:

- **Frontend:** Lovable, React, TypeScript (hosting: Vercel)
- **Backend / auth / DB:** Supabase (PostgreSQL)
- **Integrations:** HubSpot, ManyChat, WhatsApp, Google Calendar, Calendly

## Standard commands (when code exists)

Not applicable yet. Once a frontend or Supabase project is added, document commands here and reference `package.json` / Supabase CLI scripts instead of duplicating them.

Expected future commands (not yet in repo):

- Frontend dev: typically `npm run dev` or `pnpm dev` (Vite/Next per scaffold choice)
- Lint: `npm run lint`
- Test: `npm test`
- Supabase local: `supabase start` (requires Supabase CLI and Docker)

## Cursor Cloud specific instructions

### What runs today

**No services need to be started.** There is no `package.json`, `docker-compose.yml`, Makefile, or Supabase config. Lint, test, and build scripts do not exist.

### VM tooling already available

- **Node.js** v22 and **npm** — ready for when a JavaScript/TypeScript app is scaffolded
- **Python 3.12** — available for scripts/automation if added later
- **Git** — repository clones cleanly on `main`

### Supabase MCP

The planned backend uses Supabase. The Supabase MCP server may show as **needsAuth** until the user authenticates it in the Cursor desktop IDE. No Supabase project is linked in this repo yet.

### When implementing the first app

1. Scaffold or import code into `frontend/` (and optionally `supabase/` for local backend).
2. Add `.env.example` with required variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, etc.).
3. Update this file with real dev/lint/test commands.
4. Extend the VM **update script** to run the project's package-manager install (e.g. `npm ci` or `pnpm install`).

### Verification without an app

Until code lands, environment health checks are limited to:

- `git status` — clean working tree on `main`
- Confirm planned directories and `ai-content/` docs are present
- `node --version` and `npm --version` for toolchain readiness

Do not treat missing `node_modules` or absent dev servers as setup failures in the current planning-phase repo.
