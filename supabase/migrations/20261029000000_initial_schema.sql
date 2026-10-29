create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  institution text not null check (char_length(institution) between 1 and 120),
  course text not null check (char_length(course) between 1 and 120),
  year_of_study smallint not null check (year_of_study between 1 and 12),
  modules text[] not null default '{}',
  study_style text not null check (study_style in ('group', 'quiet', 'discussion')),
  availability text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.study_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles (id) on delete cascade,
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'declined', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint different_request_participants check (sender_id <> recipient_id)
);
create index study_requests_recipient_status_idx on public.study_requests (recipient_id, status, created_at desc);
create index study_requests_sender_status_idx on public.study_requests (sender_id, status, created_at desc);

create table public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles (id) on delete cascade,
  institution text not null,
  title text not null check (char_length(title) between 1 and 120),
  module text not null check (char_length(module) between 1 and 80),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  location text,
  is_online boolean not null default false,
  capacity smallint not null default 2 check (capacity between 2 and 50),
  created_at timestamptz not null default now(),
  constraint session_end_after_start check (ends_at > starts_at)
);
create index study_sessions_institution_start_idx on public.study_sessions (institution, starts_at);

create table public.session_participants (
  session_id uuid not null references public.study_sessions (id) on delete cascade,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'joined' check (status in ('joined', 'left')),
  joined_at timestamptz not null default now(),
  primary key (session_id, profile_id)
);

create table public.user_blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint different_block_participants check (blocker_id <> blocked_id)
);

create table public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  reported_id uuid not null references public.profiles (id) on delete cascade,
  reason text not null check (char_length(reason) between 1 and 1000),
  created_at timestamptz not null default now(),
  constraint different_report_participants check (reporter_id <> reported_id)
);

-- SECURITY DEFINER avoids recursive profile RLS when checking campus membership.
create function public.current_institution()
returns text
language sql stable security definer
set search_path = ''
as $$ select p.institution from public.profiles p where p.id = (select auth.uid()) $$;
revoke all on function public.current_institution() from public;
grant execute on function public.current_institution() to authenticated;

create function public.is_blocked(p_first uuid, p_second uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_blocks b
    where (b.blocker_id = p_first and b.blocked_id = p_second)
       or (b.blocker_id = p_second and b.blocked_id = p_first)
  )
$$;
revoke all on function public.is_blocked(uuid, uuid) from public;
grant execute on function public.is_blocked(uuid, uuid) to authenticated;

alter table public.profiles enable row level security;
alter table public.study_requests enable row level security;
alter table public.study_sessions enable row level security;
alter table public.session_participants enable row level security;
alter table public.user_blocks enable row level security;
alter table public.user_reports enable row level security;

create policy "Students can discover campus profiles" on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or (
    institution = (select public.current_institution())
    and not (select public.is_blocked(id, (select auth.uid())))
  ));
create policy "Students can create own profile" on public.profiles
  for insert to authenticated with check (id = (select auth.uid()));
create policy "Students can update own profile" on public.profiles
  for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "Participants can read study requests" on public.study_requests
  for select to authenticated using (sender_id = (select auth.uid()) or recipient_id = (select auth.uid()));
create policy "Students can send requests to campus peers" on public.study_requests
  for insert to authenticated with check (sender_id = (select auth.uid()) and exists (
    select 1 from public.profiles p where p.id = recipient_id and p.institution = (select public.current_institution())
  ));
create policy "Recipients can decide requests" on public.study_requests
  for update to authenticated using (recipient_id = (select auth.uid()) and status = 'pending')
  with check (recipient_id = (select auth.uid()) and status in ('accepted', 'declined'));

create policy "Students can discover campus sessions" on public.study_sessions
  for select to authenticated using (institution = (select public.current_institution()));
create policy "Students can create campus sessions" on public.study_sessions
  for insert to authenticated with check (creator_id = (select auth.uid()) and institution = (select public.current_institution()));
create policy "Creators can update their sessions" on public.study_sessions
  for update to authenticated using (creator_id = (select auth.uid())) with check (creator_id = (select auth.uid()));
create policy "Creators can delete their sessions" on public.study_sessions
  for delete to authenticated using (creator_id = (select auth.uid()));

create policy "Session participants are visible to campus members" on public.session_participants
  for select to authenticated using (exists (select 1 from public.study_sessions s where s.id = session_id and s.institution = (select public.current_institution())));
create policy "Students can join campus sessions" on public.session_participants
  for insert to authenticated with check (profile_id = (select auth.uid()) and exists (
    select 1 from public.study_sessions s where s.id = session_id and s.institution = (select public.current_institution())
  ));
create policy "Students can leave sessions" on public.session_participants
  for update to authenticated using (profile_id = (select auth.uid())) with check (profile_id = (select auth.uid()) and status = 'left');
create policy "Students can remove own participation" on public.session_participants
  for delete to authenticated using (profile_id = (select auth.uid()));

create policy "Students can read own blocks" on public.user_blocks
  for select to authenticated using (blocker_id = (select auth.uid()));
create policy "Students can block peers" on public.user_blocks
  for insert to authenticated with check (blocker_id = (select auth.uid()));
create policy "Students can unblock peers" on public.user_blocks
  for delete to authenticated using (blocker_id = (select auth.uid()));

create policy "Students can submit reports" on public.user_reports
  for insert to authenticated with check (reporter_id = (select auth.uid()));
create policy "Students can read own reports" on public.user_reports
  for select to authenticated using (reporter_id = (select auth.uid()));

grant select, insert, update on public.profiles to authenticated;
grant select, insert on public.study_requests to authenticated;
grant update (status) on public.study_requests to authenticated;
grant select, insert, update, delete on public.study_sessions to authenticated;
grant select, insert, update, delete on public.session_participants to authenticated;
grant select, insert, delete on public.user_blocks to authenticated;
grant select, insert on public.user_reports to authenticated;
