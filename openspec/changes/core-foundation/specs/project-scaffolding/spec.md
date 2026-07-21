# Project Scaffolding Specification

## Purpose

Establish a reproducible Next.js 16 project skeleton with independently verifiable quality gates and strict layer boundaries.

## Requirements

### Requirement: Build Toolchain

The project MUST use Node.js 20.9+, Next.js 16 App Router, React 19, TypeScript strict mode, Tailwind CSS 4, Vitest, and ESLint flat config. It MUST expose separate `lint`, `typecheck`, `test`, and `build` scripts because Next.js 16 does not run lint during build.

#### Scenario: Quality gates pass independently

- GIVEN a fresh clone with dependencies installed
- WHEN `npm run lint`, `npm run typecheck`, `npm test -- --run`, and `npm run build` are executed separately
- THEN every command exits with code 0
- AND no script invokes removed `next lint`

#### Scenario: Strict typing is enforced

- GIVEN `strict: true` in `tsconfig.json`
- WHEN implicit `any` or unsafe nullable code is introduced
- THEN `npm run typecheck` exits non-zero

### Requirement: Tailwind CSS 4 Configuration

The project MUST configure `@tailwindcss/postcss` in root `postcss.config.mjs` and import Tailwind with `@import "tailwindcss"` in `src/app/globals.css`. A `tailwind.config.ts` file SHALL NOT be required for this slice.

#### Scenario: Tailwind styles compile

- GIVEN a page using a Tailwind utility class
- WHEN `npm run build` executes
- THEN the stylesheet compiles without missing PostCSS plugin or Tailwind configuration errors

### Requirement: Clean Architecture Layout

The project MUST keep pure domain code in `src/domain`, Supabase adapters in `src/infrastructure`, and Next.js code in `src/app` plus `src/proxy.ts`.

#### Scenario: Domain layer has no framework imports

- GIVEN all files under `src/domain`
- WHEN imports are scanned
- THEN none imports `next`, `react`, `@supabase/*`, or `server-only`

### Requirement: Supabase Local Configuration

The project MUST include `supabase/config.toml`, CLI-generated timestamped migrations, and pgTAP tests under `supabase/tests`. Migration filenames MUST be generated with the installed Supabase CLI rather than invented.

#### Scenario: Local database rebuilds cleanly

- GIVEN Supabase CLI is installed
- WHEN `supabase db reset` and `supabase test db` are executed
- THEN migrations apply from empty state
- AND all database tests pass

### Requirement: Environment Safety

The repository MUST ignore `.env.local` and commit only `.env.local.example` with placeholder values for public URL, publishable key, and server secret key.

#### Scenario: Secrets are not committed

- GIVEN the tracked repository files
- WHEN key names and Supabase key prefixes are scanned
- THEN no real publishable, secret, anon, or service-role key value is present

### Requirement: Repository Conventions

`AGENTS.md` MUST document Clean Architecture, the three-client model, RLS SELECT/direct-write restrictions, private definer functions, explicit-key idempotency, and the Next.js 16 Proxy convention.

#### Scenario: Conventions are discoverable

- GIVEN `AGENTS.md`
- WHEN searched for each required boundary
- THEN every boundary is documented without recommending deprecated `middleware.ts` or public `SECURITY DEFINER` functions
