import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const schema = await readFile(new URL('../supabase/migrations/20261029000000_initial_schema.sql', import.meta.url), 'utf8');

test('Supabase schema enables row level security on every student-data table', () => {
  for (const table of ['profiles', 'study_requests', 'study_sessions', 'session_participants', 'user_blocks', 'user_reports']) {
    assert.match(schema, new RegExp(`alter table public\\.${table} enable row level security`, 'i'), `${table} must enable RLS`);
  }
});

test('students can read their own profile while campus discovery respects blocks', () => {
  assert.match(schema, /using \(id = \(select auth\.uid\(\)\) or \(/i);
  assert.match(schema, /not \(select public\.is_blocked\(id, \(select auth\.uid\(\)\)\)\)/i);
});

test('study requests enforce sender identity and recipient-controlled decisions', () => {
  assert.match(schema, /with check \(sender_id = \(select auth\.uid\(\)\)/i);
  assert.match(schema, /using \(recipient_id = \(select auth\.uid\(\)\) and status = 'pending'\)/i);
  assert.match(schema, /grant update \(status\) on public\.study_requests to authenticated/i);
});
