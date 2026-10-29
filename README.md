# Buddy Finder

Find your people. Study better. Succeed together.

Buddy Finder helps university and college students find compatible study partners at their institution, send study requests, and organise study sessions. It is a focused academic tool—not a social feed or chat app.

## MVP features

- Student profiles with institution, course, year, modules, study style, and availability
- Campus-scoped discovery, module search, and compatibility ranking
- Study requests and study sessions
- Privacy controls, blocking, and reporting

## Technology

- Current repository UI: responsive web prototype (plain HTML, CSS, and JavaScript)
- Product target: Flutter mobile app
- Authentication and database target: Supabase Auth + Supabase Postgres
- Access control: PostgreSQL Row Level Security (RLS)

The UI currently uses demonstration profiles and does not yet connect to Supabase. The migration below defines the initial database and RLS policies; it does not configure a hosted project or supply credentials.

## Supabase schema

The migration at `supabase/migrations/20261029000000_initial_schema.sql` creates:

- `profiles`: public student profile fields; no email or private account data
- `study_requests`: request sender, recipient, status, and timestamps
- `study_sessions` and `session_participants`: study session details and membership
- `user_blocks` and `user_reports`: safety controls and reporting

RLS is enabled on every table. Profile discovery and session access are limited to the signed-in student's institution; requests and safety records are limited by participant/owner. The authenticated client must use the Supabase project URL and anon/publishable key only. Never put the service-role key in client code or commit it to this repository.

## Local setup

Requirements: Node.js 20+ and the Supabase CLI. Start the demo UI:

```sh
npm start
```

Then open `http://localhost:4173`.

To run the Supabase database locally (Docker required):

```sh
supabase init   # only if this repository does not already have supabase/config.toml
supabase start
supabase db reset
```

`supabase db reset` applies the migration to the local database. For a hosted project, link the project and explicitly push migrations:

```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

Set the project URL and anon/publishable key in the future app's local environment configuration; those values are intentionally not committed here. Do not use a service-role key in the client. No hosted project is currently configured.

## Checks

```sh
npm test
```

The web demo's profiles, filters, and request interactions are local mock data. Supabase Auth, live profile discovery, persisted requests, and session workflows still need to be wired into the app before it is a hosted product.

## Vision

Finding a study partner who shares your modules and goals should be simple. Buddy Finder helps students find their people, study better, and succeed together.
